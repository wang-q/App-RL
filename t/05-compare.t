use Test::More tests => 3;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(compare --op intersect t/intergenic.yml t/repeat.yml -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 17, 'line count' );
like( $result->stdout, qr{878539\-878709}, 'runlist exists' );

like( $result->stdout, qr{I:.+XVI:}s, 'chromosomes exist' );
