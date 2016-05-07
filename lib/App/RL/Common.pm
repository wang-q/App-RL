package App::RL::Common;
use strict;
use warnings;
use autodie;

use 5.010000;

use Carp;
use IO::Zlib;
use List::MoreUtils;
use Path::Tiny;
use Set::Scalar;
use Tie::IxHash;
use YAML::Syck;

use AlignDB::IntSpan;

# The only entrance for AlignDB::IntSpan or AlignDB::IntSpanXS
sub new_set {
    return AlignDB::IntSpan->new;
}

sub read_sizes {
    my $file       = shift;
    my $remove_chr = shift;

    my @lines = path($file)->lines( { chomp => 1 } );
    my %length_of;
    for (@lines) {
        my ( $key, $value ) = split /\t/;
        $key =~ s/chr0?// if $remove_chr;
        $length_of{$key} = $value;
    }

    return \%length_of;
}

sub read_names {
    my $file = shift;

    my @lines = path($file)->lines( { chomp => 1 } );

    return \@lines;
}

sub runlist2set {
    my $runlist_of = shift;
    my $remove_chr = shift;

    my $set_of = {};

    for my $chr ( sort keys %{$runlist_of} ) {
        my $new_chr = $chr;
        $new_chr =~ s/chr0?// if $remove_chr;
        my $set = new_set();
        $set->add( $runlist_of->{$chr} );
        $set_of->{$new_chr} = $set;
    }

    return $set_of;
}

sub decode_header {
    my $header = shift;

    tie my %info, "Tie::IxHash";

    # S288.chrI(+):27070-29557|species=S288C
    my $head_qr = qr{
        (?:(?P<name>[\w_]+)\.)?
        (?P<chr_name>[\w-]+)
        (?:\((?P<chr_strand>.+)\))?
        [\:]                        # spacer
        (?P<chr_start>\d+)
        [\_\-]?                      # spacer
        (?P<chr_end>\d+)?
    }xi;

    $header =~ $head_qr;
    my $chr_name  = $2;
    my $chr_start = $4;
    my $chr_end   = $5;

    if ( defined $chr_name and defined $chr_start ) {
        if ( !defined $chr_end ) {
            $chr_end = $chr_start;
        }
        %info = (
            name       => $1,
            chr_name   => $chr_name,
            chr_strand => $3,
            chr_start  => $chr_start,
            chr_end    => $chr_end,
        );
        if ( defined $info{chr_strand} ) {
            if ( $info{chr_strand} eq '1' ) {
                $info{chr_strand} = '+';
            }
            elsif ( $info{chr_strand} eq '-1' ) {
                $info{chr_strand} = '-';
            }
        }
    }
    else {
        $header =~ /^(\S+)/;
        my $name = $1;
        %info = (
            name       => $name,
            chr_name   => undef,
            chr_strand => undef,
            chr_start  => undef,
            chr_end    => undef,
        );
    }

    # additional keys
    if ( $header =~ /\|(.+)/ ) {
        my @parts = grep {defined} split /;/, $1;
        for my $part (@parts) {
            my ( $key, $value ) = split /=/, $part;
            if ( defined $key and defined $value ) {
                $info{$key} = $value;
            }
        }
    }

    return \%info;
}

sub encode_header {
    my $info           = shift;
    my $only_essential = shift;

    my $header;
    if ( defined $info->{name} ) {
        if ( defined $info->{chr_name} ) {
            $header .= $info->{name};
            $header .= "." . $info->{chr_name};
        }
        else {
            $header .= $info->{name};
        }
    }
    elsif ( defined $info->{chr_name} ) {
        $header .= $info->{chr_name};
    }

    if ( defined $info->{chr_strand} ) {
        $header .= "(" . $info->{chr_strand} . ")";
    }
    if ( defined $info->{chr_start} ) {
        $header .= ":" . $info->{chr_start};
        if ( $info->{chr_end} != $info->{chr_start} ) {
            $header .= "-" . $info->{chr_end};
        }
    }

    # additional keys
    if ( !$only_essential ) {
        my %essential = map { $_ => 1 } qw{name chr_name chr_strand chr_start chr_end seq full_seq};
        my @parts;
        for my $key ( sort keys %{$info} ) {
            if ( !$essential{$key} ) {
                push @parts, $key . "=" . $info->{$key};
            }
        }
        if (@parts) {
            my $additional = join ";", @parts;
            $header .= "|" . $additional;
        }
    }

    return $header;
}

1;
