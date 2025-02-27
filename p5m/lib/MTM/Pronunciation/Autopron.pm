﻿package MTM::Pronunciation::Autopron;

#**************************************************************#
# Autopron
#
# Language	sv_se
#
# Rules for creating automatic pronunciations.
# 
# Return: pronunciation
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

# Needed if the module runs standalone, e.g. for testing
# Should probably be sorted with inheritance in time
use MTM::Vars;
use MTM::Case;

my @stressable = qw(au eu i2: i y2: y u2: u4: u4 u3 u e2: e3 e ë ä3: ä3 ä2: ä ö3: ö3 ö2: ö a3: a2: a o2: o3 o å2: å an on en ei åi ai uë eë ië);

# Create variable used in regexp
foreach my $str ( @stressable ) {
	$str = quotemeta( $str );
}
my $stressable = join"|", @stressable;

use Storable;
$Storable::interwork_56_64bit = 1;

our %ltsTree;
our %stressTree;


my $storedPath = "data/autopron";
#***********************************************************#
# Cart trees
#***********************************************************#
# .dat
my $storedLtsTreeFile = "$storedPath/storedLTStree.dat";
my $storedStressTreeFile = "$storedPath/storedStresstree.dat";

#print STDERR "S $storedLtsTreeFile\n";

# Tree files
my $sweTreeFile = "$storedPath/ltsTree.pl";

#print "Looking for: $sweTreeFile\n";
#if( -e "$sweTreeFile" ) {
#	print "Found: $sweTreeFile\n";
#}
#***********************************************************#
# Store - use this when the tree is changed
#***********************************************************#
# Create directory
#unless (-d $storedPath ) {
#	mkdir $storedPath;
#	print STDERR "Creating path: $storedPath\n";
#}

# Store if dat files don't exist.
unless ( -e "$storedLtsTreeFile" ) {
	use lib "data/autopron";
	require "ltsTree.pl";
	store ( \%ltsTree, "$storedLtsTreeFile" );
	store ( \%stressTree, "$storedStressTreeFile" );
	#print "STORE $storedStressTreeFile\n";
	#for my $l ( keys %ltsTree ) { print STDERR "NOW $l: "; for my $role ( keys %{ $ltsTree{$l} } ) { print STDERR "$role=$ltsTree{$l}{$role} "; } print STDERR "\n"; }
	#for my $l ( keys %stressTree ) { print STDERR "NOW $l: "; for my $role ( keys %{ $stressTree{$l} } ) { print STDERR "$role=$stressTree{$l}{$role} "; } print STDERR "\n"; }
}

#***********************************************************#
# Retrieve - else use this for immediate access to tree
#***********************************************************#
%ltsTree = %{ retrieve( "$storedLtsTreeFile" ) };
%stressTree = %{ retrieve( "$storedStressTreeFile" ) };

#for my $l ( keys %ltsTree ) { print STDERR "NOW $l: "; for my $role ( keys %{ $ltsTree{$l} } ) { print STDERR "lstTree $role=$ltsTree{$l}{$role} "; } print STDERR "\n"; }
#for my $l ( keys %stressTree ) { print STDERR "NOW $l: "; for my $role ( keys %{ $stressTree{$l} } ) { print STDERR "stressTree $role=$stressTree{$l}{$role} "; } print STDERR "\n"; }


#print STDERR "\n\n\n\n\n";
#exit;
#use Data::Dumper;
#while(my($k,$v)=each(%ltsTree)){ print STDERR "k $k\t$v\n"; }

