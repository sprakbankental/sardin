package Test::MTM::Pronunciation::Validation::CP_EN;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# CP validation (Swedish)
#
# Validate CP pronunciations
#
# my $validated = MTM::Pronunciation::Validation::CP_EN->validate( $pron );
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
use MTM::Pronunciation::Validation::CP_EN;

# TODO: No boundaries are allowed.

# Correct
my $validated = MTM::Pronunciation::Validation::CP_EN->validate( 'k u r e1 k t' );
is( $validated, "VALID\n", 'CP_EN:valid pronunciation check correct.' );

# Symbol check
$validated = MTM::Pronunciation::Validation::CP_EN->validate( 'ff ee1 l' );
is( $validated, "Symbol is not valid: ff\n Symbol is not valid: ee\n", 'CP_EN:symbol check correct.' );

# Unstressable phone
$validated = MTM::Pronunciation::Validation::CP_EN->validate( 'f e l1 a' );
is( $validated, "Unstressable phone: f e l1 a	l1\n", 'CP_EN:unstressable phone correct.' );

# Unstressable schwa
$validated = MTM::Pronunciation::Validation::CP_EN->validate( "f e l @1" );
is( $validated, "Schwa cannot have main stress: f e l @1	@1\n", 'Base:unstressable schwa correct.' );

# Illegal stress placement
$validated = MTM::Pronunciation::Validation::CP_EN->validate( 'f 1e l' );
is( $validated, "Illegal stress placement: f 1e l\n", 'CP_EN:illegal stress placement correct.' );

# Multiple stress
$validated = MTM::Pronunciation::Validation::CP_EN->validate( 'f e1 l a1' );
is( $validated, "Multiple stress markers: f e1 l a1\n", 'CP_EN:multiple stress correct.' );

# No main stress
$validated = MTM::Pronunciation::Validation::CP_EN->validate( 'f e l a2' );
is( $validated, "No main stress: f e l a2\n", 'CP_EN:no main stress correct.' );


#**************************************************************#
#done_testing;
