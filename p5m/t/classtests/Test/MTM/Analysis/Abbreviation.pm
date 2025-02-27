package Test::MTM::Analysis::Abbreviation;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

use utf8;

require MTM::TTSChunk;

sub class {'MTM::Analysis::Abbreviation'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Abbreviation');
}

sub markup : Tests(36) {
	my $test = shift;

	$test->chunk_assert('allm.', 'ABBREVIATION', 0,
			{orth => 'allm', exp => 'allmän' }
		);

	$test->chunk_assert('ang bg', 'ABBREVIATION', 0,
			{orth => 'ang', exp => 'angående' },
			{orth => ' ', exprType => '-'},
			{orth => 'bg', exp => 'bankgiro'}
		);

	$test->chunk_assert('+/-', 'ABBREVIATION', 0,
			{orth => '+/-', exp => 'plus minus' }
		);

	$test->chunk_assert('1 +/- 0', 'ABBREVIATION', 2,
			{orth => '+/-', exp => 'plus minus' }
		);

	$test->chunk_assert('Kalle Anka & co', 'ABBREVIATION', 4,
			{orth => '& co', exp => 'och kompani'},
		);

	$test->chunk_assert('bl. a.', 'ABBREVIATION', 0,
			{orth=> 'bl. a', exp => 'bland annat'},
			{orth => '.', exprType => '-'}
		);

	$test->chunk_assert('ff', 'ABBREVIATION', 0,
			{orth=> 'ff', exp => 'och följande sidor'},
		);
}
1;
