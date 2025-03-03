package MTM::Legacy::Lists::Build;

use strict;
use warnings;

use parent qw(MTM::Legacy::Lists);
use Path::Class qw(file);

#***************************************************************************#
#
# 2021-02-15 JE Generalized methods for populating *Legacy variables* with 
# the contents of *Legacy DB text dumps*. These methods are
# maintained, and their backwards compatibility is ensured
# through tests in /t/legacydata
#
#***************************************************************************#
# 2021-02-15 JE Top method that will populate all Legacy variables (lists)
# by building them from their respective Legacy DB text dump
#
# * Note that more than one list is often built from one text dump 
# * This code does not store the populated lists anywhere, but keeps them 
# in memory during execution. In order to store ("encode"), 
# call store_lists() after build_lists has completed.
#
##### TODO Change name to *build_lagacy_variables*
sub build_lists {

	my $mtm = shift;
	my $legacypath = shift;
	##### 2020-01-06 JE move storing out
	# So we shouldn't be using this at all here, since storing is done 
	# separately now.
	# But we leave it in temporarily to facilitate the refactoring.
	# At the same time, we change create_hash to simply create the hash, 
	# with no storage
	my $SRLPATH = undef; 

	# my $legacypath = shift; # JE 2020-12-31 package scoped variable, but gets hidden by this declaraion
	#my $SRLPATH = shift; # JE 2020-12-31 will not be used in this sub

	print STDERR "LIST BUILDING START\t" . $mtm->now . "\n";	##### JE should use $mtm->fb to print

	my $file;


	# Package scoped variables declared at the top of the file and populated in the 
	# reader subs, so 
	# ( $multiwordList, %sweDictMultiword ) = &readMultiwordList; is instead just
	#&readMultiwordList($legacypath) or die;
	# use Data::Dumper; print STDERR Dumper \%sweDictMultiword; die;

	# These are package scoped variables, declared in the package header and 
	# accessible from the outisde
	&read_sv_abbreviation_list($legacypath) or die;
	&read_en_abbreviation_list($legacypath) or die;

	&read_sv_acronym($legacypath) or die;
	&read_en_acronym($legacypath) or die;

	# 2021-02-15 JE First to get a test
	&read_sv_alphabet( $legacypath ) or die;
	&read_en_alphabet( $legacypath ) or die;

	&read_sv_suffix($legacypath) or die;;
	&read_en_suffix($legacypath) or die;;

	&read_sv_special_character($legacypath) or die;;
	&read_en_special_character($legacypath) or die;;

	&read_sv_numeral_pron( $legacypath ) or die;
	&read_en_numeral_pron( $legacypath ) or die;

	&read_sv_domain( $legacypath ) or die;
	&read_en_domain( $legacypath ) or die;

	# JE 2012-12-31 Changed to calls to populate_hash (instead of create_hash) up to here
	# Want to see that this runs on CT's computer before proceeding
	# We're bound to find some undef variables as well on CT's code

	#&read_sv_dict_main($legacypath) or die;
	#&read_sv_dict_name($legacypath) or die;
	#&read_sv_dict_english($legacypath) or die;
	&read_sv_braxen($legacypath) or die;

	if( $MTM::Vars::use_dict eq 'NST' ) { &read_sv_nst_dict($MTM::Vars::nst_path) or die; }

	print STDERR "dict\n";

	# DecParts lists
	&read_sv_initial_dec_parts($legacypath) or die;;
	&read_sv_medial_dec_parts($legacypath) or die;;
	&read_sv_final_dec_parts($legacypath) or die;;

	# JE 2020-12-31 These returned hashes rather than hash refs, but the
	# globals in build are hash refs. So changed these to match.
#	&read_sv_initial_orth_dec_parts($legacypath) or die;
#	&read_sv_medial_orth_dec_parts($legacypath) or die;
#	&read_sv_final_orth_dec_parts($legacypath) or die;
#	&read_sv_final_orth_meta($legacypath) or die;

# 220512	&read_en_initial_dec_parts($legacypath) or die;;
# 220512	&read_en_medial_dec_parts($legacypath) or die;;
# 220512	&read_en_final_dec_parts($legacypath) or die;;

	# JE 2020-12-31 These returned hashes rather than hash refs, but the
	# globals in build are hash refs. So changed these to match.
#	&read_en_initial_orth_dec_parts($legacypath) or die;
#	&read_en_medial_orth_dec_parts($legacypath) or die;
#	&read_en_final_orth_dec_parts($legacypath) or die;
#	&read_en_final_orth_meta($legacypath) or die;

	print STDERR "decparts\n";

	&read_sv_initial_c($legacypath) or die;
	&read_sv_initial_v($legacypath) or die;
	&read_sv_medial_c($legacypath) or die;
	&read_sv_medial_v($legacypath) or die;
	&read_sv_final_c($legacypath) or die;
	&read_sv_final_v($legacypath) or die;

	&read_en_initial_c($legacypath) or die;
	&read_en_initial_v($legacypath) or die;
	&read_en_medial_c($legacypath) or die;
	&read_en_medial_v($legacypath) or die;
	&read_en_final_c($legacypath) or die;
	&read_en_final_v($legacypath) or die;

	# Parole to SUC conversion (PoS)
	#k = parole pos, v = suc pos
	$file = $legacypath . 'p2s.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p2s );

	# ERRROR: Not used: has a function with %multiword_tag (not used either)
	# SUC to Parole conversion (PoS)
	#k = suc pos, v = parole pos
	$file = $legacypath . 's2p.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::s2p );

	# Bigrams (PoS)
	# k = bigram, v = probability
	$file = $legacypath . 'p_bigram.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_bigram );

	# Trigrams (Pos)
	# k = trigram, v = probability
	$file = $legacypath . 'p_trigram.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_trigram );

	# Words with pos and probability. From suc lexicon.
	# k = orthography pos, $v = probability
	$file = $legacypath . 'p_wordprob.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_wordprob );

	# Words with pos and probability. From backup lexicon.
	# k = orthography pos, $v = probability
	$file = $legacypath . 'p_backup_wordprob.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_backup_wordprob );

	# Words with all possible pos tags. From suc lexicon.
	# k = orthography, $v = pos1 pos2 ...
	$file = $legacypath . 'p_wordtags.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_wordtags );
	# ERROR: This list is uncomplete, lacking key values (in its original form). Can't find the file the db is based on (p_tpblex.txt).
	# No catastrophe, just skip this file! Rebuild if necessary, but it doesn't do much anyway.
	# Words with all possible pos tags. From backup lexicon.
	# k = orthography, $v = pos1 pos2 ...
	#$file = $legacypath . 'p_backup_wordtags.txt';
	#our %p_backup_wordtags = &create_hash( $file, $SRLPATH );
	#while(my($k,$v)=each(%p_wordtags)) { print "p_wordtags\t$k\t$v\n"; } exit;

	# Final word parts (seems to be down to 3 characters) with pos and probability. From Main lexikon.
	# k = orthography pos tag, v = probability
	$file = $legacypath . 'p_main_suffix.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_suffix );

	#print STDERR "p_suffix\n";

	# Final word parts (seems to be down to 3 characters) with pos and probability. From backup lexikon.
	# k = orthography pos tag, v = probability
	$file = $legacypath . 'p_backup_suffix.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_backup_suffix );


	#print STDERR "p_backup_suffix\n";

	# Final word parts (seems to be down to 3 characters) with all possible pos tags. From main lexikon.
	# k = orthography, v = pos1 pos2 ...
	$file = $legacypath . 'p_main_suffixtag.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_suffixtag );


	#print STDERR "p_suffixtag\n";

	# Final word parts (seems to be down to 3 characters) with all possible pos tags. From backup lexikon.
	# k = orthography, v = pos1 pos2 ...
	$file = $legacypath . 'p_backup_suffixtag.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::p_backup_suffixtag );

	#while(my($k,$v) = each( %MTM::Legacy::Lists::p_backup_suffixtag )) { print "i $k\t$v\n"; } exit;

	#print STDERR "p_backup_suffixtag\n";

	print STDERR "LIST BUILDING END\t" . $mtm->now . "\n";	##### JE should use $mtm->fb to print

	return 1;
}
##*******************************************************************************************#
## CT 2020-12-28	Read multiword list
## JE 2020-12-31 Ammended to populate only
#sub readMultiwordList {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = file($path, 'sweDictMultiwordDB.txt');
##	my %sweMultiword = &create_hash( $file, $SRLPATH );
#	&populate_hash( $file, \%MTM::Legacy::Lists::sweDictMultiword );
#
#	#while(my($k,$v)=each(%sweDictMultiword)) { print "sweDictMultiword\t$k\t$v\n"; } exit;
#	$MTM::Legacy::Lists::multiwordList = join"|", keys( %MTM::Legacy::Lists::sweDictMultiword );
#
#	$MTM::Legacy::Lists::multiwordList =~ s/\|den (I|V)\|/\|/g;			# 191106 ugly fix.
#	$MTM::Legacy::Lists::multiwordList =~ s/([\{\}])/\\\$1/g;			# 190613 ugly fix.
#
#	# NB!! JE move out!
#	&srl_scalar_file( 'multiwordList.txt', $MTM::Legacy::Lists::multiwordList );
#
#	return 1;
#}
#*******************************************************************************************#
# CT 2020-12-07	Read acronym list
# JE 2020-12-31 Ammended to populate only
# JE 2020-12-31 Sets package scoped $sv_acronym_list, %sv_acronym 
sub read_sv_acronym {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_acronym.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_acronym );

	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_acronym)) { print "sv_acronym\t$k\t$v\n"; } exit;
	$MTM::Legacy::Lists::sv_acronym_list = join"|", keys( %MTM::Legacy::Lists::sv_acronym );

	#while(my($k,$v)=each(%MTM::Legacy::Lists::sweAcronym)){ print "AXCR $k\t$v\n"; }


	# NB!! JE move out!
	&srl_scalar_file( 'sv_acronym_list.txt', $MTM::Legacy::Lists::sv_acronym_list );

	return 1;
}
#*******************************************************************************************#
# CT 2020-12-07	Read acronym list
# JE 2020-12-31 Ammended to populate only
# JE 2020-12-31 Sets package scoped $en_acronym_list, %en_acronym 
sub read_en_acronym {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_acronym.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_acronym );

	#while(my($k,$v)=each(%MTM::Legacy::Lists::en_acronym)) { print "en_acronym\t$k\t$v\n"; } exit;
	$MTM::Legacy::Lists::en_acronym_list = join"|", keys( %MTM::Legacy::Lists::en_acronym );

	#while(my($k,$v)=each(%MTM::Legacy::Lists::sweAcronym)){ print "AXCR $k\t$v\n"; }


	# NB!! JE move out!
	&srl_scalar_file( 'en_acronym_list.txt', $MTM::Legacy::Lists::en_acronym_list );

	return 1;
}
#*******************************************************************************************#
# CT 2020-11-19	Read letter pronunciations
# JE 2020-12-31 Ammended to populate only
sub read_sv_alphabet {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_alphabet.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_alphabet );
	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_alphabet)) { print "sv_alphabet\t$k\t$v\n"; } exit;
	return 1;
}
#*******************************************************************************************#
# Read English alphabet
sub read_en_alphabet {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_alphabet.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_alphabet );
	return 1;
}
#*******************************************************************************************#
# CT 2021-12-01	Read NST lexicon
sub read_sv_nst_dict {
	my $path = shift or die "Missing path!";

	# k = orthography, $v = pronunciation
	my $file = $path . '/sv_nst_dict_utf8.txt';
	my $addon = $path . '/sv_nst_dict_addon.txt';

	%MTM::Legacy::Lists::sv_nst_dict = ();

	# Read NST lexicon
	## no critic (InputOutput::RequireBriefOpen)
	open my $fh_nst, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
	## use critic
	print STDERR "Reading sv_nst_dict\n";
	while(<$fh_nst>){
		chomp;
		s/\r//g;
		next if $. == 1;
		my $line = $_;
		#print OUT "$line\n";
		my @line = split/\;/, $line;
		next if $line[7] eq 1;	# Garbage
		my $key = $line[0];

		# posmorph
		my $pos = $line[1];
		my $morph = $line[2];
		$pos =~ s/^PM\|.+$/PM/;
		$morph =~ s/\|+/\|/g;
		$morph =~ s/^\|+//g;
		$morph =~ s/\|+/ /g;
		my $posmorph = "$pos $morph";
		#$posmorph = MTM::Legacy::cleanBlanks( $posmorph );
		$posmorph =~ s/^PM$/PM NOM/g;
		$posmorph =~ s/ (MAS|FEM)$//;

		# lang
		my $ortlang = &MTM::Case::makeLowercase( $line[6] );
		my $pronlang = &MTM::Case::makeLowercase( $line[14] );

		my $val = "$line[11]\t$posmorph\t$ortlang\t$pronlang\t$line[3]\t$line[50]";

		if( exists( $MTM::Legacy::Lists::sv_nst_dict{ $key })) {
			if( $MTM::Legacy::Lists::sv_nst_dict{ $key } ne $val ) {
				$MTM::Legacy::Lists::sv_nst_dict{ $key } .= '<SPLIT>' . $val;
			}
		} else {
			$MTM::Legacy::Lists::sv_nst_dict{ $key } = $val;
		}
	}
	close $fh_nst;
	
	# Read NST lexicon
	## no critic (InputOutput::RequireBriefOpen)
	open my $fh_addon, '<:encoding(UTF-8)', $addon or die "Cannot open $addon: $!\n";
	## no critic
	
	print STDERR "Reading sv_nst_dict\n";
	while(<$fh_addon>){
		chomp;
		s/\r//g;
		next if $. == 1;
		my $line = $_;
		#print OUT "$line\n";
		my @line = split/\;/, $line;
		next if $line[7] eq 1;	# Garbage
		my $key = $line[0];

		# posmorph
		my $pos = $line[1];
		my $morph = $line[2];
		$pos =~ s/^PM\|.+$/PM/;
		$morph =~ s/\|+/\|/g;
		$morph =~ s/^\|+//g;
		$morph =~ s/\|+/ /g;
		my $posmorph = "$pos $morph";
		#$posmorph = &MTM::Legacy::cleanBlanks( $posmorph );
		$posmorph =~ s/^PM$/PM NOM/g;
		$posmorph =~ s/ (MAS|FEM)$//;

		# lang
		my $ortlang = &MTM::Case::makeLowercase( $line[6] );
		my $pronlang = &MTM::Case::makeLowercase( $line[14] );

		my $val = "$line[11]\t$posmorph\t$ortlang\t$pronlang\t$line[3]\t$line[50]";

		if( exists( $MTM::Legacy::Lists::sv_nst_dict{ $key })) {
			if( $MTM::Legacy::Lists::sv_nst_dict{ $key } ne $val ) {
				$MTM::Legacy::Lists::sv_nst_dict{ $key } .= '<SPLIT>' . $val;
			}
		} else {
			$MTM::Legacy::Lists::sv_nst_dict{ $key } = $val;
		}
	}
	close $fh_addon;

	##### CT 0210015
	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";
	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/sv_nst_dict.srl", \%MTM::Legacy::Lists::sv_nst_dict, 0);
	
	return 1;
}
#*******************************************************************************************#
# CT 2025-02-27	Read Braxen
sub read_sv_braxen {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_braxen.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_braxen );
	return 1;
}
#*******************************************************************************************#
# CT 2020-12-08	Read English lexicon
# JE 2021-01-06 Ammended to populate only
sub read_sv_dict_english {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_dict_english.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_dict_english );
	return 1;
}
# JE 2021-01-06 Ammended to populate only
#*************************************************************************#
sub read_sv_suffix {
	my $path = shift or die "Missing path!";
#	my ( $pathLexiconTools, $debug ) = @_;

	my $file = $path . 'sv_suffix.txt';

	open my $fh_SUFFIXLIST, '<', "$file" or die $!;
	while(<$fh_SUFFIXLIST>) {
		chomp;
		s/^\xEF\xBB\xBF//g;	# Remove BOM
		next if /^\#/;
		s/\r//;
		my ( $suffix, $suffixPron, $suffixPos ) = split/\t+/;
		$MTM::Legacy::Lists::sv_suffix{ $suffix } = $suffixPron;
		$MTM::Legacy::Lists::sv_suffix_pos{ $suffix } = $suffixPos;
	}
	close $fh_SUFFIXLIST;

	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";

	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/sv_suffix.srl", \%MTM::Legacy::Lists::sv_suffix, 0);
	$encoder->encode_to_file( "$SRLPATH/sv_suffix_pos.srl", \%MTM::Legacy::Lists::sv_suffix_pos, 0);

	$MTM::Legacy::Lists::sv_suffix_list = join"|", keys( %MTM::Legacy::Lists::sv_suffix );
	&srl_scalar_file( 'sv_suffix_list.txt', $MTM::Legacy::Lists::sv_suffix_list );

	return 1;
}
#*************************************************************************#
sub read_en_suffix {
	my $path = shift or die "Missing path!";
#	my ( $pathLexiconTools, $debug ) = @_;

	my $file = $path . 'en_suffix.txt';

	open my $fh_SUFFIXLIST, '<', "$file" or die $!;
	while(<$fh_SUFFIXLIST>) {
		chomp;
		s/^\xEF\xBB\xBF//g;	# Remove BOM
		next if /^\#/;
		s/\r//;
		my ( $suffix, $suffixPron, $suffixPos ) = split/\t+/;
		$MTM::Legacy::Lists::en_suffix{ $suffix } = $suffixPron;
		$MTM::Legacy::Lists::en_suffix_pos{ $suffix } = $suffixPos;
	}
	close $fh_SUFFIXLIST;

	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";

	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/en_suffix.srl", \%MTM::Legacy::Lists::en_suffix, 0);
	$encoder->encode_to_file( "$SRLPATH/en_suffix_pos.srl", \%MTM::Legacy::Lists::en_suffix_pos, 0);

	$MTM::Legacy::Lists::en_suffix_list = join"|", keys( %MTM::Legacy::Lists::en_suffix );
	&srl_scalar_file( 'en_suffix_list.txt', $MTM::Legacy::Lists::en_suffix_list );

	return 1;
}
#*******************************************************************************************#
# read_sv_special_character
sub read_sv_special_character {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = expansion	pronunciation
	my $file = $path . 'sv_special_character.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_special_character );

	$MTM::Legacy::Lists::sv_special_character_list = join"|", keys( %MTM::Legacy::Lists::sv_special_character );
	&srl_scalar_file( 'sv_special_character_list.txt', $MTM::Legacy::Lists::sv_special_character_list );
	my $encoder = Sereal::Encoder->new;

	return 1;
}
#*******************************************************************************************#
# read_en_special_character
sub read_en_special_character {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = expansion	pronunciation
	my $file = $path . 'en_special_character.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_special_character );

	$MTM::Legacy::Lists::en_special_character_list = join"|", keys( %MTM::Legacy::Lists::en_special_character );
	&srl_scalar_file( 'en_special_character_list.txt', $MTM::Legacy::Lists::en_special_character_list );
	my $encoder = Sereal::Encoder->new;

	return 1;
}
#*******************************************************************************************#
# CT 2020-12-01	Read compound parts
# JE 2021-01-06 Ammended to populate only
sub read_sv_initial_dec_parts {	# return: 1
	my $path = shift or die "Missing path!";

	my $file = $path . 'sv_initial_comp_parts.txt';
	my $file_1 = $path . 'sv_initial_dec_parts.txt';
	my $file_2 = $path . 'sv_initial_orth_dec_parts.txt';

	&populate_hash_2( $file, $file_1, $file_2, \%MTM::Legacy::Lists::sv_initial_dec_parts, \%MTM::Legacy::Lists::sv_initial_orth_dec_parts );

	$MTM::Legacy::Lists::sv_initial_dec_parts_list = join"|", keys( %MTM::Legacy::Lists::sv_initial_dec_parts );
	&srl_scalar_file( 'sv_initial_dec_parts_list.txt', $MTM::Legacy::Lists::sv_initial_dec_parts_list );

	#&populate_hash( $file, \%MTM::Legacy::Lists::sv_initial_orth_dec_parts );

	return 1;
}
#*******************************************************************************************#
# CT 2020-12-01	Read compound parts
# JE 2021-01-06 Ammended to populate only
sub read_sv_medial_dec_parts {	# return: 1
	my $path = shift or die "Missing path!";

	my $file = $path . 'sv_medial_comp_parts.txt';
	my $file_1 = $path . 'sv_medial_dec_parts.txt';
	my $file_2 = $path . 'sv_medial_orth_dec_parts.txt';

	&populate_hash_2( $file, $file_1, $file_2, \%MTM::Legacy::Lists::sv_medial_dec_parts, \%MTM::Legacy::Lists::sv_medial_orth_dec_parts );

	$MTM::Legacy::Lists::sv_medial_dec_parts_list = join"|", keys( %MTM::Legacy::Lists::sv_medial_dec_parts );
	&srl_scalar_file( 'sv_medial_dec_parts_list.txt', $MTM::Legacy::Lists::sv_medial_dec_parts_list );

	#&populate_hash( $file, \%MTM::Legacy::Lists::sv_medial_orth_dec_parts );

	return 1;
}
#*******************************************************************************************#
# CT 2020-12-01	Read compound parts
# JE 2021-01-06 Ammended to populate only
sub read_sv_final_dec_parts {	# return: 1
	my $path = shift or die "Missing path!";

	my $file = $path . 'sv_final_comp_parts.txt';

	my $file_1 = $path . 'sv_final_dec_parts.txt';
	my $file_2 = $path . 'sv_final_orth_meta.txt';
	my $file_3 = $path . 'sv_final_orth_dec_parts.txt';

	&populate_hash_3( $file, $file_1, $file_2, $file_3, \%MTM::Legacy::Lists::sv_final_dec_parts, \%MTM::Legacy::Lists::sv_final_orth_meta, \%MTM::Legacy::Lists::sv_final_orth_dec_parts );

	$MTM::Legacy::Lists::sv_final_dec_parts_list = join"|", keys( %MTM::Legacy::Lists::sv_final_dec_parts );
	&srl_scalar_file( 'sv_final_dec_parts_list.txt', $MTM::Legacy::Lists::sv_final_dec_parts_list );

	#&populate_hash( $file, \%MTM::Legacy::Lists::sv_final_orth_dec_parts );
	#&populate_hash( $file, \%MTM::Legacy::Lists::sv_final_orth_meta );

	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_final_orth_dec_parts)) { print "sv_final_dec_parts\t$k\t$v\n"; } exit;
	return 1;
}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_sv_initial_orth_dec_parts {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'sv_initial_orth_dec_parts.txt';
#	&populate_hash( $file, \%MTM::Legacy::Lists::sv_initial_orth_dec_parts );
#
#	return 1;
#}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_sv_medial_orth_dec_parts {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'sv_medial_orth_dec_parts.txt';
#	&populate_hash( $file, \%MTM::Legacy::Lists::sv_medial_orth_dec_parts );
#
#	return 1;
#}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_sv_final_orth_dec_parts {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'sv_final_orth_dec_parts.txt';
#	&populate_hash( $file, \%MTM::Legacy::Lists::sv_final_orth_dec_parts );
#
#	return 1;
#}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_sv_final_orth_meta {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'sv_final_orth_meta.txt';
#
#	&populate_hash( $file, \%MTM::Legacy::Lists::sv_final_orth_meta );
#
#	return 1;
#}
#*******************************************************************************************#
# CT 2020-12-01	Read compound parts
# JE 2021-01-06 Ammended to populate only
sub read_en_initial_dec_parts {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_initial_comp_parts.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_initial_dec_parts );

	$MTM::Legacy::Lists::en_initial_dec_parts_list = join"|", keys( %MTM::Legacy::Lists::en_initial_dec_parts );
	&srl_scalar_file( 'en_initial_dec_parts_list.txt', $MTM::Legacy::Lists::en_initial_dec_parts_list );

	&populate_hash( $file, \%MTM::Legacy::Lists::en_initial_orth_dec_parts );

	#print STDERR "MMM $MTM::Legacy::Lists::en_initial_dec_parts_list\n";
	#if ($MTM::Legacy::Lists::en_initial_dec_parts_list =~ /cytolysin/ ) { print STDERR "JA cytolysin\n"; }

	return 1;
}
#*******************************************************************************************#
# CT 2020-12-01	Read compound parts
# JE 2021-01-06 Ammended to populate only
sub read_en_medial_dec_parts {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_medial_comp_parts.txt';

	&populate_hash( $file, \%MTM::Legacy::Lists::en_medial_dec_parts );
	$MTM::Legacy::Lists::en_medial_dec_parts_list = join"|", keys( %MTM::Legacy::Lists::en_medial_dec_parts );
	&srl_scalar_file( 'en_medial_dec_parts_list.txt', $MTM::Legacy::Lists::en_medial_dec_parts_list );

	&populate_hash( $file, \%MTM::Legacy::Lists::en_medial_orth_dec_parts );

	return 1;
}
#*******************************************************************************************#
# CT 2020-12-01	Read compound parts
# JE 2021-01-06 Ammended to populate only
sub read_en_final_dec_parts {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_final_comp_parts.txt';

	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_dec_parts );
	$MTM::Legacy::Lists::en_final_dec_parts_list = join"|", keys( %MTM::Legacy::Lists::en_final_dec_parts );
	&srl_scalar_file( 'en_final_dec_parts_list.txt', $MTM::Legacy::Lists::en_final_dec_parts_list );

	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_orth_dec_parts );
	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_orth_meta );

