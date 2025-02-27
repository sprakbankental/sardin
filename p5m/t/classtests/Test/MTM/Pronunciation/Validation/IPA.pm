package Test::MTM::Pronunciation::Validation::IPA;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# IPA validation (Swedish)
#
# Validate IPA pronunciations
#
# my $validated = MTM::Pronunciation::Validation::IPA->validate( $pron );
#
# CT 2024
#**************************************************************#
# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings	qw< FATAL  utf8 >;
use open	qw< :std  :utf8 >;	 # Should perhaps be :encoding(utf-8)?
use charnames	qw< :full :short >;	# autoenables in v5.16 and above
use feature	qw< unicode_strings >;
no feature	qw< indirect >;
use feature	qw< signatures >;
no warnings	qw< experimental::signatures >;
#**************************************************************#
use MTM::Pronunciation::Validation::IPA;

# Correct
my $validated = MTM::Pronunciation::Validation::IPA->validate( 'ku.rˈ́ɛkt' );
is( $validated, "VALID\n", 'IPA:valid pronunciation check correct.' );

$validated = MTM::Pronunciation::Validation::IPA->validate( 'fˈ̀eː.lˌa' );
is( $validated, "VALID\n", 'IPA:valid pronunciation check correct.' );

# Symbol check
$validated = MTM::Pronunciation::Validation::IPA->validate( 'gˈ́eeö' );
is( $validated, "Symbol is not valid: g\n Symbol is not valid: ö\n", 'IPA:symbol check correct.' );

# Unstressable phone
$validated = MTM::Pronunciation::Validation::IPA->validate( 'feː.ˈ́la' );
is( $validated, "Unstressable phone: feː.ˈ́la	ˈ́l\n", 'IPA:unstressable phone correct.' );

# Unstressable schwa
$validated = MTM::Pronunciation::Validation::IPA->validate( 'feː.lˈ́ə' );
is( $validated, "Schwa cannot have main stress: feː.lˈ́ə	ˈ́ə\n", 'Base:unstressable schwa correct.' );

# Illegal stress placement: not applicable
#$validated = MTM::Pronunciation::Validation::IPA->validate( 'feː.ləˈ́' );
#is( $validated, "Illegal stress placement: f e2:\' l\n", 'CP:illegal stress placement correct.' );

# Multiple stress
$validated = MTM::Pronunciation::Validation::IPA->validate( 'fˈ́eː.lˈ́a' );
is( $validated, "Multiple stress markers: fˈ́eː.lˈ́a\n", 'IPA:multiple stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::IPA->validate( "feː.lˌa" );
is( $validated, "No main stress: feː.lˌa\n", 'IPA:no main stress correct.' );

# No secondary stress
$validated = MTM::Pronunciation::Validation::IPA->validate( 'fˈ̀eː.la' );
is( $validated, "No secondary stress: fˈ̀eː.la\n", 'IPA:no secondary stress correct.' );

# Multiple vowels in syllable
$validated = MTM::Pronunciation::Validation::IPA->validate( 'fˈ̀eːlˌa' );
is( $validated, "Missing boundary: fˈ̀eːlˌa\n", 'Base:missing boundary correct.' );

# Adjacent boundaris
$validated = MTM::Pronunciation::Validation::IPA->validate( 'fˈ̀eː..lˌa' );
is( $validated, "Adjacent boundaries: fˈ̀eː..lˌa\n", 'Base:adjacent boundaries correct.' );

#**************************************************************#
#done_testing;
