package MTM::Expansion::NumeralExpansion;

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
# Numeral
#
# Language	sv_se
#
# Rules for numeral expansions.
# 
# Return: expansion
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub expand {
	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	# print STDERR "NumeralExpansion $t->{orth}\t$t->{exp}\t$t->{pos}\t$t->{exprType}\n";

	if( $MTM::Vars::lang eq 'en' && $t->{exp} eq 'the' ) {
		# continue
	} elsif (
		$t->{pos} !~ /^R/
		||
		&MTM::Legacy::isDefault( $t->{exp} ) == 0
	) {
		return $self;
	}

	my $rc1base = 'void';
	my $rc2base = 'void';
	my $morph = 'void';
	my $morph_set = 0;

	# Find locations
	if( $chunk->peek(1) ) {
		$rc1base = $chunk->peek(1);
		my $rc1 = $rc1base->{LEGACYDATA};
		if( $rc1->{morph} =~ /(UTR|NEU)/ ) {
			$morph = $rc1->{morph};
			$morph_set = 1;
		}
	}

	if( $morph_set == 0 && $chunk->peek(2) ) {
		$rc2base = $chunk->peek(2);
		my $rc2 = $rc2base->{LEGACYDATA};
		if( $rc2->{morph} =~ /(UTR|NEU)/ ) {
			$morph = $rc2->{morph};
		}
	}

	my $numOrth = expand_numeral( $t->{orth}, $t->{exprType}, $t->{pos}, $morph );


	if($t->{exp} =~ /^paragraf|kapit|stycke|the/ ) {
		$t->{exp} .= "\|$numOrth";
	} else {
		$t->{exp} = $numOrth;
	}

	# print STDERR "numOrth $numOrth\tO $t->{orth} ET $t->{exprType}, POS $t->{pos}\tEXP $t->{exp}\n";

	return $self;
}
#**************************************************************#
sub expand_numeral {

	my $numeral = shift;
	my $exprType = shift;
	my $pos = shift;		# $pos is only used in this main sub.
	my $morph = shift;		# $morph is passed on to all subs that calls sub expand_1.

	my $numOrth = 'void';

	# print STDERR "expand_numeral\t$numeral\t$exprType\t$pos\t$morph\n";

	# Do not do fractions or currency (CT 151124)
	if (
		$exprType =~ /(FRACTION)/
	) {
		return;

	# years
	} elsif (
		$exprType =~ /YEAR/
		&&
		$numeral !~ /^10\d\d$/			# Avoid "tio hundra"	CT 101331
	) {
		$numOrth = &expandYear( $numeral, $exprType, $morph );

	# 1
	} elsif (
		$numeral eq '1'
		&&
		$pos eq 'RG'
	) {
		$numOrth = &expand_1( $numeral, $morph );

	# Cardinals
	} elsif (
		$pos eq 'RG'
		||
		(
			$pos =~ /^UNK/
			&&
			$numeral =~ /^\d+\-$/
		)
	) {

		#print "SENDING $numeral, $exprType, $morph\n";
		$numOrth = &makeOrthographyCardinal( $numeral, $exprType, $morph );

	# Ordinals
	} elsif (
		$pos eq 'RO'
	) {
		#my $numeral = $numeral;
		$numOrth = &makeOrthographyOrdinal( $numeral, $exprType, $morph );

	# Numeral with ending	3:e
	} elsif (
		$numeral =~ /^\d+\'?(?:$MTM::Vars::sv_word_endings)$/i
	) {
		my $numeral = $numeral;
		$numOrth = &makeNumEnding( $numeral, $exprType, $morph );

	} else {
		return '-';
	}

	# Insert expanded orthography
	#$t->{exp} = $numOrth;
	# print STDERR "expand_numeral $numeral	return $numOrth\n";
	return $numOrth;
}
#**************************************************************#
sub makeOrthographyOrdinal {	# return var

	my $numeral = shift;
	my $exprType = shift;
	my $morph = shift;

	# Remove initial zero
	$numeral =~ s/^0(\d)/$1/;

	my $ending = 'DEFAULT';

	my $ordinal = $numeral;

	# Remove initial zero		CT 110808
	$ordinal =~ s/^0//;

	$ordinal = &makeOrthographyCardinal( $numeral, $exprType, $morph );

	if( $MTM::Vars::lang eq 'en' && $numeral =~ /.+($MTM::Vars::en_ordinal_endings)$/ ) {
		$ending = $1;
	} elsif( $numeral =~ /.+($MTM::Vars::sv_ordinal_endings)$/ ) {
		$ending = $1;
	}

	# print STDERR "makeOrthographyOrdinal\t$ordinal\t$ending\n";

	# Rewrite to ordinals
	# English
	if( $MTM::Vars::lang eq 'en' ) {
		$ordinal =~ s/one$/first/;
		$ordinal =~ s/two$/second/;
		$ordinal =~ s/three$/third/;
		$ordinal =~ s/four$/fourth/;
		$ordinal =~ s/five$/fifth/;
		$ordinal =~ s/six$/sixth/;
		$ordinal =~ s/seven$/seventh/;
		$ordinal =~ s/eight$/eighth/;
		$ordinal =~ s/nine$/ninth/;
		$ordinal =~ s/ten$/tenth/;

		$ordinal =~ s/eleven$/eleventh/;
		$ordinal =~ s/twelve$/twelfth/;
		$ordinal =~ s/(thir|four|fif|six|seven|eigh|nine)teen$/$1teenth/;

		$ordinal =~ s/(twen|thir|four|fif|six|seven|eigh|nine)ty$/$1tieth/;

		$ordinal =~ s/(hundred|thousand|million|billion|trillion)s?$/$1th/;

#		if( $exprType =~ /DATE/ ) {
#			$ordinal = "the $ordinal";
#		}

		if ( $ending =~ /^[\']s$/ ) {
			$ordinal .= 's';
		}
	# Swedish and world
	} else {
		$ordinal =~ s/tre$/tredje/;
		$ordinal =~ s/fyra$/fjärde/;
		$ordinal =~ s/fem$/femte/;
		$ordinal =~ s/sex$/sjätte/;
		$ordinal =~ s/sju$/sjunde/;
		$ordinal =~ s/åtta$/åttonde/;
		$ordinal =~ s/(n|t)io$/$1ionde/;

		$ordinal =~ s/elva$/elfte/;
		$ordinal =~ s/tolv$/tolfte/;
		$ordinal =~ s/(trett|fjort|femt|sext|sjutt|art|nitt)on$/$1onde/;

		$ordinal =~ s/tjugo$/tjugonde/;
		$ordinal =~ s/(tret|fyr|fem|sex|sjut|åt|nit)tio$/$1tionde/;

		$ordinal =~ s/hundra$/hundrade/;
		$ordinal =~ s/tusen$/tusende/;
		$ordinal =~ s/en\|miljon$/miljonte/;
		$ordinal =~ s/biljon$/biljonte/;
		$ordinal =~ s/triljon$/triljonte/;

		# förste - första, andre - andra
		if ( $ending =~ /[\.\:]?e$/ ) {
			$ordinal =~ s/(ett|en)$/förste/;
			$ordinal =~ s/två$/andre/;
		} else {
			$ordinal =~ s/(ett|en)$/första/;
			$ordinal =~ s/två$/andra/;
		}

		if ( $ending =~ /^[\.\:]s$/ ) {
			$ordinal .= 's';
		}
	}

	return $ordinal;
}
#**************************************************************#
sub makeOrthographyCardinal {

	my $numeral = shift;
	my $exprType = shift;
	my $morph = shift;

	$numeral =~ s/\-//g;

	#print STDERR "\nmakeOrthographyCardinal\t$numeral\t$exprType\t$morph\n\n";

	# Expand only if orthography contains digits or is roman
	if (
		$numeral !~ /\d/
		&&
		$exprType !~ /ROMAN/
	) {
		return '-';
	}

	my $numOrth = 'void';
	my @num_exp = ();

	# Convert roman numerals to arabic
	if (
		$exprType =~ /ROMAN/
	) {
		$numeral = &roman2arabic( $numeral );
	}

	# Remove periods and ordinal endings
	$numeral =~ s/\.//g;
	$numeral =~ s/($MTM::Vars::sv_ordinal_endings)$// if $MTM::Vars::lang eq 'sv';
	$numeral =~ s/($MTM::Vars::en_ordinal_endings)$// if $MTM::Vars::lang eq 'en';

	# Starts with "0" - spell
	if (
		$numeral =~ /^0/
	) {
		#print STDERR "\n to_spell\t$numeral\t$exprType\t$morph\n\n";
		$numOrth = &spellNumeral( $numeral, $morph );

	# $exprType is EMAIL|URL|FILENAME, contains more than 5 digits - spell
	} elsif (
		$exprType =~ /(?:EMAIL|URL|FILE NAME)/
		&&
		$numeral =~ /\d\d\d\d\d/
	) {
		$numOrth = &spellNumeral( $numeral, $morph );

	# Normal numerals
	} else {
		my $ending = 'DEFAULT';
		if ( $numeral =~ s/^(\d+)s$/$1/ ) {
			$ending = 's';
		}

		# Remove single quote
		$numeral =~ s/\'$//;

		$numeral =~ s/,//g;	# 211126 Remove commas

		# Split into 3-digit clusters
		until ($numeral !~ /\d\d\d\d(\s|$)/) {
			$numeral =~ s/(\d\d\d)(\s|$)/ $1$2/;
		}

		my @numeralList = split/ /,$numeral;

		my $listCount = $#numeralList;
		foreach my $nl ( @numeralList ) {
			my $numExp = 'void';

			# 0-9
			# Works with spelled numbers?
			if ($nl =~ /^[1-9]$/) {
				$numExp = &num_0_9( $nl, $morph );

			# 10-19
			} elsif ($nl =~ /^1\d$/) {
				$numExp = &num_10_19( $nl, $morph );

			# 20-99
			} elsif ($nl =~ /^[2-9]\d$/) {
				$numExp = &num_20_99( $nl, $morph );

			# 100-999
			} elsif ( $nl =~ /^\d\d\d$/ ) {
				$numExp = &num_100_999( $nl, $morph );
			}

			# Add 'hundra', 'tusen' aso.
			if ( $listCount > 0 && $numExp ne 'void' ) {
				# print STDERR "addChunk\tnumeral\t$numeral\tnumOrth\t$numOrth\tlistCount\t$listCount\tnumeralList\t$#numeralList\n";
				$numExp = &addChunk( $numExp, $listCount );

			} else {
				$numExp =~ s/void//g;
			}

			push @num_exp, $numExp;

			$listCount--;
		}

		$numOrth = join" ",@num_exp;

		if ( &MTM::Legacy::isDefault( $ending )) {
			# do nothing
		} else {
			$numOrth .= 's';
		}
	}

	$numOrth =~ s/ /$MTM::Vars::word_boundary/g;
	$numOrth = &cleanNumeral( $numOrth );

	return $numOrth;
}
#**************************************************************#
# Read each digit
#**************************************************************#
sub spellNumeral {	# return: var

	# lc1->{morph} was used here?
	my $numeral = shift;
	my $morph = shift;

	my @numeralList = split//,$numeral;
	my @numeralOrth = ();

	foreach my $num ( @numeralList ) {
		my $o = &num_0_9( $num, $morph );
		push @numeralOrth, &num_0_9( $num, $morph );
	}

	my $numOrth = join"$MTM::Vars::word_boundary", @numeralOrth;

	return $numOrth;
}
#**************************************************************#
# expandYear
#
# Years
#
#**************************************************************#
sub expandYear {	# return: var + markup

	my $numeral = shift;
	my $exprType = shift;
	my $morph = shift;

	my $numOrth;

	my $ending = 'void';

	# Less than 4 digits, process as normal cardinal.
	if (
		$numeral !~ /^[1-9]\d\d\d/
	) {
		$numOrth = &makeOrthographyCardinal( $numeral, $exprType, $morph );

	# 4 digits
	} elsif (
		$numeral =~ /^(\d\d)(\d\d)/
	) {
		my $first = $1;
		my $last = $2;


#		print "expandYear\n\t$numeral\n";

		# 21- to normal cardinal expansion
		if ( $first !~ /^(1|20)/ ) {
			$numOrth = &makeOrthographyCardinal( $numeral, $exprType, $morph );

		} else {

			# First two digits		'1000' = dummy value
			# print "expandYear\t$first\n";
			if ( $first =~ /^1/ ) {
				$numOrth = &num_10_19( $first, $morph );
				if( $MTM::Vars::lang eq 'sv' ) {
					$numOrth .= " $MTM::Vars::hundred_word ";
				} else {
					$numOrth .= ' ';
				}

			} elsif ( $first =~ /^2/ ) {

				if( $MTM::Vars::lang eq 'sv' ) {
					$numOrth = &num_20_99( $first, $morph ) . " $MTM::Vars::hundred_word ";
				} else {
					if( $last =~ /^0\d/ ) {
						$numOrth = 'two thousand ';
					} else {
						$numOrth = 'twenty ';
					}
				}
			}

			# Last two digits
			#if( $MTM::Vars::lang eq 'en' && $last =~ /^00/ ) {
			#	$numOrth .= " $MTM::Vars::hundred_word "

			#} els
			if ( $last =~ s/0([1-9])/$1/ ) {
				# CT 101210	sub num_0 takes only two args: $numOrth .= &num_0_9( $last, '1000', $index );
				$numOrth .= &num_0_9( $last, $morph );

			} elsif ( $last =~ /^1/ ) {
				$numOrth .= &num_10_19( $last, $morph );

			} elsif ( $last =~ /^[2-9]/ ) {
				$numOrth .= &num_20_99( $last, $morph );

			}

		}

		$numOrth =~ s/ +$//;
		$numOrth =~ s/nul$//;
	}

	$numOrth = &MTM::Legacy::cleanBlanks( $numOrth );
	$numOrth =~ s/ /$MTM::Vars::word_boundary/g;

	##### CT 2020-12-04 We don't insert stuff in this module.
	# Insert pos & morph
	#$pos = 'RG';
	#$morph = 'NOM';

	if (
		$ending ne 'void'
	) {
		my $suffix = &MTM::Case::makeLowercase( $ending );

		# Concatenate
		$numOrth .= $suffix;

		# Remove double e:s		CT 110330
		$numOrth =~ s/e(ernes?)$/$1/;

	}

	# print "expandYear\n\t$numeral\t$numOrth\n";
	return $numOrth;
}
#**************************************************************#
# 0-9
#**************************************************************#
sub num_0_9 {

	my $numeral = shift;
	my $morph = shift;

	my $numOrth;
	if( $MTM::Vars::lang eq 'en' ) {
		$numOrth = $MTM::Vars::en_num_0_9{ $numeral };
	} else {
		$numOrth = $MTM::Vars::sv_num_0_9{ $numeral };

		# Number is "1" and morphology contains "UTR" --> "en"
		if ( $numeral eq "1" && $morph =~ /UTR/ ) {
			$numOrth = "en";
		}
	}

	return $numOrth;
}
#**************************************************************#
# 10-19
#**************************************************************#
sub num_10_19 {

	my $numeral = shift;
	my $morph = shift;

	my $numOrth;
	if( $MTM::Vars::lang eq 'en' ) {
		$numOrth = $MTM::Vars::en_num_10_19{ $numeral };
	} else {
		$numOrth = $MTM::Vars::sv_num_10_19{ $numeral };
	}

	return $numOrth;
}
#**************************************************************#
# Pusslar ihop tal mellan 20 och 99.
#**************************************************************#
sub num_20_99 {

	my $numeral = shift;
	my $morph = shift;

	my $firstExp;
	my $lastExp;
	my $numOrth;

	my ( $first, $last ) = split//, $numeral;

	if ($first != 0) {
		if( $MTM::Vars::lang eq 'en' ) {
			$firstExp = $MTM::Vars::en_num_20_90{ $first };
		} else {
			$firstExp = $MTM::Vars::sv_num_20_90{ $first };
		}
	}

	# Handle en/ett
	if ( $last ne '0' ) {
		if( $MTM::Vars::lang eq 'en' ) {
			$lastExp = $MTM::Vars::en_num_0_9{ $last };
			$numOrth = $firstExp . '-' . $lastExp;
		} else {
			$lastExp = $MTM::Vars::sv_num_0_9{ $last };

			if (
				$last eq '1'
				&&
				$morph =~ /(UTR|PLU)/
			) {
				$lastExp = "en";
			}
			$numOrth = $firstExp . $lastExp;
		}
	} else {
		$numOrth = $firstExp;
	}

	return $numOrth;
}
#**************************************************************#
# Concatenating numerals between 100 and 999.
#**************************************************************#
sub num_100_999 {

	my $numeral = shift;
	my $morph = shift;

	# Do not add anything for '000'		CT 110328
	if ( $numeral eq '000' ) {
		# 110708 return 'void';
	}

	my ( $first, $second, $third ) = split//, $numeral;
	my $last = $second . $third;

	my @exp = ();

	# First digit + hundred
	if ( $first ne '0' ) {
		if( $MTM::Vars::lang eq 'en' ) {
			push @exp, $MTM::Vars::en_num_0_9{ $first } . " $MTM::Vars::hundred_word ";
		} else {
			push @exp, $MTM::Vars::sv_num_0_9{ $first } . " $MTM::Vars::hundred_word ";
		}
	}

	# If last digit is "1"
	if ($last =~ /^1/) {
		push @exp, &num_10_19( $last, $morph );

	# 20-99.
	} elsif ($second =~ /^[2-9]/) {
		push @exp, &num_20_99( $last, $morph );

	# 1-9
	} elsif ( $last =~ s/^0([1-9])$/$1/ ) {
		push @exp, &num_0_9( $last, $morph );

	# 000 --> tusen				101229
	} elsif ( $first eq '0' && $last eq '00' ) {
		if( $MTM::Vars::lang eq 'en' ) {
			push @exp, 'thousand';
		} else {
			push @exp, 'tusen';
		}	

	} else {
		push @exp, 'void';
	}

	# Concatenate
	my $numOrth = join" ",@exp;

#	print "Return num_100_000: $numOrth\n";
	return $numOrth;
}
#**************************************************************#
# addChunk
#
# Adds hundreds, thousands, miljons and miljards
#**************************************************************#
sub addChunk {
	my $numOrth = shift;
	my $listCount = shift;

	if( $MTM::Vars::lang eq 'en' ) {
		if ( $listCount == 1 ) {
			$numOrth .= ' thousand';
		} elsif ( $listCount == 2 ) {
			$numOrth .= ' millions';
		} elsif ( $listCount == 3 ) {
			$numOrth .= ' billions';
		} elsif ( $listCount == 4 ) {
			$numOrth .= ' trillions';
		}

	} else {
		if ( $listCount == 1 ) {
			$numOrth .= ' tusen';
		} elsif ( $listCount == 2 ) {
			$numOrth .= ' miljoner';
		} elsif ( $listCount == 3 ) {
			$numOrth .= ' miljarder';
		} elsif ( $listCount == 4 ) {
			$numOrth .= ' biljon';
		}
	}
	return $numOrth;
}

#**************************************************************#
# expand_1
# 		expands "1" to "en" or "ett"
#**************************************************************#
sub expand_1 {	# return var

	my $numeral = shift;
	my $morph = shift;

	my $numOrth;

	if( $MTM::Vars::lang eq 'en' ) {
		$numOrth = 'one';
	} else {
		$numOrth = 'ett';

		if (
			$morph =~ /UTR/
		) {
			$numOrth = 'en';
		}
	}

	#print "$numeral\t$numOrth\t$morph\n";

	return $numOrth;
}
#**************************************************************#
sub cleanNumeral {

	my $numOrth = shift;

	$numOrth =~ s/ +/ /g;

	$numOrth =~ s/\|void\|/\|/g;

	if( $MTM::Vars::lang eq 'en' ) {

		$numOrth = &MTM::Legacy::cleanBlanks( $numOrth );
		$numOrth =~ s/\|+/\|/g;
		$numOrth =~ s/^\|+//g;
		$numOrth =~ s/\|+$//g;

		$numOrth =~ s/thousand(\|thousand)+/thousand/g;
		$numOrth =~ s/((?:milli|billi|trilli)ons?)\|([mb]illions?\|?|thousand\|?)+/$1/;

		$numOrth =~ s/((?: |\||^)one)\|(million|billion|trillion)s/$1\|$2/;		# Singular form of 'million' etc

	} else {

		$numOrth = &MTM::Legacy::cleanBlanks( $numOrth );
		$numOrth =~ s/\|+/\|/g;
		$numOrth =~ s/^\|+//g;
		$numOrth =~ s/\|+$//g;

		$numOrth =~ s/tusen(\|tusen)+/tusen/g;
		$numOrth =~ s/(milj(?:on|ard)(?:er)?)(\|(?:miljoner|tusen))+/$1/;

		# Corrections of gender and numerus
		$numOrth =~ s/\ben\|(hundra|tusen?)/ett\|$1/g;				# Replace 'en' with 'ett'

		$numOrth =~ s/^(en|ett)\|(miljon|miljard)er/en\|$2/;		# Singular form of 'miljoner' and 'miljarder'
		$numOrth =~ s/ +ett\|(miljoner|miljarder)/ en\|$1/;			# ett --> en

		$numOrth = &MTM::Legacy::cleanBlanks( $numOrth );

		$numOrth =~ s/ /$MTM::Vars::word_boundary/g;

	}

	$numOrth =~ s/\|+/\|/g;
	$numOrth =~ s/^\|+//g;
	$numOrth =~ s/\|+$//g;

	return $numOrth;
}
#**************************************************************#
# roman2arabic	Converting roman numbers to arabic numbers.
#
#**************************************************************#
sub roman2arabic {

	my $roman = shift;

	my $lastDigit = 1000;

	my $arabic;
	my $ending = 'DEFAULT';

	# Remove ending
	if ( $roman =~ /^([$MTM::Vars::romanLetters]+)($MTM::Vars::sv_roman_ending)$/i ) {
		$roman = $1;
		$ending = $2;
	}

	$roman = &MTM::Case::makeUppercase( $roman );
	my @roman = split//,$roman;

	foreach my $r ( @roman ) {
		my $a = $MTM::Vars::roman2arabic{ $r };
		$arabic -= 2 * $lastDigit if $lastDigit < $a;
		$arabic += ( $lastDigit = $a );
	}

	if (
		&MTM::Legacy::isDefault( $ending )
	) {
		# do nothing
	} else {
		$arabic .= $ending;
	}

	return $arabic;
}
#**************************************************************#
# makeNumEnding
#
# Needs testing, might be destroyd by CT 2020-11-30.
#**************************************************************#
sub makeNumEnding {

	my $numeral = shift;
	my $exprType = shift;
	my $morph = shift;

	$numeral =~ /^(\d+)\'?($MTM::Vars::sv_word_endings)$/i;
	my $num = $1;
	my $ending = $2;

	# print "\nmakeNumEnding\t$num\t$ending\n";

	my $numOrth = &makeOrthographyCardinal( $num, $exprType, $morph );
	#&insertExpansion( $index, $numOrth );

	##### CT 2020-12-04 Do we need the pronunciation already?
	my $numPron = &MTM::Pronunciation::NumeralPronunciation::pronounce( $num );

	my $pron;
	$ending = &MTM::Case::makeLowercase( $ending );
	( $pron, $morph ) = MTM::Legacy::addEnding( $num, $ending );

	return $pron;
}
#**************************************************************#
1;
