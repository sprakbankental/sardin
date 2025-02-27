package Test::MTM::Validation::Pronunciation;

#**************************************************************#
# pronunciation_validation.pm
#
# 
# NB!	Examples or help texts for cereproc mode only.
#
#**************************************************************#
use strict;
use Test::More;

use utf8;

use MTM::Validation::Pronunciation;

my $pronWarnings;
my @pronWarnings;
my $sanityWarnings;
my @sanityWarnings;
my $example;
my @example;
my $help;
my @help;


#**************************************************#
# MTM
# Main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'hej', 'h e j', 'swe', 'mtm', 1, 'NN', 'hej', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Huvudbetoning saknas:	/h e j/', 'mtm pw0: no stress (h e j): correct.' );
is( $pronWarnings[1], "VARNING	Det finns ingen huvudbetoning (\') och det finns endast en vokal i ordet:	/h e j/", 'mtm pw1: no main stress 2 (h e j): correct.' );
is( $help[0], "HJÄLP	En huvudbetoning måste finnas (\'\|\").", 'mtm help: no main stress 2 (h e j): correct.' );
is( $help[1], "HJÄLP	Om det bara finns en vokal i ordet måste den ha accent I (\').", 'mtm help: no main stress 2 (h e j): correct.' );
is( $example[0], "EXEMPEL	Accent I: sak	\/s \'a2: k\/", 'mtm ex: no main stress 2 (h e j): correct.' );
is( $sanityWarnings[0], undef, 'mtm sw0: (h e j): correct.' );

# Missing secondary stress in compound
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', "s \"a m a n - s e t n i ng", 'swe', 'mtm', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], "VARNING	Bibetoning saknas:	/s \"a m a n s e t n i ng/", 'mtm pw0: no stress (sammansättning): correct.' );
is( $pronWarnings[1], undef, 'mtm pw1:correct.' );
is( $help[0], 'HJÄLP	En sammansättning måste ha sammansättningsbetoning med accent II (") och bibetoning (,).', 'mtm h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], undef, 'mtm h1: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'mtm sw0: (sammansättning): correct.' );
is( $example[0], undef, 'mtm ex0: (sammansättning): correct.' );

