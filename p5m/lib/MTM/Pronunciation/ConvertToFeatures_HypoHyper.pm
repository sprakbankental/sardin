package MTM::Pronunciation::ConvertToFeatures_HypoHyper;
#**************************************************************#
# ConvertToFeatures
#
# Language	sv_se, en_uk
#
# Convert phones to features list
#
# Return: feature list
#
#
# (c) Swedish Agency for Accessible Media, MTM 2023
#**************************************************************#
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

our %swe_phone_feats;
my %eng_phone_feats;
our %all_feats;

#******************************************************#
# FEATURE CONVERSION
#******************************************************#
sub feature_conversion {
	my( $in, $infile, $mode, $degree ) = @_;

	my $saved_stress = 'void';

	my @ret = ();

	$in =~ s/au/a w/g;
	$in =~ s/eu/e w/g;

	my @phones;

	@phones = split/ /, $in;

	#while(my($k,$v)=each(%eng_phone_feats)){ print "I $k\tlist $v\n"; }exit;

	my $i = 0;
	foreach my $phone ( @phones ) {

		if( $phone !~ /^\d+$/ ) {
			my $features;

			# Phone (English)
			if( exists( $eng_phone_feats{ $phone } )) {
				$features = $eng_phone_feats{ $phone };
				print "HHH $phone	$features\n";

				my @features = split/\t/, $features;

				if( $saved_stress ne 'void' ) {
					# Main stress
					if( $saved_stress =~ /^[\"\'\ˈ]$/ ) {
						$features[0] = 1;
					# Seconday stress
					} elsif ( $saved_stress =~ /^[\`\ˌ]$/ ) {
						$features[0] = 0.5;
					}
				}

				# Ryan changes for Fonetik 2024
				if( $mode eq 'hypo' ) {
					@features = &ryan_hypo( $degree, @features );
				} elsif ( $mode eq 'hyper' ) {
					@features = &ryan_hyper( $degree, @features );
				}
				$features = join"\t", @features;


				$features =~ s/\t/,/g;
				push @ret, $features;
				$saved_stress = 'void';

				$all_feats{ $features }++;


			} elsif ( $phone eq '&' || $phone eq '.' ) {
				push @ret, $phone;
			} elsif ( $phone =~ /^[\"\'\`\ˈ]$/ ) {
				$saved_stress = $phone;
			} elsif ( $phone =~ /\ˌ/ ) {		#\ˌ
			} else {
				warn "no match: $phone ___	$in\n";
				print "no match: $phone ___\n";
				push @ret, 'no_match';
			}
		}
		$i++;
	}

	return join' ', @ret;
}
#******************************************************#
sub ryan_hypo {
	my( $degree, @features ) = @_;


	# Vowels
	if( $features[8] == 0 ) {
		# 0.5,1,0,0.5,0,0,0.6,0.33,0,0,0.67

		print "start	$features[6]	$features[7]	$features[10]	$features[0]	$features[3]\n";
		if( $degree eq 'moderate' ) {
			# Height
			$features[6] = '_0.2' if $features[6] eq '0';
			$features[6] = '_0.3' if $features[6] eq '0.2';
			$features[6] = '_0.4' if $features[6] eq '0.4';
			$features[6] = '_0.6' if $features[6] eq '0.6';
			$features[6] = '_0.6' if $features[6] eq '0.8';
			$features[6] = '_0.8' if $features[6] eq '1';
			$features[6] =~ s/_//;

			# Frontness			
			$features[7] = '_0.2' if $features[7] eq '0';
			$features[7] = '_0.5' if $features[7] eq '0.5';
			$features[7] = '_0.8' if $features[7] eq '1';
			$features[7] =~ s/_//;

			# Rounding
			$features[10] = '_0.25' if $features[10] eq '0';
			$features[10] = '_0.75' if $features[10] eq '1';
			$features[10] =~ s/_//;

			# Stress
			$features[0] = '0.67' if $features[0] eq '1';

			# Length
			$features[3] = '0.67' if $features[3] eq '1';

		} elsif( $degree eq 'severe' ) {
			# Height
			$features[6] = '_0.3' if $features[6] eq '0';
			$features[6] = '_0.4' if $features[6] eq '0.2';
			$features[6] = '_0.4' if $features[6] eq '0.4';
			$features[6] = '_0.6' if $features[6] eq '0.6';
			$features[6] = '_0.6' if $features[6] eq '0.8';
			$features[6] = '_0.7' if $features[6] eq '1';
			$features[6] =~ s/_//;

			# Frontness			
			$features[7] = '_0.4' if $features[7] eq '0';
			$features[7] = '_0.5' if $features[7] eq '0.5';
			$features[7] = '_0.6' if $features[7] eq '1';
			$features[7] =~ s/_//;

			# Rounding
			$features[10] = '_0.33' if $features[10] eq '0';
			$features[10] = '_0.67' if $features[10] eq '1';
			$features[10] =~ s/_//;

			# Stress
			$features[0] = '0.33' if $features[0] eq '1';

			# Length
			$features[3] = '0.33' if $features[3] eq '1';

		} elsif( $degree eq 'heavy' ) {
			# Height
			$features[6] = '_0.4' if $features[6] eq '0';
			$features[6] = '_0.4' if $features[6] eq '0.2';
			$features[6] = '_0.4' if $features[6] eq '0.4';
			$features[6] = '_0.4' if $features[6] eq '0.6';
			$features[6] = '_0.4' if $features[6] eq '0.8';
			$features[6] = '_0.4' if $features[6] eq '1';
			$features[6] =~ s/_//;

			# Frontness			
			$features[7] = '_0.5' if $features[7] eq '0';
			$features[7] = '_0.5' if $features[7] eq '0.5';
			$features[7] = '_0.5' if $features[7] eq '1';
			$features[7] =~ s/_//;

			# Rounding
			$features[10] = '_0.5' if $features[10] eq '0';
			$features[10] = '_0.5' if $features[10] eq '1';
			$features[10] =~ s/_//;

			# Stress
			$features[0] = '0.0' if $features[0] eq '1';

			# Length
			$features[3] = '0.0' if $features[3] eq '1';
		}
		print "end	$features[6]	$features[7]	$features[10]	$features[0]	$features[3]\n\n";
	}


	# Consonants
	#if( $features[8] == 1.0 ) {
	#	# Stricture
	#	$features[8] *= 0.8 if $features[8]>0.5;
	#	$features[8] *= 1.2 if $features[8]<0.5;
	#
	#	# Place of articulation
	#	$features[9] *= 0.8 if $features[9]>0.5;
	#	$features[9] *= 1.2 if $features[9]<0.5;
	#}

	return @features;
}
#******************************************************#
sub ryan_hyper {
	my( $degree, @features ) = @_;


	# Vowels
	if( $features[8] == 0 ) {
		# 0.5,1,0,0.5,0,0,0.6,0.33,0,0,0.67

		print "start	$features[6]	$features[7]	$features[10]	$features[0]	$features[3]\n";
		if( $degree eq 'moderate' ) {

			# Height
			$features[6] = '_-0.5' if $features[6] eq '0';
			$features[6] = '_0.2' if $features[6] eq '0.2';
			$features[6] = '_0.4' if $features[6] eq '0.4';
			$features[6] = '_0.6' if $features[6] eq '0.6';
			$features[6] = '_0.8' if $features[6] eq '0.8';
			$features[6] = '_1.5' if $features[6] eq '1';
			$features[6] =~ s/_//;

			# Frontness			
			$features[7] = '_-0.5' if $features[7] eq '0';
			$features[7] = '_0.5' if $features[7] eq '0.5';
			$features[7] = '_1.5' if $features[7] eq '1';
			$features[7] =~ s/_//;

			# Rounding
			$features[10] = '_-0.5' if $features[10] eq '0';
			$features[10] = '_1.5' if $features[10] eq '1';
			$features[10] =~ s/_//;

			# Stress
			$features[0] = '1.5' if $features[0] eq '1';
			$features[0] = '1' if $features[0] eq '0';

			# Length
			$features[3] = '1.5' if $features[3] eq '1';
			$features[3] = '1' if $features[3] eq '0';

		} elsif( $degree eq 'severe' ) {
			# Height
			$features[6] = '_-0.75' if $features[6] eq '0';
			$features[6] = '_0.1' if $features[6] eq '0.2';
			$features[6] = '_0.4' if $features[6] eq '0.4';
			$features[6] = '_0.8' if $features[6] eq '0.6';
			$features[6] = '_1.0' if $features[6] eq '0.8';
			$features[6] = '_1.5' if $features[6] eq '1';
			$features[6] =~ s/_//;

			# Frontness			
			$features[7] = '_-0.75' if $features[7] eq '0';
			$features[7] = '_0.5' if $features[7] eq '0.5';
			$features[7] = '_1.75' if $features[7] eq '1';
			$features[7] =~ s/_//;

			# Rounding
			$features[10] = '_-0.75' if $features[10] eq '0';
			$features[10] = '_1.75' if $features[10] eq '1';
			$features[10] =~ s/_//;

			# Stress
			$features[0] = '1.75' if $features[0] eq '1';
			$features[0] = '0.75' if $features[0] eq '0';

			# Length
			$features[3] = '1.75' if $features[3] eq '1';
			$features[3] = '0.75' if $features[3] eq '0';

		} elsif ( $degree eq 'heavy' ) {
			# Height
			$features[6] = '_-1.0' if $features[6] eq '0';
			$features[6] = '_0.1' if $features[6] eq '0.2';
			$features[6] = '_0.4' if $features[6] eq '0.4';
			$features[6] = '_0.6' if $features[6] eq '0.6';
			$features[6] = '_1.0' if $features[6] eq '0.8';
			$features[6] = '_2.0' if $features[6] eq '1';
			$features[6] =~ s/_//;

			# Frontness			
			$features[7] = '_-1.0' if $features[7] eq '0';
			$features[7] = '_0.5' if $features[7] eq '0.5';
			$features[7] = '_2.0' if $features[7] eq '1';
			$features[7] =~ s/_//;

			# Rounding
			$features[10] = '_-1.0' if $features[10] eq '0';
			$features[10] = '_2.0' if $features[10] eq '1';
			$features[10] =~ s/_//;

			# Stress
			$features[0] = '2.0' if $features[0] eq '1';
			$features[0] = '1.0' if $features[0] eq '0';

			# Length
			$features[3] = '2.0' if $features[3] eq '1';
			$features[3] = '1.0' if $features[3] eq '0';
		}
		print "end	$features[6]	$features[7]	$features[10]	$features[0]	$features[3]\n\n";
	}


	# Consonants
	#if( $features[8] == 1.0 ) {
	#	# Stricture
	#	$features[8] *= 0.8 if $features[8]>0.5;
	#	$features[8] *= 1.2 if $features[8]<0.5;
	#
	#	# Place of articulation
	#	$features[9] *= 0.8 if $features[9]>0.5;
	#	$features[9] *= 1.2 if $features[9]<0.5;
	#}

	return @features;
}
#******************************************************#
sub read_features {
	my $lang = 'Swedish';

	while(<DATA>) {
		if( /Ryan/ ) {
			$lang = 'English';
		}
		chomp;
		next if /\#/;
		my @line = split/\t/;
		my $phone = shift @line;

		if( $lang eq 'Swedish' ) {
			$swe_phone_feats{ $phone } = join'	', @line;
			#print "$phone\t$swe_phone_feats{ $phone }\n";
		} elsif ( $lang eq 'English' ) {
			$eng_phone_feats{ $phone } = join'	', @line;
			#print "$phone\t$eng_phone_feats{ $phone }\n";
		}
	}
	close DATA;
	return 1;
}
#******************************************************#
1;
__DATA__
# Ryan 240213
#		0	1	2	3	4	5	6	7	8	9	10
#index	LJSpeech	stress	voicing	obstruent	length	nasality	rhotic	vowel height	vowel frontness	stricture	c-place	lip rounding
/	0	0	0	0	0	0	0	0	0	0	0
:	0	0	0	0	0	0	0	0	0	0	0
;	0	0	0	0	0	0	0	0	0	0	0
,	0	0	0	0	0	0	0	0	0	0	0
\"	0	0	0	0	0	0	0	0	0	0	0
.	0	0	0	0	0	0	0	0	0	0	0
?	0	0	0	0	0	0	0	0	0	0	0
!	0	0	0	0	0	0	0	0	0	0	0
iː	0	1	0	1	0	0	1	1	0	0	0
ɪ	0	1	0	0	0	0	0.6	1	0	0	0
i	0	1	0	0	0	0	0.6	1	0	0	0
e	0	1	0	0	0	0	0.4	1	0	0	0
ɛ	0	1	0	0	0	0	0.2	1	0	0	0
æ	0	1	0	0	0	0	0	1	0	0	0
ə	0	1	0	0	0	0	0.4	0.5	0	0	0
ᵻ	0	1	0	0	0	0	0.4	0.5	0	0	0
ɐ	0	1	0	0	0	0	0.4	0.5	0	0	0
ɚ	0	1	0	0	0	0	0.4	0.5	0	0	0
ɜː	0	1	0	1	0	0	0.4	0.5	0	0	0
ʌ	0	1	0	0	0	0	0.2	0.5	0	0	0
a	0	1	0	0	0	0	0	0.5	0	0	0
uː	0	1	0	1	0	0	1	0	0	0	1
ʊ	0	1	0	0	0	0	0.8	0	0	0	1
oː	0	1	0	1	0	0	0	0	0	0	1
ɔː	0	1	0	1	0	0	0.8	0	0	0	1
o	0	1	0	1	0	0	0	0	0	0	1
ɔ	0	1	0	0	0	0	0.8	0	0	0	1
ɑː	0	1	0	1	0	0	0	0	0	0	0
p	0	0	1	0	0	0	0	0	1	1	0
b	0	1	1	0	0	0	0	0	1	1	0
t	0	0	1	0	0	0	0	0	1	0.57	0
d	0	1	1	0	0	0	0	0	1	0.57	0
ɾ	0	1	1	0	0	0	0	0	0.75	0.57	0
k	0	0	1	0	0	0	0	0	1	0.14	0
ɡ	0	1	1	0	0	0	0	0	1	0.14	0
f	0	0	1	0	0	0	0	0	0.5	0.86	0
v	0	1	1	0	0	0	0	0	0.5	0.86	0
θ	0	0	1	0	0	0	0	0	0.5	0.71	0
ð	0	1	1	0	0	0	0	0	0.5	0.71	0
s	0	0	1	0	0	0	0	0	0.5	0.57	0
z	0	1	1	0	0	0	0	0	0.5	0.57	0
ʃ	0	0	1	0	0	0	0	0	0.5	0.43	0
ʒ	0	1	1	0	0	0	0	0	0.5	0.43	0
x	0	0	1	0	0	0	0	0	0.5	0.14	0
h	0	1	1	0	0	0	0	0	0.5	0	0
m	0	1	0	0	1	0	0	0	1	1	0
n	0	1	0	0	1	0	0	0	1	0.57	0
ŋ	0	1	0	0	1	0	0	0	1	0.14	0
l	0	1	0	0	0	0	0	0	0.25	0.57	0
r	0	1	0	0	0	1	0	0	0.25	0.57	0
ɹ	0	1	0	0	0	1	0	0	0.25	0.57	0
j	0	1	0	0	0	0	0	0	0	0.29	0
w	0	1	0	0	0	0	0	0	0	0.14	0
ʔ	0	0	1	0	0	0	0	0	1	0	0