#	while(my($k,$v)=each(%MTM::Legacy::Lists::en_final_dec_parts)) { print "en_final_dec_parts\t$k\t$v\n"; } exit;

	return 1;
}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_en_initial_orth_dec_parts {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'en_initial_orth_dec_parts.txt';
#	&populate_hash( $file, \%MTM::Legacy::Lists::en_initial_orth_dec_parts );
#
#	return 1;
#}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_en_medial_orth_dec_parts {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'en_medial_orth_dec_parts.txt';
#	&populate_hash( $file, \%MTM::Legacy::Lists::en_medial_orth_dec_parts );
#
#	return 1;
#}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_en_final_orth_dec_parts {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'en_final_orth_dec_parts.txt';
#	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_orth_dec_parts );
#
#	return 1;
#}
##*******************************************************************************************#
## CT 2020-12-01	Read compound parts
## JE 2021-01-06 Ammended to populate only
#sub read_en_final_orth_meta {	# return: 1
#	my $path = shift or die "Missing path!";
#	# k = orthography, $v = pronunciation
#	my $file = $path . 'en_final_orth_meta.txt';
#
#	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_orth_meta );
#
#	return 1;
#}
#*******************************************************************************************#
# Consonant and vowel clusters
sub read_sv_initial_c {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_initial_c.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_initial_c );

	return 1;
}
sub read_sv_initial_v {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_initial_v.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_initial_v );

	return 1;
}
sub read_sv_medial_c {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_medial_c.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_medial_c );

	return 1;
}
sub read_sv_medial_v {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_medial_v.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_medial_v );

	return 1;
}
sub read_sv_final_c {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_final_c.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_final_c );

	return 1;
}
sub read_sv_final_v {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_final_v.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_final_v );

	return 1;
}

