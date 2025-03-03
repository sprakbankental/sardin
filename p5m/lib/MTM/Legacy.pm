package MTM::Legacy;

##### 2021-01-06 NB!!!The current rather hacky solution (my bad) is order dependent here
#     parent needs to be set first (ok I guess) and Lists last as it depends
#     on Characterizzation at load time (not ok at all)
use parent qw(MTM);
use MTM::Vars;
use MTM::Case;
use MTM::Legacy::Lists;
use MTM::Pronunciation::Syllabify;

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;
# END SBTal boilerplate

# Uncomment this to see progress for resource sourcing
# use Smart::Comments '###';

#**************************************************************#
# addEnding
#
# Adds the saved ending to transcription.
# test exists		210817
#**************************************************************#
sub addEnding {

	my ( $pron, $ending ) = @_;
	my $morph;

	if ($ending =~ /^:?s$/) {
		$pron	.=	' s';
		$morph	=	'GEN';

	} elsif ($ending =~ /^er$/) {
		$pron	.=	' ex r';
		$morph	=	'- PLU IND NOM';

	} elsif ($ending =~ /^ers$/) {
		$pron	.=	' ex rs';
		$morph	=	'- PLU IND GEN';

	} elsif ($ending =~ /^ar$/) {
		$pron	.=	' a r';
		$morph	=	'- PLU IND NOM';

	} elsif ($ending =~ /^ars$/) {
		$pron	.=	' a rs';
		$morph	=	'- PLU IND GEN';

	} elsif ($ending =~ /^or$/) {
		$pron	.=	' a r';
		$morph	=	'- PLU IND NOM';

	} elsif ($ending =~ /^ors$/) {
		$pron	.=	' a rs';
		$morph	=	'- PLU IND GEN';

	} elsif ($ending =~ /^en$/) {
		$pron	.=	' ex n';
		$morph	=	'UTR SIN DEF NOM';

	} elsif ($ending =~ /^ens$/) {
		$pron	.=	' ex n s';
		$morph	=	'UTR SIN DEF GEN';

	} elsif ($ending =~ /^et$/) {
		$pron	.=	' ex t';
		$morph	=	'NEU SIN DEF NOM';

	} elsif ($ending =~ /^ets$/) {
		$pron	.=	' ex t s';
		$morph	=	'NEU SIN DEF GEN';

	} elsif ($ending =~ /^rna$/) {
		$pron	.=	' . rn a';
		$morph	=	'- PLU DEF NOM';

	} elsif ($ending =~ /^rnas$/) {
		$pron	.=	' . rna s';
		$morph	=	'- PLU DEF GEN';

	} elsif ($ending =~ /^erna$/) {
		$pron	.=	' ex . rn a';
		$morph	=	'- PLU DEF NOM';

	} elsif ($ending =~ /^ernas$/) {
		$pron	.=	' ex . rn a s';
		$morph	=	'- PLU DEF GEN';

	} elsif ($ending =~ /^arna$/) {
		$pron	.=	' a . rn a';
		$morph	=	'- PLU DEF NOM';

	} elsif ($ending =~ /^arnas$/) {
		$pron	.=	' a . rn a s';
		$morph	=	'- PLU DEF GEN';

	} elsif ($ending =~ /^orna$/) {
		$pron	.=	' o . rn a';
		$morph	=	'- PLU DEF NOM';

	} elsif ($ending =~ /^ornas$/) {
		$pron	.=	' o . rn a s';
		$morph	=	'- PLU DEF GEN';


	} elsif ($ending =~ /^aren$/) {
		$pron	.=	' a . r ex n';
		$morph	=	'UTR SIN DEF NOM';

	} elsif ($ending =~ /^arens$/) {
		$pron	.=	' a . r ex n s';
		$morph	=	'UTR SIN DEF GEN';

	} elsif ($ending =~ /^n$/) {
		$pron	.=	' n';
		$morph	=	'UTR SIN DEF NOM';

	} elsif ($ending =~ /^ns$/) {
		$pron	.=	' n s';
		$morph	=	'UTR SIN DEF GEN';

	} elsif ($ending =~ /^t$/) {
		$pron	.=	' t';
		$morph	=	'NEU SIN DEF NOM';

	} elsif ($ending =~ /^ts$/) {
		$pron	.=	' t s';
		$morph	=	'NEU SIN DEF GEN';

	}

	$pron = &MTM::Pronunciation::Syllabify::syllabify( $pron );

	return ( $pron, $morph );
}
#***************************************************************#
# Clean blanks
#
# test exists		210817
#***************************************************************#
sub cleanBlanks {
	my $string = shift;

	$string =~ s/\t/ /g;
	$string =~ s/^ +//;
	$string =~ s/ +$//;
	$string =~ s/ +/ /g;

	return $string;
}
#***************************************************************#
# Clean multiples
#***************************************************************#
sub clean_multiples {
	my $multiple = shift;
	my $string = shift;

	$string =~ s/($multiple)+/$multiple/g;
	$string =~ s/^$multiple//;
	$string =~ s/$multiple$//;

	return $string;
}
#***************************************************************#
# Remove utf8 bom
#***************************************************************#
sub remove_bom {
	my $string = shift;
	$string =~ s/^\xEF\xBB\xBF//g;
	return $string;
}
#***********************************************************************#
# Mark abbreviations (used by SplitSentence.pm)
### TODO regex refs
sub mark_abbreviations {
	my $string = shift;

	# English
	if( $MTM::Vars::lang eq 'en' ) {
		$string =~ s/(^| |>|\b)($MTM::Legacy::Lists::en_abbreviation_list)([$MTM::Vars::delimiter]|\&|\)|\(|\&[gl]t\;|\&amp\;|\&quot\;|\&gt;|\&lt\;|$| )/$1<ABBR>$2<eABBR>$3/ig;
		$string =~ s/(^| |>|\b)($MTM::Legacy::Lists::en_abbreviation_list_case)([$MTM::Vars::delimiter]|\&|\)|\(|\&[gl]t\;|\&amp\;|\&quot\;|$| )/$1<ABBR>$2<eABBR>$3/g;
		$string =~ s/(^| |>|\b)($MTM::Vars::en_month_abbreviation|$MTM::Vars::en_weekday_abbreviation)([$MTM::Vars::delimiter]|\&|\)|\(|\&(amp|quot|gt|lt)\;|$ )/$1<ABBR>$2<eABBR>$3/ig;

		# Page references
		$string =~ s/(^| |>|\b)(pp?\.?)( \d)/$1<ABBR>$2<eABBR>$3/g;	# case sensitive (p.)

	# Swedish and world
	} else {
		$string =~ s/(^| |>|\b)($MTM::Legacy::Lists::sv_abbreviation_list)([$MTM::Vars::delimiter]|\&|\)|\(|\&[gl]t\;|\&amp\;|\&quot\;|\&gt;|\&lt\;|$| )/$1<ABBR>$2<eABBR>$3/ig;
		$string =~ s/(^| |>|\b)($MTM::Legacy::Lists::sv_abbreviation_list_case)([$MTM::Vars::delimiter]|\&|\)|\(|\&[gl]t\;|\&amp\;|\&quot\;|$| )/$1<ABBR>$2<eABBR>$3/g;

		# Not if already marked as abbreviation
		if( $string !~ /<ABBR>($MTM::Vars::sv_month_abbreviation|$MTM::Vars::sv_weekday_abbreviation)/ ) {
			$string =~ s/(^| |>|\b)($MTM::Vars::sv_month_abbreviation|$MTM::Vars::sv_weekday_abbreviation)([$MTM::Vars::delimiter]|\&|\)|\(|\&(amp|quot|gt|lt)\;|$ )/$1<ABBR>$2<eABBR>$3/ig;
		}

		$string =~ s/(^| |>|\b)(s\.?)( \d)/$1<ABBR>$2<eABBR>$3/g;	# case sensitive (s.)
		$string =~ s/\b(s\.?)( +[xvi])/<ABBR>$1<eABBR>$2/g;	# space between "s" and roman is required

		# 240511 issue-184
		$string =~ s/(<ABBR>[^<]+)<ABBR>([^>]+)<eABBR>([^>]+<eABBR>)/$1$2$3/g;

		# print STDERR "$string\n"; exit;
	}

	# Merge period with month and weekday abbreviations
	# wed.-fri. jan-may
	# English
	if( $MTM::Vars::lang eq 'en' ) {
		$string =~ s/(<ABBR>(?:$MTM::Vars::en_month_abbreviation|$MTM::Vars::en_weekday_abbreviation))<eABBR>\./$1\.<eABBR>/ig;
	# Swedish and world
	} else {
		$string =~ s/(<ABBR>(?:$MTM::Vars::sv_month_abbreviation|$MTM::Vars::sv_weekday_abbreviation))<eABBR>\./$1\.<eABBR>/g;
	}

	$string =~ s/<eABBR>\.-/\.<eABBR>-/g;

	return $string;
}
#***********************************************************#
# rewriteStuff
#
# Convert characters within abbreviations.
#***********************************************************#
sub rewrite_chars {

	my $a = shift;

	$a =~ s/\./<PERIOD>/g;
	$a =~ s/:/<COLON>/g;
	$a =~ s/\//<SLASH>/g;
	$a =~ s/1/<ONE>/g;
	$a =~ s/2/<TWO>/g;
	$a =~ s/3/<THREE>/g;
	$a =~ s/4/<FOUR>/g;
	$a =~ s/5/<FIVE>/g;
	$a =~ s/6/<SIX>/g;
	$a =~ s/7/<SEVEN>/g;
	$a =~ s/8/<EIGHT>/g;
	$a =~ s/9/<NINE>/g;
	$a =~ s/0/<ZERO>/g;

	$a =~ s/\+/<PLUS>/g;
	$a =~ s/\=/<EQUALS>/g;

	$a =~ s/ /<SPACE>/g;

	return $a;
}
#***********************************************************#
# restoreRewritten
#
# Restore the replaced characters within abbreviations.
#***********************************************************#
sub restore_rewritten_chars {

	my $s = shift;

	$s =~ s/<ABBR>/<ABBRSPLITTER><ABBR>/g;
	$s =~ s/<eABBR>/<eABBR><ABBRSPLITTER>/g;

	my @a = split/<ABBRSPLITTER>/, $s;

	foreach my $a( @a ) {

		if( $a =~ /<eABBR>/ ) {
			$a =~ s/<SPLITTER>//g;
		}

		$a =~ s/<PERIOD>/\./g;
		$a =~ s/<COLON>/\:/g;
		$a =~ s/<SLASH>/\//g;
		$a =~ s/<ONE>/1/g;
		$a =~ s/<TWO>/2/g;
		$a =~ s/<THREE>/3/g;
		$a =~ s/<FOUR>/4/g;
		$a =~ s/<FIVE>/5/g;
		$a =~ s/<SIX>/6/g;
		$a =~ s/<SEVEN>/7/g;
		$a =~ s/<EIGHT>/8/g;
		$a =~ s/<NINE>/9/g;
		$a =~ s/<ZERO>/0/g;

		$a =~ s/<PLUS>/\+/g;
		$a =~ s/<EQUALS>/\=/g;

		$a =~ s/<SPACE>/ /g;

		$a =~ s/<e?ABBR>//g;
		$a =~ s/<e?MULTI>//g;
		$a =~ s/<e?USER>//g;
	}

	return join"", @a;
}
#***************************************************************#
# Clean markup
#
# test exists		210817
#***************************************************************#
# Remove stuff between < and >.
sub cleanMarkup {
	my $string = shift;
	$string =~ s/<[^>]+>/ /g;
	return $string;
}
#************************************************#
# isDigitsOnly
#
# test exists		210817
#***************************************************************#
sub isDigitsOnly {
	my $string = shift;

	if ( $string =~ /^[0-9]+$/ ) {
		return 1;
	} else {
		return 0;
	}
}
#************************************************#
# isDefault
#
# test exists		210817
#*************************************************#
sub isDefault {
	my $string = shift;

	if ( !defined( $string )) {
		return 1;
	}
	if ( $string =~ /^(void|DEFAULT|-|\s*)$/i ) {
		return 1;
	} else {
		return 0;
	}
}
#************************************************#
# isRoman
#
# test exists		210817
#************************************************#
sub isRoman {	# return: 1/0
	my $string = shift;

	if ( !defined( $string )) {
		return "0";
	}

	if (
		$string =~ /^(?:M{0,3})(?:D?C{0,3}|C[DM])(?:L?X{0,3}|X[LC])(?:V?I{0,3}|I[VX])$/i
		&&
		$string ne 'CC'
	) {
		return 1;
	} else {
		return 0;
	}
}
#************************************************#
# isLowercaseOnly
#
# test exists		210817
#************************************************#
sub isLowercaseOnly {	# return: 1/0

	my $string = shift;

	if ( $string =~ /^[$MTM::Vars::lc]+$/ ) {
		return 1;
	} else {
		return 0;
	}
}
#************************************************#
# isUppercaseOnly
#
# test exists		210817
#************************************************#
sub isUppercaseOnly {	# return: 1/0

	my $string = shift;

	if ( $string =~ /^[$MTM::Vars::uc]+$/ ) {
		return 1;
	} else {
		return 0;
	}
}
#************************************************#
# isPossiblyPM
#
# test exists		210817
#************************************************#
sub isPossiblyPM { # return: 1/0
	my $orth = shift;
	my $pos = shift;
	my $isInDictionary = shift;
	if (
		# is tagged as proper name
		$pos =~ /^PM/
		||
		# unknown word uppercase-lowercase
		(
			&isDefault( $isInDictionary )					##### CT 2020-11-19	 This is not yet looked up, change to 1/0 when it is.
			&&
			$orth =~ /^[$MTM::Vars::uc][$MTM::Vars::lc]/
		)
	) {
		return 1;
	} else {
		return 0;
	}
}

#**************************************************************#
sub get_exprType {
	my $exprType = shift;
	my $to_insert = shift;

	if( $exprType =~ /(^|\|)$to_insert(\||$)/ ) {
		# do nothing

	} elsif( $exprType ne '-' ) {
		$exprType .= "\|$to_insert";

	} else {
		$exprType = $to_insert;
	}

	return $exprType;
}
#**************************************************************#
sub remove_exprType {
	my $exprType = shift;
	my $to_remove = shift;

	my @new = ();
	my @et = split/\|/, $exprType;

	foreach my $et ( @et ) {
		if( $et ne $to_remove ) {
			push @new, $et;
		}
	}

	push @new, '-' if $#new < 0;

	return join'|', @new;
}
#**************************************************************#
1;
