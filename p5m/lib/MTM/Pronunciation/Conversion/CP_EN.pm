package MTM::Pronunciation::Conversion::CP_EN;

#**************************************************************#
# CP_EN conversion (Swedish)
#
# Convert from CP_EN to base format
#
# my $converted = MTM::Pronunciation::Conversion::CP_EN->encode( $pron );
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
my %base2cp_en = ();
my %cp_en2base = ();

#**************************************************************#
# base2cp_en
sub encode {
	my( $self, $i ) = @_;

	&read_table();

	# Split
	my @phonemes = split' ', $i;
	my @cp_en = ();

	foreach my $p ( @phonemes ) {
		my $add_stress = 'void';

		# Remove and save stress
		if( $p =~ s/^\'// ) {
			$add_stress = '1';
		} elsif( $p =~ s/^,// ) {
			$add_stress = '2';
		} elsif( $p =~ /aouåeiäö/ ) {
			$add_stress = '0';
		}

		my $cp_en;

		# Lookup and add stress
		if( exists( $base2cp_en{ $p } )) {
			$cp_en = $base2cp_en{ $p };
			if( $add_stress ne 'void' ) {
				# Monophthong
				if( $cp_en !~ /_/ ) {
					$cp_en = $cp_en . $add_stress;
				# Diphthong
				} else {
					$cp_en =~ s/^(.+)_(.+)$/$1$add_stress $2/;
				}
			}
			$cp_en =~ s/_/ /g;		
			push @cp_en, $cp_en;
		} else {
			warn "No match for $p\n";
		}
		#print STDERR "encode $p	$cp_en\n";
	}

	my $ret = join' ', @cp_en;

	# TODO: Validate

	return "$ret";
}
#**************************************************************#
# cp_en2base
sub decode {
	my( $self, $i ) = @_;

	&read_table();

	# Split
	my @phonemes = split' ', $i;
	my @base = ();

	foreach my $p ( @phonemes ) {

		my $add_stress = 'void';

		next if $p eq 'r0';		# CP_EN does not have a match for /r0/

		# Remove and save stress
		if( $p =~ s/1$// ) {
			$add_stress = "\'";
		} elsif( $p =~ s/2$// ) {
			$add_stress = ',';
		} elsif( $p =~ s/0$// ) {
			# don't save
		}

		my $base;

		# Lookup and add stress
		if( exists( $cp_en2base{ $p } )) {
			$base = $cp_en2base{ $p };
			if( $add_stress ne 'void' ) {
				$base = $add_stress . $base;
			}

			$base =~ s/(rx)/rh/;		# CP_EN uses the same symbol for /rx/ and /rh/
			$base =~ s/r([tdsnl])/$1/;	# CP_EN uses the same symbol for /t, d, s, n, l/ and /rt, rd, rs, rn, rl/
			$base =~ s/y/i/g;		# CP_EN uses the same symbol for /i/ and /y/
			$base =~ s/aa/a/g;		# CP_EN uses the same symbol for /aa/ and /a/
			$base =~ s/^ä$/e/g;		# CP_EN uses the same symbol for /e/ and /ä/
			$base =~ s/^c$/rs/g;		# CP_EN uses the same symbol for /c/ and /rs/

			push @base, $base;
		} else {
			warn "No match for $p\n";
		}
		#print STDERR "decode $p	$base\n";
	}

	my $ret = join' ', @base;

	# TODO: Validate

	return "$ret";
}
#**************************************************************#
sub read_table {
	while(<DATA>) {
		chomp;
		s/[\r\n]//g;
		next if /\#/;
		my( $base, $cp_en ) = split/\t/;
		$base2cp_en{ $base } = $cp_en;
		$cp_en2base{ $cp_en } = $base;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# Base	CP_EN
p	p
b	b
t	t
rt	t
d	d
rd	d
k	k
g	g
f	f
v	v
s	s
rs	sh
sh	sh
zh	zh
z	z
dh	dh
th	th
h	h
x	sh
xx	sh
c	sh
tc	ch
dj	jh
m	m
n	n
rn	n
ng	ng
r	r
l	l
rl	l
j	y
w	w
rh	r
r0	-
rx	r
i:	ii
i	i
ih	i
y:	ii
y	i
e:	-
e	e
eh	e
ex	@
ä:	-
ä	e
ae:	a
ae	a
ö:	@@
ö	-
oe:	@@
oe	-
u:	uu
u	u
oh	u
o:	oo
o	o
uw:	uu
uw	u
uw	u
uw:	uu
uw	u
a:	aa
a	uh
aa:	aa
au	au
eu	e_w
ei	ei
ai	ai
oi	oi
ou	ou
eex	e@
iex	i@
uex	u@
an	aa_ng
en	e_ng
on	oo_ng
un	@@_ng
# Stress
#\'	1
#\"
#,	2
# Boundaries
.	$
-	-
~	~
|	|
