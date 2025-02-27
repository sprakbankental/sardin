package MTM::Pronunciation::Stress;

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
# Stress
#
# Language	sv_se
#
# Rules for stress asssignment.
#
# Return: pronunciation
#
# tests exist		210818
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
# numeralStress
#
# Removing stress symbols from concatenated numeral transcription.
#
#**************************************************************#
## CT 210818 Think this one is redundant now
sub numeralStress {

	my $pron = shift;

	if ( $debug ) {
		print DEBUG "\nnumeralStress\t$pron\n";
	}

	my @pron = split/ \| /, $pron;

	my @stressPron = ();
	foreach my $p ( @pron ) {

		# Remove stress at final "hundra".
		if ( $p =~ s/([a-zåäö2\:\.]) h \'u n d r a *$/$1 h u n d r a/) {

		# Remove multiple main stress.
		} elsif ( $p =~ /^(.*[\"\'].*)([\"\'][^\"\']+)$/ ) {
			my $first = $1;
			my $second = $2;

			# Save only the last stress symbol.
			$first =~ s/[\"\'\`]//g;

			$p = $first . $second;
		}

		push @stressPron, $p;
	}
	$pron = join" | ", @pron;
	# print STDERR "\tReturning\t$pron\n";
	return $pron;
}
#**************************************************************#
# firstPartStress
#
# Accent II on first part of compound.
#
# test exists
#**************************************************************#
sub firstPartStress {	# return var

	my $pron = shift;

	# Remove secondary stress
	$pron	 =~ s/\`//g;

	# Change accent I to accent II
	$pron	 =~ s/\'/\"/g;

	# Keep the last main stress only
	$pron	 =~ s/\"(.+)\"/$1\"/g;
	$pron	 =~ s/\"(.+)\"/$1\"/g;
	$pron	 =~ s/\"(.+)\"/$1\"/g;

	return $pron;

}
#**************************************************************#
# secondPartStress
#
# Seconday stress on second part of compound.
#
# test exists
#**************************************************************#
sub lastPartStress {	# return var

	my $pron = shift;

	if( $pron =~ /[\"\']/ ) {
		$pron =~ s/\`//;
		$pron =~ s/[\"\']/\`/;
	}

	# CT 171208 use rule above
	# Secondary stress exists - remove primary stress
	#if ( $pron =~ /\`/ ) {
	#	$pron =~ s/[\"\']//;
	#
	## Else change primary stress to seconday stress
	#} else {
	#	$pron =~ s/[\"\']/\`/;
	#}

	return $pron;

}
#**************************************************************#
# acronymStress
#
# Seconday stress on second part of compound (acronym).

# test exists
#**************************************************************#
# return var
sub acronymStress {

	my $acronym = shift;

	# print STDERR "\n-------------------------\nacronymStress\n\t$acronym\n";

	if( $MTM::Vars::lang eq 'sv' ) {

		my @parts = split/ \| /, $acronym;
		foreach my $pron( @parts ) {

			my @pron = split/ (\~) /, $pron;
			my $i = 0;

			my $nLetters = $pron =~ s/\~/\~/g;

			# Accent II if two letters
			if ( $nLetters == 1 ) {
				# $pron[1] is the delimiter '~'
				$pron[0] =~ s/\'/\"/;
				$pron[2] =~ s/[\"\'\`]/\`/g;

			# Accent II if more than three letters
			} elsif ( $nLetters > 3 ) {
				foreach my $p ( @pron ) {
					if (
						$i == $#pron
					) {
						$p =~ s/[\"\']/\`/g;
						$i++;
					} elsif (
						$i == $#pron-2
					) {
						$p =~ s/\'/\"/g;
						$i++;
					} else {
						$p =~ s/[\'\"\`]//g;
						$i++;
					}
				}

			# Keep last stress only
			} else {
				foreach my $p ( @pron ) {

					if (
						$i != $#pron
					) {
						$p =~ s/[\"\'\`]//g;
						$i++;
					}
				}
			}

			$pron = join' ', @pron;
		}

		my $acronymPron = join' | ', @parts;

		#print STDERR "\tReturning\t$acronymPron\n";

		return $acronymPron;

	# English
	} else {
		return $acronym;
	}
}
#**************************************************************#
# acronymEnglishStress
#
#**************************************************************#
sub englishAcronymStress {	# return: var

	my ( $acronym, $debug ) = @_;

	if ( $debug ) {
		print DEBUG "\n-------------------------\nacronymStress\n\t$acronym\n";
	}

	my @parts = split/ \| /, $acronym;
	foreach my $pron( @parts ) {

		my @pron = split/ (\~) /, $pron;
		my $i = 0;

		my $nLetters = $pron =~ s/\~/\~/g;

		# Keep last stress only
		foreach my $p ( @pron ) {

			if (
				$i != $#pron
			) {
				$p =~ s/[\"\'\`]//g;
				$i++;
			}
		}

		$pron = join' ', @pron;
	}

	my $acronymPron = join' | ', @parts;

	# print STDERR "\tReturning\t$acronym\t$acronymPron\n";

	return $acronymPron;
}
#**************************************************************#
sub sv_compound_stress {

	my $pron = shift;

	# print STDERR "\n---- Compound stress ----\n$pron\n\n";

	my @pron = split/ - /, $pron;

	my $i = 0;
	foreach my $part ( @pron ) {

		# print STDERR "P $part\t$i\n";

		# First part, accent II
		if ( $i == 0 ) {

			# Multiword: change stress on last word only
			if ( $part =~ / \| / ) {
				$part =~ /^(.+ \| )([^|]+)$/;
				my $firstWords = $1;
				my $lastWord = $2;
				$lastWord =~ s/\`//;
				$lastWord =~ s/\'/\"/;

				$part = $firstWords . $lastWord;

			# Simplex
			} else {
				$part =~ s/\`//;
				$part =~ s/\'/\"/;
			}

			# print STDERR "First part\t$part\n";

		# Last part, secondary stress
		# It's not that simple...
		} elsif ( $i == $#pron ) {

			if ( $part =~ /\"/ ) {
				$part =~ s/\`//;
				$part =~ s/\"/\`/
				#$part =~ s/\"//;

			} elsif ( $part =~ s/\'/\`/ ) {
				# do nothing
			}

		# Middle parts, remove all stress markers
		} else {
			$part =~ s/[\"\'\`]//g;

		}
		$i++;
	}

	$pron = join" - ", @pron;

	# print STDERR "Returning $pron\n\n";

	return $pron;
}
#**************************************************************#
sub en_compound_stress {

	my $pron = shift;

	# print STDERR "\n---- Compound stress ----\n$pron\n\n";

	my @pron = split/ - /, $pron;

	my $i = 0;
	foreach my $part ( @pron ) {

		# print STDERR "P $part\t$i\n";

		# First part, accent II
		if ( $i == 0 ) {

			# Multiword: change stress on last word only
			if ( $part =~ / \| / ) {
				$part =~ /^(.+ \| )([^|]+)$/;
				my $firstWords = $1;
				my $lastWord = $2;
				$lastWord =~ s/\`//;
				$lastWord =~ s/\"/\'/;

				$part = $firstWords . $lastWord;

			# Simplex
			} else {
				$part =~ s/\`//;
				$part =~ s/\"/\'/;
			}

			# print STDERR "First part\t$part\n";

		# Last part, no stress
		# It's not that simple...
		} elsif ( $i == $#pron ) {
			$part =~ s/[\"\'\`]//g;

		# Middle parts, remove all stress markers
		} else {
			$part =~ s/[\"\'\`]//g;

		}
		$i++;
	}

	$pron = join" - ", @pron;

	# print STDERR "Returning $pron\n\n";

	return $pron;
}
#**************************************************************#
sub move_stress_to_vowel {
	my $pron = shift;
	my $current_vowels = shift;

	# print STDERR "move_stress_to_vowel\t$pron\t$current_vowels\n";

	my @new_pron = ();
	my @pron = split/ +/, $pron;

	my $saved_stress = 'void';
	foreach my $p( @pron ) {

		if( $p =~ /^(\"+|\%)$/ ) {
			$saved_stress = $1;
		} elsif( $saved_stress ne 'void' && $p =~ /^($current_vowels)$/ ) {
			$p = $saved_stress . $p;
			push @new_pron, $p;
			$saved_stress = 'void';
		} else {
			push @new_pron, $p;
		}
	}

	# print STDERR "move_stress_to_vowel return\t@new_pron\n";

	return join' ', @new_pron;
}
#**************************************************************#
# NO TEST EXISTS
sub insert_secondary_stress {
	my $pron = shift;
	my $current_vowels = shift;

	# print STDERR "insert_secondary_stress\t$pron\t$current_vowels\n";

	my @new_pron = ();
	my @pron = split/ +/, $pron;

	my $accent2seen = 0;
	my $sec_stress_set = 0;
	foreach my $p( @pron ) {

		if( $p =~ /\"/ ) {
			$accent2seen = 1;
			push @new_pron, $p;
		} elsif( $accent2seen == 1 && $sec_stress_set == 0 && $p !~ /i3/ && $p =~ /^($current_vowels)$/ ) {
			$p = '`' . $p;
			push @new_pron, $p;
			$sec_stress_set = 1;
		} else {
			push @new_pron, $p;
		}
	}

	# print STDERR "move_stress_to_vowel return\t@new_pron\n";

	return join' ', @new_pron;
}
#**************************************************************#
1;
