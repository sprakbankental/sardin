package Test::MTM::Analysis::Acronym;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Acronym'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Acronym');
}

sub markup : Tests(104) {
	my $test = shift;

	$test->chunk_assert('S-E-banken', 'ACRONYM COMPOUND', 0,
						{orth => 'S-E-banken', dec => 'S+-+E+-+banken', ortlang => 'swe', lang => 'swe'}
		);
	$test->chunk_assert('ATG-ombud', 'ACRONYM COMPOUND', 0,
						{orth => 'ATG-ombud', dec => 'ATG+-+ombud', ortlang => 'swe', lang => 'swe'}
		);
	$test->chunk_assert('bank-ID', 'ACRONYM COMPOUND', 0,
						{orth => 'bank-ID', dec => 'bank+-+ID', ortlang => 'swe', lang => 'swe'}
		);
	$test->chunk_assert('marknads-VD', 'ACRONYM COMPOUND', 0,
						{orth => 'marknads-VD', dec => 'marknads+-+VD', ortlang => 'swe', lang => 'swe'}
		);
	$test->chunk_assert('TPB', 'ACRONYM', 0,
						{orth => 'TPB', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);
	$test->chunk_assert('DN', 'ACRONYM', 0,
						{orth => 'DN', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);
	$test->chunk_assert('C-', 'ACRONYM', 0,
						{orth => 'C-', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);
	$test->chunk_assert('DN:s', 'ACRONYM', 0,
						{orth => 'DN:s', lang => 'swe', pos => 'ACR', morph => 'GEN'}
		);
	$test->chunk_assert('SvD', 'ACRONYM', 0,
						{orth => 'SvD', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);
	$test->chunk_assert('SvD:s', 'ACRONYM', 0,
						{orth => 'SvD:s', lang => 'swe', pos => 'ACR', morph => 'GEN'}
		);
	$test->chunk_assert('KPR', 'ACRONYM', 0,
						{orth => 'KPR', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);
	$test->chunk_assert('KPR:arna', 'ACRONYM', 0,
						{orth => 'KPR:arna', lang => 'swe', pos => 'ACR', morph => '- PLU DEF NOM'}
		);

	$test->chunk_assert('cd:n', 'ACRONYM', 0,
						{orth => 'cd:n', lang => 'swe', pos => 'ACR', morph => 'UTR SIN DEF NOM'}
		);

	$test->chunk_assert('KPr', 'ACRONYM', 0,
						{orth => 'KPr', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);

	$test->chunk_assert('A-P-G', 'ACRONYM', 0,
						{orth => 'A-P-G', lang => 'swe', pos => 'ACR', morph => 'NOM'}
		);

	$test->chunk_assert('S.S.D', 'ACRONYM', 0,
						{orth => 'S', lang => 'swe', morph => 'NOM'},
						{orth => '.', exprType => '-'},
						{orth => 'S', lang => 'swe', morph => 'NOM'},
						{orth => '.', exprType => '-'},
						{orth => 'D', lang => 'swe', morph => 'NOM'},
		);

}
1;
