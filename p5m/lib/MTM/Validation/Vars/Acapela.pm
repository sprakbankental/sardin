package MTM::Validation::Vars::Acapela;

use warnings;
use strict;
use utf8;

# Case and markup
my @validCase = qw(0 1);
my @validMarkup = qw(- ACR ABBR HOM URL MIX PM ENG FRE NOB GER);
our $validCase = join"|", @validCase;
our $validMarkup = join"|", @validMarkup;

# Stress
our $valAccentI = '4';
our $valAccentII = '3';
our $valSecStress = '1';
our @valMainStress = ($valAccentI, $valAccentII);
our $valMainStress = join"|", @valMainStress;
our $valStress = "$valMainStress|$valSecStress";

# Phones
our @valVowels = qw( i: I y: Y e: e E: E @ {: { 2: 2 9: 9 A: aa a }: u u: U o: O o~ e~ a~);
our @valConsos = qw( p_h p b t_h t d k_h k g m n N f v s z S C x h l r j w rt rt_h rd rs rn rl T D tS dZ);
our $schwa = '@';

our $valVowels = join"|", @valVowels;
our $valConsos = join"|", @valConsos;
our $valPhones = "$valVowels|$valConsos";

our @irregularities = qw( pst sch grrr mmm pffft schh schhh ssch sssch shhh mm Hmm hm hmmm hm-ljud oooops iii-iv ising aaah aha ah bah ähh åhh åååh öh öhh ööhhhh ääh öööhhh oaaaaah ohh oooh ooooh fanimig );
our $irregularities = join"|", @irregularities;

1;
