package MTM::Legacy::Lists;

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


our %GLOBAL_OVERRIDE;

if (defined($ARGV[0]) && $ARGV[0] eq 'OVERRIDE') {
	shift @ARGV;
	%GLOBAL_OVERRIDE = @ARGV;
}

# 2021-01-06 JE
# Modularisation of building, storing and retrieving lists
# Note that we need a serialisation module as well (doing a reverse "build")
use MTM::Legacy::Lists::Build;
use MTM::Legacy::Lists::Store;
use MTM::Legacy::Lists::Retrieve;

use MTM::Legacy::Lists::Build_DB_File;
# use MTM::Legacy::Lists::Build_Stored;
# Don't think this method will e used. use MTM::Legacy::Lists::Build_Stored;

use strict;
use Sereal::Encoder;     # Will be loaded in Store
use Sereal::Decoder;     # Will be loaded in Retrieve
###use open qw(:std :utf8); # Will be loaded in Build and the serialisation module
use Path::Class qw(file);

##### JE Inherit instead? In any case, this is (harmlessly) circular - Lists
#        is loaded by Legacy itself...
use MTM::Legacy;

#***************************************************************************#
# List handling
#
# Language	sv_se
#
# Encoding/decoding lists
#
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#***************************************************************************#
# Plan:
# Short-term plan:
# The goal is to (1) get all variables that are accessed gloabally declared
# at the same place, so we can see them transparently, and (2) to separated
# text file r/w, binary file r/w, and internal list structure building.
#
# (0) DONE Go over variable management so that we don't data in RAM
# (1) set up to _either_
#     - build from file, then potentially store (encode) *or*
#     - retrieve from file (decode),
#     never both.
# (2) Set up proper code timers for each process
# (3) When (1) works, build a object based process to make control more
#     straightforward
#
# Long-term plan
#
# The goal is to (1) place each data resource in an object (or all of them
# in the same object providing different access methods), (2) provide clear
# methods on the object for: (a) access to data (in each way it is currently
# accessed), (b) reading/writing from/to arbitrary formats (called in with
# config options; currently it'd be Sereal binary and CSV), (c) pretty print
# of data (compilations, summaries...).
#
# (1) Take one item (list) and  (use the global declaration list as a plan)
# (2) Check that everything is still running
# (3) Document and add tests
# (4) Do the next item
#
#***************************************************************************#
# Declare package scoped variables
#
# These are the packgage scoped variables that are used by the MTM TTS
# preprocessing system as a stop gap during transition from the original
# codebase to the new codebase (2020/2021)
#
# These are currently accessed as hard pointers into this namespace, e.g.:
# %MTM::Legacy::Lists::p2s
#
# They are declared here, but populated by either endode or decode
#
#***************************************************************************#
# Swedish
our %sv_alphabet;
our %sv_acronym;

# English
our %en_alphabet;
our %en_acronym;

# Abbreviation lists
our %sv_abbreviation;
our %sv_abbreviation_case;
our $sv_abbreviation_list;
our $sv_abbreviation_list_case;

our %en_abbreviation;
our %en_abbreviation_case;
our $en_abbreviation_list;
our $en_abbreviation_list_case;

our %sv_numeral_pron;
our %en_numeral_pron;

our %sv_domain;
our %en_domain;

our %p2s;
our %s2p;
our %p_bigram;
our %p_trigram;
our %p_wordprob;
our %p_backup_wordprob;
our %p_wordtags;
our %p_backup_wordtags; # Likely not used?
our %p_suffix;
our %p_backup_suffix;
our %p_suffixtag;
our %p_backup_suffixtag;
our %numeralPron;

our %sv_dict_main;
our %sv_dict_name;
our %sv_dict_english;

our %sv_nst_dict;

our %sv_initial_c;
our %sv_initial_v;
our %sv_medial_c;
our %sv_medial_v;
our %sv_final_c;
our %sv_final_v;
our %en_initial_c;
our %en_initial_v;
our %en_medial_c;
our %en_medial_v;
our %en_final_c;
our %en_final_v;

# Multiword lists
our %sweDictMultiword;
our $multiwordList;


# DecPart lists
our %sv_final_dec_parts;
our $sv_final_dec_partsList;
our $sv_final_orth_dec_parts;
our $sv_final_orth_meta;
our %sv_initial_dec_parts;
our $sv_initial_dec_parts_list;
our $sv_initial_orth_dec_parts;
our %sv_medial_dec_parts;
our $sv_medial_dec_partsList;
our $sv_medial_orth_dec_parts;

our %en_final_dec_parts;
our $en_final_dec_partsList;
our $en_final_orth_dec_parts;
our $en_final_orth_meta;
our %en_initial_dec_parts;
our $en_initial_dec_parts_list;
our $en_initial_orth_dec_parts;
our %en_medial_dec_parts;
our $en_medial_dec_partsList;
our $en_medial_orth_dec_parts;

