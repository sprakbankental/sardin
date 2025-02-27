package MTM::Pronunciation::ConvertToFeatures;
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
our %eng_phone_feats;
our %all_feats;

#******************************************************#
# FEATURE CONVERSION
#******************************************************#
sub feature_conversion {
	my( $in, $infile ) = @_;

	my $saved_stress = 'void';

	my @ret = ();

	$in =~ s/au/a w/g;
	$in =~ s/eu/e w/g;

	my @phones;

	@phones = split/ /, $in;

	#while(my($k,$v)=each(%swe_phone_feats)){ print "I $k\t$v\n"; }exit;

	my $i = 0;
	foreach my $phone ( @phones ) {

		#print "\n-------------------------------\nphone\t$phone\n$in\n";

		if( $phone !~ /^\d+$/ ) {
			my $features;

			# Phone (Swedish)
			if( $infile =~ /(phoneme-accent|tts_sv_input|nordanvinden|nasality)/ && exists( $swe_phone_feats{ $phone } )) {
				$features = $swe_phone_feats{ $phone };

				my @features = split/\t/, $features;

				if( $saved_stress ne 'void' ) {

					# Main stress
					if( $saved_stress =~ /^[\"\']$/ ) {
						$features[1] = 1;

						# Accent2
						if( $saved_stress eq '"' ) {
							$features[2] = 1;
						}
					# Seconday stress
					} elsif ( $saved_stress eq '`' ) {
						$features[1] = 0.5;
						$features[2] = 1;
					}

					$features = join"\t", @features;
				}

				#print "PHONES	@phones\n";
				#print "LC	$phones[$i-1]\n";
				#print "NOW	$phones[$i]\n";
				#print "RC	$phones[$i+1]\n";

				# Context
				# Add 0.25 nasality for each nasal next to target phone ( $feature[7] )
				my $nasality = 0;
				if( $features[7] == 0 ) {
					if( $i != 0 ) {
						my $lc_phone = $phones[$i-1];
						if( $lc_phone =~ /[\"\'\`\&]/ && $i != 1 ){
							$lc_phone = $phones[$i-2];
						}
						#if( $phones[$i-1] ne $lc_phone ) {
						#	print "TRUE LC $phones[$i-1]	$lc_phone\n\n";
						#}

						if( $lc_phone =~ /(m|n|ng|rn)/ ) {
							$nasality += 0.25;
						}
					}
					if( $i != $#phones ) {
						if( $phones[$i+1] =~ /(m|n|ng|rn)/ ) {
							$nasality += 0.25;
						}
					}
					#print "NNN $nasality\n";
					$features[7] += $nasality;
					$features = join"\t", @features;
				}
				#if( $phone eq 'n' ) { exit; }
				$features =~ s/\t/,/g;
				#print "$phone\t$features\n";
				push @ret, $features;
				$saved_stress = 'void';

				$all_feats{ $features }++;

			# Phone (English)
			} elsif( $infile =~ /(eng-fem|ljs_audio|ryan|carrier)/ && exists( $eng_phone_feats{ $phone } )) {
				$features = $eng_phone_feats{ $phone };
				#print "HHH $phone	$features\n";
				if( $saved_stress ne 'void' ) {
					my @features = split/\t/, $features;

					# Main stress
					if( $saved_stress =~ /^[\"\'\ˈ]$/ ) {
						$features[0] = 1;
						# Accent2
						#if( $saved_stress eq '"' ) {
						#	$features[2] = 1;
						#}
					# Seconday stress
					} elsif ( $saved_stress =~ /^[\`\ˌ]$/ ) {
						$features[0] = 0.5;
						#$features[2] = 0.5;
					}

					$features = join"\t", @features;

				}

#				# Context
#				# Add 0.25 nasality for each nasal next to target phone ( $feature[7] )
#				my @features = split/\t/, $features;
#				my $nasality = 0;
#				if( $features[7] == 0 ) {
#					if( $i != 0 ) {
#						my $lc_phone = $phones[$i-1];
#						if( $lc_phone =~ /[\"\'\`\&]/ && $i != 1 ){
#							$lc_phone = $phones[$i-2];
#						}
#						#if( $phones[$i-1] ne $lc_phone ) {
#						#	print "TRUE LC $phones[$i-1]	$lc_phone\n\n";
#						#}
#				
#						if( $lc_phone =~ /(m|n|ng|rn)/ ) {
#							$nasality += 0.25;
#						}
#					}
#					if( $i != $#phones ) {
#						if( $phones[$i+1] =~ /(m|n|ng|rn)/ ) {
#							$nasality += 0.25;
#							print "JA $lc_phone\n";
#						}
#					}
#					#print "NNN $nasality\n";
#					$features[7] += $nasality;
#					$features = join"\t", @features;
#				}		
				$features =~ s/\t/,/g;
				#print "$phone\t$features\n";
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

	#print "RETURNING @ret\n";

	return join' ', @ret;
}
#******************************************************#
sub read_features {
	my $lang = 'Swedish';

	while(<DATA>) {
		if( /English/ ) {
		#	$lang = 'English';
		}
		chomp;
		next if /\#/;
		my @line = split/\t/;
		my $phone = shift @line;

		if( $lang eq 'Swedish' ) {
			$swe_phone_feats{ $phone } = join'	', @line;
			print "$phone\t$swe_phone_feats{ $phone }\n";
		} elsif ( $lang eq 'English' ) {
			$eng_phone_feats{ $phone } = join'	', @line;
		#	print "$phone\t$eng_phone_feats{ $phone }\n";
		}
	}
	close DATA;
	
	return 1;
}
#******************************************************#
1;
__DATA__
# Simulating speech disorders (nasality and fronting). Alexander Näslunds candidate thesis 2024.
#	c/v	stress	accent	complexity	voicing	obstruent	length	nasality	rhotic	vowel height	vowel backness	conso stricture	conso place	lip rounding	aspiration	lang
#/	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
#an	0	0	0	0	1	0	1	1	0	0	0	0	0	0	0	0
#en	0	0	0	0	1	0	1	1	0	0.5	1	0	0	0	0	0
#on	0	0	0	0	1	0	1	1	0	1	0	0	0	1	0	0
#i:	0	0	0	0	1	0	1	0	0	1	1	0	0	0	0	0
#i	0	0	0	0	1	0	0	0	0	0.83	1	0	0	0	0	0
#y:	0	0	0	0	1	0	1	0	0	1	1	0	0	1	0	0
#y	0	0	0	0	1	0	0	0	0	0.83	1	0	0	1	0	0
#e:	0	0	0	0	1	0	1	0	0	0.67	1	0	0	0	0	0
#e	0	0	0	0	1	0	0	0	0	0.5	1	0	0	0	0	0
#ë	0	0	0	0	1	0	0	0	0	0.5	0.5	0	0	0	0	0
#ö:	0	0	0	0	1	0	1	0	0	0.67	1	0	0	1	0	0
#ö	0	0	0	0	1	0	0	0	0	0.5	1	0	0	1	0	0
#ä:	0	0	0	0	1	0	1	0	0	0.5	1	0	0	0	0	0
#ä	0	0	0	0	1	0	0	0	0	0.5	1	0	0	0	0	0
#ää:	0	0	0	0	1	0	1	0	0	0.33	1	0	0	0	0	0
#ää	0	0	0	0	1	0	0	0	0	0.33	1	0	0	0	0	0
#öö:	0	0	0	0	1	0	1	0	0	0.17	1	0	0	1	0	0
#öö	0	0	0	0	1	0	0	0	0	0.17	1	0	0	1	0	0
#a:	0	0	0	0	1	0	1	0	0	0	0	0	0	0	0	0
#a	0	0	0	0	1	0	0	0	0	0	1	0	0	0	0	0
#u:	0	0	0	0	1	0	1	0	0	0.83	0.5	0	0	1	0	0
#u	0	0	0	0	1	0	0	0	0	0.37	0.5	0	0	1	0	0
#o:	0	0	0	0	1	0	1	0	0	1	0	0	0	1	0	0
#o	0	0	0	0	1	0	0	0	0	1	0	0	0	1	0	0
#å:	0	0	0	0	1	0	1	0	0	0.67	0	0	0	1	0	0
#å	0	0	0	0	1	0	0	0	0	0.33	0	0	0	1	0	0
#p	1	0	0	0	0	1	0	0	0	0	0	1	1	0	1	0
#b	1	0	0	0	1	1	0	0	0	0	0	1	1	0	0	0
#t	1	0	0	0	0	1	0	0	0	0	0	1	0.85	0	1	0
#d	1	0	0	0	1	1	0	0	0	0	0	1	0.85	0	0	0
#rt	1	0	0	0	0	1	0	0	1	0	0	1	0.6	0	1	0
#rd	1	0	0	0	1	1	0	0	1	0	0	1	0.6	0	0	0
#k	1	0	0	0	0	1	0	0	0	0	0	1	0.4	0	1	0
#g	1	0	0	0	1	1	0	0	0	0	0	1	0.4	0	0	0
#f	1	0	0	0	0	1	0	0	0	0	0	0.75	0.95	0	0	0
#v	1	0	0	0	1	1	0	0	0	0	0	0.75	0.95	0	0	0
#s	1	0	0	0	0	1	0	0	0	0	0	0.75	0.85	0	0	0
#rs	1	0	0	0	0	1	0	0	1	0	0	0.75	0.6	0	0	0
#sj	1	0	0	0	0	1	0	0	0	0	0	0.75	0.4	0	0	0
#tj	1	0	0	0	0	1	0	0	0	0	0	0.75	0.5	0	0	0
#h	1	0	0	0	1	1	0	0	0	0	0	0.75	0	0	0	0
#m	1	0	0	0	1	0	0	1	0	0	0	1	0	0	0	1
#n	1	0	0	0	1	0	0	1	0	0	0	1	0.85	0	0	1
#rn	1	0	0	0	1	0	0	1	1	0	0	1	0.6	0	0	1
#ng	1	0	0	0	1	0	0	1	0	0	0	1	0.4	0	0	1
#l	1	0	0	0	1	0	0	0	0	0	0	0.5	0.85	0	0	0
#rl	1	0	0	0	1	0	0	0	1	0	0	0.5	0.6	0	0	0
#r	1	0	0	0	1	0	0	0	1	0	0	0.5	0.85	0	0	0
#j	1	0	0	0	1	0	0	0	0	0	0	0.25	0.5	0	0	0
#w	1	0	0	0	1	0	0	0	0	0	0	0.25	0.4	0	0	0
# English-accented Swedish TTS (Speech Prosody 2024)
#	0	1	2	3	4	5	6	7	8	9	10	11	12	13	14
#	conso	voice	diph	manner	nasal	place	height	front	main	sec	accent	round	length	asp	lang
# Swedish			(air through mouth!)
/	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
i:	0	1	0	0	0	0	1	1	0	0	0	0	1	0	0
i	0	1	0	0	0	0	0.85	1	0	0	0	0	0	0	0
y:	0	1	0	0	0	0	1	1	0	0	0	1	1	0	0
y	0	1	0	0	0	0	0.85	1	0	0	0	1	0	0	0
e:	0	1	0	0	0	0	0.75	1	0	0	0	0	1	0	0
e	0	1	0	0	0	0	0.5	1	0	0	0	0	0	0	0
ë	0	1	0	0	0	0	0.5	0.5	0	0	0	0	0	0	0
ö:	0	1	0	0	0	0	0.25	1	0	0	0	1	1	0	0
ö	0	1	0	0	0	0	0.25	1	0	0	0	1	0	0	0
ä:	0	1	0	0	0	0	0.5	1	0	0	0	0	1	0	0
ä	0	1	0	0	0	0	0.5	1	0	0	0	0	0	0	0
ää:	0	1	0	0	0	0	0.2	1	0	0	0	0	1	0	0
ää	0	1	0	0	0	0	0.2	1	0	0	0	0	0	0	0
öö	0	1	0	0	0	0	0.25	1	0	0	0	1	0	0	0
öö:	0	1	0	0	0	0	0	1	0	0	0	1	1	0	0
a:	0	1	0	0	0	0	0	0.5	0	0	0	0	1	0	0
a	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0
u:	0	1	0	0	0	0	1	0.5	0	0	0	0.5	1	0	0
u	0	1	0	0	0	0	1	0.5	0	0	0	0.5	0	0	0
o:	0	1	0	0	0	0	1	0	0	0	0	0.5	1	0	0
o	0	1	0	0	0	0	0.85	0	0	0	0	0.5	0	0	0
å:	0	1	0	0	0	0	0.75	0	0	0	0	0.5	1	0	0
å	0	1	0	0	0	0	0.25	0	0	0	0	0.5	0	0	0
p	1	0	0	1	0	1	0	0	0	0	0	0	0	0	0
b	1	1	0	1	0	1	0	0	0	0	0	0	0	0	0
t	1	0	0	1	0	0.7	0	0	0	0	0	0	0	0	0
d	1	1	0	1	0	0.7	0	0	0	0	0	0	0	0	0
rt	1	0	0	1	0	0.5	0	0	0	0	0	0	0	0	0
rd	1	1	0	1	0	0.5	0	0	0	0	0	0	0	0	0
k	1	0	0	1	0	0.2	0	0	0	0	0	0	0	0	0
g	1	1	0	1	0	0.2	0	0	0	0	0	0	0	0	0
f	1	0	0	0.75	0	0.9	0	0	0	0	0	0	0	0	0
v	1	1	0	0.75	0	0.9	0	0	0	0	0	0	0	0	0
s	1	0	0	0.75	0	0.7	0	0	0	0	0	0	0	0	0
rs	1	0	0	0.75	0	0.5	0	0	0	0	0	0	0	0	0
sj	1	0	0	0.75	0	0.2	0	0	0	0	0	0	0	0	0
tj	1	0	0	0.75	0	0.4	0	0	0	0	0	0	0	0	0
h	1	1	0	0.75	0	0	0	0	0	0	0	0	0	0	0
m	1	1	0	1	1	1	0	0	0	0	0	0	0	0	0
n	1	1	0	1	1	0.7	0	0	0	0	0	0	0	0	0
rn	1	1	0	1	1	0.5	0	0	0	0	0	0	0	0	0
ng	1	1	0	1	1	0.2	0	0	0	0	0	0	0	0	0
r	1	1	0	0.5	0	0.7	0	0	0	0	0	0	0	0	0
l	1	1	0	0.2	0	0.7	0	0	0	0	0	0	0	0	0
rl	1	1	0	0.2	0	0.5	0	0	0	0	0	0	0	0	0
j	1	1	0	0.5	0	0.4	0	0	0	0	0	0	0	0	0
w	1	1	0	0	0	0.2	0	0	0	0	0	0	0	0	0
## t_tj	1	0	0	0	0	0.9	0	0	0	0	0	0	0	0	0
## d_j	1	1	0	0	0	0.9	0	0	0	0	0	0	0	0	0
## p_f	1	0	0	0	0	0.3	0	0	0	0	0	0	0	0	0
## au	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0
## eu	0	1	1	0	0	0	0.5	1	0	0	0	0	0	0	0
## rs3	1	1	0	0.75	0	0.5	0	0	0	0	0	0	0	0	0
## r3	1	1	0	0	0	0.7	0	0	0	0	0	0	0	0	0
## r4	1	1	0	0.5	0	0.1	0	0	0	0	0	0	0	0	0
## x	1	0	0	0.75	0	0.2	0	0	0	0	0	0	0	0	0
## th	1	0	0	0.75	0	0.8	0	0	0	0	0	0	0	0	0
## dh	1	1	0	0.75	0	0.8	0	0	0	0	0	0	0	0	0
## z	1	1	0	0.75	0	0.7	0	0	0	0	0	0	0	0	0
## au	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0
## eu	0	1	1	0	0	0	0.5	1	0	0	0	0	0	0	0
##	0	1	2	3	4	5	6	7	8	9	10	11	12	13	14
##	conso	voice	diph	manner	nasal	place	height	back	main	sec	accent	round	length	asp	lang
## English
#/	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#i	0	1	0	0	0	0	1	1	0	0	0	0	1	0	1
#i:	0	1	0	0	0	0	0.85	1	0	0	0	0	0	0	1
#e	0	1	0	0	0	0	0.5	1	0	0	0	0	0	0	1
#ë	0	1	0	0	0	0	0.5	0.5	0	0	0	0	0	0	1
#ö:	0	1	0	0	0	0	0.25	1	0	0	0	1	1	0	1
#ö	0	1	0	0	0	0	0.25	1	0	0	0	1	0	0	1
#ä:	0	1	0	0	0	0	0.5	1	0	0	0	0	1	0	1
#ää	0	1	0	0	0	0	0.2	1	0	0	0	0	0	0	1
#öö:	0	1	0	0	0	0	0	1	0	0	0	1	1	0	1
#a:	0	1	0	0	0	0	0	0.5	0	0	0	0	1	0	1
#a	0	1	0	0	0	0	0	0	0	0	0	0	0	0	1
#u:	0	1	0	0	0	0	1	0.75	0	0	0	0.5	1	0	1
#u	0	1	0	0	0	0	0.8	0.75	0	0	0	0.5	0	0	1
#å:	0	1	0	0	0	0	0.75	0	0	0	0	0.5	1	0	1
#å	0	1	0	0	0	0	0.25	0	0	0	0	0.5	0	0	1
#p	1	0	0	1	0	1	0	0	0	0	0	0	0	0	1
#b	1	1	0	1	0	1	0	0	0	0	0	0	0	0	1
#t	1	0	0	1	0	0.7	0	0	0	0	0	0	0	0	1
#d	1	1	0	1	0	0.7	0	0	0	0	0	0	0	0	1
#k	1	0	0	1	0	0.2	0	0	0	0	0	0	0	0	1
#g	1	1	0	1	0	0.2	0	0	0	0	0	0	0	0	1
#f	1	0	0	0.75	0	0.9	0	0	0	0	0	0	0	0	1
#v	1	1	0	0.75	0	0.9	0	0	0	0	0	0	0	0	1
#s	1	0	0	0.75	0	0.7	0	0	0	0	0	0	0	0	1
#rs	1	0	0	0.75	0	0.5	0	0	0	0	0	0	0	0	1
#h	1	1	0	0.75	0	0	0	0	0	0	0	0	0	0	1
#m	1	1	0	0	1	1	0	0	0	0	0	0	0	0	1
#n	1	1	0	0	1	0.7	0	0	0	0	0	0	0	0	1
#ng	1	1	0	0	1	0.2	0	0	0	0	0	0	0	0	1
#l	1	1	0	0	0	0.7	0	0	0	0	0	0	0	0	1
#r	1	1	0	0.5	0	0.7	0	0	0	0	0	0	0	0	1
#j	1	1	0	0	0	0.4	0	0	0	0	0	0	0	0	1
#w	1	1	0	0	0	0.2	0	0	0	0	0	0	0	0	1
#th	1	0	0	0.75	0	0.9	0	0	0	0	0	0	0	0	1
#dh	1	1	0	0.75	0	0.9	0	0	0	0	0	0	0	0	1
#z	1	1	0	0.75	0	0.7	0	0	0	0	0	0	0	0	1
# LJSpeech + first Ryan attempt
#/	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#:	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#;	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#,	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#\"	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#.	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#?	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#!	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
#iː	0	0	0	0	1	0	1	0	0	1	1	0	0	0	0	1
#ɪ	0	0	0	0	1	0	0	0	0	0.6	1	0	0	0	0	1
#i	0	0	0	0	1	0	0	0	0	0.6	1	0	0	0	0	1
#e	0	0	0	0	1	0	0	0	0	0.4	1	0	0	0	0	1
#ɛ	0	0	0	0	1	0	0	0	0	0.2	1	0	0	0	0	1
#æ	0	0	0	0	1	0	0	0	0	0	1	0	0	0	0	1
#ə	0	0	0	0	1	0	0	0	0	0.4	0.5	0	0	0	0	1
#ᵻ	0	0	0	0	1	0	0	0	0	0.4	0.5	0	0	0	0	1
#ɐ	0	0	0	0	1	0	0	0	0	0.4	0.5	0	0	0	0	1
#ɚ	0	0	0	0	1	0	0	0	0	0.4	0.5	0	0	0	0	1
#ɜː	0	0	0	0	1	0	1	0	0	0.4	0.5	0	0	0	0	1
#ʌ	0	0	0	0	1	0	0	0	0	0.2	0.5	0	0	0	0	1
#a	0	0	0	0	1	0	0	0	0	0	0.5	0	0	0	0	1
#uː	0	0	0	0	1	0	1	0	0	1	0	0	0	1	1	1
#ʊ	0	0	0	0	1	0	0	0	0	0.8	0	0	0	1	1	1
#oː	0	0	0	0	1	0	1	0	0	0	0	0	0	1	0	1
#ɔː	0	0	0	0	1	0	1	0	0	0.8	0	0	0	1	0	1
#o	0	0	0	0	1	0	1	0	0	0	0	0	0	1	0	1
#ɔ	0	0	0	0	1	0	0	0	0	0.8	0	0	0	1	0	1
#ɑː	0	0	0	0	1	0	1	0	0	0	0	0	0	0	0	1
#p	1	0	0	0	0	1	0	0	0	0	0	1	1	0	0	1
#b	1	0	0	0	1	1	0	0	0	0	0	1	1	0	0	1
#t	1	0	0	0	0	1	0	0	0	0	0	1	0.57	0	0	1
#d	1	0	0	0	1	1	0	0	0	0	0	1	0.57	0	0	1
#ɾ	1	0	0	0	1	1	0	0	0	0	0	0.75	0.57	0	0	1
#k	1	0	0	0	0	1	0	0	0	0	0	1	0.14	0	0	1
#ɡ	1	0	0	0	1	1	0	0	0	0	0	1	0.14	0	0	1
#f	1	0	0	0	0	1	0	0	0	0	0	0.5	0.86	0	0	1
#v	1	0	0	0	1	1	0	0	0	0	0	0.5	0.95	0	0	1
#θ	1	0	0	0	0	1	0	0	0	0	0	0.5	0.71	0	0	1
#ð	1	0	0	0	1	1	0	0	0	0	0	0.5	0.71	0	0	1
#s	1	0	0	0	0	1	0	0	0	0	0	0.5	0.57	0	0	1
#z	1	0	0	0	1	1	0	0	0	0	0	0.5	0.57	0	0	1
#ʃ	1	0	0	0	0	1	0	0	0	0	0	0.5	0.43	0	0	1
#ʒ	1	0	0	0	1	1	0	0	0	0	0	0.5	0.43	0	0	1
#x	1	0	0	0	0	1	0	0	0	0	0	0.5	0.14	0	0	1
#h	1	0	0	0	1	1	0	0	0	0	0	0.5	0	0	0	1
#m	1	0	0	0	1	0	0	1	0	0	0	1	1	0	0	1
#n	1	0	0	0	1	0	0	1	0	0	0	1	0.57	0	0	1
#ŋ	1	0	0	0	1	0	0	1	0	0	0	1	0.14	0	0	1
#l	1	0	0	0	1	0	0	0	0	0	0	0.25	0.57	0	0	1
#r	1	0	0	0	1	0	0	0	1	0	0	0.25	0.57	0	0	1
#ɹ	1	0	0	0	1	0	0	0	1	0	0	0.25	0.57	0	0	1
#j	1	0	0	0	1	0	0	0	0	0	0	0	0.29	0	0	1
#w	1	0	0	0	1	0	0	0	0	0	0	0	0.14	0	0	1
##ʔ	1	0	0	0	0	1	0	0	0	0	0	1	0	0	0	1
# Ryan 240213
#		0	1	2	3	4	5	6	7	8	9	10
#index	LJSpeech	stress	voicing	obstruent	length	nasality	rhotic	vowel height	vowel frontness	stricture	c-place	lip rounding
#/	0	0	0	0	0	0	0	0	0	0	0
#:	0	0	0	0	0	0	0	0	0	0	0
#;	0	0	0	0	0	0	0	0	0	0	0
#,	0	0	0	0	0	0	0	0	0	0	0
#\"	0	0	0	0	0	0	0	0	0	0	0
#.	0	0	0	0	0	0	0	0	0	0	0
#?	0	0	0	0	0	0	0	0	0	0	0
#!	0	0	0	0	0	0	0	0	0	0	0
#iː	0	1	0	1	0	0	1	1	0	0	0
#ɪ	0	1	0	0	0	0	0.6	1	0	0	0
#i	0	1	0	0	0	0	0.6	1	0	0	0
#e	0	1	0	0	0	0	0.4	1	0	0	0
#ɛ	0	1	0	0	0	0	0.2	1	0	0	0
#æ	0	1	0	0	0	0	0	1	0	0	0
#ə	0	1	0	0	0	0	0.4	0.5	0	0	0
#ᵻ	0	1	0	0	0	0	0.4	0.5	0	0	0
#ɐ	0	1	0	0	0	0	0.4	0.5	0	0	0
#ɚ	0	1	0	0	0	0	0.4	0.5	0	0	0
#ɜː	0	1	0	1	0	0	0.4	0.5	0	0	0
#ʌ	0	1	0	0	0	0	0.2	0.5	0	0	0
#a	0	1	0	0	0	0	0	0.5	0	0	0
#uː	0	1	0	1	0	0	1	0	0	0	1
#ʊ	0	1	0	0	0	0	0.8	0	0	0	1
#oː	0	1	0	1	0	0	0	0	0	0	1
#ɔː	0	1	0	1	0	0	0.8	0	0	0	1
#o	0	1	0	1	0	0	0	0	0	0	1
#ɔ	0	1	0	0	0	0	0.8	0	0	0	1
#ɑː	0	1	0	1	0	0	0	0	0	0	0
#p	0	0	1	0	0	0	0	0	1	1	0
#b	0	1	1	0	0	0	0	0	1	1	0
#t	0	0	1	0	0	0	0	0	1	0.57	0
#d	0	1	1	0	0	0	0	0	1	0.57	0
#ɾ	0	1	1	0	0	0	0	0	0.75	0.57	0
#k	0	0	1	0	0	0	0	0	1	0.14	0
#ɡ	0	1	1	0	0	0	0	0	1	0.14	0
#f	0	0	1	0	0	0	0	0	0.5	0.86	0
#v	0	1	1	0	0	0	0	0	0.5	0.86	0
#θ	0	0	1	0	0	0	0	0	0.5	0.71	0
#ð	0	1	1	0	0	0	0	0	0.5	0.71	0
#s	0	0	1	0	0	0	0	0	0.5	0.57	0
#z	0	1	1	0	0	0	0	0	0.5	0.57	0
#ʃ	0	0	1	0	0	0	0	0	0.5	0.43	0
#ʒ	0	1	1	0	0	0	0	0	0.5	0.43	0
#x	0	0	1	0	0	0	0	0	0.5	0.14	0
#h	0	1	1	0	0	0	0	0	0.5	0	0
#m	0	1	0	0	1	0	0	0	1	1	0
#n	0	1	0	0	1	0	0	0	1	0.57	0
#ŋ	0	1	0	0	1	0	0	0	1	0.14	0
#l	0	1	0	0	0	0	0	0	0.25	0.57	0
#r	0	1	0	0	0	1	0	0	0.25	0.57	0
#ɹ	0	1	0	0	0	1	0	0	0.25	0.57	0
#j	0	1	0	0	0	0	0	0	0	0.29	0
#w	0	1	0	0	0	0	0	0	0	0.14	0
#ʔ	0	0	1	0	0	0	0	0	1	0	0
