package MTM::Vars;

#****************************************************#
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
#****************************************************#

# SSML vars
our @phoneme_types;
our @sub_types;
our @break_types;

our $eval_flag = 0;		# Flag for Kestrel-ish evaluation

our $do_sent_split = 1;		# CT 2022-05-10
#our $do_sent_split = 0;		# CT 2022-05-10

# This is for decomposition into compound parts: the minimum number of characters in the compounda part that should be considered.	CT 2020-12-02
our $minTokens = 2;

# This is set to other values if preparing for e.x. David TTS.	CT 2020-12-02
#our $tts = 'cereproc';
our $tts = 'mtm';
#our $tts = 'tacotron_1';
our $runmode = 'cereproc';

#**********************************#
# CONFIG
our $lang = 'sv';
#our $lang = 'en';

#our $use_dict = 'NST';
our $use_dict = 'MTM';

#**************************************************************#
# PAHTS
our $nst_path = "data/dictionaries/NST";

#**********************************#
our $and_word = 'och';
$and_word = 'and' if $lang eq 'en';

our $to_word = 'till';
$to_word = 'to' if $lang eq 'en';

our $in_word = 'i';
$in_word = 'in' if $lang eq 'en';

our $hundred_word = 'hundra';
$hundred_word = 'hundred' if $lang eq 'en';

our $period_word = 'punkt';
$period_word = 'point' if $lang eq 'en';

our $period2_word = 'punkt';
$period2_word = 'dot' if $lang eq 'en';

our $question_mark_word = 'frågetecken';
$question_mark_word = 'question|mark' if $lang eq 'en';

our $exclamation_mark_word = 'utropstecken';
$exclamation_mark_word = 'exclamation|mark' if $lang eq 'en';

our $plus_word = 'plus';
$plus_word = 'plus' if $lang eq 'en';

our $dash_word = 'streck';
$dash_word = 'dash' if $lang eq 'en';

our $slash_word = 'snedstreck';
$slash_word = 'slash' if $lang eq 'en';

our $backslash_word = 'omvänt|snedstreck';
$backslash_word = 'backslash' if $lang eq 'en';

our $section_sign_word = 'paragraf';
$section_sign_word = 'section|sign' if $lang eq 'en';

our $section_sign_def_sin_word = 'paragraferna';
$section_sign_def_sin_word = 'section|sign' if $lang eq 'en';

our $section_sign_def_plu_word = 'paragrafen';
$section_sign_def_plu_word = 'section|sign' if $lang eq 'en';

our $at_sign_word = 'snabel-a';
$at_sign_word = 'at|sign' if $lang eq 'en';

our $at_word = 'snabel-a';
$at_word = 'at' if $lang eq 'en';

our $percent_sign_word = 'procenttecken';
$percent_sign_word = 'percent|sign' if $lang eq 'en';

our $percent_word = 'procent';
$percent_word = 'percent' if $lang eq 'en';

our $times_word = 'gånger';
$times_word = 'times' if $lang eq 'en';

our $per_mille_sign_word = 'promilletecken';
$per_mille_sign_word = 'per|mille|sign' if $lang eq 'en';

our $per_mille_word = 'promille';
$per_mille_word = 'per|mille' if $lang eq 'en';

our $ampersand_word = 'och-tecken';
$ampersand_word = 'ampersand' if $lang eq 'en';

our $equals_word = 'är|lika|med';
$equals_word = 'equals' if $lang eq 'en';

our $tilde_word = 'tilde';
$tilde_word = 'tilde' if $lang eq 'en';

our $born_word = 'född';
$born_word = 'born' if $lang eq 'en';

our $dead_word = 'avliden';
$dead_word = 'dead' if $lang eq 'en';

our $dagger_word = 'korstecken';
$dagger_word = 'dagger' if $lang eq 'en';

our $a_half_word_utr = 'en|halv';
$a_half_word_utr = 'a|half' if $lang eq 'en';

our $a_half_word_neu = 'ett|halvt';
$a_half_word_neu = 'a|half' if $lang eq 'en';

our $one_quarter_word = 'en|fjärdedel';
$one_quarter_word = 'one|quarter' if $lang eq 'en';

our $three_quarters_word = 'tre|fjärdedelar';
$three_quarters_word = 'three|quarters' if $lang eq 'en';

our $colon_word = 'kolon';
$colon_word = 'colon' if $lang eq 'en';

our $degree_word = 'grad';
$degree_word = 'degree' if $lang eq 'en';

our $degrees_word = 'grader';
$degrees_word = 'degrees' if $lang eq 'en';

our $underscore_word = 'understreck';
$underscore_word = 'underscore' if $lang eq 'en';

our $vertical_bar_word = 'lodstreck';
$vertical_bar_word = 'vertical|bar' if $lang eq 'en';

our $less_than_sign_word = 'mindre-än-tecken';
$less_than_sign_word = 'less|than|sign' if $lang eq 'en';

our $greater_than_sign_word = 'större-än-tecken';
$greater_than_sign_word = 'greater|than|sign' if $lang eq 'en';

our $less_than_word = 'är|mindre|än';
$less_than_word = 'is|less|than' if $lang eq 'en';

our $greater_than_word = 'är|större|än';
$greater_than_word = 'is|greater|than' if $lang eq 'en';

our $dollar_sign_word = 'dollartecken';
$dollar_sign_word = 'dollar|sign' if $lang eq 'en';

