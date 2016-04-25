package App::RL::Command::stat;

use App::RL -command;
use App::RL::Common qw(:all);

use constant abstract => 'coverage on chromosomes for runlists';

sub opt_spec {
    return (
        [ "outfile|o=s", "Output filename. [stdout] for screen." ],
        [ "size|s=s", "chr.sizes", { required => 1 } ],
        [ "remove|r", "Remove 'chr0' from chromosome names." ],
        [ "mk",       "YAML file contains multiple sets of runlists." ],
        [ "all",      "Only write whole genome stats." ],
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
    $desc .= "Coverage statistics.\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    $self->usage_error("This command need one input file.") unless @$args;
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
        my $yml = YAML::Syck::LoadFile( $args->[0] );
        @keys = sort keys %{$yml};

        for my $key (@keys) {
            $s_of->{$key} = runlist2set( $yml->{$key}, $opt->{remove} );
        }
    }
    else {
        @keys = ("__single");
        $s_of->{__single}
            = runlist2set( YAML::Syck::LoadFile( $args->[0] ), $opt->{remove} );
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

    my $header = sprintf "key,chr,chr_length,size,coverage\n";
    if ( $opt->{mk} ) {
        if ( $opt->{all} ) {
            $header =~ s/chr\,//;
        }
        my @lines = ($header);

        for my $key (@keys) {
            my @key_lines = csv_lines( $s_of->{$key}, $length_of, $opt->{all} );
            $_ = "$key,$_" for @key_lines;
            push @lines, @key_lines;
        }

        print {$out_fh} $_ for @lines;
    }
    else {
        $header =~ s/key\,//;
        if ( $opt->{all} ) {
            $header =~ s/chr\,//;
        }
        my @lines = ($header);

        push @lines, csv_lines( $s_of->{__single}, $length_of, $opt->{all} );
        print {$out_fh} $_ for @lines;
    }

    close $out_fh;
    return;
}

sub csv_lines {
    my $set_of    = shift;
    my $length_of = shift;
    my $all       = shift;

    my @lines;
    my ( $all_length, $all_size, $all_coverage );
    for my $chr ( sort keys %{$set_of} ) {
        my $length   = $length_of->{$chr};
        my $size     = $set_of->{$chr}->size;
        my $coverage = sprintf "%.4f", $size / $length;

        $all_length += $length;
        $all_size   += $size;

        push @lines, "$chr,$length,$size,$coverage\n";
    }
    $all_coverage = sprintf "%.4f", $all_size / $all_length;

    # only keep whole genome
    my $all_line = "all,$all_length,$all_size,$all_coverage\n";
    if ($all) {
        @lines = ();
        $all_line =~ s/all,//;
    }
    push @lines, $all_line;

    return @lines;
}

1;
