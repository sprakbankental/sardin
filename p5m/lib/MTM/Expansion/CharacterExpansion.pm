package MTM::Expansion::CharacterExpansion;

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
# Character
#
# Language	sv_se
#
# Rules for character expansions.
#
# Return: expansions
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub expand {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# Cancel if expansion field is not default
	if (
		&MTM::Legacy::isDefault( $t->{exp} )
		&&
		$t->{pos} ne 'DEL'
	) {
		# continue
	} else {
		return 0;
	}

	if ( $t->{exprType}		=~ /FRACTION/ ) {
		&expandFraction( $self, $chunk );

	# 210629	Do we need this?
	#} elsif ( $t->{orth}		  	=~	/^(\…|\.\.\.+)$/ ) {	# ellipsis
	#	&expandEllipsis( $self, $chunk );

	} elsif ( $t->{orth}		eq	',' ) {	# comma
		&expandComma( $self, $chunk );

	} elsif ( $t->{orth}		eq	'.' ) {	# period
		&expandPeriod( $self, $chunk );

	} elsif ( $t->{orth}			eq	'×' ) {	# multiplier	080612 '·' removed - same char as list thingy
		&expandMultiplier( $self, $chunk );

	} elsif ( $t->{orth} eq '+' ) {	# plus sign
		&expandPlus( $self, $chunk );

	} elsif ( $t->{orth} eq '-' ) {	# minus sign/dash/hyphen
		&expandDash( $self, $chunk );

	} elsif ( $t->{orth} eq '/' ) {	# slash
		&expandSlash( $self, $chunk );

	} elsif ( $t->{orth} eq '?' ) {	# question mark
		&expandQuestionMark( $self, $chunk );

	} elsif ( $t->{orth} eq '!' ) {	# exclamation mark
		&expandExclamationMark( $self, $chunk );

	} elsif ( $t->{orth}		 		=~ 	/^\§+$/ ) {	# paragraph/section sign	200525 added ^$
		&expandSectionSign( $self, $chunk );

	} elsif ( $t->{orth} eq '@' ) {	# at sign
		&expandAtSign( $self, $chunk );

	} elsif ( $t->{orth} eq '%' ) {	# percent
		&expandPercent( $self, $chunk );

	} elsif ( $t->{orth} eq '‰' ) {	# permille
		&expandPermille( $self, $chunk );

	} elsif ( $t->{orth}		  	=~ 	/^(?:\&|\&amp\;)$/ ) {	# ampersand
		&expandAmpersand( $self, $chunk );

	} elsif ( $t->{orth} eq '=' ) {	# equal sign
		&expandEqualSign( $self, $chunk );

	} elsif ( $t->{orth} eq ':' ) {	# colon
		&expandColon( $self, $chunk );

	#} elsif ( $t->{orth} eq ';' ) {	# semicolon	CT 2020-11-29 Not used.
	#	&expandSemicolon( $self, $chunk );

	} elsif ( $t->{orth}		 		=~ 	/\\/ ) {	# backslash
		&expandBackslash( $self, $chunk );

	#**************************************************************#
	# Brackets and quotes
	#**************************************************************#
	} elsif ( $t->{orth}		=~ /^\($/ ) {	# parentheses
		&expandParenthesis( $self, $chunk );

#	} elsif ( $t->{orth}		=~ /^[\[\]]$/ ) {	# square bracket
#		&square_bracket_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth}  =~ /^[\{\}]$/ ) {	# curly bracket
#		&curly_bracket_expansion( $self, $chunk );
#
	} elsif ( $t->{orth}  =~ /^(?:[$MTM::Vars::doubleQuote]|\&quot\;|\')$/ ) {	# double quote
		&expandDoublequote( $self, $chunk );

#	} elsif ( $t->{orth}  =~ /^\'$/ ) {	# single quote
#		&singlequote_expansion( $self, $chunk );
#
	#**************************************************************#
	# Currency symbols
	#**************************************************************#
	} elsif ( $t->{orth}  =~ /\$/ ) {	# dollar sign
		&expandDollar( $self, $chunk );

	} elsif ( $t->{orth} eq '£' ) {	# pound
		&expandPound( $self, $chunk );

	} elsif ( $t->{orth} eq '€' ) {	# euro
		&expandEuro( $self, $chunk );

	} elsif ( $t->{orth} eq '¥' ) {	# yen
		&expandYen( $self, $chunk );

	} elsif ( $t->{orth} eq '¢' ) {	# cent
		&expandCent( $self, $chunk );

	#**************************************************************#
	#
	#**************************************************************#
	} elsif ( $t->{orth} eq '~' ) {	# tilde
		&expandTilde( $self, $chunk );

	} elsif ( $t->{orth}  =~ /^\*\*?$/ ) {	# asterisk
		&expandAsterisk( $self, $chunk );

#	} elsif ( $t->{orth}  =~ /^(?:<|\&lt\;)$/ ) {	# less than sign
#		&less_than_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth}  =~ /^(?:>|\&gt\;)$/ ) {	# greater than sign
#		&greater_than_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth} eq '|' ) {	# vertical bar
#		&vertical_bar_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth} eq '_' ) {	# underscore
#		&underscore_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth} eq '^' ) {	# caret
#		&caret_expansion( $self, $chunk );
#
	} elsif ( $t->{orth}		 	=~	/^([º°])$/ ) {	# degree
		&expandDegree( $self, $chunk );

#	} elsif ( $t->{orth} eq '¿' ) {	# inverted question mark
#		&inverted_expandQuestionMark( $self, $chunk );
#
	} elsif ( $t->{orth} eq '©' ) {	# copyright
		&expandCopyright( $self, $chunk );
#
#	} elsif ( $t->{orth} eq '#' ) {	# number sign
#		&number_sign_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth} eq '•' ) {	# bullet
#		&bullet_expansion( $self, $chunk );
#
#	} elsif ( $t->{orth} eq '·' ) {	# bullet
#		&bullet_expansion( $self, $chunk );

	} elsif ( $t->{orth} eq '±' ) {	# plus-minus sign
		&expandPlusMinus( $self, $chunk );

	} elsif ( $t->{orth} eq '†' ) {	# dagger
		&expandDagger( $self, $chunk );


#	} elsif ( $t->{orth} eq '‡' ) {	# obelisk
#		&expansion();

#	} elsif ( $t->{orth} eq '¸' ) {	#
#		&expansion();

#	} elsif ( $t->{orth} eq '×' ) {	#
#		&_expansion( $self, $chunk );

#	# CT 110224
#	} elsif ( $t->{orth} eq '¹' ) {	#
#		$t->{exp} = 'i første';
#
#	} elsif ( $t->{orth} eq '²' ) {	#
#		$t->{exp} = 'i anden';
#
#	} elsif ( $t->{orth} eq '³' ) {	#
#		$t->{exp} = 'i tredje';

#	} elsif ( $t->{orth} eq '³' ) {	#
#		&expansion();


#	} elsif ( $t->{orth} eq '®' ) {	#
#		&expansion();

#	} elsif ( $t->{orth} eq '»' ) {	#
#		&_expansion( $self, $chunk );

	}
	return 1;
}
#**************************************************************#
# expandEllipsis
#**************************************************************#
sub expandEllipsis {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# More than three periods
	if (
		$t->{orth} =~ /\.\.\.\./ ) {
			$t->{pause} = $MTM::Vars::sentPause;
		}

	return $self;
}
#**************************************************************#
# expandComma
#**************************************************************#
sub expandComma {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Decimal commas	'12,5'
	if (
		$t->{exprType} =~ /(DECIMAL|CURRENCY)/
	) {
		$t->{exp} = $MTM::Vars::decimal_separator_word;

	}

	return $self;
}
#**************************************************************#
# expandPeriod
#**************************************************************#
sub expandPeriod {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc1base = $chunk->peek(1) or return $self;

	my $lc1_flag = 1;
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};

	# Decimal periods	'12.5'	'.66'
	if (
		$MTM::Vars::lang eq 'sv'
		&&
		$t->{exprType} =~ /(DECIMAL|EMAIL|URL|FILE)/
		&&
		$rc1->{exprType} =~ /(DECIMAL|EMAIL|URL|DOMAIN|FILE|ACRONYM)/
	) {
		$t->{exp} = $MTM::Vars::period_word;

		return $self;

	# English
	} elsif ( $MTM::Vars::lang eq 'en' ) {
		if (
			$t->{exprType} =~ /(DECIMAL)/
			&&
			$rc1->{exprType} =~ /(DECIMAL|EMAIL|URL|DOMAIN|FILE|ACRONYM)/
		) {
			$t->{exp} = $MTM::Vars::period_word;

			return $self;
		} elsif (
			$MTM::Vars::lang eq 'en'
			&&
			$t->{exprType} =~ /(EMAIL|URL|DOMAIN|FILE)/
			&&
			$rc1->{exprType} =~ /(DECIMAL|EMAIL|URL|DOMAIN|FILE|ACRONYM)/
		) {
			$t->{exp} = $MTM::Vars::period2_word;

			return $self;
		}
	}

	return $self;
}
#**************************************************************#
# expandMultiplier	×
#**************************************************************#
sub expandMultiplier {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Multiplier	'12·5'
	$t->{exp} = $MTM::Vars::times_word;

	return $self;
}
#**************************************************************#
# expandPlus
#**************************************************************#
sub expandPlus {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Maths			'5+4'
	if (
		$t->{exprType} eq 'MATHS'
	) {
		$t->{exp} = $MTM::Vars::plus_word;

	# Otherwhise (same)
	} else {
		$t->{exp} = $MTM::Vars::plus_word;
	}

	return $self;
}
#**************************************************************#
# expandDash (dash/minus/hyphen)
#**************************************************************#
sub expandDash {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $lc1_flag = 1;
	my $lc1;
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

	my $rc1_flag = 1;
	my $rc1;
	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;
#
#	# Maths			'5-4'
#	if (
#		$t->{exprType} eq 'MATHS'
# ) {
#		$t->{exp} = 'minus';	# translate!

	# Interval		'5-7 kap.'
	if (
		$t->{exprType} =~ /INTERVAL/
	) {
		$t->{exp} = $MTM::Vars::to_word;


	# Date: 2008-04-14
	} elsif (
		$t->{exprType} =~ /DATE/
	) {

		$t->{exp} =  $MTM::Vars::defaultExpansion;

	# ^-.				First in string.

	# .-.
	} elsif (
		&MTM::Legacy::isDefault( $t->{exprType} )
		&&
		$lc1_flag == 1
		&&
		$rc1_flag == 1
	) {
		my $lc1 = $lc1base->{LEGACYDATA};
		my $rc1 = $rc1base->{LEGACYDATA};

		if( $lc1->{orth} =~ /[a-zåäö\d]/i && $rc1->{orth} =~ /[a-zåäö\d]/i ) {
			$t->{exp} = $MTM::Vars::dash_word;
		}

	} elsif (
		$lc1_flag == 0
		&&
		$rc1_flag == 1
	) {
		# Find locations
		my $rc1 = $rc1base->{LEGACYDATA};

		if (
			$rc1->{orth} =~ /^(\.|\…)$/
	) {
			$t->{exp} = $MTM::Vars::defaultExpansion;
		}

	}

	# Else, insert pause (not if date, not if first in string)
	if (
		&MTM::Legacy::isDefault( $t->{exp} )
		&&
		$t->{exprType} !~ /DATE/
		&&
		$lc1_flag != 0
	) {
		$t->{exp} = $MTM::Vars::defaultExpansion;
		$t->{pause} = $MTM::Vars::shortPause;
	}

	return $self;
}
#**************************************************************#
# expandSlash
#**************************************************************#
sub expandSlash {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Maths			'20/5=4'
	if (
		$t->{exprType} eq 'MATHS'
	) {
		$t->{exp} = 'delat med';

	# Date: 25/4-1998
	} elsif (
		$t->{exprType} =~ /DATE/
		&&
		$MTM::Vars::lang eq 'sv'
	) {
		$t->{exp} = $MTM::Vars::in_word;

	} else {
		$t->{exp} = $MTM::Vars::slash_word;
	}

	return $self;
}
#**************************************************************#
# expandQuestionMark
#**************************************************************#
sub expandQuestionMark {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is?jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::question_mark_word;
	}

	return $self;
}
#**************************************************************#
# expandExclamationMark
#**************************************************************#
sub expandExclamationMark {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is!jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::exclamation_mark_word;

	} else {
		$t->{exp} = '-';
	}
	return $self;
}
#**************************************************************#
# expandSectionSign
#**************************************************************#
sub expandSectionSign {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $lc2_flag = 1;
	my $lc2base = $chunk->peek(-2) or $lc2_flag = 0;

	my $lc1_flag = 1;
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::section_sign_word;


	} elsif ( $t->{orth} =~ /\§\§/ ){
		$t->{exp} = $MTM::Vars::section_sign_def_plu_word;

	} else {

		$t->{exp} = $MTM::Vars::section_sign_word;


		# If numeral before, expand to 'paragrafen'	CT111221
		# 17§
		if (
			$lc1_flag == 1
	) {
			# Find locations
			my $lc1 = $lc1base->{LEGACYDATA};

			if (
				$lc1->{pos} =~ /^R[GO]/
		) {
				$t->{exp} = $MTM::Vars::section_sign_word_sin_def;

			# 17 §
			} elsif (
				$lc1->{pos}	eq	'DEL'
				&&
				$lc2_flag == 1
		) {
				# Find locations
				my $lc2 = $lc2base->{LEGACYDATA};

				if (
					$lc2->{pos} =~ /^R[GO]/
			) {
					$t->{exp} = $MTM::Vars::section_sign_word_sin_def;
				}
			}
		}

	}
	return $self;
}
#**************************************************************#
# expandAtSign
#**************************************************************#
sub expandAtSign {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if(
		$t->{exprType} =~ /EMAIL/
	) {
		$t->{exp} = $MTM::Vars::at_word;
	} else {
		$t->{exp} = $MTM::Vars::at_sign_word;
	}

	return $self;
}
#**************************************************************#
# expandPercent
#**************************************************************#
sub expandPercent {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# Email, URL:s and file names.	http://siej~is%jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::percent_sign_word;
	} else {
		$t->{exp} = $MTM::Vars::percent_word;
	}

	return $self;
}
#**************************************************************#
# expandPermille
#**************************************************************#
sub expandPermille {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::per_mille_sign_word;

	} else {
		$t->{exp} = $MTM::Vars::per_mille_word;
	}

	return $self;
}
#**************************************************************#
# expandAmpersand
#**************************************************************#
sub expandAmpersand {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is&jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::ampersand_word;

	# As conjunction		Kalle & lisa
	} else {
		$t->{exp} = $MTM::Vars::and_word;
	}

	return $self;
}
#**************************************************************#
# expandEqualSign
#**************************************************************#
sub expandEqualSign {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Maths			'7+8=15'
	# Use | as word limit	CT 110817
	$t->{exp} = $MTM::Vars::equals_word;

	return $self;
}
#**************************************************************#
# expandColon
#**************************************************************#
sub expandColon {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $lc1_flag = 1;
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

	my $rc1_flag = 1;
	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;

	# Do nothing if time expression
	return $self if $t->{exprType} =~ /TIME/;

	# In url:s and email addresses
	if (
		$t->{exprType} =~ /(?:EMAIL|URL|FILE|EXPAND)/
	) {
		$t->{exp} = $MTM::Vars::colon_word;
		# Between digits
	} elsif (
		$lc1_flag == 1
		&&
		$rc1_flag == 1
	) {
		# Find locations
		my $lc1 = $lc1base->{LEGACYDATA};
		my $rc1 = $rc1base->{LEGACYDATA};

		if (
			$lc1->{pos} =~ /RG/
			&&
			$rc1->{pos} =~ /RG/
		) {
			$t->{exp} = $MTM::Vars::colon_word;
			return $self;
		}
	}

	if (
		&MTM::Legacy::isDefault( $t->{exp} )
	) {
		# Otherwise pause.
		$t->{exp} = $MTM::Vars::defaultExpansion;
		$t->{pause} = $MTM::Vars::shortPause;

	}

	return $self;
}
#**************************************************************#
# expandSemicolon
#**************************************************************#
sub expandSemicolon {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self;
}
#**************************************************************#
# expandBackslash
#**************************************************************#
sub expandBackslash {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Also 'backstreck'	https://terminologiframjandet.se/h552a9FtZ/tnc.se/termfraga/backslash/
	$t->{exp} = $MTM::Vars::backslash_word;

	return $self;
}
#**************************************************************#
# expandParenthesis
#**************************************************************#
sub expandParenthesis {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $expanded = 0;

	if (
		&MTM::Legacy::isDefault( $t->{pause} )

	) {
		# Find the closest parenthesis in right context. Start at opening parenthesis.
		my( $endLocation, $rc ) = &getEndLocation( $self, $chunk, ')' );

		# print STDERR "\n\texpandParenthesis\t$endLocation\t$t->{orth}\n\n";

		# No closing found, insert short pause at current location.
		if (
			$endLocation eq 'notFound'
	) {
			$t->{pause} = $MTM::Vars::shortPause;

		# If more than 2 words within parentheses
		##### TODO Put $endLocation value in variable.
		} elsif( $MTM::Vars::use_announcements == 1 && $endLocation >= 3 ) {
			$t->{exp} = $MTM::Vars::parenthesisStartPhrase;
			$t->{pause} = $MTM::Vars::announcementPause;

			$rc->{exp} = $MTM::Vars::parenthesisEndPhrase;
			$rc->{pause} = $MTM::Vars::announcementPause;

		} else {
			$t->{pause} = $MTM::Vars::shortPause;
			$rc->{pause} = $MTM::Vars::shortPause;
		}

	}

	return $self;
}
#**************************************************************#
# square_bracket_expansion
# same as above
#**************************************************************#
sub square_bracket_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self;
}
#**************************************************************#
# curly_bracket_expansion
#**************************************************************#
sub curly_bracket_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self;
}
#**************************************************************#
# expandTilde
#**************************************************************#
sub expandTilde {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::tilde_word;
		$t->{pos} = 'NN NEU SIN IND NOM' if $MTM::Vars::lang eq 'sv';

	} else {
		$t->{exp} = '-';
		$t->{pos} = 'NN NEU SIN IND NOM' if $MTM::Vars::lang eq 'sv';
	}

	return $self;
}
#**************************************************************#
# expandAsterisk
#
# TEST:	*2010	* 2010
#**************************************************************#
sub expandAsterisk {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc1_flag = 1;
	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;

	my $rc2_flag = 1;
	my $rc2base = $chunk->peek(2) or $rc2_flag = 0;

	# *2010
	if (
		$rc1_flag == 1
	) {
		# Find locations
		my $rc1 = $rc1base->{LEGACYDATA};

		if (
			$rc1->{exprType} =~ /(DATE|YEAR)/
	) {
			$t->{exp} = $MTM::Vars::born_word;

		# * 2010
		} elsif (
			$rc2_flag == 1
	) {
			# Find locations
			my $rc2 = $rc2base->{LEGACYDATA};

			if (
				$rc2->{exprType} =~ /(DATE|YEAR)/
		) {
				$t->{exp} = $MTM::Vars::born_word;
			}
		}
	}

	if (
		&MTM::Legacy::isDefault( $t->{exp} )
	) {
		if ( $t->{orth} eq '*' ) {
			$t->{exp} = 'asterisk';

		} elsif ( $t->{orth} eq '**' ) {
			$t->{exp} = 'asterisk asterisk';
		}
	}

	return $self;
}
#**************************************************************#
# expandDoublequote
#**************************************************************#
sub expandDoublequote {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $expanded = 0;

	if (
		&MTM::Legacy::isDefault( $t->{pause} )
		&&
		&MTM::Legacy::isDefault( $t->{exp} )
		) {
		# Find the closest quote in right context
		my( $endLocation, $rc ) = &getEndLocation( $self, $chunk, '"' );

		# No closing found, insert short pause at current location.
		if (
			$endLocation eq 'notFound'
			) {
			$t->{pause} = $MTM::Vars::shortPause;

		# If more than 2 words within double quotes
		} elsif( $MTM::Vars::use_announcements == 1 && $endLocation >= 3 ) {
			$t->{exp} = $MTM::Vars::doubleQuoteStartPhrase;
			$t->{pause} = $MTM::Vars::announcementPause;

			$rc->{exp} = $MTM::Vars::doubleQuoteEndPhrase;
			$rc->{pause} = $MTM::Vars::announcementPause;

		} else {
			$t->{pause} = $MTM::Vars::shortPause;
			$rc->{pause} = $MTM::Vars::shortPause;
		}
	}

	return $self;
}
#*******************************************************************************#
# getEndLocation
#
# Return: location of closing parenthesis, quote etc. (or 'notFound')
#
#
#*******************************************************************************#
##### TODO Move this to more common code chunk and rename: findInRC or something better.	CT 2020-11-29
sub getEndLocation {

	my $self = shift;
	my $chunk = shift;
	my $unit = shift;

	my $t = $self->{LEGACYDATA};

	my $rcCounter = 0;
	my $endFound = 0;

	# Add 1 to rc counter when searching
	my $i = 0;	# Every item counts.
	my $j = 0;	# Blanks and delimiters do not count.


	# 1. Check if context exists
	while( defined( $chunk->peek($i+1))) {
		my $rc_base = $chunk->peek($i + 1) or return $self;

		# Find locations
		my $rc = $rc_base->{LEGACYDATA};

		#print STDERR "getEndLocation\t$rc->{orth}\t$unit\t$i\t$j\n";


		if( $rc->{orth} eq $unit ) {
			#print STDERR "YES!\t$rc->{orth}\t$unit\t$i\t$j\n";

			return( $j, $rc );
		} else {
			$i++;

			# Do not count blanks or delimiters
			if (
				$rc->{pos} !~ /^(DEL|DL)$/	##### TODO We need to be consequent with this, 'DEL' or 'DL'.	CT 2020-11-29
		) {
				$j++;
			}
		}
	}

	# If no closing unit was found, return 'notFound'
	return 'notFound';
}
#**************************************************************#
# singlequote_expansion
#**************************************************************#
sub singlequote_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};
	$t->{exp} = '-';

	return $self;
}
#**************************************************************#
# expandDollar
#**************************************************************#
sub expandDollar {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::dollar_sign_word;

	} else {

		# Add $dollar_word to expansion that already has a numeral expansion
		if ( $t->{exp} eq '1' ) {
			$t->{exp} = $MTM::Vars::dollar_sin_word;
		} elsif ( $t->{exp} =~ /<\d+>/ ) {
			$t->{exp} = $MTM::Vars::dollar_plu_word;
		} else {
			$t->{exp} = $MTM::Vars::dollar_sin_word;
		}

		$t->{pos} = 'NN';
		$t->{morph} = 'UTR - IND NOM' if $MTM::Vars::lang eq 'sv';
	}

	return $self;
}
#**************************************************************#
# expandPound
#**************************************************************#
sub expandPound {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::pound_sign_word;

	} else {

		# Add $pound_word to expansion that already has a numeral expansion
		if ( $t->{exp} eq '1' ) {
			$t->{exp} = $MTM::Vars::pound_sin_word;
		} elsif ( $t->{exp} =~ /<\d+>/ ) {
			$t->{exp} = $MTM::Vars::pound_plu_word;
		} else {
			$t->{exp} = $MTM::Vars::pound_sin_word;
		}

		$t->{pos} = 'NN';
		$t->{morph} = 'NEU - IND NOM' if $MTM::Vars::lang eq 'sv';
	}

	return $self;
}
#**************************************************************#
# expandEuro
#**************************************************************#
sub expandEuro {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::euro_sign_word;

	} else {

		# Add $euro_word to expansion that already has a numeral expansion
		if ( $t->{exp} eq '1' ) {
			$t->{exp} = $MTM::Vars::euro_sin_word;
		} elsif ( $t->{exp} =~ /<\d+>/ ) {
			$t->{exp} = $MTM::Vars::euro_plu_word;
		} else {
			$t->{exp} = $MTM::Vars::euro_sin_word;
		}

		$t->{pos} = 'NN';
		$t->{morph} = 'UTR - IND NOM' if $MTM::Vars::lang eq 'sv';
	}

	return $self;
}
#**************************************************************#
# expandYen
#**************************************************************#
sub expandYen {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::yen_sign_word;

	} else {

		# Add $yen_word to expansion that already has a numeral expansion
		if ( $t->{exp} eq '1' ) {
			$t->{exp} = $MTM::Vars::yen_sin_word;
		} elsif ( $t->{exp} =~ /<\d+>/ ) {
			$t->{exp} = $MTM::Vars::yen_plu_word;
		} else {
			$t->{exp} = $MTM::Vars::yen_sin_word;
		}

		$t->{pos} = 'NN';
		$t->{morph} = 'UTR - IND NOM' if $MTM::Vars::lang eq 'sv';
	}

	return $self;
}
#**************************************************************#
# expandCent
#**************************************************************#
sub expandCent {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Email, URL:s and file names.	http://siej~is§jksjf.com
	if (
		$t->{exprType} =~ /(EMAIL|URL|FILE)/
	) {
		$t->{exp} = $MTM::Vars::cent_sign_word;

	} else {

		# Add $cent_word to expansion that already has a numeral expansion
		if ( $t->{exp} eq '1' ) {
			$t->{exp} = $MTM::Vars::cent_sin_word;
		} elsif ( $t->{exp} =~ /<\d+>/ ) {
			$t->{exp} = $MTM::Vars::cent_plu_word;
		} else {
			$t->{exp} = $MTM::Vars::cent_sin_word;
		}

		$t->{pos} = 'NN';
		$t->{morph} = 'NEU - IND NOM' if $MTM::Vars::lang eq 'sv';
	}

	return $self;
}
#**************************************************************#
# less_than_expansion
#**************************************************************#
sub less_than_expansion {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Maths			'3 < 4'
	if (
		$t->{exprType}	eq	'MATHS'
	) {
		$t->{exp} = $MTM::Vars::less_than_word;

	} else {
		$t->{exp} = $MTM::Vars::less_than_sign_word;
		###$t->{pron} = "m \"i n: d r ë - ä n: - t \`e k: ë n";	##### Pronunciation shouldn't be inserted at this stage!
	}

	return $self;
}
#**************************************************************#
# greater_than_expansion
#**************************************************************#
sub greater_than_expansion {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Maths			'4 > 3'
	if (
		$t->{exprType}	eq	'MATHS'
	) {
		$t->{exp} = $MTM::Vars::greater_than_word;

	} else {
		$t->{exp} = $MTM::Vars::greater_than_sign_word;
		###$t->{pron} = "s t \"ö r: ë - ä n: - t \`e k: ë n";	##### Pronunciation shouldn't be inserted at this stage!
	}

	return $self;
}
#**************************************************************#
# vertical_bar_expansion
#**************************************************************#
sub vertical_bar_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	$t->{exp} = $MTM::Vars::vertical_bar_word;
	$t->{pos} = 'NN';
	$t->{morph} = 'NEU SIN IND NOM' if $MTM::Vars::lang eq 'sv';

	return $self;
}
#**************************************************************#
# underscore_expansion
#**************************************************************#
sub underscore_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	$t->{exp} = $MTM::Vars::underscore_word;
	$t->{pos} = 'NN';
	$t->{morph} = 'NEU SIN IND NOM' if $MTM::Vars::lang eq 'sv';

	return $self;
}
#**************************************************************#
# caret_expansion
#**************************************************************#
sub caret_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self;
}
#**************************************************************#
# expandDegree
#**************************************************************#
sub expandDegree {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) or return $self;

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};


	# 12 grader
	if ( $lc1->{pos} =~ /RG/ ) {

		if( $lc1->{orth} ne '1' ) {
			$t->{exp} = $MTM::Vars::degrees_word;
			$t->{pos} = 'NN';
			$t->{morph} = 'UTR PLU IND NOM' if $MTM::Vars::lang eq 'sv';
		} else {
			$t->{exp} = $MTM::Vars::degree_word;
			$t->{pos} = 'NN';
			$t->{morph} = 'UTR SIN IND NOM' if $MTM::Vars::lang eq 'sv';
		}
	}

	return $self;
}
#**************************************************************#
# inverted_expandQuestionMark
#**************************************************************#
sub inverted_expandQuestionMark {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self;
}
#**************************************************************#
# expandCopyright
#**************************************************************#
sub expandCopyright {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	$t->{exp} = 'copyright';

	return $self;
}
#**************************************************************#
# number_sign_expansion
#**************************************************************#
sub number_sign_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self;
}
#**************************************************************#
# bullet_expansion
#**************************************************************#
sub bullet_expansion {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if ( $t->{exprType} =~ /MATHS/ ) {
		$t->{exp} = 'gånger';
	}

	return $self;
}
#**************************************************************#
# expandPlusMinus
#**************************************************************#
sub expandPlusMinus {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	$t->{exp} = 'plus|minus';

	return $self;
}
#**************************************************************#
# expandDagger
#
# TEST:	†2010	† 2010
#**************************************************************#
sub expandDagger {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc1_flag = 1;
	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;

	my $rc2_flag = 1;
	my $rc2base = $chunk->peek(2) or $rc2_flag = 0;

	# †2010
	if (
		$rc1_flag == 1
	) {
		# Find locations
		my $rc1 = $rc1base->{LEGACYDATA};
		if (
			$rc1->{exprType} =~ /(DATE|YEAR)/
	) {
			$t->{exp} = $MTM::Vars::dead_word;

		# † 2010
		} elsif (
			$rc2_flag == 1
	) {
			# Find locations
			my $rc2 = $rc2base->{LEGACYDATA};

			if (
				$rc2->{exprType} =~ /(DATE|YEAR)/
		) {
				$t->{exp} = $MTM::Vars::dead_word;
			}
		}
	}

	if (
		&MTM::Legacy::isDefault( $t->{exp} )
	) {
		$t->{exp} = $MTM::Vars::dagger_word
	}

	return $self;
}
#**************************************************************#
# 1 ¼	1¼	1/2	¼
sub expandFraction {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $orth = $t->{orth};

	my $lc1_flag = 1;
	my $lc1;
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

	my $rc2_flag = 1;
	my $rc2;
	my $rc2base = $chunk->peek(2) or $rc2_flag = 0;

	#print "rc2_flag $rc2_flag\t$t->{orth}\n";

	# Flag if it is a word part - needs return later
	my $part = 0;

	if (
		$t->{orth} =~ /\-(?:$MTM::Vars::fraction)/
		||
		$t->{orth} =~ /(?:$MTM::Vars::fraction)\-/
	) {
		$orth =~ s/^.*(?:$MTM::Vars::fraction).*$/$1/;
		$part = 1;
	}

	# 1/2	½
	if (
		$orth =~ /^(1\/2|½)$/
	) {
		$t->{exp} = $MTM::Vars::a_half_word_utr;

		# Check gender
		# 1. Check if context exists
		#my $rc2base = $chunk->peek(2) or return $self;

		if( $rc2_flag == 1 ) {

			# Find locations
			my $rc2 = $rc2base->{LEGACYDATA};

			#print STDERR "GENDER $rc2->{orth}\t$rc2->{pos}\t$rc2->{morph}\n";

			if ( $rc2->{morph} =~ /NEU/ ) {
				$t->{exp} = $MTM::Vars::a_half_word_neu;
			}
		}

	} elsif (
		$orth =~ /^(1\/4|¼)$/
	) {
		$t->{exp} = $MTM::Vars::one_quarter_word;

	} elsif (
		$orth =~ /^(3\/4|\¾)$/

	) {
		$t->{exp} = $MTM::Vars::three_quarters_word;
	}

	return $self if $lc1_flag == 0;

	$lc1 = $lc1base->{LEGACYDATA};
	if( $lc1->{orth} =~ /^\d$/ ) {
		$t->{exp} =~ s/^(.+)$/$MTM::Vars::and_word\|$1/;
		return $self;
	}


	# 1. Check if context exists	1 ½
	my $lc2base = $chunk->peek(-2) or return $self;

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};

	# Check if there is a numeral to the left
	if (
		$lc1->{orth} eq ' '
		&&
		$lc2->{orth} =~ /^\d+$/
	) {
		$t->{exp} =~ s/^(.+)$/$MTM::Vars::and_word\|$1/;
	}

	return $self;
}
#**************************************************************#
1;
