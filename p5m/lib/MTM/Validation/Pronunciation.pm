package MTM::Validation::Pronunciation;

#*********************************************************#
# Validation::Pronunciation.pm
#
# CT 210930
#*********************************************************#
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


my $matchTable = "lib/MTM/Validation/Vars/validation_match_table.pl";

use MTM::Case;

#*********************************************************#
# Variables
#*********************************************************#
# Counters
our $nFormat = 0;
our $nCase = 0;
our $nMarkup = 0;
our $nMainStress = 0;
our $nSecStress = 0;
our $nPhone = 0;
our $nPhoneSweIniSanity = 0;
our $nPhoneSweFinSanity = 0;
our $nPhoneSweAcrSanity = 0,
our $nCheckedSwe = 0;
our $nCheckedEng = 0;
our $nCheckedSweAcr = 0;
our $nUncheckedWords = 0;
our $nCompound = 0;
our $nNonCompound = 0;

# Endings
our @sv_acronym_endings = qw( s t n );
our $sv_acronym_endings = join"|", @sv_acronym_endings;


my %sanityWarnings = ();
my %help = ();
my %example = ();

our ( $validCase, $validMarkup );
our ( $valStress, $valMainStress, $valAccentI, $valAccentII, $valSecStress, $valEngMainStress );
our ( $valVowels, $valEngVowels, $valConsos, $valPhones, $schwa, $tmpValVowels, $tmpValPhones );
#our ( $nFormat, $nCase, $nMarkup, $nMainStress, $nSecStress, $nPhone, $nPhoneSweIniSanity, $nPhoneSweFinSanity, $nPhoneSweAcrSanity );
#our ( $nCheckedSwe, $nCheckedEng, $nCheckedSweAcr, $nUncheckedWords );
our ( $sweIniLetters,$engIniLetters, $sweAcrLetters, $sweAcrEndLetters );
#our ( $nCompound, $nNonCompound );
our ( $sweFinLetters,$engFinLetters );
our ( %tpaSweIniMatch, %tpaEngIniMatch );
our ( %tpaSweAcrMatch, %tpaSweAcrEndMatch );
our ( %tpaSweFinMatch, %tpaEngFinMatch );
our ( %mtmSweIniMatch, %mtmEngIniMatch );
our ( %mtmSweAcrMatch, %mtmSweAcrEndMatch );
our ( %mtmSweFinMatch, %mtmEngFinMatch );
our ( %acaSweFinMatch, %acaEngFinMatch );
our ( %acaSweIniMatch, %acaEngIniMatch );
our ( %acaSweAcrMatch, %acaSweAcrEndMatch );
our ( %cereprocSweIniMatch, %cereprocEngIniMatch );
our ( %cereprocSweAcrMatch, %cereprocSweAcrEndMatch );
our ( %cereprocSweFinMatch, %cereprocEngFinMatch );
our ( @valEngVowels, @valEngConsos, @valPhones, @valVowels, @valConsos );

&readMatchingTable( $matchTable );

