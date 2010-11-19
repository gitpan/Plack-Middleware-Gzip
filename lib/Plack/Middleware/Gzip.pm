package Plack::Middleware::Gzip;

use strict;
use warnings;
use Carp;

use version;
our $VERSION = qv('0.0.1');

use 5.008_001;
use parent qw(Plack::Middleware); 
use Compress::Zlib;
use Scalar::Util;

use bytes;

our $BUFFER_SIZE = 512;

sub call {
    my($self, $env) = @_;
    my $res = $self->app->($env);
    
    if((exists($env->{HTTP_ACCEPT_ENCODING}) &&
	$env->{HTTP_ACCEPT_ENCODING} =~ /gzip/)
	){
	my $size = 0;
	my $head = $res->[1];
	my $body = $res->[2];
	
	# body compress
	if(ref($body) eq 'ARRAY'){
	    foreach(@{$body}){
		$_ = Compress::Zlib::memGzip($_);
		$size += bytes::length($_);
	    }
	}elsif(is_fh($body)){
	    # read file and compless
	    my $fh = $body;
	    
	    my($read, $raw_body);
	    while(read($fh, $read, $BUFFER_SIZE)){
		$raw_body .= $read;
	    }
	    close($fh);

	    $body = [Compress::Zlib::memGzip($raw_body)];
	    $size = bytes::length($body->[0]);
	}else{
	    last;
	}

	# add 'Content-Encoding' header
	push(@$head, 'Content-Encoding' => 'gzip');
	
	# search 'Content-Size' header
	my $add_point;
	for(my $i = 0; $i <= $#{$head}; $i += 2){
	    if($head->[$i] =~ /Content-Length/io){
		$add_point = $i;
		last;
	    }
	}
	
	# add or edit 'Content-Size' header
	if(defined($add_point)){
	    $head->[++$add_point] = $size;
	}else{
	    push(@$head, 'Content-Length' => $size);
	}
	
	# commit
	$res->[2] = $body;
    }
    
    return $res;
}

sub is_fh{
    my $fh = shift;
    my $reftype = Scalar::Util::reftype($fh);
    
    ($reftype =~ /^IO/ or  ($reftype eq 'GLOB' && *{$fh}{IO})) ? 1 : 0;
}

1;
__END__

=head1 NAME

Plack::Middleware::Gzip - gzip compless HTTP response

=head1 SYNOPSIS

    use Plack::Builder;
 
    my $app = sub {['200', ['Content-Type' => 'text/plain'], ['foobar']]};
    builder {
        enable 'Gzip';
        $app;
    }

=head1 DESCRIPTION

Plack::Middleware::Gzip

=head1 AUTHOR

Kenta Sato  C<< <kenta.sato.1990@gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Kenta Sato C<< <kenta.sato.1990@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO
 
L<Plack::Middleware> L<Plack::Builder>
 
=cut
