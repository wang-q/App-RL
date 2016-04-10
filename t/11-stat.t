use Test::More tests => 2;
use App::Cmd::Tester;

use App::RL;

my $result = test_app(
    'App::RL' => [qw(stat t/intergenic.yml -s t/chr.sizes -o stdout)] );

is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 18, 'line count' );
like( $result->stdout, qr{all,12071326,1059702,}, 'result calced' );