sub read_en_initial_c {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_initial_c.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_initial_c );

	return 1;
}
sub read_en_initial_v {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_initial_v.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_initial_v );

	return 1;
}
sub read_en_medial_c {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_medial_c.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_medial_c );

	return 1;
}
sub read_en_medial_v {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_medial_v.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_medial_v );

	return 1;
}
sub read_en_final_c {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_final_c.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_c );

	return 1;
}
sub read_en_final_v {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_final_v.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_final_v );

	return 1;
}
#*******************************************************************************************#
# sv_domain
sub read_sv_domain {	# return: 1
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_domain.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::sv_domain );

	return 1;
}
#*******************************************************************************************#
# en_domain
sub read_en_domain {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_domain.txt';
	&populate_hash( $file, \%MTM::Legacy::Lists::en_domain );

	return 1;
}
#*******************************************************************************************#
# sv_numeral_pron
sub read_sv_numeral_pron {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'sv_numeral_pron.txt';

	&populate_hash( $file, \%MTM::Legacy::Lists::sv_numeral_pron );

	return 1;
}
#*******************************************************************************************#
# en_numeral_pron
sub read_en_numeral_pron {
	my $path = shift or die "Missing path!";
	# k = orthography, $v = pronunciation
	my $file = $path . 'en_numeral_pron.txt';

	&populate_hash( $file, \%MTM::Legacy::Lists::en_numeral_pron );

	return 1;
}
#*******************************************************************************************#
# Reads abbreviation list and creates two scalars.
# JE 2021-01-06 Ammended to populate only
sub read_sv_abbreviation_list {

	my $path = shift or die "Missing path!";


	# JE 2020-12-31
	# These are the same file names as the package scoped variables that we set as 
	# the end result of the call to this sub, which is confusing but works. Good 
	# thing to change later.
#	my (%sv_abbreviation, %sv_abbreviation_case);

	my $file = "sv_abbreviation.txt"; ##### (NB!) JE Temp hardcoded file

	## no critic (InputOutput::RequireBriefOpen)
	open my $fh_ABBREVIATION, '<', "$path$file" or die "Cannot open ABBREVIATION $path$file: $!";
	## use critic
	
	while( <$fh_ABBREVIATION> ) {

		next if /^\#/;
		next if $. == 1;

		s/^\xEF\xBB\xBF//g;	# Remove bom

		chomp;

		my( $orthographies, $expansions, $rule, $mayEndSentence, $caseSensitivity ) = split/\t+/;

		my @orthographies = split/\|/,$orthographies;
		my @expansions = split/\|/,$expansions;

		# Orthographies
		foreach my $orthography ( @orthographies ) {

			if (
				$caseSensitivity == 1
			) {
				# Case sensitive abbreviations in special list
				$orthography = quotemeta( $orthography );
				$MTM::Legacy::Lists::sv_abbreviation_case{ $orthography } = "$expansions\t$rule\t$mayEndSentence";

			} else {
				# Not case sensitive - add to list in all case possibilities
				my @caseOrth = &MTM::Case::caseLookup( $orthography, "caseInsensitive" );

				foreach my $caseOrth ( @caseOrth ) {
					$caseOrth = quotemeta( $caseOrth );
					$MTM::Legacy::Lists::sv_abbreviation{ $caseOrth } = "$expansions\t$rule\t$mayEndSentence";
				}
			}
		}
	}
	close $fh_ABBREVIATION;

	# Sort by length of abbreviation
	my @sv_abbreviation_list = sort { length($b) <=> length($a) || $a cmp $b } keys %MTM::Legacy::Lists::sv_abbreviation;
	my @sv_abbreviation_list_case = sort { length($b) <=> length($a) || $a cmp $b } keys %MTM::Legacy::Lists::sv_abbreviation_case;

	# Orthography lists
	$MTM::Legacy::Lists::sv_abbreviation_list = join'|',@sv_abbreviation_list;
	$MTM::Legacy::Lists::sv_abbreviation_list_case = join'|',@sv_abbreviation_list_case;

	#print "III $MTM::Legacy::Lists::sv_abbreviation_list\n"; exit;

	##### CT 0210015
	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";
	my $srl_file = $file;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;
	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/sv_abbreviation.srl", \%MTM::Legacy::Lists::sv_abbreviation, 0);
	$encoder->encode_to_file( "$SRLPATH/sv_abbreviation_case.srl", \%MTM::Legacy::Lists::sv_abbreviation_case, 0);

	&srl_scalar_file( 'sv_abbreviation_list.txt', $MTM::Legacy::Lists::sv_abbreviation_list );
	&srl_scalar_file( 'sv_abbreviation_list_case.txt', $MTM::Legacy::Lists::sv_abbreviation_list_case );

	#print "SRL encode: $SRLPATH/$srl_file\n";
	#####


# JE 2020-12-31
# NB!!!! These need to be written at some point, but not here!
#	&srl_hash_file( 'abbreviationHash.txt', \%abbreviationList );
#	&srl_hash_file( 'abbreviationCaseHash.txt', \%abbreviationListCase );
#	&srl_scalar_file( 'abbreviationList.txt', $abbreviationList );
#	&srl_scalar_file( 'abbreviationListCase.txt', $abbreviationListCase );

#	return( $abbreviationList, $abbreviationListCase, %abbreviationList, %abbreviationListCase );
	return 1;
}
#*******************************************************************************************#
# Reads abbreviation list and creates two scalars.
# JE 2021-01-06 Ammended to populate only
sub read_en_abbreviation_list {

	my $path = shift or die "Missing path!";


	# JE 2020-12-31
	# These are the same file names as the package scoped variables that we set as 
	# the end result of the call to this sub, which is confusing but works. Good 
	# thing to change later.
#	my (%en_abbreviation, %en_abbreviation_case);

	my $file = "en_abbreviation.txt"; ##### (NB!) JE Temp hardcoded file
	## no critic (InputOutput::RequireBriefOpen)
	open my $fh_ABBREVIATION, '<', "$path$file" or die "Cannot open ABBREVIATION $path$file: $!";
	## use critic
	
	while( <$fh_ABBREVIATION> ) {

		next if /^\#/;
		next if $. == 1;

		s/^\xEF\xBB\xBF//g;	# Remove bom

		chomp;

		my( $orthographies, $expansions, $rule, $mayEndSentence, $caseSensitivity ) = split/\t+/;

		my @orthographies = split/\|/,$orthographies;
		my @expansions = split/\|/,$expansions;

		# Orthographies
		foreach my $orthography ( @orthographies ) {

			if (
				$caseSensitivity == 1
			) {
				# Case sensitive abbreviations in special list
				$orthography = quotemeta( $orthography );
				$MTM::Legacy::Lists::en_abbreviation_case{ $orthography } = "$expansions\t$rule\t$mayEndSentence";

			} else {
				# Not case sensitive - add to list in all case possibilities
				my @caseOrth = &MTM::Case::caseLookup( $orthography, "caseInsensitive" );

				foreach my $caseOrth ( @caseOrth ) {
					$caseOrth = quotemeta( $caseOrth );
					$MTM::Legacy::Lists::en_abbreviation{ $caseOrth } = "$expansions\t$rule\t$mayEndSentence";
				}
			}
		}
	}
	close $fh_ABBREVIATION;

	# Sort by length of abbreviation
	my @en_abbreviation_list = sort { length($b) <=> length($a) || $a cmp $b } keys %MTM::Legacy::Lists::en_abbreviation;
	my @en_abbreviation_list_case = sort { length($b) <=> length($a) || $a cmp $b } keys %MTM::Legacy::Lists::en_abbreviation_case;

	# Orthography lists
	$MTM::Legacy::Lists::en_abbreviation_list = join'|',@en_abbreviation_list;
	$MTM::Legacy::Lists::en_abbreviation_list_case = join'|',@en_abbreviation_list_case;

	#print "III $MTM::Legacy::Lists::en_abbreviation_list\n"; exit;

	##### CT 0210015
	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";
	my $srl_file = $file;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;
	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/en_abbreviation.srl", \%MTM::Legacy::Lists::en_abbreviation, 0);
	$encoder->encode_to_file( "$SRLPATH/en_abbreviation_case.srl", \%MTM::Legacy::Lists::en_abbreviation_case, 0);

	&srl_scalar_file( 'en_abbreviation_list.txt', $MTM::Legacy::Lists::en_abbreviation_list );
	&srl_scalar_file( 'en_abbreviation_list_case.txt', $MTM::Legacy::Lists::en_abbreviation_list_case );

	#print "SRL encode: $SRLPATH/$srl_file\n";
	#####


# JE 2020-12-31
# NB!!!! These need to be written at some point, but not here!
#	&srl_hash_file( 'abbreviationHash.txt', \%abbreviationList );
#	&srl_hash_file( 'abbreviationCaseHash.txt', \%abbreviationListCase );
#	&srl_scalar_file( 'abbreviationList.txt', $abbreviationList );
#	&srl_scalar_file( 'abbreviationListCase.txt', $abbreviationListCase );

#	return( $abbreviationList, $abbreviationListCase, %abbreviationList, %abbreviationListCase );
	return 1;
}
#***************************************************************************#
#
# JE 2020-02-15 Genric call to populate a *Legacy variable* from a 
# *Legacy DB text dump*
#
# * This is a substitute for create_hash
# * Populates a hash (passed by reference) directly
# * Does not store anything (this is done separately)
#
# 2021-02-15 This currently implements file name based heuristics 
# as an option to decide which type of key to use. The goal is to 
# make that decision already in the call to populate, and to call one of
# the specific populate subs 
# * populate_single_key_hash, 
# * populate_double_key_hash
# * populate_triple_key_hash
# instead. So:
##### Remove heuristics when all is tested 
# 
sub populate_hash {
	my $file = shift;
	print STDERR "$file\n";
	my $hashref = shift; # This is a ref to the hash we want to populate
	# If we get a coderef to build the keys in the call, we go with it. Otherwise
	# we make up our own using file name heuristics
	my $coderef = shift;

	# We're putting the key building in a code reference to not have to
	# repeart the test for each read line, and still use only one sub

	if (ref($coderef) eq 'CODE') {
		print STDERR "Call to populate from $file is done correctly through specific method\n";
	} else {
		#####warn "We're guessing which hash type to use - deprecatead! (in populate_hash)\n)";
		if( $file =~ /(p_wordprob|p_backup_wordprob|p_main_suffix|p_backup_suffix|p_bigram|p_trigram)\.txt$/ ) {
			# Tab separated multikey, monovalue
			$coderef = sub { return (shift @{$_[0]}) . "\t" . (shift @{$_[0]}); };

		###### CT 2021-01-15 Triple key for trigram probabilities. Check!
		#} elsif( $file =~ /(p_trigram)\.txt$/ ) {
		#	# Tab separated multikey, monovalue
		#	$coderef = sub { return (shift @{$_[0]}) . "\t" . (shift @{$_[0]}) . "\t" . (shift @{$_[0]}); };

		} else {
			$coderef = sub { return shift @{$_[0]}; };
		}
	}

#	print STDERR "I $file\n";

	my @line;

	### Sourcing text data from $file...
	## no critic (InputOutput::RequireBriefOpen)


	open my $fh, '<', $file or die $!;
	## use critic
	
	while (<$fh>) { 
		my $line = $_;
		chomp $line;
	
		$line =~ s/\r//;

		##### CT 210215
		utf8::decode($line);

		##### TODO Fix this in some generic way, and move it out of each file access
		$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom


		##### TODO Remove in production version
		# The $MTM::Legacy::Lists::READERCUTOFF is used for testing, to read in only
		# a limited number of lines.
		# ($. holds the number of iterations in a while loop!)
		last if $. == $MTM::Legacy::Lists::READERCUTOFF; # $. holds the number of iterations in a while loop!!!

		next if $line =~ /^\#/;
		@line = split/\t+/, $line;


		my $key = &$coderef(\@line);
		my $val = join"\t", @line;
		
		# Dionysosfesterna	d i2: $ o3 $ n "y2: $ s å s - f `e $ s t ë $ rn a	NN UTR PLU DEF NOM	swe	swe	dionysos+festerna	741460
		if( $file =~ /sv_braxen/ ) {
			
			$val = "$line[1]	$line[2]	$line[3]	-	-	$line[25]";
			#print STDERR "$file\t$line	$#line\n";
			#print STDERR "val: $val\n"; exit;
		}

		#if( $file =~ /medial_v/ ) {
		#	print STDERR "KEY $key --- $val\n";
		#}

#		print "KEY $key --- $val\n";
		# This manipulates the hash that we passed to the sub directly
		$hashref->{ $key } = $val;

	}
	close $fh or die $!;

	##### CT 210015
	my $LEGACYPATH = "data/legacy/"; 
	#my $SRLPATH = "$LEGACYPATH/srl_TEST210215";
	my $SRLPATH = "$LEGACYPATH/srl";
	my $srl_file = $file;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;
	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file", $hashref, 0);
#	print "SRL encode: $SRLPATH/$srl_file\n";
	##### 

	return 1;
}