# Suffix lists
our %sv_suffix;
our %sv_suffix_pos;
our $sv_suffix_list;
our %en_sufix;
our %en_suffix_pos;
our $en_suffix_list;

# Special characters lists
our %sv_special_character;
our $sv_special_character_list;
our %en_special_character;
our $en_special_character_list;


# We use a pckaged scoped object to access MTM convenience methods
our $MTM = MTM->new;

##### (NB) Temporary cutoff threshold for resource loading
# Set to -1 to load all resources

our $READERCUTOFF;
if (exists($GLOBAL_OVERRIDE{READERCUTOFF})) {
	$READERCUTOFF = $GLOBAL_OVERRIDE{READERCUTOFF};
} else {
	##### CT Don't set below 10000, you'll miss too many things.
	#$READERCUTOFF = 1000000000;
	#$READERCUTOFF = 10000;
	#$READERCUTOFF = 10000;
	$READERCUTOFF = -1;
	### Reading $READERCUTOFF first lines of resource files (-1 means all)...
}

our $list_mode;
if (exists($GLOBAL_OVERRIDE{LISTMODE})) {
	$list_mode = $GLOBAL_OVERRIDE{LISTMODE};
} else {
	#$list_mode = 'SRL';
	$list_mode = 'DB_File';
	#$list_mode = 'Stored';
}

##### (NB) Temporary hardcoded path to legacy data (e.g. printed_lists)
my $LEGACYPATH = "data/legacy/";
my $SRLPATH = "$LEGACYPATH/srl";

# Path to data/srl
if(! -d  $SRLPATH ) {
	mkdir $SRLPATH;
}

my $DB_PATH = "$LEGACYPATH/db";	# CT 210916

##### CT 2020-12-22 Swith for sereal (if 1, encode and decode, otherwise, just decode).
# my $do_sereal_encoding = 0;

	# Encode
#	if( $do_sereal_encoding == 1 ) {
		if(! -d  $SRLPATH ) {
			mkdir $SRLPATH;
		}
#		&sereal_encode_lists( $LEGACYPATH, $SRLPATH );
#	}

# JE 2020-12-30 Divide into build (from lists), retrieve (from serialised files).
#               Optionally also store (to serialised files).
my $METHOD;
if (exists($GLOBAL_OVERRIDE{LISTMETHOD})) {
	$METHOD = $GLOBAL_OVERRIDE{LISTMETHOD};
} else {
	$METHOD = 'retrieve';
	#$METHOD = 'build';
	#$METHOD = 'build+store';
	# $STORE = 0;
}

print STDERR "$READERCUTOFF - $list_mode - $METHOD\n";

# SRL
if( $list_mode eq 'SRL' ) {
	if ($METHOD eq 'build' ) {	##### CT 210215
		MTM::Legacy::Lists::Build::build_lists( $MTM, $LEGACYPATH );

	} elsif ($METHOD eq 'build+store') {	##### CT 210215
		#MTM::Legacy::Lists::Build::build_lists( $MTM, $LEGACYPATH, $SRLPATH );	##### CT 210215
		#store_lists() if $METHOD eq 'build+store';


	} elsif ($METHOD eq 'retrieve') {
		MTM::Legacy::Lists::Retrieve::read_lists($MTM, $SRLPATH);

	} else {
		die "Bad list population method: $METHOD";
	}
# DB_File
} elsif( $list_mode eq 'DB_File' ) {
	if ($METHOD eq 'build' ) {	##### CT 210215
		### MTM::Legacy::Lists::Build::build_lists( $MTM, $LEGACYPATH );
		MTM::Legacy::Lists::Build_DB_File::build_lists( $MTM, $LEGACYPATH, $SRLPATH, 1 );

	} elsif ($METHOD eq 'build+store') {	##### CT 210215
		#MTM::Legacy::Lists::Build::build_lists( $MTM, $LEGACYPATH, $SRLPATH );	##### CT 210215
		#store_lists() if $METHOD eq 'build+store';

	} elsif ($METHOD eq 'retrieve') {
		#MTM::Legacy::Lists::Retrieve::read_lists($MTM, $SRLPATH);
		MTM::Legacy::Lists::Build_DB_File::build_lists( $MTM, $LEGACYPATH, $SRLPATH, 0 );

	} else {
		die "Bad list population method: $METHOD";
	}
# Stored
} else {
	if ($METHOD eq 'build' ) {	##### CT 210922
		### MTM::Legacy::Lists::Build::build_lists( $MTM, $LEGACYPATH );
		MTM::Legacy::Lists::Build_Stored::build_lists( $MTM, $LEGACYPATH, $SRLPATH, 1 );

	} elsif ($METHOD eq 'build+store') {	##### CT 210215
		#MTM::Legacy::Lists::Build::build_lists( $MTM, $LEGACYPATH, $SRLPATH );	##### CT 210215
		#store_lists() if $METHOD eq 'build+store';


	} elsif ($METHOD eq 'retrieve') {

	} else {
		die "Bad list population method: $METHOD";
	}
}

1;
