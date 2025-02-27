package MTM::Analysis::Email;

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
# Email
#
# Language	sv_se
#
# Rules for marking email addresses.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	&markEmail( $self, $chunk );

	return $self;
}
#**************************************************************#
#
# TEST	svd@svd.se	lisa.larsson_99@comhem.com
#**************************************************************#
sub markEmail {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc3base = $chunk->peek(3) or return $self;
	my $lc1base = $chunk->peek(-1) or return $self;

	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	if (
		$t->{orth} eq '@'
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $lc1 = $lc1base->{LEGACYDATA};

	if (
		$t->{orth} eq '@'
		&&
		$lc1->{pos} ne 'DEL'
		&&
		$rc1->{pos} ne 'DEL'
		&&
		$rc2->{orth} eq '.'
		&&
		$rc3->{orth} ne 'DEL'
	) {
		$lc1->{exprType} = 'EMAIL';
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'EMAIL' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'EMAIL' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'EMAIL' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'EMAIL' );

		# Right context
		# Start with rc3
		my $index = 3;

		# 1. Check if context exists
		my $rc_flag = 1;
		my $rcbase = $chunk->peek($index) or $rc_flag = 0;

		if( $rc_flag == 1 ) {

			my $rc = $rcbase->{LEGACYDATA};
			# Tag as EMAIL until whitespace is seen
			while( $rc_flag == 1 && $rc->{orth} !~ /\s/ ) {
				$rc = $rcbase->{LEGACYDATA};
				$rc->{exprType} = 'EMAIL';

				$index++;
				my $rcbase = $chunk->peek($index) or $rc_flag = 0;
				#$rc = $rcbase->{LEGACYDATA};
			}
		}


		# Left context
		# Start with lc1
		# Tag as EMAIL until whitespace is seen
		$index = -1;

		# 1. Check if context exists
		my $lcbase = $chunk->peek($index) or return $self;
		my $lc = $lcbase->{LEGACYDATA};
		while( $lc->{orth} !~ /\s/ ) {
			$lc->{exprType} = MTM::Legacy::get_exprType( $lc->{exprType}, 'EMAIL' );

			$index--;
			my $lcbase = $chunk->peek($index) or return $self;
			$lc = $lcbase->{LEGACYDATA};
		}

		return $self;
	}
	return $self;
}
#**************************************************************#
1;
