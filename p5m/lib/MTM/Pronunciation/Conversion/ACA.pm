package MTM::Pronunciation::Conversion::ACA;

#**************************************************************#
# ACA conversion (Swedish)
#
# Convert from ACA to base format
#
# my $converted = MTM::Pronunciation::Conversion::ACA->encode( $pron );
#
# CT 2024
#**************************************************************#
# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings	qw< FATAL  utf8 >;
use open	qw< :std  :utf8 >;	 # Should perhaps be :encoding(utf-8)?
use charnames	qw< :full :short >;	# autoenables in v5.16 and above
use feature	qw< unicode_strings >;
no feature	qw< indirect >;
use feature	qw< signatures >;
no warnings	qw< experimental::signatures >;
#**************************************************************#
use MTM::Pronunciation::Validation::ACA;

my %base2aca = ();
#my %aca2base = ();

#**************************************************************#
# base2aca
sub encode {
	my $self = shift;
	my $pron = shift;
	my $orth = '-';
	my $pos = '-';

	if( @_ > 1 ) {
		$orth = shift;
		$pos = shift;
	}

	#print "II $pron	$orth	$pos\n";

	&read_table();

	# Split
	my @phonemes = split' ', $pron;
	my @aca = ();

	foreach my $p ( @phonemes ) {
		my $add_stress = 'void';

		# Remove and save stress
		if( $p =~ s/^\'// ) {
			$add_stress = '4';
		} elsif ( $p =~ s/^\"// ) {
			$add_stress = '3';
		} elsif( $p =~ s/^,// ) {
			# No secondary stress in simplex words.
			# Keep secondary stress in compounds and acronyms.
			if ( $pron =~ / - / || $pos =~ /ACR/ ) {
				$add_stress = '1';
			}
		}

		my $aca;

		# Lookup and add stress
		if( exists( $base2aca{ $p } )) {
			$aca = $base2aca{ $p };

			if( $add_stress ne 'void' ) {
				# Monophthong
				if( $aca !~ /_/ ) {
					$aca .= $add_stress;
				# Diphthong
				} else {
					$aca =~ s/^(.+)_(.+)$/$1$add_stress $2/;
				}
			}
			$aca =~ s/_/ /;
			push @aca, $aca;

		# Keep delimieters until the end
		} elsif ( $p =~ /^[\.\~\-\|]$/ ) {
			push @aca, $p;
		} else {
			warn "No match for $p	$pron\n";
		}
		#print STDERR "encode $p	$aca\n";
	}

	my $ret = join' ', @aca;

	# Aspiration
	$ret = &ACA_aspiration( $ret );

	# Remove boundaries - TODO: is | ok?
	$ret =~ s/ [\.\~\-] / /g;

	#print STDERR "1. $ret	$pos\n";
	# Coach
	if( $orth =~ /coach/i ) {
		$ret = &coach( $ret );
	}

	# Adjective -ig
	if( $pos =~ /JJ/ ) {
		$ret = &JJ_ig( $orth, $ret );
	}
	#print STDERR "2. $ret\n";

	# Karlsson
	$ret = &karlsson( $ret );

	return $ret;
}
#**************************************************************#
# Special Acapela transcription for "Karlsson": /rl/ --> /l/
sub karlsson {
	my $pron = shift;
	$pron =~ s/k_h A:4 rl s O n/k_h A:4 l s O n/;
	return $pron;
}
#**************************************************************#
# Special Acapela transcription for "Karlsson": /rl/ --> /l/
sub coach {
	my $pron = shift;
	$pron =~ s/(k(?:_h)?) 2(\d) U/$1 u:$2/g;
	return $pron;
}
#**************************************************************#
# aca2base	No need for decoding ACA.
#sub decode {
#}
#**************************************************************#
sub read_table {
	while(<DATA>) {
		chomp;
		s/[\r\n]//g;
		next if /\#/;
		my( $base, $aca ) = split/\t/;
		$base2aca{ $base } = $aca;
		#$aca2base{ $aca } = $base;
	}
	return;
}
#**************************************************************#
sub ACA_aspiration {

	my $pron = shift;

	my $aVP = "p|t|k|rt";		# acapela voiceless plosives
	my $aFC = "j|l|n|r|v";		# acapela following consonant
	my $aVowel = "a|A:|e|e:|\@|I|i:|U|u:|u|\}:|Y|y:|O|o:|E|E:|\{|\{:|2|2:|9|9:|aa|a\~|e\~|o\~|9\~";

	# Word initially followed by a vowel or (j|l|n|r|v) and vowel
	$pron =~ s/^($aVP) ((?:$aFC)? ?(?:$aVowel))/$1 _h $2/;

	# Morpheme initially followed by a vowel or (j|l|n|r|v) and vowel)
	$pron =~ s/(\-) ($aVP) ((?:$aFC)? ?(?:$aVowel))/$1 $2 _h $3/g;

	# Within a morpheme in a compound followed by a primary stressed vowel or (j|l|n|r|v) and vowel
	$pron =~ s/($aVP) ((?:$aFC)? ?(?:$aVowel)[34])/$1 _h $2/g;

	# Remove aspiration in same syllable if preceded by /s/
	$pron =~ s/s ($aVP) _h/s $1/g;

	# Remove aspiration if followed by /@/
	$pron =~ s/($aVP) _h \@/$1 \@/g;

	# Remove blanks
	$pron =~ s/ _h/_h/g;

	$pron =~ s/ [\$\-\~] / /g;

	return $pron;
}
#**************************************************************#
sub JJ_ig {
	my( $orth, $pron ) = @_;

	# Use /g/ for adjectives ending in <ig[ae]?>
	if ( $orth =~ /ig[ae]?s?$/ ) {
		$pron =~ s/(I\d?) ([a\@])$/$1 g $2/;
		$pron =~ s/(I\d?) ([a\@]) s$/$1 g $2 s/;
		$pron =~ s/(I\d?)$/$1 g/;
	}

	return $pron;
}
#**************************************************************#
1;
__DATA__
# Base	TPA
# Note that some diacritics does not show properly in the table,
# e.g. the desyllabification diatritic for /ih/.
Base	ACA
ACA	Acapela
Base	Acapela
p	p
b	b
t	t
rt	rt
d	d
rd	rd
k	k
g	g
f	f
v	v
s	s
rs	rs
sh	rs
zh	S
z	z
dh	D
th	T
h	h
x	S
xx	x
c	C
tc	tS
dj	dZ
m	m
n	n
rn	rn
ng	N
r	r
l	l
rl	rl
j	j
w	w
rh	r
r0	r
rx	r
i:	i:
i	I
ih	I
y:	y:
y	Y
e:	e:
e	e
eh	e
ex	@
ä:	E:
ä	E
ae:	{:
ae	{
ö:	2:
ö	2
oe:	9:
oe	9
u:	u:
u	U
oh	U
o:	o:
o	O
uu:	}:
uu	u
uuh	u
uw:	u:
uw	U
a:	A:
a	a
aa:	a
au	a_U
eu	E_U
ei	E_j
ai	a_j
oi	O_j
ou	2_U
eex	{:
iex	I_@
uex	U_@
an	a~
en	e~
on	o~
un	9~
# Stress
#\'
#\"
#,
# Boundaries
#.
#-
#~
#|
