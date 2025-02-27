package MTM::Validation::Vars::MTM;

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
our $valSecStress = ',';
our @valMainStress = ($valAccentI, $valAccentII);
our $valMainStress = join"|", @valMainStress;
our $valStress = "$valMainStress|$valSecStress";
our $valEngMainStress = "'";

# Phones
our @valSweVowels = qw( i: i y: y e: eh e ex ä: ä ae: ae ö: ö oe: oe a: aa: a uw: uw uu: uuh uu u: u oh o: o au eu an en on ou );
our @valEngVowels = qw( i: i e ex ae: ae oe: oe a: a uw: uw u: o: o au ei ai oi ou iex uex eex );
our @valConsos = qw( p b t d k g m n ng f v sh zh s z xx x c h l r rh r0 rx j w rt rd rs rn rl th dh dj tc );
our $schwa = 'ë';

our $valSweVowels = join"|", @valSweVowels;
our $valEngVowels = join"|", @valEngVowels;
our $valVowels = "$valSweVowels|$valEngVowels";
our $valConsos = join"|", @valConsos;
our $valPhones = "$valVowels|$valConsos";

# Delimiters
our $valDels = '[\.\~\-]';

our @irregularities = qw( pst sch grrr mmm pffft schh schhh ssch sssch shhh mm Hmm hm hmmm hm-ljud oooops iii-iv ising aaah aha ah bah ähh åhh åååh öh öhh ööhhhh ääh öööhhh oaaaaah ohh oooh ooooh fanimig );
our $irregularities = join"|", @irregularities;

1;
