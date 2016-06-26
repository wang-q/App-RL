use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(help stat2 -s t/chr.sizes)] );
like( $result->stdout, qr{stat2}, 'descriptions' );

$result
    = test_app(
    'App::RL' => [qw(stat2 --op intersect t/intergenic.yml t/repeat.yml -s t/chr.sizes -o stdout)]
    );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 18, 'line count' );
is( ( scalar( split ",", ( split( /\n/, $result->stdout ) )[1] ) ), 8, 'field count' );
like( $result->stdout, qr{36721},   'sum exists' );
like( $result->stdout, qr{I.+XVI}s, 'chromosomes exist' );

$result
    = test_app( 'App::RL' =>
        [qw(stat2 --op intersect t/intergenic.yml t/repeat.yml -s t/chr.sizes --all -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 2, 'line count' );
is( ( scalar( split ",", ( split( /\n/, $result->stdout ) )[1] ) ), 7, 'field count' );
like( $result->stdout, qr{36721}, 'sum exists' );
unlike( $result->stdout, qr{I.+XVI}s, 'chromosomes do not exist' );

done_testing(9);
