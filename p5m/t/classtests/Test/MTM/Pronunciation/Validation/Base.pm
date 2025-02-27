package Test::MTM::Pronunciation::Validation::Base;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# Base validation (Swedish)
#
# Validate Base pronunciations
#
# my $validated = MTM::Pronunciation::Validation::Base->validate( $pron );
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
use MTM::Pronunciation::Validation::Base;

# Correct
my $validated = MTM::Pronunciation::Validation::Base->validate( "k u \. r \'ä k t" );
is( $validated, "VALID\n", 'Base:valid pronunciation check correct.' );

# Symbol check
$validated = MTM::Pronunciation::Validation::Base->validate( "ff 'ee l" );
is( $validated, "Symbol is not valid: ff\n Symbol is not valid: ee\n", 'Base:symbol check correct.' );

# Unstressable phone
$validated = MTM::Pronunciation::Validation::Base->validate( "f e: \. 'l a" );
is( $validated, "Unstressable phone: f e: . 'l a	'l\n", 'Base:unstressable phone correct.' );

# No main stress: schwa
$validated = MTM::Pronunciation::Validation::Base->validate( "f e: \. l \'ex" );
is( $validated, "Schwa cannot have main stress: f e: . l \'ex	'ex\n", 'Base:unstressable schwa correct.' );

# Schwa can have secondary stress
$validated = MTM::Pronunciation::Validation::Base->validate( "f \"e: \. l ,ex" );
is( $validated, "VALID\n", 'Base:schwa with secondary stress correct.' );

# Illegal stress placement
$validated = MTM::Pronunciation::Validation::Base->validate( "f e:\' l" );
is( $validated, "Illegal stress placement: f e:\' l\n", 'Base:illegal stress placement correct.' );

# Multiple stress
$validated = MTM::Pronunciation::Validation::Base->validate( "f 'e: \. l 'a" );
is( $validated, "Multiple stress markers: f 'e: . l 'a\n", 'Base:multiple stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::Base->validate( "f e: \. l ,a" );
is( $validated, "No main stress: f e: . l ,a\n", 'Base:no main stress correct.' );

# No secondary stress
$validated = MTM::Pronunciation::Validation::Base->validate( 'f "e: . l a' );
is( $validated, "No secondary stress: f \"e: \. l a\n", 'Base:no secondary stress correct.' );

# English: illega secondary stress
$validated = MTM::Pronunciation::Validation::Base->validate( 'f "e: . l a', 'en' );
is( $validated, "Illegal stress, accent 2 in English word: f \"e: \. l a\n", 'Base:no secondary stress correct.' );

# Multiple vowels in syllable
$validated = MTM::Pronunciation::Validation::Base->validate( 'f "e: l ,a' );
is( $validated, "Missing boundary: f \"e: l ,a\n", 'Base:missing boundary correct.' );

# Adjacent boundaris
$validated = MTM::Pronunciation::Validation::Base->validate( 'f "e: ~ . l ,a' );
is( $validated, "Adjacent boundaries: f \"e: ~ \. l ,a\n", 'Base:adjacent boundaries correct.' );

#**************************************************************#
#done_testing;
