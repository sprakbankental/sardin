package MTM::Legacy::Config;

use warnings;
use strict;

#********************************************************************#
# SARDIN CONFIG
#********************************************************************#
# Questions
#
# - Language prefix for language independent variables? See $xx_roman_orth for an example.
# - Variables in config file or creating them when object is created? Use $@% for now + " and ' and ;
#
#
#

#********************************************************************#
# Target language
our $lang = 'sv';

# Use this phone alphabet
our $phone_output = 'cereproc';		# NEW

# This is the tts we're using
our $tts = 'mtm';			# mtm|tacotron_1		CHECK THIS
our $runmode = 'cereproc';		# cereproc|word_lookup|...	CHECK THIS


#********************************************************************#
# COMPOUND
	our $xx_min_chars_in_compound_part = 2;		# $minTokens


#********************************************************************#
# PRONUNCIATION DICTIONARY
	our $pronunciation_dictionary = 	'MTM';		# $use_dict		MTM|NST
	our $db_pronunciation_dictionary =	'';

	our $nst_path = "data/dictionaries/NST";		# CHECK THIS


	our $sv_decimal_separator = ',';		# $decimal_separator
	our $en_decimal_separator = '\.';		# $decimal_separator

	our $sv_thousand_separator = '\.';		# $thousand_separator		# space?
	our $en_thousand_separator = '[,\.]';		# $thousand_separator

#********************************************************************#
# ACRONYM
#********************************************************************#
	our $sv_acronym_endings = 's|er|ers|en|ens|et|ets|are|ares|aren|arens|an|ans|erna|ernas|arna|arnas|orna|ornas|n|ns|t|ts';	# $sv_acronym_endings
	our $en_acronym_endings 	= 's';		# $en_acronym_endings


#********************************************************************#
# ORDINAL
#********************************************************************#
	# Trigger
	$sv_ordinal_trigger = 'uppl\.?|st\.?|\&paraett\;|\&paratva\;|upplaga|upplagan|kapitlet|paragrafen|dir\.';	# $sv_ordinal_words
	$en_ordinal_trigger = 'paragraph|chapter';										# $en_ordinal_words

	# Morphology
	$sv_ordinal_endings = '[:\'\.]?(?:onde|nde|dje|de|te|a|e)';	# $sv_ordinal_endings
	$en_ordinal_endings = '[:\'\.]?(?:st|nd|rd|th)';			# $en ordinal_endings

#********************************************************************#
# ROMAN
#********************************************************************#
	# Orthography
	$xx_roman_orth = 		'ivxlcdm';			# $romanLetters
	$xx_roman_safe_orth = 	'II|III|IV|V|VII|VIII|IX|X+I+|X+I+V+|X+V+|X+V+I+|M';	# $safeRomanNum

	# Trigger
	$sv_roman_trigger = 	'del|avsnitt|block|avdelning|kapitel|sidan|sida|figur|fig\.|rubrik|notreferens|avd\.|avd|kap\.|kap|NJA|version';	# $sv_roman_words
	$en_roman_trigger = 	'part|section|block|chapter|pages|page|figure|fig\.||chapt\.|chapt|ch\.|ch|version';	# $en_roman_words

	# Morphology
	$sv_roman_ordinal_ending =		'a|e|\:a|\:e';						# $sv_roman_ordinal_ending
	$sv_roman_genitive_ending =		's|\:s';							# $sv_roman_genitive_ending
	$sv_roman_ending = 			"$sv_roman_ordinal_ending|$sv_roman_genitive_ending";	# $sv_roman_ending

	$en_roman_ordinal_ending = 		'st|nd|rd|th';						# $en_roman_ordinal_ending
	$en_roman_genitivie_ending = 	"s|\'s";							# $en_roman_genitive_ending
	$en_roman_ending = 			"$en_roman_ordinal_ending|$en_roman_genitivie_ending";	# $en_roman_ending

	# Map
	%roman2arabic = 			qw(I 1 V 5 X 10 L 50 C 100 D 500 M 1000);			# %roman2arabic

