package MTM::Pronunciation::Conversion;

#**************************************************************#
# Convert
#
# Language	sv_se
#
# Rules for converting phones.
# 
# Return: pronunciation
#
# To add a conversion:
# 1. Do the mapping in conversionTable.txt
# 2. Add
#
# tests exist	210817
#
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
my %conversionHash = ();
my %tpa2sampa = ();
my %sampa2acapela = ();
my %tpa2acapela = ();
my %tpa2cp_swe = ();
my %tpa2cp_eng = ();
my %cp2tpa = ();
my %cp2mtm = ();
my %tpa2tacotron_1 = ();
my %tpa2ipa = ();
my %tpa2ms_ipa = ();
my %nst2tpa = ();

my %tpa2mtm = ();
my %sampa2mtm = ();
my %ipa2mtm = ();
my %ms_ipa2mtm = ();
my %nst2mtm = ();
my %mtm2tpa = ();
my %mtm2sampa = ();
my %mtm2acapela = ();
my %mtm2cp_swe = ();
my %mtm2cp_eng = ();
my %mtm2ipa = ();
my %mtm2ms_ipa = ();
my %mtm2nst = ();

my $current_vowels;
#********************************************************************#
sub convert {

	my( $pron, $pos, $conversion, $orth, $dec ) = @_;
	my $newPron;

	# print STDERR "\nPRON\t$pron\nPOS\t$pos\nCON\t$conversion\nORTH\t$orth\nDEC\t$dec\n\n";

	##### This should be moved out somewhere.	CT 2021-05-07
	##### Sub is in this file.
	#my $LEGACYPATH = "data/legacy/"; 
	&readConversionTable( "data/pron/conversion_table.txt" );
	#print STDERR "OO  $conversion\n";
	# tpa2mtm	240503
	if( $conversion =~ /tpa2mtm/ ) {
		%conversionHash = %tpa2mtm;
		my $current_vowels =  $MTM::Vars::tpa_vowel;
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	} elsif( $conversion =~ /mtm2acapela/ ) {
		%conversionHash = %mtm2acapela;
		my $current_vowels =  $MTM::Vars::mtm_vowel;
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );
		$newPron = &acapelaAspiration( $newPron );


	} elsif( $conversion =~ /mtm2cp(_swe)?$/ ) {
		%conversionHash = %mtm2cp_swe;
		my $current_vowels =  $MTM::Vars::mtm_vowel;
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# tpa2sampa
	} elsif ( $conversion =~ /tpa2sampa/ ) {
		%conversionHash = %tpa2sampa;
		my $current_vowels =  $MTM::Vars::tpa_vowel;
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# sampa2acapela
	} elsif ( $conversion =~ /sampa2acapela/ ) {
		%conversionHash = %sampa2acapela;
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );
		$newPron = &acapelaAspiration( $newPron );

	# tpa2acapela
	} elsif ( $conversion =~ /tpa2acapela/ ) {
		%conversionHash = %tpa2acapela;
		$pron =~ s/(k [\"\'\`])öw /$1o2: /;

		my $current_vowels =  $MTM::Vars::tpa_vowel;
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );
		$newPron = &acapelaAspiration( $newPron );

		# Use /g/ for adjectives ending in <iga?>
		if ( $pos =~ /^JJ/ && $orth =~ /ig[ae]?s?$/ ) {
			$newPron =~ s/(I\d?) ([a\@])$/$1 g $2/;
			$newPron =~ s/(I\d?) ([a\@]) s$/$1 g $2 s/;
			$newPron =~ s/(I\d?)$/$1 g/;
			$newPron =~ s/(I\d?) s$/$1 g s/;
		}

		if ( $orth =~ /[KC]arl[sz]+on/i ) {
			$newPron = &acapelaKarlsson( $newPron );
		}

	# tpa2cp
	} elsif ( $conversion =~ /tpa2cp(_swe)?$/ ) {
		%conversionHash = %tpa2cp_swe;

		my $current_vowels =  $MTM::Vars::tpa_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion  );

		# Use /g/ for adjectives ending in <iga?>
		if ( $pos =~ /^(JJ|AB)/ && $orth =~ /ig[ae]?[s]?$/ ) {
			$newPron =~ s/(i0) (a0|eh0)$/$1 g $2/;
			$newPron =~ s/(i0) (a0|eh0) s$/$1 g $2 s/;
			$newPron =~ s/(i0)$/$1 g/;
			$newPron =~ s/(i0) s$/$1 g s/;

			$newPron =~ s/ i0 eh0 n$/ i0 g eh0 n/;
		}

		# tv-
		$newPron =~ s/^t ee3 \~ v ee0 - /t ee3 \$ v eh0 - /;


	# tpa2cp_en
	} elsif ( $conversion =~ /tpa2cp_en/ ) {
		%conversionHash = %tpa2cp_eng;

		my $current_vowels =  $MTM::Vars::tpa_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# tpa2tacotron_1
	} elsif ( $conversion =~ /tpa2tacotron_1/ ) {
		%conversionHash = %tpa2tacotron_1;

		my $current_vowels =  $MTM::Vars::tpa_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# cp2tpa
	} elsif ( $conversion =~ /cp2tpa/ ) {
		%conversionHash = %cp2tpa;

		# Correct vowel set for conversions
		my $current_vowels =  $MTM::Vars::cp_swe_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# cp2mtm
	} elsif ( $conversion =~ /cp2mtm/ ) {
		%conversionHash = %cp2mtm;

		# Correct vowel set for conversions
		my $current_vowels =  $MTM::Vars::cp_swe_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# tpa2ipa
	} elsif ( $conversion =~ /tpa2ipa/ ) {
		%conversionHash = %tpa2ipa;

		# Correct vowel set for conversions
		my $current_vowels =  $MTM::Vars::ipa_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# tpa2ms_ipa
	} elsif ( $conversion =~ /tpa2ms_ipa/ ) {
		%conversionHash = %tpa2ms_ipa;

		# Correct vowel set for conversions
		my $current_vowels =  $MTM::Vars::ms_ipa_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

		$newPron =~ s/\|/./g; # NL TODO right place for this?
		$newPron =~ s/ +//g; # NL TODO right place for this?


	# tacotron_1
	} elsif ( $conversion =~ /tacotron_1/ ) {
		%conversionHash = %tpa2tacotron_1;

		# Correct vowel set for conversions
		my $current_vowels =  $MTM::Vars::tacotron_1_vowel;

		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

	# nst2tpa
	} elsif ( $conversion =~ /nst2tpa/ ) {

		%conversionHash = %nst2tpa;

		# Correct vowel set for conversions
		my $current_vowels =  $MTM::Vars::nst_vowel;
		$current_vowels = quotemeta( $current_vowels );
		$current_vowels =~ s/\\\|/\|/g;

		# Insert space between phones
		my $nst_phones = join'|', keys %nst2tpa;

		$pron =~ s/($nst_phones|\$)/ $1 /g;
		$pron = &MTM::Legacy::cleanBlanks( $pron );
		$pron =~ s/ ([\'\`\:])/$1/g;
		$pron = &MTM::Pronunciation::Stress::move_stress_to_vowel( $pron, $current_vowels );
		$newPron = &do_convert( $pron, $pos, $current_vowels, $orth, $dec, $conversion );

		# Rewrite unstressed /e/ to schwa
		$newPron =~ s/ e/ ë/g;
	}

	# Case sensitivity and part-of-speech
	my $newPos = '-';
	if ( $pos =~ /ABBR/ ) {
		$newPos = 'ABBR';
	} elsif ( $pos =~ /ACR/ ) {
		$newPos = 'ACR';
	} elsif ( $pos =~ /PM/ ) {
		$newPos = 'PM';
	}

	return( $newPron );
}
#********************************************************************#
# tpa2sampa
#
# Todo:	remove word limits
#	fix stress att diphthongs
#	fix a U
#********************************************************************#
sub do_convert {

	my ( $words, $pos, $current_vowels, $orth, $dec, $conversion ) = @_;


	# print STDERR "do_convert\t$words\t$conversion\n";
	# print STDERR "do_convert\t$words, $pos, $current_vowels, $orth, $dec, $conversion\n";

	my @words = split/ *\| */, $words;

	my @final_pron = ();
	foreach my $pron ( @words ) {

		# Add secondary stress if abscent		240522
		if( $conversion =~ /cp2(mtm|tpa)/ ) {
			if( $pron =~ /3/ && $pron !~ /2/ ) {
#				print STDERR "$pron	III $current_vowels\n";
				my $tmp = $pron;
#				$pron =~ s/(3[^($current_vowels)]+($current_vowels))0/$1 __2/;
				$pron =~ s/(3[^aoueiy]+($current_vowels))0/$1 __2/;
				$pron =~ s/ __2/2/;
#				print STDERR "$pron	III $current_vowels\n";
				}
		}
	    
		my @pron = split/ /, $pron;
		my @newPron = ();

		# print STDERR "do_convert\t$pron\t$conversion\n";
		my $i = 0;
		foreach my $p ( @pron ) {

			if ( $orth =~ /dl$/ ) {
				$pron =~ s/d \@ l$/d ë l/g;
			}
			# Save stress
			my $stress = 'void';

			if ( $conversion =~ /tpa2mtm/ ) {		# 2420503
				if ( $p =~ s/^\"// ) {
					$stress = '"';
				} elsif ( $p =~ s/^\'// ) {
					$stress = "\'";
				} elsif ( $p =~ s/^\`// ) {
					$stress = ',';
				}

				$p =~ s/\$/\./g;
				$p =~ s/¤/\|/g;

			} elsif ( $conversion =~ /mtm2tpa/ ) {		# 2420503
				if ( $p =~ s/^\"// ) {
					$stress = '"';
				} elsif ( $p =~ s/^\'// ) {
					$stress = "\'";
				} elsif ( $p =~ s/^,// ) {
					$stress = '`';
				}

			} elsif ( $conversion =~ /mtm2acapela/ ) {	# 2420503
				if ( $p =~ s/^\"// ) {
					$stress = '3';
				} elsif ( $p =~ s/^\'// ) {
					$stress = '4';
				} elsif ( $p =~ s/^,// ) {
					$stress = '1';
				}

			} elsif ( $conversion =~ /tpa2sampa/ ) {
				if ( $p =~ s/^\'// ) {
					$stress = '"';
				} elsif ( $p =~ s/^\"// ) {
					$stress = '""';
				} elsif ( $p =~ s/^\`// ) {
					$stress = '%';
				}
				$p =~ s/¤/\|/g;

			} elsif ( $conversion =~ /sampa2acapela/ ) {
				if ( $p =~ s/^\"\"// ) {
					$stress = '3';
				} elsif ( $p =~ s/^\"// ) {
					$stress = '4';
				} elsif ( $p =~ s/^\%// ) {
					$stress = '1';
				}

			} elsif ( $conversion =~ /tpa2acapela/ ) {

				if ( $p =~ s/^\"// ) {
					$stress = '3';
				} elsif ( $p =~ s/^\'// ) {
					$stress = '4';

				} elsif ( $p =~ s/^\`//  ) {
					# No secondary stress in simplex words.
					# Keep secondary stress in acronyms.
					if ( $pron =~ / - / || $pos =~ /ACR/ ) {
						$stress = '1';
					}
				}

				$p =~ s/ ¤ / /g;
				$p =~ s/ [\~\$\-] / /g;

			} elsif ( $conversion =~ /tpa2cp(_swe)?$/ ) {

				if ( $p =~ s/^\"// ) {
					$stress = '3';

				} elsif ( $p =~ s/^\'// ) {
					$stress = '4';

				} elsif ( $p =~ s/^[\`,]//  ) {

					# No secondary stress in simplex words.
					# Keep secondary stress in acronyms and in derivation with -sam, -samt, -samma etc.
					if ( $dec =~ /\+/ || $pron =~ / - / || $pos =~ /ACR/ || $orth =~ /(sam|samt|samma)s?$/ ) {
						$stress = '2';
					} else {
						$stress = '0';
					}

				} elsif ( $p =~ /^($current_vowels)$/ ) {
					$stress = '0';
				}

				### When do_convert is called directly, e.g. from generateCereProcNewsLexicon.pl
				%conversionHash = %tpa2cp_swe;

			} elsif ( $conversion =~ /mtm2cp(_swe)?$/ ) {

				if ( $p =~ s/^\"// ) {
					$stress = '3';

				} elsif ( $p =~ s/^\'// ) {
					$stress = '4';

				} elsif ( $p =~ s/^[\`,]//  ) {

					# No secondary stress in simplex words.
					# Keep secondary stress in acronyms and in derivation with -sam, -samt, -samma etc.
					if ( $dec =~ /\+/ || $pron =~ / - / || $pos =~ /ACR/ || $orth =~ /(sam|samt|samma)s?$/ ) {
						$stress = '2';
					} else {
						$stress = '0';
					}

				} elsif ( $p =~ /^($current_vowels)$/ ) {
					$stress = '0';
				}

				### When do_convert is called directly, e.g. from generateCereProcNewsLexicon.pl
				%conversionHash = %mtm2cp_swe;

			} elsif ( $conversion =~ /tpa2cp_en/ ) {

				if ( $p =~ s/^[\"\']// ) {
					$stress = '1';
				} elsif ( $p =~ s/^\`//  ) {
					$stress = '2';
				} elsif ( $p =~ /^($current_vowels)$/ ) {
					$stress = '0';
				}

			} elsif ( $conversion =~ /cp2tpa/ ) {
				if( $p =~ s/0// ) {
					$stress = 'void';
				} elsif( $p =~ s/4// ) {
					$stress = "\'";
				} elsif( $p =~ s/3// ) {
					$stress = '"';
				} elsif( $p =~ s/2// ) {
					$stress = '`';
				}

			} elsif ( $conversion =~ /cp2mtm/ ) {
				if( $p =~ s/0// ) {
					$stress = 'void';
				} elsif( $p =~ s/4// ) {
					$stress = "\'";
				} elsif( $p =~ s/3// ) {
					$stress = '"';
				} elsif( $p =~ s/2// ) {
					$stress = ',';
				}

				$p =~ s/\$/\./g;

			} elsif ( $conversion =~ /tpa2tacotron_1/ ) {
				if ( $p =~ s/^\'// ) {
					$stress = "\' ";
				} elsif ( $p =~ s/^\"// ) {
					$stress = '" ';
				} elsif ( $p =~ s/^\`// ) {
					$stress = '` ';
				}

			} elsif ( $conversion =~ /tpa2ipa/ ) {
				if ( $p =~ s/^\'// ) {
					$stress = "\'";
				} elsif ( $p =~ s/^\"// ) {
					$stress = '"';
				} elsif ( $p =~ s/^\`// ) {
					$stress = '`';
				}

			} elsif ( $conversion =~ /tpa2ms_ipa/ ) {
				if ( $p =~ s/^\'// ) {
					$stress = "ˈ́";
				} elsif ( $p =~ s/^\"// ) {
					$stress = "ˈ̀";
				} elsif ( $p =~ s/^\`// ) {
					$stress = "ˌ";
				}

			} elsif ( $conversion =~ /nst2tpa/ ) {
				if ( $p =~ s/^\"\"// ) {
					$stress = '"';
				} elsif ( $p =~ s/^\"// ) {
					$stress = "\'";
				} elsif ( $p =~ s/^\%// ) {
					$stress = '`';
				}
			}
			#***************************************#
			# One-to-one phone conversions
			if ( $p =~ /^[\$\-\|\~\.]$/ ) {
				$newPron[ $i ] = $p;
				#print STDERR "1 $p\t $p\n";

			} elsif ( exists( $conversionHash{ $p } )) {
				$newPron[ $i ] = $conversionHash{ $p };

			} else {
				#while(my( $k,$v)=each(%conversionHash)) { print STDERR "O  $k	$v\n"; }
				$newPron[ $i ] = 'xxx';
				print STDERR "Couldn't map symbol $p in transcription. /$pron/\t$orth\t$conversion\n";
			}

			#***************************************#
			if ( $stress ne 'void' ) {
				if ( $conversion =~ /tpa2mtm/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /mtm2acapela/ ) {
					$newPron[ $i ] .= $stress;

				} elsif ( $conversion =~ /sampa2acapela/ ) {
					$newPron[ $i ] .= $stress;

				} elsif ( $conversion =~ /tpa2acapela/ ) {

					# Add stress to first token to avoid stressing the last vowel in a diphthong
					if (
						$newPron[ $i ] =~ / /
					) {
						$newPron[ $i ] =~ s/^([^\s]+) (.+)$/$1$stress $2/;
					} else {
						$newPron[ $i ] .= $stress;
					}

				} elsif ( $conversion =~ /(tpa|mtm)2cp/ ) {
					$newPron[ $i ] .= $stress;

				} elsif ( $conversion =~ /(tpa|mtm)2sampa/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /cp2tpa/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /cp2mtm/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /(tpa|mtm)2tacotron_1/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /(tpa|mtm)2ipa/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /(tpa|mtm)2ms_ipa/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				} elsif ( $conversion =~ /nst2tpa/ ) {
					$newPron[ $i ] = $stress . $newPron[ $i ];

				}
			}
			$i++;
		}

		if ( $conversion =~ /tpa2ms_ipa/ ) {
			# NL 2023-12-19 20:22:35 It turns out that stress placement before or after vowel doesn't matter in MS-IPA
			#@newPron = swapMSIPAStress(@newPron);

			my @invalidSyms = &invalidMSIPASymbols(@newPron);

			# NL TODO How and where to report errors?
			if (@invalidSyms > 0  ) {
				# TODO LATER /CT 240403
				#print STDERR "Conversion::do_convert: INVALID SYMBOLS IN MS-IPA TRANSCRIPTION:\t" . join(',', @invalidSyms) . "\t(in trans\t" . join(' ', @newPron) . ")\n";
			}
		}

		my $newPron = join' ', @newPron;

		# CereProc: remove delimimters and add underscore between phones (only for Cereproc internal user lexicon).
		if ( $conversion =~ /^(tpa|mtm)2cp/ ) {
			#$newPron =~ s/ [\~\$] / /g;	# \-
			#$newPron =~ s/ /_/g;
			$newPron =~ s/\@-\@/\@ \@/g;

			$newPron =~ s/_ng/ ng/g;

			$newPron =~ s/a2 n l e0 g n/a0 n l e2 g n/;
			$newPron =~ s/a2 n s l aa0 g/a0 n s l aa0 g/;
			$newPron =~ s/a2 n oo0 rd rn i0 ng/a0 n oo2 rd rn i0 ng/;
			$newPron =~ s/a2 n d ee0 l/a0 n d ee2 l/;
			$newPron =~ s/a2 n s oox0 k/a0 n s oox2 k/;
			$newPron =~ s/a2 n s t e0 l d/a0 n s t e2 l d/;
			$newPron =~ s/a2 n g r e0 p/a0 n g r e2 p/;

			$newPron =~ s/o0 b j e2 k t/u0 b j e2 k t/;
			$newPron =~ s/a2 r v uu0 d e/a0 r v uu2 d e/;
			$newPron =~ s/b r a2 rn rs/b r a2 n rs/;
			$newPron =~ s/e0 k s e0 m p l aa2 r/e0 k s eh0 m p l aa2 r/;
			$newPron =~ s/a0 ng t ux0 s i0 a2 s t/a0 n t ux0 s i0 a2 s t/;
			$newPron =~ s/r ee0 h a0 b i0 l i0 t ee3 r i0 ng/r e0 h a0 b i0 l i0 t ee3 r i0 ng/;
			$newPron =~ s/k uu0 u0 rd i0 n aa2 t u0 r/k uu0 rd i0 n aa2 t u0 r/;
			$newPron =~ s/f uu3 rt rs e0 t n i0 ng/f u3 rt rs e0 t n i0 ng/;
			$newPron =~ s/t ee3 v ee0 /t ee3 v eh0 /;
			$newPron =~ s/t ee2 v ee0$/t ee2 v eh0/;
			$newPron =~ s/i0 n x e0 n j ooe2 r/i0 n x e0 n j ooe2 r/;
			$newPron =~ s/a2 n v e0 n d a0/a0 n v e2 n d a0/;


			# Move stress to vowel
			$newPron =~ s/_j/ j/g;
			$newPron =~ s/([eao]) j(\d)/$1$2 j/g;


			#$newPron =~ s/([eao])(\d) y/$1i$2/g;
			#$newPron =~ s/([eao]) y/$1i/g;

			#$newPron =~ s/ - / /g;

			$newPron =~ s/uh(\d) y/ai$1/g;
			$newPron =~ s/e(\d) y/ei$1/g;
			$newPron =~ s/o(\d) y/oi$1/g;

			$newPron =~ s/ [\~\$\-\.] / /g;

		# CereProc -> TPA
		} elsif ( $conversion =~ /cp2tpa/ ) {
			# /o3, e3, u3/ in open syllable before stressed syllable	240514

			# syllabify
			#print STDERR "1. $newPron\n";
			if( $newPron =~ /[aouåeiyäöë].+[aouåeiyäöë]/ && $newPron !~ /[\$\~-]/ ) {
				$newPron = &MTM::Pronunciation::Syllabify::syllabify( $newPron );
			}
			#print STDERR "2. $newPron\n";

			$newPron =~ s/((?:^| )[oeu]) ([\$\~][^aouåeiyäöë]*[\'\"\`])/$1 3 $2/g;
			$newPron =~ s/ +3/3/g;
			#print STDERR "3. $newPron\n";

		# CereProc -> TPA
		} elsif ( $conversion =~ /cp2mtm/ ) {
			# /o3, e3, u3/ in open syllable before stressed syllable	240514
			$newPron =~ s/((?:^| )[oe]) ([\.\|\~][^aouåeiyäöë]*[\'\"\`])/$1 __h $2/g;
			$newPron =~ s/((?:^| )[u]) ([\.\|\~][^aouåeiyäöë]*[\'\"\`])/$1u $2/g;
			$newPron =~ s/ __h/h/g;
	# nono		$newPron =~ s/ i ((?:[\$\.] )?[aouåeiyäöë])/ ih $1/g;

	#		print STDERR "3. $newPron\n";

		} elsif ( $conversion =~ /(tpa2tacotron_1|tpa2ipa)/ ) {
			$newPron =~ s/ [\~\$\-] / /g;
			$newPron =~ s/_/ /g;

		} elsif ( $conversion =~ /tpa2ms_ipa/ ) {
			$newPron =~ s/ [\~\$\-\|] / \. /g;
			$newPron =~ s/_/ /g;
			$newPron =~ s/ +//g;

		}

		# 230503
		# my ( $words, $pos, $current_vowels, $orth, $dec, $conversion ) = @_;
		if ( $conversion =~ /tpa2tacotron_1/ ) {
			if( $orth eq ' ' && $pron eq '-' ) {
				$newPron = ' & ';
			} elsif( $orth =~ /^[\,\;\-]+$/ && $pron eq '-' ) {
				$newPron = ' / ';
			} elsif( $orth =~ /^[\.\!]+$/ && $pron eq '-' ) {
				$newPron = ' .';
			}
		}


		push @final_pron, $newPron;
	}

	my $final_pron = join' | ', @final_pron;

	# Keep the word delimiter
	#$final_pron =~ s/ \| / /g;
	$final_pron =~ s/ +/ /g;

	if( $final_pron =~ /xxx/ ) {
		$final_pron = '';
	}



	return $final_pron;
}
#********************************************************************#
sub readConversionTable {
	my $conversionFile = shift;

	## no critic (InputOutput::RequireBriefOpen)
	open my $fh, '<', "$conversionFile" or die "Cannot open $conversionFile: $!";
	## use critic
	while ( <$fh> ) {
		next if /\#/;
		next if /^\s*$/;
		chomp;
		s/\r//g;

		my @line = split/\t/;
		my $tpa = $line[0];
		my $sampa = $line[1];
		my $acapela = $line[2];
		my $cp_eng = $line[3];
		my $cp_swe = $line[4];
		my $tacotron_1 = $line[5];
		my $ipa = $line[6];
		my $ms_ipa = $line[7];
		my $nst = $line[8];
		my $mtm = $line[9];

		$tpa2sampa{ $tpa } = $sampa;
		$tpa2acapela{ $tpa } = $acapela;
		$tpa2cp_swe{ $tpa } = $cp_swe;
		$tpa2cp_eng{ $tpa } = $cp_eng;
		$sampa2acapela{ $sampa } = $acapela;
		$tpa2ipa{ $tpa } = $ipa;
		$tpa2ms_ipa{ $tpa } = $ms_ipa;
		$tpa2tacotron_1{ $tpa } = $tacotron_1;
		$nst2tpa{ $nst } = $tpa;

		# MTM			240503
		$tpa2mtm{ $tpa } = $mtm;
		$sampa2mtm{ $sampa } = $mtm;
		#$cp_swe2mtm{ $cp_swe } = $mtm;
		#$cp_eng2mtm{ $cp_eng } = $mtm;
		$ipa2mtm{ $ipa } = $mtm;
		$ms_ipa2mtm{ $ms_ipa } = $mtm;
		$nst2mtm{ $nst } = $mtm;

		$mtm2tpa{ $mtm } = $tpa;
		$mtm2sampa{ $mtm } = $sampa;
		$mtm2acapela{ $mtm } = $acapela;
		$mtm2cp_swe{ $mtm } = $cp_swe;

		$mtm2cp_eng{ $mtm } = $cp_eng;
		$mtm2ipa{ $mtm } = $ipa;
		$mtm2ms_ipa{ $mtm } = $ms_ipa;
		$mtm2nst{ $mtm } = $nst;

		# Use first mapping suggestion (avoiding /u/ -> /u4/).
		next if( exists( $cp2tpa{ $cp_swe } ));

		$cp2tpa{ $cp_swe } = $tpa;
		$cp2mtm{ $cp_swe } = $mtm;
	}

	# Add cp /oex/ to hash	CT 171025
	$cp2tpa{ 'oex' } = 'ö3';

	#while(my($k,$v)=each(%tpa2mtm)) { print "$k\t$v\n";  exit; }

	close $fh;
	return 1;
}
#********************************************************************#
sub acapelaAspiration {

	my $pron = shift;

	my $aVP = "p|t|k|rt";		# acapela voiceless plosives
	my $aFC = "j|l|n|r|v";		# acapela following consonant
	my $aVowel = "a|A:|e|e:|\@|I|i:|U|u:|u|\}:|Y|y:|O|o:|E|E:|\{|\{:|2|2:|9|9:|aa|a\~|e\~|o\~|9\~";


	# Word initially followed by a vowel or (j|l|n|r|v) and vowel 
	$pron =~ s/^($aVP) ((?:$aFC)? ?(?:$aVowel))/$1 _h $2/;


	# Morpheme initially followed by a vowel or (j|l|n|r|v) and vowel)
	$pron =~ s/(\-) ($aVP) ((?:$aFC)? ?(?:$aVowel))/$1 $2 _h $3/g;

	# Within a morpheme in a compound followed by a primary stressed vowel or (j|l|n|r|v) and vowel
	$pron =~ s/($aVP) ((?:$aFC)? ?(?:$aVowel)[34])/$1 _h $2/g;

	# Remove aspiration in same syllable if preceded by /s/
	$pron =~ s/s ($aVP) _h/s $1/g;

	# Remove aspiration if followed by /@/
	$pron =~ s/($aVP) _h \@/$1 \@/g;

	# Remove blanks
	$pron =~ s/ _h/_h/g;


	$pron =~ s/ [\$\-\~\.] / /g;
	return $pron;
}
#********************************************************************#
# Special Acapela transcription for "Karlsson": /rl/ --> /l/	CT 140113
sub acapelaKarlsson {

	my $pron = shift;

	$pron =~ s/k_h A:4 rl s O n/k_h A:4 l s O n/;

	return $pron;
}
#********************************************************************#
sub remove_boundary_phrase {
	my $wd = shift;

	$wd =~ s/ \/ / /g;
	$wd =~ s/^\/$//g;

	return $wd;
}
#***************************************************************************************#
sub remove_boundary_word {
	my $wd = shift;

	$wd =~ s/ <WD> / /g;
	$wd =~ s/ \& / /g;
	$wd =~ s/^\&$//g;

	return $wd;
}
#***************************************************************************************#
sub remove_boundary_compound {
	my $wd = shift;

	$wd =~ s/ - / /g;
	$wd =~ s/^-$/ /g;

	return $wd;
}
#***************************************************************************************#
sub remove_boundary_morph {
	my $wd = shift;

	$wd =~ s/ \~ / /g;
	$wd =~ s/^\~$//g;

	return $wd;
}
#***************************************************************************************#
sub convert_boundary_morph {
	my $wd = shift;

	$wd =~ s/ \~ / \$ /g;
	$wd =~ s/^\~$/\$/g;

	return $wd;
}
#***************************************************************************************#
sub remove_boundary_syllable {
	my $wd = shift;

	$wd =~ s/ [\$] / /g;
	$wd =~ s/^[\$]$//g;

	return $wd;
}
#***************************************************************************************#
sub remove_accent {
	my $wd = shift;

	$wd =~ s/\"/\'/g;
	$wd =~ s/\`//g;

	return $wd;
}
#***************************************************************************************#
sub merge_accents {
	my $wd = shift;

	$wd =~ s/\"/\'/g;

	return $wd;
}
#***************************************************************************************#
sub remove_stress {
	my $wd = shift;
	$wd =~ s/[\"\'\`]//g;
	return $wd;
}
#***************************************************************************************#
sub separate_stress {
	my $wd = shift;
	$wd =~ s/([\"\'\`])/$1 /g;

	return $wd;
}
#***************************************************************************************#
sub xenophones_ids {
	my $wd = shift;

	# Vowels		# n total	n training
	$wd =~ s/a3:/001/g;	# 321	249
	$wd =~ s/u4:/002/g;	# 177	107
	$wd =~ s/u4/003/g;	# 57	32

	# Nasal vowels
	$wd =~ s/an/004/g;	# 47	42
	$wd =~ s/en/005/g;	# 18	16
	$wd =~ s/on/006/g;	# 33	27


	# Diphthongs
	$wd =~ s/ië/007/g;	# 14	9
	$wd =~ s/eë/008/g;	# 6	5
	$wd =~ s/uë/009/g;	# 6	4
	$wd =~ s/öw/010/g;	# 200	115

	$wd =~ s/ai/011/g;	# 31	27
	$wd =~ s/ei/012/g;	# 38	31
	$wd =~ s/åi/013/g;	# 4	4

	# Consonants
	$wd =~ s/tj3/030/g;	# 137	92
	$wd =~ s/sj3/031/g;	# 48	39
	$wd =~ s/j3/032/g;	# 191	144
	$wd =~ s/z/033/g;	# 40	26
	$wd =~ s/r0//g;
	$wd =~ s/r3/034/g;	# 672	413
	$wd =~ s/r4/035/g;	# 17	14
	$wd =~ s/rs3/036/g;	# 49	40
	$wd =~ s/rs4/037/g;	# 1	1

	$wd =~ s/dh/038/g;	# 56	16
	$wd =~ s/th/039/g;	# 73	34

	#$wd =~ s/w/v/g;

	return $wd;
}
#***************************************************************************************#
sub replace_xenophones {
	my $wd = shift;
	my $nasal_vowels = shift;

	# Vowels
	$wd =~ s/a3:/a2:/g;
	$wd =~ s/a3/a/g;
	$wd =~ s/u4:/o2:/g;
	$wd =~ s/u4/o/g;

	# Nasal vowels
	if( $nasal_vowels == 0 ) {
		$wd =~ s/an/a2: ng/g;
		$wd =~ s/en/ä2: ng/g;
		$wd =~ s/on/o2: ng/g;
	}

	# Diphthongs
	$wd =~ s/([ieu])ë/$1 ë/g;
	$wd =~ s/öw/ö w/g;
	$wd =~ s/([aeå])i/$1 j/g;

	# Consonants
	$wd =~ s/tj3/t rs/g;
	$wd =~ s/sj3/s j/g;
	$wd =~ s/j3/d j/g;
	$wd =~ s/z/s/g;
	$wd =~ s/r\d/r/g;
	$wd =~ s/rs\d/rs/g;

	$wd =~ s/dh/d/g;
	$wd =~ s/th/t/g;

	#$wd =~ s/w/v/g;

	return $wd;
}
#***************************************************************************************#
sub replace_unstressed_vowels {
	my $wd = shift;
	$wd =~ s/([ieuo])3/$1/g;

	return $wd;
}
#***************************************************************************************#
sub replace_ae {
	my $wd = shift;
	if( $wd !~ /ää/ ) {
		$wd =~ s/ä$/e/;
		$wd =~ s/ä /e /g;
	}

	if( $wd =~ /äe/ ) { exit; }

	return $wd;
}
#***************************************************************************************#
sub replace_schwa {
	my $wd = shift;

	# Schwa
	$wd =~ s/ë/e/g;
	return $wd;
}
#***************************************************************************************#
sub replace_doubleyou {
	my $wd = shift;

	$wd =~ s/w/v/g;
	return $wd;
}
#***************************************************************************************#
sub remove_vowel_length {
	my $wd = shift;

	# Long vowels
	$wd =~ s/([iyeäöuåoa])2:/$1/g;
	$wd =~ s/(a3|u4|ä3|ö3):/$1/g;

	return $wd;
}
#***************************************************************************************#
sub replace_diphthongs {
	my $doubleyou = shift;
	my $wd = shift;


	# Other diphthongs
	$wd =~ s/([ieu])ë/$1 ë/g;

	if( $doubleyou == 0 ) {
		# Swedish diphtongs
		$wd =~ s/([ae])u/$1 u/g;
		$wd =~ s/([ae])u/$1 u/g;
		$wd =~ s/([ae])u/$1 u/g;

		$wd =~ s/öw/o u/g;
	} else {
		# Swedish diphtongs
		$wd =~ s/([ae])u/$1 w/g;
		$wd =~ s/([ae])u/$1 w/g;
		$wd =~ s/([ae])u/$1 w/g;

		$wd =~ s/öw/ö w/g;
	}
	$wd =~ s/([aeå])i/$1 j/g;

	return $wd;
}
#***************************************************************************************#
sub replace_extra_open_vowels {
	my $wd = shift;
	$wd =~ s/ä3:/ä2:/g;
	$wd =~ s/ö3:/ö2:/g;
	$wd =~ s/([äö])3/$1/g;

	return $wd;
}
#***************************************************************************************#
sub replace_retroflexes {
	my $wd = shift;


#	if( $wd =~ s/r([tdsnl])/r $1/g ) {
#		$wd =~ s/r t r s/r t s/g;
#		$wd =~ s/r d r s/r d s/g;
#		$wd =~ s/r n r s/r n s/g;
#		$wd =~ s/r s r ([tln])/r s $1/g;
#	}

	$wd =~ s/r([tdsnl]) r([tdsnl])/r $1 $2/g;
	$wd =~ s/r([tdsnl])/r $1/g;

	return $wd;
}
#***************************************************************************************#
sub merge_manner {
	my $wd = shift;

	$wd =~ s/\btj3\b/t tj/g;
	$wd =~ s/\bj3\b/d j/g;

	$wd =~ s/\b(p|b|t|d|rt|rd|k|g)\b/t/g;				# plosives
	$wd =~ s/\b(f|v|th|dh|s|z|rs|rs3|rs4|sj|tj|c|sj3|h)\b/s/g;	# fricatives
	$wd =~ s/\b(m|n|rn|ng)\b/n/g;					# nasals
	$wd =~ s/\b(l|r|r0|r3|r4|rl|w)\b/n/g;				# approximants

	return $wd;
}
#***************************************************************************************#
sub merge_place {
	my $wd = shift;

	# TODO
	# 'p', 'f', 'th', 't', 'rt', 'j', 'sj', 'k', 'w', 'r4', 'h'
	return $wd;
}
#***************************************************************************************#
sub merge_roundedness {
	my $wd = shift;

	my $o = $wd;

	$wd =~ s/(a|e|å|o)i\b/$1 j/g;
	$wd =~ s/(a|e)u\b/$1 w/g;
	$wd =~ s/(ö)w\b/$1 w/g;
	$wd =~ s/(e|i|u)ë\b/$1 w/g;

	$wd =~ s/(a3\:|a\:|a|an|e\:|en|e|ë|i\:|i3|in|i|ää\:|ää|ä\:|ä)/i/g;
	$wd =~ s/(o\:|on|o|u4\:|u4|u\:|u|å\:|å|y\:|y|öö\:|öö|ö\:|ö)\b/o/g;

	$wd =~ s/in/i/;
	$wd =~ s/://g;

	#if( $wd =~ /(iä|\:|å|in)/ ) {
	#	print "$o\t$wd\n";
	#}


	return $wd;
}
#***************************************************************************************#
sub remove_digits_in_phone {
	my $wd = shift;
	$wd =~ s/2:/:/g;
	$wd =~ s/(o|u|e|i|ä|ö)3/$1$1/g;

	if( $wd =~ /[^^]\d/ ) {
		#warn "Digit in phone: $wd\n";
	}

	return $wd;
}
#***************************************************************************************#

# NL TODO Can these be obtained from Sardin's conversion table?
my %msIPASyms = (
	# NL TODO '$' is _not_ a valid MS-IPA symbol, but the conversions happens _after_ other conversions. Suggestion: put it in conversion table?
	'$' => 1,
	# NL TODO '$' is _not_ a valid MS-IPA symbol, but the conversions happens _after_ other conversions. Suggestion: put it in conversion table?
	'~' => 1,
	# NL TODO '$' is _not_ a valid MS-IPA symbol, but the conversions happens _after_ other conversions. Suggestion: put it in conversion table?
	'-' => 1,

	"." =>   1,
	"ˈ̀" =>  1,
	"ˈ́" =>  1,
	"ˌ" =>   1,
	"a" =>   1,
	"a‿u" => 1,
	"e" =>   1,
	"eː" =>  1,
	"iː" =>  1,
	"oː" =>  1,
	"uː" =>  1,
	"y" =>   1,
	"yː" =>  1,
	"æ" =>   1,
	"æː" =>  1,
	"øː" =>  1,
	"œ" =>   1,
	"œː" =>  1,
	"ɑː" =>  1,
	"ɔ" =>   1,
	"ə" =>   1,
	"ɛ" =>   1,
	"ɛː" =>  1,
	"ɪ" =>   1,
	"ɵ" =>   1,
	"ɶ" =>   1,
	"ʉː" =>  1,
	"ʊ =>" =>  1,
	"ʊ" =>   1,
	"b" =>   1,
	"d" =>   1,
	"f" =>   1,
	"g" =>   1,
	"h" =>   1,
	"j" =>   1,
	"k" =>   1,
	"l" =>   1,
	"m" =>   1,
	"n" =>   1,
	"p" =>   1,
	"r" =>   1,
	"s" =>   1,
	"t" =>   1,
	"v" =>   1,
	"ŋ" =>   1,
	"ɕ" =>   1,
	"ɖ" =>   1,
	"ɧ" =>   1,
	"ɭ" =>   1,
	"ɳ" =>   1,
	"ʂ" =>   1,
	"ʈ" =>   1,
	"aj" =>  1,
	"bɹ" =>  1,
	"dj" =>  1,
	"ds" =>  1,
	"ej" =>  1,
	"kl" =>  1,
	"lj" =>  1,
	"nj" =>  1,
	"sl" =>  1,
	"ts" =>  1,
	"ɔj" =>  1,
	"əɹ" =>  1
	);

sub invalidMSIPASymbols {
	my @pron = @_; 
	my @invalid = ();

	for my $p (@pron) {
		my $p0 = $p;
		$p0 =~ s/(ˈ̀|ˈ́|ˌ)//g;

		if (! exists $msIPASyms{$p0}) {
			push(@invalid, $p0);
		}
	}

	return @invalid;
}
#***************************************************************************************#
sub swapMSIPAStress {
	my @pron  = @_;
	my @res = ();

	#my $i = 0;
	#my $lastP = '';
	foreach my $p  (@pron) {
		$p =~ s/^(ˈ́|ˈ̀|ˌ)(.+)/$2$1/;
		push(@res, $p);
		#print "PEEE:\t$p\n";
		 # if ($lastP eq "ˈ́" || $lastP eq "ˈ̀" || $lastP eq "ˌ") {
		 #     $res[$i] = $pron[$i-1];
		 #     $res[$i-1] = $pron[$i];

		 # }

		#$i++;
		#$lastP = $p;
	}
	return @res;
}
#***************************************************************************************#
1;
