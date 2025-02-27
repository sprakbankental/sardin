package MTM::TPBTag;

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

##### (NB) We temporarily redirect the trace channel $TAGOUT to STDERR
my $TAGOUT = \*STDERR;

use strict;

use utf8;
use warnings;
use warnings qw( FATAL utf8 );
use open qw( :encoding(UTF-8) :std );
use charnames qw( :full );

our $user;
our $debug;
our $Legacypath;

my $lang = 'swe';

our %x = ();

# JE/CT 2020-11-10 moved to MTM::Vars
our @AllPossTags = @MTM::Legacy::Lists::AllPossTags;


#my $tagger_mode = 'preproc';
our $tagger_mode = 'xxx';

local $| = 1; # don't buffer output

#$PERIOD_TAG = "punkt";


### This is not used, tagging is done in TTSChunk.
sub postag_in_context {
	my $self = shift; 
	my $chunk = shift;

	#$self->{RAW} =~ m/^\s$/ && return; # Titta efter taggen ist!
	#$self->{LEGACYDATA}->{PossibleTags} eq 'DEL' && return; # Blanks are tagged as 'DEL'	CT 2022-11-18
	#$self->{LEGACYDATA}->{WHITESPACE} && return;

	# Lookup whats needed 
	# NB! Ugly fix for out of bounds will disappear
	my $t = $self->{LEGACYDATA};

#	print STDERR "$t->{orth}\n";

#	##### PANIC TAGGING: REMOVE THIS	CT 2020-11-26
#	if( $t->{orth} =~ /^\d+$/ || $t->{orth} =~ /^\d+( \d\d\d)+$/ ) {
#		$t->{pos} = 'RG';
#		$t->{morph} = 'NOM';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^\d+:e$/ || $t->{orth} =~ /^\d+( \d\d\d)+:e$/ ) {
#		$t->{pos} = 'RO';
#		$t->{morph} = 'NOM';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^(en)$/i ) {
#		$t->{pos} = 'DT';
#		$t->{morph} = 'UTR SIN IND';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^(ett)$/i ) {
#		$t->{pos} = 'DT';
#		$t->{morph} = 'NEU SIN IND';
#		return $self;
#	}
#	if( $t->{orth} =~ /^(de)$/i ) {
#		$t->{pos} = 'DT';
#		$t->{morph} = 'UTR/NEU PLU DEF';
#		return $self;
#	}
#	if( $t->{orth} =~ /^(det)$/i ) {
#		$t->{pos} = 'DT';
#		$t->{morph} = 'NEU SIN DEF';
#		return $self;
#	}
#	if( $t->{orth} =~ /^(den)$/i ) {
#		$t->{pos} = 'DT';
#		$t->{morph} = 'UTR SIN DEF';
#		return $self;
#	}
#	if( $t->{orth} =~ /^(vad)$/i ) {
#		$t->{pos} = 'HP';
#		$t->{morph} = 'NEU SIN IND';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^(sedan)$/i ) {
#		$t->{pos} = 'AB';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^(men)$/i ) {
#		$t->{pos} = 'KN';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^(var)$/i ) {
#		$t->{pos} = 'VB';
#		$t->{morph} = 'PRT AKT';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^\s+$/ ) {
#		$t->{pos} = 'DEL';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^(Nilsson|Karlsson|Peder|Karl)$/ ) {
#		$t->{pos} = 'PM';
#		$t->{morph} = 'NOM';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^[\.\!\?]$/ ) {
#		$t->{pos} = 'DL';
#		$t->{morph} = 'MAD';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^[\,\;\(\)\"]$/ ) {
#		$t->{pos} = 'DL';
#		$t->{morph} = 'MID';
#		return $self;
#	}
#
#	if( $t->{orth} =~ /^mått$/ ) {
#		$t->{pos} = 'NN';
#		$t->{morph} = 'NEU SIN IND NOM';
#		return $self;
#	}
#
#	##### END PANIC TAGGING: REMOVE THIS	CT 2020-11-26


	###### CT 2020-12-08 Fake tagging: choose first alternative.

	my @PossibleTags = @{ $t->{PossibleTags }};
	#print "PT $t->{orth}\t@PossibleTags\n";

	my $parole_tag = shift @PossibleTags;
	my $suc_tag = 'NN UTR SIN IND NOM';

	#while(my($k,$v)=each(%MTM::Legacy::Lists::p2s)){ print "I $k\t$v\n"; }

	if( exists( $MTM::Legacy::Lists::p2s{ $parole_tag } )) {
		$suc_tag = $MTM::Legacy::Lists::p2s{ $parole_tag };
	}
	$t->{pos} = $suc_tag;
	#print STDERR "tagger\t$t->{orth}\t$t->{pos}\n";


#	my $look_for_lc = 0;
#
#	# Get locations
#	my $lc1base = $chunk->peek($look_for_lc - 1) or  return $self;
#	my $lc1 = $lc1base->{LEGACYDATA};
#
#	my @lc1_PossibleTags = @{ $lc1->{PossibleTags }};
#	#print "L1 @lc1_PossibleTags\n";
#
#	if( $lc1_PossibleTags[0] eq 'DEL' ) {
#		$look_for_lc--;
#		my $lc1base = $chunk->peek($look_for_lc - 1) or  return $self;
#		my $lc1 = $lc1base->{LEGACYDATA};
#		@lc1_PossibleTags = @{ $lc1->{PossibleTags }};
#		#print "L1 NEW @L1_PossibleTags\n";
#	}
#
##	my $l3base = $chunk->peek(-3) or return $self;
##	my $l3 = $l3base->{LEGACYDATA};
#
##	my $lc2base = $chunk->peek(-2) or return $self;
##	my $lc2 = $lc2base->{LEGACYDATA};
#
##	my $rc1base = $chunk->peek(1) or  return $self;
##	my $rc1 = $rc1base->{LEGACYDATA};
#
##	my $rc2base = $chunk->peek(2) or return $self;
##	my $rc2 = $rc2base->{LEGACYDATA};
#
##	my $rc3base = $chunk->peek(3) or return $self;
##	my $rc3 = $rc3base->{LEGACYDATA};
#
#	#print "L3 $l3\nL2 $lc2\nR2 $rc2\nR3 $rc3\n";
#
#	# Do something with it
#
#	#print "Bigram\t" . "L2: " . $lc2->{orth} . "\t" . "L1: " . $lc1->{orth} . "\t" . $t->{orth} . "\t" . "R1: " . $rc1->{orth} . "\t" . "R2: " . $rc2->{orth} . "\n";
#
#
#	#$lc2->{LEGACYDATA}{UnigramProb}
#
#	my @PossibleBigrams = ();
#	foreach my $pt ( @PossibleTags ) {
#		chomp $pt;
#		foreach my $lc1_pt ( @lc1_PossibleTags ) {
#			push @PossibleBigrams, "$pt\t$lc1_pt";
#			#print "PossibleBigrams: " . "$pt\t$lc1_pt" . "\n";
#		}
#	}
#
#	#print "\tBigram\t" . "L2: ORTH $lc2->{orth}\tUNIGRAM: $lc2->{LEGACYDATA}{UnigramProb}\tPOSSTAG: $lc2->{LEGACYDATA}{PossibleTags}\n"; # . "POS L2:" . $self->{LEGACYDATA}{PossibleTags} . "\t" . "L1: " . $lc1->{orth} . "\t" . $t->{orth} . "\n";
#	#print "\tTrigram\t" . "L3: " . $l3->{orth} . "\t" . "L2: " . $lc2->{orth} . "\t" . "L1: " . $lc1->{orth} . "\t" . $t->{orth} . "\n";
#

	return $self;
}



