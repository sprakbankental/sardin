package MTM::Analysis::Abbreviation;

#*******************#
# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings   qw< FATAL  utf8 >;
use open       qw< :std  :utf8 >;
use charnames  qw< :full :short >;
use feature    qw< unicode_strings >;
no feature     qw< indirect >;	  
use feature    qw< signatures >;
no warnings    qw< experimental::signatures >;

#**************************************************************#
# Abbreviation
#
# Language	sv_se
#
# Rules for marking abbreviations.
# 
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $orth = quotemeta( $t->{orth} );
	#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
		utf8::encode( $orth );
	#}

	# Case sensitive list
	if (
		# Field is blocked, e.g. when '§' or 'kap.' are moved to beginning of law reference expression.
		$t->{exp} ne '<none>'
		&&
		(
			$MTM::Vars::lang eq 'sv'
			&&
			(
				exists( $MTM::Legacy::Lists::sv_abbreviation{ $orth } )
				||
				exists( $MTM::Legacy::Lists::sv_abbreviation_case{ $orth } )
				||
				# s. 14
				$orth =~ /^s\\\.?$/
			)
		) || (
			$MTM::Vars::lang eq 'en'
			&&
			(
				exists( $MTM::Legacy::Lists::en_abbreviation{ $orth } )
				||
				exists( $MTM::Legacy::Lists::en_abbreviation_case{ $orth } )
				||
				# p. 14
				$orth =~ /^p\\\.?$/
			)
		)
	) {
		&expand_abbreviation( $self, $chunk );
	}
	return $self;
}
#**************************************************************#
# TEST:	Hundar, katter, m.m.
#**************************************************************#
sub expand_abbreviation {

	my $self = shift; 
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my ( $exps, $rule, $mayEndSentence );

	my $orth = $t->{orth};
	$orth = quotemeta( $orth );

	# English
	if ( $MTM::Vars::lang eq 'en' ) {
		if(
			exists( $MTM::Legacy::Lists::en_abbreviation{ $orth } )
		) {
			( $exps, $rule, $mayEndSentence ) = split/\t/, $MTM::Legacy::Lists::en_abbreviation{ $orth };

		} elsif (
			exists( $MTM::Legacy::Lists::en_abbreviation_case{ $orth } )
		) {
			( $exps, $rule, $mayEndSentence ) = split/\t/, $MTM::Legacy::Lists::en_abbreviation_case{ $orth };
		# s. 15
		} elsif (
			$orth =~ /^p\\\.?$/
		) {
			$exps = 'page';
			$rule = 'SPECIAL';
			$mayEndSentence = 0;
		}
	# Swedish and world
	} else {
		if(
			exists( $MTM::Legacy::Lists::sv_abbreviation{ $orth } )
		) {
			( $exps, $rule, $mayEndSentence ) = split/\t/, $MTM::Legacy::Lists::sv_abbreviation{ $orth };

		} elsif (
			exists( $MTM::Legacy::Lists::sv_abbreviation_case{ $orth } )
		) {
			( $exps, $rule, $mayEndSentence ) = split/\t/, $MTM::Legacy::Lists::sv_abbreviation_case{ $orth };
		# s. 15
		} elsif (
			$orth =~ /^s\\\.?$/
		) {
			$exps = 'sidan';
			$rule = 'SPECIAL';
			$mayEndSentence = 0;
		}
	}

	# Do not expand if $mayEndSentence == 1 and word is sentence final.
	# Det är ang. detta som ang.
	# TODO: Better way to check if it's sentence final.
	if( $mayEndSentence == 1 ) {
		my $rc1base = $chunk->peek(1) or return $self;	# Nothing in right context
		my $rc1 = $rc1base->{LEGACYDATA};

		return $self if $rc1->{orth} !~ /^($MTM::Vars::delimiter|$MTM::Vars::quote|\s)+$/;

	}

	### TODO: shouldn't be needed
	#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
		utf8::decode( $exps );
	#}

	my @exps = split/\|/, $exps;

	# The place in the expansion list that should be selected (void if none)
	my $exp_position = '0';

	my $lc2_flag = 1;
	my $lc2base = $chunk->peek(-2) or $lc2_flag = 0;

	my $rc2_flag = 1;
	my $rc2base = $chunk->peek(2) or $rc2_flag = 0;

	# A rule exists
	if (
		$rule =~ /Rule/i
	) {
		# digit LC/RC
		if ( $rule =~ /LCorRCdigit/i ) {
			$exp_position = &lc_or_rc_digit_rule( $self, $chunk, $rule );
		# digit rules
		} elsif ( $rule =~ /LCdigit/i ) {
			$exp_position = &lc_digit_rule( $self, $chunk, $rule );
		} elsif ( $rule =~ /RCdigit/i ) {
			$exp_position = &rc_digit_rule( $self, $chunk, $rule );
		# cardinal/ordinal rule
		} elsif ( $rule =~ /cardOrd/i ) {
			$exp_position = &card_ord_rule( $self, $chunk, $rule );

		# numerus rule: singular or plural
		} elsif ( $lc2_flag == 1 && $rule =~ /numerusRule/i ) {
			my $lc2 = $lc2base->{LEGACYDATA};
			$exp_position = &numerus_rule( $lc2->{orth} );

		# abbreviation_rule_3
		} elsif ( $rc2_flag == 1 && $rule =~ /abbreviation_rule_3/i ) {
			my $rc2 = $rc2base->{LEGACYDATA};
			$exp_position = &abbreviation_rule_3( $rc2->{morph} );
		}

	# Special rules
	} elsif ( $rule =~ /SPECIAL/i ) {
		# st.|st
		if ( $t->{orth} =~ /^st\.?$/ ) {
			$exp_position = &expand_st( $self, $chunk );
		}
	}

	# Get the selected expansion
	if (
		# Not an abbreviation - remove textType
		$exp_position eq 'void'
	) {
		$t->{textType} = $MTM::Vars::defaultTextType;
		$t->{exp} = $MTM::Vars::defaultExpansion;

	} else {
		$t->{textType} = 'ABBREVIATION';
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ABBREVIATION' );

		my $exp = $exps[ $exp_position ];

		# 210927
		#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
			#utf8::decode( $exp );
		#}

		$t->{exp} = $exp;
	}
	return $self;
}
#**************************************************************#
# CT 200520
#
# Return: expansion position in list
#**************************************************************#
sub card_ord_rule {

	my $self = shift; 
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Check if a digit precedes
	# 1. Check if context exists
	my $lc2_flag = 1;
	my $lc2base = $chunk->peek(-2) or return $lc2_flag = 0;

	if( $lc2_flag == 1 ) {
		# Find locations
		my $lc2 = $lc2base->{LEGACYDATA};

		if(
			$lc2->{pos} =~ /^R[GO]/
		) {
			# Select the second expansion
			return 1;
		}
	}

	# Check if a digit follows
	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return 2;

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};

	if(
		$rc2->{pos} =~ /^R[GO]/
	) {
		# Select the first expansion
		return 0;
	}

	# Else, select the third alternative 
	return 2;
}
#**************************************************************#
# $MTM::Vars::fraction added	CT 120614
#
# TEST	1 1/2
#
# Return: expansion position in list
#**************************************************************#
sub lc_digit_rule {

	my $self = shift; 
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $rule = shift;

	# Check if a digit precedes
	# 1. Check if context exists
	my $lc1_flag = 1;
	my $lc1base = $chunk->peek(-1) or return $lc1_flag = 0;

	my $lc2_flag = 1;
	my $lc2base = $chunk->peek(-2) or return $lc2_flag = 0;

	if (
		$lc1_flag == 1
	) {
		# continue
	} else {
		# Do not expand the abbreviation
		return 'void';
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};

	# 
	if (
		$lc1->{pos} =~ /RG/
		||
		$lc1->{orth} =~ /^\d+\/\d$/
		||
		$lc1->{orth} =~ /(½|$MTM::Vars::fraction)$/

	) {
		my $exp_position = 0;
		if ( $rule =~ /numerusrule/i ) {
			$exp_position = &numerus_rule( $lc1->{orth} );
			return $exp_position;
		} else {
			# Select the first expansion
			return '0';
		}
	# LC2
	} elsif (
		$lc2_flag == 1
		&&
		$lc1->{pos} eq 'DEL'
	) {
		# Find locations
		my $lc2 = $lc2base->{LEGACYDATA};

		if (
			$lc2->{pos} =~ /R[GO]/
			||
			$lc2->{orth} =~ /^(\d+\/\d)$/
			||
			$lc1->{orth} =~ /($MTM::Vars::fraction)$/
		) {
			my $exp_position = 0;
			if ( $rule =~ /numerusrule/i ) {
				$exp_position = &numerus_rule( $lc2->{orth} );

				return $exp_position;
			} else {
				# Select the first expansion
				return '0';
			}
		}
	}

	# No rule was applied, return 'void'
	return 'void';
}
#**************************************************************#
# RCdigitRule
#
# Return: expansion position in list
#**************************************************************#
sub RCdigitRule {

	my $self = shift; 
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $rule = shift;

	# Check if a digit precedes
	# 1. Check if context exists
	my $rc1_flag = 1;
	my $rc1base = $chunk->peek(1) or return $rc1_flag = 0;

	my $rc2_flag = 1;
	my $rc2base = $chunk->peek(2) or return $rc2_flag = 0;

	if (
		$rc1_flag == 1
	) {
		# continue
	} else {
		# Do not expand the abbreviation
		return 'void';
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	# 
	if (
		$rc1->{pos} =~ /RG/
	) {
		my $exp_position = 0;

		if ( $rule =~ /numerusrule/i ) {
			$exp_position = &numerus_rule( $rc1->{orth} );
			return $exp_position;
		} else {
			# Select the first expansion
			return '0';
		}
	# RC2
	} elsif (
		$rc2_flag == 1
		&&
		$rc2->{pos} eq 'DEL'
	) {
		if (
			$rc2->{pos} =~ /R[GO]/
			||
			$rc2->{orth} =~ /^\d+\/\d$/
		) {
			my $exp_position = 0;
			if ( $rule =~ /numerusrule/i ) {
				$exp_position = &numerus_rule( $rc2->{orth} );
				return $exp_position;
			} else {
				# Select the first expansion
				return '0';
			}
		}
	}

	# No rule was applied, return 'void'
	return 'void';
}
#**************************************************************#
# Return: expansion position in list
#**************************************************************#
sub lc_or_rc_digit_rule {
	my $self = shift;
	my $chunk = shift;
	my $rule = shift;

	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return 'void';
	my $lc1base = $chunk->peek(-1) or return 'void';

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	# Left context is digits, check numerus and return
	if (
		$lc2->{orth} =~ /^\d+$/
		&&
		$lc1->{pos} eq 'DEL'
	) {
		# Check numerus
		my $exp_position = 0;
		if ( $rule =~ /numerusrule/i ) {
			$exp_position = &numerus_rule( $lc2->{orth} );
			return $exp_position;
		} else {
			# Select the first expansion
			return '0';
		}
	}

	# Right context is numerus
	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return 0;
	my $rc1base = $chunk->peek(1) or return 0;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	if (
		$rc2->{orth} =~ /^\d+$/
		&&
		$rc1->{pos} eq 'DEL'
	) {
		return '0';
	}

	return 'void';
}
#**************************************************************#
# Return: 1/0
#**************************************************************#
sub numerus_rule {
	my $orth = shift;

	if (
		$orth eq '1'
	) {
		return '0';
	} else {
		return '1';
	}
}
#**************************************************************#
# Return: 1/0
#**************************************************************#
sub abbreviation_rule_3 {
	my $morph = shift;

	if ( $morph =~ /PLU/ || $morph =~ /DEF/
	) {
		return 2;
	} elsif ( $morph =~ /NEU/ ) {
		return 1;
	} else {
		return 0;
	}
}
#**************************************************************#
# st.|st		stycket|stycken			SPECIAL	0	0
#**************************************************************#
sub expand_st {

	my $self = shift;
	my $chunk = shift;
	my $rule = shift;

	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) or return 0;

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};

	#***********************************************#
	# 1st.

	# If preceded by an ordinal --> stycket
	if ( exists( $lc1->{pos} )) {
		if (
			$lc1->{pos} =~ /RO/
		) {
			return '0';

		# If preceded by a cardinal --> stycken
		} elsif (
			$lc1->{pos} =~ /RG/
		) {
			$t->{morph} = '- PLU IND NOM';
			return '1';
		}
	}

	#***********************************************#
	# 1 st.

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return 0;

	if (
		$lc1->{pos} eq 'DEL'
	) {
		# continue
	} else {
		return '0';
	}

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};

	# print "expand_st\n\t$lc1->{pos}\n";

	# If preceded by a cardinal --> stycken
	if (
		$lc2->{pos} =~ /RG/
	) {
		$t->{morph} = '- PLU IND NOM';
		return '1';
	}

	# If preceded by an ordinal --> stycket
	return '0';
}
#**************************************************************#
1;
