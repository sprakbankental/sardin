package MTM::Pronunciation::Syllabify;

#**************************************************************#
# Syllabify
#
# Language	sv_se
#
# Rules for syllable splitting.
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

#**************************************************************#
sub syllabify {

	# $word is not used
	my $pron = shift;

	# JE Temporary fix when $pron isn't set
	unless (defined($pron)) {
		warn "TEMPFIX: Variable \$pron is not defined";
		$pron = "no_pron";
	}

	# Split at word and compound boundaries
	my @parts = split/( [\-\~\|] )/, $pron;

	foreach my $part ( @parts ) {

		next if $part =~ /^ [\-\~\|] $/;

		# Split at vowels
		$part =~ s/ *([\"\%\`\']*(?:$MTM::Vars::phonesVowel)\,?) */<SPLIT>$1<SPLIT>/g;
		my @p = split/<SPLIT>/, $part;
		#my @p = split/ *([\"\%\`\']*(?:$MTM::Vars::phonesVowel)\,?) */, $pron;

		my $i = 0;
		foreach my $p ( @p ) {

			# Clean blanks
			$p =~ s/^ +//;
			$p =~ s/ +$//;
			$p =~ s/ +/ /g;

			if ( $i != 0 && $i != $#p ) {
				$p =~ s/ng/ ng \$/;

				# Geminate consonants	/s $ s/
				if ( $p !~ /\$/ ) {
					$p =~ s/($MTM::Vars::phonesConsonant) (\1)/$1 \$ $1/;
				}

				# Consonant or cluster	/$ s l/
				if ( $p !~ /\$/ ) {
					$p =~ s/^((?:$MTM::Vars::cOnset)|(?:$MTM::Vars::phonesConsonant))$/\$ $1/;
				}

				# Consonant + cluster	/k $ t r/
				if ( $p !~ /\$/ ) {
					$p =~ s/($MTM::Vars::phonesConsonant) ($MTM::Vars::cOnset)$/$1 \$ $2/;
				}

				# Consonant + consonant	/k $ t/
				if ( $p !~ /\$/ ) {
					$p =~ s/($MTM::Vars::phonesConsonant) ($MTM::Vars::phonesConsonant)$/$1 \$ $2/;
				}

				# Vowel + vowel	/u2: $ ë/
				if ( $p !~ /\$/ ) {
					$p =~ s/($MTM::Vars::phonesVowel) ($MTM::Vars::phonesVowel)$/$1 \$ $2/;
				}

				$p =~ s/^($MTM::Vars::phonesConsonant) \$$/\$ $1/;
				$p =~ s/\$ ng/ng \$/;
			}
			$i++;

			$part = join' ', @p;
			$part =~ s/\$ \$/ \$/g;

		}
	}

	# Join parts!
	$pron = join'', @parts;

	# Instead of &cleanBlanks in new text processor
	# $pron = &cleanBlanks( $pron );
	$pron =~ s/^ +//;
	$pron =~ s/ +$//;
	$pron =~ s/ +/ /g;

	# MMM, LLL, XXX, RRR
	$pron =~ s/e \$ ([mnfls]) e \$ \1 \'e \1/e $1 \$ e $1 \$ \'e $1/g;
	$pron =~ s/e k \$ ([s]) e k \$ \1 \'e k \1/e k $1 \$ e k $1 \$ \'e k $1/g;
	$pron =~ s/ä3 \$ ([r]) ä3 \$ \1 \'ä3 \1/ä3 $1 \$ ä3$1 \$ \'ä3$1/g;

	$pron =~ s/($MTM::Vars::phonesVowel|au|eu) ([\"\'\`]?(?:$MTM::Vars::phonesVowel))/$1 \$ $2/g;
	$pron =~ s/($MTM::Vars::phonesVowel|au|eu) ([\"\'\`]?(?:$MTM::Vars::phonesVowel))/$1 \$ $2/g;

	return $pron;
}
#***********************************************************#
1;