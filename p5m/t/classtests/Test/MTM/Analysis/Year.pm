package Test::MTM::Analysis::Year;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

use utf8;

require MTM::TTSChunk;

sub class {'MTM::Analysis::Year'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Year');
}

sub markup : Tests(183) {
	my $test = shift;


	$test->chunk_assert('sommaren 1986 - 1998', 'YEAR INTERVAL', 0,
						{orth => 'sommaren', exprType => '-'},
						{orth => ' ', exprType => '-'},
						{orth => '1986', morph => 'NOM', pos => 'RG'},
						' ',
						{orth => '-', pos => 'DL', exp => 'till'},
						' ',
						{orth => '1998', morph => 'NOM', pos => 'RG'}
		);

	$test->chunk_assert('vintern 2000/2001', 'YEAR INTERVAL', 0,
						{orth => 'vintern', exprType => '-'},
						{orth => ' ', exprType => '-'},
						{orth => '2000', morph => 'NOM', pos => 'RG'},
						{orth => '/', pos => 'RG'},
						{orth => '2001', morph => 'NOM', pos => 'RG'}
		);
	$test->chunk_assert('Nilsson 2001-2008', 'YEAR INTERVAL', 0,
						{orth => 'Nilsson', exprType => '-'},
						{orth => ' ', exprType => '-'},
						{orth => '2001', morph => 'NOM', pos => 'RG'},
						{orth => '-', pos => 'RG', maxProbTag => 'FI', exp => 'till'},
						{orth => '2008', morph => 'NOM', pos => 'RG'}
		);

	$test->chunk_assert('Nilsson 2001 - 2008', 'YEAR INTERVAL', 0,
						{orth => 'Nilsson', exprType => '-'},
						{orth => ' ', exprType => '-'},
						{orth => '2001', morph => 'NOM', pos => 'RG'},
						' ',
						{orth => '-', exp => 'till'},
						' ',
						{orth => '2008',  morph => 'NOM', pos => 'RG'}
		);

	$test->chunk_assert('(1986 - 1998)', 'YEAR INTERVAL', 1,
						{orth => '1986', morph => 'NOM', pos => 'RG'},
						' ',
						{orth => '-', pos => 'DL', exp => 'till'},
						' ',
						{orth => '1998', morph => 'NOM', pos => 'RG'},
		);
	$test->chunk_assert('(Wallin 1718-63)', 'YEAR INTERVAL', 3,
						{orth => '1718', morph => 'NOM', pos => 'RG'},
						{orth => '-', pos => 'RG', exp => 'till'},
						{orth => '63', morph => 'NOM', pos => 'RG'},
		);

	$test->chunk_assert('1500-1200 f.Kr', 'YEAR INTERVAL', 0,
						{orth => '1500', morph => 'NOM', pos => 'RG'},
						{orth => '-', pos => 'DL', exp => 'till'},
						{orth => '1200', morph => 'NOM', pos => 'RG'},
						{orth => ' ', exprType => '-'},
						{orth => 'f.Kr', exprType => 'ABBREVIATION'}
		);
	$test->chunk_assert('1200-1500 e. Kr.', 'YEAR INTERVAL', 0,
						{orth => '1200',  morph => 'NOM', pos => 'RG'},
						{orth => '-', pos => 'DL', maxProbTag => 'FI', exp => 'till'},
						{orth => '1500', morph => 'NOM', pos => 'RG'},
						{orth => ' ', exprType => '-'},
						{orth => 'e. Kr', exprType => 'ABBREVIATION'}
		);

	# TODO
	#$test->chunk_assert('1960- och 70-talen', 'YEAR', 0,
	#					{orth => '1960-', morph => 'NOM', pos => 'RG'},
	#					' ',
	#					{orth => 'och', exprType => '-'},
	#					' ',
	#					{orth => '70-talen'}
	#	);

	$test->chunk_assert('†1986', 'YEAR', 1,
						{orth => '1986', morph => 'NOM', pos => 'RG'},
		);

	$test->chunk_assert('(2001)', 'YEAR', 1,
						{orth => '2001', morph => 'NOM', pos => 'RG'},
		);

	$test->chunk_assert('(Rosdal, 1456)', 'YEAR', 4,
						{orth => '1456', morph => 'NOM', pos => 'RG'},
		);

	$test->chunk_assert('/2006', 'YEAR', 1,
						{orth => '2006', morph => 'NOM', pos => 'RG'},
		);

	$test->chunk_assert('1999b', 'YEAR', 0,
						{orth => '1999', morph => 'NOM', pos => 'RG'},
						{orth => 'b', exprType => 'ACRONYM'}
		);

	# TODO
	#$test->chunk_assert('1700-', 'YEAR', 0,
	#					{orth => '1700-',morph => 'NOM'},
	#	);

	$test->chunk_assert('21/3-1876', 'DATE', 0,
						'21',
						'/',
						'3',
						'-',
						{orth => '1876', pos => 'RG', exprType => 'DATE|YEAR'},
		);

	# TODO
	#$test->chunk_assert('bada 1988$', 'YEAR', 2,
	#        {orth => '1988', pos => 'RG', exprType => 'DATE|YEAR'},
	#		);

	$test->chunk_assert('sluta 1988,', 'YEAR', 2, '1988');

	$test->chunk_assert(', 1992.', 'YEAR', 2, '1992');

	# TODO
	#$test->chunk_assert('1700 år', 'YEAR', 0, '1700');

}
