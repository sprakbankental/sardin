package MTM::Analysis::Initial;

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
# Initial
#
# Language	sv_se
#
# Rules for marking name initials.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {
	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if( $t->{orth} =~ /(?:$MTM::Vars::vowel|$MTM::Vars::consonant)/i ) {
		&markInitialBefore( $self, $chunk );		# C. Karlsson
		&markInitialAfter( $self, $chunk );		# Karlsson, C.
		&markLetterLC( $self, $chunk );		# 25 a
	}
	return $self;
}
#**************************************************************#
# markInitialBefore
#
# Name initials before last name.
# TEST	C. Karlsson	C.Karlsson	C Karlsson
#
#**************************************************************#
sub markInitialBefore {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# 2. Other tests - could be done earlier?
	if (
		$t->{orth} =~ /^[$MTM::Vars::uc]$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	# With period and without blanks:	C.Karlsson
	if (
		$rc1->{orth}	 eq '.'
		&&
		&MTM::Legacy::isPossiblyPM( $rc2->{orth}, $rc2->{pos}, $rc2->{isInDictionary} )
	) {
		my $pron = '-';
		if ( my $spelledPron = &MTM::Pronunciation::Pronunciation::Spell( $rc1->{orth} ) ) {
			$pron = $spelledPron;
		}


		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INITIAL' );
		$rc1->{pron} = $pron;
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );
		$t->{pos} = 'PM';
		$t->{morph} = 'NOM';
		$t->{lang} = $MTM::Vars::defaultLang;


		$rc2->{pos} = 'PM';
		$rc2->{morph} = 'NOM';

		# Look for initials in LC
		&initialSpreadLC( $self, $chunk );

		# print STDERR "isSweInitial\tmarkInitialBefore\t$t->{orth} $rc1->{orth} $rc2->{orth}\t$t->{index}\n";
		return $self;

	}

	# Without period and with blanks:		C Karlsson
	if (
		$t->{orth}	ne	'I'		# "I" can be English pronoun, be careful.
		&&
		$rc1->{pos}	 eq 'DEL'
		&&
		&MTM::Legacy::isPossiblyPM( $rc2->{orth}, $rc2->{pos}, $rc2->{isInDictionary} )
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );
		$t->{pos} = 'PM';
		$t->{morph} = 'NOM';
		$t->{lang} = $MTM::Vars::defaultLang;

		$rc2->{pos} = 'PM';
		$rc2->{morph} = 'NOM';

		my $pron = '-';
		if ( my $spelledPron = &MTM::Pronunciation::Pronunciation::Spell( $t->{orth} ) ) {
			$pron = $spelledPron;
		}

		$t->{pron} = $pron;

		# Look for initials in LC
		&initialSpreadLC( $self, $chunk );

		return $self;
	}


	# With period and blanks:		C. Karlsson
	my $rc3base = $chunk->peek(3) or return $self;
	my $rc3 = $rc3base->{LEGACYDATA};