# Secondary stress before main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', 's ,a m a n - s "e t n i ng', 'swe', 'mtm', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Bibetoning saknas:	/s ,a m a n s "e t n i ng/', 'mtm pw0: sec stress (sammansättning): correct.' );
is( $pronWarnings[1], 'VARNING	Otillåten bibetoning	/s ,a m a n s "e t n i ng/', 'mtm pw1: sec stress (sammansättning): correct.' );
is( $pronWarnings[2], undef, 'mtm pw1:correct.' );
is( $help[0], 'HJÄLP	En sammansättning måste ha sammansättningsbetoning med accent II (") och bibetoning (,).', 'cp h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], 'HJÄLP	Bibetoning (,) får ej förekomma före huvudbetoning (")	/s ,a m a n s "e t n i ng/', 'mtm h1: (sammansättning): correct.' );
is( $help[2], undef, 'mtm h2: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'mtm sw0: (sammansättning): correct.' );
is( $example[0], undef, 'mtm ex0: (sammansättning): correct.' );

# Sanity check
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'ack', "k \'a:", 'swe', 'mtm', 1, 'NN', 'ajeh', 1 );
@sanityWarnings = @$sanityWarnings;
is( $sanityWarnings[0], "Initialt a matchar inte	ack k \'a: ", 'mtm sw0: (ack): correct.' );
is( $sanityWarnings[1], "Finalt k matchar inte	ack k \'a: ", 'mtm sw1: (ack): correct.' );
#**************************************************#
# Cereproc Swedish
# Main stress + invalid phone
#( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'hej', 'h e jj', 'swe', 'cereproc', 1, 'NN', 'hej', 1 );
#@pronWarnings = @$pronWarnings;
#@sanityWarnings = @$sanityWarnings;
#@help = @$help;
#@example = @$example;
#
#is( $pronWarnings[0], 'FELMEDDELANDE	Alla vokaler måste ha betoning:	/e/', 'cp pw0: no stress (h e jj): correct.' );
#is( $pronWarnings[1], 'FELMEDDELANDE	Ogiltigt fonem:	/jj/', 'cp pw1: invalid phone (h e jj): correct.' );
#is( $pronWarnings[2], 'VARNING	Huvudbetoning saknas:	/h e jj/', 'cp pw2 no main stress (h e jj): correct.' );
#is( $pronWarnings[3], 'VARNING	Det finns ingen huvudbetoning (4) och det finns endast en vokal i ordet:	/h e jj/', 'cp pw: no main stress 2 (h e j): correct.' );
#is( $help[0], 'HJÄLP	Obetonade vokaler ska åtföljas av 0.', 'cp help: no main stress 2 (h e jj): correct.' );
#is( $help[1], 'HJÄLP	Giltiga fonem och avskiljare: ii|i|yy|y|ee|e|eex|uux|ux|oox|ox|uu|u|oo|o|aa|a|aae|ae|ooe|oe|eu|au|an|in|on|un|aah|ii|i|e|oo|o|aa|aae|ae|ou|ie|eeh|euh|oex|uw|p|b|t|rt|d|rd|k|g|f|v|s|rs|h|m|n|rn|ng|r|l|rl|j|ch|dh|th|jh|w|rh|z|c|x|xx|rrh|eh', 'cp help: invalid phone (h e jj): correct.' );
#is( $help[2], 'HJÄLP	En huvudbetoning måste finnas (4|3).', 'cp help: no main stress 2 (h e jj): correct.' );
#is( $help[3], 'HJÄLP	Om det bara finns en vokal i ordet måste den ha accent I (4).', 'cp help: no main stress 2 (h e jj): correct.' );
#is( $example[0], 'EXEMPEL	Accent I: saker	/s aa4 k eh0 r/	Huvudbetoning accent II: sakletare	/s aa3 k l ee2 t a0 r eh0/', 'cp ex: no main stress 2 (h e j): correct.' );
#is( $example[1], 'EXEMPEL	Accent I: sak	/s aa4 k/', 'cp: ex no main stress 2 (h e jj): correct.' );
#is( $example[2], undef, 'cp ex: (h e jj): correct.' );
#is( $sanityWarnings[0], 'Initialt h matchar inte	hej h e jj ', 'cp sw0: (h e j): correct.' );
#is( $sanityWarnings[1], 'Finalt j matchar inte	hej h e jj ', 'cp sw1: (h e j): correct.' );
#is( $sanityWarnings[2], undef, 'cp sw2: (h e j): correct.' );

# Missing secondary stress in compound
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', 's a3 m a0 n $ s e0 t n i0 ng', 'swe', 'cereproc', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Bibetoning saknas:	/s a3 m a0 n s e0 t n i0 ng/', 'cp pw0: no stress (sammansättning): correct.' );
is( $pronWarnings[1], undef, 'cp pw1:correct.' );
is( $help[0], 'HJÄLP	En sammansättning måste ha sammansättningsbetoning med accent II (3) och bibetoning (2).', 'cp h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], undef, 'cp h1: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'cp sw0: (sammansättningcp sw0): correct.' );
is( $example[0], undef, 'cp ex0: (sammansättning): correct.' );

# Secondary stress before main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', 's a2 m a0 n - s e3 t n i0 ng', 'swe', 'cereproc', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Bibetoning saknas:	/s a2 m a0 n s e3 t n i0 ng/', 'cp pw0: sec stress (sammansättning): correct.' );
is( $pronWarnings[1], 'VARNING	Otillåten bibetoning	/s a2 m a0 n s e3 t n i0 ng/', 'cp pw1: sec stress (sammansättning): correct.' );
is( $pronWarnings[2], undef, 'cp pw1:correct.' );
is( $help[0], 'HJÄLP	En sammansättning måste ha sammansättningsbetoning med accent II (3) och bibetoning (2).', 'cp h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], 'HJÄLP	Bibetoning (2) får ej förekomma före huvudbetoning (3)	/s a2 m a0 n s e3 t n i0 ng/', 'cp h1: (sammansättning): correct.' );
is( $help[2], undef, 'cp h2: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'cp sw0: (sammansättning): correct.' );
is( $example[0], undef, 'cp ex0: (sammansättning): correct.' );

# Sanity check
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'ack', 'k aa4', 'swe', 'cereproc', 1, 'NN', 'ajeh', 1 );
@sanityWarnings = @$sanityWarnings;
is( $sanityWarnings[0], 'Initialt a matchar inte	ack k aa4 ', 'cp sw0: (ack): correct.' );
is( $sanityWarnings[1], 'Finalt k matchar inte	ack k aa4 ', 'cp sw1: (ack): correct.' );
#**************************************************#
# cereproc_en English
# Main stress + invalid phone
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'hej', 'h e j', 'eng', 'cereproc_en', 1, 'NN', 'hej', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'FELMEDDELANDE	Alla vokaler måste ha betoning:	/e/', 'cp pw1: no stress (h e j): correct.' );
is( $pronWarnings[1], 'FELMEDDELANDE	Ogiltigt engelskt fonem: /j/', 'cp pw0: no stress (h e j): correct.' );
is( $pronWarnings[2], 'VARNING	Huvudbetoning saknas	/h e j/', 'cp pw0: no main stress (h e j): correct.' );
is( $help[0], 'HJÄLP	Obetonade vokaler ska åtföljas av 0.', 'cp help: no main stress 2 (h e j): correct.' );
is( $help[1], 'HJÄLP	Giltiga engelska vokaler: @ @@ a aa ai au e e@ ei i i@ ii o oi oo ou u u@ uh uu	Giltiga engelska konsonanter: b ch d dh f g h jh k l m n ng p r s sh t th v w y z zh R', 'cp help: no main stress 2 (h e j): correct.' );
is( $help[2], 'HJÄLP	Ordet måste ha en huvudbetoning (1).', 'cp help: no main stress 2 (h e j): correct.' );
#is( $example[0], 'EXEMPEL	Huvudbetoning, engelska: w i1 n @0 r', 'cp ex: no main stress 2 (h e j): correct.' );
#is( $example[1], undef, 'cp ex: (h e j): correct.' );
is( $sanityWarnings[0], undef, 'cp sw0: (h e j): correct.' );

#**************************************************#
# TPA
# Main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'hej', 'h e j', 'swe', 'tpa', 1, 'NN', 'hej', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Huvudbetoning saknas:	/h e j/', 'tpa pw0: no stress (h e j): correct.' );
is( $pronWarnings[1], "VARNING	Det finns ingen huvudbetoning (\') och det finns endast en vokal i ordet:	/h e j/", 'tpa pw1: no main stress 2 (h e j): correct.' );
is( $help[0], "HJÄLP	En huvudbetoning måste finnas (\'\|\").", 'tpa help: no main stress 2 (h e j): correct.' );
is( $help[1], "HJÄLP	Om det bara finns en vokal i ordet måste den ha accent I (\').", 'tpa help: no main stress 2 (h e j): correct.' );
is( $example[0], "EXEMPEL	Accent I: sak	\/s \'a2: k\/", 'tpa ex: no main stress 2 (h e j): correct.' );
is( $sanityWarnings[0], undef, 'tpa sw0: (h e j): correct.' );

# Missing secondary stress in compound
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', "s \"a m a n \$ s e t n i ng", 'swe', 'tpa', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], "VARNING	Bibetoning saknas:	/s \"a m a n s e t n i ng/", 'tpa pw0: no stress (sammansättning): correct.' );
is( $pronWarnings[1], undef, 'mtm pw1:correct.' );
is( $help[0], "HJÄLP	Ett ord med accent II (\") måste ha bibetoning (\`).", 'tpa h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], undef, 'tpa h1: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'mtm sw0: (sammansättning): correct.' );
is( $example[0], undef, 'mtm ex0: (sammansättning): correct.' );

# Secondary stress before main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', 's `a m a n - s "e t n i ng', 'swe', 'tpa', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Bibetoning saknas:	/s `a m a n s "e t n i ng/', 'tpa pw0: sec stress (sammansättning): correct.' );
is( $pronWarnings[1], 'VARNING	Otillåten bibetoning	/s `a m a n s "e t n i ng/', 'tpa pw1: sec stress (sammansättning): correct.' );
is( $pronWarnings[2], undef, 'mtm pw1:correct.' );
is( $help[0], 'HJÄLP	Ett ord med accent II (") måste ha bibetoning (`).', 'tpa h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], 'HJÄLP	Bibetoning (`) får ej förekomma före huvudbetoning (")	/s `a m a n s "e t n i ng/', 'tpa h1: (sammansättning): correct.' );
is( $help[2], undef, 'tpa h2: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'tpa sw0: (sammansättning): correct.' );
is( $example[0], undef, 'tpa ex0: (sammansättning): correct.' );

# Sanity check
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'ack', "k \'a2:", 'swe', 'tpa', 1, 'NN', 'ajeh', 1 );
@sanityWarnings = @$sanityWarnings;
is( $sanityWarnings[0], "Initialt a matchar inte	ack k \'a2: ", 'tpa sw0: (ack): correct.' );
is( $sanityWarnings[1], "Finalt k matchar inte	ack k \'a2: ", 'tpa sw1: (ack): correct.' );

#**************************************************#
# Acapela
# Main stress

### TODO get this one back
#( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'hej', 'h e j', 'swe', 'acapela', 1, 'NN', 'hej', 1 );
#@pronWarnings = @$pronWarnings;
#@sanityWarnings = @$sanityWarnings;
#@help = @$help;
#@example = @$example;

#is( $pronWarnings[0], 'VARNING	Huvudbetoning saknas:	/h e j/', 'aca pw0: no stress (h e j): correct.' );
#is( $pronWarnings[1], "VARNING	Det finns ingen huvudbetoning (4) och det finns endast en vokal i ordet:	/h e j/", 'aca pw1: no main stress 2 (h e j): correct.' );
#is( $help[0], "HJÄLP	En huvudbetoning måste finnas (4|3).", 'aca help: no main stress 2 (h e j): correct.' );
#is( $help[1], "HJÄLP	Om det bara finns en vokal i ordet måste den ha accent I (4).", 'aca help: no main stress 2 (h e j): correct.' );
#is( $example[0], undef, 'mtm ex: no main stress 2 (h e j): correct.' );
#is( $sanityWarnings[0], undef, 'aca sw0: (h e j): correct.' );

# Missing secondary stress in compound
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', "s a3 m a n s e t n I N", 'swe', 'acapela', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], "VARNING	Bibetoning saknas:	/s a3 m a n s e t n I N/", 'aca pw0: no stress (sammansättning): correct.' );
is( $pronWarnings[1], undef, 'cp pw1:correct.' );
is( $help[0], 'HJÄLP	En sammansättning måste ha sammansättningsbetoning med accent II (3) och bibetoning (1).', 'aca h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], undef, 'aca h1: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'aca sw0: (sammansättning): correct.' );
is( $example[0], undef, 'aca ex0: (sammansättning): correct.' );

# Secondary stress before main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', 's a1 m a n - s e3 t n I N', 'swe', 'acapela', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], 'VARNING	Bibetoning saknas:	/s a1 m a n s e3 t n I N/', 'aca pw0: sec stress (sammansättning): correct.' );
is( $pronWarnings[1], 'VARNING	Otillåten bibetoning	/s a1 m a n s e3 t n I N/', 'aca pw1: sec stress (sammansättning): correct.' );
is( $pronWarnings[2], undef, 'aca pw1:correct.' );
is( $help[0], 'HJÄLP	En sammansättning måste ha sammansättningsbetoning med accent II (3) och bibetoning (1).', 'aca h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], 'HJÄLP	Bibetoning (1) får ej förekomma före huvudbetoning (3)	/s a1 m a n s e3 t n I N/', 'aca h1: (sammansättning): correct.' );
is( $help[2], undef, 'aca h2: (sammansättning): correct.' );
is( $sanityWarnings[0], undef, 'aca sw0: (sammansättning): correct.' );
is( $example[0], undef, 'aca ex0: (sammansättning): correct.' );

# Sanity check
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'ack', 'k A:4', 'swe', 'acapela', 1, 'NN', 'ajeh', 1 );
@sanityWarnings = @$sanityWarnings;
is( $sanityWarnings[0], "Initialt a matchar inte	ack k A:4 ", 'aca sw0: (ack): correct.' );
is( $sanityWarnings[1], "Finalt k matchar inte	ack k A:4 ", 'aca sw1: (ack): correct.' );

#**************************************************#
# IPA
# Main stress
### TODO get this one back
#( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'hej', 'h e j', 'swe', 'ipa', 1, 'NN', 'hej', 1 );
#@pronWarnings = @$pronWarnings;
##@sanityWarnings = @$sanityWarnings;
#@help = @$help;
#@example = @$example;

#is( $pronWarnings[0], 'VARNING	Huvudbetoning saknas:	/h e j/', 'ipa pw0: no stress (h e j): correct.' );
#is( $pronWarnings[1], "VARNING	Det finns ingen huvudbetoning (\') och det finns endast en vokal i ordet:	/h e j/", 'ipa pw1: no main stress 2 (h e j): correct.' );
#is( $help[0], "HJÄLP	En huvudbetoning måste finnas (\'|\").", 'ipa help: no main stress 2 (h e j): correct.' );
#is( $help[1], "HJÄLP	Om det bara finns en vokal i ordet måste den ha accent I (\').", 'ipa help: no main stress 2 (h e j): correct.' );
#is( $example[0], undef, 'mtm ex: no main stress 2 (h e j): correct.' );
##is( $sanityWarnings[0], undef, 'ipa sw0: (h e j): correct.' );

# Missing secondary stress in compound
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', "s \"a m a n s e t n ɪ ŋ", 'swe', 'ipa', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
#@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], "VARNING	Bibetoning saknas:	/s \"a m a n s e t n ɪ ŋ/", 'ipa pw0: no stress (sammansättning): correct.' );
is( $pronWarnings[1], undef, 'cp pw1:correct.' );
is( $help[0], "HJÄLP	Ett ord med accent II (\") måste ha bibetoning (\`).", 'ipa h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], undef, 'mtm h1: (sammansättning): correct.' );
#is( $sanityWarnings[0], undef, 'ipa sw0: (sammansättning): correct.' );
is( $example[0], undef, 'ipa ex0: (sammansättning): correct.' );


# Secondary stress before main stress
( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'sammansättning', "s \`a m a n s e t n \"ɪ ŋ", 'swe', 'ipa', 1, 'NN', 'samman+sättning', 1 );
@pronWarnings = @$pronWarnings;
#@sanityWarnings = @$sanityWarnings;
@help = @$help;
@example = @$example;

is( $pronWarnings[0], "VARNING	Bibetoning saknas:	/s \`a m a n s e t n \"ɪ ŋ/", 'ipa pw0: sec stress (sammansättning): correct.' );
is( $pronWarnings[1], "VARNING	Otillåten bibetoning	/s \`a m a n s e t n \"ɪ ŋ/", 'ipa pw1: sec stress (sammansättning): correct.' );
is( $pronWarnings[2], undef, 'ipa pw1:correct.' );
is( $help[0], "HJÄLP	Ett ord med accent II (\") måste ha bibetoning (\`).", 'ipa h0: no main stress 2 (sammansättning): correct.' );
is( $help[1], "HJÄLP	Bibetoning (\`) får ej förekomma före huvudbetoning (\")	/s \`a m a n s e t n \"ɪ ŋ/", 'ipa h1: (sammansättning): correct.' );
is( $help[2], undef, 'ipa h2: (sammansättning): correct.' );
#is( $sanityWarnings[0], undef, 'ipa sw0: (sammansättning): correct.' );
is( $example[0], undef, 'ipa ex0: (sammansättning): correct.' );

# Sanity check
#( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( 'ack', 'k ɒː', 'swe', 'ipa', 1, 'NN', 'ajeh', 1 );
#@sanityWarnings = @$sanityWarnings;
#is( $sanityWarnings[0], "Initialt a matchar inte	ack k ɒː", 'ipa sw0: (ack): correct.' );
#is( $sanityWarnings[1], "Finalt k matchar inte	ack k ɒː", 'ipa sw1: (ack): correct.' );
#**************************************************#
#open OUT, ">ct/out.txt";
#print OUT "pw0 $pronWarnings[0]\n";
#print OUT "pw1 $pronWarnings[1]\n";
#print OUT "pw2 $pronWarnings[2]\n";
#print OUT "sw0 $sanityWarnings[0]\n";
#print OUT "sw1 $sanityWarnings[1]\n";
#print OUT "sw2 $sanityWarnings[2]\n";
#print OUT "h0 $help[0]\n";
#print OUT "h1 $help[1]\n";
#print OUT "h2 $help[2]\n";
#print OUT "e0 $example[0]\n";
#print OUT "e1 $example[1]\n";
#print OUT "e2 $example[2]\n";

#**************************************************#
#done_testing();
1;
