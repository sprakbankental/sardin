package MTM::Analysis::Year;

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
# Year
#
# Language	sv_se
#
# Rules for marking year intervals and years.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if (
		$t->{orth} =~ /\d/
		&&
		$t->{exprType} !~ /(DATE|TIME|ID NUM|PHONE|DECIMAL)/i
	) {
		my $status = 0;
		( $self, $status ) = &mark_year_interval_1( $self, $chunk );				# sommaren 1986 - 1998
		( $self, $status ) = &mark_year_interval_2( $self, $chunk ) if $status == 0;		# (1986 - 1998)
		( $self, $status ) = &mark_year_interval_3( $self, $chunk ) if $status == 0;		# 1500-1200 f.Kr
		( $self, $status ) = &mark_year_interval_4( $self, $chunk ) if $status == 0;		# 1960- och 70-talen

		( $self, $status ) = &mark_year_1( $self, $chunk ) if $status == 0;			# våren 1995

		( $self, $status ) = &mark_year_2( $self, $chunk ) if $status == 0;			# (2001)
		( $self, $status ) = &mark_year_3( $self, $chunk ) if $status == 0;			# 2001/02:14
		( $self, $status ) = &mark_year_4( $self, $chunk ) if $status == 0;			# /2006
		#print STDERR "year_markup\t$t->{orth}\t$status\n";
		( $self, $status ) = &mark_year_5( $self, $chunk ) if $status == 0;			# 1999b
		( $self, $status ) = &mark_year_6( $self, $chunk ) if $status == 0;			# , 1874 VB
		( $self, $status ) = &mark_year_7( $self, $chunk ) if $status == 0;			# VB 1988,
		( $self, $status ) = &mark_year_8( $self, $chunk ) if $status == 0;			# , 1992.
		( $self, $status ) = &mark_year_9( $self, $chunk ) if $status == 0;			# 2008 Tour
#		( $self, $status ) = &mark_year_9( $self, $chunk ) if $status == 0;			# 1970erne, 70erne

		&remove_expr_type_year( $self, $chunk );
	}

	return $self;
}
#**************************************************************#
# mark_year_interval_1
#
# Year interval with preceding time word or proper name.
# Example:		sommaren 1986 - 1998
#			vintern 2000/2001
#			Nilsson 2001-2008
#
# TEST	sommaren 1986 - 1998	vintern 2000/2001	Nilsson 2001-2008
#
#**************************************************************#
sub mark_year_interval_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return( $self, $status );
	my $rc2base = $chunk->peek(2) or return( $self, $status );

	my $lc1base = $chunk->peek(-1) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	#---------------------------------------------#
	# Without blanks: Nilsson 2001-2008
	if (
		(
			$lc2->{orth} =~ /^($MTM::Vars::sv_time_words|\©|copyright|\,)$/i
			||
			$lc2->{pos} =~ /(PM|NN)/
		)
		||
		(
			$rc2->{pos} =~ /RG/
		)
	) {

		if (
			$lc1->{pos} eq 'DEL'
			&&
			$t->{orth} =~ /^($MTM::Vars::year_format)$/
			&&
			$rc1->{orth} =~ /^(-|\/|och)$/i
			&&
			$rc2->{orth} =~ /^($MTM::Vars::year_format|$MTM::Vars::year_short_format)$/
		) {

			# Tag as year interval
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR INTERVAL');
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'YEAR INTERVAL');
			$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'YEAR INTERVAL');

			$t->{pos} = 'RG';
			$t->{morph} = 'NOM';
			$rc1->{pos} = 'RG';		# Should be rc2?	CT 2020-11-19
			$rc2->{morph} = 'NOM';

			# Read '-' as $MTM::Vars::to_word
			if ( $rc1->{orth} eq '-' ) {
				$rc1->{exp} = $MTM::Vars::to_word;
			}
			$status = 1;

		}
	}

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return( $self, $status );
	my $rc3base = $chunk->peek(3) or return( $self, $status );

	# CT 2020-11-19 Added flag to signal that rc6 exists.
	my $rc6_flag = 1;
	my $rc6;
	my $rc6base = $chunk->peek(6) or $rc6_flag = 0;

	if( $rc6_flag == 1 ) {
		$rc6 = $rc6base->{LEGACYDATA};
	}

	# Find locations
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	#print STDERR "mark_year_interval_1 with blanks\n$lc2->{orth}\t$lc2->{pos}\t$rc6_flag\n";

	#---------------------------------------------#
	# With blanks Nilsson 2001 - 2008
	if (
		(
			( $lc2->{orth} =~ /^($MTM::Vars::sv_time_words|\©|copyright|\,)$/i && $MTM::Vars::lang eq 'sv' )
			||
			( $lc2->{orth} =~ /^($MTM::Vars::en_time_words|\©|copyright|\,)$/i && $MTM::Vars::lang eq 'en' )
			||
			$lc2->{pos} =~ /(PM|NN)/
		)
		||
		(
			$rc6_flag == 1			# rc6 exists
			&&
			$rc6->{pos} =~ /VB PRT/
		)
	) {

		#print STDERR "mark_year_interval_1 with blanks\n$lc2->{orth}\t$lc2->{pos}\t$rc6_flag\n";
		if (
			$lc1->{pos} eq 'DEL'
			&&
			$t->{orth} =~ /^($MTM::Vars::year_format)$/
			&&
			$rc1->{pos} eq 'DEL'
			&&
			$rc2->{orth} =~ /^(-|\/|och)$/i
			&&
			$rc3->{pos} eq 'DEL'
			&&
			$rc4->{orth} =~ /^($MTM::Vars::year_format|$MTM::Vars::year_short_format)$/
		) {

			# Tag as year interval
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR INTERVAL');
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'YEAR INTERVAL');
			$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'YEAR INTERVAL');
			$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'YEAR INTERVAL');
			$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'YEAR INTERVAL');
			$t->{pos} = 'RG';
			$t->{morph} = 'NOM';

			$rc4->{pos} = 'RG';
			$rc4->{morph} = 'NOM';

			# Read '-' as $MTM::Vars::to_word
			if ( $rc2->{orth} eq '-' ) {
				$rc2->{exp} = $MTM::Vars::to_word;
			}

			$status = 1;
			#print STDERR "mark_year_interval_1 $t->{orth}	$t->{exprType}	$rc1->{exprType}	$rc2->{exprType}	$rc3->{exprType}	$rc4->{exprType}\n";
		}
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_interval_2
#
# Year interval surrounded by parentheses or a closuring parenthesis or comma.
# Example:		(1986 - 1998)
#			(Wallin 1718-63)
#
# TEST	(1986 - 1998)	(Wallin 1718-63)
#**************************************************************#
sub mark_year_interval_2 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc3base = $chunk->peek(3) or return( $self, $status );
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
	) {
		# continue
	} else {
		return( $self, $status );
	}

	# Without blanks
	if (
		$rc1->{orth} =~ /^(-|och)$/i
		&&
		$rc2->{orth} =~ /^($MTM::Vars::year_format|$MTM::Vars::year_short_format)$/
		&&
		$rc3->{orth} =~ /^[\)|\;|\,]$/
	) {
		# Tag as year interval
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR INTERVAL');
		$rc1->{exprType} = 'YEAR INTERVAL' ;
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'YEAR INTERVAL');

		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$rc2->{pos} = 'RG';
		$rc2->{morph} = 'NOM';

		# Read '-' as $MTM::Vars::to_word
		if ( $rc1->{orth} eq '-' ) {
			$rc1->{exp} = $MTM::Vars::to_word;
		}
		$status = 1;
	}

	# 1. Check if context exists
	my $rc5base = $chunk->peek(5) or return( $self, $status );
	my $rc4base = $chunk->peek(4) or return( $self, $status );

	# Find locations
	my $rc5 = $rc5base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	if (
		$rc1->{pos} eq 'DEL'
		&&
		$rc2->{orth} =~ /^(-|och)$/i
		&&
		$rc3->{pos} eq 'DEL'
		&&
		$rc4->{orth} =~ /^($MTM::Vars::year_format|$MTM::Vars::year_short_format)$/
		&&
		$rc5->{orth} =~ /^[\)|\;|\,]$/
	) {
		# Tag as year interval
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR INTERVAL');
		$rc1->{exprType} = 'YEAR INTERVAL' ;
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'YEAR INTERVAL');
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'YEAR INTERVAL');
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'YEAR INTERVAL');

		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$rc4->{pos} = 'RG';
		$rc4->{morph} = 'NOM';

		# Read '-' as $MTM::Vars::to_word
		if ( $rc2->{orth} eq '-' ) {
			$rc2->{exp} = $MTM::Vars::to_word;
		}

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_interval_3
#
# Year interval followed by "f.Kr" or "e. Kr.".
# Or followed by VB PRT		CT 100817
# Example:		1500-1200 f.Kr
#			1200-1500 e. Kr.
#
# TEST	1500-1200 f.Kr	1200-1500 e. Kr.
#**************************************************************#
sub mark_year_interval_3 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return( $self, $status );
	my $rc3base = $chunk->peek(3) or return( $self, $status );
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc4 = $rc4base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
	) {
		# conintue
	} else {
		return( $self, $status );
	}

	# Without blanks
	if (
		$rc1->{orth} =~ /^(-|$MTM::Vars::and_word)$/i
		&&
		$rc2->{orth} =~ /^($MTM::Vars::year_format|$MTM::Vars::year_short_format)$/
		&&
		$rc3->{pos} eq 'DEL'
	) {
		# continue
	} else {
		return( $self, $status );
	}

	if (
		( $rc4->{orth} =~ /^[ef]\.? ?Kr\.?$/i && $MTM::Vars::lang eq 'sv' )
		||
		( $rc4->{orth} =~ /^(AD|BC)$/i && $MTM::Vars::lang eq 'en' )
		||
		(						
			$rc4->{pos} =~ /VB/
			&&
			$rc4->{morph} =~ /PRT/
		)
	) {
		# Tag as year interval
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR INTERVAL');
		$rc1->{exprType} = 'YEAR INTERVAL' ;
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'YEAR INTERVAL');

		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$rc2->{pos} = 'RG';
		$rc2->{morph} = 'NOM';

		# Read '-' as $MTM::Vars::to_word
		if ( $rc1->{orth} eq '-' ) {
			$rc1->{exp} = $MTM::Vars::to_word;
		}
		$status = 1;
	}


	# With blanks.
	# 1. Check if context exists
	my $rc6base = $chunk->peek(6) or return( $self, $status );
	my $rc5base = $chunk->peek(5) or return( $self, $status );

	# Find locations
	my $rc6 = $rc6base->{LEGACYDATA};
	my $rc5 = $rc5base->{LEGACYDATA};

	if (
		$rc1->{pos} eq 'DEL'
		&&
		$rc2->{orth} =~ /^(-|och)$/i
		&&
		$rc3->{pos} eq 'DEL'
		&&
		$rc4->{orth} =~ /^($MTM::Vars::year_format|$MTM::Vars::year_short_format)$/
		&&
		$rc5->{pos} eq 'DEL'
	) {
		# continue
	} else {
		return( $self, $status );
	}

	if (
		( $rc6->{orth} =~ /^[ef]\.? ?Kr\.?$/i && $MTM::Vars::lang eq 'sv' )
		||
		( $rc6->{orth} =~ /^(AD|BC)$/i && $MTM::Vars::lang eq 'en' )
		||
		(						
			$rc6->{pos} =~ /VB/			# CT 100817
			&&
			$rc6->{morph} =~ /PRT/
		)
	) {

		# Tag as year interval
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR INTERVAL');
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'YEAR INTERVAL');
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'YEAR INTERVAL');
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'YEAR INTERVAL');
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'YEAR INTERVAL');

		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$rc4->{pos} = 'RG';
		$rc4->{morph} = 'NOM';

		# Read '-' as $MTM::Vars::to_word
		if ( $rc2->{orth} eq '-' ) {
			$rc2->{exp} = $MTM::Vars::to_word;
		}

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_interval_4
#
# 1960- och 70-talen
#
# TEST	1960- och 70-talen
#**************************************************************#
sub mark_year_interval_4 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return( $self, $status );
	my $rc3base = $chunk->peek(3) or return( $self, $status );
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc4 = $rc4base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};


	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)-?$/
	) {
		# continue
	} else {
		return( $self, $status );
	}

	if (
		$MTM::Vars::lang eq 'sv'
		&&
		$rc2->{orth} =~ /^(och|till)$/i
		&&
		$rc4->{orth} =~ /^\d0-tal.?.?$/i
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}
	return( $self, $status );
}
#**************************************************************#
# mark_year_1
#
# Year with preceding time word or proper name.
# 		våren 1995
#		Andersson, 1995
#
# TEST	våren 1995	Andersson, 1995
#**************************************************************#
sub mark_year_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return( $self, $status );
	my $lc1base = $chunk->peek(-1) or return( $self, $status );

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc1base->{LEGACYDATA};


	# sommaren 1995
	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{exprType} !~ /YEAR INTERVAL/
	) {
	} else {
		return( $self, $status );
	}


	if (
		(
			( $lc2->{orth} =~ /^($MTM::Vars::sv_time_words|\©|copyright|\*|\†)$/i && $MTM::Vars::lang eq 'sv' )
			||
			( $lc2->{orth} =~ /^($MTM::Vars::en_time_words|\©|copyright|\*|\†)$/i && $MTM::Vars::lang eq 'en' )
			||
			$lc2->{pos} =~ /(PM|NN)/
		)
		&&
		$lc1->{pos}	 eq 'DEL'
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
		return( $self, $status );
	}


	# 1. Check if context exists
	my $lc3base = $chunk->peek(-3) or return( $self, $status );

	# Find locations
	my $lc3 = $lc3base->{LEGACYDATA};

	# Andersson, 1995
	if (
		$lc1->{pos} eq 'DEL'
		&&
		$lc2->{pos} =~ /DL/
		&&
		$lc3->{pos} =~ /PM/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_2
#
# Year within parentheses or right parenthesis following.
# Example:		(2001)
#			(Rosdal, 1456)
#
# TEST	(2001)	(Rosdal, 1456)
#**************************************************************#
sub mark_year_2 {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};


	#print STDERR "mark_year_2\t$t->{orth}\t$rc1->{orth}\n";

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{exprType} !~ /YEAR INTERVAL/
		&&
		$rc1->{orth} =~ /^[\)\;\,]$/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_3
