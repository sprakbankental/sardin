package Test::MTM::Analysis::Date;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Date'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Date');
}

sub markup : Tests(139) {
	my $test = shift;

	$test->chunk_assert('3:e januari', 'DATE', 0,
						{orth => '3:e', pos => 'RO', morph => 'NOM'},
						' ',
						{orth => 'januari'},
		);

	$test->chunk_assert('3 jan.', 'DATE', 0,
						{orth => '3', pos => 'RO', morph => 'NOM'},
						' ',
						{orth => 'jan'},
						{orth => '.', exprType => '-'}
		);

	$test->chunk_assert('1 januari 1987', 'DATE', 0,
						{orth => '1', pos => 'RO', morph => 'NOM'},
						' ',
						'januari',
						{orth => ' ', exprType => 'DATE'},
						{orth => '1987', pos => 'RG', morph => 'NOM', exprType => 'YEAR|DATE'}
		);

	$test->chunk_assert('1/12-1984', 'DATE', 0,
						{orth => '1', pos => 'RO', morph => 'NOM'},
						{orth => '/', exp => 'i' },
						{orth => '12', pos => 'RO', morph => 'NOM'},
						{orth => '-', pos => 'DL',},
						{orth => '1984', pos => 'RG', exprType => 'DATE|YEAR'}
		);

	$test->chunk_assert('28.06.2011', 'DATE', 0,
						{orth => '28', pos => 'RO', morph => 'NOM'},
						{orth => '.', exp => 'i'},
						{orth => '06', pos => 'RO', morph => 'NOM'},
						{orth => '.'},
						{orth => '2011', pos => 'RG', exprType => 'DATE|YEAR'}
		);

	$test->chunk_assert('tisdag 2/3', 'DATE', 0,
						'tisdag',
						' ',
						{orth => '2', pos => 'RO', morph => 'NOM'},
						{orth => '/', exp => 'i'},
						{orth => '3', pos => 'RO', morph => 'NOM'},
		);

	$test->chunk_assert('den 18/11', 'DATE', 0,
						'den',
						' ',
						{orth => '18', pos => 'RO', morph => 'NOM'},
						{orth => '/', exp => 'i'},
						{orth => '11', pos => 'RO', morph => 'NOM'},
		);



	$test->chunk_assert('1-3 jan.', 'DATE INTERVAL', 0,
						{orth => '1', pos => 'RO', morph => 'NOM'},
						{orth => '-', pos => 'DL'},
						{orth => '3', pos => 'RO', morph => 'NOM'},
						' ',
						{orth => 'jan'},
						{orth => '.', exprType => '-'}
		);

	$test->chunk_assert('1-3/7', 'DATE INTERVAL', 0,
						{orth => '1', pos => 'RO', morph => 'NOM'},
						{orth => '-', pos => 'DL'},
						{orth => '3', pos => 'RO', morph => 'NOM'},
						{orth => '/', exp => 'i'},
						{orth => '7', pos => 'RO', morph => 'NOM'},
		);
}
