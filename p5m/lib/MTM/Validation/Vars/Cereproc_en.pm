package MTM::Validation::Vars::Cereproc_en;

use warnings;
use strict;
use utf8;

# Case and markup
my @validCase = qw(0 1);
my @validMarkup = qw(- ACR ABBR HOM URL MIX PM ENG FRE NOB GER SPA ICE);
our $validCase = join"|", @validCase;
our $validMarkup = join"|", @validMarkup;

# Stress
our $valAccentI = '1';
our $valMainStress = '1';
our $valSecStress = '2';
our $valUnstress = '0';
our @valEngMainStress = ($valAccentI);
our $valEngMainStress = join"|", @valEngMainStress;
our $valStress = "$valEngMainStress|$valSecStress|$valUnstress";

# Phones
our @tmpValVowels = qw( ë ëë a aa ai au e eë ei i ië ii o oi oo ou u uë uh uu );
our @valVowels = qw( @ @@ a aa ai au e e@ ei i i@ ii o oi oo ou u u@ uh uu );

our @valConsos = qw( b ch d dh f g h jh k l m n ng p r s sh t th v w y z zh R );
our $schwa = '@';

our $valVowels = join"|", @valVowels;

our $tmpValVowels = join"|", @tmpValVowels;


our $valConsos = join"|", @valConsos;
our $valPhones = "$valVowels|$valConsos|$schwa";

our $tmpValPhones = "$tmpValVowels|$valConsos|$schwa";

# Delimiters
#our $valDels = '[\$\~\-]';

our @irregularities = qw(  );
our $irregularities = join"|", @irregularities;

1;