#
# TEST	2001/02:14	2006 : 09
#
#**************************************************************#
sub mark_year_3 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{exprType} !~ /YEAR INTERVAL/
	) {
		# continue
	} else {
		return( $self, $status );
	}

	# Without blanks	2006/09
	if (
		$rc1->{orth} =~ /^[\:\/]$/
		&&
		$rc2->{orth} =~ /^\d+$/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}	

	# With blanks	2006 : 09
	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return( $self, $status );
	my $rc3base = $chunk->peek(3) or return( $self, $status );

	# Find locations
	my $rc4 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc1base->{LEGACYDATA};

	if (
		$rc1->{pos}	 eq 'DEL'
		&&
		$rc2->{orth} =~ /^[\:\/]$/
		&&
		$rc3->{pos}	 eq 'DEL'
		&&
		$rc4->{orth} =~ /^\d+$/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_4
#
# TEST	/2006
#
#**************************************************************#
sub mark_year_4 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) or return( $self, $status );

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{exprType} !~ /YEAR INTERVAL/
	) {
		# continue
	} else {
		return( $self, $status );
	}

	if (
		$lc1->{orth} =~ /[\/\†\*]/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return( $self, $status );

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};

	if (
		$lc2->{orth} eq '/'
		&&
		$lc1->{pos} eq 'DEL'
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# f.Kr, e.Kr, 1700-, 1999b
#
# TEST	1999b	1700-
#**************************************************************#
sub mark_year_5 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{exprType} !~ /YEAR INTERVAL/
	) {
		# continue
	} else {
		return( $self, $status );
	}

	if (
		( $rc1->{orth} =~ /^($MTM::Vars::sv_year_words_rc)$/i && $MTM::Vars::lang eq 'sv' )
		||
		( $rc1->{orth} =~ /^($MTM::Vars::en_year_words_rc)$/i && $MTM::Vars::lang eq 'en' )
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return( $self, $status );

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};

	if (
		(
			( $rc2->{orth} =~ /^($MTM::Vars::sv_year_words_rc)$/i && $MTM::Vars::lang eq 'sv' )
			||
			( $rc2->{orth} =~ /^($MTM::Vars::en_year_words_rc)$/i && $MTM::Vars::lang eq 'en' )
		)
		&&
		$rc1->{pos} eq 'DEL'
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# ^1954 VB	..., 1874 VB
#
# TEST	^1954	, 1874	+ pos = VB
#**************************************************************#
sub mark_year_6 {

	my $status = 0;

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc2base->{LEGACYDATA};


	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{exprType} =~ /YEAR INTERVAL/
	) {
		# continue
	} else {
		return( $self, $status );
	}

	if (
		$rc2->{pos} =~ /VB/
		&&
		$rc1->{pos} eq 'DEL'
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		# Include year interval	(left context)
		&includeYearInterval( $self, $chunk );

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# includeYearInterval (left context)
#
# 21/3-1876
#**************************************************************#
sub includeYearInterval {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return( $self, $status );
	my $lc1base = $chunk->peek(-1) or return( $self, $status );

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc2base->{LEGACYDATA};


	if (
		$lc1->{orth} eq '-'
		&&
		$lc2->{pos} =~ /RG/
	) {
		$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'YEAR');
		$lc2->{pos} = 'RG';
		$lc2->{morph} = 'NOM';

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# mark_year_7
#	VB 1988$	VB 1988,
#
# TEST	pos=VB 1988$	pos=VB 1988,
#**************************************************************#
sub mark_year_7 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return( $self, $status );
	my $lc1base = $chunk->peek(-1) or return( $self, $status );

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc2base->{LEGACYDATA};


	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$lc2->{pos} =~ /(VB|PC|JJ)/
		&&
		$lc1->{pos} eq 'DEL'
	) {
		# continue
	} else {
		return( $self, $status );
	}

	# no RC or RC1 is delimiter
	# CT 2020-11-19 Added flag to signal that rc6 exists.
	my $rc1_flag = 1;
	my $rc1;

	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;

	if( $rc1_flag == 1 ) {
		$rc1 = $rc1base->{LEGACYDATA};
	}

	if (
		$rc1_flag == 1
	) {
		if (
			$rc1->{pos} eq 'DL'				# 'DL'??? Should be 'DEL'? CT 2020-11-19
		) {
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
			$t->{pos} = 'RG';
			$t->{morph} = 'NOM';

			$status = 1;
		}

	} else {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return( $self, $status );

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};

	if (
		$rc1->{pos} eq 'DEL'
		&&
		$rc2->{pos} eq 'DL'				# 'DL'??? Should be 'DEL'? CT 2020-11-19
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';

		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# , 1992.	Delimiters at both sides.
#
# TEST	, 1992.
#**************************************************************#
sub mark_year_8 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	#print STDERR "mark_year_8\t$t->{orth}\n";

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return( $self, $status );
	my $lc1base = $chunk->peek(-1) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc1base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	#print STDERR "mark_year_8\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\n";

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$lc2->{orth} =~ /^[$MTM::Vars::delimiter]$/
		&&
		$lc1->{orth} =~ /^\s+$/
		&&
		$rc1->{orth} =~ /^[$MTM::Vars::delimiter]$/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# 2008 Tour
#
# test is missing
#**************************************************************#
sub mark_year_9 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# print STDERR "mark_year_9\t$t->{orth}\n";

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	#print STDERR "mark_year_9\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\n";

	if (
		$t->{orth} =~ /^($MTM::Vars::year_format)$/
		&&
		$t->{orth} > 1501
		&&
		$rc1->{orth} =~ /^\s+$/
		&&
		$rc2->{orth} =~ /^[A-ZÅÄÖ][a-zåäö]/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'YEAR');
		$t->{pos} = 'RG';
		$t->{morph} = 'NOM';
		$status = 1;
	}

	return( $self, $status );
}
#**************************************************************#
# remove_expr_type_year
#
# remove_expr_type_year if next word is...
#
# TEST	1700 år
#**************************************************************#
sub remove_expr_type_year {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $status = 0;

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return( $self, $status );
	my $rc1base = $chunk->peek(1) or return( $self, $status );

	# Find locations
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$t->{exprType} eq 'YEAR'
		&&
		( $rc2->{orth} =~ /^($MTM::Vars::sv_remove_year_words)$/i && $MTM::Vars::lang eq 'sv' )
	) {
		$t->{exprType} = '-';
	}

	return( $self, $status );
}
#**************************************************************#
1;
