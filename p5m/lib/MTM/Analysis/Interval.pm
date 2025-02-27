package MTM::Analysis::Interval;

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
# Interval
#
# Language	sv_se
#
# Rules for marking intervals.
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
		$t->{exprType} !~ /(YEAR|DATE|INTERVAL|PHONE)/
	) {

		#print STDERR "INTERVAL $t->{orth}\t$t->{exprType}\n";

		&markIntervalNumLC( $self, $chunk );		# kap. 5-7
		&markIntervalNumRC( $self, $chunk );		# 7-8 min.
		&markIntervalNumRCletter( $self, $chunk );	# 7-8 a kap.
		&markIntervalNumLCletter( $self, $chunk );	# 7 b-8 a kap.
		&markIntervalTime( $self, $chunk );		# måndag - fredag
		&markIntervalRCdelimiter( $self, $chunk );	# 37-38,
		&markIntervalRange( $self, $chunk );		# 445-447
	}

	return $self;
}
#**************************************************************#
# markIntervalNumLC
#
# TEST	kap. 5-7
#
#**************************************************************#
sub markIntervalNumLC {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;

	if (
		$t->{orth} =~ /^\d+$/
	) {
		# continue
	} else {
		return $self;
	}

	my $lc1base = $chunk->peek(-1) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};


	# kap. 5-7
	if (
		(
			(
				$lc2->{orth} =~ /^($MTM::Vars::en_interval_words_lc)$/i && $MTM::Vars::lang eq 'en'
				||
				$lc2->{orth} =~ /^($MTM::Vars::sv_interval_words_lc)$/i
			)
			||
			$lc2->{orth} =~ /§+/
		)
		&&
		$lc1->{orth} eq ' '
		&&
		$rc1->{orth} eq '-'
		&&
		$rc2->{orth} =~ /^\d+$/
	) {

		# print STDERR "\n\nmarkIntervalNumLC\tlc2 $lc2->{orth}\tlc1 $lc1->{orth}\tt $t->{orth}\trc1 $rc1->{orth}\trc2 $rc2->{orth}\n\n";
		# CT 210907 don't tag '§ '	$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		# CT 210907 don't tag '§ '	$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );
		return $self;
	}

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;

	# Find locations
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	# kap. 5 - 7
	if (
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} eq '-'
		&&
		$rc3->{orth} eq ' '
		&&
		$rc4->{orth} =~ /^\d+$/
	) {
		#$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		#$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'INTERVAL' );
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'INTERVAL' );

		# print STDERR "\n\nmarkIntervalNumLC2\tlc2 $lc2->{orth}\tlc1 $lc1->{orth}\tt $t->{orth}\trc1 $rc1->{orth}\trc2 $rc2->{orth}\trc3 $rc3->{orth}\trc4 $rc4->{orth}\n\n";

		return $self;

	}

	return $self;
}
#**************************************************************#
# markIntervalNumRC
#
# TEST	7-8 min.
# Consider not to use RC words!	CT 110808
#**************************************************************#
sub markIntervalNumRC {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;

	if (
		$t->{orth} =~ /^\d+$/
	) {
		# continue
	} else {
		return $self;
	}


	# Find locations
	my $lc1base = $chunk->peek(-1) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};


	# 7-8 min.
	if (
		(
			$MTM::Vars::lang eq 'sv' && $rc2->{orth} =~ /^($MTM::Vars::sv_interval_words_rc)$/i
			||
			$MTM::Vars::lang eq 'en' && $rc2->{orth} =~ /^($MTM::Vars::en_interval_words_rc)$/i
			||
			$rc2->{pos} =~ /^(?:NN|JJ)/
		)
		&&
		$rc1->{orth} eq ' '
		&&
		$lc1->{orth} eq '-'
		&&
		$lc2->{orth} =~ /^\d+$/
	) {

		# print STDERR "\n\nmarkIntervalNumRC\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\n\n";

		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );

		return $self;
	}

	# 1. Check if context exists
	my $lc4base = $chunk->peek(4) or return $self;
	my $lc3base = $chunk->peek(3) or return $self;

	# Find locations
	my $lc3 = $lc3base->{LEGACYDATA};
	my $lc4 = $lc4base->{LEGACYDATA};

	# 7 - 8 min.
	if (
		(
			$MTM::Vars::lang eq 'sv' && $rc2->{orth} =~ /^($MTM::Vars::sv_interval_words_rc)$/i
			||
			$MTM::Vars::lang eq 'en' && $rc2->{orth} =~ /^($MTM::Vars::en_interval_words_rc)$/i
			||
			$rc2->{pos} =~ /^(?:NN|JJ)/
		)
		&&
		$rc1->{orth} eq ' '
		&&
		$lc1->{orth} eq ' '
		&&
		$lc2->{orth} eq '-'
		&&
		$lc3->{orth} eq ' '
		&&
		$lc4->{orth} =~ /^\d$/

	) {

		# print STDERR "\n\nmarkIntervalNumRC2\tlc4 $lc4->{orth}\tlc3 $lc3->{orth}\tlc2$lc2->{orth}\tlc1 $lc1->{orth}\tt $t->{orth}\trc1 $rc1->{orth}\trc2 $rc2->{orth}\n\n";

		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );

		return $self;
	}

	return $self;
}
#**************************************************************#
# markIntervalNumLCletter
#
# TEST	7 b-8 c kap.
# CT 200527
#**************************************************************#
sub markIntervalNumLCletter {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if (
		$t->{orth} =~ /^\d+$/
	) {
		# continue
	} else {
		return $self;
	}

	# 1. Check if context exists
	my $lc4base = $chunk->peek(-4) or return $self;
	my $rc4base = $chunk->peek(4) or return $self;

	# Find locations
	my $lc1base = $chunk->peek(-1) or return $self;
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc3base = $chunk->peek(-3) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;

	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc3 = $lc3base->{LEGACYDATA};
	my $lc4 = $lc4base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

#	print STDERR "\n\nmarkIntervalNumLCletter\t$lc4->{orth}\t$lc3->{orth}\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\t$rc3->{orth}\t$rc4->{orth}\n\n";

	# 7 a-8 c kap.
	if (
		(
			$MTM::Vars::lang eq 'sv' && $rc4->{orth} =~ /^(__mute_|$MTM::Vars::sv_interval_words_rc|kap\.?|\§\§|\§|st\.)/i
			||
			$MTM::Vars::lang eq 'en' && $rc4->{orth} =~ /^(__mute_|$MTM::Vars::en_interval_words_rc|ch\.?|chapt\.?|\§\§|\§)/i
			||
			$rc4->{pos} =~ /^(?:NN|JJ)/
		)
		&&
		$rc3->{orth}  eq ' '
		&&
		$rc2->{orth} =~ /^[a-z]$/
		&&
		$rc1->{orth}  eq ' '
		&&
		$lc1->{orth} eq '-'
		&&
		$lc2->{orth} =~ /^[a-z]$/
		&&
		$lc3->{orth} eq ' '
		&&
		$lc4->{orth} =~ /^\d+$/

	) {

		# print STDERR "\n\nmarkIntervalNumLCletter\t$lc4->{orth}\t$lc3->{orth}\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\t$rc3->{orth}\t$rc4->{orth}\n\n";

		$lc4->{exprType} = MTM::Legacy::get_exprType( $lc4->{exprType}, 'INTERVAL' );
		$lc3->{exprType} = MTM::Legacy::get_exprType( $lc3->{exprType}, 'INTERVAL' );
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );
		#$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'INTERVAL' );
		#$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'INTERVAL' );

		return $self;
	}

	return $self;
}
#**************************************************************#
# markIntervalNumRCletter
#
# TEST	7-8 c kap.
# CT 200527
#**************************************************************#
sub markIntervalNumRCletter {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $rc4base = $chunk->peek(4) or return $self;


	if (
		$t->{orth} =~ /^\d+$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1base = $chunk->peek(-1) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;

	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	# 7-8 c kap.
	if (
		(
			$MTM::Vars::lang eq 'sv' && $rc4->{orth} =~ /^($MTM::Vars::sv_interval_words_rc|kap\.|\§|mute_)$/i
			||
			$MTM::Vars::lang eq 'en' && $rc4->{orth} =~ /^($MTM::Vars::en_interval_words_rc|chapt\.|\§|mute_)$/i
			||
			$rc4->{pos} =~ /^(?:NN|JJ)/
		)
		&&
		$rc3->{orth}  eq ' '
		&&
		$rc2->{orth} =~ /^[a-z]$/
		&&
		$rc1->{orth}  eq ' '
		&&
		$lc1->{orth} eq '-'
		&&
		$lc2->{orth} =~ /^\d+$/
	) {

		# print STDERR "\n\nmarkIntervalNumRCletter\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\n\n";

		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'INTERVAL' );
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'INTERVAL' );

		return $self;
	}

	return $self;
}
#**************************************************************#
# isIntervalRCdelimiter
#
# TEST	37-38,
# Typically in registres.
#**************************************************************#
sub markIntervalRCdelimiter {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	if (
		$t->{orth} =~ /^\d+$/
	) {
		# continue
	} else {
		return $self;
	}


	# Find locations
	my $lc1base = $chunk->peek(-1) or return $self;

	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	# 37-38,
	if (
		$rc1->{orth} =~ /^[\,\;\.\:]$/i
		&&
		$lc1->{orth} eq '-'
		&&
		$lc2->{orth} =~ /^\d+$/
	) {
		# print STDERR "\n\nmarkIntervalRCdelimiter\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\n\n";

		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'INTERVAL' );
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'INTERVAL' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );

		return $self;
	}
	return $self;
}
#**************************************************************#
# isIntervalTime
#
# Time intervals
# TEST	tisdag - fredag	jan.-apr.
#**************************************************************#
sub markIntervalTime {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;


	if (
		$MTM::Vars::lang eq 'sv' && $t->{orth} =~ /^($MTM::Vars::sv_weekday|$MTM::Vars::sv_weekday_abbreviation|$MTM::Vars::sv_month|$MTM::Vars::sv_month_abbreviation)$/i
		||
		$MTM::Vars::lang eq 'en' && $t->{orth} =~ /^($MTM::Vars::en_weekday|$MTM::Vars::en_weekday_abbreviation|$MTM::Vars::en_month|$MTM::Vars::en_month_abbreviation)$/i
	) {
		# continue
	} else {
		return $self;
	}

	# print STDERR "markIntervalTime\t$t->{orth}\n";

	# Find locations
	my $rc1base = $chunk->peek(1) or return $self;

	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	# print STDERR "\nmarkIntervalTime\n\t0. $t->{orth} 1. $rc1->{orth} 2. $rc2->{orth}\n";

	# tisdag-fredag, månd.-fred.
	if (
		$MTM::Vars::lang eq 'sv'
		&&
		(
			$t->{orth} =~ /^($MTM::Vars::sv_weekday)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::sv_weekday)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::sv_weekday_abbreviation)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::sv_weekday_abbreviation)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::sv_month)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::sv_month)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::sv_month_abbreviation)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::sv_month_abbreviation)$/i
		)
		&&
		$rc1->{orth} eq '-'
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );

		# print STDERR "\n\nmarkIntervalTime\t$t->{orth} $t->{exprType}\t$rc1->{orth} $rc1->{exprType}\t$rc2->{orth} $rc2->{exprType}\n\n";
	}

	# tisdag-fredag, månd.-fred.
	if (
		$MTM::Vars::lang eq 'en'
		&&
		(
			$t->{orth} =~ /^($MTM::Vars::en_weekday)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::en_weekday)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::en_weekday_abbreviation)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::en_weekday_abbreviation)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::en_month)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::en_month)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::en_month_abbreviation)$/i
			&&
			$rc1->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::en_month_abbreviation)$/i
		)
		&&
		$rc1->{orth} eq '-'
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );

		# print STDERR "\n\nmarkIntervalTime\t$t->{orth} $t->{exprType}\t$rc1->{orth} $rc1->{exprType}\t$rc2->{orth} $rc2->{exprType}\n\n";
	}

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;

	# Find locations
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};


	# print STDERR "\nmarkIntervalTime\n\t0. $t->{orth} 1. $rc1->{orth} 2. $rc2->{orth} 3. $rc3->{orth} 4. $rc4->{orth}\n";

	# månd. - fred.
	if (
		$MTM::Vars::lang eq 'sv'
		&&
		(
			$t->{orth} =~ /^($MTM::Vars::sv_weekday)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::sv_weekday)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::sv_weekday_abbreviation)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::sv_weekday_abbreviation)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::sv_month)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::sv_month)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::sv_month_abbreviation)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|$MTM::Vars::to_word)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::sv_month_abbreviation)$/i
		)
		&&
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} eq '-'
		&&
		$rc2->{orth} eq ' '
	) {

		# print STDERR "\n\nmarkIntervalTime2\tt $t->{orth}\trc1 $rc1->{orth}\trc2 $rc2->{orth}\trc3 $rc3->{orth}\trc4 $rc4->{orth}\n\n";

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'INTERVAL' );
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'INTERVAL' );

	}

	# månd. - fred.
	if (
		$MTM::Vars::lang eq 'en'
		&&
		(
			$t->{orth} =~ /^($MTM::Vars::en_weekday)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|to)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::en_weekday)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::en_weekday_abbreviation)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|to)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::en_weekday_abbreviation)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::en_month)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|to)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::en_month)$/i
		) || (
			$t->{orth} =~ /^($MTM::Vars::en_month_abbreviation)$/i
			&&
			$rc1->{orth} eq ' '
			&&
			$rc2->{orth} =~ /^(-|to)$/i
			&&
			$rc3->{orth} eq ' '
			&&
			$rc4->{orth} =~ /^($MTM::Vars::en_month_abbreviation)$/i
		)
		&&
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} eq '-'
		&&
		$rc2->{orth} eq ' '
	) {

		# print STDERR "\n\nmarkIntervalTime2\tt $t->{orth}\trc1 $rc1->{orth}\trc2 $rc2->{orth}\trc3 $rc3->{orth}\trc4 $rc4->{orth}\n\n";

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'INTERVAL' );
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'INTERVAL' );

	}
	return $self;
}
#**************************************************************#
# TEST	5-7
sub markIntervalRange {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	# CT 2020-11-19 Added flag to signal that rc3 exists.
	my $rc3_flag = 1;
	my $rc3;
	my $rc3base = $chunk->peek(3) or $rc3_flag = 0;

	my $lc1_flag = 1;
	my $lc1;
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

	if( $rc3_flag == 1 ) {
		my $rc3 = $rc3base->{LEGACYDATA};
		return $self if $rc3->{orth} eq '-';
	}

	if( $lc1_flag == 1 ) {
		my $lc1 = $lc1base->{LEGACYDATA};
		return $self if $lc1->{orth} eq '-';
	}

	# 5-7
	if (
		$t->{orth} =~ /^\d+$/
		&&
		$rc1->{orth} eq '-'
		&&
		$rc2->{orth} =~ /^\d+$/
	) {

		my $first = $t->{orth};
		my $second = $rc2->{orth};

		if( $first < $second ) {

			# print STDERR "\n\nmarkIntervalRange\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\n\n";
			#print STDERR "\n\nmarkIntervalRange\n$t->{orth}\t$t->{exprType}\n$rc1->{orth}\t$rc1->{exprType}\n$rc2->{orth}\t$rc2->{exprType}\n\n";

			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INTERVAL' );
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INTERVAL' );
			$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'INTERVAL' );

			#print STDERR "\n\nmarkIntervalRange\n$t->{orth}\t$t->{exprType}\n$rc1->{orth}\t$rc1->{exprType}\n$rc2->{orth}\t$rc2->{exprType}\n\n";

		}
		return $self;
	}

	return $self;
}
#**************************************************************#
1;
