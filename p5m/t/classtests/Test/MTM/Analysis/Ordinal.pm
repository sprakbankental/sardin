package Test::MTM::Analysis::Ordinal;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

use utf8;

require MTM::TTSChunk;

sub class {'MTM::Analysis::Ordinal'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Ordinal');
}

sub markup : Tests(0) {
	my $test = shift;

#	$test->chunk_assert('3:e', 'ORDINAL', 0, '3:e');;

	# TODO	210701
	#$test->chunk_assert('17§', 'ORDINAL', 0, '17');;

#	$test->chunk_assert('1:a uppl.', 'ORDINAL', 0, '1:a');
}
