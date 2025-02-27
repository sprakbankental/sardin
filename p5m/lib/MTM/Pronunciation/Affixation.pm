package MTM::Pronunciation::Affixation;

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

use MTM::Pronunciation::Dictionary;

#**************************************************************#
# Affixation
#
# Language	sv_se
#
# Rules for getting pronunciations from dictionaries.
#
# Return: pronunciation
#
# test exists		210817
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub affixation {
	my ( $word, $minTokens ) = @_;

	$word = &MTM::Case::makeLowercase( $word );

	my $affixFlag = '0';

	# print STDERR "\n\n**************************\nInput affixation\n\t$word\tminTok: $minTokens\tDebug: $debug\n";

	#********************************************************************#
	# If word is shorter than $minTokens, return $affixFlag = 0.
	my $lengthWord = length( $word ) + 1;
	if ( $lengthWord < $minTokens ) {

		# print STDERR "\nWord length ( $lengthWord ) is less than minTokens ( $minTokens ), returning 'void', $affixFlag\n";

		return( 'void', $affixFlag );
	}

	# print STDERR "affixation\t$MTM::Legacy::Lists::sv_initial_dec_parts_list\n";
	#********************************************************************#
	# Go!
	# Word consists of word from initial decomposition parts list and suffix

	# English
#	if( $MTM::Vars::lang eq 'en' ) {
#		### TODO when decpartslists for english exist
#		if (
#			$word =~ /^($MTM::Legacy::Lists::en_initial_dec_parts_list)($MTM::Legacy::Lists::en_suffix_list|\'s|\:s)$/i
#		) {
#			my $lemmish = $1;
#			my $suffix = $2;
#
#			$suffix =~ s/\'//g;
#
#			# print STDERR "\nWord consists of lemmish part and suffix: $lemmish\t$suffix\n";
#
#			# Get pronunciation for lemmish word
#			my ( $lemmishPron, $pos, $ortlang, $lang, $decomp ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( $lemmish, "all", '-', 'swe' );
#
#
#			if ( &MTM::Legacy::isDefault( $lemmishPron ) ) {
#				# print STDERR "affixation.pl No pronunciation for\t$lemmish\n";
#				return ( 'void', '0' );
#		
#			} else {
#			
#				# Get suffix pronunciation
#				my $tmpSuffix = $suffix;
#				$tmpSuffix = &MTM::Case::makeLowercase( $suffix );
#				$tmpSuffix =~ s/^://;
#		
#				my $suffixPron;
#				if ( exists( $MTM::Legacy::Lists::en_suffix{ $tmpSuffix } )) {
#					$suffixPron = $MTM::Legacy::Lists::en_suffix{ $tmpSuffix };
#				}
#
#				# print STDERR "Suffix:\t$suffix\tPron:\t$suffixPron\n";
#		
#				# Suffix is stressed - remove stress from lemma
#				if ( $suffixPron =~ /([\"\'])/ ) {
#					
#					my $stress = quotemeta( $1 );
#					# Secondary stress
#					if ( $lemmishPron =~ /\`/ ) {
#						$stress = "\`";
#						$suffixPron =~ s/[\"\']/\`/;
#					}
#					
#					# Remove stress, vowel length and stød
#					my @lemmishPron = split/( [\$\-] )/, $lemmishPron;
#					foreach my $lp ( @lemmishPron ) {
#						if ( $lp =~ s/$stress// ) {
#							$lp =~ s/[\:\?]//g;
#							$lp =~ s/ +/ /g;
#							$lp =~ s/ +$//;
#						}
#					}
#
#					$lemmishPron = join"", @lemmishPron;
#				}
#		
#				# Concatenate pronunciations
#				my $pron = $lemmishPron . ' ' . $suffixPron;
#
#				# Retroflexation
#				$pron =~ s/ (rd|rt|rn) s$/ $1 rs/;
#				$pron =~ s/ rs s$/ rs/;
#				$pron =~ s/ r s$/ rs/;
#
#				# print STDERR "Pronunciation:\t$pron\n";
#
#				# Syllabify
#				$pron = &MTM::Pronunciation::Syllabify::syllabify( $pron );
#	
#				$affixFlag = 1;
#	
#				# print STDERR "affixation.pl returns\n\tPron\t$pron\n\tPos\t$pos\n\tLang\t$ortlang\t$lang\n\nFlag:\t$affixFlag\n";
#				
#				# Decomposition fiels
#				$decomp .= $suffix;
#
#				# Get PoS from suffix list
#				if ( exists( $MTM::Legacy::Lists::en_suffix_pos{ $suffix } )) {
#					#print "\n\nMTM::Legacy::Lists::en_suffix_pos\t$pron\n";
#					if ( $MTM::Legacy::Lists::en_suffix_pos{ $suffix } =~ /_GEN$/ ) {
#						$pos =~ s/NOM$/GEN/;
#					} else {
#						$pos = $MTM::Legacy::Lists::en_suffix_pos{ $suffix };
#					}
#			
#					#print "\n\nMTM::Legacy::Lists::en_suffix_pos\t$pron\t$pos\n";
#			
#					# print STDERR "Suffix PoS\t$pos\n";
#				}
#
#				return ( $pron,  $affixFlag, $pos, $ortlang, $lang, $decomp );
#			}
#	
#		} else {
#			# print STDERR "affixation.pl No affix found.\n";
#
#			return ( 'void',  $affixFlag);
#		}
	# Swedish and world
	#} else {
		if (
			$word =~ /^($MTM::Legacy::Lists::sv_initial_dec_parts_list)($MTM::Legacy::Lists::sv_suffix_list|\'s|\:s)$/i
		) {
			my $lemmish = $1;
			my $suffix = $2;

			$suffix =~ s/\'//g;

			# print STDERR "\nWord consists of lemmish part and suffix: $lemmish\t$suffix\n";

			# Get pronunciation for lemmish word
			my ( $lemmishPron, $pos, $ortlang, $lang, $decomp ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( $lemmish, "all", '-', 'swe' );


			if ( &MTM::Legacy::isDefault( $lemmishPron ) ) {
				# print STDERR "affixation.pl No pronunciation for\t$lemmish\n";
				return ( 'void', '0' );

			} else {

				# Get suffix pronunciation
				my $tmpSuffix = $suffix;
				$tmpSuffix = &MTM::Case::makeLowercase( $suffix );
				$tmpSuffix =~ s/^://;

				my $suffixPron;
				if ( exists( $MTM::Legacy::Lists::sv_suffix{ $tmpSuffix } )) {
					$suffixPron = $MTM::Legacy::Lists::sv_suffix{ $tmpSuffix };
				}

				# print STDERR "Suffix:\t$suffix\tPron:\t$suffixPron\n";

				# Suffix is stressed - remove stress from lemma
				if ( $suffixPron =~ /([\"\'])/ ) {

					my $stress = quotemeta( $1 );
					# Secondary stress
					if ( $lemmishPron =~ /\`/ ) {
						$stress = "\`";
						$suffixPron =~ s/[\"\']/\`/;
					}

					# Remove stress, vowel length and stød
					my @lemmishPron = split/( [\$\-] )/, $lemmishPron;
					foreach my $lp ( @lemmishPron ) {
						if ( $lp =~ s/$stress// ) {
							$lp =~ s/[\:\?]//g;
							$lp =~ s/ +/ /g;
							$lp =~ s/ +$//;
						}
					}

					$lemmishPron = join"", @lemmishPron;
				}

				# Concatenate pronunciations
				my $pron = $lemmishPron . ' ' . $suffixPron;

				# Retroflexation
				$pron =~ s/ (rd|rt|rn) s$/ $1 rs/;
				$pron =~ s/ rs s$/ rs/;
				$pron =~ s/ r s$/ rs/;

				# print STDERR "Pronunciation:\t$pron\n";

				# Syllabify
				$pron = &MTM::Pronunciation::Syllabify::syllabify( $pron );

				$affixFlag = 1;

				# print STDERR "affixation.pl returns\n\tPron\t$pron\n\tPos\t$pos\n\tLang\t$ortlang\t$lang\n\nFlag:\t$affixFlag\n";

				# Decomposition fiels
				$decomp .= $suffix;

				# Get PoS from suffix list
				if ( exists( $MTM::Legacy::Lists::sv_suffix_pos{ $suffix } )) {
					#print "\n\nMTM::Legacy::Lists::sv_suffix_pos\t$pron\n";
					if ( $MTM::Legacy::Lists::sv_suffix_pos{ $suffix } =~ /_GEN$/ ) {
						$pos =~ s/NOM$/GEN/;
					} else {
						$pos = $MTM::Legacy::Lists::sv_suffix_pos{ $suffix };
					}

					#print "\n\nMTM::Legacy::Lists::sv_suffix_pos\t$pron\t$pos\n";

					# print STDERR "Suffix PoS\t$pos\n";
				}

				return ( $pron,  $affixFlag, $pos, $ortlang, $lang, $decomp );
			}

		} else {
			# print STDERR "affixation.pl No affix found.\n";

			return ( 'void',  $affixFlag);
		}
	#}

}

#*************************************************************************#
1;
