package Test::MTM::Analysis::Interval;

use Test::More;
use Test::Class;
use Data::Dumper;

#use utf8;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Interval'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Interval');
}

sub markup : Tests(101) {
	my $test = shift;

	$test->chunk_assert('5-7', 'INTERVAL', 0,
						{orth => '5', pos => 'RG'},
						{orth => '-', pos => 'DL'},
						{orth => '7', pos => 'RG'}
		);

	$test->chunk_assert('kap. 5-7', 'INTERVAL', 0,
						{orth => 'kap.', exprType => 'REFERENCE|ABBREVIATION'},
						{orth => ' ', exprType => 'REFERENCE'},
						{orth => '5', pos => 'RG', exprType => 'REFERENCE|INTERVAL'},
						{orth => '-', pos => 'DL', exprType => 'REFERENCE|INTERVAL'},
						{orth => '7', pos => 'RG', exprType => 'REFERENCE|INTERVAL'},
	);
	$test->chunk_assert('7-8 min.', 'INTERVAL', 0,
						{orth => '7', pos => 'RG'},
						{orth => '-', pos => 'DL'},
						{orth => '8', pos => 'RG'}
		);


	$test->chunk_assert('7 b-8 c kap.', 'REFERENCE|INTERVAL', 0,
						{orth => '7', pos => 'RG'},
						' ',
						{orth => 'b'},
						{orth => '-', pos => 'DL'},
						{orth => '8', pos => 'RG'},
						' ',
						{orth => 'c'},
						{orth => ' ', exprType => 'REFERENCE'},
						{orth => 'kap', exprType => 'REFERENCE|ABBREVIATION'}
		);

	$test->chunk_assert('7-8 c kap.', 'REFERENCE|INTERVAL', 0,
						{orth => '7', pos => 'RG'},
						{orth => '-', pos => 'DL'},
						{orth => '8', pos => 'RG'}
		);
	$test->chunk_assert('37-38,', 'INTERVAL', 0,
						{orth => '37', pos => 'RG'},
						{orth => '-', pos => 'DL'},
						{orth => '38', pos => 'RG'}
		);


	$test->chunk_assert('tisdag-fredag', 'INTERVAL', 0,
						{orth => 'tisdag'},
						{orth => '-'},
						{orth => 'fredag'}
		);

	$test->chunk_assert('måndag - fredag', 'INTERVAL', 0,
						{orth => 'måndag'},
						' ',
						{orth => '-'},
						' ',
						{orth => 'fredag'}
		);


	$test->chunk_assert('jan.-apr.', 'INTERVAL', 0,
						{orth => 'jan.'},
						{orth => '-'},
						{orth => 'apr'},
		);
}
