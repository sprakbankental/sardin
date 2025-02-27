package MTM::Pronunciation;

use strict;
use warnings;

# Currently this is just a convenience package
# to load the various Pronunciation packages.
# They can still be loaded as separate modules
# instead, if that makes sense.
use MTM::Pronunciation::AcronymPronunciation;
use MTM::Pronunciation::Affixation;
use MTM::Pronunciation::Autopron;
use MTM::Pronunciation::AutopronEspeak;
use MTM::Pronunciation::AutopronVars;
use MTM::Pronunciation::Compound;
use MTM::Pronunciation::Conversion;
use MTM::Pronunciation::Decomposition;
use MTM::Pronunciation::Dictionary;
use MTM::Pronunciation::NumeralPronunciation;
use MTM::Pronunciation::Pronunciation;
use MTM::Pronunciation::PronunciabilityCheck;
use MTM::Pronunciation::Stress;
use MTM::Pronunciation::Swedify;
use MTM::Pronunciation::Syllabify;
use MTM::Pronunciation::InsertSyllableBoundaries;

use MTM::Expansion::NumeralExpansion;

use MTM::Legacy;
#use MTM::Case;
#use MTM::Legacy::Lists;
#use MTM::Vars;

1;

__END__

