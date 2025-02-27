package MTM::Pronunciation::Conversion::CP;

#**************************************************************#
# CP conversion (Swedish)
#
# Convert from CP to base format
#
# my $converted = MTM::Pronunciation::Conversion::CP->encode( $pron );
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
my %base2cp = ();
my %cp2base = ();

#**************************************************************#
# base2cp
sub encode {
	my $self = shift;
	my $pron = shift;
	my $orth = '-';
	my $pos = '-';

	if( @_ > 1 ) {
		$orth = shift;
		$pos = shift;
	}

	&read_table();

	# Split
	my @phonemes = split' ', $pron;
	my @cp = ();

	foreach my $p ( @phonemes ) {
		my $add_stress = 'void';
		
		# Remove and save stress
		if( $p =~ s/^\'// ) {
			$add_stress = '4';
		} elsif ( $p =~ s/^\"// ) {
			$add_stress = '3';
		} elsif( $p =~ s/^,// ) {
			$add_stress = '0';
			# No secondary stress in simplex words.
			# Keep secondary stress in compounds and acronyms.
			if ( $pron =~ / - / || $pos =~ /ACR/ ) {
				$add_stress = '2';
			}
		} elsif ( $p =~ /[aouåeiyäö]/ ) {
			$add_stress = '0';
		}
		my $cp;

		# Lookup and add stress
		if( exists( $base2cp{ $p } )) {
			$cp = $base2cp{ $p };
			if( $add_stress ne 'void' ) {
				$cp .= $add_stress;
				$cp =~ s/(.) j(\d)/$1$2 j/;	# e j
			}
			push @cp, $cp;
		} elsif( $p =~ /[\.\~\-\|]/ ) {
			# do nothing
		} else {
			warn "No match for $p	$pron\n";
		}
		#print STDERR "encode $p	$cp\n";

	}

	my $ret = join' ', @cp;
	$ret =~ s/ - / /g;
	
	return "$ret";
}
#**************************************************************#
# cp2base
sub decode {
	my( $self, $pron ) = @_;

	&read_table();

	# Split
	my @phonemes = split' ', $pron;
	my @base = ();

	foreach my $p ( @phonemes ) {

		my $add_stress = 'void';

		# Remove and save stress
		if( $p =~ s/4$// ) {
			$add_stress = "\'";
		} elsif ( $p =~ s/3$// ) {
			$add_stress = '"';
		} elsif( $p =~ s/2$// ) {
			$add_stress = ',';
		} elsif( $p =~ s/0$// ) {
			# don't save
		}

		my $base;

		# Lookup and add stress
		if( exists( $cp2base{ $p } )) {
			$base = $cp2base{ $p };
			if( $add_stress ne 'void' ) {
				$base = $add_stress . $base;
			}

			$base =~ s/(sh|zh)/rs/;		# CP uses the same symbol for /ʃ/ and /ʂ, ʒ/ (/sh/, /zh/ and /rs/)
			$base =~ s/xx/x/;		# CP uses the same symbol for /ɧ/ and /x/ (/x/ and /xx/)
			$base =~ s/ih/i/;		# CP uses the same symbol for /i/ and /ih/
			$base =~ s/^(eh|ä)$/e/;		# CP uses the same symbol for /e/, /ä/ and /eh/
			$base =~ s/^(uw)/u/;		# CP uses the same symbol for /u/, /uw/
			$base =~ s/^uuh$/uu/;		# CP uses the same symbol for /uuh/, /uh/
			$base =~ s/^r0$/rh/;		# CP uses the same symbol for /r0/, /rh/

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
		my( $base, $cp ) = split/\t/;
		$base2cp{ $base } = $cp;
		$cp2base{ $cp } = $base;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# Base	CP
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
zh	rs
z	z
dh	dh
th	th
h	h
x	x
xx	x
c	c
tc	ch
dj	jh
m	m
n	n
rn	rn
ng	ng
r	r
l	l
rl	rl
j	j
w	w
rh	rh
r0	rh
rx	rrh
i:	ii
i	i
ih	i
y:	yy
y	y
e:	ee
e	e
eh	e
ex	eh
ä:	eex
ä	e
ae:	aae
ae	ae
ö:	oox
ö	ox
oe:	ooe
oe	oe
u:	uu
u	u
oh	u
o:	oo
o	o
uu:	uux
uu	ux
uuh	ux
uw:	uu
uw	u
a:	aa
a	a
aa:	aah
au	au
eu	eu
ei	e j
ai	a j
oi	o j
ou	ou
eex	eeh
iex	ieh
uex	ueh
an	an
en	in
on	on
un	un
.	-
-	-
~	-
|	-
# Stress
#\'
#\"
#,
