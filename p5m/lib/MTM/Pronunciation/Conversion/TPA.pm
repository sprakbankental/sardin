package MTM::Pronunciation::Conversion::TPA;

#**************************************************************#
# TPA conversion (Swedish)
#
# Convert from TPA to base format
#
# my $converted = MTM::Pronunciation::Conversion::TPA->encode( $pron );
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
my %base2tpa = ();
my %tpa2base = ();

#**************************************************************#
# base2tpa
sub encode {
	my( $self, $i ) = @_;

	&read_table();

	# Split
	my @phonemes = split' ', $i;
	my @tpa = ();

	foreach my $p ( @phonemes ) {
		my $add_stress = 'void';

		# Remove and save stress
		if( $p =~ s/^\'// ) {
			$add_stress = "'";
		} elsif ( $p =~ s/^\"// ) {
			$add_stress = '"';
		} elsif( $p =~ s/^,// ) {
			$add_stress = '`';
		}

		my $tpa;

		# Lookup and add stress
		if( exists( $base2tpa{ $p } )) {
			$tpa = $base2tpa{ $p };
			if( $add_stress ne 'void' ) {
				$tpa = $add_stress . $tpa;
			}
			push @tpa, $tpa;
		} else {
			warn "No match for __ $p __\n";
		}
		#print STDERR "encode $p	$tpa\n";
	}

	my $ret = join' ', @tpa;

	# TODO: Validate

	return "$ret";
}
#**************************************************************#
# tpa2base
sub decode {
	my( $self, $i ) = @_;

	&read_table();

	# Split
	my @phonemes = split/ +/, $i;
	my @base = ();

	foreach my $p ( @phonemes ) {
		
		#print STDERR "NOW $p\n";
		#while(my($k,$v)=each(%tpa2base)) { print STDERR "\t$k	-	$v\n"; }
		
		my $add_stress = 'void';

		# Remove and save stress
		if( $p =~ s/^\'// ) {
			$add_stress = "\'";
		} elsif ( $p =~ s/^\"// ) {
			$add_stress = '"';
		} elsif( $p =~ s/^\`// ) {
			$add_stress = ',';
		}

		my $base;

		# Lookup and add stress
		if( exists( $tpa2base{ $p } )) {
			$base = $tpa2base{ $p };
			if( $add_stress ne 'void' ) {
				$base = $add_stress . $base;
			}

			$base =~ s/sh/rs/;		# TPA uses the same symbol for /ʃ/ and /ʂ/
			push @base, $base;
		} else {
			warn "No match for __ $p __\n";
		}
		#print STDERR "decode $p	$base\n";
	}

	my $ret = join' ', @base;

	return "$ret";
}
#**************************************************************#
sub read_table {
	while(<DATA>) {
		chomp;
		s/[\r\n]//g;
		next if /\#/;
		my( $base, $tpa ) = split/\t/;
		$base2tpa{ $base } = $tpa;
		$tpa2base{ $tpa } = $base;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# Base	TPA
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
zh	rs3
z	z
dh	dh
th	th
h	h
x	sj
xx	sj3
c	tj
tc	tj3
dj	j3
m	m
n	n
rn	rn
ng	ng
r	r
l	l
rl	rl
j	j
w	w
rh	r3
r0	r0
rx	r4
i:	i2:
i	i
ih	i3
y:	y2:
y	y
e:	e2:
e	e
eh	e3
ex	ë
ä:	ä2:
ä	ä
ae:	ä3:
ae	ä3
ö:	ö2:
ö	ö
oe:	ö3:
oe	ö3
u:	o2:
u	o
oh	o3
o:	å2:
o	å
uu:	u2:
uu	u
uuh	u3
uw:	u4:
uw	u4
a:	a2:
a	a
aa:	a3:
au	au
eu	eu
ei	ei
ai	ai
oi	åi
ou	öw
eex	eë
iex	ië
uex	uë
an	an
en	en
on	on
un	un
.	$
-	-
~	~
|	|
# Stress
#\'	\'
#\"	\"
#,	,