#	print "\n\nmarkInitial_1\n\t$rc1->{pos}\t$rc2->{pos}\n";

	if (
		$rc1->{orth} eq '.'
		&&
		$rc2->{pos} eq 'DEL'
		&&
		&MTM::Legacy::isPossiblyPM( $rc3->{orth}, $rc3->{pos}, $rc3->{isInDictionary} )
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );
		$t->{pos} = 'PM';
		$t->{morph} = 'NOM';
		$t->{lang} = $MTM::Vars::defaultLang;

		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'INITIAL' );

		$rc3->{pos} = 'PM';
		$rc3->{morph} = 'NOM';


		my $pron = '-';
		if ( my $spelledPron = &MTM::Pronunciation::Pronunciation::Spell( $t->{orth} ) ) {
			$pron = $spelledPron;
		}

		$t->{pron} = $pron;

		# Look for initials in LC
		&initialSpreadLC( $self, $chunk );

		return $self;
	}
}
#**************************************************************#
# markInitialAfter
#
# Name initials after last name.
# Example:			Karlsson, C.
#				Karlsson, C
#				Karlsson C,
#
# CT 2020-11-18	Ugly fix only for 'a' after digits
# 			Confusing name of sub. Suggestion: markInitialAfter
#
#**************************************************************#
# TEST	Karlsson C.
sub markInitialAfter {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	#print STDERR "markInitialAfter\t$t->{orth}\n";

	# 2. Other tests
	if (
		$t->{orth} =~ /^[$MTM::Vars::uc]$/
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc1 = $lc1base->{LEGACYDATA};
	my $lc2 = $lc2base->{LEGACYDATA};

	#print STDERR "markInitialAfter2\t$lc2->{orth}\t$lc1->{orth}\t$t->{orth}\n";

	# Without comma			Karlsson C.
	if (
		$lc1->{orth} =~ /^\s+$/
		&&
		&MTM::Legacy::isPossiblyPM( $lc2->{orth}, $lc2->{pos}, $lc2->{isInDictionary} )
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );

		$t->{pos} = 'PM';
		$t->{morph} = 'NOM';
		$t->{lang} = $MTM::Vars::defaultLang;

		$lc2->{pos} = 'PM';
		$lc2->{morph} = 'NOM';
		my $pron = '-';
		if ( my $spelledPron = &MTM::Pronunciation::Pronunciation::Spell( $t->{orth} ) ) {
			$pron = $spelledPron;
		}

		$t->{pron} = $pron;

		# Look for initials in RC
		&initialSpreadRC( $self, $chunk );
	}


	# Without period and blanks:		Karlsson C.
	if (
		$t->{orth}	ne	'I'
		&&
		$lc1->{orth}	 =~ /^\s+$/
		&&
		&MTM::Legacy::isPossiblyPM( $lc2->{orth}, $lc2->{pos}, $lc2->{isInDictionary} )
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );
		$t->{pos} = 'PM';
		$t->{morph} = 'NOM';
		$t->{lang} = $MTM::Vars::defaultLang;


		my $pron = '-';
		if ( my $spelledPron = &MTM::Pronunciation::Pronunciation::Spell( $t->{orth} ) ) {
			$pron = $spelledPron;
		}

		$t->{pron} = $pron;

		# Look for initials in RC
		&initialSpreadRC( $self, $chunk );
	}

	# 1. Check if context exists
	my $lc3base = $chunk->peek(-3) or return $self;

	# Find locations
	my $lc3 = $lc3base->{LEGACYDATA};


	# With comma			Karlsson, C.
	if (
		$lc1->{orth} =~ /^\s+$/
		&&
		$lc2->{orth} eq ','
		&&
		&MTM::Legacy::isPossiblyPM( $lc3->{orth}, $lc3->{pos}, $lc3->{isInDictionary} )
	) {

		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );

		$t->{pos} = 'PM';
		$t->{morph} = 'NOM';
		$t->{lang} = $MTM::Vars::defaultLang;

		$lc3->{pos} = 'PM';
		$lc3->{morph} = 'NOM';
		my $pron = '-';

		if ( my $spelledPron = &MTM::Pronunciation::Pronunciation::Spell( $t->{orth} ) ) {
			$pron = $spelledPron;
		}

		$t->{pron} = $pron;

		# Look for initials in RC
		&initialSpreadRC( $self, $chunk );
	}
	return $self;
}
#**************************************************************#
# markLetterLC		25 a
#
# TEST	25 a
#
# CT 2020-11-18	Ugly fix only for 'a' after digits
# 			Confusing name of sub. Suggestion: markInitialAfterdigit
#**************************************************************#
sub markLetterLC {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# print "markLetterLC $t->{orth}\n";

	# 1. Check if context exists
	my $lc2base = $chunk->peek(-2) or return $self;

	# 2. Other tests
	if (
		$t->{orth} eq 'a'
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $lc2 = $lc2base->{LEGACYDATA};

	if(
		$lc2->{orth} =~ /^\d+$/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'INITIAL' );
	}

	return $self;
}
#**************************************************************#
# sub initialSpreadLC
#
# Looks for more intials in front of the tagged one.
#
# TEST	H. C. Karlsson
#
#**************************************************************#
sub initialSpreadLC {


	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Left context
	# Start with lc1
	my $index = -1;

	# 1. Check if context exists
	my $lc_flag = 1;
	my $lcbase = $chunk->peek($index) or $lc_flag = 0;
	my $lc = $lcbase->{LEGACYDATA};

	if( $lc_flag == 1 ) {

		# Tag as INITIAL until not [\s\.\-] is seen
		while( $lc_flag == 1 && $lc->{orth} =~ /^([\s\.\-]|[$MTM::Vars::uc])$/ ) {
			$lc->{exprType} = MTM::Legacy::get_exprType( $lc->{exprType}, 'INITIAL' );

			$index--;
			$lcbase = $chunk->peek($index) or $lc_flag = 0;
			$lc = $lcbase->{LEGACYDATA};

		}

		# Remove 'INITIAL' from last \s
		$lcbase = $chunk->peek($index-1) or return $self;
		$lc = $lcbase->{LEGACYDATA};
		if( $lc->{orth} =~ /^\s+$/ ) {
			$lc->{exprType} = '-';
		}
	}

	return $self;
}
#**************************************************************#
# sub initial_spreadRC
#
# Looks for more intials after the tagged one.
#
# TEST	Karlsson, H.C
#
#**************************************************************#
sub initialSpreadRC {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Right context
	# Start with rc1
	my $index = 1;

	# 1. Check if context exists
	my $rc_flag = 1;
	my $rcbase = $chunk->peek($index) or $rc_flag = 0;

	my $rc;
	if( $rc_flag == 1 ) {
		$rc = $rcbase->{LEGACYDATA};

		# Tag as INITIAL until not [\s\.\-] is seen
		while( $rc->{orth} =~ /^[\s\.\-]$/ && $rc_flag == 1 ) {
			$rc->{exprType} = MTM::Legacy::get_exprType( $rc->{exprType}, 'INITIAL' );

			$index++;
			my $rcbase = $chunk->peek($index) or $rc_flag = 0;

			if( $rc_flag == 1 ) {
				$rc = $rcbase->{LEGACYDATA};
			}
		}
	}

	# Remove 'INITIAL' from last \s
	$rcbase = $chunk->peek($index-1);
	$rc = $rcbase->{LEGACYDATA};
	if( $rc->{orth} =~ /^\s+$/ ) {
		$rc->{exprType} = '-';
	}


	return $self;
}
#**************************************************************#
1;