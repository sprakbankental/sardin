package MTM::Analysis::Date;

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
# Date
#
# Language	sv_se
#
# Rules for marking dates.
# 
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if( $MTM::Vars::lang eq 'sv' ) {
		&sv_mark_date_interval_1( $self, $chunk );	# 1-3 jan.
		&sv_mark_date_interval_2( $self, $chunk );	# 1-3/7.
		&sv_mark_date_1( $self, $chunk );			# 3:e januari
		&sv_mark_date_2( $self, $chunk );			# 1/12-1984, 28.06.2011
		&sv_mark_date_3( $self, $chunk );			# tisdag 2/3
		&sv_mark_date_4( $self, $chunk );			# 2000-02-20, 2008.04.14

	} elsif( $MTM::Vars::lang eq 'en' ) {
		&en_mark_date_1( $self, $chunk );			# 3rd january
		&en_mark_date_2( $self, $chunk );			# 31st of July
		&en_mark_date_3( $self, $chunk );			# May 13th
	}

	&includeSubs( $self, $chunk );

	return $self;
}
#**************************************************************#
# en_mark_date_1
#
# TEST	3 jan.	3rd january
#**************************************************************#
sub en_mark_date_1 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	#print STDERR "sv_mark_date_1\t$t->{orth}\t$t->{pos}\t$t->{morph}\n";

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)($MTM::Vars::en_ordinal_endings)?$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	#print STDERR "en_mark_date_1\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\n";

	if (
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} =~ /^($MTM::Vars::en_month_letter_format)$/i
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE' );

		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';

		$t->{exp} = 'the';
		$rc1->{exp} = 'of';

		if( exists( $MTM::Vars::en_month_map{ $rc2->{orth} } )) {
			$rc2->{exp} = $MTM::Vars::en_month_map{ $rc2->{orth} };
		}

		#print STDERR "\nsv_mark_date_1\n\t$t->{orth}\t$t->{pos}\t$rc1->{orth}\t$rc2->{orth}\t$rc2->{exp}\n";
		#print STDERR "\t$t->{exprType}\t$rc1->{exprType}\t$rc2->{exprType}\n";
	}

	#print "W $t->{orth}\t$t->{pos}\n";


	return $self;
}
#**************************************************************#
# en_mark_date_2
#
# TEST	31st of November
#**************************************************************#
sub en_mark_date_2 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;

	#print STDERR "sv_mark_date_2\t$t->{orth}\t$t->{pos}\t$t->{morph}\n";


	# print STDERR "III $t->{orth}	$MTM::Vars::date_digit_format)($MTM::Vars::en_ordinal_endings\t\t$t->{exprType}\n";

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)($MTM::Vars::en_ordinal_endings)?$/
	) {
		# continue
	} else {
		return $self;
	}

	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};


	if (
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} =~ /^of$/i
		&&
		$rc3->{orth} eq ' '
		#&&
		#$rc4->{orth} =~ /^($MTM::Vars::en_month_letter_format)$/i
	) {

		# print STDERR "en_mark_date_2\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\t$rc4->{orth}\n$MTM::Vars::en_month_letter_format\n";

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'DATE' );
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'DATE' );

		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';

		if( exists( $MTM::Vars::en_month_map{ $rc4->{orth} } )) {
			$rc2->{exp} = $MTM::Vars::en_month_map{ $rc4->{orth} };
		}

		#print STDERR "\nsv_mark_date_1\n\t$t->{orth}\t$t->{pos}\t$rc1->{orth}\t$rc2->{orth}\t$rc2->{exp}\n";
		#print STDERR "\t$t->{exprType}\t$rc1->{exprType}\t$rc2->{exprType}\n";
	}

	#print "W $t->{orth}\t$t->{pos}\n";


	return $self;
}
#**************************************************************#
# en_mark_date_3
#
# TEST	May 13th
#**************************************************************#
sub en_mark_date_3 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)($MTM::Vars::en_ordinal_endings)?$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc1base->{LEGACYDATA};

	if (
		$lc2->{orth} =~ /^($MTM::Vars::en_month_letter_format)$/i
		&&
		$lc1->{orth} eq ' '
	) {

		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'DATE' );
		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'DATE' );
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE' );

		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';

		if( exists( $MTM::Vars::en_month_map{ $lc2->{orth} } )) {
			$lc2->{exp} = $MTM::Vars::en_month_map{ $lc2->{orth} };
		}

		#print STDERR "\nsv_mark_date_1\n\t$t->{orth}\t$t->{pos}\t$rc1->{orth}\t$rc2->{orth}\n";
		#print STDERR "\t$t->{exprType}\t$rc1->{exprType}\t$rc2->{exprType}\n";
	}

	#print "W $t->{orth}\t$t->{pos}\n";


	return $self;
}
#**************************************************************#
sub includeSubs {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	&include_year( $self, $chunk );
	&include_interval( $self, $chunk );

	return $self;
}
#**************************************************************#
# sv_mark_date_1
#
# TEST	3 jan.	3:e januari
#**************************************************************#
sub sv_mark_date_1 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	#print STDERR "sv_mark_date_1\t$t->{orth}\t$t->{pos}\t$t->{morph}\n";

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)($MTM::Vars::sv_ordinal_endings)?$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	#print STDERR "sv_mark_date_1\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\n";

	if (
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} =~ /^($MTM::Vars::sv_month_letter_format)$/i
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE' );

		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';

		if( exists( $MTM::Vars::sv_month_map{ $rc2->{orth} } )) {
			$rc2->{exp} = $MTM::Vars::sv_month_map{ $rc2->{orth} };
		}

		#print STDERR "\nsv_mark_date_1\n\t$t->{orth}\t$t->{pos}\t$rc1->{orth}\t$rc2->{orth}\n";
		#print STDERR "\t$t->{exprType}\t$rc1->{exprType}\t$rc2->{exprType}\n";
	}

	#print "W $t->{orth}\t$t->{pos}\n";


	return $self;
}
#**************************************************************#
# sv_mark_date_2
#
# TEST	1/12-1984
#**************************************************************#
sub sv_mark_date_2 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)\.?$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

