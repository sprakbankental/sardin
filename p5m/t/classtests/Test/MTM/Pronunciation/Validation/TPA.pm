package Test::MTM::Pronunciation::Validation::TPA;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# TPA validation (Swedish)
#
# Validate TPA pronunciations
#
# my $validated = MTM::Pronunciation::Validation::TPA->validate( $pron );
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
use MTM::Pronunciation::Validation::TPA;

# Correct
my $validated = MTM::Pronunciation::Validation::TPA->validate( "k u \$ r \'ä k t" );
is( $validated, "VALID\n", 'TPA:valid pronunciation check correct.' );

# Symbol check
$validated = MTM::Pronunciation::Validation::TPA->validate( "ff 'ee l" );
is( $validated, "Symbol is not valid: ff\n Symbol is not valid: ee\n", 'TPA:symbol check correct.' );

# Unstressable phone
$validated = MTM::Pronunciation::Validation::TPA->validate( "f e2: \$ 'l a" );
is( $validated, "Unstressable phone: f e2: \$ 'l a	'l\n", 'TPA:unstressable phone correct.' );

# Unstressable schwa
$validated = MTM::Pronunciation::Validation::TPA->validate( "f e2: \$ l \'ë" );
is( $validated, "Schwa cannot have main stress: f e2: \$ l \'ë	'ë\n", 'Base:unstressable schwa correct.' );

# Illegal stress placement
$validated = MTM::Pronunciation::Validation::TPA->validate( "f e2:\' l" );
is( $validated, "Illegal stress placement: f e2:\' l\n", 'CP:illegal stress placement correct.' );

# Multiple stress
$validated = MTM::Pronunciation::Validation::TPA->validate( "f 'e2: \$ l 'a" );
is( $validated, "Multiple stress markers: f 'e2: \$ l 'a\n", 'TPA:multiple stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::TPA->validate( "f e2: \$ l \`a" );
is( $validated, "No main stress: f e2: \$ l \`a\n", 'TPA:no main stress correct.' );

# No secondary stress
$validated = MTM::Pronunciation::Validation::TPA->validate( 'f "e2: $ l a' );
is( $validated, "No secondary stress: f \"e2: \$ l a\n", 'TPA:no secondary stress correct.' );

# Multiple vowels in syllable
$validated = MTM::Pronunciation::Validation::TPA->validate( 'f "e2: l `a' );
is( $validated, "Missing boundary: f \"e2: l \`a\n", 'Base:missing boundary correct.' );

# Adjacent boundaris
$validated = MTM::Pronunciation::Validation::TPA->validate( 'f "e2: ~ $ l `a' );
is( $validated, "Adjacent boundaries: f \"e2: ~ \$ l `a\n", 'Base:adjacent boundaries correct.' );

#**************************************************************#
#done_testing;
