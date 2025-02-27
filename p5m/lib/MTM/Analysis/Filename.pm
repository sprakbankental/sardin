package MTM::Analysis::Filename;

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
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	&markFilename( $self, $chunk );

	return $self;
}
#**************************************************************#
sub markFilename {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc1base = $chunk->peek(1) or return $self;

	if (
		$t->{orth} =~ /^[A-Z]$/i
	) {
		# continue
	} else {
		return 0;
	}

	# Find locations
	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};

	if (
		$rc1->{orth} eq ':'
		&&
		$rc2->{orth} =~ /^[\/\\]$/
	) {
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'FILENAME' );
		$rc1->{exprType} = MTM::Legacy::get_exprType( $rc1->{exprType}, 'FILENAME' );
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'FILENAME' );

		# Start with rc3
		my $index = 3;

		# 1. Check if context exists
		my $rcbase = $chunk->peek($index) or return $self;
		my $rc = $rcbase->{LEGACYDATA};

		# Tag as FILENAME until whitespace is seen
		while( $rc->{orth} !~ /\s/ ) {
			$rc->{exprType} = MTM::Legacy::get_exprType( $rc->{exprType}, 'FILENAME' );

			$index++;
			my $rcbase = $chunk->peek($index) or return $self;
			$rc = $rcbase->{LEGACYDATA};
		}

		return $self;
	}				
	return $self;
}
#**************************************************************#
1;
