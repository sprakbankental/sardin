package MTM::Analysis::Reference;

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
# Filename
#
# Language	sv_se
#
# Rules for marking Filenames.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
my $rc_law_found = 0;
my $lc_law_found = 0;

sub markup {

	my $self = shift;
	my $chunk = shift;

	# 1. Surround nested reference expressions
	# Det står i <REFEXP>2 kap. 18 § 2 st.</REFEXP>

	# 2. Parse: much more easy when we know where it begins and ends
	#    Now we can differ between "st." in references and in "2 st. karameller".
	# Det står i <REFEXP><KAP>2 kap.</KAP> <PARA>18 §</PARA> <ST>2 st.</ST></REFEXP>

	# Removed  st.?, is not REFERENCE without § or kap.	210914
	my @ref_types = qw( §§? kap.?);	### TODO Move to vars

	# Mark everything as REFERENCE
	foreach my $ref_type( @ref_types ) {
		markReferences( $self, $chunk, $ref_type );
	}

	return $self;
}
#**************************************************************#
sub markReferences{
	my $self = shift;
	my $chunk = shift;
	my $ref_type = shift;

	$ref_type =~ s/\./\\\./g;

	my $t = $self->{LEGACYDATA};

	# print STDERR "t $ref_type\t$t->{orth}\n";

	# Start from § kap. st
	if( $t->{orth} !~ /^$ref_type$/ || $t->{exprType} =~ /REFERENCE/ ) {
		return $self;
	}

	#print STDERR "markReferences\t$t->{orth}\n";

	my @extend_context = ();
	my $lc1_flag = 1;
	my $lc2_flag = 1;
	my $rc1_flag = 1;
	my $rc2_flag = 1;

	# Left context check
	my $lc1base = $chunk->peek(-1) or $lc1_flag = 0;
	if( $lc1_flag == 1 ) {
		my $lc1 = $lc1base->{LEGACYDATA};
		if( $lc1->{orth} =~ /^(\d+|[a-z])$/i ) {
			push @extend_context, 'lc';
		} else {
			my $lc2base = $chunk-> peek(-2) or $lc2_flag = 0;
			if( $lc2_flag == 1 ) {
				my $lc2 = $lc2base->{LEGACYDATA};

				#print STDERR "lc2 $lc2->{orth}\tlc1 $lc1->{orth} t $t->{orth}\n";
				if( $lc2->{orth} =~ /^(\d+|[a-z])$/i && $lc1->{orth} eq ' ' ) {
					push @extend_context, 'lc';
				}
			}
		}
	}

	# Right context check
	my $rc1base = $chunk->peek(1) or $rc1_flag = 0;
	if ( $rc1_flag == 1 ) {
		my $rc1 = $rc1base->{LEGACYDATA};
		if( $rc1->{orth} =~ /^(\d+|[a-z])$/i ) {
			push @extend_context, 'rc';
		} else {
			my $rc2base = $chunk-> peek(2) or $rc2_flag = 0;
			if( $rc2_flag == 1 ) {
				my $rc2 = $rc2base->{LEGACYDATA};
				if( $rc1->{orth} eq ' ' && $rc2->{orth} =~ /^(\d+|[a-z])$/i ) {
					push @extend_context, 'rc';
				}
			}
		}
	}

	foreach my $ext ( @extend_context ) {
		if( $ext eq 'lc' ) {
			&extend_lc_markup( $self, $chunk );
		}
		if( $ext eq 'rc' ) {
			&extend_rc_markup( $self, $chunk );
		}
	}
	return $self;
}
#**************************************************************#
sub extend_lc_markup {

	my $self = shift;
	my $chunk = shift;
	my $ref_type = shift;

	my $t = $self->{LEGACYDATA};

	my $index = 0;

	my $base_obj = $t;

	#print STDERR "extend_lc\t$t->{orth}\n";

	# Markup start position
	$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'REFERENCE' );

	# We know that there are reference-ish stuff to the left, just go.
	$index--;
	my $lcbase = $chunk->peek($index) or return $self;
	my $lc = $lcbase->{LEGACYDATA};
	my $lc_flag = 1;

	my $digits_position = 0;

	# Walk through left context until seeing something unreference-ish
	while( $lc_flag == 1 && $lc->{orth} =~ /^(\d+|[a-z]| |,|-|och|till|§+|kap\.?|st\.?)$/i ) {

		# Mark as REFERENCE
		$lc->{exprType} = MTM::Legacy::get_exprType( $lc->{exprType}, 'REFERENCE' );

		# print STDERR "$index\t$lc->{orth}\t$lc->{exprType}\n";

		# Save position for digits last seen
		$digits_position = $index if( $lc->{orth} =~ /^\d+$/ );

		# Go lc
		$index--;

		$lcbase = $chunk->peek($index) or $lc_flag = 0;
		$lc = $lcbase->{LEGACYDATA};
	}


	# Walk through right context and remove REF markup in rc until $digits_position is found.

	my $rc_flag = 1;

	my $i = $index;
	until( $i == $digits_position ) {

		my $targetbase = $chunk->peek($digits_position) or warn "No peek $i";
		my $tb = $targetbase->{LEGACYDATA};

		my $rcbase = $chunk->peek($i) or $rc_flag = 0;

		if( $rc_flag == 1 ) {
			my $rc = $rcbase->{LEGACYDATA};

			$rc->{exprType} = MTM::Legacy::remove_exprType( $rc->{exprType}, 'REFERENCE' );
			#print STDERR "Removing REF from $rc->{orth}\t$i\t$digits_position\n";
		}

		$rc_flag = 1;

		$i++;
	}

	return $self;
}
#**************************************************************#
sub extend_rc_markup {

	my $self = shift;
	my $chunk = shift;
	my $ref_type = shift;

	my $t = $self->{LEGACYDATA};

	my $index = 0;

	my $base_obj = $t;

	#print STDERR "extend_rc\t$t->{orth}\n";

	# Markup start position
	$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'REFERENCE' );

	# We know that there are reference-ish stuff to the right, just go.
	$index++;
	my $rcbase = $chunk->peek($index) or return $self;
	my $rc = $rcbase->{LEGACYDATA};

	my $last_safe_markup = 0;

	# Walk through left context until seeing something unreference-ish
	while( $rc->{orth} =~ /^(\d+|[a-z]| |,|-|och|till|§+|kap\.?|st\.?)$/i ) {

		# Mark as REFERENCE
		$rc->{exprType} = MTM::Legacy::get_exprType( $rc->{exprType}, 'REFERENCE' );

		# Save position for digits last seen
		$last_safe_markup = $index if( $rc->{orth} =~ /^(\d+|[a-z]|§+|kap\.?|st\.?)$/ );

		# Go rc
		$index++;

		$rcbase = $chunk->peek($index) or return $self;
		$rc = $rcbase->{LEGACYDATA};

	}

	# Walk through right context and remove REF markup in rc until $digits_position is found.
	my $i = $index;
	my $lc_flag = 1;
	until( $i == $last_safe_markup || $lc_flag == 0 ) {

		#print STDERR "$i\t$last_safe_markup\n";

		my $lcbase = $chunk->peek($i) or $lc_flag = 0;
		my $lc = $lcbase->{LEGACYDATA};

		$lc->{exprType} = MTM::Legacy::remove_exprType( $lc->{exprType}, 'REFERENCE' );
		#print STDERR "Removing REF from $lc->{orth}\t$i\t$last_safe_markup\n";

		$i--;
	}

	return $self;
}
#**************************************************************#
1;
