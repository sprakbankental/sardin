#!/usr/bin/perl -w

#**************************************************************#
# Legacy.t
#
# Language	sv_se
#
# Testing Legacy module
#
# (c) Swedish Agency for Accessible Media, MTM 2021

use strict;
use Test::More;

use utf8;

#**************************************************#
# Require

# Load all Legacy at once
use MTM::Legacy;
use MTM::Pronunciation::Syllabify;

my $string;
my $clean;
my $morph;
my $pron;
my $result;

#**************************************************#
# MODULE	MTM::Legacy.pm

# Function	addEnding
( $pron, $morph ) = &MTM::Legacy::addEnding( "g n \'uu:", 's' );
is( $pron, "g n \'uu: s", 'addEnding pron: correct.' );
is( $morph, "GEN", 'addEnding pron: correct.' );

# Function	cleanBlanks
$clean = &MTM::Legacy::cleanBlanks( '    	städa  mellanslag. ' );
is( $clean, 'städa mellanslag.', 'cleanBlanks clean: correct.' );

# Function	cleanMarkup
$clean = &MTM::Legacy::cleanMarkup( '<doc> Det är en <b>uppmärkt</b> grej.</doc asdf asf asdf:asdf>' );
is( $clean, '  Det är en  uppmärkt  grej. ', 'cleanMarkup clean: correct.' );

# Function	isDigitsOnly
$result = &MTM::Legacy::isDigitsOnly( '13,4' );
is( $result, '0', 'isDigitsOnly 0 (13,4): correct.' );
$result = &MTM::Legacy::isDigitsOnly( '0134' );
is( $result, '1', 'isDigitsOnly 1 (0134): correct.' );

# Function	isDefault
$result = &MTM::Legacy::isDefault( '13,4' );
is( $result, '0', 'isDefault 0 (13,4): correct.' );
$result = &MTM::Legacy::isDefault( ' -' );
is( $result, '0', 'isDefault 0 ( -): correct.' );
$result = &MTM::Legacy::isDefault( '-' );
is( $result, '1', 'isDefault 1 (-): correct.' );

# Function	isRoman
$result = &MTM::Legacy::isRoman( 'XVIX' );
is( $result, '0', 'isRoman 0 (XVIX): correct.' );
$result = &MTM::Legacy::isRoman( 'XXVVVVI' );
is( $result, '0', 'isRoman 0 (XXVVVVI): correct.' );
$result = &MTM::Legacy::isRoman( 'XXVI' );
is( $result, '1', 'isRoman 1 (XXVI): correct.' );
$result = &MTM::Legacy::isRoman( 'M M' );
is( $result, '0', 'isRoman 0 (M M): correct.' );
$result = &MTM::Legacy::isRoman( 'MM' );
is( $result, '1', 'isRoman 1 (MM): correct.' );

# Function	isLowercaseOnly
$result = &MTM::Legacy::isLowercaseOnly( 'abcDe' );
is( $result, '0', 'isLowercaseOnly 0 (abcDe): correct.' );
$result = &MTM::Legacy::isLowercaseOnly( 'éüd' );
is( $result, '1', 'isLowercaseOnly 1 (éüd): correct.' );

# Function	isUppercaseOnly
$result = &MTM::Legacy::isUppercaseOnly( 'ABCdE' );
is( $result, '0', 'isUppercaseOnly 0 (ABCdE): correct.' );
$result = &MTM::Legacy::isUppercaseOnly( 'ÉÜD' );
is( $result, '1', 'isUppercaseOnly 1 (ÉÜD): correct.' );

# Function	isPossiblyPM
$result = &MTM::Legacy::isPossiblyPM( 'hejsan', 'PM', 0 );
is( $result, '1', 'isPossiblyPM 1 (Ericsson, PM, 0): correct.' );
$result = &MTM::Legacy::isPossiblyPM( 'Ericsson', 'NN', '-' );
is( $result, '1', 'isPossiblyPM 1 (Ericsson, NN, -): correct.' );
$result = &MTM::Legacy::isPossiblyPM( 'ericsson', 'NN', '-' );
is( $result, '0', 'isPossiblyPM 0 (ericsson, NN, -): correct.' );
$result = &MTM::Legacy::isPossiblyPM( 'A', 'NN', '-' );
is( $result, '0', 'isPossiblyPM 0 (A, NN, -): correct.' );

# Function	spell
# JE Removed as thet give MTM::Legacy::spell not found
#$result = &MTM::Legacy::spell( 'A' );
#is( $result, "\'a2:", 'spell 1 (A): correct.' );

#$result = &MTM::Legacy::spell( 'W' );
#is( $result, "d \"u \$ b ë l \$ v \`e2:", 'spell 1 (W): correct.' );

#**************************************************#
# MODULE	MTM::Case.pm

# Function	makeLowercase
$result = &MTM::Case::makeLowercase( 'AÜÉKPÆÖÅ' );
is( $result, 'aüékpæöå', 'makeLowercase (AÜÉKPÆÖÅ): correct.' );

# Function	makeUppercaseFirst
$result = &MTM::Case::makeUppercaseFirst( 'aüékpæöå' );
is( $result, 'Aüékpæöå', 'makeUppercaseFirst (aüékpæöå): correct.' );

$result = &MTM::Case::makeUppercaseFirst( 'üékpæöå' );
is( $result, 'Üékpæöå', 'makeUppercaseFirst (aüékpæöå): correct.' );

# Function	makeUppercase
$result = &MTM::Case::makeUppercase( 'aüékpæöå' );
is( $result, 'AÜÉKPÆÖÅ', 'makeUppercase (aüékpæöå): correct.' );

# Function	caseLookup
$result = join"\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'caseInsensitive' );
is( $result, 'aÜÉkpÆÖÅ	aüékpæöå	AÜÉKPÆÖÅ	Aüékpæöå', 'caseLookup caseInsensitive (aÜÉkpÆÖÅ): correct.' );

$result = join"'\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'lc' );
is( $result, 'aüékpæöå', 'caseLookup lc (aÜÉkpÆÖÅ): correct.' );

$result = join"'\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'ucfirst' );
is( $result, 'Aüékpæöå', 'caseLookup ucfirst (aÜÉkpÆÖÅ): correct.' );

$result = join"'\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'uc' );
is( $result, 'AÜÉKPÆÖÅ', 'caseLookup uc (aÜÉkpÆÖÅ): correct.' );

#**************************************************#
done_testing();
