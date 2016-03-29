package App::RL::Command::combine;

use App::RL -command;
use App::RL::Common qw(:all);

use constant abstract => 'combine multiple sets of runlists';

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen." ],
        [ "remove|r",    "Remove 'chr0' from chromosome names." ],
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
    $desc .= "Combine multiple sets of runlists.\n";
    $desc .= " " x 4 . "It's expected that the YAML file is --mk.\n";
    $desc .= " " x 4 . "Otherwise this command will make no effects.\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    $self->usage_error("This command need one input files.") unless @$args;
    $self->usage_error("The input file [@{[$args->[0]]}] doesn't exist.")
        unless -e $args->[0];

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".combine.yml";
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    #----------------------------#
    # Loading
    #----------------------------#
    my $s_of         = {};
    my $all_name_set = Set::Scalar->new;

    my $yml  = YAML::Syck::LoadFile( $args->[0] );
    my @keys = sort keys %{$yml};

    if ( ref $yml->{ $keys[0] } eq 'HASH' ) {
        for my $key (@keys) {
            $s_of->{$key} = runlist2set( $yml->{$key}, $opt->{remove} );
            $all_name_set->insert( keys %{ $s_of->{$key} } );
        }
    }
    else {
        @keys = ("__single");
        $s_of->{__single}
            = runlist2set( $yml, $opt->{remove} );
        $all_name_set->insert( keys %{ $s_of->{__single} } );
    }

    #----------------------------#
    # Operating
    #----------------------------#
    my $op_result_of = { map { $_ => AlignDB::IntSpan->new } $all_name_set->members };

    for my $key (@keys) {
        my $s = $s_of->{$key};
        for my $chr ( keys %{$s} ) {
            $op_result_of->{$chr}->add( $s->{$chr} );
        }
    }

    # convert sets to runlists
    for my $chr ( keys %{$op_result_of} ) {
        $op_result_of->{$chr} = $op_result_of->{$chr}->runlist;
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

    print {$out_fh} YAML::Syck::Dump($op_result_of);

    close $out_fh;
    return;
}

1;
