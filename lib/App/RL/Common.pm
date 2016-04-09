package App::RL::Common;
use strict;
use warnings;
use autodie;

use 5.008001;

use Carp;
use IO::Zlib;
use List::MoreUtils;
use Path::Tiny;
use Set::Scalar;
use Tie::IxHash;
use YAML::Syck;

use AlignDB::IntSpanXS;

use base 'Exporter';
use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter);
%EXPORT_TAGS = (
    all => [
        qw{
            read_sizes read_names new_set runlist2set decode_header
            },
    ],
);
@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

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

# The only entrance for AlignDB::IntSpan or AlignDB::IntSpanXS
sub new_set {
    return AlignDB::IntSpanXS->new;
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

    # S288C.chrI(+):27070-29557|species=S288C
    my $head_qr = qr{
        (?:(?P<name>[\w_]+)\.)?
        (?P<chr_name>[\w-]+)
        (?:\((?P<chr_strand>.+)\))?
        [\:]                        # spacer
        (?P<chr_start>\d+)
        [\_\-]                      # spacer
        (?P<chr_end>\d+)
    }xi;

    tie my %info, "Tie::IxHash";

    $header =~ $head_qr;
    my $name     = $1;
    my $chr_name = $2;

    if ( defined $name or defined $chr_name ) {
        %info = (
            name       => $name,
            chr_name   => $chr_name,
            chr_strand => $3,
            chr_start  => $4,
            chr_end    => $5,
        );
        if ( !defined $info{chr_strand} ) {
            $info{chr_strand} = '+';
        }
        elsif ( $info{chr_strand} eq '1' ) {
            $info{chr_strand} = '+';
        }
        elsif ( $info{chr_strand} eq '-1' ) {
            $info{chr_strand} = '-';
        }
    }
    else {
        $name = $header;
        %info = (
            name       => undef,
            chr_name   => 'chrUn',
            chr_strand => '+',
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

1;
