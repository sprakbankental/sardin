package Test::MTM::Pronunciation::Conversion::CP;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# CP conversion (Swedish)
#
# Convert from CP to base format
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
my %base2cp = ();
my %cp2base = ();

#**************************************************************#
# base2cp - encode
use MTM::Pronunciation::Conversion::CP;

# Note that CP uses the same symbol for /ʃ/ and /ʂ/, so /sh, rs/ -> /rs/
my $converted = MTM::Pronunciation::Conversion::CP->encode( 	'p b t rt d rd k g f v s rs sh zh z dh th h x xx c tc dj m n rn ng r l rl j w rh r0 rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh uw: uw a: a aa: au eu ei ai oi ou eex iex uex an en on un' );
is( $converted, 						'p b t rt d rd k g f v s rs rs rs z dh th h x x c ch jh m n rn ng r l rl j w rh rh rrh ii i i yy y ee e e eh eex: e aae ae oox ox ooe oe uu u u oo o uux ux ux uu u aa a aah au eu e j a j o j ou eeh ieh ueh an in on un', 'base2cp:all correct.' );

$converted = MTM::Pronunciation::Conversion::CP->encode( "r 'a: . d ih u" );
is( $converted, "r aa4 \$ d i u", 'base2cp:radio correct.' );

$converted = MTM::Pronunciation::Conversion::CP->encode( 'd "i: . dj ei - k ,an rl' );
is( $converted, 'd ii3 $ jh e j - k an2 rl', 'base2cp:dj-kãrl correct.' );

#**************************************************************#
# cp2base - decode
$converted = MTM::Pronunciation::Conversion::CP->decode( 'p b t rt d rd k g f v s rs z dh th h x c ch jh m n rn ng r l rl j w rh rrh ii i yy y ee e eh eex: aae ae oox ox ooe oe uu u oo o uux ux aa a aah au eu ou eeh ieh ueh an in on un' );
is( $converted, 'p b t rt d rd k g f v s rs z dh th h x c tc dj m n rn ng r l rl j w rh rx i: i y: y e: e ex ä: ae: ae ö: ö oe: oe u: u o: o uu: uu a: a aa: au eu ou eex iex uex an en on un', 'cp2base:all correct.' );

$converted = MTM::Pronunciation::Conversion::CP->decode( "r aa4 \$ d i0 u0" );
is( $converted, "r 'a: . d i u", 'cp2base:radio correct.' );

$converted = MTM::Pronunciation::Conversion::CP->decode( 'd ii3 $ jh e j - k an2 rl' );
is( $converted, 'd "i: . dj e j - k ,an rl', 'cp2base:dj-kãrl correct.' );

$converted = MTM::Pronunciation::Conversion::CP->decode( "d \"uu \. b ex l - v ,e: \| s \"ä: \. t ,a \| t \'e:" );
is( $converted, ' d ux3 b eh l v ee2 s eex3 t a2 t ee4', 'cp2base:WZT correct.' );

#**************************************************************#
#done_testing;
