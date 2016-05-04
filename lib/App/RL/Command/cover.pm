package App::RL::Command::cover;

use App::RL -command;
use App::RL::Common qw(:all);

use constant abstract => 'output covers of positions on chromosomes';

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen." ],
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
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= " " x 4 . "Like `runlist combine`, but <infiles> are genome positions.\n";
    $desc .= " " x 4 . "I:1-100\n";
    $desc .= " " x 4 . "I(+):90-150\n";
    $desc .= " " x 4 . "S288c.I(-):190-200\tSpecies names will be omitted.\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    $self->usage_error("This command need one or more input files.") unless @{$args};
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".yml";
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my %count_of;    # YAML::Sync can't Dump tied hashes
    for my $infile ( @{$args} ) {
        my $in_fh = IO::Zlib->new( $infile, "rb" );

        while ( !$in_fh->eof ) {
            $line = $in_fh->getline;
            next if substr( $line, 0, 1 ) eq "#";
            chomp $line;

            my $info = decode_header($line);

            next unless defined $info->{chr_name};
            next unless defined $info->{chr_start};
            next unless defined $info->{chr_end};

            my $chr_name = $info->{chr_name};
            if ( !exists $count_of{$chr_name} ) {
                $count_of{$chr_name} = new_set();
            }
            $count_of{$chr_name}->add_pair( $info->{chr_start}, $info->{chr_end} );
        }

        $in_fh->close;
    }

    # IntSpan to runlist
    for my $chr_name ( keys %count_of ) {
        $count_of{$chr_name} = $count_of{$chr_name}->runlist;
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

    print {$out_fh} YAML::Syck::Dump( \%count_of );
    close $out_fh;
}

1;
