package MTM::Legacy::ReadConfig;

use warnings;
use strict;

### CHANGE
# 2024-08-20 no such file exists
#require "C:/git/mtmpreproc/lib/MTM/Legacy/config.pl";

# CHECK THIS
	our $lang = $lang;
	our $en_month_orth_format = 		"$en_month|$en_month_abbreviation";		# $en_month_letter_format
	our $path_conversion_table = "data/pron/conversion_table.txt";		### Change! Hard coded in file where it's read.

# Language dependent vars
# English
if( $lang eq 'en' ) {
	our $decimal_separator =		$en_decimal_separator;
	our $thousand_separator =		$en_thousand_separator;
	our $acronym_endings =		$en_acronym_endings;
	our $ordinal_trigger =		$en_ordinal_trigger;
	our $ortinal_endings =		$en_ordinal_endings;
	our $roman_trigger =			$en_roman_trigger;
	our $roman_ordinal_ending =		$en_roman_ordinal_ending;
	our $roman_genitive_ending =	$en_roman_genitive_ending;
	our $roman_ending = 			$en_roman_ending;
	our $law_trigger =			$en_law_trigger;		# en does not exist
	our $units =				$en_units
	our $year_trigger_rc = 		$en_year_trigger_rc;
	our $remove_year_words =		$en_remove_year_words;	# en does not exist
	our $en_interval_trigger_lc =	$en_interval_trigger_lc;
	our $en_interval_trigger_rc =	$en_interval_trigger_rc;
	our $month =				$en_month;
	our $month_abbreviation =		$en_month_abbreviation:
	our %month_abbreviation_map =	%en_month_abbreviation_map;
	our $weekday =			$en_weekday;
	our $weekday_definite =		$en_weekday_definite;	# en does not eixst
	our $weekday_abbreviation =		$en_weekday_abbreviation;
	our %weekday_abbreviation_map =	%en_weekday_abbreviation_map;
	our $time_trigger = 			$en_time_trigger
	our $phone_trigger =			$en_phone_trigger;
	our $word_endings =			$en_word_endings;
	our $boundary_word_tpa = 		$en_boundary_word_tpa;
	our $boundary_compound_tpa = 	$en_boundary_compound_tpa;
	our $boundary_morph_tpa =		$en_boundary_morph_tpa;
	our $syllable_onset =		$en_syllable_onset;
	our $phones_vowels_cereproc =	$en_phones_vowels_cereproc;
	our $boundary_word_cereproc = 	$en_boundary_word_cereproc;
	our $boundary_compound_cereproc = 	$en_boundary_compound_cereproc;
	our $boundary_morph_cereproc =	$en_boundary_morph_cereproc;
	our $word_decimal_separator =	$en_word_decimal_separator;
	our $word_and =			$en_word_and;
	our $word_to =			$en_word_to;
	our $word_in =			$en_word_in;
	our $word_hundred =			$en_word_hundred;
	our $word_point =			$en_word_point;
	our $word_dot =			$en_word_dot;
	our $word_question_mark =		$en_word_question_mark;
	our $word_exclamation_mark =	$en_word_exclamation_mark;
	our $plus_word =			$en_plus_word;
	our $word_dash =			$en_word_dash;
	our $word_slash =			$en_word_slash;
	our $word_section_sign =		$en_word_section_sign;
	our $word_section_sign_def_sin =	$en_word_section_sign_def_sin;
	our $word_section_sign_def_plun =	$en_word_section_sign_def_plun;
	our $word_at_sign =			$en_word_at_sign;
	our $word_at =			$en_word_at;
	our $word_percent_sign =		$en_word_percent_sign;
	our $word_percent =			$en_word_percent;
	our $word_times =			$en_word_times;
	our $word_per_mille_sign =		$en_word_per_mille_sign;
	our $word_permille =			$en_word_permille;
	our $word_ampersand =		$en_word_ampersand;
	our $word_equals_word =		$en_word_equals_word;
	our $word_tilde =			$en_word_tilde;
	our $word_born =			$en_word_born;
	our $word_dead =			$en_word_dead;
	our $word_dagger =			$en_word_dagger;
	our $word_a_half_utr =		$en_word_a_half_utr;
	our $word_a_half_neu =		$en_word_a_half_neu;
	our $word_a_quarter =		$en_word_a_quarter;
	our $word_three_quarters =		$en_word_three_quarters;
	our $word_colon =			$en_word_colon;
	our $word_degree =			$en_word_degree;
	our $word_degrees =			$en_word_degrees;
	our $word_underscore =		$en_word_underscore;
	our $word_vertical_bar =		$en_word_vertical_bar;
	our $word_less_than_sign =		$en_word_less_than_sign;
	our $word_greater_than_sign =	$en_word_greater_than_sign;
	our $word_less_than =		$en_word_less_than;
	our $word_greater_than =		$en_word_greater_than;
	our $word_dollar_sign =		$en_word_dollar_sign;
	our $word_dollar_sin =		$en_word_dollar_sin;
	our $word_dollar_plu =		$en_word_dollar_plu;
	our $word_pound_sign =		$en_word_pound_sign;
	our $word_pound_sin =		$en_word_pound_sin;
	our $word_pound_plu =		$en_word_pound_plu;
	our $word_euro_sign =		$en_word_euro_sign;
	our $word_euro_sin =			$en_word_euro_sin;
	our $word_euro_plu =			$en_word_euro_plu;
	our $word_cent_sign =		$en_word_cent_sign;
	our $word_cent_sin =			$en_word_cent_sin;
	our $word_cent_plu =			$en_word_cent_plu;
	our $word_yen_sign =			$en_word_yen_sign;
	our $word_yen_sin =			$en_word_yen_sin;
	our $word_yen_plu =			$en_word_yen_plu;

# Swedish and world
} else {
	our $decimal_separator =		$sv_decimal_separator;
	our $thousand_separator =		$sv_thousand_separator;
	our $acronym_endings =		$sv_acronym_endings;
	our $ordinal_trigger =		$sv_ordinal_trigger;
	our $ortinal_endings =		$sv_ordinal_endings;
	our $roman_trigger =			$sv_roman_trigger;
	our $roman_ordinal_ending =		$sv_roman_ordinal_ending;
	our $roman_genitive_ending =	$sv_roman_genitive_ending;
	our $roman_ending = 			$sv_roman_ending;
	our $law_trigger =			$sv_law_trigger;		# en does not exist
	our $units =				$sv_units
	our $year_trigger_rc = 		$sv_year_trigger_rc;
	our $remove_year_words =		$sv_remove_year_words;	# en does not exist
	our $sv_interval_trigger_lc =	$sv_interval_trigger_lc;
	our $sv_interval_trigger_rc =	$sv_interval_trigger_rc;
	our $month =				$sv_month;
	our $month_abbreviation =		$sv_month_abbreviation:
	our %month_abbreviation_map =	%sv_month_abbreviation_map;
	our $weekday =			$sv_weekday;
	our $weekday_definite =		$sv_weekday_definite;	# en does not eixst
	our $weekday_abbreviation =		$sv_weekday_abbreviation;
	our %weekday_abbreviation_map =	%sv_weekday_abbreviation_map;
	our $time_trigger = 			$sv_time_trigger
	our $phone_trigger =			$sv_phone_trigger;
	our $word_endings =			$sv_word_endings;
	our $boundary_word_tpa = 		$sv_boundary_word_tpa;
	our $boundary_compound_tpa = 	$sv_boundary_compound_tpa;
	our $boundary_morph_tpa =		$sv_boundary_morph_tpa;
	our $syllable_onset =		$sv_syllable_onset;
	our $phones_vowels_cereproc =	$sv_phones_vowels_cereproc;
	our $boundary_word_cereproc = 	$sv_boundary_word_cereproc;
	our $boundary_compound_cereproc = 	$sv_boundary_compound_cereproc;
	our $boundary_morph_cereproc =	$sv_boundary_morph_cereproc;
	our $word_decimal_separator =	$sv_word_decimal_separator;
	our $word_and =			$sv_word_and;
	our $word_to =			$sv_word_to;
	our $word_in =			$sv_word_in;
	our $word_hundred =			$sv_word_hundred;
	our $word_point =			$sv_word_point;
	our $word_dot =			$sv_word_dot;
	our $word_question_mark =		$sv_word_question_mark;
	our $word_exclamation_mark =	$sv_word_exclamation_mark;
	our $plus_word =			$sv_plus_word;
	our $word_dash =			$sv_word_dash;
	our $word_slash =			$sv_word_slash;
	our $word_section_sign =		$sv_word_section_sign;
	our $word_section_sign_def_sin =	$sv_word_section_sign_def_sin;
	our $word_section_sign_def_plun =	$sv_word_section_sign_def_plun;
	our $word_at_sign =			$sv_word_at_sign;
	our $word_at =			$sv_word_at;
	our $word_percent_sign =		$sv_word_percent_sign;
	our $word_percent =			$sv_word_percent;
	our $word_times =			$sv_word_times;
	our $word_per_mille_sign =		$sv_word_per_mille_sign;
	our $word_permille =			$sv_word_permille;
	our $word_ampersand =		$sv_word_ampersand;
	our $word_equals_word =		$sv_word_equals_word;
	our $word_tilde =			$sv_word_tilde;
	our $word_born =			$sv_word_born;
	our $word_dead =			$sv_word_dead;
	our $word_dagger =			$sv_word_dagger;
	our $word_a_half_utr =		$sv_word_a_half_utr;
	our $word_a_half_neu =		$sv_word_a_half_neu;
	our $word_a_quarter =		$sv_word_a_quarter;
	our $word_three_quarters =		$sv_word_three_quarters;
	our $word_colon =			$sv_word_colon;
	our $word_degree =			$sv_word_degree;
	our $word_degrees =			$sv_word_degrees;
	our $word_underscore =		$sv_word_underscore;
	our $word_vertical_bar =		$sv_word_vertical_bar;
	our $word_less_than_sign =		$sv_word_less_than_sign;
	our $word_greater_than_sign =	$sv_word_greater_than_sign;
	our $word_less_than =		$sv_word_less_than;
	our $word_greater_than =		$sv_word_greater_than;
	our $word_dollar_sign =		$sv_word_dollar_sign;
	our $word_dollar_sin =		$sv_word_dollar_sin;
	our $word_dollar_plu =		$sv_word_dollar_plu;
	our $word_pound_sign =		$sv_word_pound_sign;
	our $word_pound_sin =		$sv_word_pound_sin;
	our $word_pound_plu =		$sv_word_pound_plu;
	our $word_euro_sign =		$sv_word_euro_sign;
	our $word_euro_sin =			$sv_word_euro_sin;
	our $word_euro_plu =			$sv_word_euro_plu;
	our $word_cent_sign =		$sv_word_cent_sign;
	our $word_cent_sin =			$sv_word_cent_sin;
	our $word_cent_plu =			$sv_word_cent_plu;
	our $word_yen_sign =			$sv_word_yen_sign;
	our $word_yen_sin =			$sv_word_yen_sin;
	our $word_yen_plu =			$sv_word_yen_plu;
}

