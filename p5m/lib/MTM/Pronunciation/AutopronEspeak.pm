﻿package MTM::Pronunciation::AutopronEspeak;

#**************************************************************#
# EspeakAutopron
#
# Calling espeak for automatic pronunciation generation
#
# Return: pronunciation
#
# (c) Swedish Agency for Accessible Media, MTM 2023
#**************************************************************#
# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings	qw< FATAL utf8 >;
use open		qw< :std :utf8 >;	 # Should perhaps be :encoding(utf-8)?
use charnames	qw< :full :short >;	# autoenables in v5.16 and above
use feature	 qw< unicode_strings >;
no feature	qw< indirect >;
use feature	 qw< signatures >;
no warnings	 qw< experimental::signatures >;
# END SBTal boilerplate

use File::Which;
use String::ShellQuote;

use MTM::Validation::Pronunciation;

# The external command line call to invoke espeak
my $espeak_cmd="espeak-ng";

#*********************************************************#
# Create both phonemes and stress
#*********************************************************#

# Returns two values: a transcription and a potential error
# message. If no error, the second value is undef
sub run_espeak {

#	# NL TODO Is this OK for checking length of @_? length(@_) doesn't work.
#	if (@_ != 1) {
#		# NL TODO How to report errorrs? 
#		print STDERR "FATAL: run_espeak exepects a single argument, a word\n";
#		return '', "FATAL: run_espeak exepects a single argument, a word"; # ??
#	}

	my $orth = shift;

	# NL TODO Hardwired $lang for now
	my $lang = 'en-uk';

	$orth =~ s/^\s+//;
	$orth =~ s/\s+$//;

	return '-' if $orth eq '';

#	if ($orth eq '' ) {
#	# NL TODO 
#		print STDERR "run_espeak called with empty word (string) as first arg\n";
#		return '', "run_espeak called with empty word (string) as first arg";
#	}

	( my $espeakPron, my $err ) = espeak($lang, $orth);

	if (defined $err) {
		if (!espeakExists()) {
			# NL TODO How to report fatal errors?
			print STDERR "FATAL: the 'espeak-ng' command was not found! Consider installing it.\n";
			return $espeakPron, "FATAL: $err : the 'espeak-ng' command was not found! Consider installing it.";
		}
		# NL TODO How to report fatal errors?
		#die "FATAL: $err";
		#return $espeakPron, $err;
		return '-';	# CT 240419
	};


	my $tpaPron;
	#if ($lang eq 'en-uk') {
		# NL TODO Currently lang is always en-uk
		$tpaPron = espeakEnUk2TPA($espeakPron);
		#print "espeakPron $orth	$espeakPron	$tpaPron\n";
	#}

	my ( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( $orth, $tpaPron, 'swe', 'tpa', '0', '-', '-', 1 );
	my @pronWarnings = @$pronWarnings;
	#my @sanityWarnings = @$sanityWarnings;
	#my @help = @$help;
	#my @example = @$example;

	#print "pw @pronWarnings\n";

	if( $#pronWarnings < 0 ) {
		return $tpaPron;
	} else {
		return '-';
	}

	# NL TODO Doesn't work: haven't figured out how to call
	# MTM::Validation::Pronunciation::validate properly
	# my ($valRes) = validateTPATrans($orth, $tpaPron);
	# if ($valRes ne '') {
	# 	print STDERR "run_espeak: ERROR invalid TPA transcription: " . $valRes . "\n";
	# }
}
#*********************************************************#
# espeakExists checks if the espeak software is installed. Returns 1
# if there is an external command corresponding to $espeak_cmd, 0
# otherwise.
sub espeakExists{

	if (which($espeak_cmd)) {
		return 1;
	}
	return 0;
}
#*************************************************************************************#
# espeak performs a call to external command espeak-ng, and it takes
# to args: language code (en-uk, en-us, etc) and the text to
# phonetise. espeak returns a tuple: the result and an error, which is
# undef when no error has ocurred.
sub espeak{ 
	(my $lang, my $text) = @_;

	$text = shell_quote $text;

	my $cmd = "$espeak_cmd -q -v $lang -x $text" ;

	my $res = `$cmd`;


#	my $res = eval{
#	`$cmd` || die "Can't exec $cmd";
#	};
#	if ($@) { # NL TODO is this a reasonable way to handle eval failures? 
#		return ($res, $@);
#	};

	chomp($res);

	return ($res, undef);
}
#*************************************************************************************#
# TODO regexp and hash map should be synced: generate $enUkRE from %enUK2TTPAMap
#my $enUkRE = qr/^(aI3|aI@|3r-|i@3|aU@|r-|e@|3:|e#|U@|i@|aU|OI|a#|i:|eI|I2|oU|@2|aI|A@|O@|u:|A:|O:|aa|@5|l|0|p|h|n|I| |d|V|@|O|E|z|U|,|3|k|'|a|t|i)/;
my %enUK2TPAMap = (
	'@' => 'ë',
	'0' => 'å', # ? ë ? Cf helicopter /h'ElIk,0pt3/
	'@2' => 'ë', # ? depends on context?
	'3' => 'ë r0',
	'3:' => 'ö3:', # ? depends on context? Linking 'r'?
	'@5' => '@', # ? depends on context?
	'a' => 'ä3',
	'a#' => 'a', # ipa ɐ or schwa ?
	'A:' => 'a2:',
	# TODO:
	'A@' => 'a2: r0', # Could be just /a2:/ ? 
	'aa' => 'a2:',
	'aI' => 'ai',
	# TODO check if this makes sense:
	#'aI@' => 'ai ë', # ? depends on context? Linking 'r' /ai ë r0/ ?
	'aI3' => 'ai r0', # ? depends on context? add /r0/ ?
	'aU' => 'au',
	# TODO check if this makes sense:
	#'aU@' => 'au', # ? depends on context? Linking 'r'?
	'e#' => 'i', # ?
	'e@' => 'eë',
	'E' => 'e', # ? /ë/ ?
	'eI' => 'ei',
	'i' => 'i',
	'i:' => 'i2:',
	'i@' => 'ië',
	'I' => 'i',
	'I2' => 'i',
	'i@3' => 'ië r0',
	'3r-' => 'ë r3', # Linking -r
	'O' => 'å',
	'O:' => 'å2:',
	'O@' => 'öw', # ?
	'OI' => 'å j', # ?
	'oU' => 'å o', # ?
	#'u:' => 'o2:',
	'u:' => 'u4:',
	'U' => 'o',
	'U@' => 'uë',
	'V' => 'a',


	'b' => 'b',
	'd' => 'd',
	'D' => 'dh',
	'f' => 'f',
	'g' => 'g',
	'h' => 'h',
	'j' => 'j',
	'k' => 'k',
	'l' => 'l',
	'm' => 'm',
	'n' => 'n',
	'N' => 'ng',
	'p' => 'p',
	'r-' => 'r3',
	'r' => 'r3',
	's' => 's',
	't' => 't',
	'v' => 'v',
	'T' => 'th',
	'tS' => 'tj3',

	'w' => 'w',

	'S' => 'rs',

	'z' => 's',
	'Z' => 'rs', # ?? 'dZ',

	"'" => "'",
	',' => '`', # ? TODO CHECK IF CORRECT
	' ' => '|',

); 


#*************************************************************************************#
# NL TODO Build $enUkRE only once. This is syncing with keys of
# %enUK2TPAMap, so that two different lists need to be manually
# updated.
sub buildEnUKRE {
	my $re = join('|', sort { length $b <=> length $a } keys %enUK2TPAMap);
	return "^($re)"; 
};

my $enUkRE0 = buildEnUKRE();
my $enUkRE = qr/$enUkRE0/;

# NL TODO Validate TPA output after conversion

#*************************************************************************************#
sub espeakEnUk2TPA{
	my $pron = shift;

	my ($syms0, $unknown0) = parseEnUKPron($pron);

	# NL TODO How to report errors?
	for my $u (@$unknown0) {
		print STDERR "espeakEnUk2TPA: unknown symbol '$u' in transcription /$pron/\n";
	}

	my @noMapping;
	my @res;

	for my $s (@$syms0) {
		if (exists $enUK2TPAMap{$s}) {
			push(@res, $enUK2TPAMap{$s})
		} else {
			push(@noMapping, $s);
		}
	}

	# NL TODO How to report errors?
	for my $no (@noMapping) {
		print STDERR "espeakEnUk2TPA: no mapping to TPA for symbol '$no' in transcription /$pron/\n";
	}

	my $res = join(' ', @res);

	# TPA has stress attached to vowel without space
	$res =~ s/' /'/g;
	# CT No secondary stress in TPA English 
	$res =~ s/` ?//g;

	$res = MTM::Pronunciation::Syllabify::syllabify($res);

	return $res;
}

#*************************************************************************************#
# parseEnUKTrans splits output from espeak-ng -q -x -v en-uk into phonemes
sub parseEnUKPron{
	my $pron = shift;


	my @res;
	my @unk;

	my $tr = $pron;

	my $match;
	while ($tr ne '') {
		$match = '';
		if ($tr =~ $enUkRE) {
			$match = $1;
		}

		if ($match ne '') {
			push(@res, $match);
			$tr = substr($tr, length($match));
		} else {
			push(@unk, substr($tr, 0, 1));
			$tr = substr($tr, 1);
		}
		$match = '';
	}

	return \@res, \@unk;
}
#*************************************************************************************#
# NL TODO Doesn't work. Writing a local Eng. TPA validation makes more sense?
sub validateTPAPron{
	my ($orth, $pron) = @_;

	$orth =~ s/^\s+//;
	$orth =~ s/\s+$//;

	$pron =~ s/^\s+//;
	$pron =~ s/\s+$//;

	# Validate TPA transcription
	# NL TODO Fail to make this work:
	my ( $pronWarnings, $sanityWarnings, $help, $example ) = &MTM::Validation::Pronunciation::validate( $orth, $pron, 'swe', 'tpa', 1, 'NN', $orth, 1 );

	my @res = ();

	for my $w (@$pronWarnings) {
		push(@res, $w);
	}

	for my $w (@$sanityWarnings) {
		push(@res, $w);
	}

	if (@res == 0) {
		return '';
	} else { 
		return join(' : ', @res);
	}
}
#*************************************************************************************#

1;
