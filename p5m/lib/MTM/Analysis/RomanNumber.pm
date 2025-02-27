package MTM::Analysis::RomanNumber;

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

#**************************************************************#
# RomanNumber
#
# Language	sv_se
#
# Rules for marking roman numbers.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Remove and save ending for later
	my $savedEnding = 'DEFAULT';
	my $origOrth = $t->{orth};

#	if (
#		#$t->{orth} !~ /^(via|cia|CIA)$/i				##### FIX THIS!
#		#&&
#		( $t->{orth} =~ /^([^mdl]+):($MTM::Vars::sv_roman_ending)$/i && $MTM::Vars::lang eq 'sv' )
#		||
#		( $t->{orth} =~ /^([^mdl]+):($MTM::Vars::en_roman_ending)$/i && $MTM::Vars::lang eq 'en' )
#	) {
#		##### CT 2020-11-19	This must be changed, never change {orth}!!! Use temporary orth instead.
#		$savedEnding = $2;
#	}

	if (
		(
			&MTM::Legacy::isDefault( $t->{exprType} )
			||
			$t->{exprType} =~ /INITIAL/
		)
		&&
		(
			&MTM::Legacy::isRoman( $t->{orth} )
		)
		&&
		(
			&MTM::Legacy::isLowercaseOnly( $t->{orth} )
			||
			&MTM::Legacy::isUppercaseOnly( $t->{orth} )
		)
	) {
		# continue
	} elsif (
			$t->{orth} =~ /^[xvi]+:s$/i
	) {
		# continue
	} else {
	#	$t->{orth} = $origOrth;
		return $self;
	}

	&markRoman_1( $self, $chunk );
	&markRoman_2( $self, $chunk );
	&markRoman_3( $self, $chunk );
	&markRoman_4( $self, $chunk );
	&markRoman_5( $self, $chunk );
	&markRoman_6( $self, $chunk );
	&markRoman_7( $self, $chunk );
	&markRoman_8( $self, $chunk );

