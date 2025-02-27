package Test::MTM::Analysis::Decimal;

use Test::More;
use Test::Class;
use Data::Dumper;

use utf8;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Decimal'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Decimal');
}

sub markup : Tests(22) {
	my $test = shift;

	$test->chunk_assert('21,14', 'DECIMAL', 0,
						{ 'orth' => '21', 'pos' => 'RG', morph => 'NOM' },
						{ 'orth' => ',', 'pos' => 'DL', 'morph' => 'MID' },
						{ 'orth' => '14', 'pos' => 'RG', morph => 'NOM' },
		);

	$test->chunk_assert('1½', 'FRACTION', 1, '½');

	$test->chunk_assert('3 ¼', 'FRACTION', 2, '¼');

	$test->chunk_assert('3 ¾', 'FRACTION', 2, '¾');


}
