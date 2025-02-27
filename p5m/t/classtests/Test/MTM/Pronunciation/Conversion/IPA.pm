package Test::MTM::Pronunciation::Conversion::IPA;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# IPA conversion (Swedish)
#
# Convert from IPA to base format
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
# base2ipa - encode
use MTM::Pronunciation::Conversion::IPA;

my $converted = MTM::Pronunciation::Conversion::IPA->encode( 'p b t rt d rd k g f v s rs sh zh z dh th h x xx c tc dj m n rn ng r r0 l rl j w rh rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh uw: uw a: a aa: au eu ei ai oi ou eex iex uex an en on un' );
is( $converted, "pbtʈdɖkɡfvsʂʃʒzðθhɧxçt͡ʃd͡ʒmnɳŋrlɭjwɾʀiːɪɪ̯yːʏeːee̝əɛːɛæːæøːøœːœuːuooːɔʉːɵʉʊːʊɑːaaːaʊɛʊeɪaɪɔɪəʊeəɪəʊəãɛ̃õœ̃", 'base2ipa:all correct.' );

$converted = MTM::Pronunciation::Conversion::IPA->encode( "r 'a: . d ih u" );
is( $converted, "rˈ́ɑː.dɪ̯u", 'base2ipa:radio correct.' );

$converted = MTM::Pronunciation::Conversion::IPA->encode( 'd "i: . dj ei - k ,an rl' );
is( $converted, 'dˈ̀iː.d͡ʒeɪ.kˌãɭ', 'cbase2ipa:dj-kãrl correct.' );

#**************************************************************#
# ipa2base - decode
$converted = MTM::Pronunciation::Conversion::IPA->decode( "pbtʈdɖkɡfvsʂʃʒzðθhɧxçt͡ʃd͡ʒmnɳŋrlɭjwɾʀiːɪɪ̯yːʏeːee̝əɛːɛæːæøːøœːœuːuooːɔʉːɵʉʊːʊɑːaaːaʊɛʊeɪaɪɔɪəʊeəɪəʊəãɛ̃õœ̃" );
is( $converted, "p b t rt d rd k g f v s rs sh zh z dh th h x xx c tc dj m n rn ng r l rl j w rh rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh uw: uw a: a aa: au eu ei ai oi ou eex iex uex an en on un", 'ipa2base:all correct.' );

$converted = MTM::Pronunciation::Conversion::IPA->decode( "rˈ́ɑː.dɪ̯u" );
is( $converted, "r 'a: . d ih u", 'ipa2base:radio correct.' );

$converted = MTM::Pronunciation::Conversion::IPA->decode( 'dˈ̀iː.d͡ʒeɪ.kˌãɭ' );
is( $converted, 'd "i: . dj ei . k ,an rl', 'ipa2base:dj-kãrl correct.' );

#**************************************************************#
#done_testing;
