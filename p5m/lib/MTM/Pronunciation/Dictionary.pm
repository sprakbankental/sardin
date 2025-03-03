package MTM::Pronunciation::Dictionary;

#**************************************************************#
# Dictionary
#
# Language	sv_se
#
# Rules for getting pronunciations from dictionaries.
# 
# Return: pronunciation
#
# tests exist
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

#*******************************************#
# Dictionary lookup
sub dictionaryLookup {

	my $string = shift;
	my $case = shift;
	my $pos = shift;
	my $input_lang = shift;

	### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
	# 231122 Needed for e.g. ☒
#	if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $string !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|en_special_character_list)+$/ ) {
# 240513		utf8::encode( $string );
#	}
	#********************
	# Get case(s)

	#my $non_latin_chars = join("", $string =~ /\P{Script=Latin}+/g);
	#print "Non-Latin characters: $non_latin_chars\n";

	$case = &MTM::Case::getCase( $case );
	my @case = @$case;

	unshift @case, 'original';

	foreach my $c ( @case ) {

		
		### TODO: Valid characters
		$c =~ s/ÿ/y/g;
		$c =~ s/β/ss/g;

		$string =~ s/ÿ/y/g;
		$string =~ s/β/ss/g;

		my $convertedString = $string;
		if ( $c eq 'lc' ) {
			$convertedString = &MTM::Case::makeLowercase( $string );
		} elsif ( $c eq 'ucf' ) {
			$convertedString = &MTM::Case::makeUppercaseFirst( $string );
		} elsif ( $c eq 'uc' ) {
			$convertedString = &MTM::Case::makeUppercase( $string );
		}

		### TODO Now current case is looked up in all lexicons first, instead of being looked up in all cases in prioritized lexicon first.
		### Is this a problem?

		# NST Lexicon
		if( $MTM::Vars::use_dict eq 'NST' ) {

			# Special characters, e.g. Greek letters
			if ( exists( $MTM::Legacy::Lists::sv_special_character{ $convertedString } )) {
				my( $letters, $pron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $convertedString };
				# print STDERR "Returning special character: $pron\n";
				my $ret = "$pron\tNN\tswe\tswe\t$convertedString\t-";
				return( $ret );

			# Lookup NST
			} elsif ( exists( $MTM::Legacy::Lists::sv_nst_dict{ $convertedString } )) {
				# print STDERR "Returning NST $pos: $c\t$convertedString\t$MTM::Legacy::Lists::sv_nst_dict{ $convertedString }\n";
				$pos =~ s/ .+$//;
				my $result = &posMatch( $MTM::Legacy::Lists::sv_nst_dict{ $convertedString }, $pos );

				return( $result );
			}		

		# English
		} elsif ( $MTM::Vars::lang eq 'eng' || $input_lang eq 'eng' ) {

			# Special characters, e.g. Greek letters
			if ( exists( $MTM::Legacy::Lists::en_special_character{ $convertedString } )) {
				my( $letters, $pron ) = split/\t+/, $MTM::Legacy::Lists::en_special_character{ $convertedString };
				# print STDERR "Returning special character: $pron\n";
				my $ret = "$pron\tNN\teng\teng\t$convertedString\t-";
				return( $ret );

			# Lookup English
			} elsif ( exists( $MTM::Legacy::Lists::en_braxen{ $convertedString } )) {
				# print STDERR "Returning English: $c\t$convertedString\t$MTM::Legacy::Lists::en_braxen{ $convertedString }\n";

				my $result = &posMatch( $MTM::Legacy::Lists::en_braxen{ $convertedString }, $pos );
				my @result = split/\t/, $result;
				$result[3] =~ s/^-$/eng/;
				$result = join"\t", @result;
				return( $result );

			# Name
			} elsif ( exists( $MTM::Legacy::Lists::sv_braxen{ $convertedString } )) {
			
				# print STDERR "Returning name: $MTM::Legacy::Lists::sv_braxen{ $convertedString }\n";

				my $result = &posMatch( $MTM::Legacy::Lists::sv_braxen{ $convertedString }, $pos );
				my @result = split/\t/, $result;
				$result[3] =~ s/^-$/eng/;
				$result = join"\t", @result;
				return( $result );

			# Acronym
			} elsif ( exists( $MTM::Legacy::Lists::en_acronym{ $convertedString } )) {
				my $ret = $MTM::Legacy::Lists::en_acronym{ $convertedString } . "\t-\tacronym";

				# print STDERR "Returning acronym: $ret\n";
				return( $ret );
			} else {
				# print STDERR "No match in dict for:\t$convertedString\n";
			}
		#*******************************************************#
		# Swedish and world
		} else {
			# Special characters, e.g. Greek letters
			if ( exists( $MTM::Legacy::Lists::sv_special_character{ $convertedString} )) {
				my( $letters, $pron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $convertedString };
				# print STDERR "Returning special character: $pron\n";
				my $ret = "$pron\tNN\tswe\tswe\t$convertedString\t-";
				return( $ret );

			# Swedish
			} elsif( exists( $MTM::Legacy::Lists::sv_braxen{ $convertedString } )) {
				# print STDERR "Returning sv_braxen: $convertedString	$MTM::Legacy::Lists::sv_braxen{ $convertedString }\n";

				my $result = &posMatch( $MTM::Legacy::Lists::sv_braxen{ $convertedString }, $pos );
				my @result = split/\t/, $result;
				$result[3] =~ s/^-$/swe/;
				$result = join"\t", @result;
				return( $result );

			# English
			} elsif ( exists( $MTM::Legacy::Lists::en_braxen{ $convertedString } )) {
				# print STDERR "Returning en_braxen: $convertedString	$MTM::Legacy::Lists::en_braxen{ $convertedString }\n";

				my $result = &posMatch( $MTM::Legacy::Lists::en_braxen{ $convertedString }, $pos );
				my @result = split/\t/, $result;
				$result[3] =~ s/^-$/eng/;
				$result = join"\t", @result;
				return( $result );

			# Acronym
			} elsif ( exists( $MTM::Legacy::Lists::sv_acronym{ $convertedString } )) {
				my $ret = $MTM::Legacy::Lists::sv_acronym{ $convertedString } . "\t-\tacronym";

				# print STDERR "Returning acronym: $ret\n";
				return( $ret );

			# Extra lexicon
			} elsif ( exists( $MTM::Legacy::Lists::sweDictExtra{ $convertedString } )) {

				# print STDERR "Returning extra: $MTM::Legacy::Lists::sweDictExtra{ $convertedString }\n";

				return( $MTM::Legacy::Lists::sweDictExtra{ $convertedString } );



			} else {
				# print STDERR "No match in dict for:\t$convertedString\n";
			}
		}
	}

	# 170515
	return( '-' );

}
#*******************************************#
sub posMatch {
	my( $results, $pos ) = @_;
	$pos =~ s/( -)+$//g;
	$results =~ s/^<SPLIT>//;
	my @results = split/<SPLIT>/, $results;

	foreach my $r ( @results ) {
		my @r = split/\t/, $r;
		if ( $r[1] =~ /^$pos/i ) {
			return $r;
		}
	}
	return $results;
}
#*******************************************#
1;
