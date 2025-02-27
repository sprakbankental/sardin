package MTM::TTSDocument::SplitSentence;

use strict;
use warnings;
use utf8;

# We load this dependency here, so that e.g. tests
# that may load the module standalone can run.
use MTM::Legacy;


#***********************************************************************#
# SplitSentence.pm
#
# Splits text into sentences.
#
# Requires:	abbreviation list variabel
#
#***********************************************************************#
sub splitSentence {

	my $string = shift;

	# Mark abbreviations with <ABBR>...<eABBR>
	$string = &MTM::Legacy::mark_abbreviations( $string );

	#***********************************************************************#
	# Split at abbreviation markup
	my @string = split/(<ABBR>[^<]+<eABBR>)/,$string;

	foreach my $s ( @string ) {

		if ( $s !~ /<ABBR>/ ) {

			#*********************************#
			# 1. Split at major delimiters
			#*********************************#
			$s =~ s/([$MTM::Vars::majorDelimiter]+ *)/$1<SENT_SPLIT>/g;

			#*********************************#
			# 2. Fix overgenerations
			#*********************************#

			#*********************************#
			# Name initials (twice to catch longer sequences)
			$s =~ s/\.<SENT_SPLIT>([A-ZÅÄÖØÆ](\.| ))/\.$1/g;				# H.<SENT_SPLIT>C	-->	H.C
			$s =~ s/\.<SENT_SPLIT>([A-ZÅÄÖØÆ](\.| ))/\.$1/g;				# H.<SENT_SPLIT>C	-->	H.C.P

			$s =~ s/(\b[A-ZÅÄÖØÆ]\. *)<SENT_SPLIT>([A-ZÅÄÖØÆ](\.| |$))/$1$2/g;	# H.<SENT_SPLIT> C.<SENT_SPLIT> P	-->	H. C
			$s =~ s/(\b[A-ZÅÄÖØÆ]\. *)<SENT_SPLIT>([A-ZÅÄÖØÆ](\.| |$))/$1$2/g;		# H.<SENT_SPLIT> C.<SENT_SPLIT> P	-->	H. C. P

			# M. Karlsson		Andersen, R. och Karlsson, M.	P. som favorit.	Lärde känna H. 1968 i Dublin.
			$s =~ s/((?:[$MTM::Vars::delimiter]|^| )[A-ZÅÄÖØÆ]\. *)<SENT_SPLIT>( *[A-ZÅÄÖØÆa-zåäöæø][a-zåäöæø]+|\d\d\d\d\b| *[\(\&])/$1$2/g;

			$s = &MTM::Legacy::clean_multiples('<SENT_SPLIT>', $s);

			#*********************************#
			# Abbreviations

			# f. 1975
			$s =~ s/\b(f\. *)<SENT_SPLIT>(\d\d\d\d)/$1$2/g;

			#*********************************#
			# Misc removals

			#Before <noteref>.
			$s =~ s/<SENT_SPLIT><noteref/<noteref/g;

			# Betweeen [.] and one single token before eos.
			$s =~ s/\.<SENT_SPLIT>(.)$/\.$1/;

			# Between . and digit/comma
			$s =~ s/(\.)<SENT_SPLIT>(\d|\,)/$1$2/g;

			# Between [.?!] and [)"]
			$s =~ s/([\.\?\!])<SENT_SPLIT>([\)\"])/$1$2<SENT_SPLIT>/g;

			# Between [.?!)] and [.?!]
			$s =~ s/([\.\?\!\)])<SENT_SPLIT>([\.\?\!]+)/$1$2/g;

			# Digits/letters LC + RC
			$s =~ s/([\da-zåäöA-ZÅÄÖøæØÆ][\.\,])<SENT_SPLIT>([\da-zåäöA-ZÅÄÖøæØÆ])/$1$2/g;

			# Between -... and letters		-...bakom flötet.
			$s =~ s/(-\.\.\. *)<SENT_SPLIT>([\w])/$1$2/g;

			# Between " and lowercase.
			$s =~ s/(\")<SENT_SPLIT>(\)? +)([a-zåäö])/$1$2$3/g;

			# Between [!?]) and lowercase
			$s =~ s/([\!\?])<SENT_SPLIT>( ?[a-zåäö])/$1$2/g;

			# Between ! or ? and lowercase
			$s =~ s/([\!\?])<SENT_SPLIT>( [a-zåäö])/$1$2/g;
			$s =~ s/([\!\?\£] +)<SENT_SPLIT>([a-zåäö])/$1$2/g;

			# Between " and .
			$s =~ s/(\")<SENT_SPLIT>(\.)/$1$2/g;

			# Between ["?] + lowercase		Varför här? frågade Ingvar.
			$s =~ s/([\"\?] )<SENT_SPLIT>([a-zåäö])/$1$2/g;

			# H&M
			$s =~ s/\&amp\;/\&/g;
			$s =~ s/([A-Z])(?:<SENT_SPLIT>)?\&<SENT_SPLIT>([A-Z])(<SENT_SPLIT>|\s|$|\b)/$1\&$2$3/g;
		}
	}

	# Join string
	$string = join"",@string;

	# Remove abbreviation markup
	$string =~ s/<e?ABBR>//g;

	return $string;
}
#***********************************************************************#
1;
