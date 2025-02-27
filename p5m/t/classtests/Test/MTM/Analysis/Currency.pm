package Test::MTM::Analysis::Currency;

use Test::More;
use Test::Class;
use Data::Dumper;

use utf8;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Currency'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Currency');
}

sub markup : Tests(130) {
	my $test = shift;

	$test->chunk_assert('12,50:-', 'CURRENCY', 0,
						{orth => '12', pos => 'RG', morph => 'NOM', exprType => 'DECIMAL|CURRENCY'},
						{orth => ',',  exp => 'kronor|och', exprType => 'DECIMAL|CURRENCY'},
						{orth => '50', pos => 'RG', morph => 'NOM', exprType => 'DECIMAL|CURRENCY'},
						{orth => ':-', exp => 'öre'}
		);

	$test->chunk_assert('12.50$', 'CURRENCY', 0,
						{orth => '12', pos => 'RG', morph => 'NOM'},
						{orth => '.',  exp => 'dollar|och', exprType => 'DECIMAL|CURRENCY'},
						{orth => '50', pos => 'RG', morph => 'NOM', exprType => 'DECIMAL|CURRENCY'},
						{orth => '$', exp => 'cent'}
		);

	$test->chunk_assert('12kr.', 'CURRENCY', 0,
						{orth => '12', pos => 'RG'},
						{orth => 'kr', exprType => 'ABBREVIATION|CURRENCY'}
		);

	$test->chunk_assert('12 kr.,', 'CURRENCY', 0,
						{orth => '12', pos => 'RG'},
						' ',
						{orth => 'kr.', exprType => 'ABBREVIATION|CURRENCY'}
		);

	$test->chunk_assert('12,50 £', 'CURRENCY', 0,
						{orth => '12', pos => 'RG', morph => 'NOM', exprType => 'DECIMAL|CURRENCY'},
						{orth => ',', pos => 'NN', exp => 'pund|och', exprType => 'DECIMAL|CURRENCY'},
						{orth => '50', pos => 'RG', morph => 'NOM', exprType => 'DECIMAL|CURRENCY'},
						' ',
						{orth => '£', exp => 'pence'}
		);

	$test->chunk_assert('$15', 'CURRENCY', 0,
						{orth => '$', exp => '<none>', pos => 'NN', morph => 'NOM'},
						{orth => '15', exp => 'femton|dollar'},

	);

	$test->chunk_assert('$12.50', 'CURRENCY', 0,
						{orth => '$', exp => '<none>', pos => 'NN', morph => 'NOM'},
						{orth => '12', exp => 'tolv|dollar', exprType => 'CURRENCY'},
						{orth => '.', exp => 'och', exprType => 'DECIMAL|CURRENCY'},
						{orth => '50', exp => 'femtio|cent', exprType => 'DECIMAL|CURRENCY'},

	);

	$test->chunk_assert('€ 15', 'CURRENCY', 0,
						{orth => '€', exp => '<none>', pos => 'NN', morph => 'NOM'},
						' ',
						{orth => '15', exp => 'femton|euro'},

	);

	$test->chunk_assert('£ 12,50', 'CURRENCY', 0,
						{orth => '£', exp => '<none>', pos => 'NN', morph => 'NOM'},
						' ',
						{orth => '12', exp => 'tolv|pund', exprType => 'DECIMAL|CURRENCY'},
						{orth => ',', exp => 'och', exprType => 'DECIMAL|CURRENCY'},
						{orth => '50', exp => 'femtio|pence', exprType => 'DECIMAL|CURRENCY'},

	);

	$test->chunk_assert('1 kr.', 'CURRENCY', 0,
						{orth => '1', pos => 'RG'},
						' ',
						{orth => 'kr', exprType => 'ABBREVIATION|CURRENCY'},
		);

	$test->chunk_assert('2 kr.', 'CURRENCY', 0,
						{orth => '2', pos => 'RG'},
						' ',
						{orth => 'kr', exprType => 'ABBREVIATION|CURRENCY'},
		);

}