our $dollar_sin_word = 'dollar';
$dollar_sin_word = 'dollar' if $lang eq 'en';

our $dollar_plu_word = 'dollar';
$dollar_plu_word = 'dollars' if $lang eq 'en';

our $pound_sign_word = 'pundtecken';
$pound_sign_word = 'pound|sign' if $lang eq 'en';

our $pound_sin_word = 'pund';
$pound_sin_word = 'pound' if $lang eq 'en';

our $pound_plu_word = 'pund';
$pound_plu_word = 'pounds' if $lang eq 'en';

our $euro_sign_word = 'eurotecken';
$euro_sign_word = 'euro|sign' if $lang eq 'en';

our $euro_sin_word = 'euro';
$euro_sin_word = 'euro' if $lang eq 'en';

our $euro_plu_word = 'euro';
$euro_plu_word = 'euros' if $lang eq 'en';

our $cent_sign_word = 'centtecken';
$cent_sign_word = 'cent|sign' if $lang eq 'en';

our $cent_sin_word = 'cent';
$cent_sin_word = 'cent' if $lang eq 'en';

our $cent_plu_word = 'cent';
$cent_plu_word = 'cents' if $lang eq 'en';

our $yen_sign_word = 'yentecken';
$yen_sign_word = 'yen|sign' if $lang eq 'en';

our $yen_sin_word = 'yen';
$yen_sin_word = 'yen' if $lang eq 'en';

our $yen_plu_word = 'yen';
$yen_plu_word = 'yens' if $lang eq 'en';


our $decimal_separator = ',';
$decimal_separator = '\.' if $lang eq 'en';

our $thousand_separator = '\.';
$thousand_separator = '[,\.]' if $lang eq 'en';

our $decimal_separator_word = 'komma';
$decimal_separator_word = 'point' if $lang eq 'en';



#**********************************#
our %sv_num_0_9 = qw(
0	noll
1	ett
2	två
3	tre
4	fyra
5	fem
6	sex
7	sju
8	åtta
9	nio
);

our %sv_num_10_19 = qw(
10	tio
11	elva
12	tolv
13	tretton
14	fjorton
15	femton
16	sexton
17	sjutton
18	arton
19	nitton
);

our %sv_num_20_90 = qw(
2	tjugo
3	trettio
4	fyrtio
5	femtio
6	sextio
7	sjuttio
8	åttio
9	nittio
);

#our %sv_numeral_map = qw
#tre	tredje
#fyra	fjärde
#fem	femte
#sex	sjätte
#sju	sjunde
#åtta	åttonde
#nio	nionde
#tio	tionde
#elva	elfte
#tolv	tolfte
#tretton	trettonde
#fjorton	fjortonde
#femton	femtonde
#sexton	sextonde
#sjutton	sjuttonde
#arton	artonde
#nitton	nittonde
#tjugo	tjugonde
#trettio	trettionde
#fyrtio	fyrtionde
#femtio	femtionde
#sextio	sextionde
#sjuttio	sjuttionde
#åttio	åttionde
#nittio	nittionde
#hundra	hundrade
#tusen	tusende
#en\|miljon	miljonte
#biljon	biljonte
#triljon	triljonte
#);

#*************************************************#
# English number expansion
our %en_num_0_9 = qw(
0	zero
1	one
2	two
3	three
4	four
5	five
6	six
7	seven
8	eight
9	nine
);

our %en_num_10_19 = qw(
10	ten
11	eleven
12	twelve
13	thirteen
14	fourteen
15	fifteen
16	sixteen
17	seventeen
18	eighteen
19	nineteen
);

our %en_num_20_90 = qw(
2	twenty
3	thirty
4	forty
5	fifty
6	sixty
7	seventy
8	eighty
9	ninety
);

#our %en_numeral_map = qw
#one	first
#two	second
#three	third
#four	fourth
#five	fifth
#six	sixth
#seven	seventh
#eight	eighth
#nine	ninth
#ten	tenth
#eleven	eleventh
#twelve	twelfth
#tretton	thirteenth
#fourteen	fourteenth
#fifteen	fifteenth
#sixteen	sixteenth
#seventeen	seventeenth
#eighteen	eighteenth
#nineteen	nineteenth
#twenty	twentieth
#thirty	thirtieth
#forty	fortieth
#fifty	fiftieth
#sixty	sixtieth
#seventy	seventieth
#eighty	eightieth
#ninety	ninetieth
#hundred	hundredth
#thousand	thousandth
#million	millionth
#billion	billionth
#trillion	trillionth
#);

#*************************************************#
# Moved in from TPBTag.pl
our @AllPossTags = qw(RG0S RGCS RGPS RGSS AQC00G0S AQC00N0S AQPMSGDS AQPMSNDS AQPNSGIS AQPNSNIS AQPNSN0S AQPUSGIS AQPUSNIS AQPUSN0S AQP0PNIS AQP0PG0S AQP0PN0S AQP0SGDS AQP0SNDS AQP00NIS AQP00N0S AQSMSGDS AQSMSNDS AQS0PNDS AQS0PNIS AQS00NDS AQS00NIS NCNPG@DS NCNPN@DS NCNPG@IS NCNPN@IS NCNSG@DS NCNSN@DS NCNSG@IS NCNSN@IS NCUPG@DS NCUPN@DS NCUPG@IS NCUPN@IS NCUSG@DS NCUSN@DS NCUSG@IS NCUSN@IS AF0MSGDS AF0MSNDS AF0NSNIS AF0USGIS AF0USNIS AF00PG0S AF00PN0S AF00SGDS AF00SNDS AP000G0S AP000N0S NP00G@0S NP00N@0S MC00G0S MC00N0S V@M0AS V@M0PS V@N0AS V@N0PS AKT AKT SFO V@IPAS V@IPPS V@IIAS V@IIPS V@IUAS V@IUPS); 


