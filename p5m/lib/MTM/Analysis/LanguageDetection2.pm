package MTM::Analysis::LanguageDetection2;

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
# LanguageDetection2
#
# Language	sv_se
#
# Rules for Swedish/English
# Second part, is preceded by LanguageDetection.pm
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#


#***************************************************************#
# LanguageDetection2
#***************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	#***********************************************************#
	# Apply context rules
	&context_rules( $self, $chunk ) if $t->{lang} =~ /(sv_en|unknown)/;


	# it and English is not an acronym
	if( $t->{lang} eq 'eng' && $t->{orth} =~ /^it$/i && $t->{exprType} eq 'ACRONYM' ) {
		$t->{exprType} = '-';
		$t->{pos} = 'VB';
		$t->{pron} = '-';
	}

	# 240124
	$t->{lang} =~ s/sv_en/swe/;

	return $self;
}
#***************************************************************#
# context_rules
# Context rules for specific words.
#***************************************************************#
sub context_rules {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# Get context
	my $lc2_flag = 1;
	my $lc2base = $chunk->peek(-2) or $lc2_flag = 0;
	my $lc2;
	$lc2 = $lc2base->{LEGACYDATA} if $lc2_flag == 1;

	my $rc1_flag = 1;
	my $rc2_flag = 1;
	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;
	my $rc2base = $chunk->peek(2) or $rc2_flag = 0;
	my $rc1;
	my $rc2;
	$rc1 = $rc1base->{LEGACYDATA} if $rc1_flag == 1;
	$rc2 = $rc2base->{LEGACYDATA} if $rc2_flag == 1;

	# No context, do not test rules
	return $self if $lc2_flag == 0 && $rc2_flag == 0;

	my $swedish_context = 0;
	my $english_context = 0;
	my $no_swedish_context = 0;
	my $no_english_context = 0;
	my $pm_context = 0;

	# print "UK	$t->{orth}\t$t->{lang}	lc $lc2_flag	rc $lc2_flag\n";

	#print "LanguageDetection2	$t->{orth}	$lc2->{orth}	$t->{orth}	$rc2->{orth}\n";
	#print "LanguageDetection2	$t->{orth}	$lc2->{lang}	$t->{lang}	$rc2->{lang}\n";
	#print "LanguageDetection2	$t->{orth}	$lc2->{pos}	$t->{pos}	$rc2->{pos}\n\n";


	if( $lc2_flag == 1 && $rc2_flag == 1 ) {


		#print "$t->{orth}\tlc $lc2->{lang}	rc $rc2->{lang}\n";

		# Swedish (only) at both sides
		$swedish_context = 1 if $lc2->{lang} eq 'swe' && $rc2->{lang} eq 'swe';

		# English (only) at both sides
		$english_context = 1 if $lc2->{lang} eq 'eng' && $rc2->{lang} eq 'eng';

		# Not Swedish at both sides
		$no_swedish_context = 1 if $lc2->{lang} !~ /swe/ || $rc2->{lang} !~ /swe/;

		# Not English at both sides
		$no_english_context = 1 if $lc2->{lang} !~ /eng/ || $rc2->{lang} !~ /eng/;

		# Proper names at both sides
		$pm_context = 1 if $lc2->{pos} =~ /PM/ && $rc2->{pos} =~ /PM/;
	}

	#print "LanguageDetection2	$t->{orth}	$lc2->{lang}	$t->{lang}	$rc2->{lang}	not_sv_surr $no_swedish_context\n\n";


	# international, or, at, to
	if( $no_swedish_context == 1 ) {
		if( $t->{orth} =~ /^(international|or|at|to|and)$/i ) {
			$t->{lang} = 'eng';
			return $self;
		}
	}

	# i (lowercase)
	if( $no_english_context == 1 ) {
		if ( $t->{orth} eq 'i' ) {
			$t->{lang} = 'swe';
			return $self;
		}
	}

	# Between proper names
	if( $pm_context == 1 ) {
		# and,  or
		if( $t->{orth} =~ /^(and|or)$/i ) {
			$t->{lang} = 'eng';
			return $self;
		}
	}

	# Right context is English
	if( $rc2_flag == 1 && $rc2->{lang} =~ /eng/ ) {
	 	# by, the, it, human, a
	 	if( $t->{orth} =~ /^(by|the|it|human|a)$/i ) {
	 		$t->{lang} = 'eng';
	 		return $self;
	 	}
	}

	# Right context is "the"
	if( $rc2_flag == 1 && $rc2->{orth} =~ /^the$/i ) {
	 	# at
	 	if( $t->{orth} =~ /^(at)$/i ) {
	 		$t->{lang} = 'eng';
	 		return $self;
	 	}
	}

	# Right context is "the" or "at", current token is possibly English
	if( $rc2_flag == 1 && $rc2->{orth} =~ /^(the|at)$/i ) {
	 	# at
	 	if( $t->{lang} eq 'sv_en' ) {
	 		$t->{lang} = 'eng';
	 		return $self;
	 	}
	}

	#***************************************************************#
	# General rules

	if( $lc2_flag == 1 && $rc2_flag == 1 ) {

		# lc and rc English only
		if( $english_context == 1 ) {
			$t->{lang} = 'eng';
			return $self;
		}

		# lc and rc Swedish only
		if( $swedish_context == 1 ) {
			$t->{lang} = 'swe';
			return $self;
		}

		# lc English only, rc possibly English
		if( $lc2->{lang} eq 'eng' && $rc2->{lang} eq 'sv_en' ) {
			$t->{lang} = 'eng';
			return $self;
		}

		# lc possibly English , rc English only
		if( $lc2->{lang} eq 'sv_en' && $rc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}

		# lc delimiter, rc English only
		if( $lc2->{pos} =~ /DL/ && $rc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}

		# lc English only, rc1 delimiter
		if( $lc2->{lang} eq 'eng' && $rc1->{pos} =~ /DL/ ) {
			$t->{lang} = 'eng';
			return $self;
		}

		# rc English only	plausible to overgenerate from time to time
		if( $rc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}


	# no lc2, rc2 exists
	} elsif( $lc2_flag == 0 && $rc2_flag == 1 ) {
		# first word in string,
		if( $rc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}

	# lc2 exists, no rc2
	} elsif( $lc2_flag == 1 && $rc2_flag == 0 ) {
		# last word in string,
		if( $lc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}

	# The following two rules take out the previous two rules
	} elsif( $lc2_flag == 1 ) {
		# lc is English only
		if( $lc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}
	} elsif( $rc2_flag == 1 ) {
		# rc is English only
		if( $rc2->{lang} eq 'eng' ) {
			$t->{lang} = 'eng';
			return $self;
		}
	}

	$t->{lang} = 'swe';
	return $self;
}
#***************************************************************#
1;
