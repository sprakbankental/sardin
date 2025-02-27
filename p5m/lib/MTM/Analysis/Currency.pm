package MTM::Analysis::Currency;

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
# Currency
#
# Language	sv_se
#
# Rules for marking and expanding currencies.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	&markCurrencyAfter( $self, $chunk );	# 18,99:-
	&markCurrencyAfterDEL( $self, $chunk );	# 18,99 :-
	&markCurrencyBefore( $self, $chunk );	# $12, €5.75
	&markCurrencyBeforeDEL( $self, $chunk );	# $ 12. € 5.75
	return $self;
}
#**************************************************************#
# markCurrencyAfter
#
# TEST	12,50:-	12kr.	12,50:-
#
#**************************************************************#
sub markCurrencyAfter {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# print STDERR "$t->{orth}\t$t->{pos}\t$t->{exprType}\n";

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) or return $self;

	# Current orthography is a currency
	if (
		$t->{orth} =~ /^($MTM::Vars::sv_currency_list|\$|\€|\£)$/i
		||
		$t->{orth} =~ /^($MTM::Vars::en_currency_list|\$|\€|\£)$/i
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};

	# CT 2020-11-24 Added flag to signal that lc3 exists.
	my $lc3_flag = 1;
	my $lc3;
	my $lc3base = $chunk->peek(-3) or $lc3_flag = 0;

	my $numerus;

	# Get currency
	my ( $currency, $currency2 ) = &getCurrency( $t->{orth} );

	# 12kr., 12,50:-
	if (
		$lc1->{pos} =~ /RG/
	) {
		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'CURRENCY' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'CURRENCY' );

		if (
			$lc3_flag == 1
		) {
			my $lc2base;
			$lc2base = $chunk->peek(-2);
			my $lc2 = $lc2base->{LEGACYDATA};
			my $lc3 = $lc3base->{LEGACYDATA};

			# LC3	LC2	LC1	CURRENT
			# 12	,	50	kr.
			if (
				(
					$lc2->{exprType} =~ /DECIMAL/
				) || (
					$lc3->{pos} eq 'RG'
					&&
					$lc2->{orth} =~ /^[\,\.]$/
				)
			) {

				$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'CURRENCY' );
				$lc3->{exprType} = MTM::Legacy::get_exprType( $lc3->{exprType}, 'CURRENCY' );

				$lc2->{pos} = 'NN';
				$t->{pos} = 'NN';

				# Expand cardinal 1
				$lc3->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $lc3->{orth}, $lc3->{exprType}, $lc3->{pos}, $lc3->{morph} );

				$lc3->{pos} = 'RG';
				$lc3->{morph} = 'NOM';

				# Insert currency expansion
				( $lc2->{exp}, $lc2->{morph} ) = &numerusCurrencyCheck( $lc3->{orth}, $currency );
				$lc2->{exp} .= "\|$MTM::Vars::and_word";

				# Expand cardinal 2
				$lc1->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $lc1->{orth}, $lc1->{exprType}, $lc1->{pos}, $lc1->{morph} );
				$lc1->{pos} = 'RG';
				$lc1->{morph} = 'NOM';

				$t->{exp} = $currency2;
				return $self;
			}
		}
	} else {
		return $self;
	}

	# Expand cardinal
	$lc1->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $lc1->{orth}, $lc1->{exprType}, $lc1->{pos}, $lc1->{morph} );
	$lc1->{pos} = 'RG';
	$lc1->{morph} = 'NOM';

	return $self;
}
#**************************************************************#
# markCurrencyAfterDEL
#
# TEST	12,50 :-	12 kr.
#
#**************************************************************#
sub markCurrencyAfterDEL {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;

	# Current orthography is a currency
	if (
		$t->{orth} =~ /^($MTM::Vars::sv_currency_list|\$|\€|\£)$/i
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1base = $chunk->peek(-1);
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc1base->{LEGACYDATA};

	# CT 2020-11-24 Added flag to signal that lc4 exists.
	my $lc4_flag = 1;
	my $lc4base = $chunk->peek(-4) or $lc4_flag = 0;

	# Get currency
	my ( $currency, $currency2 ) = &getCurrency( $t->{orth} );

	# print STDERR "C lc2 $lc2->{orth} $lc2->{pos}\tlc1 lc1->{orth}\tt $t->{orth}\n\n";

	# 12 kr., 12,50 :-
	if (
		$lc2->{pos} =~ /RG/
		&&
		$lc1->{orth} =~ /^ $/
	) {
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'CURRENCY' );
		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'CURRENCY' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'CURRENCY' );

		if (
			$lc4_flag == 1
		) {
			my $lc3base;
			$lc3base = $chunk->peek(-3);
			my $lc3 = $lc3base->{LEGACYDATA};
			my $lc4 = $lc4base->{LEGACYDATA};

			# print STDERR "C lc4 $lc4->{orth} $lc4->{pos}\tlc3 $lc3->{orth}\t		t $t->{orth}\n\n";

			# LC4	LC3	LC2	LC1	CURRENT
			# 12	,	50	_	kr.
			if (
				$lc3->{orth} =~ /^[\,\.]$/
				&&
				$lc4->{pos} eq 'RG'
			) {
				$lc3->{exprType} = MTM::Legacy::get_exprType( $lc3->{exprType}, 'CURRENCY' );
				$lc4->{exprType} = MTM::Legacy::get_exprType( $lc4->{exprType}, 'CURRENCY' );

				$lc3->{pos} = 'NN';
				$t->{pos} = 'NN';

				# Expand cardinal 1
				$lc4->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $lc4->{orth}, $lc4->{exprType}, $lc4->{pos}, $lc4->{morph} );

				$lc4->{pos} = 'RG';
				$lc4->{morph} = 'NOM';

				# Insert currency expansion
				( $lc3->{exp}, $lc3->{morph} ) = &numerusCurrencyCheck( $lc4->{orth}, $currency );
				$lc3->{exp} .= "\|$MTM::Vars::and_word";

				# Expand cardinal 2
				$lc2->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $lc2->{orth}, $lc2->{exprType}, $lc2->{pos}, $lc2->{morph} );
				$lc2->{pos} = 'RG';
				$lc2->{morph} = 'NOM';

				$t->{exp} = $currency2;
				return $self;
			}
		}
	} else {
		return $self;
	}

	# Expand cardinal
	$lc2->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $lc2->{orth}, $lc2->{exprType}, $lc2->{pos}, $lc2->{morph} );
	$lc2->{pos} = 'RG';
	$lc2->{morph} = 'NOM';

	return $self;
}
#**************************************************************#
# markCurrencyBefore
#
# TEST	$12.50
#
#**************************************************************#
sub markCurrencyBefore {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# 1. Check if context exists
	my $rc1base = $chunk->peek(1) or return $self;

	# Current orthography is a currency
	if (
		$t->{orth} =~ /^($MTM::Vars::sv_currency_list|\$|\€|\£)$/i
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};

	# Flag to signal that rc3 exists.
	my $rc3_flag = 1;
	my $rc3;
	my $rc3base = $chunk->peek(3) or $rc3_flag = 0;

	# Get currency
	my ( $currency, $currency2 ) = &getCurrency( $t->{orth} );

	# $12, $12.50
	if (
		$rc1->{pos} =~ /RG/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'CURRENCY' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'CURRENCY' );
		if (
			$rc3_flag == 1
		) {
			my $rc2base;
			$rc2base = $chunk->peek(2);
			my $rc2 = $rc2base->{LEGACYDATA};
			my $rc3 = $rc3base->{LEGACYDATA};

			# CURRENT	RC1		RC2		RC3
			# $		12		,		50
			# tolv		dollar|och	femtio		cent
			if (
				$rc2->{orth} =~ /^[\,\.]$/
				&&
				$rc3->{pos} eq 'RG'
			) {

				$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'CURRENCY' );
				$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'CURRENCY' );

				# $	->	<none>
				$t->{exp} = '<none>';
				$t->{pos} = 'NN';
				$t->{morph} = 'NOM';

				# 5	->	fem|dollar
				$rc1->{pos} = 'RG';
				$rc1->{morph} = 'NOM';
				$rc1->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc1->{orth}, $rc1->{exprType}, $rc1->{pos}, $rc1->{morph} );
				$rc1->{pos} .= '|NN';

				my( $c, $m ) = &numerusCurrencyCheck( $rc1->{orth}, $currency );
				$rc1->{exp} .= "\|$c";

				# .	->	och		
				$rc2->{exp} = $MTM::Vars::and_word;

				# 50	->	femtio|cent
				$rc3->{pos} = 'RG';
				$rc3->{morph} = 'NOM';
				$rc3->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc3->{orth}, $rc3->{exprType}, $rc3->{pos}, $rc3->{morph} );
				$rc3->{pos} .= '|NN';
				$rc3->{exp} .= "\|$currency2";

				# print STDERR "t	$t->{orth} $t->{exp}\n";
				# print STDERR "rc1	$rc1->{orth} $rc1->{exp}\n";
				# print STDERR "rc2	$rc2->{orth} $rc2->{exp}\n";
				# print STDERR "rc3	$rc3->{orth} $rc3->{exp}\n";

				return $self;
			}
		}

	} else {
		return $self;
	}

	# print "2. t $t->{orth} $t->{exprType}\trc1 $rc1->{orth} $rc1->{exprType}\n";

	# Expand cardinal (NB: swapped expansions)
	$t->{exp} = '<none>';
	$t->{pos} = 'NN';
	$t->{morph} = 'NOM';
	$rc1->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc1->{orth}, $rc1->{exprType}, $rc1->{pos}, $rc1->{morph} );

	$rc1->{pos} = 'RG|NN';

	my( $c, $m ) = &numerusCurrencyCheck( $rc1->{orth}, $currency );
	$rc1->{exp} .= "\|$c";
	$rc1->{morph} = $m;

	return $self;
}
#**************************************************************#
# markCurrencyBeforeDEL
#
# TEST	$ 12.50
#
#**************************************************************#
sub markCurrencyBeforeDEL {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;

	# Current orthography is a currency
	if (
		( $t->{orth} =~ /^($MTM::Vars::sv_currency_list|\$|\€|\£)$/i && $MTM::Vars::lang eq 'sv' )
		||
		( $t->{orth} =~ /^($MTM::Vars::en_currency_list|\$|\€|\£)$/i && $MTM::Vars::lang eq 'en' )
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1base = $chunk->peek(1) or return $self;
	my $rc1 = $rc1base->{LEGACYDATA};

	# Flag to signal that rc3 exists.
	my $rc4_flag = 1;
	my $rc4base = $chunk->peek(4) or $rc4_flag = 0;

	# Get currency
	my ( $currency, $currency2 ) = &getCurrency( $t->{orth} );

	# $ 12kr., $ 12.50
	if (
		$rc1->{orth} eq ' '
		&&
		$rc2->{pos} =~ /RG/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'CURRENCY' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'CURRENCY' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'CURRENCY' );

		# print "1. t $t->{orth} $t->{exprType}\trc1 $rc1->{orth} $rc1->{exprType}\n";

		if (
			$rc4_flag == 1
		) {
			my $rc3base;
			$rc3base = $chunk->peek(3);
			my $rc3 = $rc3base->{LEGACYDATA};
			my $rc4 = $rc4base->{LEGACYDATA};

			# CURRENT	RC1	RC2		RC3
			# $		_	12		,		50
			# tolv		_	dollar|$MTM::Vars::and_word	femtio		cent
			if (
				(
					$rc3->{exprType} =~ /DECIMAL/
				) || (
					$rc4->{pos} eq 'RG'
					&&
					$rc3->{orth} =~ /^[\,\.]$/
				)
			) {

				$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'CURRENCY' );
				$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'CURRENCY' );

				# $	->	<none>
				$t->{exp} = '<none>';
				$t->{pos} = 'NN';
				$t->{morph} = 'NOM';

				# 5	->	fem|dollar
				$rc2->{pos} = 'RG';
				$rc2->{morph} = 'NOM';
				$rc2->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc2->{orth}, $rc2->{exprType}, $rc2->{pos}, $rc2->{morph} );
				$rc2->{pos} .= '|NN';

				my( $c, $m ) = &numerusCurrencyCheck( $rc2->{orth}, $currency );
				$rc2->{exp} .= "\|$c";

				# .	->	$MTM::Vars::and_word		
				$rc3->{exp} = $MTM::Vars::and_word;

				# 50	->	femtio|cent
				$rc4->{pos} = 'RG';
				$rc4->{morph} = 'NOM';
				$rc4->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc4->{orth}, $rc4->{exprType}, $rc4->{pos}, $rc4->{morph} );
				$rc4->{pos} .= '|NN';
				$rc4->{exp} .= "\|$currency2";

				# print STDERR "t	$t->{orth} $t->{exp}\n";
				# print STDERR "rc1	$rc1->{orth} $rc1->{exp}\n";
				# print STDERR "rc2	$rc2->{orth} $rc2->{exp}\n";
				# print STDERR "rc3	$rc3->{orth} $rc3->{exp}\n";
				# print STDERR "rc4	$rc4->{orth} $rc4->{exp}\n";

				return $self;
			}
		}
	} else {
		return $self;
	}

	# Expand cardinal (NB: swapped expansions)
	$t->{exp} = '<none>';
	$t->{pos} = 'NN';
	$t->{morph} = 'NOM';
	$rc2->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc2->{orth}, $rc2->{exprType}, $rc2->{pos}, $rc2->{morph} );
	$rc2->{pos} = 'RG|NN';

	my( $c, $m ) = &numerusCurrencyCheck( $rc1->{orth}, $currency );
	$rc2->{exp} .= "\|$c";
	$rc2->{morph} = $m;

	return $self;
}
#**************************************************************#
# getCurrency
#
# Return: currency expansion
#**************************************************************#
sub getCurrency {
	my $orth = shift;

	if (
		$orth =~ /^(\$|dollar)$/i
	) {
		return( $MTM::Vars::sv_dollar_expansion, $MTM::Vars::sv_dollar2_expansion ) if $MTM::Vars::lang eq 'sv';
		return( $MTM::Vars::en_dollar_expansion, $MTM::Vars::en_dollar2_expansion ) if $MTM::Vars::lang eq 'en';
	} elsif (
		$orth =~ /^(\£|pund)$/i
	) {
		return ( $MTM::Vars::sv_pound_expansion, $MTM::Vars::sv_pound2_expansion ) if $MTM::Vars::lang eq 'sv';
		return ( $MTM::Vars::en_pound_expansion, $MTM::Vars::en_pound2_expansion ) if $MTM::Vars::lang eq 'en';
	} elsif (
		$orth =~ /^(\€|euros?)$/i
	) {
		return ( $MTM::Vars::sv_euro_expansion, $MTM::Vars::sv_euro2_expansion ) if $MTM::Vars::lang eq 'sv';
		return ( $MTM::Vars::en_euro_expansion, $MTM::Vars::en_euro2_expansion ) if $MTM::Vars::lang eq 'en';
	} elsif (
		$orth =~ /^($MTM::Vars::sv_krona|\:-)$/i
	) {
		return ( $MTM::Vars::sv_krona_expansion, $MTM::Vars::sv_krona2_expansion ) if $MTM::Vars::lang eq 'sv';
		return ( $MTM::Vars::en_krona_expansion, $MTM::Vars::en_krona2_expansion ) if $MTM::Vars::lang eq 'en';
	}
	return 1;
}
#**************************************************************#
# numerusCurrencyCheck
#
# TEST	1 kr.	2 kr.
#**************************************************************#
sub numerusCurrencyCheck {	# return: var

	my $orth = shift;
	my $currency_expansion = shift;

	if (
		$currency_expansion =~ /kron/i
	) {
		if (
			$orth eq '1'
		) {
			$currency_expansion = 'krona';
		} else {
			$currency_expansion = 'kronor';
		}
	}

	my $morph = '-';

	# Insert UTR at cardinal
	if ( $currency_expansion eq 'krona' ) {
		$morph = 'UTR SIN IND NOM';
	} elsif( $currency_expansion =~ /(€|euro|\$|dollar)/i ) {
		$morph = 'UTR - IND NOM';
	} elsif( $currency_expansion =~ /(£|pund)/i ) {
		$morph = 'NEU - IND NOM';
	}

	if( $MTM::Vars::lang eq 'en' && $orth ne '1' ) {
		$currency_expansion .= 's';
	}

	return( $currency_expansion, $morph );

}
#**************************************************************#
1;
