package Test::MTM::Tokenisation::SplitTokens;

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
   my ($inref, $expected) = @$pair;
   my ($in, $splittype) = @$inref;
   my @res = &MTM::Tokenisation::SplitTokens::splitTokens( $in, $splittype );
   is_deeply(\@res, $expected);
 }
}

#**************************************************#
# MODULE	MTM::TTSDocument::SplitSentence.pm
sub splitSentence : Tests(52) {
 diag "Testing splitSentence";
 subtest 'Blanks (sv)' => sub {
   my $pairs = [
     [
       [ 'En hund', 'normal' ],
       [ 'En', ' ', 'hund' ],
     ],
     [
       [ 'Ett † Två * Tre §#', 'normal' ],
       [ 'Ett', ' ', '†', ' ', 'Två', ' ', '*', ' ', 'Tre', ' ', '§', '#' ],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Blanks (en)' => sub {
   my $pairs = [
     [
       [ 'A dog', 'normal' ],
       [ 'A', ' ', 'dog' ],
     ],
     [
       [ 'One † Two * Three §#', 'normal' ],
       [ 'One', ' ', '†', ' ', 'Two', ' ', '*', ' ', 'Three', ' ', '§', '#'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Delimiters (sv)' => sub {
   my $pairs = [
     [
       [ 'En hund, en: katt?!', 'normal' ],
       ['En', ' ', 'hund', ',', ' ', 'en', ':', ' ', 'katt', '?', '!'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Delimiters (en)' => sub {
   my $pairs = [
     [
       [ 'A dog, a: cat?!', 'normal' ],
       ['A', ' ', 'dog', ',', ' ', 'a', ':', ' ', 'cat', '?', '!'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Brackets (sv)' => sub {
   my $pairs = [
     [
       [ 'En hund [en katt]', 'normal' ],
       ['En', ' ', 'hund', ' ', '[', 'en', ' ', 'katt', ']'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Brackets (en)' => sub {
   my $pairs = [
     [
       [ 'A dog [a cat]', 'normal' ],
       ['A', ' ', 'dog', ' ', '[', 'a', ' ', 'cat', ']'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Currency (sv)' => sub {
   my $pairs = [
     [
       [ '£15 och fem$.', 'normal' ],
       ['£', '15', ' ', 'och', ' ', 'fem', '$', '.'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Degrees (sv)' => sub {
   my $pairs = [
     [
       [ '18ºC.', 'normal' ],
       ['18', 'º', 'C', '.'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Math (sv)' => sub {
   my $pairs = [
     [
       [ '1+2-3*4/5%', 'normal' ],
       [ '1', '+', '2', '-', '3', '*', '4', '/', '5', '%' ],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Quotes (sv)' => sub {
   my $pairs = [
     [
       [ '\'1"2»hej«', 'normal' ],
       ["'", '1', '"', '2', '»', 'hej', '«'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Quotes (en)' => sub {
   my $pairs = [
     [
       [ '\'1"2»hey«', 'normal' ],
       ["'", '1', '"', '2', '»', 'hey', '«'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'HTML (sv)' => sub {
   my $pairs = [
     [
       [ 'Katt &amp; hund &gt; myra, men &lt; häst&quot;.', 'normal' ],
       ['Katt', ' ', '&amp;', ' ', 'hund', ' ', '&gt;', ' ', 'myra', ',', ' ', 'men', ' ', '&lt;', ' ', 'häst', '&quot;', '.'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'HTML (en)' => sub {
   my $pairs = [
     [
       [ 'Cat &amp; dog &gt; ant, but &lt; horse&quot;.', 'normal' ],
       ['Cat', ' ', '&amp;', ' ', 'dog', ' ', '&gt;', ' ', 'ant', ',', ' ', 'but', ' ', '&lt;', ' ', 'horse', '&quot;', '.'],
     ],
   ];
   _testlauncher$pairs;
 };
 subtest 'Intervals (sv)' => sub {
   my $pairs = [
     [
       [ '5-12-58-98', 'normal' ],
       ['5', '-', '12', '-', '58', '-', '98'],
     ],
     [
       [ 'måndag-tisdag ons.-fre. jan-maj', 'normal'  ],
       ['måndag', '-', 'tisdag', ' ', 'ons.', '-', 'fre.', ' ', 'jan', '-', 'maj'],
     ],
   ];
   _testlauncher$pairs;
 };
# CT 230420 This is only when land is en, to be tested in English settings.
#  subtest 'Intervals (en, TODO)' => sub {
#    local $TODO = 'This has yet to pass!';
#    my $pairs = [
#      [
#        [ 'Monday-Tuesday wed.-fri. jan-may', 'normal'  ],
#        ['Monday', '-', 'Tuesday', ' ', 'wed.', '-', 'fri.', ' ', 'jan', '-', 'may'],
#      ],
#    ];
#    _testlauncher$pairs;
#  };
 subtest 'Years (sv)' => sub {
   my $pairs = [
     [
       [ '1996 -2000', 'normal' ],
       ['1996', ' ', '-', '2000'],
     ],
     [
       [ '1996 -2000', 'normal' ],
       ['1996', ' ', '-', '2000'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'a-8 (sv)' => sub {
   my $pairs = [
     [
       [ '7 a-8 c', 'normal' ],
       ['7', ' ', 'a', '-', '8', ' ', 'c'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Subscript (sv)' => sub {
   my $pairs = [
     [
       [ '7ₓ och V₅₊', 'normal' ],
       ['7', 'ₓ', ' ', 'och', ' ', 'V', '₅₊'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Subscript (en)' => sub {
   my $pairs = [
     [
       [ '7ₓ and V₅₊', 'normal' ],
       ['7', 'ₓ', ' ', 'and', ' ', 'V', '₅₊'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Superscript (sv)' => sub {
   my $pairs = [
     [
       [ '7ͮ och V⁸', 'normal' ],
       ['7', 'ͮ', ' ', 'och', ' ', 'V', '⁸'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Superscript (en)' => sub {
   my $pairs = [
     [
       [ '7ͮ and V⁸', 'normal' ],
       ['7', 'ͮ', ' ', 'and', ' ', 'V', '⁸'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Letter_digit (sv)' => sub {
   my $pairs = [
     [
       [ 'hej10', 'normal' ],
       ['hej', '10'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Letter_digit (en)' => sub {
   my $pairs = [
     [
       [ 'hey10', 'normal' ],
       ['hey', '10'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Digit_letter (sv)' => sub {
   my $pairs = [
     [
       [ '10hej', 'normal' ],
       ['10', 'hej'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Digit_letter (en)' => sub {
   my $pairs = [
     [
       [ '10hey', 'normal' ],
       ['10', 'hey'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Hyphen (sv)' => sub {
   my $pairs = [
     [
       [ '50-årsdag NLB-ansatt', 'normal' ],
       [ '50-årsdag', ' ', 'NLB-ansatt' ],
     ],
     [
       [ 'Olav, Gunhild, Marius osv. ska bli glada.', 'normal' ],
       [ 'Olav', ',', ' ', 'Gunhild', ',', ' ', 'Marius', ' ', 'osv.', ' ', 'ska', ' ', 'bli', ' ', 'glada', '.' ],
     ],
     [
       [ '20:-', 'normal' ],
       [ '20', ':-' ],
     ],
   ];
   _testlauncher$pairs;
 };
 subtest 'Hyphen (en)' => sub {
   my $pairs = [
     [
       [ '50-year NLB-ansatt', 'normal' ],
       ['50-year', ' ', 'NLB-ansatt'],
     ],
     [
       [ '20:-', 'normal' ],
       ['20', ':-'],
     ],
   ];
   _testlauncher$pairs;
 };
# CT 230420 This is only when land is en, to be tested in English settings.
#  subtest 'Hyphen (en, TODO)' => sub {
#    local $TODO = 'This has yet to pass!';
#    my $pairs = [
#      [
#        [ 'Olav, Gunhild, Marius aso. are happy.', 'normal' ],
#        ['Olav', ',', ' ', 'Gunhild', ',', ' ', 'Marius', ' ', 'aso.', ' ', 'are', ' ', 'happy', '.'],
#      ],
#    ];
#    _testlauncher$pairs;
#  };

 subtest 'Quote_compound (sv)' => sub {
   my $pairs = [
     [
       [ '«Full City»-kaptenen', 'normal' ],
       ['«', 'Full', ' ', 'City»-kaptenen'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Single_quote (sv)' => sub {
   my $pairs = [
     [
       [ "Kauami's couldn't", 'normal' ],
       [ "Kauami's", ' ', "couldn't" ],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Thousands (sv)' => sub {
   my $pairs = [
     [
       [ '2.000 och 200.000.000', 'normal' ],
       [ '2.000', ' ', 'och', ' ', '200.000.000' ],
     ],
     [
       [ '20 000 och 200 000 000', 'normal' ],
       [ '20 000', ' ', 'och', ' ', '200 000 000' ],
     ],
   ];
   _testlauncher$pairs;
 };
 subtest 'Thousands (en)' => sub {
   my $pairs = [
     [
       [ '2.000 and 200.000.000', 'normal' ],
       [ '2.000', ' ', 'and', ' ', '200.000.000' ],
     ],
     [
       [ '20 000 and 200 000 000', 'normal' ],
       [ '20 000', ' ', 'and', ' ', '200 000 000' ],
     ],
   ];
   _testlauncher$pairs;
 };
# CT 230420 This is only when land is en, to be tested in English settings.
#  subtest 'Thousands (en) TODO' => sub {
#    local $TODO = 'This has yet to pass!';
#    my $pairs = [
#      [
#        [ '2,000 and 200,000,000', 'normal' ],
#        [ '2,000', ' ', 'and', ' ', '200,000,000' ],
#      ],
#    ];
#    _testlauncher$pairs;
#
#  };
 subtest 'H&M (sv)' => sub {
   my $pairs = [
     [
       [ 'H&M', 'normal' ],
       ['H&M'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'ACR + ending (sv)' => sub {
   my $pairs = [
     [
       [ 'PFG:erna QW:s', 'normal' ],
       ['PFG:erna', ' ', 'QW:s'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'ACR + ending (en)' => sub {
   my $pairs = [
     [
       [ 'PFG\'s QWs', 'normal' ],
       ['PFG\'s', ' ', 'QWs'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest '416 18 477 (sv)' => sub {
   my $pairs = [
     [
       [ '416 18 477', 'normal' ],
       ['416', ' ', '18', ' ', '477'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'kapitel 416 18 477 (sv)' => sub {
   my $pairs = [
     [
       [ 'kapitel 416 18 477', 'normal' ],
       ['kapitel', ' ', '416', ' ', '18', ' ', '477'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'chapter 416 18 477 (en)' => sub {
   my $pairs = [
     [
       [ 'chapter 416 18 477', 'normal' ],
       ['chapter', ' ', '416', ' ', '18', ' ', '477'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Year + number (sv)' => sub {
   my $pairs = [
     [
       [ 'I slutet av 2009 450 anställda.', 'normal' ],
       ['I', ' ', 'slutet', ' ', 'av', ' ', '2009', ' ', '450', ' ', 'anställda', '.'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'year + number (en)' => sub {
   my $pairs = [
     [
       [ 'In the end of 2009 450 employees.', 'normal' ],
       ['In', ' ', 'the', ' ', 'end', ' ', 'of', ' ', '2009', ' ', '450', ' ', 'employees', '.'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'File extensions (sv)' => sub {
   my $pairs = [
     [
       [ 'fil.mp3', 'normal'  ],
       ['fil', '.', 'mp3'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest '§§ (sv)' => sub {
   my $pairs = [
     [
       [ '3-7§§', 'normal'  ],
       ['3', '-', '7', '§§'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Single quote (sv)' => sub {
   my $pairs = [
     [
       [ 'abc\'def', 'normal'  ],
       ['abc\'def'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Single_quote (en)' => sub {
   my $pairs = [
     [
       [ 'Kauami\'s couldn\'t', 'normal' ],
       ['Kauami\'s', ' ', 'couldn\'t'],
     ],
     [
       [ 'abc\'def', 'normal'  ],
       ['abc\'def'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Quote_compound (en)' => sub {
   my $pairs = [
     [
       [ '«Full City»-captain', 'normal' ],
       ['«', 'Full', ' ', 'City»-captain'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Word_ending (sv)' => sub {
   my $pairs = [
     [
       [ '3:orna', 'normal'  ],
       ['3:orna'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Word_ending (en)' => sub {
   my $pairs = [
     [
       [ '3\'s', 'normal'  ],
       ['3\'s'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Fractions (sv)' => sub {
   my $pairs = [
     [
       [ '1/2', 'normal'  ],
       ['1', '/', '2'],
     ],
     [
       [ '1/2 liter', 'normal'  ],
       ['1/2', ' ', 'liter'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'torsk-torsk (sv)' => sub {
   my $pairs = [
     [
       [ 'torsk-torsk', 'normal' ],
       ['torsk-torsk'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'monk-monk (en)' => sub {
   my $pairs = [
     [
       [ 'monk-monk', 'normal' ],
       ['monk-monk'],
     ],
   ];
   _testlauncher$pairs;

 };
 subtest 'Currency (en)' => sub {
   my $pairs = [
     [
       [ '£15 and five$.', 'normal' ],
       ['£', '15', ' ', 'and', ' ', 'five', '$', '.'],
     ],
   ];
   _testlauncher$pairs;

 };
}
1;
#***********************************************************************#
