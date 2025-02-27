package MTM::POSTagger;

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
# POSTagger
#
# Language	sv_se
#
##### NB! Temporary tagger solution, to be replaced.
#
# Return: markup
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#

use DB_File;

# Load all Legacy at once
use MTM::Legacy;
#use MTM::Case;
#use MTM::Legacy::Lists;
#use MTM::Vars;

#use warnings;
#use warnings qw( FATAL utf8 );
#use open qw( :encoding(UTF-8) :std );
#use charnames qw( :full );

#use Encode 'from_to';

our $user;
our $main_path;

my $lang = "swe";

# Path to Build directory
my $list_path = 'data/legacy/TaggerDB';
my $readPath = 'data/legacy/TaggerLists';

### LOG PATH (tmp)	TODO: create log object
my $logPath = 'logs';

our %saved_pos_analysis;
our %missing_wds;

our %x = ();
# All possible tags for unknown words (preprositions, pronouns, particles, etc. excluded).	CT 100408
our @AllPossTags = qw(RG0S RGCS RGPS RGSS AQC00G0S AQC00N0S AQPMSGDS AQPMSNDS AQPNSGIS AQPNSNIS AQPNSN0S AQPUSGIS AQPUSNIS AQPUSN0S AQP0PNIS AQP0PG0S AQP0PN0S AQP0SGDS AQP0SNDS AQP00NIS AQP00N0S AQSMSGDS AQSMSNDS AQS0PNDS AQS0PNIS AQS00NDS AQS00NIS NCNPG@DS NCNPN@DS NCNPG@IS NCNPN@IS NCNSG@DS NCNSN@DS NCNSG@IS NCNSN@IS NCUPG@DS NCUPN@DS NCUPG@IS NCUPN@IS NCUSG@DS NCUSN@DS NCUSG@IS NCUSN@IS AF0MSGDS AF0MSNDS AF0NSNIS AF0USGIS AF0USNIS AF00PG0S AF00PN0S AF00SGDS AF00SNDS AP000G0S AP000N0S NP00G@0S NP00N@0S MC00G0S MC00N0S V@M0AS V@M0PS V@N0AS V@N0PS AKT AKT SFO V@IPAS V@IPPS V@IIAS V@IIPS V@IUAS V@IUPS);

### CT 210824	&tie_tagger_files();
#&read_tagger_lists();

#while(my($k,$v) = each(%MTM::Legacy::Lists::p_wordtags)) {
#	print "oo $k\t$v\n";
#}

#my $tagger_mode = 'preproc';
our $tagger_mode = 'xxx';

local $| = 1; # don't buffer output

