package Test::MTM::Expansion::AbbreviationExpansion;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Expansion';

use utf8;

require MTM::TTSChunk;

sub class {'MTM::Expansion::AbbreviationExpansion'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_expansion('AbbreviationExpansion');
}

sub expand : Tests(39) {
	my $test = shift;

	$test->chunk_assert(	'jan.-apr.', '-', 0,
			{orth => 'jan.', exp => 'januari'},
			{orth => '-', exp => 'till'},
			{orth => 'apr', exp => 'april'}
		);

	$test->chunk_assert(	'jan.-apr.', '-', 0,
			{orth=> 'jan.', exp => 'januari'},
			{orth => '-', exp => 'till'},
			{orth=> 'apr', exp => 'april'}
		);

	$test->chunk_assert(	'månd. - sönd.', '-', 0,
			{orth=> 'månd.', exp => 'måndag'},
			' ',
			{orth => '-', exp => 'till'},
			' ',
			{orth=> 'sönd', exp => 'söndag'}
		);

	# Make sure /tors./ doesn't pass
	$test->chunk_assert(	'torsk-torsk', '-', 0,
			{orth=> 'torsk-torsk', exp => '-'},
		);

	# st.
	$test->chunk_assert(	'6 st.', '-', 0,
			{orth=> '6', exp => 'sex'},
			' ',
			{orth => 'st', exp => 'stycken'},
			{orth => '.'}
	);
}

