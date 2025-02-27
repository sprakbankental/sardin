package MTM::Analysis::PhoneNumber;

use parent 'MTM';

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
# PhoneNumber
#
# Language	sv_se
#
# Rules for marking phone numbers.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	&markPhoneNumber( $self, $chunk );	# Tel. 08-444 44 44

	return $self;
}
#**************************************************************#
#
# TEST	Tel. 08-444 44 44	Telefax 08-587 452
#
#**************************************************************#
sub markPhoneNumber {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Check if context exists
	my $rc4base = $chunk->peek(4) or return $self;

	if (
		$t->{orth} =~ /^($MTM::Vars::sv_phone_words)$/i
	) {
		# continue
	} else {
		return $self;
	}

	# Find locations
	my $rc1base = $chunk->peek(1) or return $self;
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc3base = $chunk->peek(3) or return $self;

	my $rc1 = $rc1base->{LEGACYDATA};
	my $rc2 = $rc2base->{LEGACYDATA};
	my $rc3 = $rc3base->{LEGACYDATA};
	my $rc4 = $rc4base->{LEGACYDATA};

	if (
		$rc1->{pos}	eq	'DEL'
		&&
		$rc2->{orth}	=~	/^\d+$/
		&&
		$rc3->{orth}	eq	'-'
		&&
		(
			$rc4->{orth}	=~	/^\d+$/
			||
			$rc4->{orth}	=~	/^\d+ \d+$/
		)
	) {
		$rc2->{exprType} = MTM::Legacy::get_exprType( $rc2->{exprType}, 'PHONE' );
		$rc3->{exprType} = MTM::Legacy::get_exprType( $rc3->{exprType}, 'PHONE' );
		$rc4->{exprType} = MTM::Legacy::get_exprType( $rc4->{exprType}, 'PHONE' );

		# print STDERR "\n\nmarkPhoneNumber\tt $t->{orth}\trc1 $rc1->{pos}\trc2 $rc2->{orth}\trc3 $rc3->{orth}\trc4 $rc4->{orth}\n\n";

		# Spread expression type 'PHONE' from rc4 to the right
		&phoneRC( $self, $chunk, 4 );
	}

	return $self;
}
#**************************************************************#
# phoneRC
#
# Spread expression type 'PHONE' to the right
#
# TEST	08-774 56 65 56 88
#**************************************************************#
sub phoneRC {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};
	my $index = shift;

	# Start with $rc4
	# 1. Check if context exists
	my $rcbase = $chunk->peek($index) or return $self;
	my $rc = $rcbase->{LEGACYDATA};

	my $counter = 0;
	while( $rc->{orth} =~ /^(\d+|\-| )$/ ) {
		$rc->{exprType} = MTM::Legacy::get_exprType( $rc->{exprType}, 'PHONE' );

		$index++;
		my $rcbase = $chunk->peek($index) or return $self;
		$rc = $rcbase->{LEGACYDATA};
	}

	return $self;

#	CT 2020-11-27 Old code if the above doesn't work
#	# Create right context list
#	# Put all orth in a list
#	#my @list = sort( keys( %orth ));
#	
#	#
#	my $seenCurrent = 0;
#	my @rcList = ();
#	foreach my $l ( @list ) {
#		if ( $l eq $index ) {
#			$seenCurrent = 1;
#		} elsif ( $seenCurrent == 1 ) {
#			push @rcList, $l;
#		}
#	}
#
#	# Tag right context as 'PHONE' until field is not digits or blank
#	my $seenOther = 0;
#	foreach my $rRC ( @rcList ) {
#
#		if ( $orth{ $rRC } !~ /^(\d+|\-| )$/ ) {
#			$seenOther = 1;
#		}
#		if ( $seenOther == 0 ) {
#			&insertExprType( $rRC, 'PHONE' );
#		}
#	}
#
}
#**************************************************************#
1;
