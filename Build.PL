use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'GetOpt::Alt',
    license             => 'perl',
    dist_author         => 'Ivan <ivan.wills@gmail.com>',
    dist_version_from   => 'lib/GetOpt/Alt.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'GetOpt-Alt-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
