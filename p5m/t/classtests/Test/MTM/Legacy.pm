package Test::MTM::Legacy;

#**************************************************************#
# Legacy.pm
#
# Language	sv_se
#
# Testing Legacy module
#
# (c) Swedish Agency for Accessible Media, MTM 2021
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

# This also loads the class under safe conditions!
#sub class {'MTM::Legacy'};

# The module to be tested is loaded automatically, based on the
# test module's name
# use MTM::Legacy;

# These are loaded by MTM::Legacy itself
#use MTM::Case;
#use MTM::Legacy::Lists;

# If this is used by MTM::Legacy (it is), it should be loaded by it
#use MTM::Pronunciation::Syllabify;

# Protect the test vars, declare in subtests
#my $string;
#my $clean;
#my $morph;
#my $pron;
#my $result;

#**************************************************#
# MODULE	MTM::Legacy.pm

sub Legacy : Test(11) {
	# Function	addEnding
	subtest "addEnding" => sub {
		plan tests => 2;
		my ($pron, $morph);
		( $pron, $morph ) = &MTM::Legacy::addEnding( "g n \'u2:", 's' );
		is( $pron, "g n \'u2: s", 'addEnding pron: correct.' );
		is( $morph, "GEN", 'addEnding pron: correct.' );
	};
	# Function	cleanBlanks
	subtest "cleanBlanks" => sub {
		plan tests => 1;
		my $clean;
		$clean = &MTM::Legacy::cleanBlanks( '    	städa  mellanslag. ' );
		is( $clean, 'städa mellanslag.', 'cleanBlanks clean: correct.' );
	};
	# Function	cleanMarkup
	subtest "cleanMarkup" => sub {
		plan tests => 1;
		my $clean;
		$clean = &MTM::Legacy::cleanMarkup( '<doc> Det är en <b>uppmärkt</b> grej.</doc asdf asf asdf:asdf>' );
		is( $clean, '  Det är en  uppmärkt  grej. ', 'cleanMarkup clean: correct.' );
	};
	# Function	isDigitsOnly
	subtest "isDigitsOnly" => sub {
		plan tests => 2;
		my $result;
		$result = &MTM::Legacy::isDigitsOnly( '13,4' );
		is( $result, '0', 'isDigitsOnly 0 (13,4): correct.' );
		$result = &MTM::Legacy::isDigitsOnly( '0134' );
		is( $result, '1', 'isDigitsOnly 1 (0134): correct.' );
	};
	# Function	isDefault
	subtest "isDefault" => sub {
		plan tests => 3;
		my $result;
		$result = &MTM::Legacy::isDefault( '13,4' );
		is( $result, '0', 'isDefault 0 (13,4): correct.' );
		$result = &MTM::Legacy::isDefault( ' -' );
		is( $result, '0', 'isDefault 0 ( -): correct.' );
		$result = &MTM::Legacy::isDefault( '-' );
		is( $result, '1', 'isDefault 1 (-): correct.' );
	};
	# Function	isRoman
	subtest "isRoman" => sub {
		plan tests => 5;
		my $result;
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
	};
	# Function	isLowercaseOnly
	subtest "isLowercaseOnly" => sub {
		plan tests => 2;
		my $result;
		$result = &MTM::Legacy::isLowercaseOnly( 'abcDe' );
		is( $result, '0', 'isLowercaseOnly 0 (abcDe): correct.' );
		$result = &MTM::Legacy::isLowercaseOnly( 'éüd' );
		is( $result, '1', 'isLowercaseOnly 1 (éüd): correct.' );
	};
	# Function	isUppercaseOnly
	subtest "isUppercaseOnly" => sub {
		plan tests => 2;
		my $result;
		$result = &MTM::Legacy::isUppercaseOnly( 'ABCdE' );
		is( $result, '0', 'isUppercaseOnly 0 (ABCdE): correct.' );
		$result = &MTM::Legacy::isUppercaseOnly( 'ÉÜD' );
		is( $result, '1', 'isUppercaseOnly 1 (ÉÜD): correct.' );
	};
	# Function	isPossiblyPM
	subtest "isPossiblyPM" => sub {
		plan tests => 4;
		my $result;
		$result = &MTM::Legacy::isPossiblyPM( 'hejsan', 'PM', 0 );
		is( $result, '1', 'isPossiblyPM 1 (Ericsson, PM, 0): correct.' );
		$result = &MTM::Legacy::isPossiblyPM( 'Ericsson', 'NN', '-' );
		is( $result, '1', 'isPossiblyPM 1 (Ericsson, NN, -): correct.' );
		$result = &MTM::Legacy::isPossiblyPM( 'ericsson', 'NN', '-' );
		is( $result, '0', 'isPossiblyPM 0 (ericsson, NN, -): correct.' );
		$result = &MTM::Legacy::isPossiblyPM( 'A', 'NN', '-' );
		is( $result, '0', 'isPossiblyPM 0 (A, NN, -): correct.' );
	};
	# Function	mark_abbreviations
	subtest "mark_abbreviations" => sub {
		plan tests => 1;
		my $result;
		$result = &MTM::Legacy::mark_abbreviations( 'fr.o.m.' );
		is( $result, '<ABBR>fr.o.m.<eABBR>', 'mark_abbreviations correct.' );
	};
	# Function	mark_abbreviations
	subtest "mark_abbreviations" => sub {
		plan tests => 1;
		my $result;
		$result = &MTM::Legacy::mark_abbreviations( 'En mening o. s. v.' );
		is( $result, 'En mening <ABBR>o. s. v.<eABBR>', 'mark_abbreviations correct.' );
	};
}
#**************************************************#
# MODULE	MTM::Case.pm
sub Characterisation : Test(4) {
	# Function	makeLowercase
	subtest "makeLowercase" => sub {
		plan tests => 1;
		my $result;
		$result = &MTM::Case::makeLowercase( 'AÜÉKPÆÖÅ' );
		is( $result, 'aüékpæöå', 'makeLowercase (AÜÉKPÆÖÅ): correct.' );
	};
	# Function	makeUppercaseFirst
	subtest "makeUppercaseFirst" => sub {
		plan tests => 2;
		my $result;
		$result = &MTM::Case::makeUppercaseFirst( 'aüékpæöå' );
		is( $result, 'Aüékpæöå', 'makeUppercaseFirst (aüékpæöå): correct.' );

		$result = &MTM::Case::makeUppercaseFirst( 'üékpæöå' );
		is( $result, 'Üékpæöå', 'makeUppercaseFirst (aüékpæöå): correct.' );
	};
	# Function	makeUppercase
	subtest "makeUppercase" => sub {
		plan tests => 1;
		my $result;
		$result = &MTM::Case::makeUppercase( 'aüékpæöå' );
		is( $result, 'AÜÉKPÆÖÅ', 'makeUppercase (aüékpæöå): correct.' );
	};
	# Function	caseLookup
	subtest "caseLookup" => sub {
		plan tests => 4;
		my $result;
		$result = join"\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'caseInsensitive' );
		is( $result, 'aÜÉkpÆÖÅ	aüékpæöå	AÜÉKPÆÖÅ	Aüékpæöå', 'caseLookup caseInsensitive (aÜÉkpÆÖÅ): correct.' );

		$result = join"'\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'lc' );
		is( $result, 'aüékpæöå', 'caseLookup lc (aÜÉkpÆÖÅ): correct.' );

		$result = join"'\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'ucfirst' );
		is( $result, 'Aüékpæöå', 'caseLookup ucfirst (aÜÉkpÆÖÅ): correct.' );

		$result = join"'\t", &MTM::Case::caseLookup( 'aÜÉkpÆÖÅ', 'uc' );
		is( $result, 'AÜÉKPÆÖÅ', 'caseLookup uc (aÜÉkpÆÖÅ): correct.' );
	};
}
sub Tools : Test(3) {
	# FUNCTION	cleanSplitters
	subtest "cleanSplitters" => sub {
		plan tests => 1;
		my $result;
		$result = join'<WD>', &MTM::Legacy::clean_multiples( '<SPLITTER>', '<SPLITTER> <SPLITTER>   <SPLITTER><SPLITTER><SPLITTER>' );
		is( $result, ' <SPLITTER>   ', 'clean_multiples (cleanSplitters): correct.' );
	};
	# FUNCTION	rewrite_chars
	subtest "rewrite_chars" => sub {
		plan tests => 1;
		my $result;
		$result = join'<WD>', &MTM::Legacy::rewrite_chars( 'start. 123', 'normal' );
		is( $result, 'start<PERIOD><SPACE><ONE><TWO><THREE>', 'rewrite_chars: correct.' );
	};
	# FUNCTION	restore_rewritten_chars
	subtest "restore_rewritten_chars" => sub {
		plan tests => 1;
		my $result;
		$result = join'<WD>', &MTM::Legacy::restore_rewritten_chars( 'start<PERIOD><SPACE><ONE><TWO><THREE>', 'normal' );
		is( $result, 'start. 123', 'restore_rewritten_chars: correct.' );
	};
}
1;
#**************************************************#
