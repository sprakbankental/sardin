package MTM::Pronunciation::Validation::CP;

#**************************************************************#
# CP validation (Swedish)
#
# Validate CP pronunciations
#
# my $validated = MTM::Pronunciation::Validation::CP->validate( $pron );
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
my %valid = ();
my $exceptions = 'p s t';

#**************************************************************#
# CP
sub validate {
	my( $self, $i ) = @_;

	&read_table();
	my $schwa = 'eh';

	my @ret = ();

	# Split	on word boundaries
	my @words = split/ \| /, $i;

	foreach my $word ( @words ) {

		#print STDERR "word $word\n";

		my @phonemes = split' ', $i;
		my @cv = ();
		#****************************************************************#
		# Symbols
		foreach my $p ( @phonemes ) {
			my $pp = $p;
			my $stress = 0;
			$stress = 1 if $pp =~ s/[4320]//g;
			if( not( exists( $valid{ $pp } ))) {
				push @ret, "Symbol is not valid: $pp\n";

			} else {
				# Unstressable phone
				if( $stress == 1 ) {
					if( $valid{ $pp } ne 'v' ) {
						push @ret, "Unstressable phone: $word	$p\n";
					}
				}

				if( $p =~ /^$schwa(4|3)/ ) {
					push @ret, "Schwa cannot have main stress: $word	$p\n";
				}
				push @cv, $valid{ $pp };
			}
		}
		#****************************************************************#
		# Stress
		# Illegal stress placement
		if( $word =~ / [432]/ ) {
			push @ret, "Illegal stress placement: $word\n";
		}

		# Multiple stress markers
		if( $word =~ /[42].+[432]/ ) {
			push @ret, "Multiple stress markers: $word\n";
		}

		# No main stress
		if( $word !~ /[43]/ ) {
			push @ret, "No main stress: $word\n";
		}

		# No secondary stress
		if( $word =~ /3/ && $word !~ /2/ ) {
			push @ret, "No secondary stress: $word\n";
		}

		#****************************************************************#
		# Boundaries:
		my $cv = join' ', @cv;

		# Adjacent boundaries
		if( $cv =~ /b b/ ) {
			push @ret, "Adjacent boundaries: $word\n";
		}

		#****************************************************************#
	}

	my $ret = "VALID\n";

	if( $#ret > -1 && $i !~ /^($exceptions)$/) {
		$ret = join' ', @ret;
	}
	return "$ret";
}
#**************************************************************#
sub read_table {
	while(<DATA>) {
		chomp;
		s/[\r\n]//g;
		next if /\#/;
		my( $cp, $cv ) = split/\t/;
		$valid{ $cp } = $cv;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# CP
# Phonemes
p	c
b	c
t	c
rt	c
d	c
rd	c
k	c
g	c
f	c
v	c
s	c
rs	c
z	c
dh	c
th	c
h	c
x	c
c	c
ch	c
jh	c
m	c
n	c
rn	c
ng	c
r	c
l	c
rl	c
j	c
w	c
rh	c
rrh	c
ii	v
i	v
yy	v
y	v
ee	v
e	v
eh	v
eex	v
aae	v
ae	v
oox	v
ox	v
ooe	v
oe	v
uu	v
u	v
oo	v
o	v
uux	v
ux	v
uu	v
u	v
aa	v
a	v
aah	v
au	v
eu	v
ou	v
eeh	v
ieh	v
ueh	v
an	v
in	v
on	v
un	v
# Stress
4	s
3	s
2	s
# Boundaries
$	b
-	b
~	b
|	b
