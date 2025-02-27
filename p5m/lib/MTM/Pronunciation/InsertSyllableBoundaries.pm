package MTM::Pronunciation::InsertSyllableBoundaries;

# Syllabify entries in file

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

use MTM::TTSNodeFactory;
use MTM::Pronunciation::Syllabify;
use MTM::Pronunciation::SyllabifyText;
use MTM::Vars;
use MTM::Pronunciation::Conversion;

my %sylls = ();
my %to_check = ();
my %syllkey = ();
my %syllorth = ();

my $to_check = 0;

#my $sylls_file = $outfile;
#$sylls_file =~ s/\./_sylls\./;

#my $to_check_file = $outfile;
#$to_check_file =~ s/\./_to_check\./;

# perl scripts/syllabify_file.pl tmp/metadata/tora_phonemes_220517.txt tmp/metadata/tora_phonemes_syll_220517.txt

#&read_syllkey();

#**************************************************************#
sub insert_syllable_boundaries {

	my( $word, $phones, $syllabify_text, $fh_warnings,  ) = @_;
	#$word =~ s/ /\~/g;
	$word =~ s/\~//g;
	$phones =~ s/\|//g;

	if( $phones =~ /\"/ && $phones !~ /\`/ ) {
		$phones = &MTM::Pronunciation::Stress::insert_secondary_stress( $phones, $MTM::Vars::tpa_vowel );
	}

	my $word2 = &MTM::Case::makeLowercase( $word );

	#my $t = 'avgifterna	"a2: v j `i f t ë rn a';
	#if( exists( $syllkey{ $t } )) {
	#	print "TTT $t\t$syllkey{ $t }\n";
	#}

	my $key = "$word\t$phones";
	my $key2 = "$word2\t$phones";

	if( exists( $syllkey{ $key } )) {
		my( $decomp, $phones ) = split/\t/, $syllkey{ $key };
		return( $phones, $decomp, 'SYLLKEY' );
		#print "$word\t$syllkey{ $key }\n";
	} elsif( exists( $syllkey{ $key2 } )) {
		my( $decomp, $phones ) = split/\t/, $syllkey{ $key2 };
		return( $phones, $decomp, 'SYLLKEY' );
	} else {
		if( exists( $syllorth{ $word } )) {
			print "syllorth\t$word\t$phones\n$syllorth{ $word }\n\n";
		}
	}

#	if( $key =~ /(JeanJacques|fyrtio.*åtta)/i ) {
#		print "III $key\t$syllkey{ $key }\n";
#		print "III $key2\t$syllkey{ $key2 }\n";
#	}

	my $orig_phones = $phones;

	#print STDERR "1. word $word\tphone $phones\n";

	my $case = 'all';
	my $posmorph = 'NN';

	# Look up in dictionary and get pronunciation
	my ( @dictinfo ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( $word, $case, $posmorph, '-' );
	my $dictpron = $dictinfo[0];
	my $decomp = '-';

	# print STDERR "1. word $word\tphone $phones\t$dictpron\n@dictinfo";exit;

	# Get syllable boundary from decomposition in orthography if n boundaries are equal.
	if( $dictpron ne '-' ) {
		$decomp = &compare_n_boundaries( $dictpron, $dictinfo[4] );

		# Decomp
		if( $decomp eq '-' ) {
			#my ( $compound_generated, $metadata ) = &MTM::Pronunciation::Decomposition::decompose( 'musiköra', 0 );

			my( $alternatives, $metadata ) = &MTM::Pronunciation::Decomposition::decomp( $word );
			my %alternatives = %{$alternatives};

			if( %alternatives ) {
				my( $highAlt, $highMetadata ) = &MTM::Pronunciation::Decomposition::compare_alts( $alternatives, $metadata );
				# print STDERR "ALT $highAlt\t1. word $word\tphone $phones\tdecomp $decomp\tdictpron $dictpron\n";
				$decomp = &compare_n_boundaries( $dictpron, $highAlt );
			}
		}

	}

	# print STDERR "2. word $word\tphone $phones\tdictpron $dictpron\tdecomp $decomp\n";

	# Check if compound and generate pronunciation
	if( $dictpron eq '-' ) {
		my( @compinfo ) = &MTM::Pronunciation::Pronunciation::compound_check( $word, 0 );
		$dictpron = $compinfo[0];
		if( $dictpron =~ /(void|- -)/ ) {
			$dictpron = '-';
		} else {
			$decomp = $compinfo[4];
		}
		# print "HOHOHO $dictpron\n";
	}

	# If not pronounceable, create pronunciation to catch correct syllables boundaries for spelling.
	if( $dictpron eq '-' ) {
		my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $word );
		if( $pronunciability == 0 ) {
			$dictpron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $word );

			# Syllable boundaries between all letters
			$word =~ s/(.)/-$1/g;
			$word =~ s/^-//;
			$word =~ s/-$//;
		}
	}

	#print STDERR "3. word $word\tphone $phones\tdictpron $dictpron\n";

	# Not found in dictionary or supposed compound: syllabify orig orthography and pronunciation (still TPA)
	if( $dictpron eq '-' ) {
		my $saved_nasal = 0;
		if( $phones =~ /([aoe]n)/ ) {
			$saved_nasal = $1;
		}
		my $saved_affricate = 0;
		if( $phones =~ /(t?j3)/ ) {
			$saved_affricate = $1;
		}
		my $saved_ae = 0;
		if( $phones =~ /(ä) / ) {
			$saved_ae = $1;
		}

		#$phones = &taco2tpa( $phones );
		$phones = &MTM::Pronunciation::Syllabify::syllabify( $phones );
		#$phones = &tpa2taco( $phones, $saved_nasal, $saved_affricate, $saved_ae );
	} else {
		#$dictpron = &tpa2taco( $dictpron );
		#if( $dictpron =~ /r s r t/ ) { print "HOHO $dictpron\n"; }
	}

	#print STDERR "4. word $word\tphone $phones\tdictpron $dictpron\n";

	# Remove word initial retroflexation, e.g. in "rdessutom"
	my $p2 = $phones;
	$p2 =~ s/^r([dtsnl])/r $1/;

	my $dp_no_sylls = $dictpron;
	$dp_no_sylls =~ s/ä /e /g;
	$dp_no_sylls =~ s/ [\|\~\$\-] / /g;	# \-
	my $dp_no_sylls_or_stress = $dp_no_sylls;
	$dp_no_sylls_or_stress =~ s/[\'\"\`]//g;

	# 230128	$phones = &fix_pron( $phones );

	my @word = split/ [\|\-\~\$] /, $phones;
	foreach my $w ( @word ) {
		$sylls{ $w }++;
	}

	# print STDERR "5. word $word\tphone $phones\tdp_no_sylls $dp_no_sylls\tdp_no_sylls_or_stress $dp_no_sylls_or_stress\tp2 $p2\t\n";

	# Compare new pron(s) with dictpron	
	if( $phones ne $dp_no_sylls && $phones ne $dp_no_sylls_or_stress && $p2 ne $dp_no_sylls ) {
		$to_check++;
		$to_check{ "$word	$phones	$p2	$dp_no_sylls	$dictpron" }++;
		#print "DP $word	$phones	$p2	$dp_no_sylls\n";
	} else {
		$phones = $dictpron;
	}

	# If no stress in input phones, remove them
	if( $orig_phones !~ /[\'\"\`]/ ) {
		$phones =~ s/[\'\"\`]//g;
	}

	#print STDERR "6. word $word\tphone $phones\tdictpron $dictpron\t\n";


	# $phones = pronunciation in file
	# $p2 = $phones without initial retroflexes
	# $dp_no_sylls = pronunciation from dictionary, ä -> e, no boundaries

	#if( $phones !~ /-/ && length( $word ) > 10 && $dp_no_sylls =~ / - / ) {
	if( $phones !~ /-/ && $phones =~ /\`/ && length( $word ) > 10 ) {
		#print "WARNING\t$word\t$p\t$dictpron\n";
		#print "dp_no_sylls $dp_no_sylls\n";
		my $to_print = $dp_no_sylls;
		if( $phones =~ / - / ) {
			$to_print =~ s/^-$/$phones/
		}
#		print $fh_warnings "WARNING	$word\t$to_print\n";
	}

	if( $phones =~ /[aouåeiyäöë].+[aouåeiyäöë]/ && $phones !~ /\$/ ) {
		#$phones = &taco2tpa( $phones );
		$phones = &MTM::Pronunciation::Syllabify::syllabify( $phones );
		#$phones = &tpa2taco( $phones );
		if( $phones =~ /[aouåeiyäöë].+[aouåeiyäöë]/ && $phones !~ /[\|\-\~\$]/ ) {
			print "WARNING\t$word\t$phones\n";
		}
	}

	#$phones = &tpa2taco( $phones, $word );
	#print "taco $phones\n";

	#if( $word =~ /lll/ ) { 
		#print "$word\t$p\n"; 
	#}

	$phones =~ s/ +/ /g;

	# print STDERR "100. phones $phones\tdecomp $decomp\n";

	my $lc_decomp = &MTM::Case::makeLowercase( $decomp );

	if( $syllabify_text == 1 ) {
		$decomp = &MTM::Pronunciation::SyllabifyText::syllabify_text( $lc_decomp, $phones );
	}

	#if( $word =~ /BOKTRYCKERI/i ) { print "2. HOHOH $decomp\t$phones\t$lc_decomp\n"; }

	#print "RETURN $decomp\t$phones\n\n";

	$decomp =~ s/^-$/$word/;

	return( $phones, $decomp, 'NO' );
}

##********************************************#
#sub print_syllables {
#	open my $fh_SYLLS, '>', $sylls_file or die "Cannot open SYLLS $sylls_file: $!";
#	print "SYLLS $sylls_file opened\n";
#	#while(my( $k, $v ) = each( %sylls )) {
#	foreach my $k ( sort{ $sylls{$b} <=> $sylls{$a}} keys %sylls ) {
#		#print "I $k\t$v\n";
#		print $fh_SYLLS "$k\t$sylls{ $k }\n";
#	}
#	close $fh_SYLLS;
#}
##********************************************#
#sub print_to_check {
#	open my $fh_TO_CHECK, '>', $to_check_file or die "Cannot TO_CHECK SYLLS $sylls_file: $!";
#	print "TO_CHECK $to_check_file opened\n";
#	#while(my( $k, $v ) = each( %sylls )) {
#	foreach my $k ( sort{ $to_check{$b} <=> $to_check{$a}} keys %to_check ) {
#		#print "I $k\t$v\n";
#		print $fh_TO_CHECK "$k\t$to_check{ $k }\n";
#	}
#	close $fh_TO_CHECK;
#
#	print "To check: $to_check\n";
#}
#********************************************#
sub taco2tpa {
	my $phones = shift;

	$phones =~ s/([\'\"\`]) /$1/g;

	$phones =~ s/ää/ä3/g;
	$phones =~ s/öö/ö3/g;
	$phones =~ s/([aouåeiyäö]):/$1 2:/g;
	$phones =~ s/ 2:/2:/g;

	$phones =~ s/ t tj/ tj3/g;
	$phones =~ s/d j/j3/g;

	$phones =~ s/ \.$//g;


	if( $phones =~ /\"/ && $phones !~ /\`/ ) {
		my @p = split/ /, $phones;

		my $main_seen = 0;
		foreach my $pp ( @p ) {
			# print "M $main_seen\t$pp\n";

			if( $main_seen == 1 && $pp =~/[aouåeiyäö]/ ) {
				$main_seen = 0;
				$pp =~ s/^(.+)$/\`$1/;
				#print "UU $pp\n";
			} elsif( $pp =~ /\"/ ) {
				$main_seen = 1;
			}
		}

		$phones = join' ', @p;
	}


	return $phones;
}
#********************************************#
sub tpa2taco {
	my $phones = shift;
	my $word = shift;

#	$phones =~ s/[\'\"\`]//g;
#	$phones =~ s/ [\|\-\~] / \$ /g;
#	$phones =~ s/([reouöä]|rs)3/$1/g;
#	$phones =~ s/ä /e /g;
#	$phones =~ s/ä$/e/g;
#	$phones =~ s/t i3 \$ o/t i \$ o/g;
#	$phones =~ s/i3/i/g;
#	$phones =~ s/r0/r/g;
#
#	$phones =~ s/ë/e/g;
#	$phones =~ s/2:/:/g;
#	$phones =~ s/r([tdsnl])( |$)/r $1$2/g;
#
##	$phones =~ s/ö3/öö/g;
##	$phones =~ s/ä3/ää/g;
##	$phones =~ s/ä+ /e /g;
#


	if( $phones =~ /\"/ && $phones !~ /\`/ ) {

		my @p = split/ /, $phones;

		my $main_seen = 0;
		my $v_seen = 0;
		foreach my $pp ( @p ) {
			# print "M $main_seen\t$v_seen\t$pp\n";

			if( $main_seen == 1 && $v_seen == 0 && $pp =~/[aouåeiyäö]/ ) {
				$v_seen = 1;
			} elsif( $main_seen == 1 && $v_seen == 1 && $pp =~/[aouåeiyäö]/ ) {
				$main_seen = 0;
				$v_seen = 0;
				$pp =~ s/^(.+)$/\` $1/;
				#print "UU $pp\n";
			} elsif( $pp eq '"' ) {
				$main_seen = 1;
			}
		}

		$phones = join' ', @p;

		#if ( $saved_nasal ne '0' ) {
		#	$phones =~ s/[aio] n/$saved_nasal/g;
		#}
		#if( $saved_affricate eq '1' ) {
		#	$phones =~ s/[aio] n/$saved_nasal/g;
		#}


#		print "HOHO $phones\n";
	}

	return $phones;
}
#********************************************#
sub fix_pron {
	my $phones = shift;
	my $w = shift;

	if( $phones eq 'usas' ) { $phones = "u2: \$ e s \$ 'a2: s"; }
	if( $phones eq 'smguld' ) { $phones = "\"e s \$ e m - g \`u l d"; }
	if( $phones eq 'snabela' ) { $phones = "s n \"a2: \$ b ë l - \`a2:"; }
	if( $phones eq 'tshirt' ) { $phones = "t \'i2: \~ rs ö3: rt"; }
	if( $phones eq 'nnn' ) { $phones = "e n \~ e n \~ \'e n"; }
	if( $phones eq 'mmm' ) { $phones = "e m \~ e m \~ \'e m"; }
	if( $phones eq 'fff' ) { $phones = "e f \~ e f \~ \'e f"; }
	if( $phones eq 'sss' ) { $phones = "e s \~ e s \~ \'e s"; }
	if( $phones eq 'lll' ) { $phones = "e l \~ e l \~ \'e l"; }
	if( $phones eq 'xxx' ) { $phones = "e k s \~ e k s \~ \'e k s"; }
	if( $phones eq 'ååå' ) { $phones = "å2: \~ å2: \~ \'å2:"; }
	if( $phones eq 'äää' ) { $phones = "ä2: \~ ä2: \~ \'ä2:"; }
	if( $phones eq 'ööö' ) { $phones = "ö2: \~ ö2: \~ \'ö2:"; }
	if( $phones eq 'mcworld' ) { $phones = "m ä3 k \~ w \'ö3: r0 l d"; }
	if( $phones eq 'krishnas' ) { $phones = "k r \'i \$ rs rn a s"; }
	if( $phones eq 'herrön' ) { $phones = "h \"ä3 r - \`ö2: n"; }
	if( $phones eq 'jfr' ) { $phones = "j i2: \~ e f \~ \'ä3 r"; }
	if( $phones eq 'rooiboste' ) { $phones = "r \"å j \$ b å s - t \`e2:"; }
	if( $phones eq 'sskutredning' ) { $phones = "\"e s \~ e s \~ k å2: - u2: t - r \`e2: d \$ n i ng"; }
	if( $phones eq 'llförlaget' ) { $phones = "\" e l \~ e l - f ö3 \$ rl \`a2: \$ g ë t"; }
	if( $phones eq 'årl' ) { $phones = "å2: \~ ä3 r \~ \'e l"; }
	if( $phones eq 'grubg' ) { $phones = "g e2: \~ ä3: r \~ u2: \~ b e2: \~ g \'e2:"; }
	if( $phones eq 'fnuppdrag' ) { $phones = "\"e f \~ e n - u p - d r \`a2: g"; }
	if( $phones eq 'asq' ) { $phones = "a2: \~ e s - k \'u2:"; }
	if( $phones eq 'vsoyv' ) { $phones = "v e2: \~ e s \~ o2: \~ y2: \~ v \'e2:"; }
	if( $phones eq 'dnsservrar' ) { $phones = "d e2: \~ e n \~ \"e s - s \`ö3 r \$ v r a r"; }
	if( $phones eq 'förstes' ) { $phones = "f \"ö3 \$ rs rt \`ë rs"; }
	if( $phones eq 'rättsväsen' ) { $phones = "r \"ä t s - v \`ä2: \$ s ë n"; }
	if( $phones eq 'fnförkortningar' ) { $phones = "\"e f \~ e n - f ö3 r \$ k \`å rt \$ rn i ng \$ a r"; }
	if( $phones eq 'Kambodja' ) { $phones = "k a m \$ b 'å d \$ rs a"; }
	if( $phones eq 'Blache' ) { $phones = "b l a \$ rs 'e2:"; }
	if( $phones eq 'talkshow' ) { $phones = "t 'å2: k \~ rs öw"; }
	if( $phones eq 'Istvan' ) { $phones = "'i \$ rs v a n"; }
	if( $phones eq 'Krishnas' ) { $phones = "k r \'i \$ rs rn a s"; }
	if( $phones eq 'rst' ) { $phones = "ä3 r \~ e s \~ t 'e2:"; }
	if( $phones eq 'sse' ) { $phones = "e s \~ e s \~ 'e2:"; }
	if( $phones eq 'gudvadduserfräschutkommentarer' ) { $phones = "g u2: d \~ v a2: \~ d u2: \~ s e2: r \~ f r \"ä2: rs - u2: t - k å \$ m ë n \$ t \`a2: \$ r ë r"; }
	if( $phones eq 'fullkornspasta' ) { $phones = "f \"u l - k o2: rn rs - p \`a \$ s t a"; }

	return $phones;
}
#********************************************#
sub remove_retroflexes {
	my $phones = shift;
	$phones =~ s/p e \$ r s /p e r \$ s /g;
	$phones =~ s/(u \$ n i \$ v e|^o:) \$ r s/$1 r \$ s /g;
	$phones =~ s/ r \$ s o2: n/ \$ r s o2: n/g;
	$phones =~ s/ r \$ s o2: \$ n/ \$ r s o2: \$ n/g;
	$phones =~ s/i \$ m a \$ r s i \$ n/i \$ m a \$ sj i \$ n/;
	$phones =~ s/ö: \$ v e \$ r s /ö: \$ v e r \$ s /;

	$phones =~ s/^r s /sj /;

	$phones =~ s/\$ r ([tdnl])/r \$ $1/g;
	$phones =~ s/([åäö]) \$ r s /ö r \$ s /g;

	if( 
	$phones =~ s/r s r/r s/g) { print "P $phones\n"; }

	$phones =~ s/([aouåeiyäö])2:/$1:/g;

	$phones =~ s/tj3/t tj/g;
	$phones =~ s/j3/d j/g;

	#$phones =~ s/([\'\"\`])/$1 /g;
	$phones =~ s/(^| )[\'\"\`] /$1/g;

	$phones =~ s/r s r t/r s t/g;
	$phones =~ s/^r s /sj /;
	$phones =~ s/r s r t/r s t/g;
	$phones =~ s/r t r s/r t s/g;
	$phones =~ s/r \$ r s/ \$ r s/g;
	$phones =~ s/i t r s/i r sj/g;
	$phones =~ s/\$ r s r t /r \$ s t /g;
	$phones =~ s/r s r t/r s t/g;
	$phones =~ s/\$ r s t /r \$ s t /g;
	$phones =~ s/f ö \$ r s /f ö r \$ s /g;
	$phones =~ s/\$ r s k /r \$ s k /g;
	$phones =~ s/e \$ r s ([io])/e r \$ s $1/g;
	$phones =~ s/\$ r ([tdnl])/r \$ $1/g;
	$phones =~ s/^o: \$ r s/o: r \$ s/;

	return $phones;
}
#********************************************#
# Check if orth and pron have same number of morpheme 
# and compound boundaries.
sub compare_n_boundaries {
	my $dictpron = shift;
	my $dictdecomp = shift;

	# print STDERR "compare_n_boundaries\t$dictpron\t$dictdecomp\n";

	my $n_p_morph = $dictpron =~ s/(\~)/$1/g;		# Number of morpheme boundaries in phonemes
	my $n_g_morph = $dictdecomp =~ s/(\~)/$1/g;		# Number of morpheme boundaries in graphemes
	my $n_p_comp = $dictpron =~ s/(\-)/$1/g;		# Number of compound boundaries in phonemes
	my $n_g_comp = $dictdecomp =~ s/(\+)/$1/g;		# Number of compound boundaries in graphemes

	return $dictdecomp if ( $n_p_morph == $n_g_morph && $n_p_comp == $n_g_comp );
	return '-';
}
#********************************************#
sub read_syllkey {
	my $fh;
	## no critic (InputOutput::RequireBriefOpen)
	open $fh, '<', "data/swe-fem-speech-data-syllabified-words-2.txt" or die();
	## use critic
	while(<$fh>) {
		chomp;
		my( $o, $d, $p ) = split/\t/;
		my $oo = $o;

		# Triple consonants (till+lägga)
		$oo =~ s/([bdfglmnprst])\1\+\1/$1$1/g;

		$oo =~ s/[\+\-\~\ ]//g;

		if( $p =~ /\"/ && $p !~ /\`/ ) {
			$p = &MTM::Pronunciation::Stress::insert_secondary_stress( $p, $MTM::Vars::tpa_vowel );
		}


		my $pp = $p;
		$pp =~ s/ [\$\-\~] / /g;

		my $pp2 = $pp;
		my $pp3 = $pp;
		$pp2 =~ s/ä /e /g;
		$pp3 =~ s/e /ä /g;

		$oo = &MTM::Case::makeLowercase( $o );

		$syllkey{ "$o\t$pp" } = "$d\t$p";
		$syllkey{ "$o\t$pp2" } = "$d\t$p";
		$syllkey{ "$oo\t$pp" } = "$d\t$p";
		$syllkey{ "$oo\t$pp3" } = "$d\t$p";

		$syllorth{ $o } .= "\t$p\t$pp\t$pp2\t$pp3";
	}
	close $fh;
	return 1;
}
#********************************************#
1;