# Phones - vowels and consonants
our @phonesVowel	=	qw(au eu ou ai ei oi eex iex uex oe: oe ö: ö ae: ae ä: ä e: eh ex e a: aa: a i: ih i y: y uw: uw uu: uh uu u: oh u o: o en on an);
our @phonesConsonant	=	qw(rs rt rd rn rl xx x tc c p b th t dh d k g m ng n s zh rs dj j z f v w l h rh rx r0 r);

#our @phonesVowel	=	qw(au eu öw ai ei åi eë ië uë ö3: ö3 ö2: ö ä3: ä3 ä2: ä e2: e3 e ë a2: a3: a i2: i3 i y2: y u4: u4 u2: u3 u o2: o3 o å2: å en on an);
#our @phonesConsonant	=	qw(rs rt rd rn rl sj3 sj tj3 tj p b th t dh d k g m ng n s rs3 rs j3 j z f v w l h r3 r4 r0 r);

our $phonesVowel	=	join'|', @phonesVowel;
our $phonesConsonant	=	join'|', @phonesConsonant;

#$phonVowel		=	'[aAeE\@oOuQiy26I]';
#$phonConsonant	=	'[pbtdDkgmnNsSfvwRlhTr]';
our $phones		=	$phonesVowel . "|" . $phonesConsonant;


our $cOnset	=	'rs rt|rs rn|rs rl|rs [pkmv]|s [ptk] r|s [ptkmnvl]|[td] [rv]|[kg] [rlvn]|[pbf] [rlj]|v r|[ptkpdg] rh|n j';
our $cOnsetEng	=	's [ptkbdg] (?:rh|w)|s [ptkbdgmnvw]|[tdkg] (?:rh|v|w)]|pbf (?:rh|l|j|w)';

# Orthography
our @vowel		=	qw( a o u å e i y ä ö ö æ é è ë ê í ì ï î á à â ó ò ô ú ù ü û ý ÿ æ ø );
our @consonant		=	qw( b c d f g h j k l m n p q r s t v w x z ñ ć ç);
our $vowel		=	join"|", @vowel;
our $consonant		=	join"|", @consonant;
our $characters		=	"$vowel|$consonant";

#our $cOnsetOrth	=	'sch[tnlpkmv]|s[ptk]r|s[ptkmnvlwj]|[td][rv]|[kg][rlvn]|[pbf][rlj]|v[rj]|[ptkpdg]r3|nj|pp|ttr?|ck[lrn]?|bb[lr]?|dd[r]?|gg[lrn]?|ss[lnmptkbdg]?|ff[lrn]?|mm|nn|rr|ll|r[tdsnl]|sz';
#our $cOnsetOrth		=	'sch[jlmnrw|schhh]|szcz|tsch|chr|mc[kl]|sc[hl]|sk[jrv]|sp[jlr]|st[jr]|thr|b[jlr]|c[hlr]|d[jrvw]|f[jlnr]|g[hjlnr]|h[jmv]|k[jlnrv]|l[j]|m[cjkmr]|n[j]|p[fhjlnrs]|q[v]|r[h]|s[cfhjklmnpqrtvw]|t[hjrv]|v[lr]|w[hr]|z[l]|b|c|d|f|g|h|j|k|l|m|n|p|q|r|s|t|v|w|x|z';
our $cOnsetOrth		=	'sch[jlmnrvw]|ch[lr]|mc[cdgk]|sc[hr]|sk[jlrv]|sp[jlr]|st[jr]|tc[h]|th[r]|b[jlr]|c[hlrsvz]|d[jrz]|f[jlnr]|g[hjlnrw]|h[bjrsvw]|k[jlnrvw]|l[j]|m[cj]|n[j]|p[fhjlrs]|q[vw]|r[w]|s[cfhjklmnpqtvwz]|t[hjrsvwz]|v[r]|w[hr]|z[hjlsv]';

#our $cOnsetEng		=	's [ptkbdg] (?:r3|w)|s [ptkbdgmnvw]|[tdkg] (?:r3|v|w)]|pbf (?:r3|l|j|w)';

# Graphemes in cart tree - don't change!
our $graphemesInCart = 'a|â|b|c|ç|d|e|é|è|ê|ë|f|g|h|i|î|ï|j|k|l|m|n|o|ó|ò|p|q|r|s|t|u|v|w|x|y|ü|z|å|ä|ä|ö|ô|à|ñ|á';

# Letter case
our $uc = 'A-ZÅÄÖÆØÉÈÜÁ';
our $lc = 'a-zåäöæöéèüá';
our $letter = "$uc$lc";

