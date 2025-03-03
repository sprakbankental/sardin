package MTM::Pronunciation::Compound;

#**************************************************************#
# Compound
#
# Language	sv_se
#
# Rules for creating compound pronunciations.
# 
# Return: pronunciation
#
# tests exist		210823
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

our $runmode = 'tts';	#####
#**************************************************************#
sub createCompoundPronunciation {

	my $decomposed = shift;

	# print STDERR "\n--------------------------------\ncreateCompoundPronunciation\tDecomposed: $decomposed\n";

	# Compounds with hyphens or not
	my $decomposed2 = $decomposed;

	$decomposed2 =~ s/\+\-\+/<SPLIT>/g;
	$decomposed2 =~ s/\+/<SPLIT>/g;

	my @decomposed = split/<SPLIT>/, $decomposed2;

	my $i = 0;
	my @pron = ();
	foreach my $part ( @decomposed ) {

		# 210927
		if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
			utf8::decode( $part );
		}

		# print STDERR "\n----\nLooking for $part\t$i\t$#decomposed\n";

		### TODO Allow a certain set of characters and rewrite the rest. Generally.
		$part =~ s/\’/\'/g;
		$part =~ s/ś/s/g;
		$part =~ s/ą/a/g;


		#-------------------------------------------------------------------------------------------#
		# Numerals
		if (
			$part =~ /^\d+$/
		) {
			my $markup = 'cardinal';
			my $context = 'DEFAULT';

			if ( $part =~ /^1[1-9]\d\d$/ ) {
				$markup = 'year';

				# print STDERR "Numeral marked as year\t$part\t$markup\n";
			}

			my $dummy = 0;

			my $letters = 'void';

			# 1928-kvarleva
			if ( $markup eq 'year' ) {
				$letters = &MTM::Expansion::NumeralExpansion::expandYear( $part, '-', '-' );

			# 5-nasal
			} else {
				$letters = &MTM::Expansion::NumeralExpansion::makeOrthographyCardinal( $part, '-', '-', '-' );
			}

			my $partPron = &MTM::Pronunciation::NumeralPronunciation::pronounce( $letters );

			push @pron, $partPron;

			# print STDERR "Numeral pron\t$partPron\n";


		#-------------------------------------------------------------------------------------------#
		# INITIAL
		} elsif ( $i == 0 ) {

			my $lc_part = MTM::Case::makeLowercase( $part );		# CT 210927
			 
			# print STDERR "Initial: $part\n";
			 
			### TODO: Better handling of quotes
			$lc_part =~ s/\"//g;
			$lc_part =~ s/\’/\'/g;

			# English
			if( $MTM::Vars::lang eq 'en' ) {
				# Special characters, e.g. Greek letters
				if ( exists( $MTM::Legacy::Lists::en_special_character{ $part } )) {
					my( $letters, $partPron ) = split/\t+/, $MTM::Legacy::Lists::en_special_character{ $part };
					push @pron, $partPron;

					# print STDERR "Initial special character: $part\t$partPron\n";


				# Acronym list
				} elsif ( exists( $MTM::Legacy::Lists::en_acronym{ $part } )) {
					my $partPron = $MTM::Legacy::Lists::en_acronym{ $part };
					$partPron =~ s/\t.+$//;
					push @pron, $partPron;

					# print STDERR "\tInitial $MTM::Legacy::Lists::en_acronym part\t$partPron\n";


				# Dictionary
				} elsif ( exists( $MTM::Legacy::Lists::en_initial_dec_parts{ $lc_part } )) {
					my $partPron = $MTM::Legacy::Lists::en_initial_dec_parts{ $lc_part };

					# Safety removal if two pronunciations		CT 150330
					$partPron =~ s/^.+\t(.*[\"\'\,].+)$/$1/;

					push @pron, $partPron;

					# print STDERR "Initial pron\t$partPron\n";

			
				# Spelling/autopron
				} else {

					my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $lc_part );

					# print STDERR"\nNO PRON FOR $part\t$pronunciability\n";

					# Also single letters: "a-uppfattning".
					if ( $pronunciability == 0 || $part =~ /^[a-zåäö]$/i ) {
						# Spelling
						my $partPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $lc_part );
						push @pron, $partPron;

						# print STDERR "\tInitial $MTM::Legacy::Lists::en_acronym part\t$partPron\n";

					} else {
						my $domain = 'swe';
					 	# print STDERR"\nNO PRON FOR $part\t$pronunciability\n";
						my $partPron = &getCartPron( $lc_part, $domain );

						push @pron, $partPron;

						# print STDERR "Initial cart result\t$part\t$domain\t$partPron\n";
					}
				}		
			# Swedish and world
			} else {

				# Flag to avoid wide character error in words such as "χ2-test".		CT 230420
				my $go = 1;

				# If special character + digit, don't lookup in special character hash
				if( $part =~ /($MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)\d+$/ ) {
					$go = 0;
				}

				# Special characters, e.g. Greek letters
				if ( $go == 1 ) {
					if( exists( $MTM::Legacy::Lists::sv_special_character{ $part } )) {
						my( $letters, $partPron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $part };
						push @pron, $partPron;
						$go = 0;	# Don't try the other lookups		CT 230420
						# print STDERR "Initial special character: $part\t$partPron\n";
					}
				}


				if( $go == 1 ) {		# CT 230420
					# Acronym list
					if ( exists( $MTM::Legacy::Lists::sv_acronym{ $part } )) {
						my $partPron = $MTM::Legacy::Lists::sv_acronym{ $part };
						$partPron =~ s/\t.+$//;
						push @pron, $partPron;

						# print STDERR "\tInitial $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";


					# Dictionary
					} elsif ( exists( $MTM::Legacy::Lists::sv_initial_dec_parts{ $lc_part } )) {
						my $partPron = $MTM::Legacy::Lists::sv_initial_dec_parts{ $lc_part };

						# Safety removal if two pronunciations		CT 150330
						$partPron =~ s/^.+\t(.*[\"\'\,].+)$/$1/;

						push @pron, $partPron;

						# print STDERR "Initial pron\t$partPron\n";

				
					# Spelling/autopron
					} else {

						my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $lc_part );

						# print STDERR"\nNO PRON FOR $part\t$pronunciability\n";

						# Also single letters: "a-uppfattning".
						if ( $pronunciability == 0 || $part =~ /^[a-zåäö]$/i ) {
							# Spelling
							my $partPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $lc_part );
							push @pron, $partPron;

							# print STDERR "\tInitial $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";

						} else {
							my $domain = 'swe';
						 	# print STDERR"\nNO PRON FOR $part\t$pronunciability\n";
							my $partPron = &getCartPron( $lc_part, $domain );

							push @pron, $partPron;

							# print STDERR "Initial cart result\t$part\t$domain\t$partPron\n";
						}
					}
				}
			}

		#-------------------------------------------------------------------------------------------#
		# FINAL
		} elsif ( $i == $#decomposed ) {

			# English
			if( $MTM::Vars::lang eq 'en' ) {
				# Special characters, e.g. Greek letters
				if ( exists( $MTM::Legacy::Lists::en_special_character{ $part } )) {
					my( $letters, $partPron ) = split/\t+/, $MTM::Legacy::Lists::en_special_character{ $part };
					push @pron, $partPron;

					# print STDERR "Final special character: $partPron\n";

				# Dictionary
				} elsif (
					exists( $MTM::Legacy::Lists::en_final_dec_parts{ $part } )
				) {

		#			print "FINAL $part\n";

					my $partPron = $MTM::Legacy::Lists::en_final_dec_parts{ $part };
					push @pron, $partPron;

					# print STDERR "Final pron\t$partPron\n";

				# Acronym list
				} elsif ( exists( $MTM::Legacy::Lists::en_acronym{ $part } )) {
					my $partPron = $MTM::Legacy::Lists::en_acronym{ $part };
					$partPron =~ s/\t.+$//;
					push @pron, $partPron;

					# print STDERR "\tFinal $MTM::Legacy::Lists::en_acronym part\t$partPron\n";


				# Spelling/autopron
				} else {

					my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $part );		

					if ( $pronunciability == 0 ) {
						# Spelling
						my $partPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $part );
						push @pron, $partPron;

						# print STDERR "\tFinal $MTM::Legacy::Lists::en_acronym part\t$partPron\n";

					} else {
						my $domain = 'swe';

						my $partPron = &getCartPron( $part, $domain );

						push @pron, $partPron;

						# print STDERR "Final cart result\t$part\t$domain\t$partPron\n";
					}
				}
			# Swedish and world
			} else {
				# Special characters, e.g. Greek letters
				if ( exists( $MTM::Legacy::Lists::sv_special_character{ $part } )) {
					my( $letters, $partPron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $part };
					push @pron, $partPron;

					# print STDERR "Final special character: $partPron\n";

				# Dictionary
				} elsif (
					exists( $MTM::Legacy::Lists::sv_final_dec_parts{ $part } )
				) {
					my $partPron = $MTM::Legacy::Lists::sv_final_dec_parts{ $part };
					push @pron, $partPron;

					# print STDERR "Final pron\t$partPron\n";

				# Acronym list
				} elsif ( exists( $MTM::Legacy::Lists::sv_acronym{ $part } )) {
					my $partPron = $MTM::Legacy::Lists::sv_acronym{ $part };
					$partPron =~ s/\t.+$//;
					push @pron, $partPron;

					# print STDERR "\tFinal $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";

				# Spelling/autopron
				} else {

					my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $part );		

					if ( $pronunciability == 0 ) {
						# Spelling
						my $partPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $part );
						push @pron, $partPron;

						# print STDERR "\tFinal $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";

					} else {
						my $domain = 'swe';

						my $partPron = &getCartPron( $part, $domain );

						push @pron, $partPron;

						# print STDERR "Final cart result\t$part\t$domain\t$partPron\n";
					}
				}
			}

		#-------------------------------------------------------------------------------------------#
		# MEDIAL
		} else {
			# English
			if( $MTM::Vars::lang eq 'en' ) {
				# Special characters, e.g. Greek letters
				if ( exists( $MTM::Legacy::Lists::en_special_character{ $part } )) {
					my( $letters, $partPron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $part };
					push @pron, $partPron;

					# print STDERR "Medial special character: $partPron\n";
				# Dictionary
				} elsif (
					exists( $MTM::Legacy::Lists::en_medial_dec_parts{ $part } )
				) {
					my $partPron = $MTM::Legacy::Lists::en_medial_dec_parts{ $part };
					push @pron, $partPron;

					# print STDERR "Medial pron\t$partPron\n";

				# Acronym list
				} elsif ( exists( $MTM::Legacy::Lists::en_acronym{ $part } )) {
					my $partPron = $MTM::Legacy::Lists::en_acronym{ $part };
					$partPron =~ s/\t.+$//;
					push @pron, $partPron;

					# print STDERR "\tMedial $MTM::Legacy::Lists::en_acronym part\t$partPron\n";

				# Spelling/autopron
				} else {

					my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $part );

					if ( $pronunciability == 0 ) {
						# Spelling
						my $partPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $part );
						push @pron, $partPron;

						# print STDERR "\tMedial $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";

					} else {
						my $domain = 'swe';

						my $partPron = &getCartPron( $part, $domain );

						push @pron, $partPron;

						# print STDERR "Medial cart result\t$part\t$domain\t$partPron\n";
					}
				}
			# Swedish and world
			} else {
				# Special characters, e.g. Greek letters
				if ( exists( $MTM::Legacy::Lists::sv_special_character{ $part } )) {
					my( $letters, $partPron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $part };
					push @pron, $partPron;

					# print STDERR "Medial special character: $partPron\n";
				# Dictionary
				} elsif (
					exists( $MTM::Legacy::Lists::sv_medial_dec_parts{ $part } )
				) {
					my $partPron = $MTM::Legacy::Lists::sv_medial_dec_parts{ $part };

					$partPron =~ s/^m \'ae n s$/m \'a n s/;
					push @pron, $partPron;

					# print STDERR "Medial pron\t$partPron\n"; exit;

				# Acronym list
				} elsif ( exists( $MTM::Legacy::Lists::sv_acronym{ $part } )) {
					my $partPron = $MTM::Legacy::Lists::sv_acronym{ $part };
					$partPron =~ s/\t.+$//;
					push @pron, $partPron;

					# print STDERR "\tMedial $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";

				# Spelling/autopron
				} else {

					my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $part );

					if ( $pronunciability == 0 ) {
						# Spelling
						my $partPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $part );
						push @pron, $partPron;

						# print STDERR "\tMedial $MTM::Legacy::Lists::sv_acronym part\t$partPron\n";

					} else {
						my $domain = 'swe';

						my $partPron = &getCartPron( $part, $domain );

						push @pron, $partPron;

						# print STDERR "Medial cart result\t$part\t$domain\t$partPron\n";
					}
				}
			}

		}
		$i++;
	}	
	my $pron = join" $MTM::Vars::compound_boundary ", @pron;


	if( $MTM::Vars::lang eq 'en' ) {
		$pron = &MTM::Pronunciation::Stress::en_compound_stress( $pron );
	} else {
		$pron = &MTM::Pronunciation::Swedify::swedify( $pron );
		$pron = &MTM::Pronunciation::Stress::sv_compound_stress( $pron );
	}
	# print STDERR "\nReturning $decomposed\t$pron\n";

	$pron =~ s/^[\s\-]+//;

	return( $pron );
}
#**************************************************************#
sub getCartPron {
	my ( $part, $domain ) = @_;


	if( $runmode ne 'wordLookup' ) {
		use MTM::Pronunciation::Conversion::TPA;
		my $partPron = &MTM::Pronunciation::Autopron::cartAndStress( $part, $domain );
		$partPron = MTM::Pronunciation::Conversion::TPA::decode( $partPron, $partPron );
		$partPron = &MTM::Pronunciation::Syllabify::syllabify( $partPron );
		return $partPron;
	}

	return 'void';

}
#**************************************************************#
1;
