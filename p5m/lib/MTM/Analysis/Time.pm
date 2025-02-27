package MTM::Analysis::Time;

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
# Time
#
# Language	sv_se
#
# Rules for marking time expressions.
# 
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	# Swedish
	if( $MTM::Vars::lang eq 'sv' ) {
		&mark_time_1( $self,  $chunk );		# kl. 20.00
		&time_duration( $self,  $chunk );		# 2 tim. 22 min.
	}

	# English
	if( $MTM::Vars::lang eq 'en' ) {
		&mark_time_2( $self,  $chunk );			# 12:00
		&mark_time_3( $self,  $chunk );			# 12.15 p.m.
	}
	return $self;
}
#************************************************************#
#
# TEST	kl. 20.00
#************************************************************#
sub mark_time_1 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;


	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	if (
		$t->{orth} =~ /^($MTM::Vars::sv_clock_words)\.?$/i	# kl.
		&&
		$rc1->{pos} eq 'DEL'
		&&
		$rc2->{orth} =~ /^$MTM::Vars::hours$/		# 20
		&&
		$rc3->{orth} =~ /^[\.\:]$/		# .
		&&
		$rc4->{orth} =~ /^($MTM::Vars::minutes)$/	# 00
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'TIME');
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'TIME');
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'TIME');
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'TIME');
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'TIME');

		# Read "-" as "och" only if minutes doesn's start with 0
		if (
			$rc4->{orth}	!~ /^0/
		) {
			$rc3->{exp} = 'och';
		}

	}

	return $self;
}
#************************************************************#
#
# TEST	12:00
#************************************************************#
sub mark_time_2 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc1base = $chunk->peek(-1) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$t->{orth} eq ':'
		&&
		$lc1->{orth} =~ /^$MTM::Vars::hours$/
		&&
		$rc1->{orth} =~ /^($MTM::Vars::minutes)$/	# 00
	) {
		$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'TIME');
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'TIME');
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'TIME');
	}

	return $self;
}
#************************************************************#
#
# TEST	3.15 p.m.	5.05 am
#************************************************************#
sub mark_time_3 {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	return $self if $t->{orth} !~ /^($MTM::Vars::en_clock_words)$/;

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};
	my $lc1 = $lc1base->{LEGACYDATA};

	my $lc4_flag = 1;
	my $lc4base = $chunk->peek(-4) or $lc4_flag = 0;

	# 12.30 p.m.
	if( $lc4_flag == 1 ) {

		my $lc3base = $chunk->peek(-3) or return $self;

		my $lc4 = $lc4base->{LEGACYDATA};
		my $lc3 = $lc3base->{LEGACYDATA};

		if (
			$lc4->{orth} =~ /^$MTM::Vars::hours$/
			&&
			$lc3->{orth} =~ /^[\:\.]$/
			&&
			$lc2->{orth} =~ /^($MTM::Vars::minutes)$/
			&&
			$lc1->{orth} eq ' '
		) {
			$lc4->{exprType} = MTM::Legacy::get_exprType( $lc4->{exprType}, 'TIME');
			$lc3->{exprType} = MTM::Legacy::get_exprType( $lc3->{exprType}, 'TIME');
			$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'TIME');
			$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'TIME');
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'TIME');
		}

	# 5 a.m.
	} else {
		if (
			$lc2->{orth} =~ /^$MTM::Vars::hours$/
			&&
			$lc1->{orth} eq ' '
		) {
			$lc2->{exprType} = MTM::Legacy::get_exprType( $lc2->{exprType}, 'TIME');
			$lc1->{exprType} = MTM::Legacy::get_exprType( $lc1->{exprType}, 'TIME');
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'TIME');
		}
	}

	return $self;
}
#************************************************************#
# time_duration (used e.g. for length of talking books)
#
# TEST	2 tim., 22 min.
#
#************************************************************#
sub time_duration {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};


	# 1. Check if context exists
	my $rc5base = $chunk->peek(5) or return $self;
	my $lc2base = $chunk->peek(-2) or return $self;

	my $rc4base = $chunk->peek(4) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	my $lc1base = $chunk->peek(-1) or return $self;

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};
	my $rc5 = $rc5base->{LEGACYDATA};

	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	#print STDERR "time_duration\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\t$rc1->{orth}\t$rc2->{orth}\t$rc3->{orth}\t$rc4->{orth}\t$rc5->{orth}\t\n";

	if (
		$t->{orth}	eq	'tim.'
		&&
		$lc2->{orth}	=~	/^\d+$/
		&&
		$lc1->{orth}	=~	/^\s+$/
		&&
		$rc1->{orth}	eq	','
		&&
		$rc2->{orth}	=~	/^\s+$/
		&&
		$rc3->{orth}	=~	/^\d+$/
		&&
		$rc4->{orth}	=~	/^\s+$/
		&&
		$rc5->{orth}	=~	/^min\.?$/
		#&&
		#$rc6->{orth}	=~	/^\.\.?$/
	) {
		if ( $lc2->{orth}	eq	'1' ) {
			$lc2->{exp}	=	'en';
			$t->{exp}	=	'timme';
		} else {
			$t->{exp}	=	'timmar';
		}

		if ( $rc3->{orth}	eq	'1' ) {
			$rc3->{exp}	=	'en';
			$rc5->{exp}	=	'minut';
		} else {
			$rc5->{exp}	=	'minuter';
		}

		#$rc6->{exp}		=	'<NONE>';
		$rc1->{exp}		=	'och';


		$lc2->{exprType} = 'TIME';
		$lc1->{exprType} = 'TIME';
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'TIME');
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'TIME');
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'TIME');
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'TIME');
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'TIME');
		$rc5->{exprType} = MTM::Legacy::get_exprType( $rc5->{exprType}, 'TIME');
		#$rc6->{exprType} = MTM::Legacy::get_exprType( $rc6->{exprType}, 'TIME');
	}

	return $self;
}
#************************************************************#
1;