#***************************************************************#
# Delimiters and quotes				
#***************************************************************#
our $majorDelimiter	=	'\.\!\?';
our $minorDelimiter	=	'\,\;\:\(\)\/';
our $doubleQuote	=	'\"\»\«\”\“';
our $singleQuote	=	'\'\’\‘';
$singleQuote		=	quotemeta($singleQuote);
our $quote		=	"$doubleQuote$singleQuote";
our $delimiter		=	"$majorDelimiter$minorDelimiter$quote";
our $otherDelimiter	=	quotemeta"\©\§\@\#\£\%\&\/\[\]\=\{\}\´\`\¨\^\~\*\†\<\>\|\_\-\+\\";

$delimiter = quotemeta( $delimiter );

#***************************************************************#
# Superscript and subscript
#***************************************************************#
our $superscript = '¹⁰²ⁱ⁴⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿʰʱʲʳʴʵʶʷʸ\ʹ\ʺ\ʻ\ʼ\ʽʾʿˀˁ˜˟ˠˡˢˣˤͣͤͥͦͧͨͩͪͫͬͭͮͯᵃᵄᵅᵆᵈᵉᵊᵋᵌᵍᵎᵏᵐᵑᵒᵓᵖᵗᵘᵚᵙᵛᵜᵝᵞᵟᵠᵡᴬᴭᴮᴯᴰᴱᴲᴳᴴᴵᴶᴷᴸᴹᴺᴻᴼᴽᴾᵀᵁᵂᵸᶛᶜᶝᶞᶟᶠᶡᶢᶤᶥᶦᶧᶨᶩᶪᶫᶬᶭᶮᶯᶰᶱᶲᶳᶴᶵᶶᶷᶹᶸᶺᶻᶼᶽᶾᶿ᷀᷁';
our $subscript = '₀₁₂₃₅₆₇₈₉₊₋₌₍₎ₐₑₒₓₔᵢᵤᵥᵦᵧᵨᵩᵪ';


#***************************************************************#
# Endings
#***************************************************************#
our $sv_acronym_endings = 's|er|ers|en|ens|et|ets|are|ares|aren|arens|an|ans|erna|ernas|arna|arnas|orna|ornas|n|ns|t|ts';
our $sv_ordinal_endings = '[:\'\.]?(?:onde|nde|dje|de|te|a|e)';
our $sv_word_endings = 's|er|ers|ere|en|ens|et|ets|rne|rnes|erne|ernes|eren|erens|n|ns|t|ts';

our $en_acronym_endings = 's';
our $en_ordinal_endings = '[:\'\.]?(?:st|nd|rd|th)';
our $en_word_endings = 's';

#***************************************************************#
# Ordinal formats
#***************************************************************#
our $sv_ordinal_words = 'uppl\.?|st\.?|\&paraett\;|\&paratva\;|upplaga|upplagan|kapitlet|paragrafen|dir\.';	# 200527 \§|kap\.?|\§\§|kapitel|paragraf|
our $en_ordinal_words = 'paragraph|chapter';

our $word_boundary = '|';
$word_boundary = '|' if $MTM::Vars::lang eq 'en';

our $compound_boundary = '-';
$compound_boundary = '~' if $MTM::Vars::lang eq 'en';


our $hyphens = '-|\–|\—|\―|\‒|\−';

our $sv_units = "matskedar|matsked|teskedar|tesked|knivsudd|msk\.|smsk|tsk\.|tsk|liter|deciliter|centiliter|milliliter|kilogram|kilo|hektogram|hekto|gram|kilometer|meter|decimeter|centimeter|millimeter|kg\.|kg|hg\.|hg|g\.|g|dl\.|dl|cl\.|cl|ml\.|ml|l\.|l|km\.|km|m\.|m|dm\.|dm|cm\.|cm|mm\.|mm";
our $en_units = "tablespoons|tablespoon|teaspoons|teaspoon|tbsp\.|tbsp|tsp\.|tsp|pounds|pounds|pound|litres|litres|deciliters|deciliter|centiliters|centiliter|milliliters|milliliters|kilograms|kilogram|kilos|kilo|hectograms|hectogram|hectos|hecto|grams|gram|yards|yard|miles|mile|kilometers|kilometer|meters|meter|decimeters|decimiter|centimeters|centimeter|millimeters|millimeter|lb\.|lb|kg\.|kg|hg\.|hg|g\.|g|dl\.|dl|cl\.|cl|ml\.|ml|l\.|l|km\.|km|m\.|m|dm\.|dm|cm\.|cm|mm\.|mm";

our $law_words = '\§|\§\§|kap\.?|st\.?';

### Not used
###our $lawref_regex = '\d+|[a-z]| |,|kap\.|kap|kapitel|-|och|till|st\.|st';		# CT 210906

# Fractions
our $fraction = '\½|\¼|\¾|1\/2|1\/4|3\/4';

# Year
# 1100 - 2999
our $year_format = '1[1-9][0-9][0-9]|2[0-9][0-9][0-9]';
#our $yearEnding = 'erne|ernes|rne|rnes';

#|00 - 99
our $year_short_format = '[0-9][0-9]';

# Words that signalize that the following numerals probably is an interval.
our $sv_interval_words_lc = 'kapitel|kap.|kap|sidan|nummer|från|skala|skalan';
our $en_interval_words_lc = 'chapter|ch.|ch|chs|chs|page|from|between';

# Words that signalize that the preceding numerals might be an interval.
our $sv_interval_words_rc = 'minuter|min.|min|procent|pct.|pct|%|gram|g.|g|kg.|kg|kilogram|kilo';
our $en_interval_words_rc = 'minutes|min.|min|percent|pct.|pct|%|gram|g.|g|kg.|kg|kilogram|kilo';

