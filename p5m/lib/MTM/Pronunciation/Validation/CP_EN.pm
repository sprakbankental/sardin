package MTM::Pronunciation::Validation::CP_EN;

#**************************************************************#
# CP_EN validation (Swedish)
#
# Validate CP_EN pronunciations
#
# my $validated = MTM::Pronunciation::Validation::CP_EN->validate( $pron );
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
# CP_EN
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
			$stress = 1 if $pp =~ s/[12]//g;
			if( not( exists( $valid{ $pp } ))) {
				push @ret, "Symbol is not valid: $pp\n";
			} else {
				# Unstressable phone
				if( $stress == 1 ) {
					if( $valid{ $pp } ne 'v' ) {
						push @ret, "Unstressable phone: $word	$p\n";
					}
				}
				if( $p =~ /$schwa(1)/ ) {
					push @ret, "Schwa cannot have main stress: $word	$p\n";
				}
			}
		}
		#****************************************************************#
		# Stress
		# Illegal stress placement
		if( $word =~ / [12]/ ) {
			push @ret, "Illegal stress placement: $word\n";
		}

		# Multiple stress markers
		if( $word =~ /[12].+[1]/ ) {
			push @ret, "Multiple stress markers: $word\n";
		}

		# No main stress
		if( $word !~ /1/ ) {
			push @ret, "No main stress: $word\n";
		}

		# No secondary stress
		#if( $word =~ /3/ && $word !~ /2/ ) {
		#	push @ret, "No secondary stress: $word\n";
		#}

		#****************************************************************#
		# Boundaries: not applicable for CP_EN

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
		my( $cp_en, $cv ) = split/\t/;
		$valid{ $cp_en } = $cv;
	}
	return 1;
}
#**************************************************************#
1;
__DATA__
# CP_EN
# Phonemes
CP_EN
p	c
b	c
t	c
t	c
d	c
k	c
g	c
f	c
v	c
s	c
sh	c
zh	c
dh	c
th	c
h	c
sh	c
ch	c
jh	c
m	c
n	c
ng	c
r	c
l	c
y	c
w	c
r	c
ii	v
i	v
e	v
e	v
@	v
e	v
a	v
@@	v
uu	v
u	v
oo	v
uu	v
u	v
aa	v
uh	v
au	v
e_w	v
ei	v
ai	v
oi	v
ou	v
e@	v
i@	v
u@	v
aa_ng	v
e_ng	v
oo_ng	v
@@_ng	v
# Stress
1	s
2	s
0	s
# Boundaries
#.	b
#-	b
#~	b
#|	b
