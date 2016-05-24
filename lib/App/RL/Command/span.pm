package App::RL::Command::span;
use strict;
use warnings;
use autodie;

use App::RL -command;
use App::RL::Common;

use constant abstract => 'operate spans in a YAML file';

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen." ],
        [   "op=s",
            "operations: cover, holes, trim, pad, excise or fill. Default is [cover]",
            { default => "cover" }
        ],
        [   "number|n=i",
            "Apply this number to trim, pad, excise or fill. Default is [0]",
            { default => 0 }
        ],
        [ "remove|r", "Remove 'chr0' from chromosome names." ],
        [ "mk",       "YAML file contains multiple sets of runlists." ],
    );
}

sub usage_desc {
    my $self = shift;
    my $desc = $self->SUPER::usage_desc;    # "%c COMMAND %o"
    $desc .= " <infile>";
    return $desc;
}

sub description {
    my $desc;
    $desc .= "List of operations.\n";
    $desc .= " " x 4 . "cover:  a single span from min to max;\n";
    $desc .= " " x 4 . "holes:  all the holes in runlist;\n";
    $desc .= " " x 4
        . "trim:   remove N integers from each end of each span of runlist;\n";
    $desc .= " " x 4
        . "pad:    add N integers from each end of each span of runlist;\n";
    $desc .= " " x 4 . "excise: remove all spans smaller than N;\n";
    $desc .= " " x 4 . "fill:   fill in all holes smaller than N.\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    $self->usage_error("This command need one input file.") unless @$args;
    $self->usage_error("The input file [@{[$args->[0]]}] doesn't exist.")
        unless -e $args->[0];

    if ( $opt->{op} =~ /^cover/i ) {
        $opt->{op} = 'cover';
    }
    elsif ( $opt->{op} =~ /^hole/i ) {
        $opt->{op} = 'holes';
    }
    elsif ( $opt->{op} =~ /^trim/i ) {
        $opt->{op} = 'trim';
    }
    elsif ( $opt->{op} =~ /^pad/i ) {
        $opt->{op} = 'pad';
    }
    elsif ( $opt->{op} =~ /^excise/i ) {
        $opt->{op} = 'excise';
    }
    elsif ( $opt->{op} =~ /^fill/i ) {
        $opt->{op} = 'fill';
    }
    else {
        Carp::confess "[@{[$opt->{op}]}] is invalid\n";
    }

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = $opt->{op} . ".yml";
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    #----------------------------#
    # Loading
    #----------------------------#
    my $infile;    # YAML::Syck::LoadFile handles IO::*
    if ( lc $args->[0] eq 'stdin' ) {
        $infile = *STDIN;
    }
    else {
        $infile = $args->[0];
    }

    my $s_of = {};
    my @keys;
    if ( $opt->{mk} ) {
        my $yml = YAML::Syck::LoadFile($infile);
        @keys = sort keys %{$yml};

        for my $key (@keys) {
            $s_of->{$key}
                = App::RL::Common::runlist2set( $yml->{$key}, $opt->{remove} );
        }
    }
    else {
        @keys = ("__single");
        $s_of->{__single}
            = App::RL::Common::runlist2set( YAML::Syck::LoadFile($infile),
            $opt->{remove} );
    }

    #----------------------------#
    # Operating
    #----------------------------#
    my $op_result_of = { map { $_ => {} } @keys };

    for my $key (@keys) {
        my $s = $s_of->{$key};

        for my $chr ( keys %{$s} ) {
            my $op     = $opt->{op};
            my $op_set = $s->{$chr}->$op( $opt->{number} );
            $op_result_of->{$key}{$chr} = $op_set->runlist;
        }
    }

    #----------------------------#
    # Output
    #----------------------------#
    my $out_fh;
    if ( lc( $opt->{outfile} ) eq "stdout" ) {
        $out_fh = *STDOUT;
    }
    else {
        open $out_fh, ">", $opt->{outfile};
    }

    if ( $opt->{mk} ) {
        print {$out_fh} YAML::Syck::Dump($op_result_of);
    }
    else {
        print {$out_fh} YAML::Syck::Dump( $op_result_of->{__single} );
    }

    close $out_fh;
}

1;