# Words that signalize that the previous numeral probably is a year.
our $sv_year_words_rc = '[fe]\. ?kr\.?|[åÅ]rs|\-|[a-z]';
our $en_year_words_rc = 'bc|ad|\-|[a-z]';
our $sv_remove_year_words = 'år|stycken|st\.?|dagar|månader';

# Months
our $sv_month = "januari|februari|mars|april|maj|juni|juli|augusti|september|oktober|november|december";
our $sv_month_abbreviation = 'jan\.?|febr\.?|feb\.?|mar\.?|apr\.?|maj|jun\.?|jul\.?|aug\.?|sept\.?|sep\.?|okt\.?|nov\.?|dec\.?';
our %sv_month_abbreviation = qw( jan. januari jan januari feb. februari feb februari mar. mars mar mars apr. april apr april maj maj jun. juni jun juni jul. juli jul juli aug. augusti aug augusti sep. september sept. september sep september sept september okt. oktober okt oktober nov. november nov november dec. december dec december );

our $en_month = "January|February|March|April|May|June|July|August|September|October|November|December";
our $en_month_abbreviation = 'jan\.?|febr\.?|feb\.?|mar\.?|apr\.?|may|jun\.?|jul\.?|aug\.?|sept\.?|sep\.?|oct\.?|nov\.?|dec\.?';
our %en_month_abbreviation = qw( jan. January jan January feb. February feb February mar. March mar March apr. April apr April May May jun. June jun June jul. July jul July aug. August aug August sep. September sept. September sep September sept September oct. October oct October nov. November nov November dec. December dec December );

our $en_month_letter_format = "$en_month|$en_month_abbreviation";

# Weekdays
our $sv_weekday = 'måndag|tisdag|onsdag|torsdag|fredag|lördag|söndag';
our $sv_weekday_abbreviation = 'månd\.?|mån\.?|tisd\.?|tis\.?|tis\.?|onsd\.?|ons\.?|torsd\.?|tors\.?|tor\.?|fred\.?|fre\.?|lörd\.?|lör\.?|sönd\.?|sön\.?|må\.?|ti\.?|on\.?|to\.?|fr\.?|lö\.?|sö\.?';
our $sv_weekday_definite = "måndagen|tisdagen|onsdagen|torsdagen|fredagen|lördagen|söndagen";
our %sv_weekday_abbreviation = qw( månd. måndag månd måndag mån. måndag mån måndag må. måndag må måndag tisd. tisdag tisd tisdag tis. tisdag tis tisdag ti. tisdag ti tisdag onsd. onsdag onsd onsdag ons. onsdag ons onsdag on. onsdag on onsdag torsd. torsdag torsd torsdag tors. torsdag tors torsdag tor. torsdag tor torsdag to. torsdag to torsdag fred. fredag fred fredag fre. fredag fre fredag fr. fredag fr fredag lörd. lördag lörd lördag lör. lördag lör lördag lö. lördag lö lördag sönd. söndag sönd söndag sön. söndag sön söndag sö. söndag sö söndag );

our $en_weekday = 'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday';
our $en_weekday_abbreviation = 'Mond\.?|Mon\.?|Tuesd\.?|Tues\.?|Tues\.?|Wedn\.?|Wed\.?|Thursd\.?|Thurs\.?|tor\.?|Frid\.?|Fri\.?|Sat\.?|Sun\.?|Mo\.?|Tu\.?|We\.?|th\.?|Fr\.?|Sa\.?|Su\.?';
our %en_weekday_abbreviation = qw( mond. Monday mond Monday mon. Monday mon Monday mo. Monday mo Monday tuesd. Tuesday tuesd Tuesday tues. Tuesday tues Tuesday tu. Tuesday tu Tuesday wedn. Wednesday wedn Wednesday wed. Wednesday wed Wednesday we. Wednesday we Wednesday thursd. Thursday thursd Thursday thurs. Thursday thurs Thursday thu. Thursday thu Thursday th. Thursday th Thursday frid. Friday frid Friday fri. Friday fri Friday fr. Friday fr Friday sat. Satusday sat Satusday sa. Satusday sa Satusday sund. Sunday sund Sunday sun. Sunday sun Sunday su. Sunday su Sunday );

# Words that signalize that it is a time expression
our $sv_time_words = "i|$sv_month|våren|sommaren|hösten|vintern|år|månad|påsken|påsk|julen|jul|midsommaren|midsommar|advent|född|död|åren|redan|sedan|sen|ännu|till|under|perioden|mellan|blev|av|före|från|född|f\.";
our $en_time_words = "in|$en_month|spring|summer|autumn|fall|winter|year|month|easter|christmas|born|dead|years|already|since|to|under|perios|between|of|before|from";

# Words that signalize that the following numeral is a phone number
our $sv_phone_words = '(text|txt|order)?(telefon|tel\.?|telefax|(order)?fax\.?|tfn\.?)(nr\.?|nummer)?';
our $en_phone_words = '(text|txt|order)?(telephone|tel\.?|telefax|(order)?fax\.?|tfn\.?)(no\.?|number)?';

