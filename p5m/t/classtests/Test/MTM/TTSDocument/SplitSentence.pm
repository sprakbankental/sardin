package Test::MTM::TTSDocument::SplitSentence;

#**************************************************************#
# SplitSentence.pm
#
# Language	sv_se
#
# Testing normalisation and sentence split functions
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#
#**************************************************************#
use v5.32;										# We assume pragmas and such from 5.32.0
use Test::More;							 # Explicitly load modules - no Test::Most
use parent qw(ClassTestBase); # Local class which inherits from Test::Class

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings		qw< FATAL	utf8 >;
use open				qw< :std	:utf8 >;		 # Should perhaps be :encoding(utf-8)?
use charnames	 qw< :full :short >;		# autoenables in v5.16 and above
use feature		 qw< unicode_strings >;
no feature			qw< indirect >;	
use feature		 qw< signatures >;
no warnings		 qw< experimental::signatures >;
# END SBTal boilerplate

my $result;

#**************************************************#
# Loaded automatically by test system
#use MTM::TTSDocument::SplitSentence;
# Unsure where this is used, but if it is in MTM::TTSDocument::SplitSentence,
# it should be loaded there, But in there, MTM::Legacy seems to be the thing, not the lists.
#use MTM::Legacy::Lists;

sub _testlauncher ($pairs) {
	plan tests => scalar(@$pairs);
	foreach my $pair (@$pairs) {
		my ($in, $expected) = @$pair;
		my $res = &MTM::TTSDocument::SplitSentence::splitSentence($in);
		is($res, $expected);
	}
}

