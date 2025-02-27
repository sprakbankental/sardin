package MTM::Pronunciation::NumeralPronunciation;

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
# Pronunciation
#
# Language	sv_se
#
# Rules for pronouncing numerals.
#
# Return: pronunciation
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub pronounce {

	my $numeral = shift;

	#print STDERR "\n-------------------------------\ncreateNumeralPronunciation\n\t$numeral\n";

	my @numeral = ();

	###### Move to more common place? Move to Vars.pm.
	my $sv_spaceSurroundings = $MTM::Legacy::Lists::sv_numeral_pron{ 'hundra' } . '|' . $MTM::Legacy::Lists::sv_numeral_pron{ 'tusen' } . '|' . $MTM::Legacy::Lists::sv_numeral_pron{ 'miljon' } . '|' . $MTM::Legacy::Lists::sv_numeral_pron{ 'miljoner' } . '|' . $MTM::Legacy::Lists::sv_numeral_pron{ 'miljard' } . '|' . $MTM::Legacy::Lists::sv_numeral_pron{ 'miljarder' };
	$sv_spaceSurroundings =~ s/\$/\\\$/g;

	my $en_spaceSurroundings = $MTM::Legacy::Lists::en_numeral_pron{ 'hundred' } . '|' . $MTM::Legacy::Lists::en_numeral_pron{ 'thousand' } . '|' . $MTM::Legacy::Lists::en_numeral_pron{ 'million' } . '|' . $MTM::Legacy::Lists::en_numeral_pron{ 'millions' } . '|' . $MTM::Legacy::Lists::en_numeral_pron{ 'billion' } . '|' . $MTM::Legacy::Lists::en_numeral_pron{ 'billions' };
	$en_spaceSurroundings =~ s/\$/\\\$/g;

	# Split numeral
	my $tmpNumeral = $numeral;
	$tmpNumeral = &MTM::Case::makeLowercase( $tmpNumeral );

	if( $MTM::Vars::lang eq 'en' ) {
		$tmpNumeral =~ s/((?:thousand|hundred|(?:twen|thir|for|fif|six|seven|eigh|nine)(?:ty|tieth)))/ $1 /g;
		$tmpNumeral =~ s/-//g;
	} else {
		$tmpNumeral =~ s/((?:tusen|hundra|tjugo|(?:tret|fyr|fem|sex|sjut|åt|nit)tio)(?:n?de)?)/ $1 /g;
	}
	$tmpNumeral =~ &MTM::Legacy::cleanBlanks( $tmpNumeral );


	@numeral = split/(?:\s+|\|)/, $tmpNumeral;
	my @numeralPron = ();
	foreach my $num ( @numeral ) {

		#print STDERR "NUM $num\n";

		# Lookup
		if( $MTM::Vars::lang eq 'en' && exists( $MTM::Legacy::Lists::en_numeral_pron{ $num } )) {
			push @numeralPron, $MTM::Legacy::Lists::en_numeral_pron{ $num };
		} elsif ( $MTM::Vars::lang eq 'sv' && exists( $MTM::Legacy::Lists::sv_numeral_pron{ $num } )) {
			#print STDERR "\n\nNUMERAL $num\t$MTM::Legacy::Lists::sv_numeral_pron{ $num }\n\n";
			push @numeralPron, $MTM::Legacy::Lists::sv_numeral_pron{ $num };
			# print STDERR "\tPushing\t$num\t$MTM::Legacy::Lists::sv_numeral_pron{ $num }\t@numeralPron\n";
		}
	}

	my $numPron = join' ~ ', @numeralPron;

	if( $MTM::Vars::lang eq 'en' ) {
		$numPron =~ s/($en_spaceSurroundings) \~ /$1 \| /g;
		$numPron =~ s/ \~ ($en_spaceSurroundings)/ \| $1/g;
	} else {
		$numPron =~ s/($sv_spaceSurroundings) \~ /$1 \| /g;
		$numPron =~ s/ \~ ($sv_spaceSurroundings)/ \| $1/g;
	}

	# Remove first main stress in e.g. nittiofyra
	$numPron = &MTM::Pronunciation::Stress::numeralStress( $numPron );

	return $numPron;
}
#**************************************************************#
1;
