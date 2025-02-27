package MTM::Pronunciation::Decomposition;

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

my $doWeightening = 1;
my $highScore = 0;
my $highAlt = '-';
my $highMeta = '-';

#**************************************************************#
# Decomposition
#
# Language	sv_se
#
# Rules for decomposing compounds.
# 
# Return: decomposition
#
# test exists		210818
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
# Decompose into compound parts
sub decompose {

	my $word = shift;

	### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
	#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $word !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
	#	#utf8::encode( $word );
	#}

	# print STDERR "\n\n--------------------------\nInput sub decomposition: $word\tMintok: $MTM::Vars::minTokens\n\n";

	# Words with hyphen
	### TODO allow different type of hyphens
	#if ( $word =~ s/(.)[\-\—\-](.)/$1\+-\+$2/g ) {
	#if ( $word =~ /(.)-(.)/ ) {
		my @word = split/-/, $word;
	#} else {
	#	push @word, $word;
	#}

	my @decomp = ();

	foreach my $part( @word ) {

		# print STDERR "\nPart:\t$part\n"; #\t$word\tPARTINFO\t$partpron\n";

		# Default values (if nothing else is found)
		$highScore = 0;
		$highAlt = '-';
		$highMeta = 'NN	swe	swe';

		my $to_push = $part;

		# Dictionary check
		my ( $dictPron ) = &MTM::Pronunciation::Dictionary::dictionaryLookup( $part, 'all', '-', '-' );

		# Is not indictionary
		if( &MTM::Legacy::isDefault( $dictPron )) {

			my( $alternatives, $metadata ) = &decomp( $part, $MTM::Vars::minTokens );
			my %alternatives = %{$alternatives};
			#my %metadata = %{$metadata};

			# Loop through decomposed alternatives and chose the best one.
			if( %alternatives ) {
				( $to_push, $highMeta ) = &compare_alts( $alternatives, $metadata );
			}

		# $part exists in dictionaries, use that information
		} else {
			my @dictPron = split/<split>/, $dictPron;
			my @dp = split/\t/, shift @dictPron;
			$highMeta = "$dp[1]\t$dp[2]\t$dp[3]";
		}

		push @decomp, $to_push;
	}


	my $decomp = join'-', @decomp;
	$decomp =~ s/(-)/\+$1\+/g;

	# print STDERR "decomp return $decomp\n";


	$decomp =~ s/($MTM::Legacy::Lists::sv_special_character_list)(\d)/$1\+$2/g;
	return ( $decomp, $highMeta );
#	}

#	# Test if some word parts could be truncated.
#	my $truncWord = $word;
#	if ( $truncWord =~ s/([bdfglmnprst])\1/$1$1$1/g ) {
#		my( $alternatives, $metadata ) = &decomp( $truncWord, $MTM::Vars::minTokens );
#	}

}
#****************************************************************************#
sub decomp {

	my $word = shift;

	# print STDERR "\nInput decomp\n\t$word\t$MTM::Vars::minTokens\n";

	$word = MTM::Case::makeLowercase( $word );

	my @word = split//, $word;

	my @initial = ();

	my $wordLength = length( $word );

	my $i = 0;
	my $j = $i + $MTM::Vars::minTokens;
	my $end = $#word;

	my %initialList = ();
	my %medialList = ();
	my %finalList = ();

	my $iniOccs = 0;
	my $medOccs = 0;
	my $finOccs = 0;

	my %alternatives = ();
	my %metadata = ();

	# Start from beginning - find all possible parts in the word
	foreach my $i ( 0..$end) {

		# Counter 2
		my $j = 0;
		foreach $j ( $MTM::Vars::minTokens-1..$end ) {

			if ( $j - $i >= $MTM::Vars::minTokens -1 ) {

				my $part = join"", @word[$i..$j];



				#while(my($k,$v)=each(%$MTM::Legacy::Lists::sv_initial_orth_dec_parts)) { print "I $k\t$v\n"; }
				# print "\t$i\t$j\t$MTM::Vars::minTokens\t$part\n";

				# print STDERR "$i\t$j\t$MTM::Vars::minTokens\t$part\n";

				# English
				if( $MTM::Vars::lang eq 'en' ) {
					# Initial
					if ( $i == 0 ) {
						if ( exists( $MTM::Legacy::Lists::en_initial_orth_dec_parts{ $part } )) {

							# print STDERR "INI $part\t $MTM::Legacy::Lists::en_initial_orth_dec_parts{ $part }\n";

							$initialList{ $part }++;
							$iniOccs += $MTM::Legacy::Lists::en_initial_orth_dec_parts{ $part };
						}

					# Medial
					} elsif ( $i != 0 && $j != $end ) {

						if ( exists(  $MTM::Legacy::Lists::en_medial_orth_dec_parts{ $part } )) {

							#if ( $word eq 'lungfunktionsinskränkning' ) {
							#	print "PART $part\$MTM::Legacy::Lists::en_medial_orth_dec_parts{ $part }\n";
							#}


							# Only if at least $MTM::Vars::minTokens left for final part!
							if ( $j <= $end - $MTM::Vars::minTokens ) {
								# print STDERR "MID $part\t $MTM::Legacy::Lists::en_medial_orth_dec_parts{ $part }\n";

								#print "\tMID $part\t $MTM::Legacy::Lists::en_medial_orth_dec_parts{ $part }\n";

								$medialList{ $part }++;
								$medOccs += $MTM::Legacy::Lists::en_medial_orth_dec_parts{ $part };
							}
						}

					# Final
					} elsif ( $j == $end ) {
						#print "PPP $part\n";

						if ( exists( $MTM::Legacy::Lists::en_final_orth_dec_parts{ $part } )) {

							#print STDERR "FIN EN $part\t $MTM::Legacy::Lists::en_final_orth_dec_parts{ $part }\n";

							$finalList{ $part }++;
							$finOccs += $MTM::Legacy::Lists::en_final_orth_dec_parts{ $part };
						}
					}	
				# Swedish and world
				} else {

					#print STDERR "$i\t$j\t$MTM::Vars::minTokens\t$part\n";
					### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
					if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $word !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
						#print "1. $part\n";
						utf8::encode( $part );
						#print "2. $part\n";
					}

					# Initial
					if ( $i == 0 ) {
						if ( exists( $MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $part } )) {

							# print STDERR "INI $part\t $MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $part }\n";

							$initialList{ $part }++;
							$iniOccs += $MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $part };
						}

					# Medial
					} elsif ( $i != 0 && $j != $end ) {

						if ( exists(  $MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $part } )) {

							#if ( $word eq 'lungfunktionsinskränkning' ) {
							#	print "PART $part\$MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $part }\n";
							#}


							# Only if at least $MTM::Vars::minTokens left for final part!
							if ( $j <= $end - $MTM::Vars::minTokens ) {
								# print STDERR "MID $part\t $MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $part }\n";

								#print "\tMID $part\t $MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $part }\n";

								$medialList{ $part }++;
								$medOccs += $MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $part };
							}
						}

					# Final
					} elsif ( $j == $end ) {
						#print "PPP $part\n";

						if ( exists( $MTM::Legacy::Lists::sv_final_orth_dec_parts{ $part } )) {

							#print STDERR "FIN SV $part\t $MTM::Legacy::Lists::sv_final_orth_dec_parts{ $part }\n";

							$finalList{ $part }++;
							$finOccs += $MTM::Legacy::Lists::sv_final_orth_dec_parts{ $part };
						}
					}
				}

			}

			$j++;
		}


		$i++;
	}

	# Sort lists from most tokens to least
	my @initialList = sort { length($b) <=> length($a) || $a cmp $b } keys %initialList;
	my @medialList = sort { length($b) <=> length($a) || $a cmp $b } keys %medialList;
	my @finalList = sort { length($b) <=> length($a) || $a cmp $b } keys %finalList;

	my $initialPart = '-';
	my $medialPart = '-';
	my $finalPart = '-';

	# print STDERR "INITIAL LIST\t@initialList\nMEDIAL LIST\t@medialList\nFINAL LIST\t@finalList\n\n";

	# Try combinations
	my $medialParts = join"|",@medialList;
	foreach my $ini ( @initialList ) {

		# print "INI $ini\n";

		foreach my $fin ( @finalList ) {

			# print "FIN $fin\n";

			# Initial + final
			if ( $word =~ /^$ini$fin$/ ) {

				# CT 180316 Ugly fix for '-Sverige'
				if( $MTM::Vars::lang eq 'sv' &&  $fin !~ /^rige$/i ) {

					my $iniProb = $MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $ini } / $iniOccs;
					my $finProb = $MTM::Legacy::Lists::sv_final_orth_dec_parts{ $fin } / $iniOccs;

					my $metadata = $MTM::Legacy::Lists::sv_final_orth_meta{ $fin };

					# print STDERR "HOHOH $ini\t$fin\t$metadata\n";

					my $score = $iniProb * $finProb;
					my $alt = "$ini+$fin";
					$alt =~ s/\++/\+/g;
					$alternatives{ $alt } = $score;
					$metadata{ $alt } = $metadata;

				} elsif( $MTM::Vars::lang eq 'en' ) {

					my $iniProb = $MTM::Legacy::Lists::en_initial_orth_dec_parts{ $ini } / $iniOccs;
					my $finProb = $MTM::Legacy::Lists::en_final_orth_dec_parts{ $fin } / $iniOccs;

					my $metadata = $MTM::Legacy::Lists::en_final_orth_meta{ $fin };

					# print STDERR "HOHOH $ini\t$fin\t$metadata\n";

					my $score = $iniProb * $finProb;
					my $alt = "$ini+$fin";
					$alt =~ s/\++/\+/g;
					$alternatives{ $alt } = $score;
					$metadata{ $alt } = $metadata;

					# print STDERR "ALT $alt\t$score\t$metadata\n";
				}

			# Initial + medial + final
			} elsif (
				 $#medialList > -1
				&&
				$word =~ /^$ini((?:$medialParts)+)$fin$/
			) {
				my $med = $1;


				# Do not split directly to list.	CT 150330		
				$med =~ s/^($medialParts)($medialParts)$/$1\+$2/;
				$med =~ s/\+($medialParts)($medialParts)$/\+$1\+$2/;
				$med =~ s/\+($medialParts)($medialParts)$/\+$1\+$2/;

				my @med = split/\+/, $med;

				# Split medial parts
				#my @med = split/($medialParts)/, $med;
				#$med = join"+", @med;

				my $iniProb = 0;
				my $medProb = 0;
				my $finProb = 0;
				my $add = 0;
				my $metadata;

				# English
				if( $MTM::Vars::lang eq 'en' ) {
					$iniProb = $MTM::Legacy::Lists::en_initial_orth_dec_parts{ $ini } / $iniOccs;
					$MTM::Legacy::Lists::en_final_orth_dec_parts{ $fin } =~ /^(\d+)\t(.+)$/;
					$finProb = $MTM::Legacy::Lists::en_final_orth_dec_parts{ $fin } / $iniOccs;

					$metadata = $MTM::Legacy::Lists::en_final_orth_meta{ $fin };


					# NB! The medial probability is not true (but nice to compare with) if the word contains more than one medial part.
					$medProb = 1;
					my $savedMedProb = $medProb;
					$add = 1;
					foreach my $m ( @med ) {

						if ( $m =~ /./ && exists( $MTM::Legacy::Lists::en_medial_orth_dec_parts{ $m } )) {

							#print "MM __ $m __\t$medOccs\n";

							# print STDERR "$m does not exist!\n";

							my $mp =  $MTM::Legacy::Lists::en_medial_orth_dec_parts{ $m } / $medOccs;
							$medProb *= $mp;
							#print "medprob $medProb\n";
						} else {
							$add = 0;
						}
					}

				# Swedish and world
				} else {
					$iniProb = $MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $ini } / $iniOccs;
					$MTM::Legacy::Lists::sv_final_orth_dec_parts{ $fin } =~ /^(\d+)\t(.+)$/;
					$finProb = $MTM::Legacy::Lists::sv_final_orth_dec_parts{ $fin } / $iniOccs;

					$metadata = $MTM::Legacy::Lists::sv_final_orth_meta{ $fin };

					# NB! The medial probability is not true (but nice to compare with) if the word contains more than one medial part.
					$medProb = 1;
					my $savedMedProb = $medProb;
					$add = 1;
					foreach my $m ( @med ) {

						if ( $m =~ /./ && exists( $MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $m } )) {

							#print "MM __ $m __\t$medOccs\n";

							# print STDERR "$m does not exist!\n";

							my $mp =  $MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $m } / $medOccs;
							$medProb *= $mp;
							#print "medprob $medProb\n";
						} else {
							$add = 0;
						}
					}
				}

			# print STDERR "II $iniProb = $MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $ini }\t$iniOccs\n";

				my $score = $iniProb * $medProb * $finProb;
				my $alt = "$ini+$med+$fin";

				$alt =~ s/\++/\+/g;

				if ( $add == 1 ) {
					$alternatives{ $alt } = "$score";
					$metadata{ $alt } = $metadata;
				}

			}
		}
	}

	return( \%alternatives, \%metadata );
}
#**************************************************************#
sub compare_alts {
	my $alternatives = shift;
	my %alternatives = %$alternatives;

	my $metadata = shift;
	my %metadata = %$metadata;

	my $highScore = 0;

	while( my( $alt, $score ) = each( %alternatives )) {

		# print STDERR "A word\t$alt\t$alternatives\n";

		# Weightening score: favouring decompositions with few parts
		# Not suitable for decomposing i.e. Braille (when smaller parts are desirable).
		if ( $doWeightening == 1 ) {
			my $nParts = $alt =~ s/\+/\+/g;
			my $incrScore = ( 5 - $nParts )/10;	# 0

			# Increase score even more if no split after medial "för"
			if ( $alt =~ /\+för[^\+]/i ) {
				$incrScore += 1;
				# print STDERR "$alt\tScore increased with 1, no split after _för_.\n";
			}

			$score += $incrScore;

			# print STDERR "HHH $alt\tScore increased with $incrScore\t$score\t$highAlt\n\n";
		}

		# print STDERR "ALT \t$alt\t$score\n";
		if ( $score > $highScore ) {
			$highScore = $score;
			$highAlt = $alt;

			if( exists( $metadata{ $alt } )) {
				$highMeta = $metadata{ $alt };
				# print "META\t$alt\t$highMeta\n";
			}

		}

		#$to_push = $highAlt;

		# print STDERR "FOUND $highAlt\t$highMeta\t$score\n\n";
	}

	# print STDERR "RETURN $highAlt\t$highMeta\n\n";
	return( $highAlt, $highMeta );
}
#**************************************************************#

1;
