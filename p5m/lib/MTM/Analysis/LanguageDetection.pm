package MTM::Analysis::LanguageDetection;

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

#**************************************************************#
# LanguageDetection
#
# Language	sv_se
#
# Rules for Swedish/English
# First part, is followed by LanguageDetection2.pm
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#

#***************************************************************#
# LanguageDetection
#***************************************************************#
sub markup {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	# 1. Assign each word Swedish, English or both
	&assign_possible_lang_tags( $self );
	#print "$t->{orth}\t$t->{lang}\n";

	#***********************************************************#
	# The following is done at last token in sentence only.
	# 2. Tag sentence if all words are either English or Swedish
	my( $all_english, $some_english, $last_token ) = &check_all_english_only( $self, $chunk );

	return $self;
}
#***************************************************************#
# check_all_english_only
# 	checks if all words are possibly english
# 	Only if we're at the last word of the sentence
#	and all previous words have been langtagged
#***************************************************************#
sub check_all_english_only {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	my $all_english = 1;
	my $some_english = 0;

	my $last_token = 0;
	my @sentence = ();
	push @sentence, $t->{orth};

	# 1. Check if end of sentence
	my $rc_flag = 1;
	my $rc1base = $chunk->peek(1) or $rc_flag = 0;

	$all_english = 0 if $t->{lang} eq 'swe';
	$some_english = 0;

	return( $all_english, $some_english, $last_token ) if $rc_flag == 1;
	#print "This is the last word: $t->{orth}\n";
	$last_token = 1;
	my $en_seen = 0;
	my $sv_seen = 0;

	# Walk through rest of the sentence
	my $index = 0;

	my $lcbase = $chunk->peek($index) or return( $all_english, $some_english, $last_token );
	my $lc = $lcbase->{LEGACYDATA};
	while( $lc->{orth} ) {
		$sv_seen = 1 if $lc->{lang} =~ /(swe|sv_en)/;
		$en_seen = 1 if $lc->{lang} =~ /(eng|sv_en)/;
		$all_english = 0 if $sv_seen == 1;
		$some_english = 1 if $sv_seen == 1 && $en_seen == 1;
		# print "o $lc->{orth}\t$lc->{lang}\tALL $all_english\tSOME $some_english\n";
		$index--;
		my $lcbase = $chunk->peek($index) or last; #return( $all_english, $some_english, $last_token );
		$lc = $lcbase->{LEGACYDATA};
		push @sentence, $lc->{orth};
	}

	@sentence = reverse( @sentence );


	#print "\n\nSENTENCE @sentence\tALL $all_english	SOME $some_english\n\n";

	# Set lang 'eng' if no token is possibly English
	# Set lang 'eng' if all tokens are possibly English and no token is possibly Swedish.
	my $lang_to_assign = '-';

	if( $some_english == 0 && $all_english == 0 ) {
		$lang_to_assign = 'swe';
	} elsif ( $all_english == 1 ) {
		$lang_to_assign = 'eng';
	}
	# print "\n\nSENTENCE @sentence\tALL $all_english	SOME $some_english	lang_to_assign $lang_to_assign\n\n";
	if( $lang_to_assign ne '-' ) {
		# Walk through rest of the sentence
		my $index = 0;
		my $lcbase = $chunk->peek($index) or return( $all_english, $some_english, $last_token );
		my $lc = $lcbase->{LEGACYDATA};
		while( $lc->{orth} ) {
			$lc->{lang} = $lang_to_assign;
			$index--;
			my $lcbase = $chunk->peek($index) or return( $all_english, $some_english, $last_token );
			$lc = $lcbase->{LEGACYDATA};
			push @sentence, $lc->{orth};
		}
	}

	return( $all_english, $some_english, $last_token );
}
#***************************************************************#
# assign_possible_lang_tags
# 	tag the words with language information
# 	swe = Swedish only
# 	eng = english only
# 	sv_en = Swedish or english
# 	unknown = unknown
#***************************************************************#
sub assign_possible_lang_tags {

	my $self = shift;
	my $chunk = shift;
	my $t = $self->{LEGACYDATA};

	$t->{lang} = '-';

	my $orth = $t->{orth};

	# 240410 Mix of Greek and Latin letters trigger wide character warning.
	# TODO fix this.
	if( $orth =~ /(\P{Script=Latin}).*\p{Script=Latin}/ || $orth =~ /\p{Script=Latin}.*(\P{Script=Latin})/ ) {
		if( $1 !~ /[$MTM::Vars::delimiter]/ ) {
			return ( '-', 'NN', 'swe', 'swe', '-', '-', '-' );
		}
	}


	# SSML is English
	if ( $t->{ssml} =~ /<ssml:say-as/ ) {
		if( $t->{ssml} =~ /say-as ssml:type\=\"english\"/ ) {
			$t->{lang} = 'eng';
		} else {
			$t->{lang} = 'swe';
		}
		return $self;
	}

	# Ampersand
	if ( $t->{orth} =~ /^(\&|\&amp\;)$/ ) {
		$t->{lang} = 'sv_en';
		return $self;
	}

	# Dictionary lookup
	my $possibly_en = 0;
	my $possibly_sv = 0;

	#my $saved_vars_lang = $MTM::Vars::lang;

	# Set general language to English to lookup in English dictionary first
	# If the result is English
	#$MTM::Vars::lang = 'eng';
	my $lookup = &MTM::Pronunciation::Dictionary::dictionaryLookup( $t->{orth}, 'all', 'NN', 'eng' );
	$possibly_en = 1 if $lookup =~ /eng	eng/;
	# print "\nen lookup $lookup\nen	$possibly_en\n";

	#$MTM::Vars::lang = 'swe';
	$lookup = &MTM::Pronunciation::Dictionary::dictionaryLookup( $t->{orth}, 'all', 'NN', 'swe' );
	$possibly_sv = 1 if $lookup =~ /swe	swe/;
	# print "swe lookup $lookup\nsv	$possibly_sv\n";

	$t->{lang} = 'sv_en' if $t->{orth} =~ /[a-zåäöA-ZÅÄÖ\d]/i && $possibly_sv == 0 && $possibly_en == 0;	# unknown word
	$t->{lang} = 'sv_en' if $possibly_sv == 1 && $possibly_en == 1;
	$t->{lang} = 'swe' if $possibly_sv == 1 && $possibly_en == 0;
	$t->{lang} = 'eng' if $possibly_sv == 0 && $possibly_en == 1;

	#$MTM::Vars::lang = $saved_vars_lang;

	return $self;
}
#***************************************************************#
1;