#********************************************************************#
#  LAW
#********************************************************************#
	$sv_law_trigger =	'\§|\§\§|kap\.?|st\.?';	# $law_words


#********************************************************************#
#  UNITS
#********************************************************************#
	$sv_units = 	"matskedar|matsked|teskedar|tesked|knivsudd|msk\.|smsk|tsk\.|tsk|liter|deciliter|centiliter|milliliter|kilogram|kilo|hektogram|hekto|gram|kilometer|meter|decimeter|centimeter|millimeter|kg\.|kg|hg\.|hg|g\.|g|dl\.|dl|cl\.|cl|ml\.|ml|l\.|l|km\.|km|m\.|m|dm\.|dm|cm\.|cm|mm\.|mm";	# $sv_units
	$en_units = 	"tablespoons|tablespoon|teaspoons|teaspoon|tbsp\.|tbsp|tsp\.|tsp|pounds|pounds|pound|litres|litres|deciliters|deciliter|centiliters|centiliter|milliliters|milliliters|kilograms|kilogram|kilos|kilo|hectograms|hectogram|hectos|hecto|grams|gram|yards|yard|miles|mile|kilometers|kilometer|meters|meter|decimeters|decimiter|centimeters|centimeter|millimeters|millimeter|lb\.|lb|kg\.|kg|hg\.|hg|g\.|g|dl\.|dl|cl\.|cl|ml\.|ml|l\.|l|km\.|km|m\.|m|dm\.|dm|cm\.|cm|mm\.|mm";	# $en_units


#********************************************************************#
#  NUMERALS
#********************************************************************#
	# Fractions
	$xx_fraction = '\½|\¼|\¾|1\/2|1\/4|3\/4';		# $fraction

	# Years
	$xx_year_format =		'1[1-9][0-9][0-9]|2[0-9][0-9][0-9]';		# $year_format
	$xx_year_short_format =	'[0-9][0-9]';						# $year_short_format

	$sv_year_trigger_rc =	'[fe]\. ?kr\.?|[åÅ]rs|\-|[a-z]';			# $sv_year_words_rc
	$sv_remove_year_words =	'år|stycken|st\.?|dagar|månader';			# $sv_remove_year_words

	$en_year_trigger_rc =	'bc|ad|\-|[a-z]';					# $en_year_words_rc

	# Intervals
	$sv_interval_trigger_lc =	'kapitel|kap.|kap|sidan|nummer|från|skala|skalan';				# $sv_interval_words_lc
	$en_interval_trigger_lc =	'chapter|ch.|ch|chs|chs|page|from|between';					# $en_interval_words_lc
	$sv_interval_trigger_rc =	'minuter|min.|min|procent|pct.|pct|%|gram|g.|g|kg.|kg|kilogram|kilo';		# $sv_interval_words_rc
	$en_interval_trigger_rc =	'minutes|min.|min|percent|pct.|pct|%|gram|g.|g|kg.|kg|kilogram|kilo';		# $en_interval_words_rc

