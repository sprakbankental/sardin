package MTM::Pronunciation::Swedify;

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
# Swedify
#
# Language	sv_se
#
# Rules for swedifying English pronunciations.
#
# Return: markup and expansion
#
# test exists		210817
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub swedify {
	my $pron = shift;

	# print STDERR "\n---------------------------\nSwedify\n\t$pron\t";

	$pron =~ s/ei/e j/g;
	$pron =~ s/ai/a j/g;
	$pron =~ s/oi/o j/g;

	$pron =~ s/eex/ae:/g;
	$pron =~ s/iex/e:/g;

	$pron =~ s/rh/r/g;

	# print STDERR "\n---------------------------\nSwedify\n\t$pron\n";

	return $pron;
}
#**************************************************************************************#
1;