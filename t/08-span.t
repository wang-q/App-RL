use Test::More;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(help span)] );
like( $result->stdout, qr{span}, 'descriptions' );

$result = test_app( 'App::RL' => [qw(span t/brca2.yml --op cover -o stdout)] );

is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 2, 'line count' );
like( $result->stdout, qr{32316461\-32398770}, 'cover' );

$result = test_app( 'App::RL' => [qw(span t/brca2.yml --op fill -n 1000 -o stdout)] );

is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 2, 'line count' );
like( $result->stdout, qr{32325076\-32326613}, 'fill' );

done_testing(5);