#**************************************************#
# MODULE	MTM::TTSDocument::SplitSentence.pm
sub splitSentence : Tests(24) {
	diag "Testing splitSentence";
	#---------------------------------------------------------------------#
	subtest "Abbreviations (sv)" => sub {
		my $pairs = [
			[
				'T. ex. katter. Hundar, hästar, m.m. ska vi ha.',
				'T. ex. katter. <SENT_SPLIT>Hundar, hästar, m.m. ska vi ha.',
			],
			[
				'T.ex. hästar.',
				'T.ex. hästar.',
			],
			[
				'På 400-talet f. Kr. levde Sokrates...',
				'På 400-talet f. Kr. levde Sokrates...',
			],
			[
				'Jag har P. som favorit.',
				'Jag har P. som favorit.',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Abbreviations (en)" => sub {
		my $pairs = [
			[
				'a.m',
				'a.m',
			],
			[
				'p.m',
				'p.m',
			],
		];
		_testlauncher($pairs);
	};

# CT 230420 This is only when land is en, to be tested in English settings.
#	subtest "Abbreviations (en, TODO)" => sub {
#		local $TODO = 'This has yet to pass!';
#		my $pairs = [
#			[
#				'E.g. cats. Dogs, horses a. s. o. also.',
#				'E.g. cats. <SENT_SPLIT>Dogs, horses a. s. o. also.',
#			],
#			[
#				'Read p. 39',
#				'Read p. 39',
#			],
#		];
#		_testlauncher($pairs);
#	};
	#---------------------------------------------------------------------#
	subtest "Initials (sv)" => sub {
		my $pairs = [
			[
				'T. ex. katter. Hundar, hästar, m.m. ska vi ha.',
				'T. ex. katter. <SENT_SPLIT>Hundar, hästar, m.m. ska vi ha.',
			],
			[
				'Jo, men det var H.C. Andersson och A. A. P. Andersson.',
				'Jo, men det var H.C. Andersson och A. A. P. Andersson.',
			],
			[
				'Lärde känna H. 1968 i Dublin.',
				'Lärde känna H. 1968 i Dublin.',
			],
			[
				'Zizzy f. 1979',
				'Zizzy f. 1979',
			],
			[
				'a.å',
				'a.å',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Initials (en)" => sub {
		my $pairs = [
			[
				'Yes, but it was H.C. Andersson and A. A. Andersson.',
				'Yes, but it was H.C. Andersson and A. A. Andersson.',
			],
			[
				'Learning to know H. 1968 in Dublin.',
				'Learning to know H. 1968 in Dublin.',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Single char (sv)" => sub {
		my $pairs = [
			[
				'Ett enda tecken kvar.a',
				'Ett enda tecken kvar.a',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Single char (en)" => sub {
		my $pairs = [
			[
				'One single character left.a',
				'One single character left.a',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Chars (sv)" => sub {
		my $pairs = [
			[
			'"Jodå?" det kan man göra.',
			'"Jodå?" det kan man göra.',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Digits (sv)" => sub {
		my $pairs = [
			[
				'123.456',
				'123.456',
			],
			[
				'Värdet är .5.',
				'Värdet är .5.',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Digits (sv)" => sub {
		my $pairs = [
			[
				'The value is .5.',
				'The value is .5.', 'splitSentence (.5): correct.',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Ellipsis (sv)" => sub {
		my $pairs = [
			[
				'Jo-... det är nog så.',
				'Jo-... det är nog så.',
			],
			[
				'Jo... Det är nog så.',
				'Jo... <SENT_SPLIT>Det är nog så.',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Ellipsis (en)" => sub {
		my $pairs = [
			[
				'Well... Okay.',
				'Well... <SENT_SPLIT>Okay.',
			],
			[
				'Well-... okay.',
				'Well-... okay.',
			],
			[
				'5 p.m...',
				'5 p.m...',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Exclamation marks (sv)" => sub {
		my $pairs = [
			[
				'Jo! det är nog så.',
				'Jo! det är nog så.',
			],
			[
				'Jo! Det är nog så.',
				'Jo! <SENT_SPLIT>Det är nog så.',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Exclamation marks (en)" => sub {
		my $pairs = [
			[
				'Yes! okay.',
				'Yes! okay.',
			],
			[
				'Yes! Okay.',
				'Yes! <SENT_SPLIT>Okay.',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Parentheses (sv)" => sub {
		my $pairs = [
			[
				'Nu är det (saker inom parentes).',
				'Nu är det (saker inom parentes).',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Parentheses (en)" => sub {
		my $pairs = [
			[
				'Here it is (things within parentheses).',
				'Here it is (things within parentheses).',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Citation marks (sv)" => sub {
		my $pairs = [
			[
				'"Ett, två." Sen tre.',
				'"Ett, två."<SENT_SPLIT> Sen tre.',
			],
		];
		_testlauncher($pairs);
	};
	subtest "Citation marks (en)" => sub {
		my $pairs = [
			[
			'"Yeah?" you can do that.',
			'"Yeah?" you can do that.',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "' sa han' (sv)" => sub {
		my $pairs = [
			[
				'"Ja" sa han',
				'"Ja" sa han',
			],
		];
		_testlauncher($pairs);
	};
	subtest "' sa han' (en)" => sub {
		my $pairs = [
			[
			'"Yes" he said',
			'"Yes" he said',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "., (sv)" => sub {
		my $pairs = [
			[
				'hej., sa någon',
				'hej., sa någon',
			],
		];
		_testlauncher($pairs);
	};
	subtest "., (en)" => sub {
		my $pairs = [
			[
				'hi., said somebody',
				'hi., said somebody',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
	subtest "Ampersand (sv)" => sub {
		my $pairs = [
			[
				'H&M',
				'H&M',
			],
		];
		_testlauncher($pairs);
	};
	subtest "UTF-8 (sv)" => sub {
		my $pairs = [
			[
				'Ja det är dæ just jæ.',
				'Ja det är dæ just jæ.',
			],
		];
		_testlauncher($pairs);
	};
	#---------------------------------------------------------------------#
#	Anmälningsplikten är dessutom inskriven i skollagen fr.o.m. 2003.
	subtest "fr.o.m (sv)" => sub {
		my $pairs = [
			[
				'Anmälningsplikten är dessutom inskriven i skollagen fr.o.m. 2003.',
				'Anmälningsplikten är dessutom inskriven i skollagen fr.o.m. 2003.',
			],
		];
		_testlauncher($pairs);
	};


}
1;
#***********************************************************************#