#********************************************************************#
#  DATE AND TIME
#********************************************************************#
	$sv_month =				"januari|februari|mars|april|maj|juni|juli|augusti|september|oktober|november|december";			# $sv_month
	$sv_month_abbreviation =		'jan\.?|febr\.?|feb\.?|mar\.?|apr\.?|maj|jun\.?|jul\.?|aug\.?|sept\.?|sep\.?|okt\.?|nov\.?|dec\.?';	# $sv_month_abbreviation
	%sv_month_abbreviation_map =	qw( jan. januari jan januari feb. februari feb februari mar. mars mar mars apr. april apr april maj maj jun. juni jun juni jul. juli jul juli aug. augusti aug augusti sep. september sept. september sep september sept september okt. oktober okt oktober nov. november nov november dec. december dec december );	# %sv_month_abbreviation

	$en_month =				"January|February|March|April|May|juni|juli|August|September|October|November|December";			# $en_month
	$en_month_abbreviation =		'jan\.?|febr\.?|feb\.?|mar\.?|apr\.?|May|jun\.?|jul\.?|aug\.?|sept\.?|sep\.?|oct\.?|nov\.?|dec\.?';	# $en_month_abbreviation
	$en_month_orth_format = 		"$en_month|$en_month_abbreviation";		# $en_month_letter_format
	%en_month_abbreviation_map =	qw( jan. January jan January feb. February feb February mar. March mar March apr. April apr April May May jun. June jun June jul. July jul July aug. August aug August sep. September sept. September sep September sept September oct. October oct October nov. November nov November dec. December dec December );	# %en_month_abbreviation

	# Weekdays
	$sv_weekday =				'måndag|tisdag|onsdag|torsdag|fredag|lördag|söndag';			# $sv_weekday
	$sv_weekday_definite = 		"måndagen|tisdagen|onsdagen|torsdagen|fredagen|lördagen|söndagen";	# $sv_weekday_definite
	$sv_weekday_abbreviation =		'månd\.?|mån\.?|tisd\.?|tis\.?|tis\.?|onsd\.?|ons\.?|torsd\.?|tors\.?|tor\.?|fred\.?|fre\.?|lörd\.?|lör\.?|sönd\.?|sön\.?|må\.?|ti\.?|on\.?|to\.?|fr\.?|lö\.?|sö\.?';	# $sv_weekday_abbreviation
	%sv_weekday_abbreviation_map =	qw( månd. måndag månd måndag mån. måndag mån måndag må. måndag må måndag tisd. tisdag tisd tisdag tis. tisdag tis tisdag ti. tisdag ti tisdag onsd. onsdag onsd onsdag ons. onsdag ons onsdag on. onsdag on onsdag torsd. torsdag torsd torsdag tors. torsdag tors torsdag tor. torsdag tor torsdag to. torsdag to torsdag fred. fredag fred fredag fre. fredag fre fredag fr. fredag fr fredag lörd. lördag lörd lördag lör. lördag lör lördag lö. lördag lö lördag sönd. söndag sönd söndag sön. söndag sön söndag sö. söndag sö söndag );	# %sv_weekday_abbreviation

	$en_weekday =				'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday';		# $en_weekday
	$en_weekday_abbreviation =		'Mond\.?|Mon\.?|Tuesd\.?|Tues\.?|Tues\.?|Wedn\.?|Wed\.?|Thursd\.?|Thurs\.?|tor\.?|Frid\.?|Fri\.?|Sat\.?|Sun\.?|Mo\.?|Tu\.?|We\.?|th\.?|Fr\.?|Sa\.?|Su\.?';	# $en_weekday_abbreviation
	%en_weekday_abbreviation_map =		qw( mond. Monday mond Monday mon. Monday mon Monday mo. Monday mo Monday tuesd. Tuesday tuesd Tuesday tues. Tuesday tues Tuesday tu. Tuesday tu Tuesday wedn. Wednesday wedn Wednesday wed. Wednesday wed Wednesday we. Wednesday we Wednesday thursd. Thursday thursd Thursday thurs. Thursday thurs Thursday thu. Thursday thu Thursday th. Thursday th Thursday frid. Friday frid Friday fri. Friday fri Friday fr. Friday fr Friday sat. Satusday sat Satusday sa. Satusday sa Satusday sund. Sunday sund Sunday sun. Sunday sun Sunday su. Sunday su Sunday );	# %en_weekday_abbreviation

	# Words that signalize that it is a time expression
	$sv_time_trigger = "i|$sv_month|våren|sommaren|hösten|vintern|år|månad|påsken|påsk|julen|jul|midsommaren|midsommar|advent|född|död|åren|redan|sedan|sen|ännu|till|under|perioden|mellan|blev|av|före|från|född|f\.";	# $sv_time_words
	$en_time_trigger = "in|$en_month|spring|summer|autumn|fall|winter|year|month|easter|christmas|born|dead|years|already|since|to|under|perios|between|of|before";	# $en_time_words

	# Words that signalize that the following numeral is a phone number
	$sv_phone_trigger = '(text|txt|order)?(telefon|tel\.?|telefax|(order)?fax\.?|tfn\.?)(nr\.?|nummer)?';	# $sv_phone_words
	$en_phone_trigger = '(text|txt|order)?(telephone|tel\.?|telefax|(order)?fax\.?|tfn\.?)(no\.?|number)?';	# $en_phone_words