##### (NB) This is not currently an object, nor is it called like one
# We're simply passing the MTM::TTSToken object for development purposes.
sub postag {

	my $tobj = shift; # The token object
	##### (TODO) These are switches that will be moved out to the 
	#            object 1st, and then added to the general configuration 
	#            framework.
	my $text_mode   = 'preproc'; # Can also be 'analyse'
	my $tagger_mode = 'preproc'; # NB! check what the other possibilities are!

	#***********************************************************************#
	#
	# These are working variable - we'll swap them out for
	# a work hash in preparation for a POSTAG object.
	#
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
	#
	#***********************************************************************#

	#***********************************************************************#
	# 
	# This segment contains additions that implement funcitonality in the 
	# original codebase differently
	#
	# The original codebase points to the orthografic word using an index $i
	# into the array that it works over. Here, we work over omne word at 
	# time, so we replace all instances of $string[$i] with that one string
	my $orth = $tobj->{LEGACYDATA}->{orth};
#	die $orth; ##### (NB) This is where we're at - add whitespace detection here
	# 
	# The original codebase separates out whitespace before this step and 
	# treats it separately. Here and for now, we identify it, label it as 
	# whitespace, and return it.
	#


	#***********************************************************************#
	# 1. Find all possible tags for the token.
	#***********************************************************************#
	my $res;

	if ($res = is_startend($orth)) {
#	print STDERR "startend\n";
	}
	elsif ($res = is_whitespace($orth)) {
#		print STDERR "whitespace\n";
	}
	elsif ($res = is_numeral($orth)) {
#		print STDERR "numeral\n";
	}
	elsif ($res = is_dash($orth)) {
#		print STDERR "dash\n";
	}

	##### CT 2021-06-10 Can't use string ("KW") as a HASH ref while "strict refs" in use at lib/MTM/TPBTag.pm line 280, <$fh> line 2.
	#elsif ($res = is_num_colon_s($orth)) {
#	#	print STDERR "num_colon_s\n";
	#} 
	else {
		my $new_orth = modify_case($orth);
		$res = possible_tags($new_orth);
	}
# JE Dum spårkod för bugglet
	use Data::Dumper;
	#print "$orth\n";
	#print Dumper $res;
#	#<>;
	foreach my $k (keys %$res) {
		$tobj->{LEGACYDATA}->{$k} = $res->{$k};
	}
	return 1;
}
#***************************************************************************#
#
# These are tests sequential tests taken from the first stage of PosTag
#
##### (NB) Check if needed/useful, else remove
# This probably does not hit, ever, with the new codebase
# Whys is '$__' not handled here? Bug? Is used?
sub is_startend {
	my $orth = shift;
	my $res;
	if ( $orth eq '__$' ) {
		$res->{PT}         = $orth;
		$res->{PossibleTags} = [ 'FE' ];		# CT 160509

		$res->{maxProbTag} = '__$';
		$res->{maxProb} = 1.0;
		$res->{tagConf} = 'KW';

		return $res;
	}
	return 1;
}
#
sub is_whitespace {
	my $orth = shift;
	my $res;
	if ( $orth =~ m/^\s+$/ ) {
		$res->{WHITESPACE}         = 1;

		# CT 2020-11-18 Insert values for tagger
		$res->{PossibleTags} = [ 'DEL' ];
		$res->{maxProbTag} = 'DEL';
		$res->{maxProb} = 1.0;
		$res->{tagConf} = 'KW';
		return $res;
	}
	return 1;
}
#
sub is_numeral {
	my $orth = shift;
	my $res;
	if ( $orth =~ /\d/ && $orth =~ /^[\d\.\, ]+$/ ) {

		$res->{PossibleTags} = [ 'MC00N0S' ];
		$res->{maxProbTag} = 'MC00N0S';
		$res->{maxProb} = 1.0;
		$res->{tagConf} = 'KW';

		return $res;
	}
	return 1;
}
#
sub is_dash {
	my $orth = shift;
	my $res;
	if ( $orth =~ /^(–|-)$/ ) {
		$res->{PossibleTags} = [ 'FI' ];
		$res->{maxProbTag} = 'FI';
		$res->{maxProb} = 1.0;
		$res->{tagConf} = 'KW';

		return $res;
	}
	return 1;
}
#
sub is_num_colon_s {
	my $orth = shift;
	my $res;
	if ( $orth =~ /^\d+(:?s)$/i ) {
		$res->{PossibleTags} = [ 'MC00N0S' ];
		$res->{maxProbTag} = 'MC00N0S';
		$res->{maxProb} = 1.0;
		$res->{tagConf} = 'KW';
	}
	return 1;
}
sub modify_case {
	my $orth = shift;
	my $original_orth = $orth;

	# Upper-/lowercase word until found in lexicon.
	#use Data::Dumper;
	#print Dumper \%MTM::Legacy::Lists::p_wordtags; die;
	##### (NB) CT/JE Fix the case changes here to not leave ucfirst when nothing is found. CT: done.
	if (
		!( exists ( $MTM::Legacy::Lists::p_wordtags{ $orth } ) )
		&&
		!( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $orth } ) )
	) {

		# Lowercase
		$orth = &MTM::Case::makeLowercase( $orth );
		$orth =~ s/-$//;

		if (
			!( exists ( $MTM::Legacy::Lists::p_wordtags{ $orth } ) )
			&&
			!( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $orth } ) )
		) {
			# JE: CT also, shold no-hits be flagged here?
			# Uppercase first
			$orth = ucfirst( $orth ); 

			if (
				!( exists ( $MTM::Legacy::Lists::p_wordtags{ $orth } ) )
				&&
				!( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $orth } ) )
			) {
				# JE: CT also, shold +-hits be flagged here?

				# CT 20-11-12 Return original orthography if no match.
				$orth = $original_orth;
			}
		}
	}
	return $orth;
}

