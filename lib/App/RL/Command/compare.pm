package App::RL::Command::compare;

use App::RL -command;

use constant abstract => 'compare 2 chromosome runlists';

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen." ],
        [   "op=s",
            "operations: intersect, union, diff or xor. Default is [intersect]",
            { default => "intersect" }
        ],
        [ "remove|r", "Remove 'chr0' from chromosome names." ],
        [ "mk",       "*Fisrt* YAML file contains multiple sets of runlists." ],
    );
}

sub usage_desc {
    my $self = shift;
    my $desc = $self->SUPER::usage_desc;    # "%c COMMAND %o"
    $desc .= " <infiles>";
    return $desc;
}

sub description {
    my $desc;
    $desc .= "Coverage statistics.\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    #print YAML::Syck::Dump {
    #    opt  => $opt,
    #    args => $args,
    #};

    $self->usage_error("This command need two input files.") unless @$args == 2;
    $self->usage_error("The first input file [@{[$args->[0]]}] doesn't exist.")
        unless -e $args->[0];
    $self->usage_error("The second input file [@{[$args->[1]]}] doesn't exist.")
        unless -e $args->[1];

    if ( $opt->{op} =~ /^dif/i ) {
        $opt->{op} = 'diff';
    }
    elsif ( $opt->{op} =~ /^uni/i ) {
        $opt->{op} = 'union';
    }
    elsif ( $opt->{op} =~ /^int/i ) {
        $opt->{op} = 'intersect';
    }
    elsif ( $opt->{op} =~ /^xor/i ) {
        $opt->{op} = 'xor';
    }
    else {
        Carp::confess "[@{[$opt->{op}]}] invalid\n";
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
    my $all_name_set = Set::Scalar->new;

    # file1
    my $s1_of = {};
    my @keys;
    if ( $opt->{mk} ) {
        my $yml = YAML::Syck::LoadFile( $args->[0] );
        @keys = sort keys %{$yml};

        for my $key (@keys) {
            $s1_of->{$key} = App::RL::runlist2set( $yml->{$key}, $opt->{remove} );
            $all_name_set->insert( keys %{ $s1_of->{$key} } );
        }
    }
    else {
        @keys = ("__single");
        $s1_of->{__single}
            = App::RL::runlist2set( YAML::Syck::LoadFile( $args->[0] ), $opt->{remove} );
        $all_name_set->insert( keys %{ $s1_of->{__single} } );
    }

    # file2
    my $s2;
    {
        $s2 = App::RL::runlist2set( YAML::Syck::LoadFile( $args->[1] ), $opt->{remove} );
        $all_name_set->insert( keys %{$s2} );
    }

    #----------------------------#
    # Operation
    #----------------------------#
    my $op_result_of = { map { $_ => {} } @keys };

    for my $key (@keys) {
        my $s1 = $s1_of->{$key};

        # give empty set to non-existing chrs
        for my $s ( $s1, $s2 ) {
            for my $chr ( $all_name_set->members ) {
                if ( !exists $s->{$chr} ) {
                    $s->{$chr} = AlignDB::IntSpan->new;
                }
            }
        }

        # operate on each chr
        for my $chr ( sort $all_name_set->members ) {
            my $op     = $opt->{op};
            my $op_set = $s1->{$chr}->$op( $s2->{$chr} );
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
    return;
}

1;
