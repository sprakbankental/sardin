package MTM::Expansion::ReferenceExpansion;

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
# ReferenceExpansion
#
# Language	sv_se
#
# Rules for reference expansions.
#
# Return: expansions
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
# To consider
# Pre-preprocess function to see which reference pattern the text follows,
# reporting when law word is placed differently.
#**************************************************************#
sub expand {

	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	# print STDERR "\n\nexpand reference $t->{orth}\t$t->{exprType}\n\n";

	# Current token is marked as REFERENCE
	if( $t->{exprType} =~ /REFERENCE/ ) {

		my $go = 1;

		# Check lc - don't continue if lc is marked as REFERENCE (just start once)
		my $lc1_flag = 1;
		my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;

		if( $lc1_flag == 1 ) {
			my $lc1 = $lc1base->{LEGACYDATA};
			if( $lc1->{exprType} =~ /REFERENCE/ ) {
				$go = 0;
			}
			# print STDERR "Start expansion: $t->{orth}\t$lc1->{orth}\n";
		}

		return $self if $go == 0;

		# print STDERR "\nGO: $t->{orth}\n";

		my @ref_types = qw( §§? kap.? st.?);	### TODO Move to vars
		my $ref_types = join'|', @ref_types;
		$ref_types =~ s/\./\\\./g;

		# § 17
		if( $t->{orth} =~ /^($ref_types)$/ ) {
			#print STDERR "\nExpanding reference start - unit first: $t->{orth}\n";
			&expand_unit_first( $self, $chunk );

		# 17 §
		} else {
			#print STDERR "\nExpanding reference start - unit last: $t->{orth}\n";
			&expand_unit_last( $self, $chunk );
		}
	}
	return 1;
}
#**************************************************************#
# 17 §
sub expand_unit_last {
	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	my $i = 0;

	my $rcbase = $chunk->peek($i) or return $self;
	my $rc = $rcbase->{LEGACYDATA};
	my $rc_flag = 1;

	my $saved_i = $i;
	my $reset_saved_i = 0;


	# Walk rc until found law word
	### TODO put regex in vars
	while( $rc_flag == 1 ) {

		#print STDERR "unit_last while $rc->{orth}\t$i\t$saved_i\n";

		# Law word found: insert expansion
		if( $rc->{orth} =~ /^(§§?|kap\.?)$/ ) {

			#print STDERR "found $rc->{orth}\t$i\t$saved_i\n";

			my $targetbase = $chunk->peek($saved_i) or return $self;
			my $target = $targetbase->{LEGACYDATA};

			$target->{exp} = &law_word_expansion( $rc->{orth} ) . '|' . $target->{exp};
			$rc->{exp} = '<none>';

			# Reset $saved_i
			$reset_saved_i = 1;

		} elsif ( $rc->{orth} =~ /^st\.?/ ) {
			$rc->{exp} = 'stycket';

		} elsif( $rc->{orth} =~ /^\d+$/ ) {

			my $rc2_flag = 1;
			my $rc2base = $chunk->peek($i+2) or $rc2_flag = 0;
			my $exp_done = 0;

			# Ordinal if next word is 'st.'	
			if( $rc2_flag == 1 ) {
				my $rc2 = $rc2base->{LEGACYDATA};

				if( $rc2->{orth} =~ /^st\.?$/ ) {
					$rc->{exp} = &MTM::Expansion::NumeralExpansion::makeOrthographyOrdinal( $rc->{orth}, $rc->{exprType}, $rc->{pos}, $rc->{morph} );
					$exp_done = 1;
				}
			}

			# Else cardinal
			$rc->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc->{orth}, $rc->{exprType}, $rc->{pos}, $rc->{morph} ) if $exp_done == 0;

			$saved_i = $i if $reset_saved_i == 1;
			$reset_saved_i = 0;

		} elsif( $rc->{orth} =~ /^[a-z]$/ ) {
			$rc->{pron} = &MTM::Pronunciation::Pronunciation::Spell( $rc->{orth} );
			$rc->{pos} = 'NN';

		} elsif( $rc->{orth} eq '-' ) {
			$rc->{exp} = 'till';
			$rc->{pos} = 'PP';
		}

		$i++;

		my $rcbase = $chunk->peek($i) or return $self;
		$rc = $rcbase->{LEGACYDATA};
		$rc_flag = 0 if $rc->{exprType} !~ /REFERENCE/;

	}

	return $self;
}
#**************************************************************#
# § 17
sub expand_unit_first {
	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	my $i = 0;

	my $rcbase = $chunk->peek($i) or return $self;
	my $rc = $rcbase->{LEGACYDATA};
	my $rc_flag = 1;

	my $stycke_flag = 0;

	while( $rc_flag == 1 ) {

		# print STDERR "unit_first while $rc->{orth}\t$i\n";

		if( $rc->{orth} =~ /^(§§?|kap\.?)$/ ) {
			$rc->{exp} = &law_word_expansion( $rc->{orth} );

		} elsif ( $rc->{orth} =~ /^st\.?/ ) {
			$rc->{exp} = '<none>';
			$stycke_flag = 1;

			# print STDERR "STYCKE $rc->{orth}\t$rc->{exp}\n";

		} elsif( $rc->{orth} =~ /^\d+$/ ) {
			# Preceeded by 'st.'
			if( $stycke_flag == 1 ) {

				my $ordinal = &MTM::Expansion::NumeralExpansion::makeOrthographyOrdinal( $rc->{orth}, $rc->{exprType}, $rc->{pos}, $rc->{morph} );

				$rc->{exp} = "$ordinal|stycket";
				$stycke_flag = 0;

				# print STDERR "STYCKENR $rc->{orth}\t$rc->{exp}\n";

			# Not preceeded by 'st.'
			} else {
				$rc->{exp} = &MTM::Expansion::NumeralExpansion::expand_numeral( $rc->{orth}, $rc->{exprType}, $rc->{pos}, $rc->{morph} );
			}

		} elsif( $rc->{orth} =~ /^[a-z]$/ ) {
			$rc->{pron} = &MTM::Pronunciation::Pronunciation::Spell( $rc->{orth} );
			$rc->{pos} = 'NN';

		} elsif( $rc->{orth} eq '-' ) {
			$rc->{exp} = 'till';
			$rc->{pos} = 'PP';
		}

		$i++;

		my $rcbase = $chunk->peek($i) or return $self;
		$rc = $rcbase->{LEGACYDATA};
		$rc_flag = 0 if $rc->{exprType} !~ /REFERENCE/;
	}

	return $self;
}
#**************************************************************#
sub law_word_expansion {

	my $law_token = shift;

	return 'paragraf' if $law_token eq '§';
	return 'paragraferna' if $law_token eq '§§';	### TODO check if 'paragraf' is better.
	return 'kapitel' if $law_token =~ /^kap\.?/i;
	return 'stycke' if $law_token =~ /^st\.?/i;
	return 1;
}
#**************************************************************#


1;