#******************************************************************#
# Find all possible tags for the word
#******************************************************************#
sub possible_tags {
	my $orth = shift;	# In the case that first hit in hash.
	my $res;
	my (@PT, @PT2, %PT2);
	my $found;

	# Get possible tags
	if ( exists ( $MTM::Legacy::Lists::p_wordtags{ $orth } ) ) {
		my $PT = $MTM::Legacy::Lists::p_wordtags{ $orth };
		@PT = split/\t/,$PT;

		# Remove duplicates in tag list and lookup unigram probabilities.
		foreach my $pt ( @PT ) {
			unless ( exists ( $PT2{ $pt } ) ) {
				push @PT2,$pt;
				$PT2{ $pt }++;

				# Lookup probability for each $orth\t$tag key.		
				my $key = "$orth\t$pt";

				if( exists( $MTM::Legacy::Lists::p_wordprob{ $key } )) {
					#print "\nPROB PRIO $key\t$MTM::Legacy::Lists::p_wordprob{ $key }\n\n";
					$res->{UnigramProb}{$pt} = $MTM::Legacy::Lists::p_wordprob{ $key };
				}			
			}
		}
		$found = 1;

	} 

	# 080228 Use backup lexicon only if word not found in priority lex.
	if ( $#PT2 < 1 ) {
		if ( exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $orth } ) ) {
			my $PT = $MTM::Legacy::Lists::p_backup_wordtags{ $orth };
			@PT = split/\t/,$PT;

			foreach my $pt ( @PT ) {
				unless ( exists ( $PT2{ $pt } ) ) {
					push @PT2,$pt;
					$PT2{ $pt }++;

					# Lookup probability for each $orth\t$tag key.		
					my $key = "$orth\t$pt";

					if( exists( $MTM::Legacy::Lists::p_backup_wordprob{ $key } )) {
						#print "\nPROB BACKUP $key\t$MTM::Legacy::Lists::p_backup_wordprob{ $key }\n\n";
						$res->{UnigramProb}{$pt} = $MTM::Legacy::Lists::p_backup_wordprob{ $key };
					}			
				}
			}
			$found = 1;
		}
	}


	# Tag with UNKNOWN if not found in p lists.
	unless ( $found ) {
		push @PT2,'UNKNOWN';
	}

	$res->{found} = $found;

	# CT 2020-11-12 This info is also in $res->{UnigramProb}, not necessary to keep $res->{PossibleTags}-
	$res->{PossibleTags} = [join"\t",@PT2];
	return $res;
}
#******************************************************************#
# Tag Words
#******************************************************************#
sub TagWords {

	my( $text_mode, @string )  = @_;

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
	# JE 2020-11-11 This loop is not needed anymore, but pay attention 
	#               to where $i is used! 
	foreach my $i (0 .. $#string){ 

		my $found = 0;

		@PT2 = ();
		@PT = ();
		%PT2 = ();

		# Start & end
		if ( $string[ $i ] eq '__$' ) {
			push @PT,$string[ $i ];
			push @WordList,$string[ $i ];
			$PossibleTags[ $i ] = 'FE';		# CT 160509

		# Numerals
		} elsif ( $string[ $i ] =~ /\d/ && $string[ $i ] =~ /^[\d\.\, ]+$/ ) {
			$PossibleTags[ $i ] = 'MC00N0S';
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


		} else {

			my $WordNow = $string[ $i ];

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

			# 080228 Use backup lexicon only if word not found in priority lex.
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


#			# GENITIVE check
#			} elsif ( $WordNow =~ /s$/ ) {
#
#				$WordNow =~ s/[\'\:]?s$//;
#				($maxProb,$maxProbTag) = &KnownWord($WordNow,$PrevTag,$i,\@string,\@bestTag,\@prob);
#				$tagConf = 'GW';
#		
#			}

			# UNKNOWN word
			if ( $found == 0 ) {
				push @PT2,'UNKNOWN';
			}

			$PossibleTags[ $i ] = join"\t",@PT2;



		} # end if '__$'

	} # end foreach @string
##### JE HERE NOW - but lookups are not working properly. fix before next bit

	#*************************************************************************#
	# Tag
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

		# Numerals		# 080129 Added ' ' (2 000)
		} elsif ( $string[ $i ] =~ /\d/ && $string[ $i ] =~ /^[\d\.\, ]+$/ ) {
			$maxProb = 1.0;
			$maxProbTag = 'MC00N0S';
			$tagConf = 'KW';


		# Dash	
		} elsif ( $string[ $i ] =~ /^(–|-)$/ ) {
			$maxProb = 1.0;
			$maxProbTag = 'FI';
			$tagConf = 'KW';


		} else {

			# If word exists in lexicon (as is)
			if (
				exists ( $MTM::Legacy::Lists::p_wordtags{ $WordNow } ) 
				||
				exists ( $MTM::Legacy::Lists::p_backup_wordtags{ $WordNow } ) 
			) {

#				print "FINNS: $WordNow\t$MTM::Legacy::Lists::p_wordtags{ $WordNow }\n";

				my $jo = 0;
				foreach my $x (@PossibleTags) {
#					print "HOHO\t$string[$jo]\t$x\n";
					$jo++;
				}

#				print "$string[$i]\t$PossibleTags[ $i ]\n";

				($maxProb,$maxProbTag) = &KnownWord($WordNow,$PrevTag,$i,\@string,\@bestTag,\@prob,\@PossibleTags);
				$tagConf = 'KW';

			# GENITIVE check
			} elsif ( $WordNow =~ /s$/ ) {

				$WordNow =~ s/[\'\:]?s$//;
				($maxProb,$maxProbTag) = &KnownWord($WordNow,$PrevTag,$i,\@string,\@bestTag,\@prob,\@PossibleTags);
				$tagConf = 'GW';

			}

			# UNKNOWN word
			if ( $maxProb eq '0' ) {
#				print "NUNUNU $string[ $i ]\t$PossibleTags[$i]\n\n";
				($maxProb,$maxProbTag) = &UnknownWord($i,\@string,\@bestTag,\@prob,$PrevTag,\@PossibleTags,$text_mode);
				$tagConf = 'UW';

#				print "MP $maxProb\t\t$maxProbTag\t$string[$i]\n";
			}

		} # end if '__$'

		$PrevTag = $maxProbTag;

		# 080512 PoS-tags not accepted by SPARK parser.
		$maxProbTag =~ s/NCUS0\@IC$/NCUS0\@0S/;
		$maxProbTag =~ s/NC000\@0C$/NCUS0\@0S/;

		# 080829	Error somewhere.
		$maxProbTag =~ s/MOMSN0S/MOMSNDS/;

		push @prob,$maxProb;
		push @bestTag,$maxProbTag;
		push @TagConf,$tagConf;

	#	print "\nMP $maxProb\t\t$maxProbTag\t$string[$i]\n";
	#	print "III $TagConf[ $i ]\t$bestTag[ $i ]\t$string[ $i ]\n";

		dbg("\t\tMAX = $maxProb\n");
		dbg("\t\tTAG = $maxProbTag\n")
	} # end i loop

	return (\@bestTag,\@prob,\@TagConf);
}
#******************************************************************#
# Known words
#******************************************************************#
sub KnownWord {

	my ($WordNow,$PrevTag,$i,$string,$bestTag,$prob,$PossibleTags) = @_;

	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;
	my @PossibleTags = @$PossibleTags;

#	print "PPPP $WordNow\t@PossibleTags\n";

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

#	print "$string[ $i ]\t@PossTags\n";

	my $PossTagsCheck = join"|",@PossTags;

	foreach my $PossTag ( @PossTags ) {

		my $factor1 = 0.0;
		my $factor2 = 0.0;

		my $WordTag = "$WordNow\t$PossTag";
#			print "TAGGAR\n";
		print $TAGOUT "\t-----------------------\n\t\tWT: $WordTag\n";
#		print "\t\t\tWT: $WordTag\n";

		#print "PPP $WordTag\tPossTags: @PossTags\n";


		my $ttest = 'banan';

		# Unigram tags
		if ( exists ( $MTM::Legacy::Lists::p_wordprob{ $WordTag } ) ) {
			$factor1 = $MTM::Legacy::Lists::p_wordprob{ $WordTag };

			#print "OOIUY $WordTag\t$factor1\n";

		} elsif ( exists ( $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag } ) ) {
			$factor1 = $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag };

			# Lower $factor1 if taken from backup lexicon	080828
			$factor1 *= 0.5;

#			print "2 $WordNow\t$WordTag\t$factor1\n\n";

		} else {
			$factor1 = 0.0;
		}

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
		#print "BI $Bigram\tTRI $Trigram\n";

		chomp $factor1;
		chomp $factor2;

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
		print $TAGOUT "\t\ttmpProb before rules: $tmpProb\n";

		# Get $PossTags for next word.
		my $NextPossTags = 'UNKNOWN';
		my $NextPossTags2 = 'UNKNOWN';
		if ( $i != $#string ) {
			$NextPossTags = $PossibleTags[ $i+1 ];
			if ( $i != $#string-1 ) {
				$NextPossTags2 = $PossibleTags[ $i+2 ];
			}
		}

		#print SCANDEBUG "\n$WordNow\t";
		#print SCANDEBUG "@string\n";
		#print SCANDEBUG "$NextPossTags ---\n";
		#print SCANDEBUG "$NextPossTags2 ---\n";
		#print SCANDEBUG "1. $PossibleTags[ $i+1 ]\n";
		#print SCANDEBUG "2. $PossibleTags[ $i+2 ]\n\n";


		if ( $WordNow =~ /^[ivx]+(:?s)$/i ) {
			$tmpProb = 100;
			$PossTag = 'MO00G0S';
		}


		# en en	--> DT NN
		if ( $WordNow =~ /^en$/i && $string[ $i-1 ] =~ /^en$/ && $PossTag =~ /^N/ ) {
			$tmpProb =~ s/^0$/0.1/;
			$tmpProb *= 1000;
		}


		# förlåt NN --> VB/IN			080925
		if ( $WordNow =~ /^förlåt$/i && $PossTag =~ /^[VI]/ && $string[ $i ] !~ /^en$/i ) {
			$tmpProb *= 100;
		}

		# utan VB --> KN			080901
		if ( $WordNow =~ /^utan$/i && $PossTag eq 'CCS' && $NextPossTags =~ /V\@/ ) {
			$tmpProb *= 100;
		}

		# för att långsiktigt fördjupa --> AB	080902
		#if ( $PossTag =~ /^RG/ && $NextPossTags =~ /V\@/ ) {
		#	$tmpProb *= 100;
		#}

		# många	VB --> PN			080828
		if ( $WordNow =~ /^många$/i && $PossTag eq 'PI@0P0@S' && $NextPossTags =~ /V\@/ ) {
			$tmpProb *= 100;
		}

		# man NN --> PN				080829
		if ( $WordNow =~ /^man$/i && $PossTag =~ /^PI/ && $PrevTag !~ /(?:^|_)DI/ ) {
			$tmpProb *= 100;
		}

		# vi					080829
		if ( $WordNow =~ /^vi$/i && $PossTag =~ /^PF/ ) {
			$tmpProb *= 100;
		}

		# har/hade lyft --> SUP			080828
		if ( $PossTag =~ /^V\@IU/ && $string[ $i-1 ] =~ /^(har|hade)$/i ) {
			$tmpProb *= 100;
		}

		# var imponerade		080828
		if ( $PossTag =~ /^AF/ && $PrevTag =~ /^V/ && $string[ $i-1 ] !~ /^(har|hade)$/i ) {
			$tmpProb *= 100;
		}


		# One possible tag is proper name and the word starts with uppercase letter - degrade other PoSes.
		# Not if first word in sentence.
		if ( $PossTagsCheck =~ /(?:^|\|)NP/  && $WordNow =~ /^[A-ZÅÄÖ]/ && $PossTag !~ /^NP/ && $i != 1 ) {
			$tmpProb *= 0.01;
		}


		# mr, miss, mrs X
		if ( $PossTag =~ /^NP/ && $string[ $i-1 ] =~ /^(?:mr|miss|mrs)$/i ) {
			$tmpProb *= 100;
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

		# Hans	--> pronoun if first in sent.
		# 080910 Not if next word could be proper noun.
		if ( $WordNow eq 'Hans' && $i == 1 && $PossTag =~ /^NP/ && $NextPossTags !~ /\bNP/ ) {
			$tmpProb *= 0.01;
		}

		# Hans --> pm	if followed by PM or initial				CT 110113
		if ( $WordNow eq 'Hans' && ( $string[$i+1] =~ /^[A-Z]$/|| $NextPossTags =~ /\bNP/ ) )  {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		}

		# Mats --> always PM		CT 110113
		if ( $WordNow eq 'Mats' ) {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		}


		# Vi
		if ( $i == 1 && $string[ $i ] eq 'Vi' && $PossTag =~ /^NP/ ) {
			$tmpProb *= 0.01;
		}

		# Din, min			CT 100421	added "min"
		if ( $string[ $i ] =~ /^[dm]in$/i && $PossTag =~ /^NC/ ) {
			$tmpProb *= 0.01;
		}


		# min NN			CT 100428
		if ( $WordNow =~ /^min$/ && $PossTag =~ /^PS/ && $NextPossTags =~ /\bNC/ ) {
			$tmpProb = 100;
		}

		# JJ min __$ --> NN		CT 100826
		if ( $WordNow =~ /^min$/i && $PossTag =~ /^N/ && $PrevTag =~ /^A/ && $string[ $i+1 ] eq '.' ) {
			$tmpProb = 100;
		}

		# min PS			CT 100819	en min, sur min, sura min,
		if ( $WordNow =~ /^min$/ && $PossTag =~ /^N/ && $string[ $i-1 ] =~ /^(?:en|sura|sur)$/i ) {
			$tmpProb = 100;
		}

		# dom				CT 100819	är det dom?		CT 100907	något otalt mellan dom
		if ( $WordNow =~ /^dom$/i && $string[ $i-1 ] =~ /^(det|mellan|andra|hade)$/i ) {
			$tmpProb = 100;
		}

		# Pronoun / determiner
		# Pronoun if next word is a verb or pronoun.
		if ( $PossTagsCheck =~ /(?:^|\|)DF/  && $NextPossTags =~ /(?:^|\t)(?:V|PF)/ && $PossTag =~ /^PF/ ) {
			$tmpProb *= 100;

		# Determiner if next word is a noun or adjective.				080901 Added !~ /V\@/
		} elsif ( $WordNow =~ /^(de[nt])$/i && $PossTag =~ /^D/ && $NextPossTags =~ /(?:^|\t)[NA]/ && $NextPossTags !~ /V\@/ ) {
			$tmpProb *= 100;
		}

		# Homograph: sen,
		if ( $WordNow =~ /^sen$/i && $PossTag =~ /^AQ/ ) {

			# en sen NN
			if ( $i != 0 && $string[$i-1] =~ /^en$/i && $NextPossTags =~ /NC/ ) {
				$tmpProb *= 100;

			# var sen att, inte sen att
			} elsif ( $i != 0 && $i != $#string && $string[ $i-1 ] =~ /^(var|vara|varit|inte)$/i && $string[ $i+1 ] =~ /^att$/ ) {
				$tmpProb *= 100;

			# eller sen JJ
			} elsif ( $PrevTag =~ /^CCS/ && $NextPossTags =~ /^AQ/ ) {
				$tmpProb *= 100;
			}

		}
		if ( $WordNow =~ /^sen$/i && $PossTag !~ /^AQ/ ) {
			# sen VB
			if ( $i != $#string && $NextPossTags =~ /V\@/ ) {
				$tmpProb *= 100;
			}
		}	


		# Homograph: parad, next word is 'med'			080915
		if ( $WordNow =~ /^para[dt]$/i && $string[ $i+1 ] =~ /^med$/i && $PossTag =~ /^AF/) {
			$tmpProb *= 100;
		}


#		print "$WordNow\t$NextPossTags\t$PossTag\n";
		# Homograph: modern, next PoS is possibly N*			080131
		# 080910 Removing && $PrevTag =~ /^SPS/ 
		# modern en
		# added RC=UNKNOWN-->JJ						CT 100826
		if ( $WordNow =~ /^modern$/i && $PossTag =~ /^N/ && $string[ $i+1 ] eq 'en' ) {
			$tmpProb *= 1000;
		} elsif ( $WordNow =~ /^modern$/i && $PossTag =~ /^N/ && $string[ $i+1 ] eq 'till' ) {
			$tmpProb *= 1000;
		} elsif ( $WordNow =~ /^modern$/i && $PossTag =~ /^N/ && $string[ $i+1 ] =~ /^(?:är|var|har|hade)$/i ) {		# CT 100824 copula
			$tmpProb *= 1000;
		} elsif ( $WordNow =~ /^modern$/i && $NextPossTags =~ /(?:^|\t)(?:N|UNKNOWN)/ && $string[ $i+1 ] !~ /klarat$/i && $PossTag =~ /^AQ/ ) {	# CT 100907 added klarat$
			$tmpProb *= 100;
		}

#		print "$WordNow\t$PossTag\t$string[ $i-1 ]\t$PrevTag\n\n";

		# Homograph: kort, next PoS is possibly N* --> JJ		080915
		# kort --> JJ if next word is för or alltför or om		100721
		# kort --> JJ if previous word is AB or PN or var		100824
		# kort --> JJ if next word is KN and the next JJ		110225
		# PP kort PP --> NN						121128
		if ( $WordNow =~ /^kort-?$/i ) {

			if ( $string[ $i+1 ] =~ /^och$/i && $NextPossTags2 =~ /(^|\t)AQ/ ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# Kort om boken
			# CT151015 added e.g. 'efter', 'efteråt' and 'dessförinnan'
			} elsif ( $string[ $i+1 ] =~ /^(om|efter|efteråt|dessförinnan|därpå|.*tid|.*ning|.*period|duration|sagt|beskr[ie]v*?|\d)$/i ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# med kort i
			} elsif (
				( $PrevTag =~ /^SPS/ || $string[ $i-1 ] =~ /^ett$/i )
				&&
				$string[ $i+1 ] =~ /^(med|i|på|till)$/i
			) {
				if ( $PossTag =~ /^N/ ) {
					$tmpProb *= 100;
				}

		
			# ett nytt kort		CT151015
			} elsif ( $PrevTag =~ /^(?:AQPNSNIS|RGPS|AQP0PN0S)$/ ) {
				if ( $PossTag =~ /^N/ ) {
					$tmpProb *= 100;
				}

			} elsif ( $NextPossTags =~ /(?:^|\t)(?:N|AQ)/ || $string[ $i-1 ] =~ /^(?:(?:allt)?för|var)$/i || $PrevTag =~ /^(?:RG|PD)/ ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;

				}

			# CT 100907	sa han kort.
			} elsif ( $PrevTag =~ /^P[IDF]/ ) {

				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# den är kort	CT151019
			} elsif ( $string[ $i-2 ] =~ /^den$/ && $string[ $i-1 ] =~ /^är$/i ) {

				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# kort, fjällig svans	CT151015
			} elsif ( $NextPossTags eq 'FI' && $NextPossTags2 =~ /AQ/ ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# Gjorde processen kort		CT151015
			} elsif ( $string[ $i-1 ] =~ /^(?:processen|livet|blev|tittade|inom|extremt|i|blivit)$/i ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# kort och blodigt		CT1510015
			} elsif ( $string[ $i+1 ] =~ /^och$/ && $NextPossTags2 =~ /(?:AQ|RG)/ ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# är kort.			CT151015
			} elsif ( $string[ $i-1 ] =~ /^(?:vara|var|varit|är|bli|blir|blev)$/i && $NextPossTags =~ /F[IEP]/ ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			# kort eller lång		CT151015
			} elsif ( $string[ $i+1 ] =~ /^(?:och|eller|som)$/i && $string[ $i+2 ] =~ /^lång/i ) {
				if ( $PossTag =~ /^AQ/ ) {
					$tmpProb *= 100;
				}

			} elsif ( $PossTag =~ /^N/ ) {			# CT 100511	noun
				$tmpProb *= 100;
			}
		}


		# Homograph: ovan
		# ovan vid		CT151015
		if ( $WordNow =~ /^ovan$/i ) {
			if ( $string[ $i+1 ] =~ /^vid$/i && $PossTag =~ /^AQ/ && $string[1] !~ /^se$/i ) {
				$tmpProb *= 1000;
			}
		}


