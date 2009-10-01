use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'GetOpt::Alt',
	license             => 'perl',
	dist_author         => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from   => 'lib/GetOpt/Alt.pm',
	requires => {
		'version'     => 0,
		'Config::Any' => 0,
		'Moose'       => 0,
	},
	build_requires => {
		'Test::More' => 0,
	},
	add_to_cleanup     => [ 'GetOpt-Alt-*' ],
	create_makefile_pl => 'traditional',
	create_licence     => 1,
);

$builder->create_build_script();
