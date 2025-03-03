package MTM::Analysis::Acronym;

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
# Acronym
#
# Language	sv_se
#
# Rules for acronyms that should be spelled out.
# Other acronyms are treated as normal words.
#
# Return: markup and expansion
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
my $current_lang = 'swe';
$current_lang = 'eng' if $MTM::Vars::lang eq 'en';

use MTM::Pronunciation::Pronunciation;

sub markup {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $orth = $t->{orth};


	# Maximum number of tokens in string to be regarded an acronym
	my $nMaxTokens = 5;

	# Exists in dictionaries?
	my $isInDictionary = $t->{isInDictionary};

	# Letter count
	my $nTokens = length( $orth );

	if (
		# Expression expr is not these vaules
		$t->{exprType} !~ /(ABBREVIATION|BIBLICREF|FILENAME|ROMAN)/
		&&
		$t->{orth} =~ /[a-zåäöæøÅÄÖ]/i
		&&
		# Maximum number of tokens	TODO
#		$nTokens <= $nMaxTokens
#		&&
		(
			# Is not in dictionary
			#$t->{isInDictionary} == 0
			$t->{isInDictionary} !~ /1/		##### CT 2020-12-07 Temporary solution, we haven't put anything in this list yet.
		)
		&&
		# Is pre-defined acronym format
		&isAcronymFormat( $self, $chunk )
	) {
		my $acronymDone = 0;

		$acronymDone = &markAcronymFirstInCompound( $self, $chunk );
		#print STDERR "markAcronymFirstInCompound\t$acronymDone\t$t->{orth}\t$t->{exprType}\t$t->{pron}\n";
		$acronymDone = &markAcronymLastInCompound( $self, $chunk );
		#print STDERR "markAcronymLastInCompound\t$acronymDone\n";
		$acronymDone = &markAcronym( $self, $chunk ) if $acronymDone == 0;
		#print STDERR "markAcronym\t$acronymDone\n";
		$acronymDone = &isPossibleAcronym( $self, $chunk ) if $acronymDone == 0;
		#print STDERR "isPossibleAcronym\t$acronymDone\n";

	}
	return $self;
}
#**************************************************************#
# isAcronymFirstInCompound
#
# Compounds with acronym in acronym dictionary as first part.
#
# Test:	S-E-banken	ATG-ombud
#
#**************************************************************#
sub markAcronymFirstInCompound {	# return: markup and flag (1/0)

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $acronymDone = 0;

	#print STDERR "isAcronymFirstInCompound\t$t->{orth}\n";

	if (
		&MTM::Legacy::isDefault( $t->{pron} )
		&&
		(
			( $MTM::Vars::lang eq 'sv' && $t->{orth} =~ /^($MTM::Legacy::Lists::sv_acronym_list|[$MTM::Vars::letter])-(.+)$/i )
			||
			( $MTM::Vars::lang eq 'en' && $t->{orth} =~ /^($MTM::Legacy::Lists::en_acronym_list|[$MTM::Vars::letter])-(.+)$/i )
		)
		&&
		$t->{orth} !~ /^([$MTM::Vars::letter])-([$MTM::Vars::letter])-([$MTM::Vars::letter])$/i
	) {
		my $acronym = $1;
		my $wdPart = $2;

		# print STDERR "isAcronymFirstInCompound\t$acronym\t$wdPart\n";

		# Acronym lookup case insensitive
		my ( $firstPron, $firstPos, $firstMorph, $firstLang ) =  split/\t/, &acronymLookup( $acronym, 'caseInsensitive' );

		# Lookup last part in any dictionary
		my ( $lastPron, $lastPosMorph, $lastOrtlang, $lastPronlang, $decomposed, $pronMethod, $id ) = &MTM::Pronunciation::Pronunciation::pronounce( $self, $chunk, $wdPart );

		#print STDERR "isAcronymFirstInCompound\t$lastPron, $lastPosMorph, $lastOrtlang, $lastPronlang, $decomposed, $pronMethod, $id\n";

# CT 240512 this doesn't do anything
#		# Last part is not in dictionary, use automatic methods
#		if ( &MTM::Legacy::isDefault( $lastPron )) {
#			my $orth = &MTM::Case::makeLowercase( $wdPart );
#
#			# Create automatic pronunciation
#			#( $lastPron, $lastPos, $lastMorph, $lastLang ) = &createSweAutopron( $index, $wdPart );
#			my $domain = $current_lang;
#
#			# 200123 Ugly fix to avoid error in cart tree for wordLookup.pl
#			if( $MTM::Vars::runmode ne 'wordLookup' ) {
#				##### CT 2020-12-07 WAIT with this one, not committed
#				#$lastPron = &MTM::Pronunciation::Autopron::cartAndStress( $orth, $domain );
#				$lastPron = '-';
#			}
#		}

		# Stress
		#$firstPron = &firstPartStress( $firstPron );
		#$lastPron = &lastPartStress( $lastPron );

		# Concatenate compound with hyphen
		my $pron = '-';
		if( $firstPron ne '-' && $lastPron ne '-' ) {
			$pron = "$firstPron - $lastPron"
		}

		if( $MTM::Vars::lang eq 'en' ) {
			$pron = &MTM::Pronunciation::Stress::en_compound_stress( $pron );
		} else {
			$pron = &MTM::Pronunciation::Stress::sv_compound_stress( $pron );
		}

		my $lastPos = $lastPosMorph;
		my $lastMorph = '-';
		if ( $lastPosMorph =~ /^(..) (.+)$/ ) {
			$lastPos = $1;
			$lastMorph = $2;
		}

		# Insert fields
		$t->{pron} = $pron;
		$t->{pos} = $lastPos;
		$t->{morph} = $lastMorph;
		$t->{lang} = $lastOrtlang;
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ACRONYM COMPOUND' );

		# print STDERR "isAcronymFirstInCompound\t$t->{orth}\t$wdPart\t$acronym\n";

		# CT 2020-12-07 Do we use these?
		$t->{ortlang} = $lastOrtlang;
		$t->{pronlang} = $lastPronlang;

		# CT 200610 %dec was empty
		my $dec = $t->{orth};
		$dec =~ s/-/\+-\+/g;
		$t->{dec} = $dec;

		# print STDERR "sweAcronymMarkup\tisAcronymFirstInCompound\n\t$t->{orth}\n$t->{exprType}\n$t->{pron}\DEC $t->{dec}\n";

		$acronymDone = 1;
	}

	return $acronymDone;
}
#**************************************************************#
# isAcronymLastInCompound
#
# Compounds with acronym in acronym dictionary as first part.
# Example:	bank-ID
#		marknads-VD
#
#**************************************************************#
sub markAcronymLastInCompound {	# return: markup and flag (1/0)

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $acronymDone = 0;

	if (
		&MTM::Legacy::isDefault( $t->{pron} )
		&&
		(
			( $MTM::Vars::lang eq 'sv' && $t->{orth} =~ /^(.+)-($MTM::Legacy::Lists::sv_acronym_list|[$MTM::Vars::letter])$/i )
			||
			( $MTM::Vars::lang eq 'en' && $t->{orth} =~ /^(.+)-($MTM::Legacy::Lists::en_acronym_list|[$MTM::Vars::letter])$/i )
		)
		&&
		$t->{orth} !~ /^([$MTM::Vars::letter])-([$MTM::Vars::letter])-([$MTM::Vars::letter])$/i
	) {
		my $wdPart = $1;
		my $acronym = $2;


		# print STDERR "isAcronymLastInCompound\t$t->{orth}\t$wdPart\t$acronym\n";

		my ( $firstPron, $firstPos, $firstMorph, $firstLang );

		# Lookup last part in any dictionary
		if ( $wdPart !~ /\d/ ) {
			# 200124 Use &MTM::Pronunciation::Pronunciation::pronounce instead of &dictionaryLookup. We need a pronunciation.
			( $firstPron, $firstPos, $firstMorph, $firstLang ) = &MTM::Pronunciation::Pronunciation::pronounce( $self, $chunk, $wdPart );

		# Look-up for numerals	CT 110420
		} else {
			my $firstExp = &MTM::Expansion::NumeralExpansion::makeOrthographyCardinal( $wdPart, '-', 'NOM' );	# Send orth, exprType and morph
			$t->{exp} = $firstExp;

			$firstPron = &MTM::Pronunciation::Pronunciation::pronounce( $self, $chunk, $wdPart );	##### TODO

			$firstPos = 'RG';
			$firstMorph = 'NOM';
			$firstLang  = $current_lang;
		}	

		my $lastPos = $MTM::Vars::defaultPos;
		my $lastMorph = $MTM::Vars::defaultMorph;
		my $lastLang = $current_lang;

		# Acronym lookup case insensitive
		my ( $lastPron ) =  split/\t/, &acronymLookup( $acronym, 'caseInsensitive' );

		# Last part is not in dictionary, use automatical methods
		if ( &MTM::Legacy::isDefault( $firstPron )) {

			my $orth = &MTM::Case::makeLowercase( $wdPart );

			#( $firstPron, $firstPos, $firstMorph, $firstLang ) = &createSweCartpron( $wdPart, 'sv' );

			# CT 170328 Bug fix: sub routine createSweAutopron is not used anymore.	
			#( $firstPron, $firstPos, $firstMorph, $firstLang ) = &createSweAutopron( $index, $orth );
			my $domain = $lastLang;

			# 200123 Ugly fix to avoid error in cart tree for wordLookup.pl
			if( $MTM::Vars::runmode ne 'wordLookup' ) {
				##### CT 2020-12-07 WAIT with this one, not committed
				$firstPron = &MTM::Pronunciation::Autopron::cartAndStress( $orth, $domain );	##### TODO
				#$firstPron = '"f \'e j k"';
			}
		}

		# Concatenate compound with hyphen
		my $pron = "$firstPron - $lastPron";

		# Stress
		if( $MTM::Vars::lang eq 'en' ) {
			$pron = &MTM::Pronunciation::Stress::en_compound_stress( $pron );
		} else {
			$pron = &MTM::Pronunciation::Stress::sv_compound_stress( $pron );
		}


		# Insert fields
		#&insertAcronymFields( $index, $pron, $lastPos, $lastMorph, $lastLang, 'ACRONYM COMPOUND' );	##### TODO
		$t->{pron} = $pron;
		$t->{pos} = $lastPos;
		$t->{morph} = $lastMorph;
		$t->{lang} = $current_lang;
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ACRONYM COMPOUND' );

		# CT 200610 %dec was empty
		my $dec = $t->{orth};
		$dec =~ s/-/\+-\+/g;
		$t->{dec} = $dec;

		# print STDERR "sweAcronymMarkup\tisAcronymLastInCompound\n\t$t->{orth}\n$t->{exprType}\n$t->{pron}\n";
		$acronymDone = 1;
	}
	return $acronymDone;
}
#**************************************************************#
# markAcronym
#
# Acronyms in acronym list
#
# Test:	TPB	DN	C-	DN:s
#**************************************************************#
sub markAcronym {	# return: markup and flag (1/0)

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $acronymDone = 0;

	#print "markAcronym	$t->{orth}\n";

	# Without ending
	if (
		&MTM::Legacy::isDefault( $t->{pron} )
		&&
		(
			( $MTM::Vars::lang eq 'sv' && $t->{orth} =~ /^((?:$MTM::Legacy::Lists::sv_acronym_list)-?|[$MTM::Vars::letter]-|[$MTM::Vars::letter]-[$MTM::Vars::letter]-[$MTM::Vars::letter])$/i )
			||
			( $MTM::Vars::lang eq 'en' && $t->{orth} =~ /^((?:$MTM::Legacy::Lists::en_acronym_list)-?|[$MTM::Vars::letter]-|[$MTM::Vars::letter]-[$MTM::Vars::letter]-[$MTM::Vars::letter)$/i )
		)
	) {
		my $acronym = $1;
		$acronym =~ s/-$//;

		# Acronym lookup case insensitive
		my ( $pron, $pos, $morph, $lang ) =  split/\t/, &acronymLookup( $acronym, 'caseInsensitive' );

		# print STDERR "Without ending $t->{orth}\t$pron\t$current_lang\n"; exit;

		# Insert fields
		$t->{pron} = $pron;
		$t->{pos} = 'ACR';
		$t->{morph} = 'NOM';
		$t->{lang} = $current_lang;
		$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ACRONYM' );

		# print STDERR "sweAcronymMarkup\tisAcronym\n\t$t->{orth}\n$t->{exprType}\n$t->{pron}\n";
		$acronymDone = 1;

	# With ending			case insensitive	SF's
	} elsif (
		( $MTM::Vars::lang eq 'sv' && $t->{orth} =~ /^($MTM::Legacy::Lists::sv_acronym_list)[\'\-\:]($MTM::Vars::sv_acronym_endings)$/i )
		||
		( $MTM::Vars::lang eq 'sv' && $t->{orth} =~ /^([$MTM::Vars::letter][$MTM::Vars::letter]+)[\'\-\:]($MTM::Vars::sv_acronym_endings)$/i )
		||
		( $MTM::Vars::lang eq 'en' && $t->{orth} =~ /^($MTM::Legacy::Lists::en_acronym_list)[\'\-\:]?($MTM::Vars::sv_acronym_endings)$/ )
	) {
		my $acronym = $1;
		my $ending = $2;

		# print STDERR "A $acronym\tE $ending\n";

		# Ending must be lowercased
		if ( $ending =~ /^($MTM::Vars::sv_acronym_endings)$/ ) {

			# print STDERR "HOHOH $MTM::Vars::sv_acronym_endings\n";

			# Acronym lookup case insensitive
			my ( $pron, $pos, $morph, $lang ) =  split/\t/, &acronymLookup( $acronym, 'caseInsensitive' );

			return 0 if $pron eq '-';

			#print STDERR "HOHOH $acronym	$pron\n";

			# Add ending pronunciation and get morphological information
			( $pron, $morph ) = MTM::Legacy::addEnding( $pron, $ending);

			# Insert fields
			$t->{pron} = $pron;
			$t->{pos} = 'ACR';
			$t->{morph} = $morph;
			$t->{lang} = $current_lang;
			$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ACRONYM' );

			$t->{isInDictionary} = 1;

			# print STDERR "sweAcronymMarkup\tisAcronym with ending\n\t$t->{orth}\n$t->{exprType}\n$t->{pron}\n";
			$acronymDone = 1;
		}
	}

	return $acronymDone;
}
#**************************************************************#
# isPossibleAcronym
#
# Acronyms not in acronym list
# Creates pronunciation if it is a possible acronym that don't follow the phonotactical rules of the target language.
# Including mixed upper- and lowercase
#
# A-P-G
#
#**************************************************************#
sub isPossibleAcronym {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $acronymDone = 0;

	# print STDERR "isPossibleAcronym $t->{orth}\t$t->{exprType}\n";

	if (
		&MTM::Legacy::isDefault( $t->{exprType} )
		||
		$t->{exprType} =~ /^(URL|EMAIL|FILENAME)$/i
	) {
		if (
			# XxX		SvD, SvD:s
			# XXX		KPR, KPR:arna
			$t->{orth}	=~ /^[$MTM::Vars::uc]+[$MTM::Vars::lc]*[$MTM::Vars::uc]+[\'\:\']?($MTM::Vars::sv_acronym_endings)?$/
			||
			# XxXx		PpPp
			# XXx		PPq
			$t->{orth}	=~ /^[$MTM::Vars::uc]+[$MTM::Vars::lc]*[$MTM::Vars::uc]+[$MTM::Vars::lc][\'\:\']?($MTM::Vars::sv_acronym_endings)?$/
			||
			# X-X-X		A-P-G
			$t->{orth}	=~ /^[$MTM::Vars::uc]-[$MTM::Vars::uc]-[$MTM::Vars::uc][\'\:\']?($MTM::Vars::sv_acronym_endings)?$/
			||
			# X.X.X		S.S.D
			$t->{orth}	=~ /^[$MTM::Vars::uc](?:[\.\-][$MTM::Vars::uc])+[\'\:\']?($MTM::Vars::sv_acronym_endings)?$/
			||
			$t->{orth}	=~ /^([$MTM::Vars::consonant]+)$/i
			||
			$t->{orth}	=~ /^([$MTM::Vars::vowel]|Å|Ä|Ö)+$/i
			||
			$t->{orth}	=~ /^([$MTM::Vars::letter]+\d+)$/i

		) {

			# print STDERR "isPossibleAcronym $t->{orth}\n";

			# With ending
			if ( $t->{orth} =~ /^([$MTM::Vars::uc]+[$MTM::Vars::lc]*[$MTM::Vars::uc]+)[\'\:\']?($MTM::Vars::sv_acronym_endings)$/ ) {
				my $acronym = $1;
				my $ending = $2;

				# print STDERR "A $acronym\tE $ending\n"; sleep 1;

				# Acronym lookup case insensitive
				my $pron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $acronym, 'caseInsensitive' );

				my $morph;

				# Add ending pronunciation and get morphological information
				( $pron, $morph ) = MTM::Legacy::addEnding( $pron, $ending);

				# Insert fields
				$t->{pron} = $pron;
				$t->{pos} = 'ACR';
				$t->{morph} = $morph;
				$t->{lang} = $current_lang;
				$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ACRONYM' );

				$t->{isInDictionary} = 1;

				# print STDERR "sweAcronymMarkup\tisAcronym with ending\n\t$t->{orth}\n$t->{exprType}\n$t->{pron}\n";
				$acronymDone = 1;

			} elsif ( &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $t->{orth} )) {
				# Is pronouncable - do nothing here
			} else {
				my $pron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $t->{orth}, 0 );
				$t->{pron} = $pron;
				$t->{pos} = 'ACR';
				$t->{morph} = 'NOM';
				$t->{lang} = $current_lang;
				$t->{exprType} = MTM::Legacy::get_exprType( $t->{exprType}, 'ACRONYM' );

				# print STDERR "sweAcronymMarkup\tisPossibleAcronym\n\t$t->{orth}\n\t$t->{exprType}\n\t$t->{pron}\n\t$t->{pos}\n";
				$acronymDone = 1;
			}
		}
	}
	return $acronymDone;
}
#************************************************#
sub isAcronymFormat {	# return: 1/0

	my $self = shift;;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	my $orth = $t->{orth};

	if ( !defined( $orth )) {
		return "0";
	}

	if (
		&MTM::Legacy::isDefault( $t->{exp} )
		&&
		(
			( $MTM::Vars::lang eq 'sv' && $orth =~ /^(?:$MTM::Legacy::Lists::sv_acronym_list|$MTM::Vars::letter):?($MTM::Vars::sv_acronym_endings)$/i )	# acronym list	DN, DN:s
			||
			( $MTM::Vars::lang eq 'sv' && $orth =~ /^(?:$MTM::Legacy::Lists::sv_acronym_list|$MTM::Vars::letter)-(?:.+)$/i )	# acronym list -	DN-prenumerant
			||
			( $MTM::Vars::lang eq 'en' && $orth =~ /^(?:$MTM::Legacy::Lists::en_acronym_list|$MTM::Vars::letter):?($MTM::Vars::sv_acronym_endings)$/i )	# acronym list	DN, DN:s
			||
			( $MTM::Vars::lang eq 'en' && $orth =~ /^(?:$MTM::Legacy::Lists::en_acronym_list|$MTM::Vars::letter)-(?:.+)$/i )	# acronym list -	DN-prenumerant
			||
			$orth 	=~	/^(?:[$MTM::Vars::uc](?:\.[$MTM::Vars::uc]\.[$MTM::Vars::uc]|[$MTM::Vars::lc]*[$MTM::Vars::uc])+)-(?:[$MTM::Vars::letter]+)$/	# V B.KaP-
			||
			#$orth	=~	/^(?:[$MTM::Vars::uc](?:[\.\-\/][$MTM::Vars::uc])+)-([letter][$MTM::Vars::letter][$MTM::Vars::letter]+)$/
			#||
			$orth	=~	/^(?:(?:[$MTM::Vars::uc]-[$MTM::Vars::uc])+)-([letter][$MTM::Vars::letter]+)$/
			||
			$orth	=~	/^[$MTM::Vars::uc]+[$MTM::Vars::lc]*[$MTM::Vars::uc]+[\:\-\']?(?:$MTM::Vars::sv_acronym_endings)?$/	# VbpK's
			||
			$orth	=~	/^[$MTM::Vars::uc]+[$MTM::Vars::lc]*[$MTM::Vars::uc]+[$MTM::Vars::lc][\:\-\']?(?:$MTM::Vars::sv_acronym_endings)?$/	# VbåLo:erna
			||
			$orth	=~	/^[$MTM::Vars::uc](?:[\.\-][$MTM::Vars::uc])+[\:\-\']?(?:$MTM::Vars::sv_acronym_endings)?$/	# VB:erna
			||
			$orth	=~	/^(?:[$MTM::Vars::uc])-$/	# V-
			||
			( $MTM::Vars::lang eq 'sv' && $orth =~ /^(?:.+)-(?:(?:$MTM::Legacy::Lists::sv_acronym_list)[\:\-\']?(?:$MTM::Vars::sv_acronym_endings)?)$/ )	# bank-ID
			||
			( $MTM::Vars::lang eq 'en' && $orth =~ /^(?:.+)-(?:(?:$MTM::Legacy::Lists::en_acronym_list)[\:\-\']?(?:$MTM::Vars::sv_acronym_endings)?)$/ )	# bank-ID
			||
			$orth	=~	/^(?:[$MTM::Vars::uc])-(.+)$/	# A-par
			||
			$orth	=~	/^[A-ZÅÄÖa-zåäö]+-[$MTM::Vars::uc]+$/	# bank-VBV
			||
			$orth	=~	/^[$MTM::Vars::uc]+-[A-ZÅÄÖa-zåäö]+$/	# VBV-bank
			||
			$orth	=~	/^(?:$MTM::Vars::consonant+)$/i	# prkvbTW
			||
			$orth	=~	/^[A-ZÅÄÖa-zåäö]+\d+$/	# ABC12				230215
		)
	) {
		return 1;
	} else {
		return '-';
	}

}
#************************************************#
sub acronymLookup {

	my ( $acronym, $case ) = @_;

	# print STDERR "$MTM::Vars::lang\t$acronym\t$case\n";

	if( $MTM::Vars::lang eq 'en' ) {
		if ( $case =~ /casesensitive/ ) {
			if ( exists( $MTM::Legacy::Lists::en_acronym{ $acronym } )) {
				return $MTM::Legacy::Lists::en_acronym{ $acronym };
			} elsif (  exists( $MTM::Legacy::Lists::en_alphabet{ $acronym } )) {
				return $MTM::Legacy::Lists::en_alphabet{ $acronym }
			} else {
				return '-';
			}

		} elsif ( $case =~ /uc/ ) {
			my $ucAcronym = &MTM::Case::makeUppercase( $acronym );

			if ( exists( $MTM::Legacy::Lists::en_acronym{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::en_acronym{ $ucAcronym };
			} elsif (  exists( $MTM::Legacy::Lists::en_alphabet{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::en_alphabet{ $ucAcronym }
			} else {
				return '-';
			}

		} elsif ( $case =~ /lc/ ) {
			my $lcAcronym = &MTM::Case::makeLowercase( $acronym );

			if ( exists( $MTM::Legacy::Lists::en_acronym{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::en_acronym{ $lcAcronym };
			} elsif (  exists( $MTM::Legacy::Lists::en_alphabet{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::en_alphabet{ $lcAcronym }
			} else {
				return '-';
			}

		} elsif ( $case =~ /caseinsensitive/i ) {
			my $ucAcronym = &MTM::Case::makeUppercase( $acronym );
			my $lcAcronym = &MTM::Case::makeLowercase( $acronym );


			if ( exists( $MTM::Legacy::Lists::en_acronym{ $acronym } )) {
				return $MTM::Legacy::Lists::en_acronym{ $acronym };
			} elsif ( exists( $MTM::Legacy::Lists::en_acronym{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::en_acronym{ $ucAcronym };
			} elsif ( exists( $MTM::Legacy::Lists::en_acronym{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::en_acronym{ $lcAcronym }
			} elsif (  exists( $MTM::Legacy::Lists::en_alphabet{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::en_alphabet{ $ucAcronym }
			} elsif (  exists( $MTM::Legacy::Lists::en_alphabet{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::en_alphabet{ $lcAcronym }
			} else {
				return '-';
			}
		}

	# Swedish and world
	} else {

		if ( $case =~ /casesensitive/ ) {
			if ( exists( $MTM::Legacy::Lists::sv_acronym{ $acronym } )) {
				return $MTM::Legacy::Lists::sv_acronym{ $acronym };
			} elsif (  exists( $MTM::Legacy::Lists::sv_alphabet{ $acronym } )) {
				return $MTM::Legacy::Lists::sv_alphabet{ $acronym }
			} else {
				return '-';
			}

		} elsif ( $case =~ /uc/ ) {
			my $ucAcronym = &MTM::Case::makeUppercase( $acronym );

			if ( exists( $MTM::Legacy::Lists::sv_acronym{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::sv_acronym{ $ucAcronym };
			} elsif (  exists( $MTM::Legacy::Lists::sv_alphabet{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::sv_alphabet{ $ucAcronym }
			} else {
				return '-';
			}

		} elsif ( $case =~ /lc/ ) {
			my $lcAcronym = &MTM::Case::makeLowercase( $acronym );

			if ( exists( $MTM::Legacy::Lists::sv_acronym{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::sv_acronym{ $lcAcronym };
			} elsif (  exists( $MTM::Legacy::Lists::sv_alphabet{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::sv_alphabet{ $lcAcronym }
			} else {
				return '-';
			}

		} elsif ( $case =~ /caseinsensitive/i ) {
			my $ucAcronym = &MTM::Case::makeUppercase( $acronym );
			my $lcAcronym = &MTM::Case::makeLowercase( $acronym );


			if ( exists( $MTM::Legacy::Lists::sv_acronym{ $acronym } )) {
				return $MTM::Legacy::Lists::sv_acronym{ $acronym };
			} elsif ( exists( $MTM::Legacy::Lists::sv_acronym{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::sv_acronym{ $ucAcronym };
			} elsif ( exists( $MTM::Legacy::Lists::sv_acronym{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::sv_acronym{ $lcAcronym }
			} elsif (  exists( $MTM::Legacy::Lists::sv_alphabet{ $ucAcronym } )) {
				return $MTM::Legacy::Lists::sv_alphabet{ $ucAcronym }
			} elsif (  exists( $MTM::Legacy::Lists::sv_alphabet{ $lcAcronym } )) {
				return $MTM::Legacy::Lists::sv_alphabet{ $lcAcronym }
			} else {
				return '-';
			}
		}
	}
	return 1;
}
#**************************************************************#
1;
