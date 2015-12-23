use Test::More tests => 3;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(merge t/I.yml t/II.yml -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 3, 'line count' );
like( $result->stdout, qr{28547\-29194}, 'runlist exists' );

$result = test_app( 'App::RL' => [qw(merge t/I.yml t/II.yml -o stdout)] );
like( $result->stdout, qr{^I\:.+^II\:}m, 'chromosomes exist' );