#	if (
#		$savedEnding ne 'DEFAULT'
#	) {
#		&insertRomanEnding( $self, $savedEnding );
#	}

	return $self;
}
#**************************************************************#
# markRoman_1
#
# Intervals
# TEST	sidan xv-xix.
#
# CT 2020-11-19 Doesn't work because of incorrect word tokenisation.
#**************************************************************#
sub markRoman_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	if (
		&MTM::Legacy::isRoman( $t->{orth} )
	) {

		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	# With blanks	- needs fix in word tokenisation
	if (
		$rc1->{orth}	eq	"-"
		&&
		&MTM::Legacy::isRoman( $rc2->{orth} )
		&&
		(
			&MTM::Legacy::isLowercaseOnly( $rc2->{orth} )
			||
			&MTM::Legacy::isUppercaseOnly( $rc2->{orth} )
		)
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN INTERVAL');
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'ROMAN INTERVAL');
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'ROMAN INTERVAL');

		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$rc2->{pos}= 'RG';
		$rc2->{morph}= 'NOM';

		$rc1->{exp} = 'till';
	}

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;

	# Find locations
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	# With blanks
	if (
		$rc1->{pos}	eq	'DEL'
		&&
		$rc2->{orth}	eq	'-'
		&&
		$rc3->{pos}	eq	'DEL'
		&&
		&MTM::Legacy::isRoman( $rc4->{orth} )
		&&
		(
			&MTM::Legacy::isLowercaseOnly( $rc4->{orth} )
			||
			&MTM::Legacy::isUppercaseOnly( $rc4->{orth} )
		)
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN INTERVAL');
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'ROMAN INTERVAL');
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'ROMAN INTERVAL');
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'ROMAN INTERVAL');
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'ROMAN INTERVAL');

		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$rc4->{pos} = 'RG';
		$rc4->{morph} = 'NOM';

		$rc2->{exp} = 'till';

	}

	return $self;
}
#**************************************************************#
# markRoman_2
#
# Safe roman numbers (not "I", "VI" or "X" or "CC" preceeded by
# typical section word as "chapter" or "part".
# "I", "VI" and "X" only allowed if preceeded by "notreferens".
#
# TEST	kap. XV
#**************************************************************#
sub markRoman_2 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	if (
		$t->{orth}	=~	/^$MTM::Vars::safeRomanNum$/i
	) {
		# continue
	} else {
		return $self;
	}


	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	if (
		(
			( $lc2->{orth}	=~	/^($MTM::Vars::sv_roman_words)$/i && $MTM::Vars::lang eq 'sv' )
			||
			( $lc2->{orth}	=~	/^($MTM::Vars::en_roman_words)$/i && $MTM::Vars::lang eq 'en' )
		)
		&&
		$lc1->{pos}	eq	'DEL'
		&&
		$t->{orth}	=~ 	/^[xvi]+$/i	# not too high numbers
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
	}

	return $self;
}
#**************************************************************#
# markRoman_3
#
# TEST	IV Påvekyrkans uppgång och fall
#**************************************************************#
sub markRoman_3 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) && return $self;	# Must be first in string, nothing in left context.
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;


	if (
		&MTM::Legacy::isRoman( $t->{orth} )
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	# CT 2020-11-19 Is it really necessary with use utf8;?
#	use utf8;	# Needed to chatch e.g. XVIII Återfärden.	CT 160309
	if (
		$t->{orth}	=~	/^[XVI][XVI]+$/i
		&&
		$rc1->{pos}	eq	'DEL'
		&&
		$rc2->{orth}	=~	/^[A-ZÅÄÖÆØ][a-zåäöæö]/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
	}

	return $self;
}
#**************************************************************#
# markRoman_4
#
# TEST	I. Påvekyrkans uppgång och fall
#**************************************************************#
sub markRoman_4 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) && return $self;	# Must be first in string, nothing in left context.
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};


	if (
		$t->{orth} =~ /^[XVI]+$/
		&&
		$rc1->{orth} eq '.'
		&&
		$rc2->{pos} eq 'DEL'
		&&
		$rc3->{orth} =~ /^[$MTM::Vars::uc][$MTM::Vars::lc]/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$t->{pron} = '-';
		$rc1->{exprType} = 'ROMAN';

	}

	return $self;
}
#**************************************************************#
# markRoman_5
#
# Only roman number in string, but more than one letter.
# Would be nice to have the markup from *ML (page number triggers roman numbers)
#
# TEST	II
#**************************************************************#
sub markRoman_5 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# No context allowed
	my $lc1base = $chunk->peek(-1) && return $self;
	my $rc1base = $chunk->peek(1) && return $self;

	if (
		$t->{orth} =~ /^(vi|div|liv|lix|mix|mdi|mmi|mm+|cm|dm|i|c|l|d)$/i
	) {
		return $self;
	}

	$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
	$t->{pos} = 'RG';
	$t->{morph} = 'NOM';

	return $self;
}
#**************************************************************#
# markRoman_6
#
# Roman number preceeded by name.
# TEST	Karl XII
#**************************************************************#
sub markRoman_6 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	my $roman = $t->{orth};
#	my $ending = 'DEFAULT';
#
#	# Remove ending
#	if ( $t->{orth} =~ /^([$romanLetters]+)($MTM::Vars::romanEnding)$/i ) {
#		$roman = $1;
#		$ending = $2;
#	}
	if (
		&MTM::Legacy::isRoman( $roman )
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	if (
		$roman =~ /^[MLCDXVI][MLCDXVI]+$/
		&&
		$lc1->{pos} eq 'DEL'
		&&
		$lc2->{pos} =~ /PM/
		#$lc2->{orth} =~ /Peder/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
		if( $MTM::Vars::lang eq 'sv' ) {
			$lc1->{exp} = 'den';
			$t->{pos} = 'RO';
			$t->{morph} = 'NOM';
		}
	}

	return $self;
}
#**************************************************************#
# markRoman_7
#
# "I", "VI" and "X" only allowed if preceeded by "notreferens".
#
# TEST	notreferens I
#**************************************************************#
sub markRoman_7 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	if (
		(
			( $lc2->{orth}	=~	/^notreferens$/i && $MTM::Vars::lang eq 'sv' )
			#||
			#( $lc2->{orth}	=~	/^notreferens$/i && $MTM::Vars::lang eq 'en' )
		)
		&&
		$lc1->{pos}	eq	'DEL'
		&&
		$t->{orth}	=~ 	/^[xvi]+$/i	# not too high numbers
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
	}

	return $self;
}
#**************************************************************#
# markRoman_8
#
# Genitives
#
# TEST	III:s
#**************************************************************#
sub markRoman_8 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	#my $lc2base = $chunk->peek(-2) or return $self;
	#my $lc1base = $chunk->peek(-1) or return $self;

	# Find locations
	#my $lc1 = $lc1base->{LEGACYDATA};
	#my $lc2 = $lc2base->{LEGACYDATA};

	if (
		#( $t->{orth} =~ /^([^xvi]+):($MTM::Vars::sv_roman_ending)$/i && $MTM::Vars::lang eq 'sv' )
		#||
		#( $t->{orth} =~ /^([^xvi]+):($MTM::Vars::en_roman_ending)$/i && $MTM::Vars::lang eq 'en' )
		$t->{orth} =~ /^([xvi]+):s$/i && $MTM::Vars::lang eq 'sv'
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN');
		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';
	}

	return $self;
}
#**************************************************************#
sub insertRomanEnding {	# return: markup

	my $self = shift;
	my $savedEnding = shift;
	my $t = $self->{LEGACYDATA};

	# Re-tag roman ordinals
	if (
		$savedEnding =~ /^($MTM::Vars::sv_roman_ordinal_ending)$/i
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ROMAN ORDINAL');
		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';

	}

	# Re-tag roman genitives
	if (
		( $savedEnding =~ /^($MTM::Vars::sv_roman_genitive_ending)$/i && $MTM::Vars::lang eq 'sv' )
		||
		( $savedEnding =~ /^($MTM::Vars::en_roman_genitivie_ending)$/i && $MTM::Vars::lang eq 'en' )
	) {
		# This one destroys ordinal roman numbers:	&insertPos( $index, 'RG' );	# OO CHANGE 201106
		$t->{morph} = 'GEN';
	}


	# Put the ending back in orthography
	# CT 2020-11-19	This must be changed, we never change {orth}!!!
	$t->{orth} = $savedEnding;

	return $self;
}
#************************************************#
1;
