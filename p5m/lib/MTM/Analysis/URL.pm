package MTM::Analysis::URL;

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
# URL
#
# Language	sv_se
#
# Rules for marking URLs.
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
		$t->{exprType} !~ /^time/
	) {
		&isURLwww( $self, $chunk );
		&isURLnaked( $self, $chunk );
	}

	return $self;
}
#**************************************************************#
# isURLwww
#
# TEST	www.tpb.se
#
#**************************************************************#
sub isURLwww {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	if (
		$t->{orth}	=~ /^(www|https?)$/
	) {

		# Find locations
		my $rc1 = $rc1base->{LEGACYDATA};
		my $rc2 = $rc2base->{LEGACYDATA};

		if (
			$rc1->{orth} =~ /^[\:\.\/]+$/
		) {

			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'URL');
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'URL');

			# Start with rc2
			my $index = 2;
			# 1. Check if context exists
			my $rcbase = $chunk->peek($index) or return $self;
			my $rc = $rcbase->{LEGACYDATA};

			# Tag as URL until whitespace is seen
			while( $rc->{orth} !~ /\s/ ) {
				$rc->{exprType} = MTM::Legacy::get_exprType( $rc->{exprType}, 'URL');

				$index++;
				my $rcbase = $chunk->peek($index) or return $self;
				$rc = $rcbase->{LEGACYDATA};
			}

			return $self;
		}				
	}
	return $self;
}
#**************************************************************#
# isURLnaked
#
# TEST	svd.tb.se
#
#**************************************************************#
sub isURLnaked {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	# Import vars
	my $lc = $MTM::Vars::lc;

	if (
		$t->{orth} =~ /[$lc][$lc]/
		&&
		$t->{exprType} !~ /EMAIL/
	) {
		# Find locations
		my $rc1 = $rc1base->{LEGACYDATA};
		my $rc2 = $rc2base->{LEGACYDATA};

		if (
			$rc1->{orth} eq '.'
			&&
			# top domains
			$rc2->{orth} =~ /^($MTM::Vars::tld)$/
		) {

			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'URL');
			$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'URL');

			# Start with rc2
			my $index = 1;
			# 1. Check if context exists
			my $rcbase = $chunk->peek($index) or return $self;
			my $rc = $rcbase->{LEGACYDATA};

			# Tag as URL until whitespace is seen
			while( $rc->{orth} !~ /\s/ ) {
				$rc->{exprType} = MTM::Legacy::get_exprType( $rc->{exprType}, 'URL');

				$index++;
				my $rcbase = $chunk->peek($index) or return $self;
				$rc = $rcbase->{LEGACYDATA};
			}

			return $self;		

		}
	}

	return $self;
}
#**************************************************************#
1;