#		# Homograph: stegen
#		# de viktigaste stegen		CT151015
#		if ( $WordNow =~ /^stegen$/i ) {
#			if ( $string[ $i-2 ] =~ /^de$/i && $PossTag =~ /^AQ/ && $string[1] !~ /^se$/i ) {
#				$tmpProb *= 1000;
#			}
#		}


		# Homograph: karl
		if ( $WordNow =~ /^Karl$/ ) {
			# och Karl Mannheim		CT151016
			if ( $string[ $i+1 ] =~ /^[A-ZÅÄÖ]/ ) {
				$PossTag = 'NP00N@0S';
				$tmpProb *= 1000;

			# Popper, Karl (1992).		CT151019
			} elsif ( $PrevTag =~ /^FI/ && $string[ $i-2 ] =~ /^[A-ZÅÄÖ].+$/ ) {
				$PossTag = 'NP00N@0S';
				$tmpProb *= 1000;
			}

		}
		# Homograph: rest
		# kvarvarande rest		CT151015
		if ( $WordNow =~ /^rest$/i ) {
			if ( $PrevTag =~ /^(?:AQ|AP)/ && $PossTag =~ /^N/ ) {
				$tmpProb *= 1000;
			}
		}

		# Homograph: rykte
		# dåligt rykte		CT151015
		if ( $WordNow =~ /^rykte$/i ) {
			if ( $string[ $i-1 ] =~ /^(?:dåligt|gott|bättre|sämre|detta)$/i && $PossTag =~ /^NC/ ) {
				$tmpProb *= 1000;
			}
		}

		# Homograph: skott
		# hade skott sig på	CT151015
		if ( $WordNow =~ /^skott$/i ) {
			if ( $string[ $i+1 ] =~ /^(?:mig|dig|sig|oss)$/ ) {
				$PossTag = 'AF0NSNIS';
				$tmpProb = 100;
			}
		}

		# Homograph: bärs
		# eller bärs upp av	CT151015
		if ( $WordNow =~ /^bärs$/i ) {
			if ( $string[ $i+1 ] =~ /^(?:upp|nära)$/i && $PossTag =~ /^V/ ) {
				$tmpProb *= 100;
			}
		}

		# Homograph: delta
		# stora delta		CT151015
		if ( $WordNow =~ /^delta$/i ) {
			if ( $PrevTag =~ /^AQ/ ) {
				$PossTag = 'NCNSN@IS';
				$tmpProb *= 1000;
			}
		}

		# Homograph: andra, prev PoS is V*				080131
		if ( $WordNow =~ /^andras?/i && $PrevTag =~ /V\@/ && $PossTag =~ /^AQ/ ) {
			$tmpProb *= 10000;

		# andras NN
		} elsif ( $WordNow =~ /^andras?/i && $i != $#string && $NextPossTags =~ /NC/ ) {
			$tmpProb *= 10000;
		}

		# att --> IE/SN							080827
		if ( $WordNow =~ /^att$/i && $PossTag eq 'CIS' ) {

			my $INF_seen = 0;
			my $VB_seen = 0;

			# Check if closest following verb is possibly INF
			if ( $i != $#string ) {
				my $m = 0;
				foreach my $pt ( @PossibleTags ) {
					if ( $m > $i && $pt =~ /V\@/ && $VB_seen == 0 ) {	# Closest following verb not yet seen
						$VB_seen = 1;

#						print "PPP $WordNow\t_\t$string[$m]\t$pt\n";
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

		}

		# fördelar PP --> NN					CT 100826
		if ( $WordNow =~ /^fördelar$/i && $PossTag =~ /^N/ && $NextPossTags =~ /(^|\t)SPS/ ) {
			$tmpProb *= 100;
		}

		# kön								090303
#		if ( $WordNow =~ /^kön$/i && $PrevTag !~ /SPS/ && $PossTag eq 'NCNSN@IS' ) {
		# kön --> /tj 'ö2: n/ alltid		NCNSN@IS		CT 101014
		if ( $WordNow =~ /^kön$/i && $PossTag eq 'NCNSN@IS' ) {
			$tmpProb *= 100;
		}

		# homograph: kön
		if ( $WordNow =~ /^kön$/i ) {

			# i kön				CT151015
			if ( $string[ $i-1 ] =~ /^i$/i ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;

			# JJ POS UTR SIN IND NOM kön	CT151015
			} elsif ( $PrevTag eq 'AQPUSNIS' ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;

			} elsif ( $string[ $i+1 ] =~ /^till$/i && $string[ $i+2 ] =~ /^(?:snabbköps)kassan$/i ) {
				$PossTag = 'NCUSN@DS';
				$tmpProb *= 1000;
			}		

		}

		# homograph: svalt
		if ( $WordNow =~ /^svalt$/i ) {

			# svalt en cigarett	CT151015
			if (
				$string[ $i+1 ] =~ /^(?:en|ett)$/i
				||
				$string[ $i-1 ] =~ /^har$/i
			) {
				$PossTag = 'V@IUAS';
				$tmpProb *= 1000;

			# Duscha svalt		CT151015
			} elsif (
				$PrevTag =~ /^V/
				&&
				$PossTag =~ /^AQ/
			) {
				$tmpProb *= 1000;
			}
		}

		# homograph: bete
		# bete sig	CT151015
		if ( $WordNow =~ /^bete$/i ) {
			if ( $string[ $i+1 ] =~ /^(?:mig|dig|sig|oss|er)$/i && $PossTag =~ /^V/ ) {
				$tmpProb *= 1000;
			}
		}


		# rosa VB --> JJ			090324
		if ( $WordNow =~ /^rosa$/i && $PossTag =~ /^AQ/ && $PrevTag =~ /^PF/ ) {
			$tmpProb =~ s/^0$/0.1/;
			$tmpProb *= 100;
		}

		# fars NOM --> GEN			090324
		if ( $WordNow =~ /^fars$/i && $PossTag =~ /^NCUSG/ && $NextPossTags =~ /NC/ ) {
			$tmpProb =~ s/^0$/0.1/;
			$tmpProb *= 100;
		}

		# son DEF --> IND			090326
		if ( $WordNow =~ /^son$/i && $PossTag =~ /\@IS/ ) {
			$tmpProb *= 100;
		}

		# rivet NN/AQ
		if ( $i == 1 && $PossTagsCheck =~ /(AQ.+\|NC|NC.+\|AQ)/ && $PossTag =~ /^AQ/ && $NextPossTags =~ /NC/ ) {
			$tmpProb *= 100;
		}

		# Tom JJ/PM				CT 100421
		if ( $WordNow =~ /^Tom$/ && $i != 0 ) {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		}

		# PN tomt				CT 100423
		if ( $WordNow =~ /^tomt$/i && $PrevTag =~ /^P/ && $PossTag =~ /^NC/ ) {
			$tmpProb *= 100;
		}

		# tomt --> JJ				CT 100824	"tomt" alone
		if ( $WordNow =~ /^tomt$/i && $PossTag =~ /^AQ/ && $i == 1 ) {
			if ( $i == $#string-1 || $i == $#string-2 ) {
				$tmpProb *= 100;
			}
		}

		# drog	NN/VB				CT 100421
		if ( $WordNow =~ /^drog$/i && $PossTag =~ /^V/ && $NextPossTags =~ /(^|\t)P/ ) {
			$tmpProb *= 100;
		}


		# PN/DT parad				CT 100423
		if ( $WordNow =~ /^parad$/i && $PrevTag =~ /^[PD]/ ) {
			$PossTag = 'NCUSN@IS';
			$tmpProb = 100;
		}


		# kör					CT 100423	CT 110113	$PrevTag changed to ^D (was ^A)
		if ( $WordNow =~ /^kör$/i && $PossTag =~ /^V/ && $PrevTag !~ /^D/ ) {
			$tmpProb *= 100;
		}

		# print "I $WordNow\t$PossTag\t$PrevTag\n";
		# i kör --> NN				CT 120812
		if ( $WordNow =~ /^kör$/i && $PossTag =~ /^N/ && $PrevTag =~ /^SP/ ) {
			$tmpProb *= 100;
		}

		# syntes - det syntes --> VB		CT 100428
		# CT 100819	NN syntes --> VB
		if ( $WordNow =~ /^syntes$/i && $PossTag =~ /^V/ && $PrevTag =~ /^[PDN]/ ) {
			$tmpProb *= 100;
		}

		# fördelar sig --> VB			CT 100714
		if ( $WordNow =~ /^fördelar$/ && $string[ $i+1 ] =~ /^sig$/i && $PossTag =~ /^V/ ) {
			$tmpProb *= 100;
		}

		# nu --> AB				CT 100716
		if ( $WordNow =~ /^nu$/i && $PossTag =~ /^RG/ ) {
			$tmpProb = 100;
		}

		# var __$ --> AB			CT 100722
		if ( $WordNow =~ /^var$/ && $string[ $i+1 ] eq '__$' ) {
			$PossTag = "RG0S";
			$tmpProb = 100;
		}

# CT 100819	"ögonen var döda" doesn't work
#		# var + VB --> AB			CT 100722
#		if ( $WordNow =~ /^var$/ && $NextPossTags =~ /(^|\t)V/ ) {
#			$PossTag = "RG0S";
#			$tmpProb = 100;
#		}

		# vi och dom --> PN			CT 100817
		if ( $WordNow =~ /^dom$/i && $string[ $i - 2 ] =~ /^vi$/i && $string[ $i-1 ] =~ /^och$/i ) {
			$PossTag = 'PD@0PO@S';
			$tmpProb = 100;
		}

#	print "$WordNow\t$NextPossTags\t$PossTag\n";

#		# dom PC				CT 100819		dom levande
#		if ( $WordNow =~ /^dom$/i && $NextPossTags =~ /(^|\t)A[FPQ]/ && $PossTag =~ /^P/ ) {
#			print "JO\n";
#			$tmpProb = 100;
#		}

		# !~ en	dom				CT 100819
#		if ( $WordNow =~ /^dom$/i && $PossTag =~ /^P/ && $string[ $i-1 ] !~ /^en$/i ) {
#			$tmpProb = 100;
#		}

		# dom					CT 100831
		if ( $WordNow =~ /^dom$/i && $string[$i-1] =~ /^(?:domstols|TR:s|vars|tingsrättens)/ && $PossTag =~ /^N/ ) {
			$tmpProb = 1000;
		}

		# homograph: läst
		if ( $WordNow =~ /^läst$/ ) {

			# ha läst --> VB			CT 100817
			# en läst berättelse			CT 151015
			if (
				$string[ $i-1 ] =~ /^ha$/i
				||
				$NextPossTags =~ /NC/
				||
				$string[ $i+1 ] =~ /^(?:om|på|in)$/i
			) {
				$PossTag = 'V@IUAS';
				$tmpProb = 100;
			} 
		}

		# stans	--> NN				CT 100819
		if ( $WordNow =~ /^stans$/i && $PossTag =~ /^N/ && $string[ $i-1 ] =~ /^(hos)$/i ) {
			$tmpProb = 100;
		}

		# fint --> JJ				CT 100819
		if ( $WordNow =~ /^fint$/i && $PossTag =~ /^[A]/ && $string[ $i-1 ] !~ /^en$/i ) {
			$tmpProb = 100;
		}

		# mors --> NN					CT 100819
		if ( $WordNow =~ /^mors$/i && $PossTag =~ /^N/ && $NextPossTags =~ /(^|\t)N/ ) {
			$tmpProb = 100;
		}

		# taget --> NN					CT 100830
		if ( $WordNow =~ /^taget$/i && $PossTag =~ /^N/ && $PrevTag =~ /^V/ ) {
			$tmpProb = 100;
		}

		# Japan - japan, Japans - japans
		if ( $WordNow =~ /^Japans?$/ && $PossTag =~ /^NP/ ) {
			$PossTag = 'NP00N@0S';
			$tmpProb = 100;
		}


	#***********************************************************************************************************#		


		print $TAGOUT "\t\ttmpProb: $tmpProb\n\n";

		if($tmpProb >= $maxProb){
			$maxProb = $tmpProb;
			$maxProbTag = $PossTag;
		}

	} # end @PossTags

	# All probs are 0.0 - use max unigram.
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

#	print "MMMMPPPP $maxProb\t\t$string[ $i ]\n";

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


	print $TAGOUT "\t\tUNKNOWN: $string[ $i ]\n";
	# print "\t\tUNKNOWN: $string[ $i ]\n";

	#while(my($k,$v) = each(%multiword_tag)) { print "K $k\t$v\n"; }

	# Multiword check			080828
	if ( exists( $MTM::Legacy::Lists::multiword_tag{ $string[ $i ]} )) {
		$maxProb = 1;
		$maxProbTag = $MTM::Legacy::Lists::multiword_tag{ $string[ $i ]};
		$maxProbTag =~ s/\t+.*$//;
		$maxProbTag = $MTM::Legacy::Lists::s2p{ $maxProbTag };		# Convert from SUC to Parole tags
	}

	# Changed place with name check	CT 120119
	if ( $maxProb == 0 ) {
		# Suffix check
		( $maxProb, $maxProbTag ) = &SuffixProb($i, $string, $bestTag, $prob, $PrevTag, $PossibleTags);
	}


	# Name check
	if ( $maxProb == 0 ) {
		( $maxProb, $maxProbTag ) = &NameCheck($i, $string, $bestTag, $prob, $PrevTag);
	}

# ngrams are checked in the suffix chech sub
#	# ngram check				CT 100408
#	# Possible tags are:	noun, verb, proper name, adjective, adverb
#	$text_mode = 'analyse';
##	print "II $text_mode\n";
#	if ( $maxProb == 0 && $text_mode eq 'analyse' ) {
#		( $maxNgramProb,$maxNgramProbTag ) = &ngramUnknownWord($string[ $i ],$PrevTag,$i,\@string,\@bestTag,\@prob,\@AllPossTags);
##		print "@AllPossTags\n";
##		print "Max ngram Prob: $maxNgramProb\nMax ngram Tag: $maxNgramProbTag\n";
#	}
#
#	if ( $maxProb == 0 ) {
#		# Suffix check
#		( $maxSuffixProb, $maxSuffixProbTag ) = &SuffixProb($i, $string, $bestTag, $prob, $PrevTag, $PossibleTags);
#	}
#
#	# Hur kombinera probbar från ngram och suffix? Förslag: om suffix == 0, sätt till 0,1, multiplicera sedan $maxNgramProb och $SuffixProb.
#	print "SUFF $maxSuffixProb\t$maxSuffixProbTag\n";
#	print "NGRA $maxNgramProb\t$maxNgramProbTag\n";
#
#	if ( $maxSuffixProb >= $maxNgramProb ) {
#		$maxProb = $maxSuffixProb;
#		$maxProbTag = $maxSuffixProbTag;
#	} else {
#		$maxProb = $maxNgramProb;
#		$maxProbTag = $maxNgramProbTag;
#	}

	# If we're dealing with the analysis of the whole text, save the word and its analysis for the tagging of strings.	CT 100408
	if (
		$text_mode eq 'analyse'
		&&
		exists( $MTM::Legacy::Lists::missing_wds{ $string[ $i ] } )
	) {
		$MTM::Legacy::Lists::saved_pos_analysis{ $string[ $i ] } .= "|$maxProb\=$maxProbTag";

	}

	# print "MM $maxProb\t$maxProbTag\t$string[$i]\n";
	return ( $maxProb, $maxProbTag);
}
#******************************************************************#
# ngram check for unknown words
# Works like known words but always start with $factor1 (unigram) as 1
# and uses the list of possible tags for unknown words specified above
# CT 100408
#******************************************************************#
sub ngramUnknownWord {

	my ($WordNow,$PrevTag,$i,$string,$bestTag,$prob,$PossibleTags) = @_;

	my @string = @$string;
	my @bestTag = @$bestTag;
	my @prob = @$prob;
	my @PossibleTags = @$PossibleTags;

#	print "PPPP $WordNow\t@PossibleTags\n";

#	print "Prev $WordNow\t$PrevTag\n";
#	print "Next $string[ $i+1 ]\n";

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
#			print "TAGGAR\n";
		print $TAGOUT "\t-----------------------\n\t\tWT: $WordTag\n";
#		print "\t\t\tWT: $WordTag\n";

#		print "PPP $WordTag\t@PossTags\n";

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

#			print "YES: $Trigram\t$factor2\n";

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

		print $TAGOUT "\t\ttmpProb: $tmpProb\n\n";

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
#	if ( $word =~ /^[A-ZÅÄÖÜÉÈ][A-ZÅÄÖÜÉÈa-zåäöüéè]/ ) {		# 090915 not uppercase only
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

#	print "$string[$i]\t$string[$i+1]\t$maxProb\t$maxProbTag\n";

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
			print $TAGOUT "THIS WORD EXISTS: $CheckWord\n\n";
			#($maxProb,$maxProbTag) = &KnownWord($CheckWord,$PrevTag,$i,\@string,\@bestTag,\@prob,\@PossibleTags);
				my $PossTagsCheck = join"|",@PossibleTags;

				foreach my $PossTag ( @PossibleTags ) {

					my $factor1 = 0.0;
					my $factor2 = 0.0;

					my $WordTag = "$CheckWord\t$PossTag";

					print $TAGOUT "------------\n\t\t\tWT: $WordTag\n";
			#		print "\t\t\tWT: $WordTag\n";

			#		print "PPP $WordTag\t@PossTags\n";

					# Unigram tags
					if ( exists ( $MTM::Legacy::Lists::p_wordprob{ $WordTag } ) ) {
						$factor1 = $MTM::Legacy::Lists::p_wordprob{ $WordTag };

			#			print "$WordTag\t$factor1\n";

					} elsif ( exists ( $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag } ) ) {
						$factor1 = $MTM::Legacy::Lists::p_backup_wordprob{ $WordTag };

			#			print "2 $WordTag\t$factor1\n";

					} else {
						$factor1 = 0.0;
					}

					dbg ("\t\t\tUnigram: $factor1\n");

					# The lookup word is modified (e.g. genitive strip)
					my $compare = $string[ $i ] . "s";
					if ( $CheckWord eq $compare ) {
			#			print "$WordNow\t$string[ $i ]\t\t$PossTag\n";
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

					print $TAGOUT "\t\ttmpProb: $tmpProb\n";

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

			#	print "MMMMPPPP $maxProb\t\t$string[ $i ]\n";

		
#				return ( $maxProb, $maxProbTag);


		} else {

			#print "MMM $CheckWord\t$maxProb\n";
			#if ( $maxProb == 0 ) {
				( $maxProb, $maxProbTag ) = &CheckSuffix( $i, $CheckWord, $string, $bestTag, $prob, 'mainlex' );
			#}

		}

		print $TAGOUT "\nCHECKING: $CheckWord\nMP: $maxProb\tMPT: $maxProbTag\n---------------\n";
	}

	@CheckWord = split//,$word;
	# Check in TPB lexicon if not found in SUC.
	if ( $maxProb == 0 ) {
		until ( $#CheckWord < 3 || $maxProb != 0) {
			my $CheckWord = join"",@CheckWord;
			( $maxProb, $maxProbTag ) = &CheckSuffix( $i, $CheckWord, $string, $bestTag, $prob , 'backuplex');

			print $TAGOUT "CHECKING TPB: $CheckWord\nMP: $maxProb\tMPT: $maxProbTag\n";

			# Shift here to get the lookup for the whole word.
			shift @CheckWord;
		}
	}

	if ( $maxProb == 0 ) {
		$maxProbTag = "UNKNOWN";
	}

	return ( $maxProb, $maxProbTag );

} # end sub
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

