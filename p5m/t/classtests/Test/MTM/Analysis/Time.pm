package Test::MTM::Analysis::Time;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Time'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Time');
}

sub markup : Tests(12) {
	my $test = shift;

	$test->chunk_assert('kl. 20.00', 'TIME', 0,
						{orth => 'kl.', exprType => 'ABBREVIATION|TIME', 'exp' => 'klockan'},
						' ',
						{orth => '20'},
						'.',
						{orth => '00'}

		);


	# TODO timeDuration doesn't work

	#$test->chunk_assert('2 tim.', 'TIME', 0,
	# '2', ' ', 'tim', '.');

	#$test->chunk_assert('22 min.', 'TIME', 0,
	# '22', ' ', 'min', '.');
}
