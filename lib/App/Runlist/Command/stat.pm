package App::Runlist::Command::merge;

use App::Runlist -command;

use constant abstract => 'coverage on chromosomes for runlists';

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen." ],
        [ "size|s=s", "chr.sizes", { required => 1 } ],
        [ "remove|r", "Remove 'chr0' from chromosome names." ],
        [ "mk",       "YAML file contains multiple sets of runlists." ],
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

    $self->usage_error("This command need one input files.") unless @$args;
    $self->usage_error("The input file [@{[$args->[0]]}] doesn't exist.")
        unless -e $args->[0];

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".csv";
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    #----------------------------#
    # Loading
    #----------------------------#
    my $length_of = read_sizes( $opt->{size}, $opt->{remove} );

    my $s_of = {};
    my @keys;
    if ( $opt->{mk} ) {
        my $yml = LoadFile( $args->[0] );
        @keys = sort keys %{$yml};

        for my $key (@keys) {
            $s_of->{$key} = runlist2set( $yml->{$key}, $opt->{remove} );
        }
    }
    else {
        @keys = ("__single");
        $s_of->{__single} = runlist2set( LoadFile( $args->[0] ), $opt->{remove} );
    }

    #----------------------------#
    # Calcing
    #----------------------------#
    my $out_fh;
    if ( lc( $opt->{outfile} ) eq "stdout" ) {
        $out_fh = *STDOUT;
    }
    else {
        open $out_fh, ">", $opt->{outfile};
    }

    if ( $opt->{mk} ) {
        my @lines;
        for my $key (@keys) {
            my @key_lines = csv_lines( $s_of->{$key}, $length_of );
            $_ = "$key,$_" for @key_lines;
            push @lines, @key_lines;
        }

        unshift @lines, "key,name,length,size,coverage\n";
        print {$out_fh} $_ for @lines;
    }
    else {
        my @lines = csv_lines( $s_of->{__single}, $length_of );

        unshift @lines, "name,length,size,coverage\n";
        print {$out_fh} $_ for @lines;
    }

    close $out_fh;
    return;
}

sub csv_lines {
    my $set_of    = shift;
    my $length_of = shift;

    my @lines;

    my ( $all_length, $all_size, $all_coverage );
    for my $chr ( sort keys %{$set_of} ) {
        my $length   = $length_of->{$chr};
        my $size     = $set_of->{$chr}->size;
        my $coverage = $size / $length;

        $all_length += $length;
        $all_size   += $size;

        push @lines, "$chr,$length,$size,$coverage\n";
    }

    $all_coverage = $all_size / $all_length;
    push @lines, "all,$all_length,$all_size,$all_coverage\n";

    return @lines;
}

1;