#********************************************************************#
#  ORTHOGRAPHY & GRAPHEMES
#********************************************************************#
	# Graphemes
	$xx_grapheme_vowel =		'a|o|u|å|e|i|y|ä|ö|ö|æ|é|è|ë|ê|í|ì|ï|î|á|à|â|ó|ò|ô|ú|ù|ü|û|ý|ÿ|æ|ø';	# $vowel
	$xx_grapheme_consonant =	'b|c|d|f|g|h|j|k|l|m|n|p|q|r|s|t|v|w|x|z|ñ|ć|ç';	# $consonant
	$xx_grapheme_character =	"$vowel|$consonant";	# characters

	$xx_grapheme_uc = 		'A-ZÅÄÖÆØÉÈÜÁ';	# $uc
	$xx_grapheme_lc = 		'a-zåäöæöéèüá';	# $lc
	$xx_grapheme_uc_lc = 	"$uc$lc";		# $letter

	# Superscript and subsctript
	$xx_grapheme_superscript = '¹⁰²ⁱ⁴⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿʰʱʲʳʴʵʶʷʸ\ʹ\ʺ\ʻ\ʼ\ʽʾʿˀˁ˜˟ˠˡˢˣˤͣͤͥͦͧͨͩͪͫͬͭͮͯᵃᵄᵅᵆᵈᵉᵊᵋᵌᵍᵎᵏᵐᵑᵒᵓᵖᵗᵘᵚᵙᵛᵜᵝᵞᵟᵠᵡᴬᴭᴮᴯᴰᴱᴲᴳᴴᴵᴶᴷᴸᴹᴺᴻᴼᴽᴾᵀᵁᵂᵸᶛᶜᶝᶞᶟᶠᶡᶢᶤᶥᶦᶧᶨᶩᶪᶫᶬᶭᶮᶯᶰᶱᶲᶳᶴᶵᶶᶷᶹᶸᶺᶻᶼᶽᶾᶿ᷀᷁';	# $superscript
	$xx_grapheme_subscript = '₀₁₂₃₅₆₇₈₉₊₋₌₍₎ₐₑₒₓₔᵢᵤᵥᵦᵧᵨᵩᵪ';	# $subscript

	# Delimiters and quotes
	$xx_delimiter_major =		'\.\!\?';	# $majorDelimiter
	$xx_delimiter_minor = 		'\.\!\?';	# $minorDelimiter

	$xx_delimiter_quote_double =	'\"\»\«\”\“';	# $doubleQuote
	$xx_delimiter_quote_single =	'\'\’\‘';	# $singleQuote
	$xx_delimiter_quote_single =	quotemeta($xx_delimiter_quote_single);	### Is this necessary?
	$xx_delimiter_quote 	=		"$doubleQuote$singleQuote";	# $quote

	$xx_delimiter =	"$majorDelimiter$minorDelimiter$quote";	# delimiter	### Should other be part of this?
	$xx_delimiter = 	quotemeta( $xx_delimiter );	#		## Is this necessary?

	$xx_delimiter_other = quotemeta"\©\§\@\#\£\%\&\/\[\]\=\{\}\´\`\¨\^\~\*\†\<\>\|\_\-\+\\";	# $otherDelimiter

	# Hyphens
	$xx_hyphens = '-|\–|\—|\―|\‒|\−';	# $hyphens


	# Superscript and subsctript
	$xx_grapheme_superscript = '¹⁰²ⁱ⁴⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿʰʱʲʳʴʵʶʷʸ\ʹ\ʺ\ʻ\ʼ\ʽʾʿˀˁ˜˟ˠˡˢˣˤͣͤͥͦͧͨͩͪͫͬͭͮͯᵃᵄᵅᵆᵈᵉᵊᵋᵌᵍᵎᵏᵐᵑᵒᵓᵖᵗᵘᵚᵙᵛᵜᵝᵞᵟᵠᵡᴬᴭᴮᴯᴰᴱᴲᴳᴴᴵᴶᴷᴸᴹᴺᴻᴼᴽᴾᵀᵁᵂᵸᶛᶜᶝᶞᶟᶠᶡᶢᶤᶥᶦᶧᶨᶩᶪᶫᶬᶭᶮᶯᶰᶱᶲᶳᶴᶵᶶᶷᶹᶸᶺᶻᶼᶽᶾᶿ᷀᷁';
	$xx_grapheme_subscript = '₀₁₂₃₅₆₇₈₉₊₋₌₍₎ₐₑₒₓₔᵢᵤᵥᵦᵧᵨᵩᵪ';

	# Morphology
	$sv_word_endings = 's|er|ers|ere|en|ens|et|ets|rne|rnes|erne|ernes|eren|erens|n|ns|t|ts';	#  $sv_word_endings
	$en_word_endings = 's';	#  $en_word_endings


