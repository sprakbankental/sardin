package Test::MTM::Analysis::LanguageDetection2;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

use utf8;
use strict;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::LanguageDetection2'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('LanguageDetection2');
}

sub markup : Tests(73) {
	my $test = shift;

	# my ($test, $text, $type, $offset, @expected_chunk) = @_;

	# not_english_context
	#$test->chunk_assert('Ute or inne.', '-', 2,
	#		{orth => 'or', lang => 'swe' }
	#	);

	# no_swedish_context
	$test->chunk_assert('Out or please.', '-', 2,
			{orth => 'or', lang => 'eng' }
		);

	# no_english_context
	$test->chunk_assert('Ost i väst.', '-', 2,
			{orth => 'i', lang => 'swe' }
		);

	# Between proper names
	$test->chunk_assert('Christina and Petra.', '-', 2,
			{orth => 'and', lang => 'eng' }
		);


	# RC = English
	#$test->chunk_assert('Testar by Sweden.', '-', 2,
	#		{orth => 'by', lang => 'eng' }
	#	);

	# Right context is "the"
	$test->chunk_assert('Bor at the trappa.', '-', 2,
			{orth => 'at', lang => 'eng' }
		);

	# Right context is "the" or "at", current token is possibly English
	$test->chunk_assert('Höra the trappa.', '-', 2,
			{orth => 'the', lang => 'eng' }
		);

	# lc and rc English only
	$test->chunk_assert('Bored in danger.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# $english_context == 1	eats previous rule
	$test->chunk_assert('Bored in danger.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# lc and rc Swedish only
	$test->chunk_assert('Hoppar in plötsligt.', '-', 2,
			{orth => 'in', lang => 'swe' }
		);

	# $swedish_context == 1	eats previous rule
	$test->chunk_assert('Bored in danger.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# lc English only, rc possibly English
	$test->chunk_assert('Bored in city.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# lc possibly English , rc English only
	$test->chunk_assert('City in boredom.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# lc delimiter, rc English only
	$test->chunk_assert(', in boredom.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# lc English only, rc1 delimiter
	$test->chunk_assert('boredom in,', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

	# rc English only	plausible to overgenerate from time to time
	$test->chunk_assert('in boredom', '-', 0,
			{orth => 'in', lang => 'eng' }
		);

	# no lc2, rc2 exists,  first word in string
	$test->chunk_assert('The city', '-', 0,
			{orth => 'The', lang => 'eng' }
		);

	# lc2 exists, no rc2, last word in string
	$test->chunk_assert('boredom in.', '-', 2,
			{orth => 'in', lang => 'eng' }
		);

#	# The following two rules take out the previous two rules
#	} elsif( $lc2_flag == 1 ) {
#		# lc is English only
#		if( $lc2->{lang} eq 'eng' ) {
#			$t->{lang} = 'eng';
#			return $self;
#		}
#	} elsif( $rc2_flag == 1 ) {
#		# rc is English only
#		if( $rc2->{lang} eq 'eng' ) {
#			$t->{lang} = 'eng';
#			return $self;
#		}
#	}

}
#*******************************************************************************************************#
1;