#***************************************************************#
# Roman numbers formats
#***************************************************************#
our $romanLetters = 'ivxlcdm';
our $safeRomanNum = 'II|III|IV|V|VII|VIII|IX|X+I+|X+I+V+|X+V+|X+V+I+|M';
our $sv_roman_words = 'del|avsnitt|block|avdelning|kapitel|sidan|sida|figur|fig\.|rubrik|notreferens|avd\.|avd|kap\.|kap|NJA|version';
our $sv_roman_ordinal_ending = 'a|e|\:a|\:e';
our $sv_roman_genitive_ending = 's|\:s';
our $sv_roman_ending = "$sv_roman_ordinal_ending|$sv_roman_genitive_ending";
our %roman2arabic = qw(I 1 V 5 X 10 L 50 C 100 D 500 M 1000);

our $en_roman_words = 'part|section|block|chapter|pages|page|figure|fig\.||chapt\.|chapt|ch\.|ch|version';
our $en_roman_ordinal_ending = 'st|nd|rd|th';
our $en_roman_genitivie_ending = "s|\'s";
our $en_roman_ending = "$en_roman_ordinal_ending|$en_roman_genitivie_ending";

### NOT USED	our $validExprType = 'ACRONYM|ACRONYM COMPOUND|ABBREVIATION|INITIAL|DEFAULT|NUMERAL|ORDINAL|ROMAN INTERVAL|PHONE|INTERVAL|ROMAN ORDINAL|ROMAN|DECIMAL|YEAR INTERVAL|YEAR|FRACTION|MULTIWORD|DATE INTERVAL|DATE|TIME|CURRENCY|MATHS|EMAIL|FILENAME|URL|ZIPCODE|REFERENCE';
### NOT USED	our $defaultExprType = '-';

### NOT USED	our $validLang = 'swe|SWE|eng|ENG';
our $defaultLang = 'swe';

### NOT USED	our $validPos = 'NN|VB|JJ|PC|AB|KN|SN|HA|HP|PN|PS|DT|IN|IE|PM|PP|DL|RG|RO';
our $defaultPos = 'NN';
our $defaultMorph = 'UTR SIN IND NOM';

### NOT USED	our $validMorphDL = '(MID|MAD)';
### NOT USED	our $defaultMorphDL = 'MID';

### NOT USED	oour $validMorphNN = '(UTR|NEU|UTR\/NEU) (SIN|PLU) (IND|DEF) (NOM|GEN)';
### NOT USED	oour $defaultMorphNN = 'UTR SIN IND NOM';

### NOT USED	oour $validMorphVB = '(INF|PRS|PRT|SUP) (AKT|SFO)';
### NOT USED	oour $defaultMorphVB = 'PRS AKT';

### NOT USED	our $validMorphJJ = '(POS|KOM|SUP) (UTR|NEU|UTR\/NEU) (SIN|PLU) (IND|DEF) (NOM|GEN)';
### NOT USED	our $defaultMorphJJ = 'POS UTR SIN IND NOM';

### NOT USED	our $validMorphPC = '(POS|KOM|SUP) (UTR|NEU|UTR\/NEU) (SIN|PLU) (IND|DEF) (NOM|GEN)';
### NOT USED	our $defaultMorphPC = 'POS UTR SIN IND NOM';

### NOT USED	our $validMorphAB = '(POS|KOM|SUP|-)';
### NOT USED	our $defaultMorphAB = '-';

### NOT USED	our $validMorphPM = '(NOM|GEN)';
### NOT USED	our $defaultMorphPM = "NOM";

### NOT USED	our $validTextType = 'DEFAULT|SPORTS|LAWTEXT';
our $defaultTextType = '-';

### NOT USED	our $validPron = '.';
### NOT USED	our $defaultPron = '-';

### NOT USED	our $defaultPause = '-';
### NOT USED	our $defaultSSML = '-';
our $defaultExpansion = '-';
### NOT USED	our $defaultIsInDictionary= '0';
### NOT USED	our $defaultPronunciation = '-';
### NOT USED	our $defaultExpressionType = '-';

#***************************************************************#
# Pauses
#***************************************************************#
our $shortPause = '150';
our $sentPause = '300';
our $announcementPause 	= '150|150';	# Pause before and after announcement: 100ms|citat|100ms

#***************************************************************#
# Date formats
#***************************************************************#
# 1-9	10-19	20-29	30-31
our $date_digit_format	=	'[1-9]|1[0-9]|2[0-9]|3[01]';

### NOT USED	our $date31 = '[1-9]|[12][0-9]|3[01]';
### NOT USED	our $date30 = '[1-9]|[12][0-9]|30';
### NOT USED	our $date29 = '[1-9]|[12][0-9]';

# Months with letters, full form and abbreviations		CT 100601
our %sv_month_map = qw( jan. januari feb februari feb. februari febr. februar febr februar mar. mars apr. april jun. juni jul. juli aug. augusti sep. september sept. september okt. oktober nov. november dec. december );
our $sv_month_letter_format = 'januari|februari|mars|april|maj|juni|juli|augusti|september|oktober|november|december|jan\.?|feb\.?|mar\.?|apr\.?|jun\.?|jul\.?|aug\.?|sept?\.?|okt\.?|nov\.?|dec\.?';

our %en_month_map = qw( Jan. January Jan January Feb February Feb. February Febr. February Febr February mar. Match Apr. April Apr April Jun. June Jun June Jul. July Jul July Aug. August Aug August Sep. September Sep September Sept. September Sept September Oct. October Oct October Nov. November Nov November Dec. December Dec December);

