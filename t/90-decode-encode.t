use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok( 'App::RL::Common', qw(decode_header encode_header) );
}

{
    print "#fas headers\n";

    my @data_fas_header = (
        [   q{S288c.I(+):27070-29557|species=yeast},
            {   name       => "S288c",
                chr_name   => "I",
                chr_strand => "+",
                chr_start  => 27070,
                chr_end    => 29557,
                species    => "yeast",
            }
        ],
        [   q{S288c.I(+):27070-29557},
            {   name       => "S288c",
                chr_name   => "I",
                chr_strand => "+",
                chr_start  => 27070,
                chr_end    => 29557,
            }
        ],
        [   q{I(+):90-150},
            {   chr_name   => "I",
                chr_strand => "+",
                chr_start  => 90,
                chr_end    => 150,
            }
        ],
        [   q{S288c.I(-):190-200},
            {   name       => "S288c",
                chr_name   => "I",
                chr_strand => "-",
                chr_start  => 190,
                chr_end    => 200,
            }
        ],
        [   q{I:1-100},
            {   chr_name  => "I",
                chr_start => 1,
                chr_end   => 100,
            }
        ],
        [   q{I:100},
            {   chr_name  => "I",
                chr_start => 100,
                chr_end   => 100,
            }
        ],
        [ q{S288c}, { name => "S288c", } ],
    );

    for my $i ( 0 .. $#data_fas_header ) {
        my ( $header, $expected ) = @{ $data_fas_header[$i] };
        my $result = decode_header($header);

        for my $key ( keys %{$expected} ) {
            is( $expected->{$key}, $result->{$key}, "fas decode $i" );
        }
        for my $key ( keys %{$result} ) {
            next if !defined $result->{$key};
            is( $expected->{$key}, $result->{$key}, "fas decode $i" );
        }

        is( $header, encode_header($expected), "fas encode expected $i" );
        is( $header, encode_header($result),   "fas encode result $i" );
    }
}

{
    print "#fa headers\n";

    my @data_fa_header = (
        [ q{S288c},                   { name => "S288c", } ],
        [ q{S288c The baker's yeast}, { name => "S288c", } ],
        [ q{1:-100},                  { name => "1:-100", } ],
    );

    for my $i ( 0 .. $#data_fa_header ) {
        my ( $header, $expected ) = @{ $data_fa_header[$i] };
        my $result = decode_header($header);
        for my $key ( keys %{$expected} ) {
            is( $expected->{$key}, $result->{$key}, "fa decode $i" );
        }
    }
}

done_testing(72);
