package MTM::Validation::Vars::Cereproc;

use warnings;
use strict;
use utf8;

# Case and markup
our @validCase = qw(0 1);
our @validMarkup = qw(- ACR ABBR HOM URL MIX PM ENG FRE NOB GER SPA ICE);
our $validCase = join"|", @validCase;
our $validMarkup = join"|", @validMarkup;

# Stress
our $valAccentI = "4";
our $valAccentII = '3';
our $valSecStress = '2';
our $valUnstress = '0';
our @valMainStress = ($valAccentI, $valAccentII);
our $valMainStress = join"|", @valMainStress;
our $valStress = "$valMainStress|$valSecStress|$valUnstress";
our $valEngMainStress = "'";

# Phones
our @valSweVowels = qw( ii i yy y ee e eex uux ux oox ox uu u oo o aa a aae ae ooe oe eu au an in on un aah );
our @valEngVowels = qw( ii i e oo o aa aae ae ou ie eeh euh oex uw );
our @valVowels = qw( ii i yy y ee e eex uux ux oox ox uu u oo o aa a aae ae ooe oe eu au an in on un aah ie euh oex uw );

our @valSweConsos = qw( p b t rt d rd k g f v s rs h m n rn ng r l rl j ch dh th jh w rh z c x xx rrh );
our @valEngConsos = qw( p b t d k g f v s h m n ng r l j ch dh th jh w rh z );
our @valConsos = qw( p b t rt d rd k g f v s rs h m n rn ng r l rl j ch dh th jh w rh z c x xx rrh );
our $schwa = 'eh';

our $valSweVowels = join"|", @valSweVowels;
our $valEngVowels = join"|", @valEngVowels;
our $valVowels = "$valSweVowels|$valEngVowels";
our $valConsos = join"|", @valConsos;
our $valPhones = "$valVowels|$valConsos|$schwa";

# Delimiters
#our $valDels = '[\$\~\-]';

our @irregularities = qw(  );
our $irregularities = join"|", @irregularities;

1;