# 1-9	10-12
our $month_digit_format = '[1-9]|1[0-2]';

# January, March, May, July, August, October, December
### NOT USED	our $month31 = '?:1|3|5|7|8|10|12';

# April, June, September, November
### NOT USED	our $month30 = '4|6|9|11';

# February
### NOT USED	our $month29 = '2';

# With "0" included
### NOT USED	our $monthDigit0 = '0[1-9]|1[12])';
#***************************************************************#
# Time formats
#***************************************************************#
our $hours = '[01][0-9]|[0-9]|2[0-4]';
our $minutes = '[0-5][0-9]';
our $sv_clock_words = 'klockan|kl\.';
our $en_clock_words = "a.m.|a.m|p.m.|p.m|am|pm";
#***************************************************************#
# Announcement phrases
our $use_announcements = 0;
our $doubleQuoteStartPhrase = 'citat';
$doubleQuoteStartPhrase = 'quote' if $MTM::Vars::lang eq 'en';
our $doubleQuoteEndPhrase = 'slut|citat';
$doubleQuoteEndPhrase = 'end|of|quote' if $MTM::Vars::lang eq 'en';
our $parenthesisStartPhrase = 'parentes';
$parenthesisStartPhrase = 'parenthesis' if $MTM::Vars::lang eq 'en';
our $parenthesisEndPhrase = 'slut|parentes';
$parenthesisEndPhrase = 'end|of|parenthesis' if $MTM::Vars::lang eq 'en';
our $bracketStartPhrase = 'hakparentes';
### NOT USED	$bracketStartPhrase = 'bracket' if $MTM::Vars::lang eq 'en';
### NOT USED	our $bracketEndPhrase = 'slut|hakparentes';
### NOT USED	$bracketEndPhrase = 'end|o|bracket' if $MTM::Vars::lang eq 'en';

#***************************************************************#
# Currency formats
#***************************************************************#
our $sv_currency_list = 'krona|kronor|kr\.|kr|\:-|dollar|pund|euro'; #|cent|pence|öre|,-"; [\$\£\€\¥\¢]|
our $sv_currency_lc_list = 'kr\.|kr';			# [\$\£\€\¥\¢]
our $sv_krona = 'krona|kronor|kr\.|kr';
our $sv_dollar_expansion = 'dollar';
our $sv_dollar2_expansion = 'cent';
our $sv_pound_expansion = 'pund';
our $sv_pound2_expansion = 'pence';
our $sv_euro_expansion = 'euro';
our $sv_euro2_expansion = 'cent';
our $sv_krona_expansion = 'kronor';
our $sv_krona2_expansion = 'öre';

our $en_currency_list = 'krona|kronor|kr\.|kr|\:-|dollars\?|pounds\?|euros\?'; #|cent|pence|öre|,-"; [\$\£\€\¥\¢]|
our $en_currency_lc_list = 'kr\.|kr';			# [\$\£\€\¥\¢]
our $en_krona = 'krona|kronor|kr\.|kr';
our $en_dollar_expansion = 'dollar';
our $en_dollar2_expansion = 'cent';
our $en_pound_expansion = 'pound';
our $en_pound2_expansion = 'pence';
our $en_euro_expansion = 'euro';
our $en_euro2_expansion = 'cent';
our $en_krona_expansion = 'kronor';
our $en_krona2_expansion = 'öre';
#***************************************************************#
# Phones
#***************************************************************#
our $mtm_vowel = join"|", qw( au eu ou ai ei oi eex iex uex öe: öe ö: ö ae: ae ä: ä e: e3 eh ex e a: aa: a i: i y: y uw: uw uu: uuh uu u o: oh o å: å en on an un );
our $tpa_vowel = join"|", qw( au eu öw ai ei åi eë ië uë ö3: ö3 ö2: ö ä3: ä3 ä2: ä e2: e3 e ë a2: a3: a i2: i3 i y2: y u4: u4 u2: u3 u o2: o3 o å2: å en on an);
our $cp_eng_vowel = join"|", qw( ii i e e @ e a @@ oo o uu u aa uh au ei ai oi ou e@ i@ u@ );
our $cp_swe_vowel = join"|", qw( ii i yy y ee eh e eex aae ae ooe oe uu u u uux ux oo o aa a ah au eu ei ai oi ou e@ i@ u@ an in on );
our $ipa_vowel = join"|", qw( iː ɪ yː ʏ eː ɛ e ə ɛː ɛ æː æ øː ø œː œ uː u u oː ɔ ʉː ɵ ʉ ʊː ʊ ɒː a aː aʊ ɛʊ eɪ aɪ ɔɪ əʊ eə ɪə ʊə ̃ɑ̃ ̃ɛ̃ õ ̃œ̃ );
our $ms_ipa_vowel = join"|", qw( iː ɪ yː ʏ eː ɛ e ə ɛː ɛ æː æ øː ø œː œ uː u u oː ɔ ʉː ɵ ʉ ʊː ʊ ɒː a aː );
our $tacotron_1_vowel = join"|", qw( au eu öw öö: öö ö: ö ää: ää ä: ä e: e ë a: a i: i y: y u: u o: o å: å);
our $nst_vowel = join"|", qw( a*U oU 2: 9 E: E e: e A: a i: I y: y }: u0 o: O);

