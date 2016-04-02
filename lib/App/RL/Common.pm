package App::RL::Common;
use strict;
use warnings;
use autodie;

use 5.008001;

use Carp;
use List::MoreUtils;
use Path::Tiny;
use Set::Scalar;
use YAML::Syck;

use AlignDB::IntSpan;

use base 'Exporter';
use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter);
%EXPORT_TAGS = (
    all => [
        qw{
            read_sizes read_names new_set runlist2set
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
    return AlignDB::IntSpan->new;
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

1;
