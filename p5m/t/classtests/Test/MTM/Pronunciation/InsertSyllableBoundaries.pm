package Test::MTM::Pronunciation;

use v5.32;                    # We assume pragmas and such from 5.32.0
use Test::More;               # Explicitly load modules - no Test::Most
use parent qw(ClassTestBase); # Local class which inherits from Test::Class

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;
# END SBTal boilerplate

#**************************************************#
# Function	createCompoundPronunciation
#**************************************************#
# MODULE	MTM::Pronunciation::InsertSyllableBoundaries.pm
sub InsertSyllableBoundaries : Test(1) {
	subtest "Insert syllable boundaries" => sub {
		plan tests => 17;
		my $result;
		my $ph;
		my $dec;


		# Function	insert_syllable_boundaries

		# in dict

		# incorrect decomp in dict
		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'musiköra', 'm u3 s i2: k ö3: r a', 0 );
		is( $ph, 'm u3 $ s i2: k - ö3: $ r a', 'insert_syllable_boundaries 1 (m u3 s i2: k ö3: r a, musiköra): correct.' );
		is( $dec, 'musik+öra', 'insert_syllable_boundaries decomp (m u3 s i2: k ö3: r a, musiköra): correct.' );

		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'musiköra', 'm u3 s i2: k ö3: r a', 1 );
		is( $ph, 'm u3 $ s i2: k - ö3: $ r a', 'insert_syllable_boundaries 1 (m u3 s i2: k ö3: r a, musiköra): correct.' );
		is( $dec, 'mu-sik+ö-ra', 'insert_syllable_boundaries decomp (m u3 s i2: k ö3: r a, musiköra): correct.' );

		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'nordöstra', 'n o2: rd ö s t r a', 0 );
		is( $ph, 'n o2: rd ~ ö $ s t r a', 'insert_syllable_boundaries 1 (n o2: rd ö s t r a, nordöstra): correct.' );
		is( $dec, 'nordöstra', 'insert_syllable_boundaries decomp (n o2: rd ö s t r a, nordöstra): correct.' );

		# compound, not in dict
		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'storarmens', 's t o2: r a r m ë n s', 0 );
		is( $ph, 's t o2: r - a r $ m ë n s', 'insert_syllable_boundaries 1 (s t o2: r a r m ë n s, storarmens): correct.' );
		is( $dec, 'stor+armens', 'insert_syllable_boundaries decomp (s t o2: r a r m ë n s, storarmens): correct.' );

		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'sydarbetsmössa', 's y2: d a r b e2: t s m ö s a', 0 );
		is( $ph, 's y2: d - a r $ b e2: t s - m ö $ s a', 'insert_syllable_boundaries 1 (s y2: d a r b e2: t s m ö s a, sydarbetsmössa): correct.' );
		is( $dec, 'syd+arbets+mössa', 'insert_syllable_boundaries decomp (s y2: d a r b e2: t s m ö s a, sydarbetsmössa): correct.' );

		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'PLL-gruppen', 'p e2: e l e l g r u p ë n', 0 );
		is( $ph, 'p e2: ~ ä l ~ ä l - g r u $ p ë n', 'insert_syllable_boundaries 1 (p e2: e l e l g r u p ë n, PLL-gruppen): correct.' );
		is( $dec, 'PLL+-+gruppen', 'insert_syllable_boundaries decomp (p e2: e l e l g r u p ë n, PLL-gruppen): correct.' );

		# acronym
		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'AAE', 'a2: a2: e2:', 0 );
		is( $ph, 'a2: ~ a2: ~ e2:', 'insert_syllable_boundaries 1 (a2: a2: e2:, AAE): correct.' );
		#is( $dec, 'AAE', 'insert_syllable_boundaries decomp (a2: a2: e2:, AAE): correct.' );

		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'AA', 'a2: a2:', 0 );
		is( $ph, 'a2: ~ a2:', 'insert_syllable_boundaries 1 (a2: a2:, AA): correct.' );

		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'BDRR', 'b e2: d e2: ä3 r ä3 r', 0 );
		is( $ph, 'b e2: ~ d e2: ~ ä3 r ~ ä3 r', 'insert_syllable_boundaries 1 (b e2: d e2: ä3 r ä3 r:, BDRR): correct.' );

		# nonsense words
		( $ph, $dec ) = &MTM::Pronunciation::InsertSyllableBoundaries::insert_syllable_boundaries( 'bespriftningar', 'b e3 s p r i f t n i ng a r', 0 );
		is( $ph, 'b e3 $ s p r i f t $ n i ng $ a r', 'insert_syllable_boundaries 1 (b e3 s p r i f t n i ng a r, bespriftningar): correct.' );
		is( $dec, 'bespriftningar', 'insert_syllable_boundaries decomp (b e3 s p r i f t n i ng a r, bespriftningar): correct.' );
	};
}
#**************************************************#
1;