#***************************************************************#
# Internet top domains (TLD's)
#***************************************************************#
our $tld = join"|", qw( net org info ac ad ae af ag ai al am an ao aq ar as at au aw ax az ba bb bd be bf bg bh bi bj bm bn bo br bs bt bv bw by bz ca cc cd cf cg ch ci ck cl cm cn co cr cs cu cv cw cx cy cz dd de dj dk dm do dz ec ee eg eh er es et eu fi fj fk fm fo fr ga gb gd ge gf gg gh gi gl gm gn gp gq gr gs gt gu gw gy hk hm hn hr ht hu id ie il im in io iq ir is it je jm jo jp ke kg kh ki km kn kp kr kw ky kz la lb lc li lk lr ls lt lu lv ly ma mc md me mg mh mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz na nc ne nf ng ni nl no np nr nu nz om oz pa pe pf pg ph pk pl pm pn pr ps pt pw py qa re ro rs ru rw sa sb sc sd se sg sh si sj sk sl sm sn so sr ss st su sv sy sz tc td tf tg th tj tk tl tm tn to tp tr tt tv tw tz ua ug uk um us uy uz va vc ve vg vi vn vu wf ws ye yt yu za zm zr zw );

#***************************************************************#
# Parameters for which ssml to insert in preproc output
### TODO Move to SSML config file when the structure is ready
#**************************************************************#
# <phoneme>
our $do_pronunciation_ssml = 0;	# <phoneme> for each token.
our $do_oov_ssml = 0;		# <phoneme> for 'unknown' tokens.
our $do_acronym_ssml = 0;		# <phoneme> for all acronyms.
our $do_initial_ssml = 0;		# <phoneme> for all name initials.

our $do_email_ssml = 0;		# <phoneme> for all email expressions.
our $do_url_ssml = 0;		# <phoneme> for all url expressions.
our $do_filename_ssml = 0;		# <phoneme> for all filename expressions.

#**************************************************************#
# <sub>
our $do_sub_exprtypes_ssml = 0;	# <sub> for all expression _types (resulting in <sub>, not EMAIL, URL etc.)

our $do_abbreviation_ssml = 0;	# <sub> for all abbreviations.

# Numeral expressions
our $do_numeral_ssml = 0;		# <sub> for all numeral expressions (below).
our $do_date_ssml = 0;		# <sub> for all date expressions.
our $do_time_ssml = 0;		# <sub> for all time expressions.
our $do_year_ssml = 0;		# <sub> for all year expressions.
our $do_currency_ssml = 0;		# <sub> for all currency expressions.
our $do_decimal_ssml = 0;		# <sub> for all decimal expressions.
our $do_phone_number_ssml = 0;	# <sub> for all phone number expressions.
our $do_ordinal_ssml = 0;		# <sub> for all ordinal expressions.
our $do_interval_ssml = 0;		# <sub> for all interval expressions.
our $do_fraction_ssml = 0;		# <sub> for all fraction expressions.

#**************************************************************#
# <break>
our $do_pause_ssml = 0;		# <break> for each pause.

#**************************************************************#
# Special	### TODO!
our $do_page_ssml = 0;		# <sub> for all page references.

our $do_law_reference_ssml = 0;	# <sub> for all law references.

our $do_hyphen_ssml = 0;		# <sub> for all hyphens.
our $do_hyphen_interval_ssml = 0;	# <sub> for all hyphens in intervals.

#**************************************************************#
# Entropy averages

our %entropy_avg = ();
$entropy_avg{ 'ge' }{ 'sv' }{ 'word' } = 2.90425361714748;
$entropy_avg{ 'pe' }{ 'sv' }{ 'word' } = 3.34098292414323;

$entropy_avg{ 'ge' }{ 'sv' }{ 'pn' } = 2.62604762200028;
$entropy_avg{ 'pe' }{ 'sv' }{ 'pn' } = 3.01295256873224;

$entropy_avg{ 'ge' }{ 'en' }{ 'word' } = 2.70219040711196;
$entropy_avg{ 'pe' }{ 'en' }{ 'word' } = 2.97689755724816;

$entropy_avg{ 'ge' }{ 'en' }{ 'pn' } = 2.66623221718805;
$entropy_avg{ 'pe' }{ 'en' }{ 'pn' } = 2.90318757575277;

$entropy_avg{ 'ge' }{ 'uo' }{ 'word' } = 2.68666344580833;
$entropy_avg{ 'pe' }{ 'uo' }{ 'word' } = 3.0695029884571;

$entropy_avg{ 'ge' }{ 'uo' }{ 'pn' } = 2.61923839547211;
$entropy_avg{ 'pe' }{ 'uo' }{ 'pn' } = 2.87733821265402;

$entropy_avg{ 'ge' }{ 'all' }{ 'word' } = 2.8889245670515;
$entropy_avg{ 'pe' }{ 'all' }{ 'word' } = 3.29980790021285;

$entropy_avg{ 'ge' }{ 'all' }{ 'pn' } = 2.62849601116003;
$entropy_avg{ 'pe' }{ 'all' }{ 'pn' } = 2.96824324778499;

$entropy_avg{ 'ge' }{ 'all' }{ 'all' } = 2.83990464755118;
$entropy_avg{ 'pe' }{ 'all' }{ 'all' } = 3.23739818283171;
#**************************************************************#
1;