#	print "1 $rc1->{orth}\n2 $rc2->{orth}\n3 $rc3->{orth}\n4 $rc4->{orth}\n\n";

	if (
		# 24/6-1987
		(
			$rc1->{orth} eq '/'
			&&
			$rc2->{orth} =~ /^(0[1-9]|$MTM::Vars::month_digit_format)$/
			&&
			$rc3->{orth} =~ /^(-| )$/
			&&
			$rc4->{orth} =~ /^($MTM::Vars::year_format)$/

		# 24.06.1987
		) || (
			$rc1->{orth} eq '.'
			&&
			$rc2->{orth} =~ /^(0[1-9]|1[0-2])$/
			&&
			$rc3->{orth} eq '.'
			&&
			$rc4->{orth} =~ /^($MTM::Vars::year_format)$/

		)
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE' );
		$t->{pos} = 'RO';
		$t->{morph} = 'NOM';

		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE' );
		$rc1->{exp} = 'i';
		$rc1->{pos} = 'PP';

		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE' );
		$rc2->{pos}= 'RO';
		$rc2->{morph} = 'NOM';

		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'DATE' );

		$rc4->{exprType} = 'DATE|YEAR';

		#print "W $t->{orth}\t$t->{pos}\t$rc2->{orth}\t$rc2->{pos}\n";
		#.

		#print STDERR "\nsv_mark_date_2\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\t$rc3->{orth}\t$rc2->{exp}\t$rc4->{orth}\n";
	}

	return $self;
}
#**************************************************************#
# sv_mark_date_3
#
# TEST	tisdag 3/1	# den 3/1
#
#**************************************************************#
sub sv_mark_date_3 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^(?:$MTM::Vars::sv_weekday|$MTM::Vars::sv_weekday_abbreviation|$MTM::Vars::sv_weekday_definite|den)$/i
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	if (
		# Context
		$t->{exprType}	!~	/DATE/
		&&
		$rc1->{orth}		eq	' '
		&&
		$rc2->{orth}	=~	/^(?:$MTM::Vars::date_digit_format)$/
		&&
		$rc3->{orth}	eq	'/'
		&&
		$rc4->{orth}	=~	/^(?:$MTM::Vars::month_digit_format)$/

	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE' );
		$rc1->{exprType}= 'DATE';
		$rc2->{exprType}= 'DATE';
		$rc3->{exprType}= 'DATE';
		$rc4->{exprType}= 'DATE';

		$rc2->{pos} = 'RO';
		$rc2->{morph} = 'NOM';

		$rc3->{exp} = 'i';

		$rc4->{pos} = 'RO';
		$rc4->{morph} = 'NOM';
	}

	return $self;
}
#**************************************************************#
# sv_mark_date_4
#
# TEST	2008-04-14, 2008.04.14
#**************************************************************#
sub sv_mark_date_4 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $rc4base = $chunk->peek(4) or return $self;

	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::year_format)\.?$/
	) {
		# continue
	} else {
		return $self;
	}

	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

