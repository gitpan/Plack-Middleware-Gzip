use Test::More tests => 1;

BEGIN {
use_ok( 'Plack::Middleware::Gzip' );
}

diag( "Testing Plack::Middleware::Gzip $Plack::Middleware::Gzip::VERSION" );