## no critic (InputOutput::RequireBriefOpen)
open my $fh_TAGGER_LOG,'>', "$logPath/POSTagger.log" or die "Cannot open TAGGER_LOG $logPath/POSTagger.log: $!";
## use critic
#******************************************************************#
##### To be replaced when we use the new structure for pos tagging.
##### CT 210925
sub insert_postags {
	my $self = shift;
	my $chunk = shift;
	my $poslist = shift;
	my $morphlist = shift;
	my $c = shift;

	my @poslist = @$poslist;
	my @morphlist = @$morphlist;

	my $i = 0;

	my $t = $self->{LEGACYDATA};
	$t->{pos} = $poslist[$c];
	$t->{morph} = $morphlist[$c];

	#print STDERR "T $t->{orth}\t$t->{pos} $t->{morph}\n";

	return $self;

}
#******************************************************************#
sub runPosTagger {

	my @words = @_;
	my $debug = pop( @words );

	# Create new list without blanks,
	# save indices for blanks
	my @words2 = ();
	my %savedIndices = ();
	my $i = 0;

	foreach my $w ( @words ) {

		# Don't use original word
		my $tmpW = $w;

		if ( $tmpW !~ /^\s*$/ ) {
			push @words2, $tmpW;
		} else {
			$savedIndices{ $i }++;
		}
		$i++;
	}

	# Add start and end of string
	unshift @words2, '__$';
	unshift @words2, 'preproc';
	push @words2, '__$';

	# Tag words
	my( $bestTag ) = &TagWords( @words2 );
	my @bestTag = @$bestTag;
	shift @bestTag;

	my @poslist = ();
	my @morphlist = ();

	# Restore word list with blanks
	$i = 0;		# hash counter ( @words, with blanks)
	my $j = 0;		# list counter ( tag list)
	foreach my $word ( @words ) {
		my $pos;
		my $morph;

		if ( exists( $savedIndices{ $i } )) {
			$pos = 'DEL';
			$morph = '-';

		} else {
			$pos = 'UNK';

			# Convert to SUC format
			if ( exists ( $MTM::Legacy::Lists::p2s{ $bestTag[ $j ] } ) ){
				$pos = $MTM::Legacy::Lists::p2s{ $bestTag[ $j ] };
				$morph = '-';
			}

			if ( $pos =~ /^(..) (.+)$/ ) {
				$pos = $1;
				$morph = $2;
			} else {
				$morph = '-';
			}

			$j++;
		}

		push @poslist, $pos;
		push @morphlist, $morph;
		# print STDERR "\truntagger $word\t$pos $morph\n";
		$i++;
	}
	return(  \@poslist, \@morphlist );
}
#******************************************************************#
# Tag Words
#******************************************************************#
sub TagWords {

	my( $text_mode, @string ) = @_;

	if ( $string[-1] eq 'preproc' ) {
		$tagger_mode = 'preproc';
	}

	my @prob = ();
	my @bestTag = ();
	my @TagConf = ();

	my $PrevTag;
	my $maxProbTag;
	my $maxProb;
	my $tagConf;

	my @PossibleTags = ();
	my @WordList = ();
	my @PT2 = ();
	my @PT = ();
	my %PT2 = ();

	#*************************************************************************#
	# 1. Find all possible tags for all words.
	#*************************************************************************#
	foreach my $i (0 .. $#string){

		my $found = 0;

		@PT2 = ();
		@PT = ();
		%PT2 = ();

		# print STDERR "S $string[$i]\n";

		### Panic $MTM::Legacy::Lists::list_mode eq 'DB_File'encoding
		if( $MTM::Legacy::Lists::list_mode eq 'DB_File' && $string[$i] !~ /^([åäöÅÄÄÖ]|$MTM::Vars::vowel|$MTM::Vars::consonant|$MTM::Vars::characters|$MTM::Vars::uc|$MTM::Vars::lc|$MTM::Vars::quote|$MTM::Vars::delimiter|$MTM::Vars::otherDelimiter|\d|$MTM::Legacy::Lists::sv_special_character_list)+$/ ) {
			utf8::encode( $string[$i] );
		}

		# Start & end
		if ( $string[ $i ] eq '__$' ) {
			push @PT,$string[ $i ];
			push @WordList,$string[ $i ];
			$PossibleTags[ $i ] = 'FE';

		# Numerals
		} elsif ( $string[ $i ] =~ /\d/ && $string[ $i ] =~ /^[\d\.\, ]+$/ ) {
			$PossibleTags[ $i ] = 'MC00N0S';
			push @WordList,$string[ $i ];

		# Ordinal endings
		} elsif ( $string[ $i ] =~ /^[\d\.\, ]+($MTM::Vars::sv_ordinal_endings)$/ ) {
			$PossibleTags[ $i ] = 'MO00N0S';
			push @WordList,$string[ $i ];

		# Dash	
		} elsif ( $string[ $i ] =~ /^(–|-)$/ ) {
			push @PT,'FI';
			$PossibleTags[ $i ] = 'FI';
			push @WordList,$string[ $i ];

		# 4:s
		} elsif ( $string[ $i ] =~ /^\d+(:?s)$/i ) {
			$PossibleTags[ $i ] = 'MC00N0S';
			push @WordList,$string[ $i ];


		# Special characters: ζ
		} elsif ( $string[ $i ] =~ /($MTM::Legacy::Lists::sv_special_character_list|€|£|‰|×|±|†)/ ) {
			$PossibleTags[ $i ] = 'NC000@0S';
			my $tmp = $string[ $i ];
			utf8::encode( $tmp );
			push @WordList,$tmp;

		# Other
		} else {
			my $WordNow = $string[ $i ];
			$WordNow =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			$WordNow =~ s/^\x{FEFF}//;

			# Upper-/lowercase word until found in lexicon.
			if (
				!( exists ( $MTM::Legacy::Lists::p_wordtags{ $WordNow } ) )
				&&
				!( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } ) )
			) {
				$WordNow = &MTM::Case::makeLowercase( $WordNow );
				$WordNow =~ s/-$//;

				# Uppercase first
				if (
					!( exists ( $MTM::Legacy::Lists::p_wordtags{ $WordNow } ) )
					&&
					!( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } ) )
				) {
					$WordNow = ucfirst( $WordNow );
				}
			}

			#print STDERR "WordNow case: ___ $WordNow ___\t$MTM::Legacy::Lists::p_wordtags{ $WordNow }\n";
			push @WordList, $WordNow;

			# Get possible tags
			if ( exists ( $MTM::Legacy::Lists::p_wordtags{ $WordNow } ) ) {

				my $PT = $MTM::Legacy::Lists::p_wordtags{ $WordNow };
				@PT = split/\t/,$PT;

				foreach my $pt ( @PT ) {
					if ( exists ( $PT2{ $pt } ) ) {
					} else {
						push @PT2,$pt;
						$PT2{ $pt }++;
					}
				}
				$found = 1;
			}

			# Use backup lexicon only if word not found in priority lex.
			if ( $#PT2 < 1 ) {
				if ( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } ) ) {
					my $PT = $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow };
					@PT = split/\t/,$PT;

					foreach my $pt ( @PT ) {
						if ( exists ( $PT2{ $pt } ) ) {
						} else {
							push @PT2,$pt;
							$PT2{ $pt }++;
						}
					}
					$found = 1;
				}
			}

			# UNKNOWN word
			if ( $found == 0 ) {
				push @PT2,'UNKNOWN';
			}

			$PossibleTags[ $i ] = join"\t",@PT2;
		}
	}

	#*************************************************************************#
	# 2. Tag
	#*************************************************************************#
	foreach my $i (0 .. $#string) {

		dbg("\n++++++++++++++++++++++++++++++++++++++++++++++++++\n'$i: $string[$i]'\n");

		my $maxProb = 0.0;
		$maxProbTag = undef;
		$tagConf = 'WW';

		my $WordNow = $WordList[ $i ];
		my $PossTags = $PossibleTags[ $i ];

		# Start & end
		if ( $string[ $i ] eq '__$' ) {
			$maxProb = 1.0;
			$maxProbTag = '__$';
			$tagConf = 'KW';

		# Numerals		# Added ' ' (2 000)
		} elsif ( $string[ $i ] =~ /\d/ && $string[ $i ] =~ /^[\d\.\, ]+$/ ) {
			$maxProb = 1.0;
			$maxProbTag = 'MC00N0S';
			$tagConf = 'KW';

		# Ordinal endings
		} elsif ( $string[ $i ] =~ /^[\d\.\, ]+($MTM::Vars::sv_ordinal_endings)$/ ) {
			$maxProb = 1.0;
			$maxProbTag = 'MO00N0S';

			$tagConf = 'KW';

		# Dash	
		} elsif ( $string[ $i ] =~ /^(–|-)$/ ) {
			$maxProb = 1.0;
			$maxProbTag = 'FI';
			$tagConf = 'KW';

		# Special characters: ζ
		} elsif ( $string[ $i ] =~ /($MTM::Legacy::Lists::sv_special_character_list)/ ) {
			$maxProb = 1.0;
			$maxProbTag = 'NC000@0S';
			$tagConf = 'KW';

		} else {

			# If word exists in lexicon (as is)
			if (
				exists ( $MTM::Legacy::Lists::p_wordtags{ $WordNow } )
				||
				exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } )
			) {
				# No tags found
				if( $#PossibleTags == 0 ) {
					return ( 1, $PossibleTags[0]);
				}
				($maxProb,$maxProbTag) = &KnownWord($WordNow,$PrevTag,$i,\@string,\@bestTag,\@prob,\@PossibleTags);
				$tagConf = 'KW';

			# GENITIVE check
			} elsif ( $WordNow =~ /s$/ ) {
				$WordNow =~ s/[\'\:]?s$//;
				($maxProb,$maxProbTag) = &KnownWord($WordNow,$PrevTag,$i,\@string,\@bestTag,\@prob,\@PossibleTags);
				$tagConf = 'GW';
			}

			# UNKNOWN word
			if ( $maxProb eq '0' && $WordNow ) {
				($maxProb,$maxProbTag) = &UnknownWord($i,\@string,\@bestTag,\@prob,$PrevTag,\@PossibleTags,$text_mode);
				$tagConf = 'UW';
			}
		}

		$PrevTag = $maxProbTag;

		# PoS-tags not accepted by SPARK parser (which is not used, but still)
		$maxProbTag =~ s/NCUS0\@IC$/NCUS0\@0S/;
		$maxProbTag =~ s/NC000\@0C$/NCUS0\@0S/;

		# Error somewhere.
		$maxProbTag =~ s/MOMSN0S/MOMSNDS/;

		push @prob,$maxProb;
		push @bestTag,$maxProbTag;
		push @TagConf,$tagConf;

		dbg("\t\tMAX = $maxProb\n");
		dbg("\t\tTAG = $maxProbTag\n")
	}

	print $fh_TAGGER_LOG "Returning @bestTag\t@prob\t@TagConf\n";
	return (\@bestTag,\@prob,\@TagConf);
}
#******************************************************************#
# Known words
#******************************************************************#
sub KnownWord {

	my ( $WordNow, $PrevTag, $i, $string, $bestTag, $prob, $PossibleTags ) = @_;

	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;
	my @PossibleTags = @$PossibleTags;

	my $maxProb = 0.0;
	my $maxProbTag = 'UNKNOWN';
	my $maxProbSuffix = 0.0;
	my $maxProbTagSuffix = undef;
	my $maxProbBigram = 0.0;
	my $maxProbTagBigram = undef;

	my @PossTags = ();

	# Word exists in lexicon - get possible tags.
	# Main lexicon
	if ( exists ( $MTM::Legacy::Lists::p_wordtags{ $WordNow } ) || exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } ) ) {
		@PossTags = split/\t/,$PossibleTags[ $i ];
		dbg ("\t\tPossible Tag SUC: @PossTags\n");

	}