#	print "1 $rc1->{orth}\n2 $rc2->{orth}\n3 $rc3->{orth}\n4 $rc4->{orth}\n\n";

	if (
		# 2014-04-14
		(
			$rc1->{orth} eq '-'
			&&
			$rc2->{orth} =~ /^(0[1-9]|$MTM::Vars::month_digit_format)$/
			&&
			$rc3->{orth} eq '-'
			&&
			$rc4->{orth} =~ /^($MTM::Vars::date_digit_format)$/

		# 2014.04.14
		) || (
			$rc1->{orth} eq '.'
			&&
			$rc2->{orth} =~ /^(0[1-9]|$MTM::Vars::month_digit_format)$/
			&&
			$rc3->{orth} eq '.'
			&&
			$rc4->{orth} =~ /^($MTM::Vars::date_digit_format)$/

		)
	) {

		$t->{exprType} = 'DATE|YEAR';
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE' );

		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE' );
		$rc2->{pos}= 'RG';
		$rc2->{morph} = 'NOM';

		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'DATE' );

		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'DATE' );
		$rc4->{pos}= 'RG';
		$rc4->{morph} = 'NOM';

		#print "W $t->{orth}\t$t->{pos}\t$rc2->{orth}\t$rc2->{pos}\n";
		#.

		#print STDERR "\nsv_mark_date_4\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\t$rc3->{orth}\t$rc2->{exp}\t$rc4->{orth}\n";
	}

	return $self;
}