#********************************************************************#
#  G2P
#********************************************************************#
our $xx_grapheme_g2p_cart = 'a|â|b|c|ç|d|e|é|è|ê|ë|f|g|h|i|î|ï|j|k|l|m|n|o|ó|ò|p|q|r|s|t|u|v|w|x|y|ü|z|å|ä|ä|ö|ô|à|ñ|á';	# $graphemesInCart



#********************************************************************#
#  PHONES AND BOUNDARIES AND CONVERSION
#********************************************************************#
	# Path to conversion table
	$path_conversion_table = "data/pron/conversion_table.txt";		### Change! Hard coded in file where it's read.

	#********************************************************************#
	# TPA
	# Phones - default is TPA, which is used internally
	# Vowels
	$xx_phones_vowels_tpa =	'au|eu|öw|ai|ei|åi|eë|ië|uë|ö3:|ö3|ö2:|ö|ä3:|ä3|ä2:|ä|e2:|e3|e|ë|a2:|a3:|a|i2:|i3|i|y2:|y|u4:|u4|u2:|u3|u|o2:|o3|o|å2:|å|en|on|an';	# $tpa_vowel, $phonesVowel
	$xx_phones_consonant_tpa =	'rs|rt|rd|rn|rl|sj3|sj|tj3|tj|p|b|th|t|dh|d|k|g|m|ng|n|s|rs3|rs4|rs|j3|j|z|f|v|w|l|h|r3|r0|r';	# $phonesConsonant
	$xx_phones_tpa =		"$phonesVowel|$phonesConsonant";	# $phones

	# Boundaries
	$sv_boundary_word_tpa = 		'|';		# $word_boundary
	$en_boundary_word_tpa = 		'|';		# $word_boundary
	$sv_boundary_compound_tpa = 	'-';		# $compound_boundary
	$en_boundary_compound_tpa =		'~';		# $compound_boundary if $lang eq 'en'
	$sv_boundary_morph_tpa =		'~';		# -
	$xx_boundary_syllable_tpa =		'$';		# -

	# Syllalbe onsets
	$sv_syllable_onset =	'rs rt|rs rn|rs rl|rs [pkmv]|s [ptk] r|s [ptkmnvl]|[td] [rv]|[kg] [rlvn]|[pbf] [rlj]|v r|[ptkpdg] r3|n j';	# $cOnset
	$en_syllable_onset =	's [ptkbdg] (?:r3|w)|s [ptkbdgmnvw]|[tdkg] (?:r3|v|w)]|pbf (?:r3|l|j|w)';						# $cOnsetEng

	#********************************************************************#
	# Cereproc
	# Vowels
	$sv_phones_vowels_cereproc =	'ii|i|yy|y|ee|eh|e|eex|aae|ae|ooe|oe|uu|u|u|uux|ux|oo|o|aa|a|ah|au|eu|ei|ai|oi|ou|e@|i@|u@|an|in|on';	# $cp_swe_vowel
	$en_phones_vowels_cereproc =	'ii|i|e|e|@|e|a|@@|oo|o|uu|u|aa|uh|au|ei|ai|oi|ou|e@|i@|u@';	# $cp_eng_vowel

	# Boundaries
	$sv_boundary_word_cereproc = 	'|';		# $word_boundary
	$en_boundary_word_cereproc = 	'|';		# $word_boundary
	$sv_boundary_compound_cereproc = 	'-';		# $compound_boundary
	$en_boundary_compound_cereproc =	'~';		# $compound_boundary if $lang eq 'en'
	$sv_boundary_morph_cereproc =	'~';		# -
	$xx_boundary_syllable_cereproc =	'$';		# -


	#********************************************************************#
	# IPA
	# Vowels
	$xx_phones_vowels_ipa =		'aiː|ɪ|yː|ʏ|eː|ɛ|e|ə|ɛː|ɛ|æː|æ|øː|ø|œː|œ|uː|u|u|oː|ɔ|ʉː|ɵ|ʉ|ʊː|ʊ|ɒː|a|aː|aʊ|ɛʊ|eɪ|aɪ|ɔɪ|əʊ|eə|ɪə|ʊə|̃ɑ̃|̃ɛ̃|õ|̃œ̃';	# $ipa_vowel

	# Boundaries
	#$sv_boundary_word_ipa = 		'|';
	#$en_boundary_word_ipa = 		'|';
	#$sv_boundary_compound_ipa = 	'-';		# $compound_boundary
	#$en_boundary_compound_ipa =	'~';		# $compound_boundary if $lang eq 'en'
	#$sv_boundary_morph_ipa =		'~';		# -
	$xx_boundary_syllable_ipa =		'.';		# -

	#********************************************************************#
	# Tacotron_1
	# Vowels
	$xx_phones_vowels_nst =			'a*U|oU|2:|9|E:|E|e:|e|A:|a|i:|I|y:|y|}:|u0|o:|O';	# $nst_vowel

	# Boundaries
	$xx_phones_vowels_tacotron_1 =		'au|eu|öw|öö:|öö|ö:|ö|ää:|ää|ä:|ä|e:|e|ë|a:|a|i:|i|y:|y|u:|u|o:|o|å:|å';	# $tacotron_1_vowel
	$xx_boundary_pause_tacotron_1 = 		'/';		# $word_boundary
	$xx_boundary_word_tacotron_1 = 		'&';		# $word_boundary
	#$xx_boundary_compound_tacotron_1 = 	'-';		# $compound_boundary
	#$xx_boundary_morph_tacotron_1 =		'~';		# -
	#$xx_boundary_syllable_tacotron_1 =	'$';		# -
	$xx_boundary_end_tacotron_1 = 		',';		# -

