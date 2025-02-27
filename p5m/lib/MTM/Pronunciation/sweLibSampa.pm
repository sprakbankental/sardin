MTM::Pronunciation::sweLibSampa;

##### Change filename

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
# sweLibSampa
#
# Language	sv_se
#
# Variables for Autopron
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#

my @phones = qw(
	eu au öw uë eë ië ai åi ei \
	i2: i3 i y2: y \
	e2: e3 e ä3: ä3 ä2: ä ë \
	ö3: ö3 ö2: ö \
	a2: a3 a \
	o2: o3 o å2: å \
	u2: u3 u4: u4 u \
	an en on \
	p t k b d g \
	rd rd rs rn rl \
	tj3 tj sj3 sj j3 rs3 \
	f v s h j w \
	m n ng \
	l r r3 r0 r4 \
	th dh \

);

my @stressable = qw(
	eu au öw uë eë ië ai åi ei \
	i2: i3 i y2: y \
	e2: e3 e ä3: ä3 ä2: ä ë \
	ö3: ö3 ö2: ö \
	a2: a3 a \
	o2: o3 o å2: å \
	u2: u3 u4: u4 u \
	an en on \
);

# Danish grapheme-phoneme mappings
my %g2pMAP = (
	"i"	=>	["i2:", "i3", "ai", "a_j", "i", "j", "a", "s_i3", "s_i", "rs_i3", "rs_i", "sj", "ö3:", "ö3", "e_j", "eps"],
	"í"	=>	["i2:", "i", "eps"],
	"î"	=>	["i2:", "i", "eps"],

	"y"	=>	["y2:", "y", "j", "i", "a_j", "ö3", "eps"],
	"ü"	=>	["y2:", "y", "eps"],

	"e"	=>	["e2:", "e2", "e3", "ei", "e", "ë", "ä", "ä2:", "ä3:", "ä3", "i2:", "a", "å", "ië", "eë", "i3", "i", "ö3:", "ö3", "j_e", "e_j", "ö2:", "eps"],
	"é"	=>	["e2:", "e", "ë", "ä", "ä2:", "eps"],
	"è"	=>	["e2:", "e", "ë", "ä", "ä2:", "eps"],
	"ê"	=>	["e2:", "e", "ë", "ä", "ä2:", "eps"],
	"ë"	=>	["e2:", "e", "ë", "ä", "ä2:", "eps"],

	"o"	=>	["o2:", "o3", "o", "å2:", "å", "ö2:", "ö3:", "ö3", "öw", "ö", "u4:", "u4", "u", "au", "ë", "o3", "a", "eps"],
	"ó"	=>	["o2:", "o3", "o", "å2:", "å", "eps"],
	"ò"	=>	["o2:", "o3", "o", "å2:", "å", "eps"],
	"ô"	=>	["o2:", "o3", "o", "å2:", "å", "eps"],

	"å"	=>	["å2:", "å", "o3", "eps"],

	"ä"	=>	["ä2:", "ä3:", "ä3", "ä", "e", "e3", "eps"],
	"æ"	=>	["ä2:", "ä3:", "ä3", "ä", "e", "eps"],

	"ø"	=>	["ö3:", "ö3", "ö2:", "ö", "eps"],
	"ö"	=>	["ö3:", "ö3", "ö2:", "ö", "eps"],

	"u"	=>	["u2:", "j_u4:", "u4:", "u4", "u3", "u", "y2:", "y", "o2:", "o", "v", "w", "au", "eu", "a", "ö3:", "j", "f", "eps"],

	"a"	=>	["a2:", "a3:", "a3", "a", "ä3:", "ä3", "ä2:", "å2:", "å", "ei", "ai", "a_j", "ei", "e_j", "e", "ë", "o3", "eps"],
	"â"	=>	["a2:", "a3:", "a3", "a", "eps"],
	"á"	=>	["a2:", "a3:", "a3", "a", "eps"],
	"à"	=>	["a2:", "a3:", "a3", "a", "eps"],


	"p"	=>	["p", "b", "f", "eps"],
	"b"	=>	["b", "p", "eps"],
	"t"	=>	["rt", "tj3", "tj", "th", "dh", "t", "t_j", "s", "d", "eps"],
	"d"	=>	["rd", "dh", "d", "t", "eps"],
	"k"	=>	["k", "tj", "eps"],
	"q"	=>	["k", "tj3", "tj", "eps"],
	"g"	=>	["g", "rs", "ng", "j3", "d_j", "j", "sj", "k", "eps"],

	"f"	=>	["f", "v", "eps"],
	"v"	=>	["v", "f", "eps"],
	"s"	=>	["rs", "s", "sj", "eps"],
	"ß"	=>	["s", "eps"],
	"z"	=>	["s", "z", "t_s", "rs", "rt_rs", "eps"],

	"c"	=>	["rs", "s", "k", "tj3", "tj", "sj3", "sj", "eps"],
	"h"	=>	["h", "sj", "eps"],

	"ç"	=>	["s", "eps"],
	"x"	=>	["k_s", "k", "s", "tj3", "tj", "eps"],

	"m"	=>	["m", "eps"],
	"n"	=>	["n_j", "rn", "n", "ng", "eps"],
	"ñ"	=>	["n_j", "eps"],

	"j"	=>	["j", "rs", "j3", "d_j", "rs3", "sj", "eps"],
	"l"	=>	["rl", "l", "j", "ë_l", "eps"],
	"w"	=>	["v", "w", "f", "au", "eps"],

	"r"	=>	["r", "r0", "r3", "r4", "eps"],

	"/"	=>	["eps"],
	"'"	=>	["eps"]
#	"´"	=>	["eps"],
#	"\`"	=>	["eps"],
#	"’"	=>	["eps"],
#	"="	=>	["eps]
);

1;