#	print "LL $lex\n";

	# lowercase!!!					CT 100719
	$CheckWord = &MTM::Case::makeLowercase( $CheckWord );


	# Main lexicon (SUC for Swedish)
	if ( $lex eq 'mainlex' ) {

		if ( exists ( $MTM::Legacy::Lists::p_suffixtag{ $CheckWord } ) ) {

			my @PossTags = split/\t/, $MTM::Legacy::Lists::p_suffixtag{ $CheckWord };


			print $TAGOUT "TAGGAR... @PossTags\t$CheckWord\n";

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

					print $TAGOUT "PROB $Prob\t\t$maxProb\n";
					if ( $Prob >= $maxProb ) {
						$maxProb = $Prob ;
						$maxProbTag = $tag;
					}

					print $TAGOUT "HOGSTA: $maxProbTag\t\t$maxProb\n\n";

				}	
			}
		}
	}

	# Word part not found in mainlexicon, use backup lexicon
	if ( $maxProb == 0 ) {

#		while( my($k,$v) = each( %p_backup_suffixtag )) { print "$k\t$v\n"; }

		if ( exists ( $MTM::Legacy::Lists::p_backup_suffixtag{ $CheckWord } ) ) {


			my @PossTags = split/\t/, $MTM::Legacy::Lists::p_backup_suffixtag{ $CheckWord };

			print  $TAGOUT "TAGGAR... @PossTags\t$CheckWord\n";

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

					print $TAGOUT "PROB $Prob\t\t$maxProb\n";
					if ( $Prob >= $maxProb ) {
						$maxProb = $Prob ;
						$maxProbTag = $tag;
					}

					print $TAGOUT "HOGSTA: $maxProbTag\t\t$maxProb\n\n";
				} # end if

			} # end foreach 
		} # end exists
	} # end else


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


	print $TAGOUT "\n--------------\nRESULTS:\n";
	#my $count = 0;

