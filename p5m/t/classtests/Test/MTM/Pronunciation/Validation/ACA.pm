package Test::MTM::Pronunciation::Validation::ACA;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# ACA validation (Swedish)
#
# Validate ACA pronunciations
#
# my $validated = MTM::Pronunciation::Validation::ACA->validate( $pron );
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
use MTM::Pronunciation::Validation::ACA;

# TODO: No boundaries are allowed.

# Correct
my $validated = MTM::Pronunciation::Validation::ACA->validate( 'k U r E4 k t' );
is( $validated, "VALID\n", 'ACA:valid pronunciation check correct.' );

# Symbol check
$validated = MTM::Pronunciation::Validation::ACA->validate( 'ff ee4 l' );
is( $validated, "Symbol is not valid: ff\n Symbol is not valid: ee\n", 'ACA:symbol check correct.' );

# Unstressable phone
$validated = MTM::Pronunciation::Validation::ACA->validate( 'f e: l4 a' );
is( $validated, "Unstressable phone: f e: l4 a	l4\n", 'ACA:unstressable phone correct.' );

# Unstressable schwa
$validated = MTM::Pronunciation::Validation::ACA->validate( "f e: l \@4" );
is( $validated, "Schwa cannot have main stress: f e: l \@4	\@4\n", 'Base:unstressable schwa correct.' );

# Illegal stress placement
$validated = MTM::Pronunciation::Validation::ACA->validate( 'f 4e: l' );
is( $validated, "Illegal stress placement: f 4e: l\n", 'ACA:illegal stress placement correct.' );

# Multiple stress
$validated = MTM::Pronunciation::Validation::ACA->validate( 'f e:4 l a4' );
is( $validated, "Multiple stress markers: f e:4 l a4\n", 'ACA:multiple stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::ACA->validate( 'f e: l a1' );
is( $validated, "No main stress: f e: l a1\n", 'ACA:no main stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::ACA->validate( 'p s t' );
is( $validated, "VALID\n", 'ACA:exceptions correct.' );

# No secondary stress: ACA does not use secondary stress for simplex words.
#$validated = MTM::Pronunciation::Validation::ACA->validate( 'f e:3 l a' );
#is( $validated, "No secondary stress: f e:3 l a\n", 'ACA:no secondary stress correct.' );

#**************************************************************#
#done_testing;
