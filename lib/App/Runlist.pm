package App::Runlist;
use strict;
use warnings;
use autodie;

use 5.008001;

our $VERSION = '0.0.1';

use App::Cmd::Setup -app;
use Carp;
use List::MoreUtils;
use Path::Tiny;
use YAML::Syck;

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
        my $set = AlignDB::IntSpan->new( $runlist_of->{$chr} );
        printf "\tkey:\t%s\tlength:\t%s\n", $new_chr, $set->size;
        $set_of->{$new_chr} = $set;
    }

    return $set_of;
}

1;

__END__

=head1 NAME

App::Runlist - operating chromosome runlist files

=head1 SYNOPSIS

    commands: list the application's commands
        help: display a command's help screen

       merge: convert axt to blocked fasta
        stat: convert maf to blocked fasta

See C<runlist commands> for usage information.

=cut

=head1 LICENSE

Copyright 2015- Qiang Wang

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Qiang Wang

=cut