#	# Backup lexicon		
#	if ( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } ) ) {
#		my @PossTags2 = split/\t/,$MTM::Legacy::Lists::p_backup_wordtags{ $WordNow };
#		@PossTags = split/\t/,$PossibleTags[ $i ];
#		dbg ("\t\tPossible Tag TPB: @PossTags2\n");
#		push @PossTags,@PossTags2;
#	}	

	my $PossTagsCheck = join"|",@PossTags;

	foreach my $PossTag ( @PossTags ) {

		my $factor1 = 0.0;
		my $factor2 = 0.0;

		my $WordTag = "$WordNow\t$PossTag";
		print $fh_TAGGER_LOG "\t-----------------------\n\t\tWT: $WordTag\n";

		# Unigram tags
		if ( exists ( $MTM::Legacy::Lists::p_wordprob{ $WordTag } ) ) {
			$factor1 = $MTM::Legacy::Lists::p_wordprob{ $WordTag };

		} elsif ( exists ( $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag } ) ) {
			$factor1 = $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag };

			# Lower $factor1 if taken from backup lexicon
			$factor1 *= 0.5;

		} else {
			$factor1 = 0.0;
		}

		dbg ("\t\t\tUnigram: $factor1\n");

		# The lookup word is modified (e.g. genitive strip)
		my $compare = $string[ $i ] . "s";
		if ( $WordNow eq $compare ) {
			$PossTag =~ s/NP00N\@0S/NP00G\@0S/;
		}
		#************************************************************************************************#
		# BIGRAM & TRIGRAM
		my $Bigram = "$PrevTag\t$PossTag";
		my $Trigram = "$bestTag[ $i-2 ]-$PrevTag\t$PossTag";

		dbg("\n\n\t\tLook for trigram: $Trigram\n");
		dbg("\t\tor bigram: $Bigram\n\n");

		# TRIGRAM
		if ( exists ( $MTM::Legacy::Lists::p_trigram{ $Trigram } ) ) {
			$factor2 = $MTM::Legacy::Lists::p_trigram{ $Trigram };
			chomp $factor2;
			dbg ("\t\t\tTrigram: $factor2\n");

		# BIGRAM
		} elsif ( exists ( $MTM::Legacy::Lists::p_bigram{ $Bigram } ) ) {
			$factor2 = $MTM::Legacy::Lists::p_bigram{ $Bigram };
			chomp $factor2;
			dbg ("\t\t\tBigram: $factor2\n");

		} else {
			$factor2 = 0.0;
		}

		chomp $factor1;
		chomp $factor2;

		# Fallbacks
		if ( $factor1 !~ /\d/ ) {
			$factor1 = 0.5;
		}
		if ( $factor2 !~ /\d/ ) {
			$factor2 = 0.5;
		}

		my $tmpProb = $factor1 * $factor2;

		#************************************************************************************************#
		# C O N S T R A I N T   R U L E S
		#************************************************************************************************#
		print $fh_TAGGER_LOG "\t\ttmpProb before rules: $tmpProb\n";

		# Get $PossTags for next word.
		my $NextPossTags = 'UNKNOWN';
		my $NextPossTags2 = 'UNKNOWN';
		if ( $i != $#string ) {
			$NextPossTags = $PossibleTags[ $i+1 ];
			if ( $i != $#string-1 ) {
				$NextPossTags2 = $PossibleTags[ $i+2 ];
			}
		}

		# Roman numbers genitive
		if ( $WordNow =~ /^[ivx]+(:?s)$/i && $WordNow !~ /^is$/i ) {
			$tmpProb = 100;
			$PossTag = 'MO00G0S';
		}

		# Reparing rules
		if (
			( $WordNow =~ /^förlåt$/i && $PossTag =~ /^[VI]/ && $string[ $i+1 ] !~ /^en$/i )			# förlåt NN --> VB/IN
			||
			( $WordNow =~ /^utan$/i && $PossTag eq 'CCS' && $NextPossTags =~ /V\@/ )				# utan VB --> KN
			||
			( $WordNow =~ /^många$/i && $PossTag eq 'PI@0P0@S' && $NextPossTags =~ /V\@/ )			# många	VB --> PN
			||
			( $WordNow =~ /^man$/i && $PossTag =~ /^PI/ && $PrevTag !~ /(?:^|_)DI/ )				# man NN --> PN
			||
			( $WordNow =~ /^vi$/i && $PossTag =~ /^PF/ )								# vi --> PF
			||
			( $PossTag =~ /^V\@IU/ && $string[ $i-1 ] =~ /^(har|hade)$/i )						# har/hade VB --> SUP
			||
			( $PossTag =~ /^AF/ && $PrevTag =~ /^V/ && $string[ $i-1 ] !~ /^(har|hade)$/i )			# var imponerade
			||
			( $PossTag =~ /^NP/ && $string[ $i-1 ] =~ /^(?:mr|miss|mrs)$/i )					# mr, miss, mrs X
			||
			( $PossTagsCheck =~ /(?:^|\|)DF/  && $NextPossTags =~ /(?:^|\t)(?:V|PF)/ && $PossTag =~ /^PF/ )	# Pronoun if next word is a verb or pronoun.
			||
			( $WordNow =~ /^(de[nt])$/i && $PossTag =~ /^D/ && $NextPossTags =~ /(?:^|\t)[NA]/ && $NextPossTags !~ /V\@/ )	# Determiner if next word is a noun or adjective.
			||
			( $WordNow =~ /^sen$/i && $PossTag !~ /^AQ/ ) && ( $i != $#string && $NextPossTags =~ /V\@/ )	# sen VB
			||
			( $WordNow =~ /^para[dt]$/i && $string[ $i+1 ] =~ /^med$/i && $PossTag =~ /^AF/)			# Homograph: parad, next word is 'med'
			||
			( $WordNow =~ /^fördelar$/i && $PossTag =~ /^N/ && $NextPossTags =~ /(^|\t)SPS/ )			# fördelar PP --> NN
			||
			( $WordNow =~ /^en$/i && $string[ $i-1 ] =~ /^en$/ && $PossTag =~ /^N/ ) 				# en en --> DT NN
			||
			( $WordNow =~ /^bärs$/i && $string[ $i+1 ] =~ /^(?:upp|nära)$/i && $PossTag =~ /^V/ )			# eller bärs upp av
		) {
			$tmpProb *= 100;
		}


		if (
			( $WordNow eq 'Hans' && ( $string[$i+1] =~ /^[A-Z]$/|| $NextPossTags =~ /\bNP/ ))		# Hans --> pm	if followed by PM or initial
			||
			$WordNow eq 'Mats'
		) {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		}

		if (
			( $WordNow =~ /^min$/ && $PossTag =~ /^PS/ && $NextPossTags =~ /\bNC/ )				# min NN
			||
			( $WordNow =~ /^min$/i && $PossTag =~ /^N/ && $PrevTag =~ /^A/ && $string[ $i+1 ] eq '.' )		# JJ min __$ --> NN
			||
			( $WordNow =~ /^min$/ && $PossTag =~ /^N/ && $string[ $i-1 ] =~ /^(?:en|sura|sur)$/i )		# min PS	en min, sur min, sura min,
			||
			( $WordNow =~ /^dom$/i && $string[ $i-1 ] =~ /^(det|mellan|andra|hade)$/i )				# dom		är det dom?		något otalt mellan dom
			||
			( $PossTagsCheck =~ /(?:^|\|)NP/  && $WordNow =~ /^[A-ZÅÄÖ]/ && $PossTag !~ /^NP/ && $i != 1 )	# One possible tag is proper name and the word starts with uppercase letter - degrade other PoSes. Not if first word in sentence.

		) {
			$tmpProb = 100;
		}









		# som				080827
		if ( $WordNow =~ /^som$/i ) {
# TESTA ----PAUSING NN_KN_VB--- Hon söker därutöver ofta efter lösningar som skall vara hållbara i ett längre tidsperspektiv .

			# NN som/HP VB		hunden som springer, det som
			if ( $PossTag =~ /PH\@000\@S/ && $PrevTag =~ /^(N|P|DF)/ && $NextPossTags =~ /V\@/ ) {
				$tmpProb *= 1000;

			# VB som/KN NN		springer som hunden
			# NN som/KN NN/DT	psykology som en del
			} elsif ( $PossTag =~ /CCS/ && $PrevTag =~ /(V\@|N)/ && $NextPossTags =~ /^(N|P|D)/ ) {
				$tmpProb *= 100;

			}

		}


		# Lower probability
		if (
			( $i == 1 && $string[ $i ] eq 'Vi' && $PossTag =~ /^NP/ )	# Vi		NP
			||
			( $string[ $i ] =~ /^[dm]in$/i && $PossTag =~ /^NC/ )		# Din, min	NC
			||
			( $WordNow eq 'Hans' && $i == 1 && $PossTag =~ /^NP/ && $NextPossTags !~ /\bNP/ )		# Hans	--> pronoun if first in sent, but not if next word could be proper noun.
		) {
			$tmpProb *= 0.01;
		}





		# sen
		if ( $WordNow =~ /^sen$/i ) {
			# Adjective
			if ( $PossTag =~ /^AQ/ ) {
				if(
					( $i != 0 && $string[$i-1] =~ /^en$/i && $NextPossTags =~ /NC/ ) 							# en sen NN
					||
					( $i != 0 && $i != $#string && $string[ $i-1 ] =~ /^(var|vara|varit|inte)$/i && $string[ $i+1 ] =~ /^att$/ )	# var sen att, inte sen att
					||
					( $PrevTag =~ /^CCS/ && $NextPossTags =~ /^AQ/ )										# eller sen JJ
				) {
					$tmpProb *= 100;
				}
			}
		# kort
		} elsif( $WordNow =~ /^kort-?$/i ) {
			# Adjective
			if( $PossTag =~ /^AQ/ ) {
				if(
					( $string[ $i+1 ] =~ /^och$/i && $NextPossTags2 =~ /(^|\t)AQ/ )								# kort och gott
					||
					( $string[ $i+1 ] =~ /^(om|efter|efteråt|dessförinnan|därpå|.*tid|.*ning|.*period|duration|sagt|beskr[ie]v*?|\d)$/i )	# kort om boken
					||
					( $NextPossTags =~ /(?:^|\t)(?:N|AQ)/ || $string[ $i-1 ] =~ /^(?:(?:allt)?för|var)$/i || $PrevTag =~ /^(?:RG|PD)/  )	# för kort JJ
					||
					( $string[ $i-2 ] =~ /^den$/ && $string[ $i-1 ] =~ /^är$/i ) 									# den är kort
					||
					( $NextPossTags eq 'FI' && $NextPossTags2 =~ /AQ/ )										# kort, fjällig svans
					||
					( $string[ $i-1 ] =~ /^(?:processen|livet|blev|tittade|inom|extremt|i|blivit)$/i )			 			# Gjorde processen kort
					||	
					( $string[ $i+1 ] =~ /^och$/ && $NextPossTags2 =~ /(?:AQ|RG)/ )								# kort och blodigt
					||
					( $string[ $i-1 ] =~ /^(?:vara|var|varit|är|bli|blir|blev)$/i && $NextPossTags =~ /F[IEP]/ )				# är kort.
					||
					( $string[ $i+1 ] =~ /^(?:och|eller|som)$/i && $string[ $i+2 ] =~ /^lång/i )							# kort eller lång
					||
					( $PrevTag =~ /^P[IDF]/ )														# sa han kort
				) {
					$tmpProb *= 100;
				}
			# Noun
			} elsif( $PossTag =~ /^N/ ) {
				if(
					( ( $PrevTag =~ /^SPS/ || $string[ $i-1 ] =~ /^ett$/i ) && $string[ $i+1 ] =~ /^(med|i|på|till)$/i )			# med kort i
					||
					( $PrevTag =~ /^(?:AQPNSNIS|RGPS|AQP0PN0S)$/ )											# ett nytt kort
				) {
					$tmpProb *= 100;
				}
			}

		# modern
		} elsif ( $WordNow =~ /^modern$/i ) {
			# Noun
			if( $PossTag =~ /^N/ ) {
				if(
					( $string[ $i+1 ] =~ /^(en|till|är|var|har|hade)$/i )				# modern är|till|en
				) {
					$tmpProb *= 1000;
				}
			} elsif( $PossTag =~ /^AQ/ ) {
				if(
					( $NextPossTags =~ /(^|\t)(N|UNKNOWN)/ && $string[ $i+1 ] !~ /klarat$/i )	# modern väska
				) {
					$tmpProb *= 100;
				}
			}

		# ovan
		} elsif ( $WordNow =~ /^ovan$/i ) {
			if( $PossTag =~ /^AQ/ ) {
				if ( $string[ $i+1 ] =~ /^vid$/i && $string[1] !~ /^se$/i ) {		# ovan vid
					$tmpProb *= 1000;
				}
			}

		# karl
		} elsif ( $WordNow =~ /^Karl$/ ) {
			if (
				( $string[ $i+1 ] =~ /^[A-ZÅÄÖ]/ )					# och Karl Mannheim
				||
				( $PrevTag =~ /^FI/ && $string[ $i-2 ] =~ /^[A-ZÅÄÖ].+$/ )	# Popper, Karl (1992).
			) {
				$PossTag = 'NP00N@0S';
				$tmpProb *= 1000;
			}
		# rest
		} elsif ( $WordNow =~ /^rest$/i ) {
			if ( $PrevTag =~ /^(?:AQ|AP)/ && $PossTag =~ /^N/ ) { 						# kvarvarande rest
				$tmpProb *= 1000;
			}
		# rykte
		} elsif ( $WordNow =~ /^rykte$/i ) {
			if ( $string[ $i-1 ] =~ /^(?:dåligt|gott|bättre|sämre|detta)$/i && $PossTag =~ /^NC/ ) {	# dåligt rykte
				$tmpProb *= 1000;
			}
		# skott
		} elsif ( $WordNow =~ /^skott$/i ) {
			if ( $string[ $i+1 ] =~ /^(?:mig|dig|sig|oss)$/ ) {						# hade skott sig på
				$PossTag = 'AF0NSNIS';
				$tmpProb = 100;
			}
		# Homograph: delta
		} elsif ( $WordNow =~ /^delta$/i ) {
			if ( $PrevTag =~ /^AQ/ ) {										# stora delta
				$PossTag = 'NCNSN@IS';
				$tmpProb *= 1000;
			}
		# andra*
		} elsif ( $WordNow =~ /^andras?/i && $PrevTag =~ /V\@/ && $PossTag =~ /^AQ/ ) {			# andra, prev PoS is V*
			$tmpProb *= 10000;

		# andras NN
		} elsif ( $WordNow =~ /^andras?/i && $i != $#string && $NextPossTags =~ /NC/ ) {
			$tmpProb *= 10000;

		# att --> IE/SN
		} elsif ( $WordNow =~ /^att$/i && $PossTag eq 'CIS' ) {
			my $INF_seen = 0;
			my $VB_seen = 0;

			# Check if closest following verb is possibly INF
			if ( $i != $#string ) {
				my $m = 0;
				foreach my $pt ( @PossibleTags ) {
					if ( $m > $i && $pt =~ /V\@/ && $VB_seen == 0 ) {	# Closest following verb not yet seen
						$VB_seen = 1;
						if ( $pt =~ /V\@N/ && $string[ $m ] !~ /^var$/i ) {		# Is possibly INF
							$INF_seen = 1;
						}
					}
					$m++;
				}
			}
			if ( $INF_seen == 1 ) {		# IE
				$tmpProb *= 100;
			} else {
				$tmpProb *= 0.001;	# SN
			}
		# kön
		} elsif( $WordNow =~ /^kön/i ) {
			if ( $PossTag eq 'NCNSN@IS' ) {	# kön --> /tj 'ö2: n/ alltid
				$tmpProb *= 100;
			}

			# i kön
			if ( $string[ $i-1 ] =~ /^i$/i ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;

			# JJ POS UTR SIN IND NOM kön
			} elsif ( $PrevTag eq 'AQPUSNIS' ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;

			# Den PC PRS kön	
			} elsif( $string[ $i-2 ] =~ /^den$/i && $PrevTag =~ /AP000/ ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;

			} elsif ( $string[ $i+1 ] =~ /^till$/i && $string[ $i+2 ] =~ /^(?:snabbköps)kassan$/i ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;
			}		
		# svalt
		} elsif ( $WordNow =~ /^svalt$/i ) {
			# svalt en cigarett
			if ( $string[ $i+1 ] =~ /^(?:en|ett)$/i	|| $string[ $i-1 ] =~ /^har$/i ) {
				$PossTag = 'V@IUAS';
				$tmpProb *= 1000;

			# Duscha svalt
			} elsif ( $PrevTag =~ /^V/ && $PossTag =~ /^AQ/ ) {
				$tmpProb *= 1000;
			}

		# bete sig
		} elsif ( $WordNow =~ /^bete$/i ) {
			if ( $string[ $i+1 ] =~ /^(?:mig|dig|sig|oss|er)$/i && $PossTag =~ /^V/ ) {
				$tmpProb *= 1000;
			}


		} elsif (
			( $WordNow =~ /^rosa$/i && $PossTag =~ /^AQ/ && $PrevTag =~ /^PF/ )						# rosa VB --> JJ
			||
			( $WordNow =~ /^fars$/i && $PossTag =~ /^NCUSG/ && $NextPossTags =~ /NC/ )					# fars NOM --> GEN
			||
			( $WordNow =~ /^son$/i && $PossTag =~ /\@IS/ )									# son DEF --> IND
			||
			( $i == 1 && $PossTagsCheck =~ /(AQ.+\|NC|NC.+\|AQ)/ && $PossTag =~ /^AQ/ && $NextPossTags =~ /NC/ )	# rivet NN/AQ
			||
			( $WordNow =~ /^tomt$/i && $PrevTag =~ /^P/ && $PossTag =~ /^NC/ ) 						# PN tomt
			||
			( $WordNow =~ /^tomt$/i && $PossTag =~ /^AQ/ && $i == 1 ) && ( $i == $#string-1 || $i == $#string-2 )	# tomt --> JJ
			||
			( $WordNow =~ /^drog$/i && $PossTag =~ /^V/ && $NextPossTags =~ /(^|\t)P/ )					# drog	NN/VB
			||
			( $WordNow =~ /^syntes$/i && $PossTag =~ /^V/ && $PrevTag =~ /^[PDN]/ )					# syntes - det syntes --> VB	NN syntes --> VB
			||
			( $WordNow =~ /^fördelar$/ && $string[ $i+1 ] =~ /^sig$/i && $PossTag =~ /^V/ )				# fördelar sig --> VB
			||
			( $WordNow =~ /^nu$/i && $PossTag =~ /^RG/ )									# nu --> AB
			||
			( $WordNow =~ /^stans$/i && $PossTag =~ /^N/ && $string[ $i-1 ] =~ /^(hos)$/i ) 				# stans --> NN
			||
			( $WordNow =~ /^fint$/i && $PossTag =~ /^[A]/ && $string[ $i-1 ] !~ /^en$/i ) 				# fint --> JJ
			||
			( $WordNow =~ /^mors$/i && $PossTag =~ /^N/ && $NextPossTags =~ /(^|\t)N/ ) 					# mors --> NN
			||
			( $WordNow =~ /^taget$/i && $PossTag =~ /^N/ && $PrevTag =~ /^V/ )						# taget --> NN
		) {
			$tmpProb =~ s/^0$/0.1/;
			$tmpProb *= 100;

		# Tom
		} elsif ( $WordNow =~ /^Tom$/ && $i != 0 ) {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		# PN/DT parad
		} elsif ( $WordNow =~ /^parad$/i && $PrevTag =~ /^[PD]/ ) {
			$PossTag = 'NCUSN@IS';
			$tmpProb = 100;
		# kör
		} elsif ( $WordNow =~ /^kör$/i ) {
			if(
				( $PossTag =~ /^V/ && $PrevTag !~ /^D/ )
				||
				( $PossTag =~ /^N/ && $PrevTag =~ /^SP/ )
			) {
				$tmpProb *= 100;
			}
		# var __$ --> AB
		} elsif ( $WordNow =~ /^var$/ && $string[ $i+1 ] eq '__$' ) {
			$PossTag = "RG0S";
			$tmpProb = 100;
		# vi och dom --> PN
		} elsif ( $WordNow =~ /^dom$/i && $string[ $i - 2 ] =~ /^vi$/i && $string[ $i-1 ] =~ /^och$/i ) {
			$PossTag = 'PD@0PO@S';
			$tmpProb = 100;
		# dom
		} elsif ( $WordNow =~ /^dom$/i && $string[$i-1] =~ /^(?:domstols|TR:s|vars|tingsrättens)/ && $PossTag =~ /^N/ ) {
			$tmpProb = 1000;
		# homograph: läst
		} elsif ( $WordNow =~ /^läst$/ ) {
			if (
				$string[ $i-1 ] =~ /^ha$/i		# ha läst --> VB	en läst berättelse
				||
				$NextPossTags =~ /NC/
				||
				$string[ $i+1 ] =~ /^(?:om|på|in)$/i
			) {
				$PossTag = 'V@IUAS';
				$tmpProb = 100;
			}
		# Japan - japan, Japans - japans
		} elsif ( $WordNow =~ /^Japans?$/ && $PossTag =~ /^NP/ ) {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		}


		#**********************************************#		
		print $fh_TAGGER_LOG "\t\ttmpProb: $tmpProb\n\n";

		if( $tmpProb >= $maxProb ) {
			$maxProb = $tmpProb;
			$maxProbTag = $PossTag;
		}

	} # end @PossTags

	# $maxProb is 0.0 - use max unigram.
	if ( $maxProb == 0 ) {
		foreach my $PossTag ( @PossTags ) {

			my $WordTag = "$WordNow\t$PossTag";

			my $factor1 = 0.0;

			if ( exists ( $MTM::Legacy::Lists::p_wordprob{ $WordTag } ) ) {
				$factor1 = $MTM::Legacy::Lists::p_wordprob{ $WordTag };

			} elsif ( exists ( $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag } ) ) {
				$factor1 = $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag };

			} else {
				$factor1 = 0.0;
			}

			my $tmpProb = $factor1;

			if($tmpProb >= $maxProb){
				$maxProb = $tmpProb;
				$maxProbTag = $PossTag;
			}
		}
	}

	# Ugly fix for 'kan', fix this bug later.
	if ( $WordNow =~ /^kan$/i ) {
		$maxProb = "100";
		$maxProbTag = 'V@IPAS';
	}	

	return ( $maxProb, $maxProbTag);
}
#******************************************************************#
# Unknown words
#******************************************************************#
sub UnknownWord {
	my ($i,$string,$bestTag,$prob,$PrevTag,$PossibleTags,$text_mode) = @_;

	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;
	my @PossibleTags = @$PossibleTags;

	my $maxProb = 0.0;
	my $maxProbTag = 'UNKNOWN';
	my $maxProbSuffix = 0.0;
	my $maxProbTagSuffix = undef;
	my $maxProbBigram = 0.0;
	my $maxProbTagBigram = undef;
	my $maxNgramProb = 0.0;
	my $maxNgramProbTag = 0.0;
	my $maxSuffixProb = 0.0;
	my $maxSuffixProbTag = 0.0;

	print $fh_TAGGER_LOG "\t\tUNKNOWN: $string[ $i ]\n";

	# Multiword check
	if ( exists( $MTM::Legacy::Lists::multiword_tag{ $string[ $i ]} )) {
		$maxProb = 1;
		$maxProbTag = $MTM::Legacy::Lists::multiword_tag{ $string[ $i ]};
		$maxProbTag =~ s/\t+.*$//;
		$maxProbTag = $MTM::Legacy::Lists::s2p{ $maxProbTag };		# Convert from SUC to Parole tags
	}

	# Suffix check
	if ( $maxProb == 0 ) {
		( $maxProb, $maxProbTag ) = &SuffixProb($i, $string, $bestTag, $prob, $PrevTag, $PossibleTags);
	}

	# Name check
	if ( $maxProb == 0 ) {
		( $maxProb, $maxProbTag ) = &NameCheck($i, $string, $bestTag, $prob, $PrevTag);
	}

	return ( $maxProb, $maxProbTag);
}
#******************************************************************#
# ngram check for unknown words
# Works like known words but always start with $factor1 (unigram) as 1
# and uses the list of possible tags for unknown words specified above
#******************************************************************#
sub ngramUnknownWord {

	my ($WordNow,$PrevTag,$i,$string,$bestTag,$prob,$PossibleTags) = @_;

	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;
	my @PossibleTags = @$PossibleTags;


	my $maxProb = 0.0;
	my $maxProbTag = 'UNKNOWN';
	my $maxProbSuffix = 0.0;
	my $maxProbTagSuffix = undef;
	my $maxProbBigram = 0.0;
	my $maxProbTagBigram = undef;

	my @PossTags = @AllPossTags;

	foreach my $PossTag ( @PossTags ) {

		my $factor1 = 0.0;
		my $factor2 = 0.0;

		my $WordTag = "$WordNow\t$PossTag";
		print $fh_TAGGER_LOG "\t-----------------------\n\t\tWT: $WordTag\n";

		$factor1 = 1;

		#************************************************************************************************#
		dbg ("\t\t\tUnigram: $factor1\n");

		# The lookup word is modified (e.g. genitive strip)
		my $compare = $string[ $i ] . "s";
		if ( $WordNow eq $compare ) {
#			print "$WordNow\t$string[ $i ]\t\t$PossTag\n";
			$PossTag =~ s/NP00N\@0S/NP00G\@0S/;
		}

		# BIGRAM & TRIGRAM
		my $Bigram = "$PrevTag\t$PossTag";
		my $Trigram = "$bestTag[ $i-2 ]-$PrevTag\t$PossTag";


		dbg("\n\n\t\tLook for trigram: $Trigram\n");
		dbg("\t\tor bigram: $Bigram\n\n");

		if ( exists ( $MTM::Legacy::Lists::p_trigram{ $Trigram } ) ) {
			$factor2 = $MTM::Legacy::Lists::p_trigram{ $Trigram };
			chomp $factor2;

			dbg ("\t\t\tTrigram: $factor2\n");

		# BIGRAM
		} elsif ( exists ( $MTM::Legacy::Lists::p_bigram{ $Bigram } ) ) {
			$factor2 = $MTM::Legacy::Lists::p_bigram{ $Bigram };
			chomp $factor2;

			dbg ("\t\t\tBigram: $factor2\n");
		} else {
			$factor2 = 0.0;
		}

		my $tmpProb = $factor1 * $factor2;

		print $fh_TAGGER_LOG "\t\ttmpProb: $tmpProb\n\n";

		if($tmpProb >= $maxProb){
			$maxProb = $tmpProb;
			$maxProbTag = $PossTag;
		}

	} # end @PossTags

	return ( $maxProb, $maxProbTag);
}
#******************************************************************#
# Name check for unknown words
#******************************************************************#
sub NameCheck {

	my ( $i, $string, $bestTag, $prob , $PrevTag) = @_;
	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;

	my $word = $string[ $i ];

	my $maxProbTag = undef;
	my $maxProb = 0;

	# First letter is uppercase
	if ( $word =~ /^[A-ZÅÄÖÜÉÈ][a-zåäöüéèéúù]/ ) {
		if ( $PrevTag	=~	/^NP/ ) {
			$maxProbTag	=	'NP00N@0S';
			$maxProb	=	1;

		} elsif ( $i+1 <= $#string ) {

			if ( $string[ $i+1 ]	=~	/^[A-ZÅÄÖÜÉÈ][A-ZÅÄÖÜÉÈa-zåäöüéèéúù]/ ) {
				$maxProbTag	=	'NP00N@0S';
				$maxProb	=	1;
			}
		}
	}

	if ( $maxProb == 0 ) {
		$maxProbTag = "UNKNOWN";
	}

	return ( $maxProb, $maxProbTag );		
}
#******************************************************************#
# Suffix check for unknown words
#******************************************************************#
sub SuffixProb {

	my ( $i, $string, $bestTag, $prob , $PrevTag, $PossibleTags) = @_;
	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;
	my @PossibleTags = @$PossibleTags;

	my $word = $string[ $i ];

	my @CheckWord = split//,$word;

	my $maxProbTag = undef;
	my $maxProb = 0;


	until ( $#CheckWord < 3 || $maxProb != 0) {
		shift @CheckWord;
		my $CheckWord = join"",@CheckWord;

		# Check if whole word exists (compounds)

		# If word exists in lexicon (as is)
		if (
			exists ( $MTM::Legacy::Lists::p_wordtags{ $CheckWord } )
		) {
			if ( exists ( $MTM::Legacy::Lists::p_wordtags{ $CheckWord } ) ) {
				@PossibleTags = split/\t/,$MTM::Legacy::Lists::p_wordtags{ $CheckWord };
			} else {
				@PossibleTags = split/\t/,$MTM::Legacy::Lists::p_backup_wordtags{ $CheckWord };
			}

#			print "THIS WORD EXISTS: $CheckWord\n\n";
			print $fh_TAGGER_LOG "THIS WORD EXISTS: $CheckWord\n\n";
			#($maxProb,$maxProbTag) = &KnownWord($CheckWord,$PrevTag,$i,\@string,\@bestTag,\@prob,\@PossibleTags);
				my $PossTagsCheck = join"|",@PossibleTags;

				foreach my $PossTag ( @PossibleTags ) {

					my $factor1 = 0.0;
					my $factor2 = 0.0;

					my $WordTag = "$CheckWord\t$PossTag";

					print $fh_TAGGER_LOG "------------\n\t\t\tWT: $WordTag\n";

					# Unigram tags
					if ( exists ( $MTM::Legacy::Lists::p_wordprob{ $WordTag } ) ) {
						$factor1 = $MTM::Legacy::Lists::p_wordprob{ $WordTag };

					} elsif ( exists ( $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag } ) ) {
						$factor1 = $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag };

					} else {
						$factor1 = 0.0;
					}

					dbg ("\t\t\tUnigram: $factor1\n");

					# The lookup word is modified (e.g. genitive strip)
					my $compare = $string[ $i ] . "s";
					if ( $CheckWord eq $compare ) {
						$PossTag =~ s/NP00N\@0S/NP00G\@0S/;
					}

					# BIGRAM & TRIGRAM
					my $Bigram = "$PrevTag\t$PossTag";
					my $Trigram = "$bestTag[ $i-2 ]-$PrevTag\t$PossTag";

					dbg("\n------------\n\t\tLook for trigram: $Trigram\n");
					dbg("\t\tor bigram: $Bigram\n\n");

					if ( exists ( $MTM::Legacy::Lists::p_trigram{ $Trigram } ) ) {
						$factor2 = $MTM::Legacy::Lists::p_trigram{ $Trigram };
						dbg ("\t\t\tTrigram: $factor2\n");

					# BIGRAM
					} elsif ( exists ( $MTM::Legacy::Lists::p_bigram{ $Bigram } ) ) {
						$factor2 = $MTM::Legacy::Lists::p_bigram{ $Bigram };
						dbg ("\t\t\tBigram: $factor2\n");

					} else {
						$factor2 = 0.0;
					}

					my $tmpProb = $factor1 * $factor2;

					print $fh_TAGGER_LOG "\t\ttmpProb: $tmpProb\n";

					if($tmpProb >= $maxProb){
						$maxProb = $tmpProb;
						$maxProbTag = $PossTag;
					}

				} # end @PossTags

				# All probs are 0.0 - use max unigram.
				if ( $maxProb == 0 ) {
					foreach my $PossTag ( @PossibleTags ) {

						my $WordTag = "$CheckWord\t$PossTag";

						my $factor1 = 0.0;

						if ( exists ( $MTM::Legacy::Lists::p_wordprob{ $WordTag } ) ) {
							$factor1 = $MTM::Legacy::Lists::p_wordprob{ $WordTag };

						} elsif ( exists ( $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag } ) ) {
							$factor1 = $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag };

						} else {
							$factor1 = 0.0;
						}

						my $tmpProb = $factor1;

						if($tmpProb >= $maxProb){
							$maxProb = $tmpProb;
							$maxProbTag = $PossTag;
						}
					}
				}
		} else {

			( $maxProb, $maxProbTag ) = &CheckSuffix( $i, $CheckWord, $string, $bestTag, $prob, 'mainlex' );
		}
		print $fh_TAGGER_LOG "\nCHECKING: $CheckWord\nMP: $maxProb\tMPT: $maxProbTag\n---------------\n";
	}

	@CheckWord = split//,$word;
	# Check in TPB lexicon if not found in SUC.
	if ( $maxProb == 0 ) {
		until ( $#CheckWord < 3 || $maxProb != 0) {
			my $CheckWord = join"",@CheckWord;
			( $maxProb, $maxProbTag ) = &CheckSuffix( $i, $CheckWord, $string, $bestTag, $prob , 'backuplex');

			print $fh_TAGGER_LOG "CHECKING TPB: $CheckWord\nMP: $maxProb\tMPT: $maxProbTag\n";

			# Shift here to get the lookup for the whole word.
			shift @CheckWord;
		}
	}

	if ( $maxProb == 0 ) {
		$maxProbTag = "UNKNOWN";
	}

	return ( $maxProb, $maxProbTag );

}
#******************************************************************#
# Suffix check
#******************************************************************#
sub CheckSuffix {
	my ( $i, $CheckWord, $string, $bestTag, $prob, $lex ) = @_;
	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;


	my $maxProbTag = 'UNKNOWN';
	my $maxProb = 0;

	# lowercase!!!
	$CheckWord = &MTM::Case::makeLowercase( $CheckWord );

	# Main lexicon (SUC for Swedish)
	if ( $lex eq 'mainlex' ) {

		if ( exists ( $MTM::Legacy::Lists::p_suffixtag{ $CheckWord } ) ) {

			my @PossTags = split/\t/, $MTM::Legacy::Lists::p_suffixtag{ $CheckWord };

			print $fh_TAGGER_LOG "TAGGAR... @PossTags\t$CheckWord\n";

			foreach my $tag ( @PossTags ) {

				if ( exists ( $MTM::Legacy::Lists::p_suffix{ "$CheckWord\t$tag" } ) ) {
					my $SuffixProb = $MTM::Legacy::Lists::p_suffix{ "$CheckWord\t$tag" };
					my $bigram = "$bestTag[ $i-1 ]\t$tag";
					my $Prob = 0.0;

					# Bigram exists
					if ( exists ( $MTM::Legacy::Lists::p_bigram{ $bigram } ) ) {
					$Prob = $SuffixProb * $MTM::Legacy::Lists::p_bigram{ $bigram };

					# Bigram does not exist - use $SuffixProb (not in real life... or?)
					} else {
						$Prob = $SuffixProb;
					}

					print $fh_TAGGER_LOG "PROB $Prob\t\t$maxProb\n";
					if ( $Prob >= $maxProb ) {
						$maxProb = $Prob ;
						$maxProbTag = $tag;
					}

					print $fh_TAGGER_LOG "HIGHEST: $maxProbTag\t\t$maxProb\n\n";

				}	
			}
		}
	}

	# Word part not found in mainlexicon, use backup lexicon
	if ( $maxProb == 0 ) {

		if ( exists ( $MTM::Legacy::Lists::p_backup_suffixtag{ $CheckWord } ) ) {


			my @PossTags = split/\t/, $MTM::Legacy::Lists::p_backup_suffixtag{ $CheckWord };

			print $fh_TAGGER_LOG "TAGGAR... @PossTags\t$CheckWord\n";

			foreach my $tag ( @PossTags ) {

				if ( exists ( $MTM::Legacy::Lists::p_backup_suffix{ "$CheckWord\t$tag" } ) ) {

					my $SuffixProb = $MTM::Legacy::Lists::p_backup_suffix{ "$CheckWord\t$tag" };
					my $bigram = "$bestTag[ $i-1 ]\t$tag";
					my $Prob = 0.0;

					# Bigram exists
					if ( exists ( $MTM::Legacy::Lists::p_bigram{ $bigram } ) ) {
					$Prob = $SuffixProb * $MTM::Legacy::Lists::p_bigram{ $bigram };

					# Bigram does not exist - use $SuffixProb (not in real life... or?)
					} else {
						$Prob = $SuffixProb;
					}

					print $fh_TAGGER_LOG "PROB $Prob\t\t$maxProb\n";
					if ( $Prob >= $maxProb ) {
						$maxProb = $Prob ;
						$maxProbTag = $tag;
					}

					print $fh_TAGGER_LOG "HOGSTA: $maxProbTag\t\t$maxProb\n\n";
				} # end if

			}
		}
	}
	return ( $maxProb, $maxProbTag );
}
#******************************************************************#
# Print results
#******************************************************************#
sub PrintResults {

	my ($string,$bestTag,$prob) = @_;

	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;

	print $fh_TAGGER_LOG "\n--------------\nRESULTS:\n";

	foreach my $i ( 0 .. $#string ) {
		my $suc = $MTM::Legacy::Lists::p2s{ $bestTag[ $i ] };

		if ( $bestTag[ $i ] eq "UNKNOWN" ) {
			print $fh_TAGGER_LOG "$string[ $i ]\t\tUNKNOWN\t\t$bestTag[ $i ]\t\t0\n";
		} else {
			print $fh_TAGGER_LOG "$string[ $i ]\t\t$suc\t\t$bestTag[ $i ]\t\t$prob[ $i ]\n";
		}

		#$count++;
	}
	print $fh_TAGGER_LOG "\n--------------\n\n";
	return 1;
} # end sub

###################################################################
### dbg() - Einfache Info-Messages über den Programmablauf ausgeben
###################################################################
sub dbg{
	print $fh_TAGGER_LOG "$_[0]";
	return 1;
}
#******************************************************************#
1;
