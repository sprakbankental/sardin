package Test::MTM::Pronunciation::Conversion;

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

#use strict;
#use utf8;
#use warnings;
use Test::More;


my @msIPA_01 = qw( k a . t r iːˈ́ n );
my @msIPA_02 = qw( k a . Q t r iːˈ́ n );
my @msIPA_03 = qw( k o . Q t r iːˈ́ n );
my @msIPA_04 = qw( k a . t r iːˈ́ n u );

use MTM::Pronunciation::Conversion;

my @invalid_01 = MTM::Pronunciation::Conversion::invalidMSIPASymbols(@msIPA_01);
is(@invalid_01, 0, "invalidMSIPASymbols");

my @invalid_02 = MTM::Pronunciation::Conversion::invalidMSIPASymbols(@msIPA_02);
is(@invalid_02, 1);
is(shift @invalid_02, 'Q');

my @invalid_03 = MTM::Pronunciation::Conversion::invalidMSIPASymbols(@msIPA_03);
is(@invalid_03, 2);
is(shift @invalid_03, 'o');

my @invalid_04 = MTM::Pronunciation::Conversion::invalidMSIPASymbols(@msIPA_04);
is(@invalid_04, 1);
is(shift @invalid_04, 'u');

done_testing;