#**************************************************************#
# sv_mark_date_interval_2	# return: markup
#
# TEST	27-28/12
#
#**************************************************************#
sub sv_mark_date_interval_2 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# 1-3 januari
	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)\.?$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	if (
		$rc1->{orth} eq '-'
		&&
		$rc2->{orth} =~ /^($MTM::Vars::date_digit_format)\.?$/
		&&
		$rc3->{orth} eq '/'
		&&
		$rc4->{orth} =~ /^($MTM::Vars::month_digit_format)$/i
	) {

		# Restrictions
		# The first date number must be lower than the second.
		my $first = $t->{orth};
		my $second = $rc2->{orth};

		$first =~ s/\.//;
		$second =~ s/\.//;

		if (
			$first < $second
		) {
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE INTERVAL' );
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE INTERVAL' );
			$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE INTERVAL' );
			$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'DATE INTERVAL' );
			$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'DATE INTERVAL' );

			$t->{pos} = 'RO';
			$t->{morph} = 'NOM';

			$rc1->{exp} = $MTM::Vars::to_word;

			$rc2->{pos} = 'RO';
			$rc2->{morph} = 'NOM';

			$rc3->{exp} = 'i';

			$rc4->{pos} = 'RO';
			$rc4->{morph} = 'NOM';

			#print STDERR "\nsv_mark_date_interval2\n\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\t$rc2->{pos}\t$rc3->{orth}\t$rc4->{orth}\n";

		}

	}

	return $self;
}
#**************************************************************#
# sv_mark_date_interval_1	# return: markup
#
# TEST	1-3 januari	23-30 oktober	27-28/12
#
#**************************************************************#
sub sv_mark_date_interval_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# 1-3 januari
	if (
		$t->{exprType}	!~	/DATE/
		&&
		$t->{orth} =~ /^($MTM::Vars::date_digit_format)\.?$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	if (
		$rc1->{orth} eq '-'
		&&
		$rc2->{orth} =~ /^($MTM::Vars::date_digit_format)\.?$/
		&&
		$rc3->{orth} eq ' '
		&&
		$rc4->{orth} =~ /^($MTM::Vars::sv_month_letter_format)$/i
	) {

		# Restrictions
		# The first date number must be lower than the second.
		my $first = $t->{orth};
		my $second = $rc2->{orth};

		$first =~ s/\.//;
		$second =~ s/\.//;

		if (
			$first < $second
		) {
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE INTERVAL' );
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE INTERVAL' );
			$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE INTERVAL' );
			$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'DATE INTERVAL' );
			$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'DATE INTERVAL' );

			$t->{pos} = 'RO';
			$t->{morph} = 'NOM';
			$rc2->{pos} = 'RO';
			$rc2->{morph} = 'NOM';

			#print STDERR "\nsv_mark_date_interval\n\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\t$rc2->{pos}\t$rc3->{orth}\t$rc4->{orth}\n";

		}

		return $self;
	}


	# 1. Check if context exists
	my $rc6base = $chunk->peek(6) or return $self;
	my $rc5base = $chunk->peek(5) or return $self;

	# Find locations
	my $rc5 = $rc5base->{LEGACYDATA};
	my $rc6 = $rc6base->{LEGACYDATA};

	if (
		$rc1->{orth} eq ' '
		&&
		$rc2->{orth} eq '-'
		&&
		$rc3->{orth} eq ' '
		&&
		$rc4->{orth} =~ /^($MTM::Vars::date_digit_format)\.?$/
		&&
		$rc5->{orth} eq ' '
		&&
		$rc6->{orth} =~ /^($MTM::Vars::sv_month_letter_format)$/i
	) {

		# Restrictions
		# The first date number must be lower than the second.
		my $first = $t->{orth};
		my $second = $rc4->{orth};

		$first =~ s/\.//;
		$second =~ s/\.//;

		if (
			$first < $second
		) {

			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'DATE INTERVAL' );
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'DATE INTERVAL' );
			$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'DATE INTERVAL' );
			$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'DATE INTERVAL' );
			$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'DATE INTERVAL' );
			$rc5->{exprType} = MTM::Legacy::get_exprType( $rc5->{exprType}, 'DATE INTERVAL' );
			$rc6->{exprType} = MTM::Legacy::get_exprType( $rc6->{exprType}, 'DATE INTERVAL' );

			$t->{pos} = 'RO';
			$t->{morph} = 'NOM';
			$rc4->{pos} = 'RO';
			$rc4->{morph} = 'NOM';

		}
	}

	return $self;
}
#**************************************************************#
# include_interval	# return: markup
#
# TEST	1-2 januari
#
#**************************************************************#
sub include_interval {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	if (
		$t->{exprType} =~ /DATE$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	#print STDERR "include_interval\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t\n";

	if (
		$lc2->{orth} =~ /^(?:$MTM::Vars::date_digit_format)$/
		&&
		$lc1->{orth} eq '-'
	) {
		# continue
	} else {
		return $self;
	}

	# Current number must be lower than second number in interval.
	if (
		$lc2->{orth} < $t->{orth}
	) {
		$lc2->{exprType}	=	'DATE';
		$lc2->{pos}		=	'RO';
		$lc2->{morph} = 'NOM';
		$lc1->{exprType}	=	'DATE';
		$lc1->{exp}		=	$MTM::Vars::to_word;

	}
	return $self;
}
#**************************************************************#
# include_year
# 
# TEST	1 januari 1987	1 januari, 1987
#
#**************************************************************#
sub include_year {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	if (
		$t->{exprType} !~ /DATE/
		&&
		$t->{orth} =~ /^(?:$MTM::Vars::year_format)$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	# 1 januari 1987
	if (
		$lc2->{exprType}	=~	/DATE/
		&&
		$lc1->{orth}		eq	' '
	) {
		$t->{pos}	=	'RG';
		$t->{exprType}	=	"YEAR|DATE";
		$lc1->{exprType}	=	"DATE";

		return $self;
	}

	# 1. Check if context exists
	my $lc3base = $chunk->peek(-3) or return $self;

	# Find locations
	my $lc3 = $lc3base->{LEGACYDATA};

	#print STDERR "include_year\t$lc3->{orth}\t$lc2->{orth}\t$t->{orth}\n\n";

	if (
		$lc3->{exprType} =~ /DATE/
		&&
		$lc2->{orth} eq ','
		&&
		$lc1->{orth} eq ' '
	) {
		$t->{exprType}	=	"YEAR|DATE";
		$t->{pos}	=	'RG';
		$lc3->{exprType}	=	'DATE';
		$lc2->{exprType}	=	'DATE';
		$lc1->{exprType}	=	'DATE';
	}

	return $self;
}
#**************************************************************#
1;
