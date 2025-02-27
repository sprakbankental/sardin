package MTM::Validation::Vars::TPA;

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

# Phones
our @valSweVowels = qw( i2: i i3 y2: y e2: e3 e ë ä2: ä ä3: ä3 ö2: ö ö3: ö3 a2: a3: a u4: u2: u u3 o2: o o3 å2: å au eu an en on öw );
our @valEngVowels = qw( i2: i i3 e ë ä3: ä3 ö3: ö3 a2: a u4: u4 o2: å2: å au ei ai åi öw ië uë eë );
our @valConsos = qw( p b t d k g m n ng f v s z sj tj sj3 h l r r3 r0 j w rt rd rs rn rl th dh j3 tj3 dj3 rs3 );
our $schwa = 'ë';

our $valSweVowels = join"|", @valSweVowels;
our $valEngVowels = join"|", @valEngVowels;
our $valVowels = "$valSweVowels|$valEngVowels";
our $valConsos = join"|", @valConsos;
our $valPhones = "$valVowels|$valConsos";

# Delimiters
our $valDels = '[\$\~\-]';

our @irregularities = qw( pst sch grrr mmm pffft schh schhh ssch sssch shhh mm Hmm hm hmmm hm-ljud oooops iii-iv ising aaah aha ah bah ähh åhh åååh öh öhh ööhhhh ääh öööhhh oaaaaah ohh oooh ooooh fanimig );
our $irregularities = join"|", @irregularities;

1;