#********************************************************************#
# TRANSLATIONS
#********************************************************************#
our $sv_word_decimal_separator = 'komma';	# $decimal_separator_word
our $en_word_decimal_separator = 'point';	# $decimal_separator_word

our $sv_word_and = 'och';		# $and_word
our $en_word_and = 'and';		# $and_word

our $sv_word_to = 'till';		# $to_word
our $en_word_to = 'to';			# $to_word

our $sv_word_in = 'i';			# $in_word
our $en_word_in = 'in';			# $in_word

our $sv_word_hundred = 'hundra';	# $hundred_word
our $en_word_hundred = 'hundred';	# $hundred_word

our $sv_word_point = 'punkt';		# $period_word
our $en_word_point = 'point';		# $period_word

our $sv_word_dot = 'punkt';		# $period2_word
our $en_word_dot= 'dot';			# $period2_word

our $sv_word_question_mark = 'frågetecken';	# $question_mark_word
our $en_word_question_mark = 'question|mark';	# $question_mark_word

our $sv_word_exclamation_mark = 'utropstecken';	# $exclamation_mark_word
our $en_word_exclamation_mark = 'exclamation|mark';	# $exclamation_mark_word

our $sv_plus_word = 'plus';		# $plus_word
our $en_plus_word = 'plus';		# $plus_word

