use Test::More;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(help stat -s t/chr.sizes)] );
like( $result->stdout, qr{stat}, 'descriptions' );

$result = test_app( 'App::RL' => [qw(stat t/intergenic.yml -s t/chr.sizes -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 18, 'line count' );
is( ( scalar( split ",", ( split( /\n/, $result->stdout ) )[1] ) ), 4, 'field count' );
like( $result->stdout, qr{all,12071326,1059702,}, 'result calced' );

$result = test_app( 'App::RL' => [qw(stat t/intergenic.yml -s t/chr.sizes --all -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 2, 'line count' );
is( ( scalar( split ",", ( split( /\n/, $result->stdout ) )[1] ) ), 3, 'field count' );
unlike( $result->stdout, qr{all}, 'no literal all' );

done_testing(7);
