package MTM::Pronunciation::Validation::ACA;

#**************************************************************#
# ACA validation (Swedish)
#
# Validate ACA pronunciations
#
# my $validated = MTM::Pronunciation::Validation::ACA->validate( $pron );
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
# ACA
sub validate {
	my( $self, $i ) = @_;

	&read_table();
	my $schwa = '@';

	my @ret = ();

	# Split	on word boundaries
	my @words = split/ \| /, $i;

	foreach my $word ( @words ) {

		#print STDERR "word $word\n";

		my @phonemes = split' ', $i;

		#****************************************************************#
		# Symbols
		foreach my $p ( @phonemes ) {
			my $pp = $p;
			my $stress = 0;
			$stress = 1 if $pp =~ s/[431]//g;
			if( not( exists( $valid{ $pp } ))) {
				push @ret, "Symbol is not valid: $pp\n";
			} else {
				# Unstressable phone
				if( $stress == 1 ) {
					if( $valid{ $pp } ne 'v' ) {
						push @ret, "Unstressable phone: $word	$p\n";
					}
				}
				if( $p =~ /$schwa(4|3)/ ) {
					push @ret, "Schwa cannot have main stress: $word	$p\n";
				}
			}
		}
		#****************************************************************#
		# Stress
		# Illegal stress placement
		if( $word =~ / [431]/ ) {
			push @ret, "Illegal stress placement: $word\n";
		}

		# Multiple stress markers
		if( $word =~ /[41].+[431]/ ) {
			push @ret, "Multiple stress markers: $word\n";
		}

		# No main stress
		if( $word !~ /[43]/ ) {
			push @ret, "No main stress: $word\n";
		}

		# No secondary stress: ACA does not use secondary stress for simplex words.
		#if( $word =~ /3/ && $word !~ /1/ ) {
		#	push @ret, "No secondary stress: $word\n";
		#}

		#****************************************************************#
		# Boundaries: not applicable for ACA

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
		my( $aca, $cv ) = split/\t/;
		$valid{ $aca } = $cv;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# ACA
# Phonemes
p_h	c
t_h	c
rt_h	c
k_h	c
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
s	c
z	c
D	c
T	c
h	c
S	c
x	c
C	c
tS	c
dZ	c
m	c
n	c
rn	c
N	c
r	c
l	c
rl	c
j	c
w	c
i:	v
I	v
I	v
y:	v
Y	v
e:	v
e	v
e	v
@	v
E:	v
E	v
{:	v
{	v
2:	v
2	v
9:	v
9	v
u:	v
U	v
o:	v
O	v
}:	v
u	v
u:	v
U	v
A:	v
a	v
{:	v
a~	v
e~	v
o~	v
9~	v
# Stress
4	s
3	s
1	s
# Boundaries
#.	b
#-	b
#~	b
|	b
