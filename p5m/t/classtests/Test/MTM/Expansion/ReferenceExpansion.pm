package Test::MTM::Expansion::ReferenceExpansion;

use Test::More;
use Test::Class;
use Data::Dumper;

use utf8;

use parent 'Test::MTM::Expansion';

require MTM::TTSChunk;

sub class {'MTM::Expansion::ReferenceExpansion'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;

	eval "use $class";
	die $@ if $@;
	$test->set_expansion('ReferenceExpansion');
}

sub expand : Tests(591) {
	my $test = shift;

	# RC
	$test->chunk_assert('§17', '-', 0,
		{orth => '§', exp => 'paragraf'},
		{orth => '17', exp => 'sjutton'}
	);



	$test->chunk_assert('§ 17', '-', 0,
		{orth => '§', exp => 'paragraf'},
		{orth => ' '},
		{orth => '17', exp => 'sjutton'}
	);

	$test->chunk_assert('§ 2-4', '-', 0,
		{orth => '§', exp => 'paragraf'},
		{orth => ' '},
		{orth => '2', exp => 'två'},
		{orth => '-', exp => 'till'},
		{orth => '4', exp => 'fyra'}
	);

	$test->chunk_assert('Bestämmelser enligt §§ 15, 16 och 16 a finns.', '-', 0,
		{orth => 'Bestämmelser'},
		{orth => ' '},
		{orth => 'enligt'},
		{orth => ' '},
		{orth => '§§', exp => 'paragraferna'},
		{orth => ' '},
		{orth => '15', exp => 'femton'},
		{orth => ','},
		{orth => ' '},
		{orth => '16', exp => 'sexton'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '16', exp => 'sexton'},
		{orth => ' '},
		{orth => 'a'},
		{orth => ' '},
		{orth => 'finns'},
		{orth => '.', exprType => '-'}
	);

	$test->chunk_assert('17§', '-', 0,
		{orth => '17', exp => 'paragraf|sjutton'},
		{orth => '§', exp => '<none>'}
	);

	$test->chunk_assert('17 kap', '-', 0,
		{orth => '17', exp => 'kapitel|sjutton'},
		' ',
		{orth => 'kap', exp => '<none>'}
	);

	$test->chunk_assert('Det står i 17§', '-', 0,
		{orth => 'Det',exprType => '-' },
		{orth => ' ', exprType => '-' },
		{orth => 'står', exprType => '-' },
		{orth => ' ', exprType => '-' },
		{orth => 'i', exprType => '-' },
		{orth => ' ', exprType => '-' },
		{orth => '17', exp => 'paragraf|sjutton'},
		{orth => '§', exp => '<none>'}
	);


	# unit after
	# 2 kap. 18 § 2 st.
	# 10 kap. 6 § 1 st. FBL

	$test->chunk_assert('2 kap. 4 §', '-', 0,
		{orth => '2', exp => 'kapitel|två'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '4', exp => 'paragraf|fyra'},
		{orth => ' '},
		{orth => '§', exp => '<none>'}
	);

	$test->chunk_assert('3 kap. 2 a §', '-', 0,
		{orth => '3', exp => 'kapitel|tre'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '2', exp => 'paragraf|två'},
		{orth => ' '},
		{orth => 'a', pron => "\'a:"},
		{orth => ' '},
		{orth => '§', exp => '<none>'}
	);

	$test->chunk_assert('4 kap. 1-6 §§', '-', 0,
		{orth => '4', exp => 'kapitel|fyra'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '1', exp => 'paragraferna|ett'},
		{orth => '-', exp => 'till'},
		{orth => '6', exp => 'sex'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('6-6 c kap.', '-', 0,
		{orth => '6', exp => 'kapitel|sex'},
		{orth => '-', exp => 'till'},
		{orth => '6', exp => 'sex'},
		{orth => ' '},
		{orth => 'c', pron => "s \'e:"},
		{orth => ' '},
		{orth => 'kap', exp => '<none>'},
		{orth => '.'}
	);

	$test->chunk_assert('6 och 6 c kap.', '-', 0,
		{orth => '6', exp => 'kapitel|sex'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '6', exp => 'sex'},
		{orth => ' '},
		{orth => 'c', pron => "s \'e:"},
		{orth => ' '},
		{orth => 'kap', exp => '<none>'},
		{orth => '.'}
	);

	$test->chunk_assert('1 kap. 11 och 12 §§', '-', 0,
		{orth => '1', exp => 'kapitel|ett'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '11', exp => 'paragraferna|elva'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '12', exp => 'tolv'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('4 kap. 1–6 §§	', '-', 0,
		{orth => '4', exp => 'kapitel|fyra'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '1', exp => 'paragraferna|ett'},
		{orth => '-', exp => 'till'},
		{orth => '6', exp => 'sex'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('64–66 och 68 §§', '-', 0,
		{orth => '64', exp => 'paragraferna|sextiofyra'},
		{orth => '-', exp => 'till'},
		{orth => '66', exp => 'sextiosex'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '68', exp => 'sextioåtta'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('1, 2, 4, 6, 7 och 9–14 §§', '-', 0,
		{orth => '1', exp => 'paragraferna|ett'},
		{orth => ','},
		{orth => ' '},
		{orth => '2', exp => 'två'},
		{orth => ','},
		{orth => ' '},
		{orth => '4', exp => 'fyra'},
		{orth => ','},
		{orth => ' '},
		{orth => '6', exp => 'sex'},
		{orth => ','},
		{orth => ' '},
		{orth => '7', exp => 'sju'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '9', exp => 'nio'},
		{orth => '-', exp => 'till'},
		{orth => '14', exp => 'fjorton'}
	);


	$test->chunk_assert('10 kap. 5 a–5 c §§', '-', 0,
		{orth => '10', exp => 'kapitel|tio'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '5', exp => 'paragraferna|fem'},
		{orth => ' '},
		{orth => 'a', pron => "\'a:"},
		{orth => '-', exp => 'till'},
		{orth => '5', exp => 'fem'},
		{orth => ' '},
		{orth => 'c', pron => "s \'e:"},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('15–17, 28 § och 30 a §', '-', 0,
		{orth => '15', exp => 'paragraf|femton'},
		{orth => '-', exp => 'till'},
		{orth => '17', exp => 'sjutton'},
		{orth => ','},
		{orth => ' '},
		{orth => '28', exp => 'tjugoåtta'},
		{orth => ' '},
		{orth => '§', exp => '<none>'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '30', exp => 'paragraf|trettio'},
		{orth => ' '},
		{orth => 'a', pron => "\'a:"},
		{orth => ' '},
		{orth => '§', exp => '<none>'}
	);


	$test->chunk_assert('2, 3, 4, 5, 6, 15, 16, 28, 33 d, 36 och 40 §§', '-', 0,
		{orth => '2', exp => 'paragraferna|två'},
		{orth => ','},
		{orth => ' '},
		{orth => '3', exp => 'tre'},
		{orth => ','},
		{orth => ' '},
		{orth => '4', exp => 'fyra'},
		{orth => ','},
		{orth => ' '},
		{orth => '5', exp => 'fem'},
		{orth => ','},
		{orth => ' '},
		{orth => '6', exp => 'sex'},
		{orth => ','},
		{orth => ' '},
		{orth => '15', exp => 'femton'},
		{orth => ','},
		{orth => ' '},
		{orth => '16', exp => 'sexton'},
		{orth => ','},
		{orth => ' '},
		{orth => '28', exp => 'tjugoåtta'},
		{orth => ','},
		{orth => ' '},
		{orth => '33', exp => 'trettiotre'},
		{orth => ' '},
		{orth => 'd', pron => "d \'e:"},
		{orth => ','},
		{orth => ' '},
		{orth => '36', exp => 'trettiosex'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '40', exp => 'fyrtio'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('36 - 38 §§', '-', 0,
		{orth => '36', exp => 'paragraferna|trettiosex'},
		{orth => ' '},
		{orth => '-', exp => 'till'},
		{orth => ' '},
		{orth => '38', exp => 'trettioåtta'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);


	$test->chunk_assert('2-4 §', '-', 0,
		{orth => '2', exp => 'paragraf|två'},
		{orth => '-', exp => 'till'},
		{orth => '4', exp => 'fyra'},
		{orth => ' '},
		{orth => '§', exp => '<none>'}
	);

	$test->chunk_assert('Enligt 15, 16 och 16 a §§', '-', 0,
		{orth => 'Enligt'},
		{orth => ' '},
		{orth => '15', exp => 'paragraferna|femton'},
		{orth => ','},
		{orth => ' '},
		{orth => '16', exp => 'sexton'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '16', exp => 'sexton'},
		{orth => ' '},
		{orth => 'a'},
		{orth => ' '},
		{orth => '§§', exp => '<none>'}
	);

	$test->chunk_assert('Kommentar till jordabalken 13 och 21 kap m.m.', '-', 0,
		{orth => 'Kommentar'},
		{orth => ' '},
		{orth => 'till'},
		{orth => ' '},
		{orth => 'jordabalken'},
		{orth => ' '},
		{orth => '13', exp => 'kapitel|tretton'},
		{orth => ' '},
		{orth => 'och'},
		{orth => ' '},
		{orth => '21', exp => 'tjugoett'},
		{orth => ' '},
		{orth => 'kap', exp => '<none>'},
		{orth => ' '},
	);

	$test->chunk_assert('I 2 kap. 18 §', '-', 0,
		{orth => 'I'},
		{orth => ' '},
		{orth => '2', exp => 'kapitel|två'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => '18', exp => 'paragraf|arton'},
		{orth => ' '},
		{orth => '§', exp => '<none>'}
	);

	$test->chunk_assert('18 § 2 st.', '-', 0,
		{orth => '18', exp => 'paragraf|arton'},
		{orth => ' '},
		{orth => '§', exp => '<none>'},
		{orth => ' '},
		{orth => '2', exp => 'andra'},
		{orth => ' '},
		{orth => 'st', exp => 'stycket'},
		{orth => '.'}
	);

	$test->chunk_assert('( 7 kap. JB)', '-', 0,
		{orth => '('},
		{orth => ' '},
		{orth => '7', exp => 'kapitel|sju'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => 'JB'},
		{orth => ')'}
	);

	$test->chunk_assert('( 7 - 15 kap. JB)', '-', 0,
		{orth => '('},
		{orth => ' '},
		{orth => '7', exp => 'kapitel|sju'},
		{orth => ' '},
		{orth => '-', exp => 'till'},
		{orth => ' '},
		{orth => '15', exp => 'femton'},
		{orth => ' '},
		{orth => 'kap.', exp => '<none>'},
		{orth => ' '},
		{orth => 'JB'},
		{orth => ')'},
	);	

}
