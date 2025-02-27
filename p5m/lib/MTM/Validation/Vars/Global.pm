package MTM::Validation::Vars::Global;

use warnings;
use strict;

# Counters
our $nFormat = 0;
our $nCase = 0;
our $nMarkup = 0;
our $nMainStress = 0;
our $nSecStress = 0;
our $nPhone = 0;
our $nPhoneSweIniSanity = 0;
our $nPhoneSweFinSanity = 0;
our $nPhoneSweAcrSanity = 0,
our $nCheckedSwe = 0;
our $nCheckedEng = 0;
our $nCheckedSweAcr = 0;
our $nUncheckedWords = 0;
our $nCompound = 0;
our $nNonCompound = 0;

# Endings
our @sv_acronym_endings = qw( s t n );
our $sv_acronym_endings = join"|", @sv_acronym_endings;

1;