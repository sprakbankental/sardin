package MTM::Pronunciation::SyllabifyText;

#**************************************************************#
# SyllabifyText
#
# Language	sv_se
#
# Rules for syllable splitting in orthography.
# 
# Return: 1/0
#
# test extists	210817
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

use MTM::Vars;

my $orth_syll_boundary = '-';
#**************************************************************#
sub syllabify_text {

	my $word = shift;
	my $pron = shift;

	# JE Temporary fix when $word isn't set
	unless (defined($word)) {
		warn "TEMPFIX: Variable \$word is not defined";
		$word = "no_word";
	}

	# Split at compound boundary
	my @parts = split/(\+)/, $word;

	foreach my $part ( @parts ) {

		next if $part eq '+';

		# Number of vowels in orthography and number of syllables in pronunciation
		my $n_sylls_in_pron = $pron =~ s/$orth_syll_boundary/$orth_syll_boundary/g;
		my $n_vowels_in_orth = $word =~ s/($MTM::Vars::vowel)/$1/g;


		# Split at vowels
		$part =~ s/($MTM::Vars::vowel)/<SPLIT>$1<SPLIT>/ig;
		my @p = split/<SPLIT>/, $part;

		my $i = 0;
		foreach my $p ( @p ) {

			# Clean blanks
			$p =~ s/^ +//;
			$p =~ s/ +$//;
			$p =~ s/ +/ /g;

			if ( $i != 0 && $i != $#p ) {

				#print "A. $p\t$word\n";


				# Consonant + cluster	/k $ t r/
				#$p =~ s/($MTM::Vars::consonant) ($MTM::Vars::cOnsetOrth)$/$1 $orth_syll_boundary $2/;
				$p =~ s/($MTM::Vars::cOnsetOrth)$/$orth_syll_boundary$1/i;

#				# Consonant
				if ( $p !~ /$orth_syll_boundary/ ) {
					$p =~ s/($MTM::Vars::consonant)$/$orth_syll_boundary$1/i;
				}

			}
			$i++;

			$part = join'', @p;
			#$part =~ s/$orth_syll_boundary /$orth_syll_boundary/g;
			#$part =~ s/ $orth_syll_boundary/$orth_syll_boundary/g;
		}
	}

	# Join parts!
	$word = join'', @parts;

	# Vowel + vowel	/u $ e/
	$word =~ s/($MTM::Vars::vowel)($MTM::Vars::vowel)/$1$orth_syll_boundary$2/ig;
	$word =~ s/($MTM::Vars::vowel)($MTM::Vars::vowel)/$1$orth_syll_boundary$2/ig;

	$word =~ s/([A-ZÅÄÖ])([A-ZÅÄÖ])/$1$orth_syll_boundary$2/g;
	$word =~ s/([A-ZÅÄÖ])([A-ZÅÄÖ])/$1$orth_syll_boundary$2/g;
	$word =~ s/([A-ZÅÄÖ])([A-ZÅÄÖ])/$1$orth_syll_boundary$2/g;

	$word =~ s/\~/$orth_syll_boundary/g;

	$word =~ s/\++/\+/g;

	return $word;
}
#***********************************************************#
1;