# Language independent vars
our $min_chars_in_compound_part = 	$xx_min_chars_in_compound_part;
our $roman_orth =			$xx_roman_orth;
our $roman_safe_orth =		$xx_roman_safe_orth;
our $fraction =			$xx_fraction;
our $year_format =			$xx_year_format;
our $year_short_format =		$xx_year_short_format;
our $grapheme_vowel =		$xx_grapheme_vowel;
our $grapheme_consonant =		$xx_grapheme_consonant;
our $grapheme_character =		$xx_grapheme_character;
our $grapheme_uc = 			$xx_grapheme_uc;
our $grapheme_lc = 			$xx_grapheme_lc;
our $grapheme_uc_lc = 		$xx_grapheme_uc_lc;
our $grapheme_superscript =		$xx_grapheme_superscript;
our $grapheme_subscript = 		$xx_grapheme_subscript;
our $delimiter_major =		$xx_delimiter_major;
our $delimiter_minor = 		$xx_delimiter_minor;
our $delimiter_quote_double =	$xx_delimiter_quote_double;
our $delimiter_quote_single =	$xx_delimiter_quote_single;
our $delimiter_quote =		$xx_delimiter_quote;
our $delimiter =			$xx_delimiter;
our $delimiter_other = 		$xx_delimiter_other;
our $hyphens = 			$xx_hyphens;
our $grapheme_g2p_cart		$xx_grapheme_g2p_cart;
our $phones_vowels_tpa =		$xx_phones_vowels_tpa;
our $phones_consonant_tpa =		$xx_phones_consonant_tpa;
our $phones_tpa =			$xx_phones_tpa;
our $boundary_syllable_tpa =	$xx_boundary_syllable_tpa;
our $boundary_syllable_cereproc =	$xx_boundary_syllable_cereproc;
our $phones_vowels_ipa =		$xx_phones_vowels_ipa;
our $boundary_syllable_ipa =	$xx_boundary_syllable_ipa;
our $phones_vowels_nst =		$xx_phones_vowels_nst;
our $phones_vowels_tacotron_1 =	$xx_phones_vowels_tacotron_1;
our $boundary_pause_tacotron_1 = 	$xx_boundary_pause_tacotron_1;
our $boundary_word_tacotron_1 = 	$xx_boundary_word_tacotron_1;
our $boundary_end_tacotron_1 = 	$xx_boundary_end_tacotron_1;


1;