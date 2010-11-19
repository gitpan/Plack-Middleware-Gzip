use strict;
use warnings;
use Test::More tests => 8;
use HTTP::Request::Common;
use Plack::Builder;
use Plack::Test;
use Compress::Zlib;
require bytes;

my $testtext = "TestText\n" x 100;

my $app = builder {
    enable 'Plack::Middleware::Gzip';
    sub {
	[
	 '200',
	 ['Content-Type' => 'text/html'],
	 [$testtext]
	]
    };
};

my $client = sub{
    my $cb = shift;

    {
        my $req = GET "http://localhost/";
	$req->header('Accept-Encoding' => 'gzip,deflate');
        my $res = $cb->($req);

	ok(defined($res->header('Content-Encoding')));
	cmp_ok(Compress::Zlib::memGunzip($res->content), 'eq', $testtext);
	ok(defined($res->header('Content-Length')));
	cmp_ok(bytes::length($res->content), '==', $res->header('Content-Length'));
    }
};

test_psgi app => $app, client => $client;

$app = builder {
    enable 'Plack::Middleware::Gzip';
    sub {
	[
	 '200',
	 [
	  'Content-Type'   => 'text/html',
	  'Content-Length' => bytes::length($testtext)
	 ],
	 [$testtext]
	]
    };
};

test_psgi app => $app, client => $client;

done_testing;