#*********************************************************#
# Create both phonemes and stress
#*********************************************************#
sub cartAndStress {
	my $word = shift;
	my $domain = shift;

	# print STDERR "\nInput cartAndStress:\t$word\t$domain\n";

	$domain =~ s/^(sv_se|default)$/swe/;
	$domain =~ s/^en_uk$/eng/;

	if ( $word =~ /[a-zA-ZåäöÅÄÖ]/ ) {

		my $pron = &cart( $word, $domain );
		$pron = &doStress( $word, $pron, $domain );


		return $pron;
	} else {
		return '-';
	}
}
#*********************************************************#
# Create phoneme string (no stress)
#*********************************************************#
sub cart {
	my $word = shift;
	my $domain = shift;

	# print STDERR "$word\t$domain\n";

	$word =~ s/[\-\']//g;

	$word = &MTM::Case::makeLowercase( $word );

	$word =~ s/ï/i/g;
	$word =~ s/ç/c/g;
	$word =~ s/ô/o/g;
	$word =~ s/è/e/g;
	$word =~ s/ø/ö/g;
	$word =~ s/æ/ä/g;
	$word =~ s/ú/u/g;
	$word =~ s/ó/o/g;
	$word =~ s/é/e/g;
	$word =~ s/ü/y/g;
	$word =~ s/Ü/y/g;
	$word =~ s/î/i/g;

	if( $domain =~ /en/i ) {
		$word =~ s/ä / e /g;
		$word =~ s/ö/o/g;
		$word =~ s/[åä]/a/g;
	}

	# Remove delimiters and digits
	$word =~ s/[\.\,\:\;\(\)\?\!\d]//g;
	# 210610 $word =~ s/[^aouåeiyäöøæéèëêíìïîáàâóòôúùüûýÿbcdfghjklmnpqrstvwxzñ]//g;

	$domain =~ s/default/swe/;
	$domain =~ s/sv_se/swe/;
	$domain =~ s/en_uk/eng/;

	my $pre = 4;
	my $post = 4;

	my @string = ();

	# Do not split on each characater (split//, $word), does not work for utf8 e.g. åäö.
	$word =~ s/($MTM::Vars::characters|å|ä|ö)/ $1/g;
	my @word = split/ /, $word;
	shift @word;

	my $x = 0;
	until ( $x == $pre ) {
		push @string, "_";
		$x++;
	}

	foreach my $w ( @word ) {
		push @string, "$w";
	}

	my $y = 0;
	until ( $y == $post ) {
		push @string, "_";
		$y++;
	}

	my $max = $#string - $post;
	my @pron = ();

	# Build feature vector and call walk tree to get prediction
	my $i = 0;
	foreach my $char ( @string ) {

		# Character must have a represenation in cart tree!	CT 111101
		if ( $char =~ /($MTM::Vars::graphemesInCart|_)/ ) {

			# Get sublist
			if ( $i > $pre-1 && $i < $max+1 ) {
				my @featVect = @string[$i-$pre..$i+$post];

				# UNTIL ENGLISH TREE IS BUILT!!	CT 120619
				if ( $domain =~ /eng/ ) {
					$domain = 'swe';
				}

				# Get tree of current grapheme
				my @cartTree = $ltsTree{ $domain }{ $char };

				# Find phone
				my $predictedPhone = &walkTree( \@cartTree, \@featVect );

				$predictedPhone =~ s/_/ /g;

				push @pron, $predictedPhone;

				# print STDERR "\n";
				# print STDERR "featVect:		@featVect\n";
				# print STDERR "char:			$char\n";
				# print STDERR "predictedPhone:		$predictedPhone\n";
				# print STDERR "phone list:		@pron\n";
				# print STDERR "\n";

			}
		} else {
			# print STDERR "No represenation in cart tree, returning schwa: $char\n";
			push @pron, 'ë';
		}
		$i++;
	}

	my $pron = join' ', @pron;

	# Fixes
	$pron =~ s/ i s k t$/ i s t/;
	$pron =~ s/ i s k t s$/ i s t s/;
	$pron =~ s/ rn s$/ rn rs/;


	$pron =~ s/eps/ /g;
	$pron =~ s/^ +//;
	$pron =~ s/ +$//;
	$pron =~ s/ +/ /g;

	$pron =~ s/rs h/rs/g;
	$pron =~ s/([\'\"])u3/$1u/;
	$pron =~ s/([\'\"])i3/$1i/;

	if ( $pron =~ /^ *$/ ) {
		$pron = "sil";
	}

	# Remove geminate final phones	CT 210824
	$pron =~ s/ ([^ ]+) \1$/ $1/g;

	# print STDERR "Returning\t$pron\n";


	return $pron;
}
#*********************************************************#
sub doStress {
	my $word = shift;
	my $pron = shift;
	my $domain = shift;

	# print STDERR "doStress\t$word\t$domain\t$pron\n";

	#$pron = &setStress1 ( $word, $pron, $domain );
	$pron = &setStress2 ( $word, $pron, $domain );


	# print STDERR "After doStress\t$word\t$domain\t$pron\n";

	return $pron;
}
#*********************************************************#
# Data-driven stress assignment
#*********************************************************#
sub setStress2 {
	my $word = shift;
	my $pron = shift;
	my $domain = shift;

	$word = &MTM::Case::makeLowercase( $word );
	#print STDERR "setStress2:\t$word\t$pron\t$domain\n";

	$word =~ s/[^aouåeiyäöøæéèëêíìïîáàâóòôúùüûýÿbcdfghjklmnpqrstvwxzñ]//g;
	$domain =~ s/^(sv_se|default)$/swe/;
	$domain =~ s/^en_uk$/eng/;
	# print STDERR "WORD2: $word	$pron\n";


	# Remove delimiters and digits
	$word =~ s/[\.\,\:\;\(\)\?\!\d]//g;

	$domain =~ s/default/swe/;

	my $firstCh = 10;
	my $lastCh = 10;
	my $firstVo = 5;
	my $lastVo = 5;
	my @vector = ();
	my @featVect = ();

	my @firstWordList = ();
	my @lastWordList = ();
	my @firstVowelList = ();
	my @lastVowelList = ();

	# Number of characters
	my $nChars  = length( $word );

	# Number of vowels
	my $tmpWord = $word;
	$tmpWord =~ s/[$MTM::Vars::consonant]//g;

	my $nVowels = length( $tmpWord );
	my @tmpWord = split//, $tmpWord;

	my @word = split//, $word;

	my $wordLength = length( $word );
	my $vowelLength = length( $tmpWord );

	# Push character 0-10 to list
	for ( my $i = 0; $i < $firstCh; $i++ ) {
		if ( $i < $wordLength ) {
			push @firstWordList, $word[ $i ];
		} else {
			push @firstWordList, "";
		}
	}

	# Push character -10 - $# to list
	my @revWord = reverse( @word );
	for ( my $i = 0; $i < $lastCh; $i++ ) {
		if ( $i < $wordLength ) {
			push @lastWordList, $revWord[ $i ];
		} else {
			push @lastWordList, "";
		}
	}
	@lastWordList = reverse( @lastWordList );


	# Push vowel 0-5 to list
	for ( my $i = 0; $i < $firstVo; $i++ ) {
		if ( $i < $vowelLength ) {
			push @firstVowelList, $tmpWord[ $i ];
		} else {
			push @firstVowelList, "";
		}
	}

	# Push vowel -5 - $# to list
	my @revVowel = reverse( @tmpWord );
	for ( my $i = 0; $i < $lastVo; $i++ ) {
		if ( $i < $vowelLength ) {
			push @lastVowelList, $revVowel[ $i ];
		} else {
			push @lastVowelList, "";
		}
	}
	@lastVowelList = reverse( @lastVowelList );

	# Combine lists to @featVect
	push @featVect, @firstWordList;
	push @featVect, @lastWordList;
	push @featVect, @firstVowelList;
	push @featVect, @lastVowelList;
	push @featVect, $nChars;
	push @featVect, $nVowels;

	# print STDERR "\nfirstWordList\t@firstWordList\n";
	# print STDERR "lastWordList\t@lastWordList\n";
	# print STDERR "firsVowelListtWordList\t@firstVowelList\n";
	# print STDERR "lastVowelList\t@lastVowelList\n";
	# print STDERR "nChars\t$nChars\n";
	# print STDERR "nVowels\t$nVowels\n";


	# print STDERR "\n";
	# print STDERR "featVect:		@featVect\n";
	# print STDERR "word:			$word\n";
	# print STDERR "pron:	$pron\n";
	# print STDERR "\n";

	# TMP!!!	CT 130624
	$domain =~ s/name/swe/;
	$domain =~ s/eng/swe/;
#
#	if( exists( $stressTree{ $domain }{ "3" } )) {
#		print "TREE $domain\t1\t@featVect\n";
#		print "TREE $domain\t2\t@featVect\n";
#		print "TREE $domain\t3\t@featVect\n";
#	} else {
#		print "NO $domain\t1\t@featVect\n";
#		print "NO $domain\t2\t@featVect\n";
#		print "NO $domain\t3\t@featVect\n";
#	}

	# Get tree of current stress type
	my @cartTree = $stressTree{ $domain }{ "1" };
	my $stress1 = &walkTree( \@cartTree, \@featVect );

	@cartTree = $stressTree{ $domain }{ "2" };
	my $stress2 = &walkTree( \@cartTree, \@featVect );

	@cartTree = $stressTree{ $domain }{ "3" };
	my $stress3 = &walkTree( \@cartTree, \@featVect );

	# print STDERR "PredictedStress: $word\t$stress1\t$stress2\t$stress3\n";

	# Save missed primary stress: PredictedStress: hotelsers	-1	-1	3		CT 130626
	if ( $stress1 == -1 && $stress2 == -1 && $stress3 > 0 ) {
		# print STDERR "PredictedStress: $word\t$stress1\t$stress2\t$stress3\n";
		$stress2 = 1;
	}

	my $dummy;
	# Assign stress to closest stressable phoneme
	if ( $stress1 ne -1 ) {
		$pron  = &assignStress( $word, $pron, $stress1, '1' );
	} else {
		$pron = &assignStress( $word, $pron, $stress2, '2' );
		# $pron = &assignStress( $word, $pron, $stress3, '3' );
		# Set secondary stress to next vowel
		( $pron, $dummy ) = &stressToFirstVowel( $pron, '3' );
		# print STDERR "Secondary stress set to next vowel: $pron\n";
	}

	# processpårning
	$pron =~ s/\"ë(.+\`)/\"e$1/;

	# secondary stress at schwa, but there are more vowels in rc:	spindelskivling	CT 210824
	$pron =~ s/\`ë (.+) (.2:)/ë $1 \`$2/;

	# Accent II on last syllabe, set accent I to first vowel		CT 210929
	#if( $pron =~ s/\"(($stressable)[^($stressable)]*)/$1/ ) {
	#	( $pron, $dummy ) = &stressToFirstVowel( $pron, '1' );
	#}


	# CT 130625
	$pron =~ s/ä3: r a r [\'\"]ë/\'ä3: r a r ë/;
	$pron =~ s/ä3: r \'a s t/\'ä3: r a s t/;
	$pron =~ s/d l$/d ë l/;
	$pron =~ s/\'ë n s/\'e n s/;
	$pron =~ s/rt s$/rt rs/;								# retroflexation
	$pron =~ s/\'(.+ e3 [^\s]+) (.2:)/$1 \'$2/;					# acefals
	$pron =~ s/e2: r \'([ai])/\'e2: r $1/;						# abandonnerades
	$pron =~ s/\'i a2:/i \'a2:/;							# abaxials
	$pron =~ s/\'(.+) sj o2: (n|n ë rn a|n ë rs)$/$1 sj \'o2: $2/;			# abalienationers
	$pron =~ s/i s (a|a s|a n|a n s|o r|o r s|o rn a|o rn a s)$/\"i s \`$1/;	# abedissa
	$pron =~ s/e2: r i ng a $ rn \'a s/\'e2: r i ng a rn a s/;			# accelereringarnas
	$pron =~ s/\'u3 e2:/u3 \'e2:/;							# accentuerad
	$pron =~ s/t \'ë t$/t \'e2: t/;							# acceptabilitet
	# 210824 $pron =~ s/ s s$/ s/;								# blåtts
	# 210824 $pron =~ s/ d \$ d/ \$ d/;							# blödde
	#$pron =~ s/([\'\"])ë/$1e/;							# processpårning	CT 140806

	# Fallback if schwa has main stress	CT 130626
	if ( $pron =~ /([\'\"])ë/ ) {
		my $t = $1;
		$pron =~ s/$t//g;
		$t =~ s/\'/1/;
		$t =~ s/\"/2/;
		( $pron, $dummy ) = &stressToFirstVowel( $pron, $t );
	}

	$pron =~ s/\`(.+\')/$1/;							# sec stress before accent I
	$pron =~ s/\'(.+\`)/\"$1/;							# accent I and sec stress
	$pron =~ s/[\"\'](.+)\`?(.+)\'/$1$2\'/;					# main stress and sec stress before accent I
	$pron =~ s/\"($stressable) ([^(?:$stressable)]+)$/\'$1 $2/;		# accent II at last syllable --> accent I
	$pron =~ s/\`(.+)\"/$1\'/;							# sec stress before accent II --> accent I
	$pron =~ s/[\"\'\`]\"/\"/g;							# CT 161123


	# No ultima at short vowel if penultima exists	CT 130625
	if ( $pron !~ /2:$/ ) {
		$pron =~ s/(^| )($stressable) ([^($stressable)]+) \'($stressable)$/$1 \'$2 $3 $4/;
	}


	$pron =~ s/eps/ /g;

	$pron =~ s/^ +//;
	$pron =~ s/ +$//;
	$pron =~ s/ +/ /g;

	if ( $pron =~ /^ *$/ ) {
		$pron = "sil";
	}

	# Backup if no stress were set	240514
	if( $pron !~ /[\"\']/ ) {
		$pron =~ s/($stressable)/\'$1/;
	}

	# print STDERR "PredictedStress: $word\t$stress1\t$stress3\t$pron\n";

	return $pron;
}
#*********************************************************#
# Assign stress to closest stressable phoneme
#
# test exists
#*********************************************************#
sub assignStress {
	my ( $orth, $pron, $stressLoc, $stressType ) = @_;

	my @orth = split//, $orth;
	my @pron = split/ /, $pron;

	my $orthLength = $#orth;
	my $stressSet = 0;

	# Stress is outside word, assign to first vowel
	# (if secondary stress, it will be set to first vowel after main stress)
	if ( $stressLoc > $orthLength ) {
		( $pron, $stressSet ) = &stressToFirstVowel( $pron, $stressType );
		if ( $stressSet == 1 ) {
			return $pron;
		}
	}

	# Find closest stressable phoneme
	( $pron, $stressSet ) = &stressToTarget( $orth, $pron, $stressLoc, $stressType );

	if ( $stressSet == 1 ) {
		return $pron;
	}


	# Last way out, set to first vowel
	( $pron, $stressSet ) = &stressToFirstVowel( $pron, $stressType );

	if ( $stressSet == 1 ) {
		return $pron;
	}

	# Fallback if the only vowel is schwa
	( $pron, $stressSet ) = &stressSchwa( $pron, $stressType );

	return $pron;
}
#*********************************************************#
# Fallback if the only vowel is schwa
#
# test exists
#*********************************************************#
sub stressSchwa {
	my ( $pron, $stressType ) = @_;

	$stressType =~ s/^1$/\'/;
	$stressType =~ s/^2$/\"/;
	$stressType =~ s/^3$/\`/;

	if (
		$pron =~ /^([^($stressable)]*)\ë([^($stressable)]*)$/
	) {
		$pron =~ s/(\b)\ë(\b)/$1$stressType\ë$2/;
		$pron =~ s/\ë/e/;

		return( $pron, '1' );
	}

	# Else return 0
	return ( $pron, '0' );
}
#*********************************************************#
# Set stress to target position (counting phones, not vowels)
#
# test exists
#*********************************************************#
sub stressToTarget {
	my ( $orth, $pron, $stressLoc, $stressType ) = @_;
	my $stressSet = 0;

	# print STDERR "\nstressToTarget\n\tOrth: $orth\n\tPron: $pron\n\tLoc: $stressLoc\n\tType: $stressType\n";
	# print  "\nstressToTarget\n\tOrth: $orth\n\tPron: $pron\n\tLoc: $stressLoc\n\tType: $stressType\n";

	my @orth = split//, $orth;
	my @pron = split/ /, $pron;

	$stressType =~ s/^1$/\'/;
	$stressType =~ s/^2$/\"/;
	$stressType =~ s/^3$/\`/;


	# Find closest stressable phoneme
	# Same list element is stressable
	# Do not set main stress at schwa	CT 130626
	if ( $stressType =~ /^[\'\"12]$/ ) {

		# Set stress to 1 if $stressLoc is beyond the phone list.	CT 130711
		if ( $stressLoc > $#pron ) {
			$stressLoc = 1;
		}

		if ( $stressLoc <= $#pron && $pron[ $stressLoc ] =~ s/^($stressable)$/$stressType$1/ && $pron[ $stressLoc ] ne 'ë' ) {
			$pron = join' ', @pron;
			# print STDERR "RETURNING 1 /$pron/ after $stressType set at $stressLoc\n";
			return ( $pron, '1' );
		}
	} else {
		if ( $pron[ $stressLoc ] =~ s/^($stressable)$/$stressType$1/ ) {
			$pron = join' ', @pron;
			# print STDERR "RETURNING 1 /$pron/ after $stressType set at $stressLoc\n";
			return ( $pron, '1' );
		}
	}

	# Location is 0, set to first stressable
	if ( $stressLoc eq '0' ) {
		my $dummy;
		( $pron, $dummy) = &stressToFirstVowel( $pron, $stressType );
		# print STDERR "RETURNING 2 /$pron/ after $stressType set at $stressLoc\n";
		return ( $pron, '1' );
	}

	# Look to the right
	# $#pron > $stressLoc &&	CT 130701
	if ( $#pron > $stressLoc && $pron[ $stressLoc + 1 ] =~ s/^($stressable)$/$stressType$1/ ) {
		$pron = join' ', @pron;
		# print STDERR "RETURNING 3 /$pron/ after $stressType set at $stressLoc + 1\n";
		return ( $pron, '1' );
	}

	# print STDERR "Orth\t$orth\tPron\t@pron\nLoc\t$stressLoc\nType\t$stressType\n\n";

	# Look to the left
	# $stressLoc > 0 &&	CT 130701
	if ( $stressLoc > 0 && $pron[ $stressLoc - 1 ] =~ s/^($stressable)$/$stressType$1/ ) {
		$pron = join' ', @pron;
		# print STDERR "RETURNING 4 /$pron/ after $stressType set at $stressLoc - 1\n";
		return ( $pron, '1' );
	}

	# Look two slots to the left
	# $stressLoc > 1 &&	CT 130701
	if ($stressLoc > 1 &&  $pron[ $stressLoc - 2 ] =~ s/^($stressable)$/$stressType$1/ ) {
		$pron = join' ', @pron;
		# print STDERR "RETURNING 5 /$pron/ after $stressType set at $stressLoc - 1\n";
		return ( $pron, '1' );
	}

	return ( $pron, $stressSet );
}
#*********************************************************#
# Set stress to first vowel
#
# test exists
#*********************************************************#
sub stressToFirstVowel {
	my $pron = shift;
	my $stressType = shift;

	my @pron = split/ /, $pron;


	# Accent I - set to first stressable in word
	if ( $stressType =~ /[1\']/ ) {

		$stressType =~ s/1/\'/;
		foreach my $p ( @pron ) {
			# Do not set main stress to schwa
			if ( $p =~ s/^($stressable)$/$stressType$1/ && $p ne 'ë' ) {
				my $newPron = join' ', @pron;
				$newPron =~ s/[\"\`]//g;
				return ( $newPron, '1' );
			}
		}

	# Accent II - set to first stressable in word
	} elsif ( $stressType =~ /[2\"]/ ) {
		$stressType =~ s/2/\"/;
		foreach my $p ( @pron ) {
			# Do not set main stress at schwa	CT 130626
			if ( $p =~ s/^($stressable)$/$stressType$1/ && $p ne 'ë' ) {
				my $newPron = join' ', @pron;

				# Set secondary stress at next vowel
				$stressType = '`';
				my $seenPrimaryStress = 0;
				foreach my $p ( @pron ) {
					if ( $seenPrimaryStress == 1 && $p =~ s/^($stressable)$/$stressType$1/ ) {
						my $newPron = join' ', @pron;
						return ( $newPron, '1' );
					}

					if ( $p =~ /\"/ ) {
						$seenPrimaryStress = 1;
					}

				}

				#return ( $newPron, '1' );
			}
		}
	} elsif ( $stressType =~ /[3\`]/ ) {
		$stressType =~ s/3/\`/;
		my $seenPrimaryStress = 0;
		foreach my $p ( @pron ) {
			if ( $seenPrimaryStress == 1 && $p !~ /[\"\']/ && $p =~ s/^($stressable)$/$stressType$1/ ) {
				my $newPron = join' ', @pron;
				$newPron =~ s/\`(.+)\`/\`$1/;
				return ( $newPron, '1' );
			}
			if ( $p =~ /[\'\"]/ ) {
				$seenPrimaryStress = 1;
			}
		}
	}

	# print "RETURN $pron\n";

	return ( $pron, '0' );
}
#*********************************************************#
sub walkTree {

	my ( $cartTree ) = shift;
	my ( $featVect ) = shift;

	# Deref @cartTree and @featVect
	my @cartTree = @{$cartTree};
	my @featVect = @{$featVect};

	my $match = 0;

	my $current = $cartTree[0];

	my @current = @{$current};

	# Only one slot in tree - grab phone!
	if ( $#current == 0 ) {
		# If in stressTree, 
		return $current[0];
	}

	# Structure of the tree:
	# [[context pattern] yes-tree no-tree]
	my $question = $current[0];
	my @yesTree = $current[1];
	my @noTree = $current[2];

	my @question = @{$question};	# deref
	my $context = $question[0];
	my $pattern = $question[1];


#		my $n = 0;
#		foreach my $v ( @featVect ) {
#		# print STDERR "\t$n\t$v\n";
#			$n++;
#		}
#	# print STDERR "Vector: @featVect\n";
#	# print STDERR "Char: $featVect[4]\t";		# Current character is always 4 in @featVect
#	# print STDERR "Context: $context\t";
#	# print STDERR "Pattern: $pattern\t";
#	# print STDERR "Features: @featVect\t";
#	# print STDERR "Look at: $featVect[ $context ]\n";

	if ( $featVect[$context] =~ /$pattern/ ) {
		$match = 1;
	}

	# If match, continue with yes-tree
	if ( $match ) {
		&walkTree( \@yesTree, \@featVect );
	} else {
		&walkTree( \@noTree, \@featVect );
	}
	# return here causes problems
}
#*********************************************************#
1;
