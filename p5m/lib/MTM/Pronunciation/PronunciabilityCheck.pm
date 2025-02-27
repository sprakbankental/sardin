package MTM::Pronunciation::PronunciabilityCheck;

#**************************************************************#
# PronunciabilityCheck
#
# Language	sv_se
#
# Rules for checking if a word orthography is pronouncable or not.
#
# Return: 1/0
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
sub checkPronunciability {	# return: 1/0

	my $string = shift;

	my $pronunciability = 1;

	# print STDERR "\n---------------------\npronunciability\t$string\n";

	# Only cononants in string
	if ( $string =~ /^($MTM::Vars::consonant)+$/i ) {
		$pronunciability = 0;

	} else {

		# Hyphen-separated compound or multiword, check each part.
		my @string = split/[-\s]/,$string;
		my $prony = 1;
		foreach my $str ( @string ) {

			my $prony;

			# English
			if( $MTM::Vars::lang eq 'en' ) {
				$prony = &en_checkCluster( $str );

			# Swedish and world
			} else {
				$prony = &sv_checkCluster( $str );
			}

			if ( $prony == 0 ) {
				$pronunciability = 0;
			}
		}
	}

	# print STDERR "\nReturning pronunciability\t$pronunciability\n";

	return $pronunciability;

}
#*********************************************************************#
# sv_checkCluster								#
#*********************************************************************#
sub sv_checkCluster {

	my $string = shift;

	#print STDERR "checkCluster\t$string\n";

	if ( $string !~ /\w/ ) {
		return '0';
	}

	#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
		#if( $string =~ s/\x{C3BC}/ü/g ) { print "I $string\n"; }
		#if( $string =~ s/\x{00FC}/ü/g ) { print "I $string\n"; }
		## \x{2015}
	#}

	$string = &MTM::Case::makeLowercase( $string);

	my $pronunciability = 1;

	$string =~ s/($MTM::Vars::vowel|å|ä|ö|ü|é)($MTM::Vars::consonant)/$1 __SPLITTER__ $2/g;
	$string =~ s/($MTM::Vars::consonant)($MTM::Vars::vowel|å|ä|ö|ü|é)/$1 __SPLITTER__ $2/g;

	# print STDERR "checkCluster\tSplitted\t$string\n";

	my @string = split/ __SPLITTER__ /, $string;

	my $firstCluster = shift @string;


	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_medial_c)) { if( $k =~ /^m/ ) { print "MTM::Legacy::Lists::sv_medial_c\t$k\t$v\n"; }} exit;


	#----------------------------------------------------------#
	# Initial cluster
	#----------------------------------------------------------#
	### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
	if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $firstCluster !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
		utf8::encode( $firstCluster );
	}
	if (
		!( exists( $MTM::Legacy::Lists::sv_initial_c{ $firstCluster } ))
		&&
		!( exists( $MTM::Legacy::Lists::sv_initial_v{ $firstCluster } ))
		&&
		$firstCluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
		&&
		$firstCluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
	) {
		$pronunciability = 0;
	}

	# print STDERR "Initial\t$firstCluster\t$pronunciability\n";


	#----------------------------------------------------------#
	# Final cluster
	#----------------------------------------------------------#
	if ( $#string >= 0 && $pronunciability eq 1 ) {

		my $lastCluster = pop @string;

		### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
		if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $lastCluster !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
			utf8::encode( $lastCluster );
		}

		if (
			!( exists( $MTM::Legacy::Lists::sv_final_c{ $lastCluster } ))
			&&
			!( exists( $MTM::Legacy::Lists::sv_final_v{ $lastCluster } ))
			&&
			$lastCluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
		) {
			$pronunciability = 0;
		}

		# print STDERR "Final\t$lastCluster\t$pronunciability\n";
	}

	#----------------------------------------------------------#
	# Intermediate cluster
	#----------------------------------------------------------#
	if ( $#string >= 0 && $pronunciability eq 1 ) {

		foreach my $cluster (@string) {

			### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
			if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $cluster !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
				utf8::encode( $cluster );
			}


			if (
				!( exists( $MTM::Legacy::Lists::sv_medial_c{ $cluster } ))
				&&
				!( exists( $MTM::Legacy::Lists::sv_medial_v{ $cluster } ))
				&&
				$cluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
			) {
				$pronunciability = 0;
			}
				#print STDERR "NONO $cluster\n";

			# print STDERR "Medial\t$cluster\t$pronunciability\n";
		}
	}

	return $pronunciability;

}
#*********************************************************************#
# en_checkCluster								#
#*********************************************************************#
sub en_checkCluster {

	my $string = shift;

	# print STDERR "checkCluster\t$string\n";

	if ( $string !~ /\w/ ) {
		return '0';
	}

	#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
		#if( $string =~ s/\x{C3BC}/ü/g ) { print "I $string\n"; }
		#if( $string =~ s/\x{00FC}/ü/g ) { print "I $string\n"; }
		## \x{2015}
	#}

	$string = &MTM::Case::makeLowercase( $string);

	my $pronunciability = 1;

	$string =~ s/($MTM::Vars::vowel|å|ä|ö|ü|é)($MTM::Vars::consonant)/$1 __SPLITTER__ $2/g;
	$string =~ s/($MTM::Vars::consonant)($MTM::Vars::vowel|å|ä|ö|ü|é)/$1 __SPLITTER__ $2/g;

	# print STDERR "checkCluster\tSplitted\t$string\n";

	my @string = split/ __SPLITTER__ /, $string;

	my $firstCluster = shift @string;


	# while(my($k,$v)=each(%MTM::Legacy::Lists::en_medial_c)) { print "MTM::Legacy::Lists::en_medial_c\t$k\t$v\n"; }


	#----------------------------------------------------------#
	# Initial cluster
	#----------------------------------------------------------#
	if (
		!( exists( $MTM::Legacy::Lists::en_initial_c{ $firstCluster } ))
		&&
		!( exists( $MTM::Legacy::Lists::en_initial_v{ $firstCluster } ))
		&&
		$firstCluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
		&&
		$firstCluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
	) {
		$pronunciability = 0;
	}

	# print STDERR "Initial\t$firstCluster\t$pronunciability\n";


	#----------------------------------------------------------#
	# Final cluster
	#----------------------------------------------------------#
	if ( $#string >= 0 && $pronunciability eq 1 ) {

		my $lastCluster = pop @string;

		if (
			!( exists( $MTM::Legacy::Lists::en_final_c{ $lastCluster } ))
			&&
			!( exists( $MTM::Legacy::Lists::en_final_v{ $lastCluster } ))
			&&
			$lastCluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
		) {
			$pronunciability = 0;
		}

		# print STDERR "Final\t$lastCluster\t$pronunciability\n";
	}

	#----------------------------------------------------------#
	# Intermediate cluster
	#----------------------------------------------------------#
	if ( $#string >= 0 && $pronunciability eq 1 ) {

		foreach my $cluster (@string) {

			if (
				!( exists( $MTM::Legacy::Lists::en_medial_c{ $cluster } ))
				&&
				!( exists( $MTM::Legacy::Lists::en_medial_v{ $cluster } ))
				&&
				$cluster !~ /^($MTM::Vars::vowel|$MTM::Vars::consonant)$/
			) {
				$pronunciability = 0;
			}
				#print STDERR "NONO $cluster\n";

			# print STDERR "Medial\t$cluster\t$pronunciability\n";
		}
	}

	return $pronunciability;

}
#********************************************************************#
1;
