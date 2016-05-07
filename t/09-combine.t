use Test::More;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(help combine)] );
like( $result->stdout, qr{combine}, 'descriptions' );

$result = test_app( 'App::RL' => [qw(combine t/Atha.yml -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 3, 'line count' );
unlike( $result->stdout, qr{7232\,7384}, 'combined' );

$result = test_app( 'App::RL' => [qw(combine t/brca2.yml -o stdout)] );

is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 2, 'line count' );
like( $result->stdout, qr{13\: 32316461\-32316527}, 'no changes' );

done_testing(5);
