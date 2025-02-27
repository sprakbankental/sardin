package Test::MTM::Pronunciation::Conversion::ACA;

use Test::More;
use Test::Class;
use Data::Dumper;

#**************************************************************#
# ACA conversion (Swedish)
#
# Convert from ACA to base format
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
# base2aca - encode
use MTM::Pronunciation::Conversion::ACA;

# The final stressed /"a:/ is added not to trigger validation error (missing main stress).
my $converted = MTM::Pronunciation::Conversion::ACA->encode( 'p b t rt d rd k g f v s rs sh zh z dh th h x xx c tc dj m n rn ng r l rl j w rh r0 rx i: i ih y: y e: e eh ex ä: ä ae: ae ö: ö oe: oe u: u oh o: o uu: uu uuh uw: uw a: a aa: au eu ei ai oi ou eex iex uex an en on un "a:' );
is( $converted, 'p b t rt d rd k g f v s rs rs S z D T h S x C tS dZ m n rn N r l rl j w r r r i: I I y: Y e: e e @ E: E {: { 2: 2 9: 9 u: U U o: O }: u u u: U A: a a a U E U E j a j O j 2 U {: I @ U @ a~ e~ o~ 9~ A:3', 'base2aca:all correct.' );

$converted = MTM::Pronunciation::Conversion::ACA->encode( "r 'a: . d ih u" );
is( $converted, "r A:4 d I U", 'base2aca:radio correct.' );

$converted = MTM::Pronunciation::Conversion::ACA->encode( 'd "i: . dj ei - k ,an rl' );
is( $converted, 'd i:3 dZ E j k_h a~1 rl', 'base2aca:dj-kãrl correct.' );

$converted = MTM::Pronunciation::Conversion::ACA->encode( "dh 'ou" );
is( $converted, 'D 24 U', 'base2aca:though correct.' );

# ACA specific: aspirated stops
$converted = MTM::Pronunciation::Conversion::ACA->encode( 'k "a: k ,a' );
is( $converted, 'k_h A:3 k a', 'base2aca:kaka correct.' );

$converted = MTM::Pronunciation::Conversion::ACA->encode( 's p "a t ,a t' );
is( $converted, 's p a3 t a t', 'base2aca:spattat correct.' );

# ACA specific: Karlsson
$converted = MTM::Pronunciation::Conversion::ACA->encode( "k \'a: rl . s o n" );
is( $converted, 'k_h A:4 l s O n', 'base2aca:karlsson correct.' );

#**************************************************************#
# Secondary stress
# Simplex word
$converted = MTM::Pronunciation::Conversion::ACA->encode( 'i n . k "a . s u k r ,a: v' );
is( $converted, 'I n k_h a3 s U k r A: v', 'base2aca:simplex inkassokrav correct.' );

# Compound
$converted = MTM::Pronunciation::Conversion::ACA->encode( 'i n . k "a . s u - k r ,a: v' );
is( $converted, 'I n k_h a3 s U k_h r A:1 v', 'base2aca:compound inkassokrav correct.' );

#**************************************************************#
# aca2base - decode
# No need for decoding ACA.

#**************************************************************#
#done_testing;
