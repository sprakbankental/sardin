package MTM::Pronunciation::AcronymPronunciation;

#**************************************************************#
# Acronym
#
# Language	sv_se
#
# Rules for creating acronym pronunciations (by spelling them).
#
# Return: pronunciation
#
# tests exist
#
# (c) Swedish Agency for Accessible Media, MTM 2021
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

our $debug;


#**************************************************************#
sub pronounce {
	my $orth = shift;

	#print STDERR "\n------------------------------------\ncreateAcronymPronunciation\n\t$orth\n";

	$orth = &MTM::Case::makeLowercase( $orth );

	if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
		# 240512 utf8::encode( $orth );
	}

	my $orig_orth = $orth;

	# 240512 Split at digits
	$orth =~ s/(\d|$MTM::Vars::characters|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)/<SPLIT>$1<SPLIT>/g;

	$orth =~ s/(<SPLIT>)+/<SPLIT>/g;
	$orth =~ s/^<SPLIT>//;
	$orth =~ s/<SPLIT>$//;

	my @orth = split/<SPLIT>/, $orth;

	my $allLetters = 1;
	my @acronym = ();

	foreach my $o ( @orth ) {

		next if $o eq '-';

		# English
		if( $MTM::Vars::lang eq 'en' ) {
			# Push spelled letters to list
			if ( exists( $MTM::Legacy::Lists::en_alphabet{ $o } )) {
				push @acronym, $MTM::Legacy::Lists::en_alphabet{ $o };

			} elsif ( exists( $MTM::Legacy::Lists::en_special_character_list{ $o } )) {
				my( $orth, $pron ) = split/\t+/, $MTM::Legacy::Lists::en_special_character_list{ $o };
				push @acronym, $pron;

			} elsif ( $o =~ /^\d+$/ ) {
				#my( $orth, $pron ) = split/\t+/, $MTM::Legacy::Lists::en_special_character_list{ $o };
				my $exp = &MTM::Expansion::NumeralExpansion::makeOrthographyCardinal( $o, '-', '-' );
				my $pron = &MTM::Pronunciation::NumeralPronunciation::pronounce( $exp );

				push @acronym, $pron;

			# Unknown letter/non-letter
			} else {
				# print STDERR "No match\t$o\n";
				$allLetters = 0;
			}

		# Swedish and world
		} else {
			#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_alphabet)){ print "ttttttttt k $k\tv $v\n"; }
			#print STDERR "OO $o\n ";
			# Push spelled letters to list

			if( $o !~ /($MTM::Legacy::Lists::sv_special_character_list)/ ) {

				if ( exists( $MTM::Legacy::Lists::sv_alphabet{ $o } )) {
					push @acronym, $MTM::Legacy::Lists::sv_alphabet{ $o };

				} elsif ( exists( $MTM::Legacy::Lists::sv_special_character_list{ $o } )) {
					my( $orth, $pron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character_list{ $o };
					push @acronym, $pron;

				} elsif ( $o =~ /^\d+$/ ) {
					#my( $orth, $pron ) = split/\t+/, $MTM::Legacy::Lists::en_special_character_list{ $o };

					my $exp = &MTM::Expansion::NumeralExpansion::makeOrthographyCardinal( $o, '-', '-' );
					my $pron = &MTM::Pronunciation::NumeralPronunciation::pronounce( $exp );
					push @acronym, $pron;

				# Unknown letter/non-letter
				} else {
					# print STDERR "No match\t$o\n";
					$allLetters = 0;
				}
			} else {
				$allLetters = 0;
			}
		}
	}

	# CT 231122 return pronunciation even if all characters didn't get a pronunciation
	if ( $allLetters == 1 ) {
		my $acronym = join" \~ ", @acronym;

		# Insert word boundaries around W and Z
		$acronym =~ s/ \~ (s \"ä: \. t \,a|d \"u \. b ex l [\-\.] v \,e:)/ \| $1/g;
		$acronym =~ s/(s \"ä: \. t \,a|d \"u \. b ex l [\-\.] v \,e:) \~ /$1 \| /g;

		$acronym = &MTM::Pronunciation::Stress::acronymStress( $acronym, $debug );
		# print STDERR "\nacronym_return $orth\t$acronym\n\n";
		return( $acronym );
	} else {
		# spell
		my $acronym = &MTM::Pronunciation::Pronunciation::spell_all( $orig_orth );
		return( $acronym );
	}
}
#**************************************************************#
1;

