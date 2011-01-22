use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Getopt::Alt',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/Getopt/Alt.pm',
    requires => {
        'perl'        => 5.008,
        'version'     => 0,
        'Config::Any' => 0,
        'Moose'       => 0,
    },
    build_requires => {
        'Test::More'       => 0,
        'Test::NoWarnings' => 0,
    },
    add_to_cleanup     => [ 'Getopt-Alt-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge         => {
        resources => {
            repository => 'http://github.com/ivanwills/Getopt-Alt',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Getopt-Alt',
        },
    },
);

$builder->create_build_script();
