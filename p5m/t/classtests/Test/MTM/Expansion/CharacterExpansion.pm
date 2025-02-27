package Test::MTM::Expansion::CharacterExpansion;

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


use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Expansion';

require MTM::TTSChunk;

sub class {'MTM::Expansion::CharacterExpansion'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_expansion('CharacterExpansion');
}

sub expand : Tests(244) {
	my $test = shift;

	# expandFraction
	$test->chunk_assert(	'½', 'en|halv', 0, '½');
	$test->chunk_assert(	'1/2', '-', 0, '1');
	$test->chunk_assert(	'1/2 liter', 'en|halv', 0, '1/2');
	$test->chunk_assert(	'¼', 'en|fjärdedel', 0, '¼');
	$test->chunk_assert(	'1/4 dl.', 'en|fjärdedel', 0, '1/4');
	$test->chunk_assert(	'¾', 'tre|fjärdedelar', 0, '¾');
	$test->chunk_assert(	'3/4 meter', 'tre|fjärdedelar', 0, '3/4');


	# Gender
	$test->chunk_assert(	'½ mått', 'ett|halvt', 0, '½');
	$test->chunk_assert(	'1/2 deciliter', 'en|halv', 0, '1/2');

	# Preceding digit
	$test->chunk_assert(	'2½', 'och|en|halv', 1, '½');
	$test->chunk_assert(	'2 ½ mått', 'och|ett|halvt', 2, '½');
	$test->chunk_assert(	'5 ¾', 'och|tre|fjärdedelar', 2, '¾');

	# expandEllipsis
	# Do we need this?

	# expandComma
	$test->chunk_assert(	'12,5', 'komma', 1, ',');
	$test->chunk_assert(	', ', '-', 0, ',');

	# expandPeriod
	$test->chunk_assert(	'12.5', 'punkt', 1, '.');
	$test->chunk_assert(	'.66', 'punkt', 0, '.');

	# expandMultiplier
	$test->chunk_assert(	'×', 'gånger', 0, '×');

	# expandPlus
	$test->chunk_assert(	'5+4', 'plus', 1, '+');
	$test->chunk_assert(	'+', 'plus', 0, '+');

	# expandDash
	# TODO $test->chunk_assert(	'5-4', 'streck', 1, '-' );
	$test->chunk_assert( '7-8 min.', 'till', 1, '-' );
	$test->chunk_assert( '7 b-8 c kap.', 'till', 3, '-' );
	$test->chunk_assert(	'2008-04-14', '-', 1, '-' );
	$test->chunk_assert(	'2008-04-14', '-', 3, '-' );
	$test->chunk_assert(	'-.', '-', 0, '-' );
	$test->chunk_assert(	'ord - ord', '-', 2, '-' );
	$test->chunk_assert(	'3-2 blev det', 'streck', 1, '-' );

	# expandSlash
	# TODO MATHS makrup	$test->chunk_assert(	'20/5=4', 'delat med', 1, '/');	# TODO	check if MATHS
	$test->chunk_assert(	'25/4-1998', 'i', 1, '/');		# TODO	check if DATE
	$test->chunk_assert(	'/', 'snedstreck', 0, '/');		# TODO	check if not DATE or MATHS

	# expandQuestionMark
	$test->chunk_assert(	'http://test_is?jksjf.com', 'frågetecken', 7, '?');
	$test->chunk_assert(	'Verkligen?', '-', 1, '?');
	$test->chunk_assert(	'Jaså?!', '-', 1, '?');
	$test->chunk_assert(	'?', '-', 0, '?');

	# expandExclamationMark
	$test->chunk_assert(	'http://test_is!jksjf.com', 'utropstecken', 7, '!');
	$test->chunk_assert(	'Verkligen!', '-', 1, '!');
	$test->chunk_assert(	'Jaså?!', '-', 2, '!');
	$test->chunk_assert(	'!', '-', 0, '!');
#
	# expandSectionSign
	# TODO when law references are solved.

	# expandAtSign
	$test->chunk_assert(	'@', 'snabel-a', 0, '@');

	# expandPercent
	$test->chunk_assert(	'http://test_is%jksjf.com', 'procenttecken', 7, '%');
	$test->chunk_assert(	'%', 'procent', 0, '%');

	### This one causes warning: Wide character in print at /usr/local/share/perl/5.30.0/Test2/Formatter/TAP.pm line 156.
	# expandPermille
	#$test->chunk_assert( 'http://test_is‰jksjf.com', 'promilletecken', 7, '‰');
	#$test->chunk_assert( '‰', 'promille', 0, '‰');

	# expandAmpersand
	$test->chunk_assert(	'http://test_is&jksjf.com', 'och-tecken', 7, '&');
	$test->chunk_assert(	'&', 'och', 0, '&');

	# expandEqualSign
	$test->chunk_assert(	'=', 'är|lika|med', 0, '=');

	# expandColon
	$test->chunk_assert(	'http://test_is&jksjf.com', 'kolon', 1, ':');
	$test->chunk_assert(	'15:67', 'kolon', 1, ':');
	#$test->chunk_assert(	'Text: text', 'PAUSE', 1);	# TODO check pause

	# expandBackslash
	$test->chunk_assert("\\", 'omvänt|snedstreck', 0, "\\");

	# expandTilde
	$test->chunk_assert(	'http://test_is~jksjf.com', 'tilde', 7, '~');
	$test->chunk_assert(	'~', '-', 0, '~');

	### This one causes warning: Wide character in print at /usr/local/share/perl/5.30.0/Test2/Formatter/TAP.pm line 156.
	# expandDegree
	$test->chunk_assert(	'1º', 'grad', 1, 'º');
	$test->chunk_assert(	'21º**', 'grader', 1, 'º');
	$test->chunk_assert(	'1°', 'grad', 1, '°');
	$test->chunk_assert(	'21°**', 'grader', 1, '°');

	# expandCopyright
	$test->chunk_assert(	'©', 'copyright', 0, '©');

	# expandPlusMinus
	$test->chunk_assert(	'±', 'plus|minus', 0, '±');


	# expandAsterisk
	$test->chunk_assert(	'*1998', 'född', 0, '*');	# TODO check if DATE|YEAR
	$test->chunk_assert(	'* 1998', 'född', 0, '*');	# TODO check if DATE|YEAR
	$test->chunk_assert(	'Enkel*', 'asterisk', 1, '*');
	$test->chunk_assert(	'Dubbel**', 'asterisk', 1, '*');

	### This one causes warning: Wide character in print at /usr/local/share/perl/5.30.0/Test2/Formatter/TAP.pm line 156.
	# expandDagger
	#$test->chunk_assert(	'†1998', 'avliden', 0, '†');	# TODO check if DATE|YEAR
	#$test->chunk_assert(	'† 1998', 'avliden', 0, '†');	# TODO check if DATE|YEAR
	#$test->chunk_assert(	'†', 'korstecken', 0, '†');

	#*******************************************************************************************************#
	# PARENTHESIS AND QUOTES

	# expandParenthesis
	$test->chunk_assert(	'Texten (ett) mer text.', '-', 2,
		{orth => '(', pause => '150'}
		);
	$test->chunk_assert(	'Texten (ett) mer text.', '-', 4,
		{orth => ')', pause => '150'},
		);

	$test->chunk_assert(	'Texten (ett två tre fyra inget slut.', '-', 2,
		{orth => '(', pause => '150'}
		);

	# This test does acutally belong to the pause tests (no opening parenthesis seen).
	$test->chunk_assert(	'Texten ett två tre fyra) ingen början.', '-', 9,
		{orth => ')'}
		);

###	$test->chunk_assert(	'Texten (ett, två, tre, fyra) mer text.', 'parentes', 2, '(');
###	$test->chunk_assert(	'Texten (ett, två, tre, fyra) mer text.', 'slut|parentes', 13, ')');

	# expandDoublequote
	$test->chunk_assert(	'Texten "ett" mer text.', '-', 2,
		{orth => '"', pause => '150'}
		);

	$test->chunk_assert(	'Texten "ett" mer text.', '-', 4,
		{orth => '"', pause => '150'}
		);

	$test->chunk_assert(	'Texten "ett två tre fyra inget slut.', '-', 2,
		{orth => '"', pause => '150'}
		);

	$test->chunk_assert(	'Texten ett två tre fyra" ingen början.', '-', 9,
		{orth => '"', pause => '150'}
		);

###	$test->chunk_assert(	'Texten "ett, två, tre, fyra" mer text.', 'citat', 2, '"');
###	$test->chunk_assert(	'Texten "ett, två, tre, fyra" mer text.', 'slut|citat', 13, '"');


	#*******************************************************************************************************#
	# CURRENCIES

	### Something here causes warning: Wide character in print at /usr/local/share/perl/5.30.0/Test2/Formatter/TAP.pm line 156.

	# expandDollar
	$test->chunk_assert(	'http://test_i$&jksjf.com', 'dollartecken', 7, '$');
	$test->chunk_assert(	'$', 'dollar', 0, '$');

	# expandPound
	$test->chunk_assert(	'£', 'pund', 0, '£');

	# expandEuro
	#$test->chunk_assert(	'€', 'euro', 0, '€');

	# expandYen
	$test->chunk_assert(	'¥', 'yen', 0, '¥');

	# expandCent
	$test->chunk_assert(	'¢', 'cent', 0, '¢');



	#*******************************************************************************************************#

}

