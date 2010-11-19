use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Plack::Middleware::Gzip',
    license             => 'perl',
    dist_author         => 'Kenta Sato <kenta.sato.1990@gmail.com>',
    dist_version_from   => 'lib/Plack/Middleware/Gzip.pm',
    requires => {
        'Test::More'        => 0,
        'version'           => 0,
	'parent'            => 0,
	'Plack::Middleware' => 0,
	'Compress::Zlib'    => 0,
	'Scalar::Util'      => 0
    },
    add_to_cleanup      => [ 'Plack-Middleware-Gzip-*' ],
);

$builder->create_build_script();
