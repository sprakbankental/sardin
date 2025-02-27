package Test::MTM::Analysis::Reference;

use Test::More;
use Test::Class;
use Data::Dumper;

use utf8;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Reference'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Reference');
}

#**************************************************************#
sub markup : Tests(275) {
	my $test = shift;

	# LC
	$test->chunk_assert('17§', 'REFERENCE', 0,
		{orth => '17'},
		{orth => '§'}
	);

	$test->chunk_assert('17 kap', 'REFERENCE', 0,
		{orth => '17'},
		' ',
		{orth => 'kap'}
	);

	$test->chunk_assert('st. 17', '-', 0,
		{orth => 'st.'},
		' ',
		{orth => '17'}
	);


	$test->chunk_assert('Det står i 17§', 'REFERENCE', 0,
		{orth => 'Det',exprType => '-' },
		{orth => ' ', exprType => '-' },
		{orth => 'står', exprType => '-' },
		{orth => ' ', exprType => '-' },
		{orth => 'i', exprType => '-' },
		{orth => ' ', exprType => '-' },
		{orth => '17'},
		{orth => '§'}
	);

	# 2 kap. 18 § 2 st.
	# 10 kap. 6 § 1 st. FBL

	# RC
	$test->chunk_assert('§17', 'REFERENCE', 0,
		{orth => '§'},
		{orth => '17'}
	);

	$test->chunk_assert('§ 17', 'REFERENCE', 0,
		{orth => '§'},
		{orth => ' '},
		{orth => '17'}
	);

	$test->chunk_assert('§ sjutton', '-', 0,
		{orth => '§'},
		{orth => ' '},
		{orth => 'sjutton'}
	);

	$test->chunk_assert('§ 2-4', 'REFERENCE', 0,
		{orth => '§'},
		{orth => ' '},
		{orth => '2'},
		{orth => '-'},
		{orth => '4'},
	);

	$test->chunk_assert('Bestämmelser enligt §§ 15, 16 och 16 a finns.', 'REFERENCE', 0,
		{orth => 'Bestämmelser', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => 'enligt', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => '§§'},
		{orth => ' '},
		{orth => '15'},
		{orth => ','},
		{orth => ' '},
		{orth => '16'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '16'},
		{orth => ' '},
		{orth => 'a'},
		{orth => ' ', exprType => '-'},
		{orth => 'finns', exprType => '-'},
		{orth => '.', exprType => '-'}
	);

	# LC
	$test->chunk_assert('17§', 'REFERENCE', 0,
		{orth => '17'},
		{orth => '§'}
	);

	$test->chunk_assert('17 §', 'REFERENCE', 0,
		{orth => '17'},
		{orth => ' '},
		{orth => '§'}
	);

	$test->chunk_assert('sjutton §', '-', 0,
		{orth => 'sjutton'},
		{orth => ' '},
		{orth => '§'}
	);

	$test->chunk_assert('2-4 §', 'REFERENCE', 0,
		{orth => '2'},
		{orth => '-'},
		{orth => '4'},
		{orth => ' '},
		{orth => '§'}
	);

	$test->chunk_assert('Enligt 15, 16 och 16 a §§', 'REFERENCE', 0,
		{orth => 'Enligt', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => '15'},
		{orth => ','},
		{orth => ' '},
		{orth => '16'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '16'},
		{orth => ' '},
		{orth => 'a'},
		{orth => ' '},
		{orth => '§§'}
	);

	$test->chunk_assert('Kommentar till jordabalken 13 och 21 kap m.m.', 'REFERENCE', 0,
		{orth => 'Kommentar', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => 'till', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => 'jordabalken', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => '13'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '21'},
		{orth => ' '},
		{orth => 'kap'},
		{orth => ' ', exprType => '-'},
		{orth => 'm.m', exprType => '-'},
		{orth => '.', exprType => '-'}
	);

	$test->chunk_assert('I 2 kap. 18 §', 'REFERENCE', 0,
		{orth => 'I', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => '2'},
		{orth => ' '},
		{orth => 'kap.'},
		{orth => ' '},
		{orth => '18'},
		{orth => ' '},
		{orth => '§'}
	);

	$test->chunk_assert('18 § 2 st.', 'REFERENCE', 0,
		{orth => '18'},
		{orth => ' '},
		{orth => '§'},
		{orth => ' '},
		{orth => '2'},
		{orth => ' '},
		{orth => 'st'},
		{orth => '.', exprType => '-'}
	);

	$test->chunk_assert('( 7 kap. JB)', 'REFERENCE', 0,
		{orth => '(', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => '7'},
		{orth => ' '},
		{orth => 'kap.'},
		{orth => ' ', exprType => '-'},
		{orth => 'JB', exprType => '-'},
		{orth => ')', exprType => '-'}
	);

	$test->chunk_assert('( 7 - 15 kap. JB)', 'REFERENCE', 0,
		{orth => '(', exprType => '-'},
		{orth => ' ', exprType => '-'},
		{orth => '7'},
		{orth => ' '},
		{orth => '-'},
		{orth => ' '},
		{orth => '15'},
		{orth => ' '},
		{orth => 'kap.'},
		{orth => ' ', exprType => '-'},
		{orth => 'JB', exprType => '-'},
		{orth => ')', exprType => '-'}
	);	

}
#**************************************************************#
1;