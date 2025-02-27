	package MTM::Legacy::Lists::Retrieve;

#use parent qw(MTM::Legacy::Lists);

use warnings;
use strict;

sub read_lists {
	### JE use MTM-time...
	my $mtm = shift;
	my $SRLPATH = shift;
	print STDERR "LIST RETRIEVAL START\t" . $mtm->now . "\n";	##### JE should use $mtm->fb to print

	# Decode
	my $decoder = Sereal::Decoder->new;

	my $sv_alphabet = $decoder->decode_from_file( "$SRLPATH/sv_alphabet.srl" );
	my $en_alphabet = $decoder->decode_from_file( "$SRLPATH/en_alphabet.srl" );

	our $sweAcronym = $decoder->decode_from_file( "$SRLPATH/sv_acronym.srl" );

	my $sv_numeral_pron = $decoder->decode_from_file( "$SRLPATH/sv_numeral_pron.srl" );
	my $en_numeral_pron = $decoder->decode_from_file( "$SRLPATH/en_numeral_pron.srl" );

	my $sv_domain = $decoder->decode_from_file( "$SRLPATH/sv_domain.srl" );
	my $en_domain = $decoder->decode_from_file( "$SRLPATH/en_domain.srl" );


	my $p2s = $decoder->decode_from_file( "$SRLPATH/p2s.srl" );
	my $s2p = $decoder->decode_from_file( "$SRLPATH/s2p.srl" );
	my $p_bigram = $decoder->decode_from_file( "$SRLPATH/p_bigram.srl" );
	my $p_trigram = $decoder->decode_from_file( "$SRLPATH/p_trigram.srl" );
	my $p_wordprob = $decoder->decode_from_file( "$SRLPATH/p_wordprob.srl" );
	my $p_backup_wordprob = $decoder->decode_from_file( "$SRLPATH/p_backup_wordprob.srl" );
	# print STDERR "p_backup_wordprob_db_file\n";
	my $p_wordtags = $decoder->decode_from_file( "$SRLPATH/p_wordtags.srl" );
	#our %p_backup_wordtags = $decoder->decode_from_file( "$SRLPATH/ );
	my $p_suffix = $decoder->decode_from_file( "$SRLPATH/p_main_suffix.srl" );
	# print STDERR "p_main_suffix_db_file\n";
	my $p_backup_suffix = $decoder->decode_from_file( "$SRLPATH/p_backup_suffix.srl" );
	my $p_suffixtag = $decoder->decode_from_file( "$SRLPATH/p_main_suffixtag.srl" );
	my $p_backup_suffixtag = $decoder->decode_from_file( "$SRLPATH/p_backup_suffixtag.srl" );
#	our $sweDictMultiword = $decoder->decode_from_file( "$SRLPATH/sweDictMultiword.srl" ); # likely not used



	# print STDERR "alphabet\n";
	my $sv_dict_main = $decoder->decode_from_file( "$SRLPATH/sv_dict_main.srl" );
	# print STDERR "sv_dict_main\n";
	my $sv_dict_name = $decoder->decode_from_file( "$SRLPATH/sv_dict_name.srl" );
	my $sv_dict_english = $decoder->decode_from_file( "$SRLPATH/sv_dict_english.srl" );

	my $sv_nst_dict;
	if( $MTM::Vars::use_dict eq 'NST' ) { $sv_nst_dict = $decoder->decode_from_file( "$SRLPATH/sv_nst_dict.srl" ); }

	my $sv_initial_c = $decoder->decode_from_file( "$SRLPATH/sv_initial_c.srl" );
	my $sv_initial_v = $decoder->decode_from_file( "$SRLPATH/sv_initial_v.srl" );
	my $sv_medial_c = $decoder->decode_from_file( "$SRLPATH/sv_medial_c.srl" );
	my $sv_medial_v = $decoder->decode_from_file( "$SRLPATH/sv_medial_v.srl" );
	my $sv_final_c = $decoder->decode_from_file( "$SRLPATH/sv_final_c.srl" );
	my $sv_final_v = $decoder->decode_from_file( "$SRLPATH/sv_final_v.srl" );

	my $en_initial_c = $decoder->decode_from_file( "$SRLPATH/en_initial_c.srl" );
	my $en_initial_v = $decoder->decode_from_file( "$SRLPATH/en_initial_v.srl" );
	my $en_medial_c = $decoder->decode_from_file( "$SRLPATH/en_medial_c.srl" );
	my $en_medial_v = $decoder->decode_from_file( "$SRLPATH/en_medial_v.srl" );
	my $en_final_c = $decoder->decode_from_file( "$SRLPATH/en_final_c.srl" );
	my $en_final_v = $decoder->decode_from_file( "$SRLPATH/en_final_v.srl" );
	# print STDERR "final_v_db_file\n";

	# Abbreviaion lists
	my $tmp_sv_abbreviation = $decoder->decode_from_file( "$SRLPATH/sv_abbreviation.srl" ); # JE used?
	my $tmp_sv_abbreviation_case = $decoder->decode_from_file( "$SRLPATH/sv_abbreviation_case.srl" ); # JE used?
	%MTM::Legacy::Lists::sv_abbreviation = %$tmp_sv_abbreviation;
	%MTM::Legacy::Lists::sv_abbreviation_case = %$tmp_sv_abbreviation_case;
	$MTM::Legacy::Lists::sv_abbreviation_list = $decoder->decode_from_file( "$SRLPATH/sv_abbreviation_list.srl" );
	$MTM::Legacy::Lists::sv_abbreviation_list_case = $decoder->decode_from_file( "$SRLPATH/sv_abbreviation_list_case.srl" );

	my $tmp_en_abbreviation = $decoder->decode_from_file( "$SRLPATH/en_abbreviation.srl" ); # JE used?
	my $tmp_en_abbreviation_case = $decoder->decode_from_file( "$SRLPATH/en_abbreviation_case.srl" ); # JE used?
	%MTM::Legacy::Lists::en_abbreviation = %$tmp_en_abbreviation;
	%MTM::Legacy::Lists::en_abbreviation_case = %$tmp_en_abbreviation_case;
	$MTM::Legacy::Lists::en_abbreviation_list = $decoder->decode_from_file( "$SRLPATH/en_abbreviation_list.srl" );
	$MTM::Legacy::Lists::en_abbreviation_list_case = $decoder->decode_from_file( "$SRLPATH/en_abbreviation_list_case.srl" );

	#print STDERR "abbreviationListCase\n";

	# Acronym lists
	my $tmp_sv_acronym = $decoder->decode_from_file( "$SRLPATH/sv_acronym.srl" );
	%MTM::Legacy::Lists::sv_acronym = %$tmp_sv_acronym;					# Hash
	$MTM::Legacy::Lists::sv_acronym_list = $decoder->decode_from_file( "$SRLPATH/sv_acronym_list.srl" );		# Scalar

	my $tmp_en_acronym = $decoder->decode_from_file( "$SRLPATH/en_acronym.srl" );
	%MTM::Legacy::Lists::en_acronym = %$tmp_en_acronym;					# Hash
	$MTM::Legacy::Lists::en_acronym_list = $decoder->decode_from_file( "$SRLPATH/en_acronym_list.srl" );		# Scalar

	# Multiword lists
#	my $tmp_multiwordList = $decoder->decode_from_file( "$SRLPATH/sweDictMultiword.srl" );
#	%MTM::Legacy::Lists::sweDictMultiword = %$tmp_multiwordList;							# Hash
#	$MTM::Legacy::Lists::multiwordList = $decoder->decode_from_file( "$SRLPATH/multiwordList.srl" );		# Scalar

	# Special characters list
	my $tmp_sv_special_character = $decoder->decode_from_file( "$SRLPATH/sv_special_character.srl" );
	%MTM::Legacy::Lists::sv_special_character = %$tmp_sv_special_character;							# Hash
	$MTM::Legacy::Lists::sv_special_character_list = $decoder->decode_from_file( "$SRLPATH/sv_special_character_list.srl" );	# Scalar

	my $tmp_en_special_character = $decoder->decode_from_file( "$SRLPATH/en_special_character.srl" );
	%MTM::Legacy::Lists::en_special_character = %$tmp_en_special_character;							# Hash
	$MTM::Legacy::Lists::en_special_character_list = $decoder->decode_from_file( "$SRLPATH/en_special_character_list.srl" );	# Scalar

	#print STDERR "specialCharacters\n";

	#**************************************************************************#
	# DecPart lists

	# Initial
	my $tmp_sv_initial_dec_parts = $decoder->decode_from_file( "$SRLPATH/sv_initial_dec_parts.srl" );
	%MTM::Legacy::Lists::sv_initial_dec_parts = %$tmp_sv_initial_dec_parts;								# Hash
	$MTM::Legacy::Lists::sv_initial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/sv_initial_dec_parts_list.srl" );	# Scalar

	$MTM::Legacy::Lists::sv_initial_orth_dec_parts = $decoder->decode_from_file( "$SRLPATH/sv_initial_orth_dec_parts.srl" );
	%MTM::Legacy::Lists::sv_initial_orth_dec_parts = %$MTM::Legacy::Lists::sv_initial_orth_dec_parts;				# Hash

	# Medial
	my $tmp_sv_medial_dec_parts = $decoder->decode_from_file( "$SRLPATH/sv_medial_dec_parts.srl" );
	%MTM::Legacy::Lists::sv_medial_dec_parts = %$tmp_sv_medial_dec_parts;								# Hash

	$MTM::Legacy::Lists::sv_medial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/sv_medial_dec_parts_list.srl" );	# Scalar

	$MTM::Legacy::Lists::sv_medial_orth_dec_parts = $decoder->decode_from_file( "$SRLPATH/sv_medial_orth_dec_parts.srl" );
	%MTM::Legacy::Lists::sv_medial_orth_dec_parts = %$MTM::Legacy::Lists::sv_medial_orth_dec_parts;					# Hash

	my $tmp_sv_final_dec_parts = $decoder->decode_from_file( "$SRLPATH/sv_final_dec_parts.srl" );
	%MTM::Legacy::Lists::sv_final_dec_parts = %$tmp_sv_final_dec_parts;								# Hash

	$MTM::Legacy::Lists::sv_final_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/sv_final_dec_parts_list.srl" );		# Scalar

	$MTM::Legacy::Lists::sv_final_orth_dec_parts = $decoder->decode_from_file( "$SRLPATH/sv_final_orth_dec_parts.srl" );
	%MTM::Legacy::Lists::sv_final_orth_dec_parts	= %$MTM::Legacy::Lists::sv_final_orth_dec_parts;					# Hash

	$MTM::Legacy::Lists::sv_final_orth_meta = $decoder->decode_from_file( "$SRLPATH/sv_final_orth_meta.srl" );
	%MTM::Legacy::Lists::sv_final_orth_meta = %$MTM::Legacy::Lists::sv_final_orth_meta;						# Hash

	# English
	#my $tmp_en_initial_dec_parts = $decoder->decode_from_file( "$SRLPATH/en_initial_dec_parts.srl" );
	#%MTM::Legacy::Lists::en_initial_dec_parts = %$tmp_en_initial_dec_parts;								# Hash
	#$MTM::Legacy::Lists::en_initial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/en_initial_dec_parts_list.srl" );	# Scalar

	#$MTM::Legacy::Lists::en_initial_orth_dec_parts = $decoder->decode_from_file( "$SRLPATH/en_initial_orth_dec_parts.srl" );
	#%MTM::Legacy::Lists::en_initial_orth_dec_parts = %$MTM::Legacy::Lists::en_initial_orth_dec_parts;				# Hash

	# Medial
	#my $tmp_en_medial_dec_parts = $decoder->decode_from_file( "$SRLPATH/en_medial_dec_parts.srl" );
	#%MTM::Legacy::Lists::en_medial_dec_parts = %$tmp_en_medial_dec_parts;								# Hash

	#$MTM::Legacy::Lists::en_medial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/en_medial_dec_parts_list.srl" );	# Scalar

	#$MTM::Legacy::Lists::en_medial_orth_dec_parts = $decoder->decode_from_file( "$SRLPATH/en_medial_orth_dec_parts.srl" );
	#%MTM::Legacy::Lists::en_medial_orth_dec_parts = %$MTM::Legacy::Lists::en_medial_orth_dec_parts;					# Hash

	#my $tmp_en_final_dec_parts = $decoder->decode_from_file( "$SRLPATH/en_final_dec_parts.srl" );
	#%MTM::Legacy::Lists::en_final_dec_parts = %$tmp_en_final_dec_parts;								# Hash

	#$MTM::Legacy::Lists::en_final_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/en_final_dec_parts_list.srl" );		# Scalar

	#$MTM::Legacy::Lists::en_final_orth_dec_parts = $decoder->decode_from_file( "$SRLPATH/en_final_orth_dec_parts.srl" );
	#%MTM::Legacy::Lists::en_final_orth_dec_parts	= %$MTM::Legacy::Lists::en_final_orth_dec_parts;					# Hash

	#$MTM::Legacy::Lists::en_final_orth_meta = $decoder->decode_from_file( "$SRLPATH/en_final_orth_meta.srl" );
	#%MTM::Legacy::Lists::en_final_orth_meta = %$MTM::Legacy::Lists::en_final_orth_meta;						# Hash

	#**************************************************************************#
	# Suffix lists
	my $tmp_sv_suffix = $decoder->decode_from_file( "$SRLPATH/sv_suffix.srl" );
	%MTM::Legacy::Lists::sv_suffix = %$tmp_sv_suffix;

	my $tmp_sv_suffix_pos = $decoder->decode_from_file( "$SRLPATH/sv_suffix_pos.srl" );
	%MTM::Legacy::Lists::sv_suffix_pos = %$tmp_sv_suffix_pos;

	$MTM::Legacy::Lists::sv_suffix_list = $decoder->decode_from_file( "$SRLPATH/sv_suffix.srl" );

	my $tmp_en_suffix = $decoder->decode_from_file( "$SRLPATH/en_suffix.srl" );
	%MTM::Legacy::Lists::en_suffix = %$tmp_en_suffix;

	my $tmp_en_suffix_pos = $decoder->decode_from_file( "$SRLPATH/en_suffix_pos.srl" );
	%MTM::Legacy::Lists::en_suffix_pos = %$tmp_en_suffix_pos;

	$MTM::Legacy::Lists::en_suffix_list = $decoder->decode_from_file( "$SRLPATH/en_suffix.srl" );

	#**************************************************************************#
	# JE 2020-12-31
	# We dereference all of these...
	# This is so that the original codebase can run
	# without a lot of changes if we pass tha hash lists by reference.
	# Costly, but it'll changing is low priority now.
	%MTM::Legacy::Lists::p2s = %$p2s;
	%MTM::Legacy::Lists::s2p = %$s2p;
	%MTM::Legacy::Lists::p_bigram = %$p_bigram;
	%MTM::Legacy::Lists::p_trigram = %$p_trigram;
	%MTM::Legacy::Lists::p_wordprob = %$p_wordprob;
	%MTM::Legacy::Lists::p_backup_wordprob = %$p_backup_wordprob;
	%MTM::Legacy::Lists::p_wordtags = %$p_wordtags;
	# our %p_backup_wordtags = %$p_backup_wordtags;
	%MTM::Legacy::Lists::p_suffix = %$p_suffix;
	# our %p_backup_suffix = %$p_backup_suffix;
	%MTM::Legacy::Lists::p_suffixtag = %$p_suffixtag;
	# our %p_backup_suffixtag = %$p_backup_suffixtag;

	%MTM::Legacy::Lists::sv_numeral_pron = %$sv_numeral_pron;
	%MTM::Legacy::Lists::en_numeral_pron = %$en_numeral_pron;

	%MTM::Legacy::Lists::sv_domain = %$sv_domain;
	%MTM::Legacy::Lists::en_domain = %$en_domain;

	%MTM::Legacy::Lists::sv_alphabet = %$sv_alphabet;
	%MTM::Legacy::Lists::en_alphabet = %$en_alphabet;

	%MTM::Legacy::Lists::sv_dict_main = %$sv_dict_main;
	%MTM::Legacy::Lists::sv_dict_name = %$sv_dict_name;
	%MTM::Legacy::Lists::sv_dict_english = %$sv_dict_english;

	if( $MTM::Vars::use_dict eq 'NST' ) { %MTM::Legacy::Lists::sv_nst_dict = %$sv_nst_dict; }

	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_nst_dict)){  if( $k =~ /^h/ ) { print "I $k\t$v\n"; }}

	%MTM::Legacy::Lists::sv_initial_c = %$sv_initial_c;
	%MTM::Legacy::Lists::sv_initial_v = %$sv_initial_v;
	%MTM::Legacy::Lists::sv_medial_c = %$sv_medial_c;
	%MTM::Legacy::Lists::sv_medial_v = %$sv_medial_v;
	%MTM::Legacy::Lists::sv_final_c = %$sv_final_c;
	%MTM::Legacy::Lists::sv_final_v = %$sv_final_v;

	%MTM::Legacy::Lists::en_initial_c = %$en_initial_c;
	%MTM::Legacy::Lists::en_initial_v = %$en_initial_v;
	%MTM::Legacy::Lists::en_medial_c = %$en_medial_c;
	%MTM::Legacy::Lists::en_medial_v = %$en_medial_v;
	%MTM::Legacy::Lists::en_final_c = %$en_final_c;
	%MTM::Legacy::Lists::en_final_v = %$en_final_v;

	### JE use MTM-time...
	print STDERR "LIST RETRIEVAL END\t" . $mtm->now . "\n";	##### JE should use $mtm->fb to print
	#while(my($k,$v)=each(%sv_alphabet)){print"$k\t$v\n";}
#	while(my($k,$v)=each(%MTM::Legacy::Lists::sv_abbreviation)){print STDERR "$k\t$v\n";} #exit;

	return 1;
}

1;
