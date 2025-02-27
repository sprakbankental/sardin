package MTM::Analysis::Ordinal;

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
# Ordinal
#
# Language	sv_se
#
# Rules for marking ordinals.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;

	# Swedish ordinals are handled in PoS tagger
	&markOrdinal( $self, $chunk ) if $MTM::Vars::lang eq 'en';

	return $self;
}
#**************************************************************#
# TEST	3:e	17§	5 kapitlet
#**************************************************************#
sub markOrdinal {	# return: markup

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# With ending		3:rd
	if (
		$t->{orth} =~ /^\d+(\,\d\d\d)*($MTM::Vars::en_ordinal_endings)$/
	) {
		$t->{pos} = 'RO';
		#$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ORDINAL' );
		return $self;
	}

	$t->{pos} eq 'RG' or return $self;

	# 17§
	# 1. Check if context exists
	my $rc1base = $chunk->peek(1) or return $self;
	my $rc1 = $rc1base->{LEGACYDATA};

	if (
		$rc1->{orth} =~ /^($MTM::Vars::en_ordinal_words)$/i		# §§
		#||
		#$rc1->{orth} eq '§'
	) {
		$t->{pos} = 'RO';
		#$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ORDINAL' );
	}

	# 17 §
	# 1. Check if context exists
	my $rc2base = $chunk->peek(2) or return $self;
	my $rc2 = $rc2base->{LEGACYDATA};

	# 200520 Added §
	if (
		$rc2->{orth} =~ /^($MTM::Vars::en_ordinal_words)$/i		# |\§
	) {
		$t->{pos} = 'RO';
		#$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ORDINAL' );
	}
	return $self;
}
#**************************************************************#
1;
