package MTM::Tokenisation::SplitTokens;
#***********************************************************#
# SplitTokens
#
# Split sentence into tokens
#
# tests exist		210820
#***********************************************************#

use strict;
use warnings;
use utf8;

use MTM::Legacy;
sub splitTokens {

	##### CT 210820 Why do we need $self here?	my $self = shift; ##### (NB) We're actually calling this as an object!
	my $string = shift;
	my $runmode = shift; 	##### (TODO) We pass runmode for the time being only.

	### TODO solve this with paralell data representation from start.
	# If not allowed to change orthography
	if( $runmode !~ /unsupervisedSSML/ ) {
		$string =~ s/^ +//;
		$string =~ s/ +$//;
		$string =~ s/ +/ /g;
		$string =~ s/ / /g;
	}

	#**********************************************************************************#
	# 1. Mark abbreviations
	$string = &MTM::Legacy::mark_abbreviations( $string );

	if( $string =~ /<ABBR>/ ) {
		my @abbr = split/(<ABBR>[^<]+<eABBR>)/,$string;
		my $count = 0;

		foreach my $abb ( @abbr ) {

			# Avoid acronym endings such as "SBU:s"
			if ( $count > 0 && $abbr[$count-1] =~ /\:$/ && $abb =~ /<ABBR>s<eABBR>/i ) {
				$abb =~ s/<e?ABBR>//g;
			}

			# Rewrite digits, periods, colons and slashes
			if ( $abb =~ /<ABBR>/ ) {
				$abb = &MTM::Legacy::rewrite_chars( $abb );
			}
			$count++;
		}

		$string = join"",@abbr;
		$string =~ s/<PERIOD><eABBR>$/<eABBR>\./;		# Sentence final period is not part of the abbreviation.
	}
	# print STDERR "1. $string\n";

	#**********************************************************************************#
	# 2.	Split at blanks.
	$string =~ s/( +)/<SPLITTER>$1<SPLITTER>/g;
	$string = &MTM::Legacy::clean_multiples( '<SPLITTER>', $string );

	#print STDERR "2. $string\n\n";

	#**********************************************************************************#
	# 3.	Split at delimiters.

	### TODO solve this with paralell data representation from start.
	if( $runmode !~ /unsupervisedSSML/ ) {
		$string =~ s/\•//g;
		$string =~ s/\”/\"/g;
	}

	$string =~ s/([\.\!\?\_])/<SPLITTER>$1<SPLITTER>/g;		# Major delimiters
	$string =~ s/([\,\;\:\(\)\/])/<SPLITTER>$1<SPLITTER>/g;		# Minor delimiters

	$string =~ s/(€|£|\$)/<SPLITTER>$1<SPLITTER>/g;			# Currencies
	$string =~ s/([º°])/<SPLITTER>$1<SPLITTER>/g;			# Degrees
	$string =~ s/(\=|\+|\%|\‰|\×)/<SPLITTER>$1<SPLITTER>/g;		# Maths

	$string =~ s/(\»|\«|\"|\'|\’|\‘)/<SPLITTER>$1<SPLITTER>/g;	# Quotes
	$string =~ s/([\[\]\{\}])/<SPLITTER>$1<SPLITTER>/g;		# Brackets
	$string =~ s/(\#|\&|\§|\@|†|\~|\*)/<SPLITTER>$1<SPLITTER>/g;	# Other

	$string =~ s/(\&(?:amp|gt|lt|quot)\;)/<SPLITTER>$1<SPLITTER>/g;	# HTML

	# Dash between digits. Twice to catch all.
	$string =~ s/(\d)-(\d)/$1<SPLITTER>-<SPLITTER>$2/g;
	$string =~ s/(\d)-(\d)/$1<SPLITTER>-<SPLITTER>$2/g;

	$string =~ s/(\d<SPLITTER> <SPLITTER>-)(\d)/$1<SPLITTER>$2/g;	# Split "1996 -2000"

	$string = &MTM::Legacy::clean_multiples( '<SPLITTER>', $string );

	# print STDERR "3. $string\n\n";

	#**********************************************************************************#
	# 4. Split
	my @ort = split/(<SPLITTER>)/,$string;
	foreach my $o ( @ort ) {
		$o =~ s/^-(\d)/-<SPLITTER>$1/;				# ^-1
		$o =~ s/(\d)-(\d)/$1<SPLITTER>-<SPLITTER>$2/g;		# 1-1
		$o =~ s/^([a-z])-(\d)/$1<SPLITTER>-<SPLITTER>$2/;	# 7 a-8 c kap.
		$o =~ s/([\d\w])([¹²³ʰʱʲʳʴʵʶʷʸ\ʹ\ʺ\ʻ\ʼ\ʽʾʿˀˁ˜˟ˠˡˢˣˤͣͤͥͦͧͨͩͪͫͬͭͮͯᵃᵄᵅᵆᵈᵉᵊᵋᵌᵍᵎᵏᵐᵑᵒᵓᵖᵗᵘᵚᵙᵛᵜᵝᵞᵟᵠᵡᴬᴭᴮᴯᴰᴱᴲᴳᴴᴵᴶᴷᴸᴹᴺᴻᴼᴽᴾᵀᵁᵂᵸᶛᶜᶝᶞᶟᶠᶡᶢᶤᶥᶦᶧᶨᶩᶪᶫᶬᶭᶮᶯᶰᶱᶲᶳᶴᶵᶶᶷᶹᶸᶺᶻᶼᶽᶾᶿ᷀᷁⁰ⁱ⁴⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿ₀₁₂₃₅₆₇₈₉₊₋₌₍₎ₐₑₒₓₔᵢᵤᵥᵦᵧᵨᵩᵪ])/$1<SPLITTER>$2/;		# Superscript/subscript
		$o =~ s/(\d)([$MTM::Vars::letter])/$1<SPLITTER>$2/;

		# 230215
		if( $MTM::Vars::eval_flag == 0 ) {
			$o =~ s/([$MTM::Vars::letter])(\d)/$1<SPLITTER>$2/;
		}
	}

	$string = join"",@ort;
	$string = &MTM::Legacy::clean_multiples( '<SPLITTER>', $string );

	# print STDERR "4. $string\n\n";

	#**********************************************************************************#
	# 10.	Repair incorrect splittings
	#**********************************************************************************#

	# 10A.	Merge dashes within words					50-årsdag, NLB-ansatt
	$string =~ s/([$MTM::Vars::characters]|\d)<SPLITTER>-<SPLITTER>([$MTM::Vars::characters])/$1-$2/g;

	# 10D.	Merge :-
	$string =~ s/(^|>)\:<SPLITTER>-(<|$)/$1:-$2/g;

	# 10E.	Merge »-							«Full City»-kapteinen
	$string =~ s/<SPLITTER>(\»|\")<SPLITTER>\-/$1\-/g;

	# 10F.	Merge singlequotes within words.
	$string =~ s/([$MTM::Vars::characters])<SPLITTER>([$MTM::Vars::singleQuote])<SPLITTER>([$MTM::Vars::characters])/$1$2$3/ig;	# couldn't
	$string =~ s/([$MTM::Vars::characters])<SPLITTER>([$MTM::Vars::singleQuote])<SPLITTER><ABBR>s<eABBR>/$1$2s/ig;				# Kauami's

	# Merge H&M
	$string =~ s/(\&)<SPLITTER>(amp|quot|gt|lt)<SPLITTER>(\;)/$1$2$3/ig;
	$string =~ s/(^|<SPLITTER>)H<SPLITTER>(\&|\&amp\;)<SPLITTER>M(<SPLITTER>|$)/$1H$2M$3/ig;

	# Merge e.g. acronym endings
	$string =~ s/<SPLITTER>:<SPLITTER>($MTM::Vars::sv_acronym_endings|$MTM::Vars::sv_ordinal_endings)(<SPLITTER>|$)/:$1$2/ig if $MTM::Vars::lang eq 'sv';	# Swedish

	$string =~ s/(\d+)<SPLITTER>($MTM::Vars::en_ordinal_endings)(<SPLITTER>|$)/$1$2$3/ig if $MTM::Vars::lang eq 'en';	# English


	#**********************************************************************************#
	# 10H.	Merge separated numbers.
	$string =~ s/(\d)<SPLITTER>($MTM::Vars::thousand_separator)<SPLITTER>(\d\d\d)(\b|th)/$1$2$3$4/g;		# 2.000/2.000
	$string =~ s/(\d)<SPLITTER>($MTM::Vars::thousand_separator)<SPLITTER>(\d\d\d)(\b|th)/$1$2$3$4/g;		# 2.000.000/2,000,000
	$string =~ s/(\d)<SPLITTER>($MTM::Vars::thousand_separator)<SPLITTER>(\d\d\d)(\b|th)/$1$2$3$4/g;		# 2.000.000.000/2,000,000,000

	$string =~ s/(\d)<SPLITTER> <SPLITTER>(\d\d\d)\b/$1 $2/g;			# 2 000
	$string =~ s/(\d)<SPLITTER> <SPLITTER>(\d\d\d)\b/$1 $2/g;			# 2 000 000
	$string =~ s/(\d)<SPLITTER> <SPLITTER>(\d\d\d)\b/$1 $2/g;			# 2 000 000 000

	# Undo merging if the merged numbers is preceded by another number, e.g. phone numbers 416 18 477
	$string =~ s/(\d<SPLITTER> <SPLITTER>\d+) (\d\d\d)\b/$1<SPLITTER> <SPLITTER>$2/g;

	# Undo merging if preceded by 'kapitel'
	$string =~ s/(kapitel<SPLITTER> <SPLITTER>)(\d\d?) (\d\d\d)/$1$2<SPLITTER>,<SPLITTER> <SPLITTER>$3/ig;

	# Undo merging if there's more than three digits to the left		# I slutet av 2009 450 anställda.
	$string =~ s/(\d\d\d\d+) (\d\d\d)\b/$1<SPLITTER> <SPLITTER>$2/g;

	#**********************************************************************************#
	# 10J.	Merge special expressions
	$string =~ s/\bmp<SPLITTER>3\b/mp3/ig;				# mp3
	$string =~ s/(\bA)<SPLITTER>\/<SPLITTER>(S\b)/$1\/$2/g;		# A/S
	$string =~ s/\§<SPLITTER>\§/\§\§/g;				# §§

	#**********************************************************************************#
	# 10L.	Remove splittings
	$string =~ s/(\w)<SPLITTER>([\'\’])<SPLITTER>(\w)/$1$2$3/i;		# d's

	if( $MTM::Vars::lang eq 'sv' ) {
		$string =~ s/(\d)<SPLITTER>([\'\’])<SPLITTER>($MTM::Vars::sv_word_endings)$/$1$2$3/g;	# 1's
		$string =~ s/(\d)<SPLITTER>($MTM::Vars::sv_word_endings)$/$1$2/g;				# 1orna
	}
	#**********************************************************************************#
	# 10K. Fractions	1/2 liter
	if ( $string =~ /(\d)<SPLITTER>\/<SPLITTER>(\d+)(<SPLITTER> +<SPLITTER>(?:<ABBR>)?($MTM::Vars::sv_units)(<PERIOD>)?(<eABBR>)?(<SPLITTER>|$))/ ) {
		my $fractionTest = "$1/$2";
		if ( $fractionTest =~ /^($MTM::Vars::fraction)$/ ) {
			$string =~ s/(\d)<SPLITTER>\/<SPLITTER>(\d+)(<SPLITTER> +<SPLITTER>(?:<ABBR>)?(?:$MTM::Vars::sv_units)(?:<PERIOD>)?(?:<eABBR>)?(?:<SPLITTER>|$)|$)/$1\/$2$3/g;
		}
	}
	$string =~ s/(\d)($MTM::Vars::fraction)/$1<SPLITTER>$2/g;

	$string =~ s/s<SPLITTER>(\'<SPLITTER>)/s$1/g;	# 2022-05-10

	#**********************************************************************************#
	# Restore rewritten stuff
	#**********************************************************************************#
	if( $string =~ /<ABBR>.+<eABBR>/ ) {
		$string = &MTM::Legacy::restore_rewritten_chars( $string );
	}

	#**********************************************************************************#
	# 20.	Intervals (last since we need to remove <ABBR> first)
	# English
	if( $MTM::Vars::lang eq 'en' ) {
		$string =~ s/\b($MTM::Vars::en_weekday)-($MTM::Vars::en_weekday)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::en_weekday_abbreviation)-($MTM::Vars::en_weekday_abbreviation)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::en_month)-($MTM::Vars::en_month)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::en_month_abbreviation)-($MTM::Vars::en_month_abbreviation)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::en_weekday_abbreviation)-($MTM::Vars::en_weekday_abbreviation)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
	# Swedish and world
	} else {
		$string =~ s/\b($MTM::Vars::sv_weekday)-($MTM::Vars::sv_weekday)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::sv_weekday_abbreviation)-($MTM::Vars::sv_weekday_abbreviation)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::sv_month)-($MTM::Vars::sv_month)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::sv_month_abbreviation)-($MTM::Vars::sv_month_abbreviation)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
		$string =~ s/\b($MTM::Vars::sv_weekday_abbreviation)-($MTM::Vars::sv_weekday_abbreviation)\b/$1<SPLITTER>-<SPLITTER>$2/ig;
	}

	$string = &MTM::Legacy::clean_multiples( '<SPLITTER>', $string );

	my @orth = split/<SPLITTER>/,$string;

	return @orth;
}
#**********************************************************************************#
1;
