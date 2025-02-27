package MTM::Analysis::Decimal;

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
# Decimal
#
# Language	sv_se
#
# Rules for marking decimals.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	if (
		&MTM::Legacy::isDefault( $t->{exprType} )
	) {
		&markNumDecimal_1( $self, $chunk );
		&markNumFraction_1( $self, $chunk );
		&markNumDecimal_2( $self, $chunk );
	}

	return $self;
}
#**************************************************************#
# markNumDecimal
#
# Example:	21	,	14	-->	21,14
#		NUM	MIN_DEL	NUM	-->	NUM DEC
#
# TEST	21,14
#**************************************************************#
sub markNumDecimal_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;

	if (
		$t->{orth} =~ /\d/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1base = $chunk->peek(1) or return $self;

	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	if(
		$MTM::Vars::lang eq 'en'
		&&
		$rc1->{orth} eq ','
		&&
		$rc2->{orth} =~ /^\d\d?$/		# No more than two decimals
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DECIMAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DECIMAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DECIMAL' );
		return $self;
	}

	# RC
	if (
		# $rc1->{orth} =~ /^[\,\.]$/
		$rc1->{orth} =~ /^$MTM::Vars::decimal_separator$/
		&&
		$rc2->{orth} =~ /^\d+$/
	) {
		# continue
	} else {
		return $self;
	}


	# 1. Check if context exists
	my $lc2_flag = 1;
	my $lc2base = $chunk->peek(-2) or $lc2_flag = 0;

	if( $lc2_flag == 1 ) {
		my $lc1base = $chunk->peek(-1) or return $self;
		my $lc1 = $lc1base->{LEGACYDATA};
		my $lc2 = $lc2base->{LEGACYDATA};

		if (
			$lc2_flag == 1
			&&
			$lc2->{orth} =~ /^\d+$/
			&&
			$lc1->{orth} =~ /^$MTM::Vars::decimal_separator$/
		) {
			return $self;
		}
	}

	# 1. Check if context exists
	my $rc4_flag = 1;
	my $rc4base = $chunk->peek(4) or $rc4_flag = 0;

	# Don't continue if followed by /[\.\,]\d/
	if (
		$rc4_flag == 1
	) {

		my $rc3base = $chunk->peek(3) or return $self;
		my $rc3 = $rc3base->{LEGACYDATA};
		my $rc4 = $rc4base->{LEGACYDATA};

		if (
			#$rc3->{orth} =~ /^[\.\,]$/
			$rc3->{orth} =~ /^$MTM::Vars::decimal_separator$/
			&&
			$rc4->{orth} =~ /^\d+$/
		) {
			return $self;
		}
	}

	# Tag as decimal number
	$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DECIMAL' );
	$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DECIMAL' );
	$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DECIMAL' );

	#print STDERR "t	$t->{orth}\t$t->{exprType}\n";
	#print STDERR "rc1	$rc1->{orth}\t$rc1->{exprType}\n";
	#print STDERR "rc2	$rc2->{orth}\t$rc2->{exprType}\n";

	$t->{pos} = 'RG';
	$t->{morph} = 'NOM';
	$rc1->{pos } = 'DL';
	$rc1->{morph } = 'MID';
	$rc2->{pos} = 'RG';
	$rc2->{morph} = 'NOM';

	return $self;
}
#**************************************************************#
# isNumFraction_1
#
# Fractions
#
# Example:	1½	3 ¼	¾
#
# TEST	1½	3 ¼	3 ¾
#**************************************************************#
sub markNumFraction_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Import vars
	my $fraction = $MTM::Vars::fraction;

	if (
		$t->{orth} =~ /^(½|$fraction)$/
	) {
		$t->{exprType} = 'FRACTION';
		$t->{pos} = 'NN';
		$t->{morph} = 'NOM';
	}

	return $self;
}
#**************************************************************#
# isDecimal_2
#
# TEST	.66
#**************************************************************#
sub markNumDecimal_2 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) or return $self;

	if (
		&MTM::Legacy::isDigitsOnly( $t->{orth} )
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};

	if (
		$lc1->{orth}	eq	'.'
	) {

		# LC2 cannot be digit (see comment about periods above)
		my $lc2base;
		if (
			$lc2base = $chunk->peek(-1)
		) {
			my $lc2 = $lc2base->{LEGACYDATA};

			if (
				$lc2->{orth} =~ /\d/
			) {
				return $self;
			}

		}


		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DECIMAL' );
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'DECIMAL' );
		$lc1->{pos} = 'DL';
		$lc1->{morph} = 'MID';
	}
	return $self;
}
#**************************************************************#
1;

