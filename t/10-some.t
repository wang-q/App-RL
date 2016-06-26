use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::RL;

my $result = test_app( 'App::RL' => [qw(help some)] );
like( $result->stdout, qr{some}, 'descriptions' );

$result = test_app( 'App::RL' => [qw(some t/Atha.yml t/Atha.list -o stdout)] );

is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 7, 'line count' );
like( $result->stdout, qr{AT2G01008}, 'present' );
unlike( $result->stdout, qr{AT2G01021}, 'absent' );

done_testing(4);