our $sv_word_dash = 'streck';		# $dash_word
our $en_word_dash = 'dash';		# $dash_word

our $sv_word_slash = 'snedstreck';	# $slash_word
our $en_word_slash = 'slash';		# $slash_word

our $sv_word_section_sign = 'paragraf';	# $section_sign_word
our $en_word_section_sign = 'section|sign';	# $section_sign_word

our $sv_word_section_sign_def_sin = 'paragrafen';	# $section_sign_def_sin_word
our $en_word_section_sign_def_sin = 'section|sign';	# $section_sign_def_sin_word

our $sv_word_section_sign_def_plun = 'paragraferna';	# $section_sign_def_plu_word
our $en_word_section_sign_def_plu = 'section|sign';	# $section_sign_def_plu_word

our $sv_word_at_sign = 'snabel-a';	# $at_sign_word
our $en_word_at_sign = 'at|sign';	# $at_sign_word

our $sv_word_at = 'snabel-a';		# $at_word
our $en_word_at = 'at';			# $at_word

our $sv_word_percent_sign = 'procenttecken';	# $percent_sign_word
our $en_word_percent_sign = 'percent|sign';	# $percent_sign_word

our $sv_word_percent = 'procent';	# $percent_word
our $en_word_percent = 'percent';	# $percent_word

our $sv_word_times = 'gånger';		# $times_word
our $en_word_times = 'times';		# $times_word

our $sv_word_per_mille_sign = 'promilletecken';	# $per_mille_sign_word
our $en_word_per_mille_sign = 'per|mille|sign';	# $per_mille_sign_word

our $sv_word_permille = 'promille';	# $per_mille_word
our $en_word_permille = 'per|mille';	# $per_mille_word

our $sv_word_ampersand = 'och-tecken';	# $ampersand_word
our $en_word_ampersand = 'ampersand';	# $ampersand_word

our $sv_word_equals_word = 'är|lika|med';	# $equals_word
our $en_word_equals_word = 'equals';		# $equals_word

our $sv_word_tilde = 'tilde';	# $tilde_word
our $en_word_tilde = 'to';	# $tilde_word

our $sv_word_born = 'född';	# $born_word
our $en_word_born = 'born';	# $born_word

our $sv_word_dead = 'avliden';	# $dead_word
our $en_word_dead = 'dead';	# $dead_word

our $sv_word_dagger = 'korstecken';	# $dagger_word
our $en_word_dagger = 'dagger';		# $dagger_word

our $sv_word_a_half_utr = 'en|halv';	# $a_half_word_utr
our $en_word_a_half_utr = 'a|half';	# $a_half_word_utr

our $sv_word_a_half_neu = 'ett|halvt';	# $a_half_word_neu
our $en_word_a_half_neu = 'a|half';	# $a_half_word_neu