#*********************************************************#
# pronValidation
#*********************************************************#
sub validate {
	my ( $orth, $pron, $pronlang, $pa, $checkPhoneMatch, $pos, $decomp, $flag ) = @_;

	my $use_vars = 'mtmVars';

	if ( $pa =~ /mtm$/i ) {
		&mtmVars();
	} elsif ( $pa =~ /tpa$/i ) {
		&tpaVars();
	} elsif ( $pa =~ /(cereproc|cp)$/i ) {
		&cereprocVars();
	} elsif ( $pa =~ /cereproc_en/ ) {
		&cereprocVars_en();
	} elsif ( $pa =~ /acapela/ ) {
		&acapelaVars();
	} elsif ( $pa =~ /ms-ipa/ ) {
		&ipaVars();
	} else {
		&tpaVars();
	}

	@valPhones = $valPhones;

	my @pronWarnings = ();
	my $pronWarnings;
	my @help = ();
	my @example = ();

	#*********************************************#
	# Transcription checks
	#------------------------------------------#
	#*************************************************************#
	# English
	#*************************************************************#
	if ( $pa =~ /(cereproc|cp)$/ && $pronlang =~ /^en/i ) {
		$nCheckedEng++;

#		print "IIIII $pa\t$pronlang\t$valStress\n";
		# Remove syllable and compound limits	NB: use them later
		$pron =~ s/ [\|\$\-\~] / /g;

		my @pron = split/ [\|\¤] /, $pron;

		#*************************************************#
		# Stressable phones
		foreach my $p ( @pron ) {

			$p =~ s/ [\|\$\-\~] / /g;

			my @phones = split/ /, $p;
			foreach my $phone ( @phones ) {

				# TPA
				if ( $pa =~ /(tpa)/i ) {
					# Valid phones
					if ( $phone !~ /^($valEngMainStress)?($valEngVowels|$valConsos)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tOgiltigt engelskt fonem: $p";
					}

					# Only vowels (not @) can have main stress
					if ( $phone =~ /^($valMainStress)($valConsos|$schwa)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tOgiltig engelsk fonembetoning: $p";
					}

				# Cereproc Ylva	?????
				} elsif ( $pa =~ /(cereproc|cp)$/i ) {
					# Valid phones
					if ( $phone !~ /^($valEngVowels|$valConsos)($valEngMainStress)?$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tOgiltigt engelskt fonem: /$p/";
						push @help, "HJÄLP\tGiltiga engelska vokaler: @valEngVowels\tGiltiga engelska konsonanter: @valEngConsos";

					}

					# Only vowels (not @) can have main stress
					if ( $phone =~ /^($valConsos|$schwa)($valMainStress)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter och schwa (/eh/) kan inte ha huvudbetoning ($valMainStress): $p";
						push @help, "HJÄLP\tBara vokaler (förutom schwa /eh/) kan ha huvudbetoning ($valMainStress): @valEngVowels";
					}

				# Cereproc William
				} elsif ( $pa =~ /(cereproc_en|cp_en)/i ) {

					my $tmpPhone = $phone;
					$tmpPhone =~ s/\@/ë/g;

					# Valid phones
					if ( $tmpPhone !~ /^($tmpValVowels|$valConsos)($valStress)?$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tOgiltigt engelskt fonem: /$phone/";
						push @help, "HJÄLP\tGiltiga engelska vokaler: @valVowels\tGiltiga engelska konsonanter: @valConsos";
					}

					# Only vowels (not @) can have stress
					if ( $phone =~ /^($valConsos|$schwa)($valEngMainStress)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter och schwa (/@/) kan inte ha huvudbetoning (1): $p";
						push @help, "HJÄLP\tBara vokaler (förutom schwa /@/) kan ha huvudbetoning (1): @valEngVowels";
					}
				}			
			}
		}

		#*************************************************************#
		# Stress checks		
		@pron = split/ [\|\¤] /, $pron;

		foreach my $p ( @pron ) {

			# Pron must have main stress
			if ( $p !~ /($valMainStress)/ && $pos !~ / SMS$/ && $pos ne 'IN' ) {
				$nMainStress++;
				push @pronWarnings, "VARNING\tHuvudbetoning saknas\t/$p/";
				push @help, "HJÄLP\tOrdet måste ha en huvudbetoning ($valMainStress).";

				if ( $pa =~ /(cereproc|cp)$/i ) {
					my $example = 'Huvudbetoning, engelska: w i4 n eh0 rh';
					push @example, "EXEMPEL\t$example";
				}
			}

			# Pron can have only one main stress
			if ( $p =~ /($valEngMainStress).+($valEngMainStress)/ ) {
				$nMainStress++;
				push @pronWarnings, "VARNING\tEndast en huvudbetoning är tillåten\t/$p/";
				push @help, "HJÄLP\tOrdet kan bara ha en huvudbetoning ($valMainStress).";

				if ( $pa =~ /(cereproc|cp)$/i ) {
					my $example = 'Huvudbetoning, engelska: o4 rh i0 jh i0 n';
					push @example, "EXEMPEL\t$example";
				}
			}

			# If pron has accent I, secondary stress is prohibited
			# Not for English
			#if ( $p =~ /($valEngMainStress)/ && $p =~ /($valSecStress)/ ) {
			#	$nSecStress++;
			#	push @pronWarnings, "VARNING\tBibetoning\t/$p/";
			#	push @help, "HJÄLP\tOm ordet har accent I ($valAccentI) får det inte ha bibetoning ($valSecStress)";
			#
			#	if ( $pa =~ /(cereproc|cp)$/i ) {
			#		my $example = 'Huvudbetoning, engelska: o4 rh i0 jh i0 n';
			#		push @example, "EXEMPEL\t$example";
			#	}
			#}
		}

	#*************************************************************#
	# SWEDISH
	#*************************************************************#
	# SWEDISH
	} elsif ( $pronlang =~ /^s[vw]/i ) {

		# Remove syllable and compound limits	NB: use them later
		$pron =~ s/ [\|\$\-\~\.] / /g; # CT 171024

		$pron =~ s/ \¤ / \| /g;			# Old-style word delimiter

		my @pron = split/ [\|] /, $pron;

		#*************************************************#
		# Stressable phones
		foreach my $p ( @pron ) {

			my @phones = split/ /, $p;
			foreach my $phone ( @phones ) {

				# MTM
				if ( $pa =~ /mtm/i ) {
					
					# Valid phones
					if ( $phone !~ /^($valStress)?($valPhones)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tOgiltigt svenskt fonem: /$phone/";
						push @help, "HJÄLP\tGiltiga fonem och avskiljare: @valPhones";
					}

					# Only vowels (not @) can have main stress
					if ( $phone =~ /^($valMainStress)($valConsos|$schwa)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter och schwa /ë/ kan inte ha huvudbetoning $phone";
						push @help, "HJÄLP\tVokaler som kan ha huvudbetoning: @valVowels";
					}

					# Only vowels (including ex) can have secondary stress
					if ( $phone =~ /^($valSecStress)($valConsos)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter kan inte ha bibetoning:\t/$phone/";
						push @help, "HJÄLP\tVokaler som kan ha bibetoning: @valVowels $schwa";

						#if ( $pa =~ /(cereproc|cp)$/i ) {
						#	my $example = 'Huvudbetoning på vokal: saker	/s aa4 k eh0 r/';
						#	push @example, "EXEMPEL\t$example";
						#}
					}
				# TPA
				} elsif ( $pa =~ /tpa/i ) {
					# Valid phones
					if ( $phone !~ /^($valStress)?($valPhones)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tOgiltigt svenskt fonem: /$phone/";
						push @help, "HJÄLP\tGiltiga fonem och avskiljare: @valPhones";

						if ( $pa =~ /(cereproc|cp)$/i ) {
							my $example = 'Huvudbetoning, svenska: saker	/s aa4 k eh0 r/';
							push @example, "EXEMPEL\t$example";
						}
					}

					# Only vowels (not @) can have main stress
					if ( $phone =~ /^($valMainStress)($valConsos|$schwa)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter och schwa /ë/ kan inte ha huvudbetoning $phone";
						push @help, "HJÄLP\tVokaler som kan ha huvudbetoning: @valVowels";

						if ( $pa =~ /(cereproc|cp)$/i ) {
							my $example = 'Huvudbetoning på vokal: saker	/s aa4 k eh0 r/';
							push @example, "EXEMPEL\t$example";
						}
					}

					# Only vowels (including @) can have secondary stress
					if ( $phone =~ /^($valSecStress)($valConsos)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter kan inte ha bibetoning:\t/$phone/";
						push @help, "HJÄLP\tVokaler som kan ha bibetoning: @valVowels $schwa";

						if ( $pa =~ /(cereproc|cp)$/i ) {
							my $example = 'Huvudbetoning på vokal: saker	/s aa4 k eh0 r/';
							push @example, "EXEMPEL\t$example";
						}
					}

				# Acapela
				} elsif ( $pa =~ /aca/i ) {

					# Valid phones
					if ( $phone !~ /^($valPhones)($valStress)?$/ ) {
						$nPhone++;
						push @pronWarnings, "Invalid phone: /$phone/";
					}

					# Only vowels (not @) can have main stress
					if ( $phone =~ /^($valConsos|$schwa)($valMainStress)$/ ) {
						$nPhone++;
						push @pronWarnings, "Phone cannot have main stress:\t/$phone/";
					}

					# Only vowels (including @) can have secondary stress
					if ( $phone =~ /^($valConsos)($valSecStress)$/ ) {
						$nPhone++;
						push @pronWarnings, "Phone cannot have secondary stress:\t/$phone/";
					}

				# Cereproc
				} elsif ( $pa =~ /cereproc/i ) {

					# Valid phones
					if ( $phone !~ /^($valPhones)($valStress)?$/ ) {
						$nPhone++;

						push @pronWarnings, "FELMEDDELANDE\tOgiltigt svenskt fonem:\t/$phone/";
						push @help, "HJÄLP\tGiltiga fonem och avskiljare: @valPhones";
					}

					# Only vowels (not /eh/) can have main stress
					if ( $phone =~ /^($valConsos)($valMainStress)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter och schwa /eh/ kan inte ha huvudbetoning $phone";
						push @help, "HJÄLP\tVokaler som kan ha huvudbetoning: @valVowels";

						if ( $pa =~ /(cereproc|cp)$/i ) {
							my $example = 'Huvudbetoning accent I: saker	/s aa4 k eh0 r/	Huvudbetoning accent II: sakna	/s aa3 k n a0/';
							push @example, "EXEMPEL\t$example";
						}
					}

					# Only vowels (including /eh/) can have secondary stress
					if ( $phone =~ /^($valConsos)($valSecStress)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tKonsonanter kan inte ha bibetoning:\t/$phone(";
						push @help, "HJÄLP\tVokaler som kan ha bibetoning: @valVowels $schwa";

						if ( $pa =~ /(cereproc|cp)$/i ) {
							my $example = 'Bibetoning accent II: sakna	/s aa3 k n a0/';
							push @example, "EXEMPEL\t$example";
						}
					}

					# All vowels (including /eh/) must have a stress marker.
					if ( $phone =~ /^($valVowels)$/ ) {
						$nPhone++;
						push @pronWarnings, "FELMEDDELANDE\tAlla vokaler måste ha betoning:\t/$phone/";
						push @help, "HJÄLP\tObetonade vokaler ska åtföljas av 0.";

						if ( $pa =~ /(cereproc|cp)$/i ) {
							my $example = 'Accent I: saker	/s aa4 k eh0 r/	Huvudbetoning accent II: sakletare	/s aa3 k l ee2 t a0 r eh0/';
							push @example, "EXEMPEL\t$example";
						}
					}
				}
			}
		}
		#*************************************************************#
		# Stress checks
		@pron = split/ \| /, $pron;

		foreach my $p ( @pron ) {

			# Pron must have main stress (if not SMS)
			if ( $p !~ /($valMainStress)/ && $pos !~ / SMS$/ && $pos ne 'IN' ) {
				$nMainStress++;
				push @pronWarnings, "VARNING\tHuvudbetoning saknas:\t/$p/";
				push @help, "HJÄLP\tEn huvudbetoning måste finnas ($valMainStress)."
			}

			# Allow multiple main stresses.	CT 170315
			# Pron can have only one main stress
			#if ( $p =~ /($valMainStress).+($valMainStress)/ ) {
			#	$nMainStress++;
			#	push @help, "VARNING! Flera huvudbetoningar:\t/$p/";
			#	push @help, "HJÄLP\tNormalt sett är endast en huvudbetoning är tillåten, accent I ($valAccentI) eller accent II ($valAccentII).";
			#}

			if( $pa =~ /(tpa|ipa)/i ) {
				# If pron has accent II, secondary stress is required
				if ( $p =~ /($valAccentII)/ && $pron !~ /($valAccentII).+($valSecStress)/ ) {
					$nSecStress++;
					push @pronWarnings, "VARNING\tBibetoning saknas:\t/$p/";
					push @help, "HJÄLP\tEtt ord med accent II ($valAccentII) måste ha bibetoning ($valSecStress).";
				}
			} else {
				# If pron has accent II, secondary stress is required if it's a compound
				if ( $decomp =~ /\+/ && $p =~ /($valAccentII)/ && $pron !~ /($valAccentII).+($valSecStress)/ ) {
					$nSecStress++;
					push @pronWarnings, "VARNING\tBibetoning saknas:\t/$p/";
					push @help, "HJÄLP\tEn sammansättning måste ha sammansättningsbetoning med accent II ($valAccentII) och bibetoning ($valSecStress).";
				}
			}

			# If pron has accent I, secondary stress is prohibited
			#if ( $p =~ /($valAccentI)/ && $p =~ /($valSecStress)/ ) {
			# If pron hasn't accent II, secondary stress is prohibited	CT 170313
			if ( $p !~ /($valAccentII)/ && $p =~ /($valSecStress)/ ) {
				$nSecStress++;
				push @pronWarnings, "VARNING\tOgiltig bibetoning:\t/$p/";
				push @help, "HJÄLP\tAccent I ($valAccentI) kan inte ha bibetoning ($valSecStress).";
			}

			# If not multiword expression		CT 170313
			if( $p !~ /($valMainStress).+($valMainStress)/ ) {

				# Secondary stress can not occur before main stress
				if ( $p =~ /($valSecStress).+($valMainStress)/ ) {
					$nSecStress++;
					push @pronWarnings, "VARNING\tOtillåten bibetoning\t/$p/";
					push @help, "HJÄLP\tBibetoning ($valSecStress) får ej förekomma före huvudbetoning ($valAccentII)\t/$p/";
				}

				# Pron can have only one secondary stress
				if ( $p =~ /($valSecStress).+($valSecStress)/ ) {
					$nSecStress++;
					push @pronWarnings, "VARNING\tFler än en bibetoning:\t/$p/";
					push @help, "HJÄLP\tEndast en bibetoning ($valSecStress) får finnas\t/$p/";
				}
			}

			# If there's only one vowel, it must have accent I
			my $nVowels = $p =~ s/($valVowels)/$1/g;

			# CT 240130 Seems that this one reacts on single vowel words, also when there is a correct main stress (accent I).
			# CT 240216 No?
			# CT 240404 Done.
			if ( $nVowels == 1 ) {
				if ( $pa =~ /(cereproc|cp)$/i ) {
					if( $p !~ /4/ || $p =~ /[012356789]/ ) {
						$nPhone++;
						push @pronWarnings, "VARNING\tDet finns ingen huvudbetoning ($valAccentI) och det finns endast en vokal i ordet:\t/$p/";
						push @help, "HJÄLP\tOm det bara finns en vokal i ordet måste den ha accent I ($valAccentI).";

						my $example = 'Accent I: sak	/s aa4 k/';
						push @example, "EXEMPEL\t$example";
					}
				} elsif ( $pa =~ /tpa/i ) {
					if( $p !~ /\'/ || $p =~ /[\"\`]/ ) {
						$nPhone++;
						push @pronWarnings, "VARNING\tDet finns ingen huvudbetoning ($valAccentI) och det finns endast en vokal i ordet:\t/$p/";
						push @help, "HJÄLP\tOm det bara finns en vokal i ordet måste den ha accent I ($valAccentI).";

						my $example = 'Accent I: sak	/s \'a2: k/';
						push @example, "EXEMPEL\t$example";
					}
				} elsif ( $pa =~ /mtm/i ) {
					if( $p !~ /\'/ || $p =~ /[\"\,]/ ) {
						$nPhone++;
						push @pronWarnings, "VARNING\tDet finns ingen huvudbetoning ($valAccentI) och det finns endast en vokal i ordet:\t/$p/";
						push @help, "HJÄLP\tOm det bara finns en vokal i ordet måste den ha accent I ($valAccentI).";

						my $example = 'Accent I: sak	/s \'a2: k/';
						push @example, "EXEMPEL\t$example";
					}
				}			
			}
		}
	#*************************************************************#
	# WILLIAM
	} elsif ( $pa =~ /(cereproc_en)/ ) {

		my $tmpPron = $pron;
		$tmpPron =~ s/ [\$\-\~] / /g;

		my @pron = split/ [\|\¤] /, $tmpPron;

		#*************************************************#
		# Stressable phones
		foreach my $p ( @pron ) {

			my @phones = split/ /, $p;
			foreach my $phone ( @phones ) {

				my $tmpPhone = $phone;
				$tmpPhone =~ s/\@/ë/g;

				# Valid phones
				if ( $tmpPhone !~ /^($valVowels|$valConsos)($valStress)?$/ ) {
					$nPhone++;
					push @pronWarnings, "FELMEDDELANDE\tOgiltigt engelskt fonem: /$phone/";
					push @help, "HJÄLP\tGiltiga engelska vokaler: @valVowels\tGiltiga engelska konsonanter: @valConsos";
				}

				# Only vowels (not @) can have stress
				if ( $tmpPhone =~ /^($valConsos|$schwa)($valStress)$/ ) {
					$nPhone++;
					push @pronWarnings, "FELMEDDELANDE\tKonsonanter och schwa (/@/) kan inte ha huvudbetoning (1): $p";
					push @help, "HJÄLP\tBara vokaler (förutom schwa /@/) kan ha huvudbetoning (1): @valEngVowels";
				}


				# All vowels (including /eh/) must have a stress marker.
				if ( $phone =~ /^($valVowels)$/ ) {
					$nPhone++;
					push @pronWarnings, "FELMEDDELANDE\tAlla vokaler måste ha betoning:\t/$phone/";
					push @help, "HJÄLP\tObetonade vokaler ska åtföljas av 0.";

					if ( $pa =~ /(cereproc|cp)$/i ) {
						my $example = 'Accent I: saker	/s aa4 k eh0 r/	Huvudbetoning accent II: sakletare	/s aa3 k l ee2 t a0 r eh0/';
						push @example, "EXEMPEL\t$example";
					}
				}
			}
		}
		#*************************************************************#
		# Stress checks		
		@pron = split/ [\|\¤] /, $pron;

		foreach my $p ( @pron ) {

			# Pron must have main stress
			if ( $p !~ /($valEngMainStress)/ && $pos !~ / SMS$/ && $pos ne 'IN' ) {
				$nMainStress++;
				push @pronWarnings, "VARNING\tHuvudbetoning saknas\t/$p/";
				push @help, "HJÄLP\tOrdet måste ha en huvudbetoning ($valEngMainStress).";

				if ( $pa =~ /(cereproc|cp)_en$/i ) {
					my $example = 'Huvudbetoning, engelska: w i1 n @0 r';
					push @example, "EXEMPEL\t$example";
				}
			}

			if ( $pa =~ /(cp|cereproc)$/i ) {

				# Pron can have only one main stress
				if ( $p =~ /($valEngMainStress).+($valEngMainStress)/ ) {
					$nMainStress++;
					push @pronWarnings, "VARNING\tEndast en huvudbetoning är tillåten\t/$p/";
					push @help, "HJÄLP\tOrdet kan bara ha en huvudbetoning ($valMainStress).";

					if ( $pa =~ /(cereproc|cp)_en$/i ) {
						my $example = 'Huvudbetoning, engelska: o4 rh i0 jh i0 n';
						push @example, "EXEMPEL\t$example";
					}
				}

				# If pron has accent I, secondary stress is prohibited
				if ( $p =~ /($valEngMainStress)/ && $p =~ /($valSecStress)/ ) {
					$nSecStress++;
					push @pronWarnings, "VARNING\tBibetoning\t/$p/";
					push @help, "HJÄLP\tOm ordet har accent I ($valAccentI) får det inte ha bibetoning ($valSecStress)";

					if ( $pa =~ /(cereproc|cp)$/i ) {
						my $example = 'Huvudbetoning, engelska: o4 rh i0 jh i0 n';
						push @example, "EXEMPEL\t$example";
					}
				}
			}
		}
	}

	my $sanityWarnings;
	my $help;
	if( $pa !~ /(tacotron|ipa)/i ) {
		( $sanityWarnings, $help ) = &sanityCheck( $pron, $orth, $pos, $pronlang, $pa, $checkPhoneMatch );
	}

	return( \@pronWarnings, $sanityWarnings, \@help, \@example );
}

#*********************************************************#
sub readMatchingTable {

	my $matchTable = shift;

	our @sweIniLetters;
	our %mtmSweIniMatch = ();
	our %tpaSweIniMatch = ();
	our %acaSweIniMatch = ();
	our %cereprocSweIniMatch = ();
	our @sweFinLetters;
	our %mtmSweFinMatch = ();
	our %tpaSweFinMatch = ();
	our %acaSweFinMatch = ();
	our %cereprocSweFinMatch = ();

	our @engIniLetters = ();
	our %mtmEngIniMatch = ();
	our %tpaEngIniMatch = ();
	our %acaEngIniMatch = ();
	our %cereprocEngIniMatch = ();
	our @engFinLetters = ();
	our %mtmEngFinMatch = ();
	our %tpaEngFinMatch = ();
	our %acaEngFinMatch = ();
	our %cereprocEngFinMatch = ();

	our @sweAcrLetters = ();
	our @sweAcrEndLetters = ();
	our %mtmSweAcrMatch = ();
	our %tpaSweAcrMatch = ();
	our %acaSweAcrMatch = ();
	our %cereprocSweAcrMatch = ();
	our %mtmSweAcrEndMatch = ();
	our %tpaSweAcrEndMatch = ();
	our %acaSweAcrEndMatch = ();
	our %cereprocSweAcrEndMatch = ();


	## no critic (InputOutput::RequireBriefOpen)
	my $fh;
	open $fh, '<', $matchTable or die "Cannot open matchTable $matchTable $fh: $!";
	## use critic
	while (<$fh>) {
		chomp;
		s/\r//g;
		#next if /^\#/;
		#next if /^\s*$/;


		my $line = $_;
		next if $line !~ /^(SWE|ENG)/;

		my ( $position, $letters, $mtmPhones, $tpaPhones, $acaPhones, $cereprocPhones ) = split/\t+/, $line;

		my @mtmPhones = split/ +/, $mtmPhones;
		my @tpaPhones = split/ +/, $tpaPhones;
		my @acaPhones = split/ +/, $acaPhones;
		my @cereprocPhones = split/ +/, $cereprocPhones;
		my @letters = split/ +/, $letters;


		# Word initial
		if ( $position =~ /^sweini/i ) {
			push @sweIniLetters, @letters;
			foreach my $letter ( @letters ) {
				if ( not( exists( $tpaSweIniMatch{ $letter } ))) {
					# Create var and remove hyphen in phone clusters
					my $mtmPhones = join"|", @mtmPhones;
					my $tpaPhones = join"|", @tpaPhones;
					my $acaPhones = join"|", @acaPhones;
					my $cereprocPhones = join"|", @cereprocPhones;
					$mtmPhones =~ s/-/ /g;
					$tpaPhones =~ s/-/ /g;
					$acaPhones =~ s/-/ /g;
					$cereprocPhones =~ s/-/ /g;
					$mtmSweIniMatch{ $letter } = $mtmPhones;
					$tpaSweIniMatch{ $letter } = $tpaPhones;
					$acaSweIniMatch{ $letter } = $acaPhones;
					$cereprocSweIniMatch{ $letter } = $cereprocPhones;

				} else {
					print "$letter already exists: $tpaSweIniMatch{ $letter }\t$tpaPhones\n";
				}
			}
		} elsif ( $position =~ /^engini/i ) {
			push @engIniLetters, @letters;
			foreach my $letter ( @letters ) {

				if ( not( exists( $mtmEngIniMatch{ $letter } ))) {
					# Create var and remove hyphen in phone clusters
					my $mtmPhones = join"|", @mtmPhones;
					my $tpaPhones = join"|", @tpaPhones;
					my $acaPhones = join"|", @acaPhones;
					my $cereprocPhones = join"|", @cereprocPhones;
					$mtmPhones =~ s/-/ /g;
					$tpaPhones =~ s/-/ /g;
					$acaPhones =~ s/-/ /g;
					$cereprocPhones =~ s/-/ /g;
					$mtmEngIniMatch{ $letter } = $mtmPhones;
					$tpaEngIniMatch{ $letter } = $tpaPhones;
					$acaEngIniMatch{ $letter } = $acaPhones;
					$cereprocEngIniMatch{ $letter } = $cereprocPhones;
				} else {
					print "$letter already exists: $mtmEngIniMatch{ $letter }\t$tpaPhones\n";
				}
			}

		# Word final
		} elsif ( $position =~ /^swefin/i ) {
			push @sweFinLetters, @letters;
			foreach my $letter ( @letters ) {

				if ( not( exists( $tpaSweFinMatch{ $letter } ))) {
					# Create var and remove hyphen in phone clusters
					my $mtmPhones = join"|", @mtmPhones;
					my $tpaPhones = join"|", @tpaPhones;
					my $acaPhones = join"|", @acaPhones;
					my $cereprocPhones = join"|", @cereprocPhones;
					$mtmPhones =~ s/-/ /g;
					$tpaPhones =~ s/-/ /g;
					$acaPhones =~ s/-/ /g;
					$cereprocPhones =~ s/-/ /g;
					$mtmSweFinMatch{ $letter } = $mtmPhones;
					$tpaSweFinMatch{ $letter } = $tpaPhones;
					$acaSweFinMatch{ $letter } = $acaPhones;
					$cereprocSweFinMatch{ $letter } = $cereprocPhones;

				} else {
					print "$letter already exists: $tpaSweFinMatch{ $letter }\t$tpaPhones\n";
				}
			}
		} elsif ( $position =~ /^engfin/i ) {
			push @engFinLetters, @letters;
			foreach my $letter ( @letters ) {

				if ( not( exists( $tpaEngFinMatch{ $letter } ))) {
					# Create var and remove hyphen in phone clusters
					my $mtmPhones = join"|", @mtmPhones;
					my $tpaPhones = join"|", @tpaPhones;
					my $acaPhones = join"|", @acaPhones;
					my $cereprocPhones = join"|", @cereprocPhones;
					$mtmPhones =~ s/-/ /g;
					$tpaPhones =~ s/-/ /g;
					$acaPhones =~ s/-/ /g;
					$cereprocPhones =~ s/-/ /g;
					$mtmEngFinMatch{ $letter } = $mtmPhones;
					$tpaEngFinMatch{ $letter } = $tpaPhones;
					$acaEngFinMatch{ $letter } = $acaPhones;
					$cereprocEngFinMatch{ $letter } = $cereprocPhones;
				} else {
					print "$letter already exists: $tpaEngFinMatch{ $letter }\t$tpaPhones\n";
				}
			}

		# Acronym endings
		} elsif ( $position =~ /sweacrend/i ) {
			push @sweAcrEndLetters, @letters;
			foreach my $letter ( @letters ) {

				if ( not( exists( $tpaSweAcrEndMatch{ $letter } ))) {
					# Create var and remove hyphen in phone clusters
					my $mtmPhones = join"|", @mtmPhones;
					my $tpaPhones = join"|", @tpaPhones;
					my $acaPhones = join"|", @acaPhones;
					my $cereprocPhones = join"|", @cereprocPhones;
					$mtmPhones =~ s/-/ /g;
					$tpaPhones =~ s/-/ /g;
					$acaPhones =~ s/-/ /g;
					$cereprocPhones =~ s/-/ /g;
					$mtmSweAcrEndMatch{ $letter } = $mtmPhones;
					$tpaSweAcrEndMatch{ $letter } = $tpaPhones;
					$acaSweAcrEndMatch{ $letter } = $acaPhones;
					$cereprocSweAcrEndMatch{ $letter } = $cereprocPhones;

				} else {
					print "$letter already exists: $tpaSweAcrEndMatch{ $letter }\t$tpaPhones\n";
				}
			}

		# Swedish acronyms
		} elsif ( $position =~ /sweacr/i ) {
			push @sweAcrLetters, @letters;
			foreach my $letter ( @letters ) {

				if ( not( exists( $tpaSweAcrMatch{ $letter } ))) {
					# Create var and remove hyphen in phone clusters
					my $mtmPhones = join"|", @mtmPhones;
					my $tpaPhones = join"|", @tpaPhones;
					my $acaPhones = join"|", @acaPhones;
					my $cereprocPhones = join"|", @cereprocPhones;
					$mtmPhones =~ s/-/ /g;
					$tpaPhones =~ s/-/ /g;
					$acaPhones =~ s/-/ /g;
					$cereprocPhones =~ s/-/ /g;
					$mtmSweAcrMatch{ $letter } = $mtmPhones;
					$tpaSweAcrMatch{ $letter } = $tpaPhones;
					$acaSweAcrMatch{ $letter } = $acaPhones;
					$cereprocSweAcrMatch{ $letter } = $cereprocPhones;

				} else {
					print "$letter already exists: $tpaSweAcrMatch{ $letter }\t$tpaPhones\n";
				}
			}
		}	
	}
	close $fh;

	# Put the longest chunks first
	@sweIniLetters = sort { length($b) <=> length($a) || $a cmp $b } @sweIniLetters;
	our $sweIniLetters = join"|", @sweIniLetters;

	@engIniLetters = sort { length($b) <=> length($a) || $a cmp $b } @engIniLetters;
	our $engIniLetters = join"|", @engIniLetters;

	@sweFinLetters = sort { length($b) <=> length($a) || $a cmp $b } @sweFinLetters;
	our $sweFinLetters = join"|", @sweFinLetters;

	@engFinLetters = sort { length($b) <=> length($a) || $a cmp $b } @engFinLetters;
	our $engFinLetters = join"|", @engFinLetters;

	@sweAcrLetters = sort { length($b) <=> length($a) || $a cmp $b } @sweAcrLetters;
	our $sweAcrLetters = join"|", @sweAcrLetters;

	@sweAcrEndLetters = sort { length($b) <=> length($a) || $a cmp $b } @sweAcrLetters;
	our $sweAcrEndLetters = join"|", @sweAcrEndLetters;

	return 1;
}
#***************************************************#
sub sanityCheck {

	my( $pron, $orth, $pos, $pronlang, $pa, $checkPhoneMatch ) = @_;

	my %tmpMatch = ();
	my %tmpSweAcrMatch = ();
	my %tmpSweAcrEndMatch = ();
	my %tmpIniMatch = ();
	my %tmpFinMatch = ();
	my( $tmpLetters, $tmpIniLetters, $tmpFinLetters );
	my $check = 0;
	my @sanityWarnings = ();
	my @help = ();

	# Swedish
	if (
		$pronlang eq 'swe'
		&&
		$pos !~ /(MIX|URL|ENG|NOB|FRE|GER|DAN|JAP|ITA|GER|SPA|ICE|LAT|SLA|FIN|ABBR|ACR|UNK)/i
		#&&
		#$line[9] !~ /:1/
	) {

		# Initial
		$tmpIniLetters = $sweIniLetters;
		$check = 1;
		if ( $pa =~ /mtm/i ) {
			%tmpIniMatch = %mtmSweIniMatch;
		} elsif ( $pa =~ /tpa/i ) {
			%tmpIniMatch = %tpaSweIniMatch;
		} elsif ( $pa =~ /acapela/i ) {
			%tmpIniMatch = %acaSweIniMatch;
		} elsif ( $pa =~ /(cereproc|cp)$/i ) {
			%tmpIniMatch = %cereprocSweIniMatch;
		}

		# Final
		$tmpFinLetters = $sweFinLetters;
		$check = 1;
		if ( $pa =~ /mtm/i ) {
			%tmpFinMatch = %mtmSweFinMatch;
		} elsif ( $pa =~ /tpa/i ) {
			%tmpFinMatch = %tpaSweFinMatch;
		} elsif ( $pa =~ /acapela/i ) {
			%tmpFinMatch = %acaSweFinMatch;
		} elsif ( $pa =~ /(cereproc|cp)$/i ) {
			%tmpFinMatch = %cereprocSweFinMatch;

		}
		$nCheckedSwe++;

	# English
	} elsif ( ( $pronlang =~ /ENG/ && $pos !~ /MIX/ ) || $pa =~ /(cp|cerpeproc)_en/ ) {

		# Initial
		$tmpIniLetters = $engIniLetters;
		$check = 1;
		if ( $pa =~ /mtm/i ) {
			%tmpIniMatch = %mtmEngIniMatch;
		} elsif ( $pa =~ /tpa/i ) {
			%tmpIniMatch = %tpaEngIniMatch;
		} elsif ( $pa =~ /acapela/i ) {
			%tmpIniMatch = %acaEngIniMatch;
		} elsif ( $pa =~ /(cereproc|cp)$/i ) {
			%tmpIniMatch = %cereprocEngIniMatch;
		}

		# Final
		$tmpFinLetters = $engFinLetters;
		$check = 1;
		if ( $pa =~ /mtm/i ) {
			%tmpFinMatch = %mtmEngFinMatch;
		} elsif ( $pa =~ /tpa/i ) {
			%tmpFinMatch = %tpaEngFinMatch;
		} elsif ( $pa =~ /acapela/i ) {
			%tmpFinMatch = %acaEngFinMatch;
		} elsif ( $pa =~ /(cereproc|cp)$/i ) {
			%tmpFinMatch = %cereprocEngFinMatch;
		}
		# $nCheckedEng++;

	# Acronyms
	} elsif ( $pos =~ /ACR/ && $pos !~ /MIX/ ) {
		$tmpLetters = $sweAcrLetters;

		$check = 1;
		if ( $pa =~ /mtm/i ) {
			%tmpSweAcrMatch = %mtmSweAcrMatch;
			%tmpSweAcrEndMatch = %mtmSweAcrEndMatch;
		} elsif ( $pa =~ /tpa/i ) {
			%tmpSweAcrMatch = %tpaSweAcrMatch;
			%tmpSweAcrEndMatch = %tpaSweAcrEndMatch;
		} elsif ( $pa =~ /acapela/i ) {
			%tmpSweAcrMatch = %acaSweAcrMatch;
			%tmpSweAcrEndMatch = %acaSweAcrEndMatch;
		} elsif ( $pa =~ /(cereproc|cp)$/i ) {
			%tmpSweAcrMatch = %cereprocSweAcrMatch;
			%tmpSweAcrEndMatch = %cereprocSweAcrEndMatch;
		}
		$nCheckedSweAcr++;

	} else {
		# $unchecked{ $. } .= "unchecked\t$line $pron ";	$nUncheckedWords++;
	}


	if ( $check == 1 && $checkPhoneMatch == 1 ) {	# $pa =~ /tpa/ &&


		# Acronym letter-phone match
		if ( $pos =~ /ACR/ ) {
			my $acronym = $orth;
			my $tmpEndingOrth = 'void';

			# If an uppercased acronym has a lowercased 's' it is a genitive.
			# Remove the ending temporarily.
			if ( $orth =~ /^(.+[A-ZÅÄÖ])([\:\-]?($sweAcrEndLetters))$/ ) {
				$acronym = $1;
				$tmpEndingOrth = $2;
			}


			my @acronym = split//, $acronym;

			# Letter check	
			foreach my $l ( @acronym ) {

				# Must contain valid letter
				if ( $l !~ /^($tmpLetters)$/i ) {
			#		push @sanityWarnings, "acronym $l\t$tmpLetters\t$line $pron "; $nPhoneSanity++;

				# No phone match
				} elsif ( not( exists( $tmpSweAcrMatch{ $l } ))) {
					push @sanityWarnings, "Akronym: Det finns inget uttal som matchar tecknet: $l\t$orth";
					push @help, "HJÄLP\tAkronym: Uttalet matchar inte bokstaven $l\t$orth";
					$nPhoneSweAcrSanity++;

				# Phone match
				} else {
					my $tmpPron = $pron;
					$tmpPron =~ s/($valStress)//g;
					my $validPhones = $tmpSweAcrMatch{ $l };
					$validPhones =~ s/([\{\}\@])/\\$1/g;

					if ( $tmpPron !~ /(^| )($validPhones)( |$)/ ) {
						push @sanityWarnings, "Akronym: Otillåtet uttal för $l\t$orth ";
						push @help, "HJÄLP\tAkronym: Tillåtna uttal för $l är $validPhones.";
						$nPhoneSweAcrSanity++;
					}
				}
			}

			# Check ending
			if ( $tmpEndingOrth ne 'void' ) {
				my $e = $tmpEndingOrth;
				$e =~ s/[\:\-]//g;

				# Check pronunciation of the ending
				if ( exists( $tmpSweAcrEndMatch{ $e } )) {
					my $validPhones = $tmpSweAcrEndMatch{ $e };

					if ( $pron !~ /($validPhones)$/ ) {
						push @sanityWarnings, "Akronymändelse: Otillåtet uttal för $e\t$orth ";
						push @help, "HJÄLP\tAkronymändelse: Tillåtna uttal för $e är $validPhones.";
						$nPhoneSweAcrSanity++;
					}
				}
			}


		# Initial letter-phone match
		} elsif ( $orth =~ /^($tmpIniLetters)/i ) {
			my $iLetters = $1;
			$iLetters = MTM::Case::makeLowercase( $iLetters );

			# Get valid phones
			if ( exists( $tmpIniMatch{ $iLetters } )) {
				my $validIniPhones = $tmpIniMatch{ $iLetters };
				$validIniPhones =~ s/([\{\}\@])/\\$1/g;

				# Remove stress from pronunsiation
				my $tmpPron = $pron;
				$tmpPron =~ s/($valStress)//g;

				if ( $tmpPron !~ /^($validIniPhones)/ ) {
					push @sanityWarnings, "Initialt $iLetters matchar inte\t$orth $pron ";
					push @help, "HJÄLP\tVanliga uttal för initialt $iLetters: $validIniPhones";
					$nPhoneSweIniSanity++;
				}
			} else {
				push @sanityWarnings, "Initialt $iLetters matchar inte\t$orth $pron";
				$nPhoneSweIniSanity++;
			}

			# Final letter-phone match
			if ( $orth =~ /($tmpFinLetters)$/i ) {
				my $iLetters = $1;
				$iLetters = &MTM::Case::makeLowercase( $iLetters );

				# Get valid phones
				if ( exists( $tmpFinMatch{ $iLetters } )) {
					my $validFinPhones = $tmpFinMatch{ $iLetters };
					$validFinPhones =~ s/([\{\}\@])/\\$1/g;

					# Remove stress from pronunciation
					my $tmpPron = $pron;
					$tmpPron =~ s/($valStress)//g;

					if ( $tmpPron !~ /($validFinPhones)$/ ) {

						push @sanityWarnings, "Finalt $iLetters matchar inte\t$orth $pron ";
						push @help, "HJÄLP\tVanliga uttal för finalt $iLetters: $validFinPhones";
						$nPhoneSweFinSanity++;
					}
				} else {
					push @sanityWarnings, "Finalt $iLetters matchar inte\t$orth $pron";
					$nPhoneSweFinSanity++;
				}
			}
		}
	}

	return( \@sanityWarnings, \@help );
}
#***************************************************#
sub cereprocVars {
	use MTM::Validation::Vars::Cereproc;

	#@validCase = @MTM::Validation::Vars::Cereproc::validCase;
	#@validMarkup = @MTM::Validation::Vars::Cereproc::validMarkup;
	$validCase = $MTM::Validation::Vars::Cereproc::validCase;
	$validMarkup = $MTM::Validation::Vars::Cereproc::validMarkup;

	# Stress
	$valAccentI = $MTM::Validation::Vars::Cereproc::valAccentI;
	$valAccentII = $MTM::Validation::Vars::Cereproc::valAccentII;
	$valSecStress = $MTM::Validation::Vars::Cereproc::valSecStress;
	#$valUnstress = $MTM::Validation::Vars::Cereproc::valUnstress;
	#@valMainStress = @MTM::Validation::Vars::Cereproc::valMainStress;
	$valMainStress = $MTM::Validation::Vars::Cereproc::valMainStress;
	$valStress = $MTM::Validation::Vars::Cereproc::valStress;
	$valEngMainStress = $MTM::Validation::Vars::Cereproc::valEngMainStress;

	# Phones
	#@valSweVowels = @MTM::Validation::Vars::Cereproc::valSweVowels;
	@valEngVowels =   @MTM::Validation::Vars::Cereproc::valEngVowels;
	@valVowels = @MTM::Validation::Vars::Cereproc::valVowels;

	#@valSweConsos = @MTM::Validation::Vars::Cereproc::valSweConsos;
	@valEngConsos = @MTM::Validation::Vars::Cereproc::valEngConsos;
	@valConsos = @MTM::Validation::Vars::Cereproc::valConsos;
	$schwa = $MTM::Validation::Vars::Cereproc::schwa;

	#$valSweVowels = $MTM::Validation::Vars::Cereproc::valSweVowels;
	$valEngVowels = $MTM::Validation::Vars::Cereproc::valEngVowels;
	$valVowels = $MTM::Validation::Vars::Cereproc::valVowels;
	$valConsos = $MTM::Validation::Vars::Cereproc::valConsos;
	$valPhones = $MTM::Validation::Vars::Cereproc::valPhones;

	return 1;
}
#***************************************************#
sub cereprocVars_en {
	use MTM::Validation::Vars::Cereproc_en;

	#@validCase = @MTM::Validation::Vars::Cereproc_en::validCase;
	#@validMarkup = @MTM::Validation::Vars::Cereproc_en::validMarkup;
	$validCase = $MTM::Validation::Vars::Cereproc_en::validCase;
	$validMarkup = $MTM::Validation::Vars::Cereproc_en::validMarkup;

	# Stress
	$valAccentI = $MTM::Validation::Vars::Cereproc_en::valAccentI;
	$valAccentII = $MTM::Validation::Vars::Cereproc_en::valAccentII;
	$valSecStress = $vMTM::Validation::Vars::Cereproc_en::alSecStress;
	#$valUnstress = $MTM::Validation::Vars::Cereproc_en::valUnstress;
	#@valMainStress = @MTM::Validation::Vars::Cereproc_en::valMainStress;
	$valMainStress = $MTM::Validation::Vars::Cereproc_en::valMainStress;

	$valStress = $MTM::Validation::Vars::Cereproc_en::valStress;
	$valEngMainStress = $MTM::Validation::Vars::Cereproc_en::valEngMainStress;

	# Phones
	#@valSweVowels = @MTM::Validation::Vars::Cereproc_en::valSweVowels;
	@valEngVowels =   @MTM::Validation::Vars::Cereproc_en::valEngVowels;
	@valVowels = @MTM::Validation::Vars::Cereproc_en::valVowels;

	#@valSweConsos = @MTM::Validation::Vars::Cereproc_en::valSweConsos;
	@valEngConsos = @MTM::Validation::Vars::Cereproc_en::valEngConsos;
	@valConsos = @MTM::Validation::Vars::Cereproc_en::valConsos;
	$schwa = $MTM::Validation::Vars::Cereproc_en::schwa;

	#$valSweVowels = $MTM::Validation::Vars::Cereproc_en::valSweVowels;
	$valEngVowels = $MTM::Validation::Vars::Cereproc_en::valEngVowels;
	$valVowels = $MTM::Validation::Vars::Cereproc_en::valVowels;
	$valConsos = $MTM::Validation::Vars::Cereproc_en::valConsos;
	$valPhones = $MTM::Validation::Vars::Cereproc_en::valPhones;
	$tmpValVowels = $MTM::Validation::Vars::Cereproc_en::tmpValVowels;
	$tmpValPhones = $MTM::Validation::Vars::Cereproc_en::tmpValPhones;

	return 1;
}
#***************************************************#
sub acapelaVars {
	use MTM::Validation::Vars::Acapela;

	#@validCase = @MTM::Validation::Vars::Acapela::validCase;
	#@validMarkup = @MTM::Validation::Vars::Acapela::validMarkup;
	$validCase = $MTM::Validation::Vars::Acapela::validCase;
	$validMarkup = $MTM::Validation::Vars::Acapela::validMarkup;

	# Stress
	$valAccentI = $MTM::Validation::Vars::Acapela::valAccentI;
	$valAccentII = $MTM::Validation::Vars::Acapela::valAccentII;
	$valSecStress = $MTM::Validation::Vars::Acapela::valSecStress;
	#$valUnstress = $MTM::Validation::Vars::Acapela::valUnstress;
	#@valMainStress = @MTM::Validation::Vars::Acapela::valMainStress;
	$valMainStress = $MTM::Validation::Vars::Acapela::valMainStress;
	$valStress = $MTM::Validation::Vars::Acapela::valStress;
	$valEngMainStress = $MTM::Validation::Vars::Acapela::valEngMainStress;

	# Phones
	#@valSweVowels = @MTM::Validation::Vars::Acapela::valSweVowels;
	@valEngVowels =   @MTM::Validation::Vars::Acapela::valEngVowels;
	@valVowels = @MTM::Validation::Vars::Acapela::valVowels;

	#@valSweConsos = @MTM::Validation::Vars::Acapela::valSweConsos;
	@valEngConsos = @MTM::Validation::Vars::Acapela::valEngConsos;
	@valConsos = @MTM::Validation::Vars::Acapela::valConsos;
	$schwa = $MTM::Validation::Vars::Acapela::schwa;

	#$valSweVowels = $MTM::Validation::Vars::Acapela::valSweVowels;
	$valEngVowels = $MTM::Validation::Vars::Acapela::valEngVowels;
	$valVowels = $MTM::Validation::Vars::Acapela::valVowels;
	$valConsos = $MTM::Validation::Vars::Acapela::valConsos;
	$valPhones = $MTM::Validation::Vars::Acapela::valPhones;

	return 1;
}
#***************************************************#
sub tpaVars {
	use MTM::Validation::Vars::TPA;

	#@validCase = @MTM::Validation::Vars::TPA::validCase;
	#@validMarkup = @MTM::Validation::Vars::TPA::validMarkup;
	$validCase = $MTM::Validation::Vars::TPA::validCase;
	$validMarkup = $MTM::Validation::Vars::TPA::validMarkup;

	# Stress
	$valAccentI = $MTM::Validation::Vars::TPA::valAccentI;
	$valAccentII = $MTM::Validation::Vars::TPA::valAccentII;
	$valSecStress = $MTM::Validation::Vars::TPA::valSecStress;
	#$valUnstress = $MTM::Validation::Vars::TPA::valUnstress;
	#@valMainStress = @MTM::Validation::Vars::TPA::valMainStress;
	$valMainStress = $MTM::Validation::Vars::TPA::valMainStress;
	$valStress = $MTM::Validation::Vars::TPA::valStress;
	$valEngMainStress = $MTM::Validation::Vars::TPA::valEngMainStress;

	# Phones
	#@valSweVowels = @MTM::Validation::Vars::TPA::valSweVowels;
	@valEngVowels =   @MTM::Validation::Vars::TPA::valEngVowels;
	@valVowels = @MTM::Validation::Vars::TPA::valVowels;

	#@valSweConsos = @MTM::Validation::Vars::TPA::valSweConsos;
	@valEngConsos = @MTM::Validation::Vars::TPA::valEngConsos;
	@valConsos = @MTM::Validation::Vars::TPA::valConsos;
	$schwa = $MTM::Validation::Vars::TPA::schwa;

	#$valSweVowels = $MTM::Validation::Vars::TPA::valSweVowels;
	$valEngVowels = $MTM::Validation::Vars::TPA::valEngVowels;
	$valVowels = $MTM::Validation::Vars::TPA::valVowels;
	$valConsos = $MTM::Validation::Vars::TPA::valConsos;
	$valPhones = $MTM::Validation::Vars::TPA::valPhones;

	return 1;
}
#***************************************************#
sub mtmVars {
	use MTM::Validation::Vars::MTM;

	#@validCase = @MTM::Validation::Vars::MTM::validCase;
	#@validMarkup = @MTM::Validation::Vars::MTM::validMarkup;
	$validCase = $MTM::Validation::Vars::MTM::validCase;
	$validMarkup = $MTM::Validation::Vars::MTM::validMarkup;

	# Stress
	$valAccentI = $MTM::Validation::Vars::MTM::valAccentI;
	$valAccentII = $MTM::Validation::Vars::MTM::valAccentII;
	$valSecStress = $MTM::Validation::Vars::MTM::valSecStress;
	#$valUnstress = $MTM::Validation::Vars::MTM::valUnstress;
	#@valMainStress = @MTM::Validation::Vars::MTM::valMainStress;
	$valMainStress = $MTM::Validation::Vars::MTM::valMainStress;
	$valStress = $MTM::Validation::Vars::MTM::valStress;
	$valEngMainStress = $MTM::Validation::Vars::MTM::valEngMainStress;

	# Phones
	#@valSweVowels = @MTM::Validation::Vars::MTM::valSweVowels;
	@valEngVowels =   @MTM::Validation::Vars::MTM::valEngVowels;
	@valVowels = @MTM::Validation::Vars::MTM::valVowels;

	#@valSweConsos = @MTM::Validation::Vars::MTM::valSweConsos;
	@valEngConsos = @MTM::Validation::Vars::MTM::valEngConsos;
	@valConsos = @MTM::Validation::Vars::MTM::valConsos;
	$schwa = $MTM::Validation::Vars::MTM::schwa;

	#$valSweVowels = $MTM::Validation::Vars::MTM::valSweVowels;
	$valEngVowels = $MTM::Validation::Vars::MTM::valEngVowels;
	$valVowels = $MTM::Validation::Vars::MTM::valVowels;
	$valConsos = $MTM::Validation::Vars::MTM::valConsos;
	$valPhones = $MTM::Validation::Vars::MTM::valPhones;

	return 1;
}
#***************************************************#
sub ipaVars {
	use MTM::Validation::Vars::IPA;

	#@validCase = @MTM::Validation::Vars::IPA::validCase;
	#@validMarkup = @MTM::Validation::Vars::IPA::validMarkup;
	$validCase = $MTM::Validation::Vars::IPA::validCase;
	$validMarkup = $MTM::Validation::Vars::IPA::validMarkup;

	# Stress
	$valAccentI = $MTM::Validation::Vars::IPA::valAccentI;
	$valAccentII = $MTM::Validation::Vars::IPA::valAccentII;
	$valSecStress = $MTM::Validation::Vars::IPA::valSecStress;
	#$valUnstress = $MTM::Validation::Vars::IPA::valUnstress;
	#@valMainStress = @MTM::Validation::Vars::IPA::valMainStress;
	$valMainStress = $MTM::Validation::Vars::IPA::valMainStress;
	$valStress = $MTM::Validation::Vars::IPA::valStress;
	$valEngMainStress = $MTM::Validation::Vars::IPA::valEngMainStress;

	# Phones
	#@valSweVowels = @MTM::Validation::Vars::IPA::valSweVowels;
	@valEngVowels =   @MTM::Validation::Vars::IPA::valEngVowels;
	@valVowels = @MTM::Validation::Vars::IPA::valVowels;

	#@valSweConsos = @MTM::Validation::Vars::IPA::valSweConsos;
	@valEngConsos = @MTM::Validation::Vars::IPA::valEngConsos;
	@valConsos = @MTM::Validation::Vars::IPA::valConsos;
	$schwa = $MTM::Validation::Vars::IPA::schwa;

	#$valSweVowels = $MTM::Validation::Vars::IPA::valSweVowels;
	$valEngVowels = $MTM::Validation::Vars::IPA::valEngVowels;
	$valVowels = $MTM::Validation::Vars::IPA::valVowels;
	$valConsos = $MTM::Validation::Vars::IPA::valConsos;
	$valPhones = $MTM::Validation::Vars::IPA::valPhones;

	return 1;
}
#***************************************************#
1;
