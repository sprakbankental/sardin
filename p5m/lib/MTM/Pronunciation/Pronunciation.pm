﻿package MTM::Pronunciation::Pronunciation;

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

use MTM::Pronunciation::Validation::Base;
use MTM::Pronunciation::Conversion::TPA;

##### Take care of these
our $debug;
my $mode = 'preprocess';

#**************************************************************#
# Pronounciation
#
# Language	sv_se
#
# Rules for pronounciation.
# 
# Return: pronunciation
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub pronounce_and_insert {

	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	# print STDERR "pronounce_and_insert\t$t->{orth}\t$t->{pron}\n";

	# 210811 Pronunciation is already done
	return $self if MTM::Legacy::isDefault( $t->{pron} ) == 0;
	return $self if $t->{exp} =~ /<none>/i;		# 20231130

	my $word = $t->{orth};

	# 240410 Mix of Greek and Latin letters trigger wide character warning.
	# TODO fix this.
	if( $word =~ /(\P{Script=Latin}).*\p{Script=Latin}/ || $word =~ /\p{Script=Latin}.*(\P{Script=Latin})/ ) {
		if( $1 !~ /[$MTM::Vars::delimiter\-]/ ) {
			return ( '-', 'NN', 'swe', 'swe', '-', '-', '-' );
		}
	}


	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_dict_main)){ print "m $k\t$v\n"; }
	# print STDERR "W $word\t$t->{exp}\n";

	if( &MTM::Legacy::isDefault( $t->{exp} )) {
		# keep $word
	} else {
		# $word is the expansion
		$word = $t->{exp};
	}

	### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
	#if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $word !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
	# 210927	utf8::encode( $word );
	#}

	# print STDERR "pronunciation $word\n";

	if(
		$word =~ /(?:\p{Latin}{1}|\d)/
		||
		(
			$t->{exp} =~ /(?:\p{Latin}{1}|\d)/
			&&
			$t->{exp} !~ /DEFAULT/i
		)
		&&
		$t->{pron} !~ /[\"\'\`]/
		&&
		$word !~ /^__mute_(\§\§|\§|kap\.?|st\.?)/		##### TODO special rule for law text
		&&
		$word !~ /\§/
	) {

		my ( $p, $pos_morph, $ortlang, $pronlang, $decomposed, $pron_method, $id );
		my @words = split/[\| ]/, $word;
		my @pron = ();
		foreach my $wd( @words ) {
			#print "I $wd\n";
			( $p, $pos_morph, $ortlang, $pronlang, $decomposed, $pron_method, $id ) = &MTM::Pronunciation::Pronunciation::pronounce( $self, $chunk, $wd );
			# print STDERR "PPPPP $wd\t$p\t$pos_morph\n";
			chomp $p; 
			push @pron, $p;
		}

		my $pron = join' | ', @pron;

		# No main stress
		if( $pron !~ /[\"\']/ ) {
			$pron =~ s/\`/\'/;
		}

		# print STDERR "pronounce_and_insert\tw $t->{orth}\tp $pron\n";

		if( &MTM::Legacy::isDefault( $pron )) {
			# do nothing
		} else {

			my $conversion = '-';
			if( $MTM::Vars::tts eq 'cereproc' && $pron =~ /[a-zåäö]/i ) {
				if( $MTM::Vars::lang =~ /^e/ ) {
					$conversion = 'tpa2cp_en';
				} else {
					$conversion = 'tpa2cp';
				}

				#print STDERR "SEND\t$pron\t\t$conversion\n";
				### CT $pron = &MTM::Pronunciation::Conversion::convert( $pron, $t->{pos}, $conversion, $word, $decomposed, $debug );
			} elsif( $MTM::Vars::tts eq 'tacotron_1' && $pron =~ /[a-zåäö]/i ) {
				$conversion = 'tpa2tacotron_1';

				#print STDERR "SEND\t$pron\t\t$conversion\n";
				### CT $pron = &MTM::Pronunciation::Conversion::convert( $pron, $t->{pos}, $conversion, $word, $decomposed, $debug );
			}

			# print STDERR "PPP $word\t$pron\t$pos_morph\n";

			# CT 220317 Use pos and morph from dictionary
			if( defined $pos_morph && $pos_morph =~ /^(..) (.+)$/ ) {
				$t->{pos} = $1;
				$t->{morph} = $2;
			}

			$t->{pron} = $pron;

			### CT 231115 Language tagging is done in LanguageDetection
			### $t->{lang} = $pronlang;

			$t->{dec} = $decomposed;

			###$t->{pronmethod} = $pron_method;
			$t->{isInDictionary} = $pron_method;
			#print "isInDictionary $t->{orth}\t$t->{isInDictionary}\n";

#	TODO		if( $t->{id} =~ /\d/ ) {
#				$t->{isInDictionary} = $t->{id};
#			} else {
#				$t->{isInDictionary} = $pron_method;
#			}
		}
	}

	# 241114
	if( $t->{pos} =~ /^RG/ && $t->{exprType} eq '-' ) {
		$t->{exprType} = 'NUMERAL';
	}

	# Convert to Base format
	my $base_pron = convert2base( $t->{pron} );
	if( $base_pron ne 'INVALID' ) {
		$t->{pron} = $base_pron;
	}

	return $self;
}
#**************************************************************#
sub convert2base {

	my $pron = shift;

	# Convert $pron to Base format
	if( $pron ne '-' ) {
		my $base_pron = MTM::Pronunciation::Conversion::TPA->decode( $pron );
		
		# Validate
		my $validated = MTM::Pronunciation::Validation::Base::validate( $base_pron, $base_pron, 'sv' );
		
		if(
			$validated =~ /^VALID/
			||
			$validated =~ /Multiple stress markers/
		) {
			return $base_pron;
		} else {
			return 'INVALID';
		}
	}
}
#**************************************************************#
sub pronounce {

	my $self = shift;
	my $chunk = shift;
	my $word = shift;

	# 240410 Mix of Greek and Latin letters trigger wide character warning.
	# TODO fix this.
	if( $word =~ /(\P{Script=Latin}).*\p{Script=Latin}/ || $word =~ /\p{Script=Latin}.*(\P{Script=Latin})/ ) {
		if( $1 !~ /[$MTM::Vars::delimiter\-]/ ) {
			return ( '-', 'NN', 'swe', 'swe', '-', '-', '-' );
		}
	}
	return $self if $word =~ /<none>/i;		# 20231130

	my $t = $self->{LEGACYDATA};

	return $self if $t->{exp} =~ /<none>/i;		# 20231130

	$word = $t->{orth} if !defined $word;

	# print STDERR "WD $word\n";

	my $posmorph = "$t->{pos} $t->{morph}";
	my $case = 'all';
	my $pron_method;
	my $affixGenerated;
	my $ortlang;
	my $pronlang;
	my $decomposed;
	my $pron;
	my $cartWord;

	# print STDERR "pronounce: $word\t$t->{exprType}\n";

	# 210811 Pronunciation is already done
	if( MTM::Legacy::isDefault( $t->{pron} ) == 0) {
		#print STDERR "RETURN 2 $word\t$t->{pron}\t$t->{pos}\n";
		return ( $t->{pron}, "$t->{pos} $t->{morph}", $t->{lang}, $t->{lang}, $t->{dec}, '-', '0' );
	}
	# print STDERR "pronounce: $word\t$t->{exprType}\n";

	#********************************************************#
	# 0. Domains etc.
	#******************************#
	# English domain
	if (
		$MTM::Vars::lang eq 'en'
		&&
		$t->{orth} ne '@'
		&&
		$t->{exprType} =~ /(?:EMAIL|URL)/i
		&&
		exists( $MTM::Legacy::Lists::en_domain{ $word } )
	) {
		my( $pron, $posmorph, $ortlang, $pronlang ) = split/\t+/, $MTM::Legacy::Lists::en_domain{ $word };
		my $pron_method = 'dict';
		my $decomposed = $word;

		# print STDERR "\nResult from domains etc.: $pron\t$posmorph\t$ortlang\t$pronlang\n";

		return ( $pron, $posmorph, $ortlang, $pronlang, $decomposed, $pron_method, '0' );
	}

	# Swedish and world
	if (
		$MTM::Vars::lang eq 'sv'
		&&
		$t->{exprType} =~ /(?:EMAIL|URL)/i
		&&
		exists( $MTM::Legacy::Lists::sv_domain{ $word } )
	) {
		my( $pron, $posmorph, $ortlang, $pronlang ) = split/\t+/, $MTM::Legacy::Lists::sv_domain{ $word };
		my $pron_method = 'dict';
		my $decomposed = $word;

		# print STDERR "\nResult from dictionaryLookup domains etc.: $pron\t$posmorph\t$ortlang\t$pronlang\n";

		return ( $pron, $posmorph, $ortlang, $pronlang, $decomposed, $pron_method, '0' );
	}		

	### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
	if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $word !~ /^([åäöÅÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)+$/ ) {
	#	utf8::encode( $word );
	}

	# print STDERR "pronounce1: $word\t$t->{pos}\t$t->{exprType}\n";

	#********************************************************#
	# 0. Numerals
	#******************************#
	if (
		##### $mode !~ /preprocess/
		##### && 
		(
			( $t->{pos} =~ /^(RG|RO)$/ && $word =~ /[a-zåäö]/i )		# CT 210908 11:25
			||
			$word =~ /^\d+$/
			||
			$word =~ /^\d+[\d\s]*\d+$/
			||
			(
				$t->{epxrType} = 'CURRENCY'
				&&
				$t->{orth} =~ /^($MTM::Vars::sv_currency_list|$MTM::Vars::en_currency_list)$/		# Needed to get pronunciations for switched orths/exps ($5).
				&&
				$word =~ /^[a-z\| ]$/		# Needed to get pronunciations for switched orths/exps ($5).
			)
		)
		&&
		$word !~ /^the$/i			# the third	220513
	) {
		my $markup = 'cardinal';
		my $context = 'DEFAULT';

		# print STDERR "\n\nPronunciation orth $t->{orth}\tpos $t->{pos}\n\n";

		#my $letters = &MTM::Expansion::NumeralExpansion::expand_numeral( $word, $t->{exprType}, $t->{pos}, $t->{morph} );
		my $pron = &MTM::Pronunciation::NumeralPronunciation::pronounce( $word );


		# print STDERR "\nResult from dictionaryLookup numerals: $word\t$pron\n";

		return ( $pron, 'RG NOM', 'swe', 'swe', $word, 'autonumeral', '-' ) if $pron =~ /[\"\']/;
	}

	# print STDERR "pronounce2: $word\t$t->{exprType}\n";
	#********************************************************#
	# 1. Spell
	#******************************#
	# CT 200527
	if(
		$t->{exprType} =~ /INITIAL/
		||
		$word eq 'a' && $t->{exprType} =~ /INTERVAL/
	) {
		my $pron = &MTM::Pronunciation::Pronunciation::Spell( $word );
		# print STDERR "pronounce3: $word\t$t->{exprType}\t$pron\n"; exit;
		return ( $pron, 'NN', 'swe', 'swe', '-', 'spell', '-' );
	}
	#********************************************************#
	# 1. Acronym
	#******************************#
	# CT 210810
	if(
		$t->{exprType} =~ /ACRONYM/
	) {
		my $pron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $word );
		# print STDERR "pronounce acronym: $word\t$t->{exprType}\t$pron\t$t->{pos}\n";

		# print STDERR "P $word $pron\t$t->{pos}\n";

		return ( $pron, 'ACR', 'swe', 'swe', '-', '-', '-' );
	}

	#********************************************************#
	# 1. Dictionary lookup
	#******************************#
	my ( $dictPron ) = &MTM::Pronunciation::Dictionary::dictionaryLookup( $word, $case, $posmorph, $t->{lang} );
	my @dictPron = split/\t/, $dictPron;

	# print STDERR "\nResult from dictionaryLookup: $word\t@dictPron\n";

	# Some pronunciation was returned
	if ( $dictPron[0] =~ /../ ) {
		my $dictPron = join"\t", @dictPron;
		my @dP = split/<SPLIT>/, $dictPron;

		# Choose the first entry
		my ( $pron, $posmorph, $ortlang, $pronlang, $decomposed, $id ) = split/\t/, $dP[0];

		my @testdp = split/\t/, $dP[0];
		my $n = $#testdp;
		if( $n < 5 ) {
			$id = '-';
			$decomposed = '-';
		}

		# print STDERR "\nResult from dictionaryLookup: $word\t@dictPron\n";

		my @dp0 = split/\t/, $dP[0];

		if( $#dp0 < 1 ) {

			# 210810 
			if( $posmorph !~ /[A-Z]/ ) {
				$posmorph = 'NN';
			}

			#$ortlang = 'swe';
			#$pronlang = 'swe';
			$decomposed = '-';
			$id = '-';
		}

		$pron_method = "dict|$id";

		# print STDERR "Lookup: $pron\t$ortlang\t$posmorph\n";
		return ( $pron, $posmorph, $ortlang, $pronlang, $decomposed, $pron_method, $id );

	} elsif ( $word =~ /^[A-ZÅÄÖa-zåäö]$/ ) {
		my $pron = MTM::Pronunciation::Pronunciation::Spell( $word );
		# print STDERR "\nspell: $word	$pron\n";
		return ( $pron, 'NN', 'swe', 'swe', $word, 'spell', '-' );

	# Lookup without hyphens
	} elsif ( $word =~ /-/ ) {
		my $cleanWord = $word;
		$cleanWord =~ s/[-\"]//g;


		@dictPron = &MTM::Pronunciation::Dictionary::dictionaryLookup( $cleanWord, $case, $posmorph, $t->{lang} );

		# print STDERR "\nTrying without hyphens: $cleanWord	@dictPron\n";

		# Some pronunciation was returned
		if ( $dictPron[0] =~ /../ ) {

			my $dictPron = join"\t", @dictPron;
			my @dP = split/<SPLIT>/, $dictPron;


			# Choose the first entry (PoS match is done in &dictionaryLookup).
			my ( $pron, $posmorph, $ortlang, $pronlang, $decomposed, $id ) = split/\t/, $dP[0];

			#if ( $debug ) {
			#	print DEBUG "\nResult from dictionaryLookup: @dictPron\n";
			#}

			$ortlang =~ s/^\s*$/swe/;

			$pron_method = 'dict';
			#print "Lookup without hyphens: $pron\t$ortlang\n";
			return ( $pron, $posmorph, $ortlang, $pronlang, $decomposed, $pron_method, $id );
		}


	}

	#********************************************************#
	# 2. Affix check
	#******************************#
	# Minimum number of tokens of the word.
	my $minTokens = 3;

	my $affixFlag = 0;
	my $affixGenereated = 'void';

	# 240513
	if( $t->{lang} !~ /en/ ) {
		( $affixGenerated, $affixFlag, $posmorph, $ortlang, $pronlang, $decomposed ) = &MTM::Pronunciation::Affixation::affixation( $word, $minTokens, $debug );

		# print STDERR "\ncreatePronuncitions:\tResult from affixation: $word\t$affixGenerated\tFlag: $affixFlag\n";

		# Insert decomposition	170124
		$t->{dec} = $decomposed;
		if ( $affixFlag eq '1' ) {
			$pron_method = 'affix';
			#print "Affix: $pron\t$ortlang\n";
			return ( $affixGenerated, $posmorph, $ortlang, $pronlang, $decomposed, $pron_method, '-' );
		}
	}

	# print STDERR "After Affix: $word\n";

	#********************************************************#
	# 3. Compound check
	#******************************#
	my $compound_pron;
	my $compound_generated;
	#my $ortlang;
	#my $pronlang;
	#my $posmorph;
	( $compound_pron, $posmorph, $ortlang, $pronlang, $compound_generated, $pron_method ) = &compound_check( $word, $debug );
	if( $compound_pron ne 'void' ) {
		return ( $compound_pron, $posmorph, $ortlang, $pronlang, $compound_generated, $pron_method, '-' );
	}

	#********************************************************#
	# 4. Acronyms
	#******************************#
	# Check pronunciability
	my $tmpWord = $word;
	$tmpWord =~ s/\'//g;
	my $pronunciability = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability( $tmpWord, $debug );

	#print STDERR "Pronunciation::pronunce\t$word\t$pronunciability\n";

	if ( $pronunciability == 0 ) {
		my $acronymPron = &MTM::Pronunciation::AcronymPronunciation::pronounce( $word, $debug );
		return ( $acronymPron, 'ACR', 'swe', 'swe', $word, 'autoacronym', '-' );
	}

	#********************************************************#
	# 4. Cart tree
	#my ( $cartGenereated, $cartScore ) = &cartification( $word );

	#********************************************************#
	# 200123 Ugly fix to avoid error in cart tree for wordLookup.pl

	if( $t->{lang} =~ /^en/ ) {
		my $err;
		( $pron, $err ) = &MTM::Pronunciation::AutopronEspeak::run_espeak( $word );
	} else {
		my $domain = 'swe';
		if( $MTM::Vars::runmode ne 'wordLookup' ) {
			$pron = &MTM::Pronunciation::Autopron::cartAndStress( $word, $domain );
		}
	}

	#if ( $debug ) {
	#	print DEBUG "Cart result\t$word\t$domain\t$pron\n";
	#}

	$pron = &MTM::Pronunciation::Syllabify::syllabify( $pron );

	# Cheating!
	if ( $word =~ /^[A-ZÅÄÖ]/ ) {
		if ( $word =~ /s$/ ) {
			$posmorph = 'PM GEN';
		} else {
			$posmorph = 'PM NOM';
		}
	} else {
		$posmorph = 'NN';
	}
	$ortlang = 'swe';
	$pronlang = 'swe';

	$pron_method = 'cart';

	# print STDERR "Pronunciation::pronounce\t$word\t$t->{orth}\t$t->{pos}\t$t->{exprType}\t$pron\n";

	#print OUTPUT "\n\nCart: $word\t$pron\t$ortlang\n\n";
	#print "Cart: $pron\t$ortlang\n";
	
	return ( $pron, $posmorph, $ortlang, $pronlang, $word, $pron_method, '-' );


#	my ( $word, $case, $posmorph, $mode, $index, $debug ) = @_;
#
#	$word =~ s/\’//;
#
#	if ( $debug ) {
#		print DEBUG "\n\n************************************************************\nInput createPronunciation\n\t$word\t$case\t$posmorph\t$mode\t$debug\n";
#	}
#
#	my $pron_method = 'void';
#
#	if ( $word eq '__paragraf_insertion' ) {
#		return ( "p a \$ r a \$ g r \'a2: f", 'NN UTR SIN IND NOM', 'swe', 'swe', '-', 'dict', 0 );
#	}
#
#	if ( $word eq '__kapitel_insertion' ) {
#		return ( "k a \$ p \'i \$ t ë l", 'NN NEU SIN IND NOM', 'swe', 'swe', '-', 'dict', 0 );
#	}
#
#	if ( $word eq '__stycke_insertion' ) {
#		return ( "s t \"y \$ k \`ë", 'NN NEU SIN IND NOM', 'swe', 'swe', '-', 'dict', 0 );
#	}
#
#	if ( $word =~ /^__mute_(\§\§|\§|kap\.?|st\.?)/ ) {
#		return ( '', '-', '-', '-', '-', '-', 0 );
#	}
}
#**************************************************************#
# spell.pl
# 
# Returns a pronunciation to a letter.
#
# test exists		210817
#**************************************************************#

# CALL: my $pron = $data_obj->lookup_letter_pron($letter);		# Uses target language
# CALL: my $pron = $data_obj->lookup_letter_pron($letter, $lang);	# Uses language of choice

sub Spell {	# return: var/fail
	# my $self = shift;
	my $letter = shift;
	my $lc_letter = MTM::Case::makeLowercase( $letter );

	# if exists( $self->pronlists->alphabet{ $letter }  { .. }

	# JE
	# Acessmetod (på dataobjektet - som då måste kontrueras som objekt
	# sub lookup_letter_pron {
	#
	# 	if exists( $data_obj->pronlists->alphabet{ $letter }  { .. }
	# 	....
	#      return $pron;
	# }

	# English
	if( $MTM::Vars::lang eq 'en' ) {
		if( exists( $MTM::Legacy::Lists::en_alphabet{ $lc_letter } )) {
			return $MTM::Legacy::Lists::en_alphabet{ $lc_letter };
		} else {
			return 0;
		}

	# Swedish and world
	} else {
		if( exists( $MTM::Legacy::Lists::sv_alphabet{ $lc_letter } )) {
			return $MTM::Legacy::Lists::sv_alphabet{ $lc_letter };
		} else {
			return 0;
		}
	}
}
#**************************************************************#
# spell_all
# 
# Returns a pronunciation to a string
#
# 
#**************************************************************#
sub spell_all {
	my $orth = shift;

	$orth =~ s/(\d|$MTM::Vars::characters|$MTM::Legacy::Lists::sv_special_character_list|$MTM::Legacy::Lists::en_special_character_list)/<SPLIT>$1<SPLIT>/g;
	my @orth = split/<SPLIT>/, $orth;
	$orth =~ s/(<SPLIT>)+/<SPLIT>/g;
	$orth =~ s/^<SPLIT>//;
	$orth =~ s/<SPLIT>$//;

	my @pron = ();

	#print STDERR "sv $orth $MTM::Legacy::Lists::sv_special_character_list\n";
	foreach my $o ( @orth ) {

		my $lc_letter = MTM::Case::makeLowercase( $o );
		if ( $o =~ /($MTM::Legacy::Lists::sv_special_character_list)/ ) {
			my( $exp, $pron ) = split/\t+/, $MTM::Legacy::Lists::sv_special_character{ $o };
			push @pron, $pron;
			#print STDERR "PART	$o	$pron\n";
		} elsif( exists( $MTM::Legacy::Lists::sv_alphabet{ $lc_letter } )) {
			my $pron = $MTM::Legacy::Lists::sv_alphabet{ $lc_letter };
			push @pron, $pron;
			#print STDERR "PART	$o	$pron\n";
		} elsif ( exists( $MTM::Vars::sv_num_0_9{ $o } )) {
			my $num = $MTM::Vars::sv_num_0_9{ $o };
			my $pron = &MTM::Pronunciation::NumeralPronunciation::pronounce( $num, '-', 'RG', 'NOM'  );
			push @pron, $pron;
			#print STDERR "PART	$o	$pron\n";
		} else {
			#print STDERR "NO $o\n";
		}
	}

	my $ret = join' | ', @pron;
#	print STDERR "spell_all	$orth	$ret\n";
	return $ret;

}
#**************************************************#
sub compound_check {

	my( $word, $debug ) = @_;

	my ( $compound_generated, $metadata ) = &MTM::Pronunciation::Decomposition::decompose( $word, $debug );

	my $posmorph;
	my $ortlang;
	my $pronlang;
	my $pron_method;

	# print STDERR "\n\nCompound check	$word\t$compound_generated\n"; #\t$metadata\n";

	if( $MTM::Vars::tts eq 'mtm-david' ) {
		if( $compound_generated !~ /\+/ ) {
			$compound_generated =~ s/(men|det|jag|hur|ja|den|och|ska|du|han|hon|då|min|kanske|alltså|nej|så|eller|vad|vadå|inte)$/\+$1/;
			$compound_generated =~ s/^(nej|okej)$/$1\+/;
			$compound_generated =~ s/(alltså|liksom)$/\+$1\+/;

			$compound_generated =~ s/^\++//;
			$compound_generated =~ s/\++$//;
			$compound_generated =~ s/\++/\+/g;
		}
	}

	if ( $compound_generated =~ /\+/ ) {

		my @metadata = split/\t/, $metadata;
		if( $#metadata == 2 ) {
			$posmorph = $metadata[0];
			$ortlang = $metadata[1];
			$pronlang = $metadata[2];
		} else{
			$posmorph = '-';
			$ortlang = '-';
			$pronlang = '-';
		}
		# print STDERR "\nC $compound_generated\tP $posmorph\tO $ortlang\tP $pronlang\n";

		$pron_method = 'compound';

		my $tmp_compoundGenerated = $compound_generated;
		$tmp_compoundGenerated =~ s/\"//g;

		my $compound_pron = &MTM::Pronunciation::Compound::createCompoundPronunciation( $tmp_compoundGenerated );
		#print STDERR "II $compound_pron\n";

		# Dummy posmorph
		if ( $posmorph eq '-' ) {
			# Cheating!
			if ( $word =~ /^[A-ZÅÄÖ]/ ) {
				if ( $word =~ /s$/ ) {
					$posmorph = 'PM GEN';
				} else {
					$posmorph = 'PM NOM';
				}
			} else {
				# 210810 
				if( $posmorph !~ /[A-Z]/ ) {
					$posmorph = 'NN';
				}

			}
			$ortlang = 'swe';
			$pronlang = 'swe';
		}

		# print STDERR "\n\nCompound: $word\t$compound_pron\t$ortlang\n\n";
		return ( $compound_pron, $posmorph, $ortlang, $pronlang, $compound_generated, $pron_method );
	}

	return 'void';
}
#**************************************************#
1;