#***************************************************************************#
# CT 220512		$orth	$pron	$freq	to two hashes
sub populate_hash_2 {
	my $file = shift;			# Read this file
	my $file_1 = shift;		# Save to file 1
	my $file_2 = shift;		# Save to file 2

	my $hashref = shift; # This is a ref to the hash we want to populate
	my $hashref_2 = shift;

	my @line;

	print STDERR "Reading $file\n";

	### Sourcing text data from $file...
	open my $fh, '<', $file or die $!;
	while (<$fh>) { 
		my $line = $_;
		chomp $line;

		$line =~ s/\r//;

		##### CT 210215
		utf8::decode($line);

		##### TODO Fix this in some generic way, and move it out of each file access
		$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

		##### TODO Remove in production version
		# The $MTM::Legacy::Lists::READERCUTOFF is used for testing, to read in only
		# a limited number of lines.
		# ($. holds the number of iterations in a while loop!)
		last if $. == $MTM::Legacy::Lists::READERCUTOFF; # $. holds the number of iterations in a while loop!!!

		next if $line =~ /^\#/;
		@line = split/\t+/, $line;

		# print STDERR "$file\t$line\n";

		# This manipulates the hash that we passed to the sub directly
		$hashref->{ $line[0] } = $line[1];
		$hashref_2->{ $line[0] } = $line[2];

	}
	close $fh or die $!;

	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";


	my $srl_file = $file_1;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;

	print STDERR "Saving to file $srl_file\n";

	my $srl_file_2 = $file_2;
	$srl_file_2 =~ s/^.*\///;
	$srl_file_2 =~ s/\.txt/\.srl/;

	print STDERR "Saving to file $srl_file_2\n";

	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file", $hashref, 0);

	$encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file_2", $hashref_2, 0);

	return 1;
}
#***************************************************************************#
# CT 220512		$orth	$pron	$freq $meta	to three hashes
sub populate_hash_3 {
	my $file = shift;			# Read this file

	my $file_1 = shift;		# Save to file 1
	my $file_2 = shift;		# Save to file 2
	my $file_3 = shift;		# Save to file 3

	my $hashref = shift; # This is a ref to the hash we want to populate
	my $hashref_2 = shift;
	my $hashref_3 = shift;

	my @line;

	print STDERR "Reading $file\n";

	### Sourcing text data from $file...
	## no critic (InputOutput::RequireBriefOpen)
	open my $fh, '<', $file or die $!;
	## use critic
	
	while (<$fh>) { 
		my $line = $_;
		chomp $line;

		$line =~ s/\r//;

		##### CT 210215
		utf8::decode($line);

		##### TODO Fix this in some generic way, and move it out of each file access
		$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

		##### TODO Remove in production version
		# The $MTM::Legacy::Lists::READERCUTOFF is used for testing, to read in only
		# a limited number of lines.
		# ($. holds the number of iterations in a while loop!)
		last if $. == $MTM::Legacy::Lists::READERCUTOFF; # $. holds the number of iterations in a while loop!!!

		next if $line =~ /^\#/;
		@line = split/\t+/, $line;

		# print STDERR "$file\t$line\n";

		# This manipulates the hash that we passed to the sub directly
		$hashref->{ $line[0] } = $line[1];
		$line[2] =~ s/\|/\t/g;
		$hashref_2->{ $line[0] } = $line[2];
		$hashref_3->{ $line[0] } = $line[3];

	}
	close $fh or die $!;

	my $LEGACYPATH = "data/legacy/"; 
	my $SRLPATH = "$LEGACYPATH/srl";


	my $srl_file = $file_1;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;

	print STDERR "Saving to file $srl_file\n";

	my $srl_file_2 = $file_2;
	$srl_file_2 =~ s/^.*\///;
	$srl_file_2 =~ s/\.txt/\.srl/;

	print STDERR "Saving to file $srl_file_2\n";

	my $srl_file_3 = $file_3;
	$srl_file_3 =~ s/^.*\///;
	$srl_file_3 =~ s/\.txt/\.srl/;

	print STDERR "Saving to file $srl_file_3\n";


	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file", $hashref, 0);

	$encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file_2", $hashref_2, 0);

	$encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file_3", $hashref_3, 0);

	return 1;
}
#***************************************************************************#
#
# 2021-02-15 JE Populate Legacy variables
#
# Legacy variables have one out of three sturctures:
#
# (1) HASH{KEY} = VAR # (standard hash)
# (2) HASH{KEY1\tKEY2} = VAR # (double key hash)
# (3) HASH{KEY1\tKEY2\tKEY3} = VAR # (triple key hash)
#
# The latter two will be slow access, as they require the key to be 
# processed each time, but they are left in place in Legacy variable to
# ensure full backwards compatibility.
# 
# We implement a separate *populate* method for each of these types to
# boost speed and readability a little. The calls to these populate 
# methods originate either from the *populate_lists* umpralla method in 
# this package, or from the backwards compatibility test code which calls
# the variable building for each specific Legacy DB text dump separately.
# 
#***************************************************************************#
# 2021-02-15 JE Build "single key hash" from Legacy DB text dump
#
# This is one of three substitutes for *create_hash*
# The method populates a hash (passed by reference) directly
# It does not store anything (this is done through a separate call if needed)
sub populate_single_key_hash {
	my $file = shift; # The Legacy DB text dump to be read
	my $hashref = shift; # Ref to the hash we want to populate
	# There's some code cleaning to be done here - should work on a variable that is passed in
	my $coderef = sub { return shift @{$_[0]}; };
	populate_hash($file, $hashref, $coderef);

	return 1;
}
#***************************************************************************#
sub srl_scalar_file {
	#warn "Attempting to store in build phase: @_\n";

	##### 2021-06-11 CT	Temporally, until JE has fixed final solution.
	my $file = shift;
	my $scalar = shift;
	warn "Attempting to store in build phase: $file\n";

	my $Legacypath = "data/legacy/"; 
	my $srl_path = "$Legacypath/srl";

	my $srl_file = $file;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;
	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$srl_path/$srl_file", $scalar, 0);
	
	return 1;
}
#***************************************************************************#
1;
