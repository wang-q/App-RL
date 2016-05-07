use Test::More;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(help genome)] );
like( $result->stdout, qr{genome}, 'descriptions' );

$result = test_app( 'App::RL' => [qw(genome t/chr.sizes -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 17, 'line count' );
like( $result->stdout, qr{I\:\s+1\-230218}, 'first chromosome' );

done_testing(3);
