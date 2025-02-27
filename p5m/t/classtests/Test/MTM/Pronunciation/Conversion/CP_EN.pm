package Test::MTM::Pronunciation::Conversion::CP_EN;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# CP:EN conversion (Swedish)
#
# Convert from CP_EN to base format
#
# CT 2024
#**************************************************************#
# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings	qw< FATAL utf8 >;
use open	qw< :std :utf8 >;	 # Should perhaps be :encoding(utf-8)?
use charnames	qw< :full :short >;	# autoenables in v5.16 and above
use feature	qw< unicode_strings >;
no feature	qw< indirect >;
use feature	qw< signatures >;
no warnings	qw< experimental::signatures >;
#**************************************************************#
my %base2cp_en = ();
my %cp_en2base = ();

#**************************************************************#
# base2cp_en - encode
use MTM::Pronunciation::Conversion::CP_EN;

# Note that CP uses the same symbol for /ʃ/ and /ʂ/, so /sh, rs/ -> /rs/
my $converted = MTM::Pronunciation::Conversion::CP_EN->encode( 'p b t rt d rd k g f v s rs sh zh z dh th h x xx c tc dj m n rn ng r l rl j w rh r0 rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh a: a aa: au eu ei ai oi ou eex iex uex an en on un' );
is( $converted, 'p b t t d d k g f v s sh sh zh z dh th h sh sh sh ch jh m n n ng r l l y w r - r ii i i ii i - e e @ - e a a @@ - @@ - uu u u oo o aa uh aa au e w ei ai oi ou e@ i@ u@ aa ng e ng oo ng @@ ng', 'base2cp_en:all correct.' );

$converted = MTM::Pronunciation::Conversion::CP_EN->encode( "rh 'ei . d i . ou" );
is( $converted, "r ei1 \$ d i \$ ou", 'base2cp_en:radio correct.' );

$converted = MTM::Pronunciation::Conversion::CP_EN->encode( "d 'i: . dj ei ~ k ,an rl" );
is( $converted, "d ii1 \$ jh ei ~ k aa2 ng l", 'base2cp_en:dj-kãrl correct.' );

#**************************************************************#
# cp_en2base - decode
$converted = MTM::Pronunciation::Conversion::CP_EN->decode( 	'p b t d k g f v s zh z dh th h sh ch jh m n ng r l y w ii i e @ a @@ uu u oo o aa uh aa au e_w ei ai oi ou e@ i@ u@ aa ng e ng oo ng @@ ng' );
is( $converted, 						'p b t d k g f v s zh z dh th h rs tc dj m n ng rh l j w i: i e ex ae oe: uw: uw o: o a: a a: au eu ei ai oi ou eex iex uex a: ng e ng o: ng oe: ng', 'cp_en2base:all correct.' );

$converted = MTM::Pronunciation::Conversion::CP_EN->decode( "r ei1 \$ d i \$ ou" );
is( $converted, "rh 'ei . d i . ou", 'cp_en2base:radio correct.' );

$converted = MTM::Pronunciation::Conversion::CP_EN->decode( "d ii1 \$ jh ei ~ k aa2 ng l" );
is( $converted, "d 'i: . dj ei ~ k ,a: ng l", 'cp_en2base:dj-kãrl correct.' );

#**************************************************************#
#done_testing;
