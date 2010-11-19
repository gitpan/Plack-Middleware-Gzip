use strict;
use warnings;
use Test::More tests => 16;
use HTTP::Request::Common;
use Plack::Builder;
use Plack::Test;
use Compress::Zlib;
use IO::String;
require bytes;

my $testtext = "TestText\n" x 5;
open(my $fh, 'test.txt');

my $app = builder {
    enable 'Plack::Middleware::Gzip';
    sub {
	[
	 '200',
	 ['Content-Type' => 'text/html'],
	 $fh
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
undef $fh;

$fh = IO::String->new($testtext);

use Data::Dumper;

$app = builder {
    enable 'Plack::Middleware::Gzip';
    sub {
	[
	 '200',
	 ['Content-Type' => 'text/html'],
	 $fh
	]
    };
};
test_psgi app => $app, client => $client;
undef $fh;

open($fh, 'test.txt');
$app = builder {
    enable 'Plack::Middleware::Gzip';
    sub {
	[
	 '200',
	 [
	  'Content-Type'   => 'text/html',
	  'Content-Length' => bytes::length($testtext)
	 ],
	 $fh
	]
    };
};

test_psgi app => $app, client => $client;
undef $fh;

$fh = IO::String->new($testtext);
$app = builder {
    enable 'Plack::Middleware::Gzip';
    sub {
	[
	 '200',
	 [
	  'Content-Type'   => 'text/html',
	  'Content-Length' => bytes::length($testtext)
	 ],
	 $fh
	]
    };
};

test_psgi app => $app, client => $client;
undef $fh;

done_testing;
