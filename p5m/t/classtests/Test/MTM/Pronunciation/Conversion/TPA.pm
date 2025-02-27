package Test::MTM::Pronunciation::Conversion::TPA;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# TPA conversion (Swedish)
#
# Convert from TPA to base format
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
my %base2tpa = ();
my %tpa2base = ();

#**************************************************************#
# base2tpa - encode
use MTM::Pronunciation::Conversion::TPA;

my $converted = MTM::Pronunciation::Conversion::TPA->encode( 'p b t rt d rd k g f v s rs sh zh z dh th h x xx c tc dj m n rn ng r l rl j w rh r0 rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh uw: uw a: a aa: au eu ei ai oi ou eex iex uex an en on un' );
is( $converted, 'p b t rt d rd k g f v s rs rs rs3 z dh th h sj sj3 tj tj3 j3 m n rn ng r l rl j w r3 r0 r4 i2: i i3 y2: y e2: e e3 ë ä2: ä ä3: ä3 ö2: ö ö3: ö3 o2: o o3 å2: å u2: u u3 u4: u4 a2: a a3: au eu ei ai åi öw eë ië uë an en on un', 'base2tpa:all correct.' );

$converted = MTM::Pronunciation::Conversion::TPA->encode( "r 'a: . d ih u" );
is( $converted, "r 'a2: \$ d i3 o", 'base2tpa:radio correct.' );

$converted = MTM::Pronunciation::Conversion::TPA->encode( 'd "i: . dj ei - k ,an rl' );
is( $converted, 'd "i2: $ j3 ei - k `an rl', 'base2tpa:dj-kãrl correct.' );

#**************************************************************#
# tpa2base - decode
# Note that TPA uses the same symbol for /ʃ/ and /ʂ/, so /sh, rs/ -> /rs/
$converted = MTM::Pronunciation::Conversion::TPA->decode( 'p b t rt d rd k g f v s rs rs rs3 z dh th h sj sj3 tj tj3 j3 m n rn ng r l rl j w r3 r0 r4 i2: i i3 y2: y e2: e e3 ë ä2: ä ä3: ä3 ö2: ö ö3: ö3 o2: o o3 å2: å u2: u u3 u4: u4 a2: a a3: au eu ei ai åi öw eë ië uë an en on un' );
is( $converted, 'p b t rt d rd k g f v s rs rs zh z dh th h x xx c tc dj m n rn ng r l rl j w rh r0 rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh uw: uw a: a aa: au eu ei ai oi ou eex iex uex an en on un', 'tpa2base:all correct.' );

$converted = MTM::Pronunciation::Conversion::TPA->decode( "r 'a2: \$ d i3 o" );
is( $converted, "r 'a: . d ih u", 'tpa2base:radio correct.' );

$converted = MTM::Pronunciation::Conversion::TPA->decode( 'd "i2: $ j3 ei - k `an rl' );
is( $converted, 'd "i: . dj ei - k ,an rl', 'tpa2base:dj-kãrl correct.' );

#**************************************************************#
#done_testing;
