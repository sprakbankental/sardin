package Test::MTM::Analysis::Initial;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Initial'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Initial');
}

sub markup : Tests(39) {
	my $test = shift;


	# TODO Spelling of INITIAL in some cases?
	$test->chunk_assert('Karlsson, C.', 'INITIAL', 3, 'C', '.');
	$test->chunk_assert('Karlsson, C', 'INITIAL', 3, 'C');
	$test->chunk_assert('Karlsson C', 'INITIAL', 2, 'C');

	$test->chunk_assert('C. Karlsson', 'INITIAL', 0, 'C', '.');
	$test->chunk_assert('C.Karlsson', 'INITIAL', 0, 'C', '.');
	$test->chunk_assert('C Karlsson', 'INITIAL', 0, 'C');
	$test->chunk_assert('H. C. Karlsson', 'INITIAL', 0, 'H', '.', ' ', 'C', '.');

	$test->chunk_assert('25 a', 'INITIAL', 2, 'a');
}
