package Test::MTM::Pronunciation::Autopron;

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

# We do not need to load the module to be tested explicitly.
# If it is not the same as the current test package name minus the initial 'Test::',
# use the following form to provide the class name. It will then be loaded safely.
#sub class {'MTM::Pronunciation::Autopron'};
# If it is the same as the current package name minus the initial 'Test::', as it
# should be, it will be loaded safely automatically by our parent ClassTestBase
# ==============================================================================
#
# If this is needed by Autopron it should be loaded by Autopron (and it is now)
# use MTM::Case;

# This is legacy code, and not needed for loading modules, as this is dealt with by
# the parent class now. It can be used to set up module specific things, such as
# loading a module with non-default settings
#sub startup : Test(startup) {
#	my $test  = shift;
#	my $class = $test->class;
#	eval "use $class";
#	die $@ if $@;
#}

#**************************************************#
# MODULE	MTM::Autopron.pm

sub Autopron : Test(7) {
	# Function	setStress2
	subtest "setStress2" => sub {
		plan tests => 12;
		my $pron;
		$pron = &MTM::Pronunciation::Autopron::setStress2( 'SASM', "s a s m", 'sv_se' );
		is( $pron, "s \'a s m", 'setstress2 (sasm): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'test', "t e s t", 'sv_se' );
		is( $pron, "t \'e s t", 'setstress2 (test): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'testat', 't e s t a t', 'default' );
		is( $pron, "t \"e s t \`a t", 'setstress2 (testat): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'sprätt', 's p r ä t', 'default' );
		is( $pron, "s p r \'ä t", 'setstress2 (sprätt): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'tidning', 't i2: d n i ng', 'default' );
		is( $pron, "t \"i2: d n \`i ng", 'setstress2 (tidning): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'spindelskivling', 's p i n d ë l sj i2: v l i ng', 'default' );
		is( $pron, "s p \"i n d ë l sj \`i2: v l i ng", 'setstress2 (spindelskivling): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'brnpst', 'b r n p s t', 'default' );
		is( $pron, "b r n p s t", 'setstress2 (brnpst): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'blåtts', 'b l \'å t s', 'default' );
		is( $pron, "b l \'å t s", 'setstress2 (blåtts): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'blödde', 'b l ö d ë', 'default' );
		is( $pron, "b l \"ö d \`ë", 'setstress2 (blödde): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'prekärare', 'p r e3 k ä3: r a r ë', 'default' );
		is( $pron, "p r e3 k \'ä3: r a r ë", 'setstress2 (prekärare): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'populärast', 'p å p u3 l ä3: r a s t', 'default' );
		is( $pron, "p å p u3 l \'ä3: r a s t", 'setstress2 (populärast): correct.' );

		$pron = &MTM::Pronunciation::Autopron::setStress2( 'processpårning', 'p r o3 s ë s s p å2: rn i ng', 'swe' );
		is( $pron, "p r o3 s \"e s s p \`å2: rn i ng", 'setStress2 (processpårning): correct.' );
	};
	#**************************************************#
	# Function	cart
	subtest "cart" => sub {
		plan tests => 8;
		my $pron;
		$pron = &MTM::Pronunciation::Autopron::cart( 'test', 'sv_se' );
		is( $pron, "t e s t", 'cart (test): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'blåtts', 'sv_se' );
		is( $pron, "b l å t s", 'cart (blåtts): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'ico', 'default' );
		is( $pron, "i k o", 'cart (ico): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'iCO', 'default' );
		is( $pron, "i k o", 'cart (iCO): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'ÏçÔ', 'swe' );
		is( $pron, "i k o", 'cart (ÏçÔ): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'prekärare', 'swe' );
		is( $pron, "p r e3 k ä3: r a r ë", 'cart (prekärare): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'wåtön', 'eng' );
		is( $pron, "v a t o2: n", 'cart (wåtön): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cart( 'processpårning', 'default' );
		is( $pron, "p r o3 s ë s s p å2: rn i ng", 'cart (processpårning): correct.' );
	};
	#**************************************************#
	# Function	cartAndStress
	subtest "cart and stress" => sub {
		plan tests => 10;
		my $pron;

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'JÄRN', 'sv_se' );
		is( $pron, "j \'ä3: rn", 'cartAndStress (JÄRN): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'prekärare', 'sv_se' );
		is( $pron, "p r e3 k \'ä3: r a r ë", 'cartAndStress (prekärare): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'populärast', 'sv_se' );
		is( $pron, "p å p u3 l \'ä3: r a s t", 'cartAndStress (populärast): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'prekärast', 'sv_se' );
		is( $pron, "p r e3 k \'ä3: r a s t", 'cartAndStress (prekärast): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'Lidl', 'sv_se' );
		is( $pron, "l \'i2: d ë l", 'cartAndStress (Lidl): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'harts', 'sv_se' );
		is( $pron, "h \'a rt rs", 'cartAndStress (harts): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'blåtts', 'default' );
		is( $pron, "b l \'å t s", 'cartAndStress (blåtts): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'blödde', 'default' );
		is( $pron, "b l \"ö d \`ë", 'cartAndStress (blödde): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'processpårning', 'default' );
		is( $pron, "p r o3 s \"e s s p \`å2: rn i ng", 'cartAndStress (processpårning): correct.' );

		$pron = &MTM::Pronunciation::Autopron::cartAndStress( 'mîm', 'default' );
		is( $pron, "m \'i m", 'cartAndStress (mîm): correct.' );
	};
	#**************************************************#
	# Function	stressToFirstVowel
	subtest "stressToFirstVowel" => sub {
		plan tests => 5;
		my ($pron, @rest);

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToFirstVowel( 'p l a t e2: rn a', '1' );
		is( $pron, "p l \'a t e2: rn a", 'stressToFirstVowel (platerna): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToFirstVowel( 'p l ë t e2: rn a', '2' );
		is( $pron, "p l \"ë t \`e2: rn a", 'stressToFirstVowel (platerna): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToFirstVowel( 'p r o3 s ë s s p å2: rn i ng', '1' );
		is( $pron, "p r \'o3 s ë s s p å2: rn i ng", 'stressToFirstVowel (processpårning): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToFirstVowel( 'p r o3 s ë s s p å2: rn i ng', '2' );
		is( $pron, "p r \"o3 s \`ë s s p å2: rn i ng", 'stressToFirstVowel (processpårning): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToFirstVowel( "p a r e n t ë s", '1' );
		is( $pron, "p \'a r e n t ë s", 'stressToFirstVowel (parentes): correct.' );
	};
	#**************************************************#
	# Function	stressToTarget
	subtest "stressToTarget" => sub {
		plan tests => 3;
		my ($pron, @rest);

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToTarget( 'platerna', 'p l a t e2: rn a', 2, 1 );
		is( $pron, "p l \'a t e2: rn a", 'stressToTarget (haplaternarts): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToTarget( 'platerna', 'p l a t e2: rn a', 4, 2 );
		is( $pron, "p l a t \"e2: rn a", 'stressToTarget (platerna): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressToTarget( 'platerna', 'p l a t e2: rn a', 6, 3 );
		is( $pron, "p l a t e2: rn \`a", 'stressToTarget (platerna): correct.' );
	};
	#**************************************************#
	# Function	stressSchwa
	subtest "stressSchwa" => sub {
		plan tests => 2;
		my ($pron, @rest);

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressSchwa( 'p l ë', 1 );
		is( $pron, "p l \'e", 'stressSchwa (p l ë): correct.' );

		( $pron, @rest ) = &MTM::Pronunciation::Autopron::stressSchwa( 'p l ë', 2 );
		is( $pron, "p l \"e", 'stressSchwa (p l ë): correct.' );
	};
	#**************************************************#
	# Function	assignStress
	# Stress location is outside word, assign to first vowel
	subtest "assignStress" => sub {
		plan tests => 1;
		my ($pron, @rest);
		( $pron, @rest ) = &MTM::Pronunciation::Autopron::assignStress( 'platerna', 'p l a t e2: rn a', 10, 1 );
		is( $pron, "p l \'a t e2: rn a", 'assignStress (p l a t e2: rn a): correct.' );
	};
}

1;
#**************************************************#
