package MTM::Pronunciation::Validation::TPA;

#**************************************************************#
# TPA validation (Swedish)
#
# Validate TPA pronunciations
#
# my $validated = MTM::Pronunciation::Validation::TPA->validate( $pron );
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

#**************************************************************#
sub validate {
	my( $self, $i ) = @_;

	&read_table();
	my $schwa = 'ë';

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
			$stress = 1 if $pp =~ s/[\'\"\`]//g;
			if( not( exists( $valid{ $pp } ))) {
				push @ret, "Symbol is not valid: $pp\n";
			} else {
				# Unstressable phone
				if( $stress == 1 ) {
					if( $valid{ $pp } ne 'v' ) {
						push @ret, "Unstressable phone: $word	$p\n";
					}
					if( $p =~ /[\'\",]$schwa/ ) {
						push @ret, "Schwa cannot have main stress: $word	$p\n";
					}
				}
				push @cv, $valid{ $pp };
			}
		}
		#****************************************************************#
		# Stress
		# Illegal stress placement
		if( $word =~ /[\'\",\`] / ) {
			push @ret, "Illegal stress placement: $word\n";
		}

		# Multiple stress markers
		if( $word =~ /[\'\`].*[\'\"\`]/ ) {
			push @ret, "Multiple stress markers: $word\n";
		}

		# No main stress
		if( $word !~ /[\'\"]/ ) {
			push @ret, "No main stress: $word\n";
		}

		# No secondary stress
		if( $word =~ /\"/ && $word !~ /\`/ ) {
			push @ret, "No secondary stress: $word\n";
		}
		#****************************************************************#
		# Boundaries
		my $cv = join' ', @cv;
		if( $cv =~ /v [^b]+ v/ ) {
			push @ret, "Missing boundary: $word\n";
		}

		# Adjacent boundaries
		if( $cv =~ /b b/ ) {
			push @ret, "Adjacent boundaries: $word\n";
		}
		#****************************************************************#
	}

	my $ret = "VALID\n";
	if( $#ret > -1 ) {
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
		my( $tpa, $cv ) = split/\t/;
		$valid{ $tpa } = $cv;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# TPA
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
rs	c
rs3	c
z	c
dh	c
th	c
h	c
<<<<<<< HEAD
x	c
xx	c
=======
sj	c
sj3	c
>>>>>>> issue-191
tj	c
tj3	c
j3	c
m	c
n	c
rn	c
ng	c
r	c
l	c
rl	c
j	c
w	c
r3	c
r0	c
r4	c
i2:	v
i	v
i3	v
y2:	v
y	v
e2:	v
e	v
e3	v
ë	v
ä2:	v
ä	v
ä3:	v
ä3	v
ö2:	v
ö	v
ö3:	v
ö3	v
o2:	v
o	v
o3	v
å2:	v
å	v
u2:	v
u	v
u3	v
u4:	v
u4	v
a2:	v
a	v
a3:	v
au	v
eu	v
ei	v
ai	v
åi	v
öw	v
eë	v
ië	v
uë	v
an	v
en	v
on	v
un	v
# Stress
'	s
"	s
`	s
# Boundaries
$	b
-	b
~	b
|	b
