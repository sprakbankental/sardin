package Test::MTM::Analysis::Email;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

use utf8;

require MTM::TTSChunk;

sub class {'MTM::Analysis::Email'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Email');
}

sub markup : Tests(30) {
	my $test = shift;

	$test->chunk_assert('svd@svd.se', 'EMAIL', 0, 'svd', '@', 'svd', '.', 'se');
	$test->chunk_assert('lisa.larsson_99@comhem.com', 'EMAIL', 0, 'lisa',	'.', 'larsson', '_', '99', '@', 'comhem', '.', 'com');
}