our $sv_word_a_quarter = 'en|fjärdedel';	# $one_quarter_word
our $en_word_a_quarter = 'a|quarter';		# $one_quarter_word

our $sv_word_three_quarters = 'tre|fjärdedelar';	# $three_quarters_word
our $en_word_three_quarters = 'three|quarters';	# $three_quarters_word

our $sv_word_colon = 'kolon';	# $colon_word
our $en_word_colon = 'colon';	# $colon_word

our $sv_word_degree = 'grad';	# $degree_word
our $en_word_degree = 'degree';	# $degree_word

our $sv_word_degrees = 'grader';	# $degrees_word
our $en_word_degrees = 'degrees';	# $degrees_word

our $sv_word_underscore = 'understreck';	# $underscore_word
our $en_word_underscore = 'underscore';	# $underscore_word

our $sv_word_vertical_bar = 'lodstreck';	# $vertical_bar_word
our $en_word_vertical_bar = 'vertical|bar';	# $vertical_bar_word

our $sv_word_less_than_sign = 'mindre-än-tecken';	# $less_than_sign_word
our $en_word_less_than_sign = 'less|than|sign';	# $less_than_sign_word

our $sv_word_greater_than_sign = 'större-än-tecken';	# $greater_than_sign_word
our $en_word_greater_than_sign = 'greater|than|sign';# $greater_than_sign_word

our $sv_word_less_than = 'är|mindre|än';	# $less_than_word
our $en_word_less_than = 'is|less|than';	# $less_than_word

our $sv_word_greater_than = 'är|större|än';	# $greater_than_word
our $en_word_greater_than = 'is|greater|than';# $greater_than_word

our $sv_word_dollar_sign = 'dollar_sign_word';# $dollar_sign_word
our $en_word_dollar_sign = 'dollar|sign';	# $dollar_sign_word

our $sv_word_dollar_sin = 'dollar';	# $dollar_sin_word
our $en_word_dollar_sin = 'dollar';	# $dollar_sin_word

our $sv_word_dollar_plu = 'dollar';	# $dollar_plu_word
our $en_word_dollar_plu = 'dollars';	# $dollar_plu_word

our $sv_word_pound_sign = 'pundtecken';# $pound_sign_word
our $en_word_pound_sign = 'pound|sign';# $pound_sign_word

our $sv_word_pound_sin = 'pund';	# $pound_sin_word
our $en_word_pound_sin = 'pound';	# $pound_sin_word

our $sv_word_pound_plu = 'pound';	# $pound_plu_word
our $en_word_pound_plu = 'pounds';	# $pound_plu_word

our $sv_word_euro_sign = 'eurotecken';	# $euro_sign_word
our $en_word_euro_sign = 'euro|sign';	# $euro_sign_word

our $sv_word_euro_sin = 'euro';		# $euro_sin_word
our $en_word_euro_sin = 'euro';		# $euro_sin_word

our $sv_word_euro_plu = 'euro';		# $euro_plu_word
our $en_word_euro_plu = 'euros';	# $euro_plu_word

our $sv_word_cent_sign = 'centtecken';	# $cent_sign_word
our $en_word_cent_sign = 'cent|sign';	# $cent_sign_word

our $sv_word_cent_sin = 'cent';		# $cent_sin_word
our $en_word_cent_sin = 'cent';		# $cent_sin_word

our $sv_word_cent_plu = 'cent';		# $cent_plu_word
our $en_word_cent_plu = 'cents';	# $cent_plu_word

our $sv_word_yen_sign = 'yentecken';	# $yen_sign_word
our $en_word_yen_sign = 'yen|sign';	# $yen_sign_word

our $sv_word_yen_sin = 'yen';		# $yen_sin_word
our $en_word_yen_sin = 'yen';		# $yen_sin_word

our $sv_word_yen_plu = 'yen';		# $yen_plu_word
our $en_word_yen_plu = 'yens';		# $yen_plu_word
#********************************************************************#


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