#	if ( $#string != $#bestTag ) {
#		print "OLIKA LANGA: @string\t$#string\n@bestTag\t$#bestTag\n\n";
#		exit;
#	}

	foreach my $i ( 0 .. $#string ) {
		my $suc = $MTM::Legacy::Lists::p2s{ $bestTag[ $i ] };

		if ( $bestTag[ $i ] eq "UNKNOWN" ) {
			print $TAGOUT "$string[ $i ]\t\tUNKNOWN\t\t$bestTag[ $i ]\t\t0\n";
		} else {
			print $TAGOUT "$string[ $i ]\t\t$suc\t\t$bestTag[ $i ]\t\t$prob[ $i ]\n";
		}

		#$count++;
	}
	print $TAGOUT "\n--------------\n\n";

	return 1;
} # end sub

####################################################################
#sub dbg{
#	print $TAGOUT $_[0] if($debug);
#}
#

###############################################
### read_tagger_lists()
###############################################
sub read_tagger_lists {

#	my $tagsetFile			=	"$list_path/TagSet.txt";

#	my $p2s_file			=	"$readPath/p2s.txt";
#	my $p2s_db_file			=	"$list_path/p2s.db";
#	tie (%p2s,"DB_File",$p2s_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p2s_db_file: $!";

#	my $s2p_file			=	"$readPath/s2p.txt";
#	my $s2p_db_file			=	"$list_path/s2p.db";
#	tie (%s2p,"DB_File",$s2p_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $s2p_db_file: $!";

#	my $p_bigramFile		=	"$readPath/p_bigram.txt";
#	my $p_bigram_db_file		=	"$list_path/p_bigram.db";
#	tie (%p_bigram,"DB_File",$p_bigram_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_bigram_db_file: $!";

#	my $p_trigramFile		=	"$readPath/p_trigram.txt";
#	my $p_trigram_db_file		=	"$list_path/p_trigram.db";
#	tie (%p_trigram,"DB_File",$p_trigram_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_trigram_db_file: $!";

#	my $p_wordFile			=	"$readPath/p_suclex.txt";
#	my $p_wordtags_db_file		=	"$list_path/p_wordtags.db";
#	my $p_wordprob_db_file		=	"$list_path/p_wordprob.db";
#	tie (%p_wordtags,"DB_File",$p_wordtags_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_wordtags_db_file: $!";
#	tie (%p_wordprob,"DB_File",$p_wordprob_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_wordprob_db_file: $!";

#	my $p_backup_wordFile		=	"$readPath/p_tpblex.txt";
#	my $p_backup_wordtags_db_file	=	"$list_path/p_backup_wordtags.db";
#	my $p_backup_wordprob_db_file	=	"$list_path/p_backup_wordprob.db";
#	tie (%p_backup_wordtags,"DB_File",$p_backup_wordtags_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_backup_wordtags_db_file: $!";
#	tie (%p_backup_wordprob,"DB_File",$p_backup_wordprob_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_backup_wordprob_db_file: $!";

#	my $p_main_suffix_file		=	"$readPath/p_suc_suffix.txt";
#	my $p_main_suffix_db_file	=	"$list_path/p_suc_suffix.db";
#	my $p_main_suffixtag_db_file	=	"$list_path/p_suc_suffixtag.db";
#	tie (%p_suffix,"DB_File",$p_main_suffix_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_main_suffix_db_file: $!";
#	tie (%p_suffixtag,"DB_File",$p_main_suffixtag_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot#tie $p_main_suffixtag_db_file: $!";

#	my $p_backup_suffix_file 	=	"$readPath/p_tpb_suffix.txt";
#	my $p_backup_suffix_db_file	=	"$list_path/p_tpb_suffix.db";
#	my $p_backup_suffixtag_db_file	=	"$list_path/p_tpb_suffixtag.db";
#	tie (%p_backup_suffix,"DB_File",$p_backup_suffix_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_backup_suffix_db_file: $!";
#	tie (%p_backup_suffixtag,"DB_File",$p_backup_suffixtag_db_file,O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $p_backup_suffixtag_db_file: $!";


#	# Empty hashes
#	%p_bigram = ();
#	%p2s = ();
#	%s2p = ();
#
#	%p_wordtags = ();
#	%p_wordprob = ();
#
#	%p_backup_wordtags = ();
#	%p_backup_wordprob = ();
#
#	%p_suffix = ();
#	%p_suffixtag = ();
#	%p_backup_suffix = ();
#	%p_backup_suffixtag = ();


	#**********************************************************************************************#
	# SUFFIXES FROM SUC-LEXICON (In MTM::Vars)
	#**********************************************************************************************#
#	open MAINSUFF,"<$p_main_suffix_file";
#	while (<MAINSUFF>) {
#		chomp;
#		my @list = split/\t+/;
#		$MTM::Legacy::Lists::p_suffixtag{ $list[0] } .= "$list[1]\t";
#		$MTM::Legacy::Lists::p_suffix{ "$list[0]\t$list[1]" } = $list[2];
#
#	}
#	close MAINSUFF;
	#print "Main suffixes read.\n";

	#**********************************************************************************************#
	# SUFFIXES FROM TPB-LEXICON (In MTM::Vars)
	#**********************************************************************************************#
#	open BACKUPSUFF,"<$p_backup_suffix_file";
#	while (<BACKUPSUFF>) {
#		next if /^\#/;
#		chomp;
#		my @list = split/\t+/;
#		$MTM::Legacy::Lists::p_backup_suffixtag{ $list[0] } .= "$list[1]\t";
#		$MTM::Legacy::Lists::p_backup_suffix{ "$list[0]\t$list[1]" } = $list[2];
#	}
#	close BACKUPSUFF;
	#print "Backup suffixes read.\n";

	#**********************************************************************************************#
	# PAROLE --> SUC (In MTM::Vars)
	#**********************************************************************************************#
#	open P,"<$p2s_file" or die "NEJ: $p2s_file $!";
#	while (<P>) {
#		chomp;
#		my ($p,$s) = split/\t+/;
#		$MTM::Legacy::Lists::p2s{ $p } = $s;
#	}
#	close P;
	#print "Parole to SUC mapping read.\n";
	#**********************************************************************************************#
	# SUC --> PAROLE
	#**********************************************************************************************#
# CT 100329	The sub is not used
#	sub read_s2p {
#
#		open S2P, "<$s2p_file" or die "NEJ: $!";
#		while (<S2P>) {
#			chomp;
#			my ($s,$p) = split/\t+/;
#			$MTM::Legacy::Lists::s2p{ $s } = $p;
#		}
#		close S2P;
#	}
	#**********************************************************************************************#
	# BIGRAM: Word Tag1 Tag2 Prob (In MTM::Vars)
	#**********************************************************************************************#

#	open (BIGRAMRAM, "<$p_bigramFile") || die "Could not open '$p_bigramFile'";
#	while(<BIGRAM>){
#
#		if ( my ($tag1,$tag2,$prob) = split/\t+/ ) {
#			$MTM::Legacy::Lists::p_bigram{ "$tag1\t$tag2" } = $prob;
#		} else {
#			warn "$p_bigramFile: Wrong format";
#		}
#	}
#	close BIGRAM;
	#print "Bigrams read.\n";
	#**********************************************************************************************#
	# TRIGRAM: Word Tag1 Tag2 Tag3 Prob (In MTM::Vars)
	#**********************************************************************************************#

#	open (TRIGRAM, "<$p_trigramFile") || die "Could not open '$p_trigramFile'";
#	while(<TRIGRAM>){
#
#		if ( my ($tag1,$tag2,$tag3,$prob) = split/\t+/ ) {
#			$MTM::Legacy::Lists::p_trigram{ "$tag1-$tag2\t$tag3" } = $prob;
#		} else {
#			warn "$p_trigramFile: Wrong format";
#		}
#	}
#	close TRIGRAM;
	#print "Trigrams read.\n";
	#**********************************************************************************************#
	# UNIGRAM: Word Tag Prob (In MTM::Vars)
	#**********************************************************************************************#

#	open (WORDTAG, "<$p_wordFile") || die "Could not open '$p_wordFile'";
#	while(<WORDTAG>){
#		next if /^\#/;
#
#		if ( $_ =~ /([^\t]+)\t+([^\s]+)\t+([^\s]+)\t+([^\s]+)\t+([\d\.e\-]+)$/ ) {
#			my $word = $1;
#			my $tag = $2;
#			my $prob = $5;
#
#			$MTM::Legacy::Lists::p_wordtags{ $word } .= "$tag\t";
#			my $wordtag = "$word\t$tag";
#			$MTM::Legacy::Lists::p_wordprob{$wordtag} = $prob;
#	
		# CT 111222
#		} elsif ( $_ =~ /\t.+\t/ ) {
#			my ( $word, $tag, $prob ) = split/\t/;
#	
#			$MTM::Legacy::Lists::p_wordtags{ $word } .= "$tag\t";
#			my $wordtag = "$word\t$tag";
#			$MTM::Legacy::Lists::p_wordprob{$wordtag} = $prob;
#	
#		} else {
#		 	warn "$p_wordFile: Wrong format";
#		}

#	}
#	close WORDTAG;
	#print "Unigrams read.\n";
	#exit;
	#while(my($k,$v) = each(%p_wordtags)) { print OUT "HEJ\t$k\t$v\n"; } exit;


	#**********************************************************************************************#
	# UNIGRAM: Backup Word Tag Prob
	#**********************************************************************************************#

#	open (BUWORDTAG, "<$p_backup_wordFile") || die "Could not open '$p_backup_wordFile'";
#	while(<BUWORDTAG>){
#
#		my @list = split/\t/;
#		if( $#list == 2 ) {
#
#		#if ( $_ =~ /([^\t]+)\t+([^\s]+)\t+([^\s]+)\t+([^\s]+)\t+([\d\.e\-]+)$/ ) {
#			my $word = $list[1];
#			my $tag = $list[2];
#			my $prob = $list[3];
#	
#			print "W $word\tT $tag\tP $prob\n";
#
#			$MTM::Legacy::Lists::p_backup_wordtags{ $word } .= "$tag\t";
#			my $wordtag = "$word\t$tag";
#			$MTM::Legacy::Lists::p_backup_wordprob{$wordtag} = $prob;
#		} else {
#		 	warn "$p_backup_wordFile: Wrong format";
#		}
#
#	}
#	close BUWORDTAG;
	#print "Backup unigrams read.\n";#	while (($k,$v) = each( %wt)) { print "$k\t$v\n"; }

	#**********************************************************************************************#
	# TAGSET: Tag
	#*************************************************************************************************#

#	open(T, "<$tagsetFile") || die "Could not open '$tagsetFile'";	## Tags einlesen
#	while(<T>){
#		push(@tagset, ($_ =~ /([^\r\n]+)/));
#	}
#	close T;
#	print "Tagset read.\n";

}
#**********************************************************************************************#
#******************************************************************#
# SplitString
#
# Used by tagger
#
#******************************************************************#
sub SplitString {
	my $string = shift;
	$string =~ s/([\.\?\:\;\=\,\"\'\(\)\[\]\/\+\!\”])/ $1 /g;
	$string =~ s/- / - /g;
	$string =~ s/(\d)-(\d)/$1 - $2/g;

	$string =~ s/^ +//;
	$string =~ s/ +$//;

	my @string = split/ +/,$string;

	return (\@string);
}
###################################################################
### dbg() - Einfache Info-Messages über den Programmablauf ausgeben
###################################################################
sub dbg{
#	print "JOJO $_[0]\n";
	print $TAGOUT "$_[0]";

	return 1;
}
#******************************************************************#
1;

