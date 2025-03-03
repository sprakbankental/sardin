package Test::MTM::Pronunciation::AutopronEspeak;

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

use MTM::Pronunciation::AutopronEspeak;
use MTM::Pronunciation::Syllabify;
use MTM::Vars;

# To get the results in utf8: export PERL_UNICODE=SDL

#binmode(STDOUT, ":utf8");
#plan tests => 40; # Why this number?

sub Autopron : Test(7) {
	
	subtest "espeack" => sub {
		is('apa', 'apa', "Testing the test");
		
		## Call to espeak -q -v en-uk -x
		my ($pron1, $err1) = MTM::Pronunciation::AutopronEspeak::espeak('en-uk', 'mama');
		is($pron1, "m'ama#", 'espeak');
		is($err1, undef);
		
		## Parsing espak-ng phoneme sequence into individual symbols
		my ($syms, $unknown) = MTM::Pronunciation::AutopronEspeak::parseEnUKPron('f\'aI@');
		
		is(@$syms, 4, "parseEnUKPron");
		is(@$syms[0], 'f');
		is(@$syms[1], '\'');
		is(@$syms[2], 'aI');
		is(@$syms[3], '@');
		
		# Handling of unknown symbol (Ö) in pron
		($syms, $unknown) = MTM::Pronunciation::AutopronEspeak::parseEnUKPron('f\'aIÖ@');
		is(@$syms, 4);
		is(@$unknown, 1);
		is(@$unknown[0], 'Ö');
		is(@$syms[0], 'f');
		is(@$syms[1], '\'');
		is(@$syms[2], 'aI');
		is(@$syms[3], '@');
		
		## Conversion between espeak en-uk and TPA
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA('t'), 't', 'espeakEnUk2TPA');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA('h\'at'), 'h \'ae t');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA('h\'aI'), 'h \'ai');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("h'ElIk,0pt3"), "h 'e \. l i \. k o p \. t ex r0");
		
		# TODO Problem w. 3r- sequence
		# is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("h'ElIk,0pt3r-and"), 'h \'e . l i . k o p . t ex rh | ae n d');
	
		
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("f'IS"), "f 'i rs");
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("k'A@"), "k 'a: r0");
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("d'0g"), "d 'o g");
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("j'u:l"), "j 'uw: l");
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("tS'Ip"), 'tc \'i p');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("r'0k"), 'rh \'o k');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("b'3:d"), 'b \'oe: d'); # NB no /r0/
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("tr'VNk"), 't rh \'a ng k');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("b'u:t"), 'b \'uw: t');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("w'O:t3"), 'w \'o: . t ex r0');
		
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("T'IN"), 'th \'i ng');
		is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA("D'eI"), 'dh \'ei');
		
		#is(MTM::Pronunciation::AutopronEspeak::espeakEnUk2TPA(""), '');
		
		## Generate TPA from espeak en-uk
		#is(MTM::Pronunciation::AutopronEspeak::run_espeak('t'), 't');
		my ($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak('hat');
		is($pron, 'h \'ae t', 'run_espeak');
		is($err, undef);
		
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak('hi');
		is($pron, 'h \'ai');
		is($err, undef);
		
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("helicopter");
		is($pron, "h 'e \. l i \. k o p \. t ex r0");
		is($err, undef);
		
		# NL TODO Problem w. 3r- sequence
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("helicopter and");
		is($pron, 'h \'e . l i . k o p . t ex rh | ae n d');
		is($err, undef);
		
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("fish");
		is($pron, "f 'i rs");
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("car");
		is($pron, "k 'a: r0");
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("dog");
		is($pron, "d 'o g");
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("yule");
		is($pron, "j 'uw: l");
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("chip");
		is($pron, 'tc \'i p');
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("rock");
		is($pron, 'rh \'o k');
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("bird");
		is($pron, 'b \'oe: d'); # NB no /r0/
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("trunk");
		is($pron, 't rh \'a ng k');
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("boot");
		is($pron, 'b \'uw: t');
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("water");
		is($pron, 'w \'o: . t ex r0');
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("thing");
		is($pron, 'th \'i ng');
		is($err, undef);
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("they");
		is($pron, 'dh \'ei');
		is($err, undef);
		
		
		# NL TODO Is this a proper mapping? Z -> rs
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("pleasure");
		is($pron, 'p l \'e . rs ex r0');
		is($err, undef);
		
		
		($pron, $err) = MTM::Pronunciation::AutopronEspeak::run_espeak("");
		is($pron, '-');
		is(length($pron), 1);
		isnt($pron, undef);
		is($err, undef);
		isnt($err, '');
		isnt($err, '_');
		is($err, undef);
		
		# validate
		my $validated = MTM::Pronunciation::Validation::Base::validate( "d \'o g", "d \'o g", 'sv' );
		like( $validated, qr/VALID/, "validate dog" );

		$validated = MTM::Pronunciation::Validation::Base::validate( "d\"Kg", "d\"Kg", 'sv' );
		unlike( $validated, qr/VALID/, "validate dkg" );

	}
}
1;