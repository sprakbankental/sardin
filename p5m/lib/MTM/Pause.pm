package MTM::Pause;

#**************************************************************#
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
# Pause
#
# Language	sv_se
#
# Rules for inserting pauses.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
# Insert pauses at MID and PAD
sub pause {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	if (
		$t->{morph} =~ /(MID|PAD)/i
		&&
		$t->{exp} =~ /^(?:DEFAULT|-)$/
		&&
		$t->{exprType} =~ /^(?:DEFAULT|-)$/
	) {
		$t->{pause} = $MTM::Vars::shortPause;
	}

	return 1;
	#print STDERR"\tpause.pm+n\t\t$t->{orth}\t$t->{morph}\t$t->{exp}\t$t->{exprType}\t$t->{pause}\n";
}
#**************************************************************#


1;