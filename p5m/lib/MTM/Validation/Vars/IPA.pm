package MTM::Validation::Vars::IPA;

use warnings;
use strict;
use utf8;

# Case and markup
my @validCase = qw(0 1);
my @validMarkup = qw(- ACR ABBR HOM URL MIX PM ENG FRE NOB GER SPA ICE);
our $validCase = join"|", @validCase;
our $validMarkup = join"|", @validMarkup;

# Stress
our $valAccentI = "'";
our $valAccentII = '"';
our $valSecStress = '`';
our @valMainStress = ($valAccentI, $valAccentII);
our $valMainStress = join"|", @valMainStress;
our $valStress = "$valMainStress|$valSecStress";
our $valEngMainStress = "'";

#p|b|t|ʈ|d|ɖ|k|g|f|v|s|ʂ|ʂ|s|d|t|h|ɧ|ɧ|ç|ɕ|tʂ|d j|dʂ|m|n|ɳ|ŋ|r|l|ɭ|j|v|r|r|r|
#iː|ɪ|j|ɪ|yː|ʏ|y|eː|ɛ|e|ə|ɛː|ɛ|æː|æ|øː|ø|œ|œː|œ|ɶ|uː|u|ʊ|ʊ|oː|ɔ|ʉː|ɵ|ʉ|ɵ|ʊː|uː|ʊ|ɒː|ɑː|a|ɒː|ɑː|a‿u|ɛ u|ɛ ʊ|ej|aj|o j|ɔj|o u|ɶ ʊ|e ə|ɪ ə|u ə|ʊ ə|ɒː n|ɑː n|ɛː n|oː n|œː n|

# Phones
our @valSweVowels = qw( a e eː iː n o oː u uː y yː æ æː ø øː œ œː ɑː ɒː ɔ ə ɛ ɛː ɪ ɵ ɶ ʉ ʉː ʊ ʊː ʏ );
our @valEngVowels = qw( a e eː iː n o oː u uː y yː æ æː ø øː œ œː ɑː ɒː ɔ ə ɛ ɛː ɪ ɵ ɶ ʉ ʉː ʊ ʊː ʏ );
our @valConsos = qw( b d f g h j k l m n p r s t v ç ŋ ɕ ɖ ɧ ɭ ɳ ʂ ʈ );
our $schwa = 'ə';

our $valSweVowels = join"|", @valSweVowels;
our $valEngVowels = join"|", @valEngVowels;
our $valVowels = "$valSweVowels|$valEngVowels";
our $valConsos = join"|", @valConsos;
our $valPhones = "$valVowels|$valConsos";

# Delimiters
our $valDels = '.';

our @irregularities = qw( pst sch grrr mmm pffft schh schhh ssch sssch shhh mm Hmm hm hmmm hm-ljud oooops iii-iv ising aaah aha ah bah ähh åhh åååh öh öhh ööhhhh ääh öööhhh oaaaaah ohh oooh ooooh fanimig );
our $irregularities = join"|", @irregularities;

1;
