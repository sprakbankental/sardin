package Test::MTM::Pronunciation::Validation::CP;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# CP validation (Swedish)
#
# Validate CP pronunciations
#
# my $validated = MTM::Pronunciation::Validation::CP->validate( $pron );
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
use MTM::Pronunciation::Validation::CP;

# TODO: No boundaries are allowed.

# Correct
my $validated = MTM::Pronunciation::Validation::CP->validate( 'k u r e4 k t' );
is( $validated, "VALID\n", 'CP:valid pronunciation check correct.' );

$validated = MTM::Pronunciation::Validation::CP->validate( "f eeh4 l eh" );
is( $validated, "VALID\n", 'CP:stressed diphthong correct.' );

# Symbol check
$validated = MTM::Pronunciation::Validation::CP->validate( 'ff e:4 l' );
is( $validated, "Symbol is not valid: ff\n Symbol is not valid: e:\n", 'CP:symbol check correct.' );

# Unstressable phone
$validated = MTM::Pronunciation::Validation::CP->validate( 'f ee l4 a' );
is( $validated, "Unstressable phone: f ee l4 a	l4\n", 'CP:unstressable phone correct.' );

# Unstressable schwa
$validated = MTM::Pronunciation::Validation::CP->validate( "f ee l eh4" );
is( $validated, "Schwa cannot have main stress: f ee l eh4	eh4\n", 'CP:unstressable schwa correct.' );


# Illegal stress placement
$validated = MTM::Pronunciation::Validation::CP->validate( 'f 4ee l' );
is( $validated, "Illegal stress placement: f 4ee l\n", 'CP:illegal stress placement correct.' );

# Multiple stress
$validated = MTM::Pronunciation::Validation::CP->validate( 'f ee4 l a4' );
is( $validated, "Multiple stress markers: f ee4 l a4\n", 'CP:multiple stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::CP->validate( 'f ee l a2' );
is( $validated, "No main stress: f ee l a2\n", 'CP:no main stress correct.' );

# No secondary stress
$validated = MTM::Pronunciation::Validation::CP->validate( 'f ee3 l a' );
is( $validated, "No secondary stress: f ee3 l a\n", 'CP:no secondary stress correct.' );

# Adjacent boundaris
$validated = MTM::Pronunciation::Validation::CP->validate( 'f ee3 ~ - l a2' );
is( $validated, "Adjacent boundaries: f ee3 ~ - l a2\n", 'Base:adjacent boundaries correct.' );

#**************************************************************#
#done_testing;
