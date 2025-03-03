package MTM::Legacy::Lists::Build_DB_File;

use parent qw(MTM::Legacy::Lists);
use Path::Class qw(file);

use warnings;
use strict;

use DB_File;
use DBM_Filter;

use Sereal::Encoder;
use Sereal::Decoder;

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

#***************************************************************************#
#
# 2021-09-22 CT need them for now
#
#***************************************************************************#
sub build_lists {

	my $mtm = shift;
	my $legacypath = shift;
	my $SRLPATH = shift;
	my $do_build = shift;

	if (! -e "$legacypath/db/" ) {
		mkdir( "$legacypath/db/" ) or die "Can't create $legacypath/db/: $!\n";
	}

	print STDERR "LIST READING START\t$mtm\t$legacypath\t$do_build\n";

	### &readMultiwordList( $legacypath, $do_build )  or die;

	$do_build = 0;

	&read_sv_alphabet( $legacypath, $do_build ) or die;
	&read_en_alphabet( $legacypath, $do_build ) or die;

	&read_sv_abbreviation( $legacypath, $do_build ) or die;
	&read_en_abbreviation( $legacypath, $do_build ) or die;

	&read_sv_acronym( $legacypath, $do_build ) or die;
	&read_en_acronym( $legacypath, $do_build ) or die;

	&read_sv_numeral_pron( $legacypath, $do_build ) or die;
	&read_en_numeral_pron( $legacypath, $do_build ) or die;

	&read_sv_domain( $legacypath, $do_build ) or die;
	&read_en_domain( $legacypath, $do_build ) or die;

	&read_sv_suffix( $legacypath, $do_build ) or die;
	&read_en_suffix( $legacypath, $do_build ) or die;

	&read_sv_special_character( "$legacypath/sv_special_character.txt", $do_build ) or die;
	&read_en_special_character( "$legacypath/en_special_character.txt", $do_build ) or die;

	#print STDERR "Small lists read.\n";

	# DecParts lists
	&read_sv_initial_dec_parts( $legacypath, $SRLPATH, $do_build ) or die;
	&read_sv_medial_dec_parts( $legacypath, $SRLPATH, $do_build ) or die;
	&read_sv_final_dec_parts( $legacypath, $SRLPATH, $do_build ) or die;


	&read_sv_braxen($legacypath, $do_build) or die;
	&read_en_braxen($legacypath, $do_build) or die;

	# TODO Switch?
	if( $MTM::Vars::use_dict eq 'NST' ) { &read_nst_dict( $do_build ) or die; }

	&read_sv_initial_c( $legacypath, $do_build ) or die;
	&read_sv_initial_v( $legacypath, $do_build ) or die;
	&read_sv_medial_c( $legacypath, $do_build ) or die;
	&read_sv_medial_v( $legacypath, $do_build ) or die;
	&read_sv_final_c( $legacypath, $do_build ) or die;
	&read_sv_final_v( $legacypath, $do_build ) or die;

	&read_en_initial_c( $legacypath, $do_build ) or die;
	&read_en_initial_v( $legacypath, $do_build ) or die;
	&read_en_medial_c( $legacypath, $do_build ) or die;
	&read_en_medial_v( $legacypath, $do_build ) or die;
	&read_en_final_c( $legacypath, $do_build ) or die;
	&read_en_final_v( $legacypath, $do_build ) or die;

	#$do_build = 1;
	# TAGGER DB's
	&read_p2s( "$legacypath/p2s.txt", $do_build ) or die;	# %p2s
	&read_s2p( "$legacypath/s2p.txt", $do_build ) or die;	# %s2p

	&read_p_bigram( "$legacypath/p_bigram.txt", $do_build ) or die;	# %p_bigram
	&read_p_trigram( "$legacypath/p_trigram.txt", $do_build ) or die;	# %p_trigram

	&read_p_wordprob( "$legacypath/p_wordprob.txt", $do_build ) or die;	# %p_wordprob
	&read_p_backup_wordprob( "$legacypath/p_backup_wordprob.txt", $do_build ) or die;	# %p_backup_wordprob

	# Words with all possible pos tags. From suc lexicon.
	&read_p_wordtags( "$legacypath/p_wordtags.txt", $do_build ) or die;	# %p_wordtags

	# ERROR: This list is uncomplete, lacking key values (in its original form). Can't find the file the db is based on (p_tpblex.txt).
	# No catastrophe, just skip this file! Rebuild if necessary, but it doesn't do much anyway.
	# Words with all possible pos tags. From backup lexicon.
	# k = orthography, $v = pos1 pos2					...
	# &read_p_backup_wordtags( "$legacypath/p_backup_wordtags.txt", $do_build ) or die;	# %p_backup_wordtags

	# Final word parts (seems to be down to 3 characters) with pos and probability. From Main lexikon.
	# k = orthography pos tag, v = probability
	&read_p_main_suffix( "$legacypath/p_main_suffix.txt", $do_build ) or die;	# %p_suffix

	# Final word parts (seems to be down to 3 characters) with pos and probability. From backup lexikon.
	# k = orthography				pos tag, v = probability
	&read_p_backup_suffix( "$legacypath/p_backup_suffix.txt", $do_build ) or die;	# %p_backup_suffix

	&read_p_main_suffixtag( "$legacypath/p_main_suffixtag.txt", $do_build ) or die;	# %p_suffix
	&read_p_backup_suffixtag( "$legacypath/p_backup_suffixtag.txt", $do_build ) or die;	# %p_backup_suffix

	#print STDERR "Tagger lists read.\n";

	print STDERR "LIST BUILDING END\n";
	return 1;
}
#*******************************************************************************************#
# Read Swedish letter pronunciations
sub read_sv_alphabet {
	my $path = shift or die "Missing path!";
	my $do_build = shift;
	my $file = $path . 'sv_alphabet.txt';

	my $db = $file;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	#my $do_build = 1;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading $file\t$db\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_alphabet = ();
		tie( %MTM::Legacy::Lists::sv_alphabet, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			utf8::decode( $line );
			# k = orthography, $v = pronunciation
			my( $k, $v ) = split/\t/, $line;
			$MTM::Legacy::Lists::sv_alphabet{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_alphabet, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_alphabet)){ print "hhh k $k\tv $v\n"; }
	return 1;
}
#*******************************************************************************************#
# Read English letter pronunciations
sub read_en_alphabet {
	my $path = shift or die "Missing path!";
	my $do_build = shift;
	my $file = $path . 'en_alphabet.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	#$do_build = 1;
	if( $do_build == 1 ) {

		print STDERR "READING $file\n";

		open my $fh_FILE, '<', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_alphabet\n";
		unlink $db;
		%MTM::Legacy::Lists::en_alphabet = ();
		tie( %MTM::Legacy::Lists::en_alphabet, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			utf8::decode( $line );

			# k = orthography, $v = pronunciation
			my( $k, $v ) = split/\t/, $line;
			$MTM::Legacy::Lists::en_alphabet{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_alphabet, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}

	return 1;
}
#*******************************************************************************************#
# Read Swedish acronyms
sub read_sv_acronym {

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_acronym.txt';

	#$do_build = 1;

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_sv_acronym\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_acronym = ();
		tie( %MTM::Legacy::Lists::sv_acronym, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			utf8::decode( $line );

			# k = orthography, $v = pronunciation
			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::sv_acronym{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_acronym, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	#while(my($k,$v)=each(%MTM::Legacy::Lists::sv_acronym)){ print "sv_acronym $k\t$v\n"; }

	$MTM::Legacy::Lists::sv_acronym_list = &create_sorted_scalar( \%MTM::Legacy::Lists::sv_acronym );
	return 1;
}
#*******************************************************************************************#
# Read English acronyms
sub read_en_acronym {

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_acronym.txt';

	# $do_build = 1;

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_acronym\n";
		unlink $db;
		%MTM::Legacy::Lists::en_acronym = ();
		tie( %MTM::Legacy::Lists::en_acronym, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			utf8::decode( $line );

			# k = orthography, $v = pronunciation
			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::en_acronym{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_acronym, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	#while(my($k,$v)=each(%MTM::Legacy::Lists::en_acronym)){ print "en_acronym $k\t$v\n"; }
	$MTM::Legacy::Lists::en_acronym_list = &create_sorted_scalar( \%MTM::Legacy::Lists::en_acronym );
	return 1;
}
#*******************************************************************************************#
# Reads abbreviation list and creates two scalars.
sub read_sv_abbreviation {

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = "$path/sv_abbreviation.txt";
	my $db1 = "$path/db/sv_abbreviation.db";
	my $db2 = "$path/db/sv_abbreviation_case.db";

	# $do_build = 1;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading $file\n";

		unlink $db1;
		unlink $db2;
		%MTM::Legacy::Lists::sv_abbreviation = ();
		%MTM::Legacy::Lists::sv_abbreviation_case = ();

		tie %MTM::Legacy::Lists::sv_abbreviation, "DB_File", $db1 or die "Cannot tie %MTM::Legacy::Lists::sv_abbreviation: $!";
		tie %MTM::Legacy::Lists::sv_abbreviation_case, "DB_File", $db2 or die "Cannot tie %MTM::Legacy::Lists::sv_abbreviation_case: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			chomp;
			next if /\#/;
			s/^\xEF\xBB\xBF//g;	# Remove bom
			my $line = $_;

			my( $k, @v ) = split/\t/, $line;

			my( $orthographies, $expansions, $rule, $mayEndSentence, $caseSensitivity ) = split/\t+/, $line;

			my @orthographies = split/\|/, $orthographies;
			my @expansions = split/\|/, $expansions;

			# Orthographies
			foreach my $orthography( @orthographies ) {
				if (
					$caseSensitivity == 1
				) {
					# Case sensitive abbreviations in special list
					#$caseOrth =~ s/([\.\?\+\/\&\- ])/\\$1/g;
					$orthography = quotemeta( $orthography );
					$orthography =~ s/\\\|/\|/g;

					$MTM::Legacy::Lists::sv_abbreviation_case{ $orthography } = "$expansions\t$rule\t$mayEndSentence";

					#print "I $MTM::Legacy::Lists::sv_abbreviation_case{ $orthography }\n";
				} else {
					# Not case sensitive - add to list in all case possibilities
					my @caseOrth = &MTM::Case::caseLookup( $orthography, "caseInsensitive" );

					foreach my $caseOrth ( @caseOrth ) {
						#$caseOrth =~ s/([\.\?\+\/\&\- ])/\\$1/g;
						$caseOrth = quotemeta( $caseOrth );
						$caseOrth =~ s/\\\|/\|/g;

						$MTM::Legacy::Lists::sv_abbreviation{ $caseOrth } = "$expansions\t$rule\t$mayEndSentence";
					}
				}
			}
		}
		close $fh_FILE;

		# Backup for empty lists (else won't work in token split.
		if( $#MTM::Legacy::Lists::sv_abbreviation == 0 ) {
			$MTM::Legacy::Lists::sv_abbreviation{ 'PhXY218Ii' } = "PhXY218Ii\t-\t0";
		}
		if( $#MTM::Legacy::Lists::sv_abbreviation_list_case == 0 ) {
			$MTM::Legacy::Lists::sv_abbreviation_list_case{ 'PhXY218Ii' } = "PhXY218Ii\t-\t0";
		}
	} else {
		tie %MTM::Legacy::Lists::sv_abbreviation, "DB_File", $db1 or die "Cannot tie %MTM::Legacy::Lists::sv_abbreviation: $!";
		tie %MTM::Legacy::Lists::sv_abbreviation_case, "DB_File", $db2 or die "Cannot tie %MTM::Legacy::Lists::sv_abbreviation: $!";
	}

	# while(my($k,$v)=each(%MTM::Legacy::Lists::sv_abbreviation_case)) { print STDERR "KL $k\t$v\n"; } exit;

	$MTM::Legacy::Lists::sv_abbreviation_list = &create_sorted_scalar( \%MTM::Legacy::Lists::sv_abbreviation );
	$MTM::Legacy::Lists::sv_abbreviation_list_case = &create_sorted_scalar( \%MTM::Legacy::Lists::sv_abbreviation_case );

	return 1;
}
#*******************************************************************************************#
# Reads abbreviation list and creates two scalars.
sub read_en_abbreviation {

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = "$path/en_abbreviation.txt";
	my $db1 = "$path/db/en_abbreviation.db";
	my $db2 = "$path/db/en_abbreviation_case.db";

	# $do_build = 1;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading $file\n";

		unlink $db1;
		unlink $db2;
		%MTM::Legacy::Lists::en_abbreviation = ();
		%MTM::Legacy::Lists::en_abbreviation_case = ();

		tie %MTM::Legacy::Lists::en_abbreviation, "DB_File", $db1 or die "Cannot tie %MTM::Legacy::Lists::en_abbreviation: $!";
		tie %MTM::Legacy::Lists::en_abbreviation_case, "DB_File", $db2 or die "Cannot tie %MTM::Legacy::Lists::en_abbreviation_case: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			chomp;
			next if /\#/;
			s/^\xEF\xBB\xBF//g;	# Remove bom
			my $line = $_;

			my( $k, @v ) = split/\t/, $line;

			my( $orthographies, $expansions, $rule, $mayEndSentence, $caseSensitivity ) = split/\t+/, $line;

			my @orthographies = split/\|/, $orthographies;
			my @expansions = split/\|/, $expansions;

			# Orthographies
			foreach my $orthography( @orthographies ) {
				if (
					$caseSensitivity == 1
				) {
					# Case sensitive abbreviations in special list
					#$caseOrth =~ s/([\.\?\+\/\&\- ])/\\$1/g;
					$orthography = quotemeta( $orthography );
					$orthography =~ s/\\\|/\|/g;

					$MTM::Legacy::Lists::en_abbreviation_case{ $orthography } = "$expansions\t$rule\t$mayEndSentence";

					#print "I $MTM::Legacy::Lists::en_abbreviation_case{ $orthography }\n";
				} else {
					# Not case sensitive - add to list in all case possibilities
					my @caseOrth = &MTM::Case::caseLookup( $orthography, "caseInsensitive" );

					foreach my $caseOrth ( @caseOrth ) {
						#$caseOrth =~ s/([\.\?\+\/\&\- ])/\\$1/g;
						$caseOrth = quotemeta( $caseOrth );
						$caseOrth =~ s/\\\|/\|/g;

						$MTM::Legacy::Lists::en_abbreviation{ $caseOrth } = "$expansions\t$rule\t$mayEndSentence";
					}
				}
			}
		}
		close $fh_FILE;

		# Backup for empty lists (else won't work in token split.
		if( $#MTM::Legacy::Lists::en_abbreviation == 0 ) {
			$MTM::Legacy::Lists::en_abbreviation{ 'PhXY218Ii' } = "PhXY218Ii\t-\t0";
		}
		if( $#MTM::Legacy::Lists::en_abbreviation_list_case == 0 ) {
			$MTM::Legacy::Lists::en_abbreviation_list_case{ 'PhXY218Ii' } = "PhXY218Ii\t-\t0";
		}
	} else {
		tie %MTM::Legacy::Lists::en_abbreviation, "DB_File", $db1 or die "Cannot tie %MTM::Legacy::Lists::en_abbreviation: $!";
		tie %MTM::Legacy::Lists::en_abbreviation_case, "DB_File", $db2 or die "Cannot tie %MTM::Legacy::Lists::en_abbreviation: $!";
	}

	# while(my($k,$v)=each(%MTM::Legacy::Lists::en_abbreviation_case)) { print STDERR "KL $k\t$v\n"; } exit;

	$MTM::Legacy::Lists::en_abbreviation_list = &create_sorted_scalar( \%MTM::Legacy::Lists::en_abbreviation );
	$MTM::Legacy::Lists::en_abbreviation_list_case = &create_sorted_scalar( \%MTM::Legacy::Lists::en_abbreviation_case );


	return 1;
}
#*******************************************************************************************#
# Read numeral pronunciations
sub read_sv_numeral_pron {

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_numeral_pron.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_sv_numeral_pron\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_numeral_pron = ();
		tie( %MTM::Legacy::Lists::sv_numeral_pron, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			next if $. == 1;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_numeral_pron{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_numeral_pron, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read numeral pronunciations
sub read_en_numeral_pron {

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_numeral_pron.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	# $do_build = 1;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_sv_numeral_pron\n";
		unlink $db;
		%MTM::Legacy::Lists::numeralPro = ();
		tie( %MTM::Legacy::Lists::en_numeral_pron, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			next if $. == 1;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_numeral_pron{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_numeral_pron, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read letter pronunciations
sub read_sv_domain {	# return: 1

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_domain.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_sv_domain\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_domain = ();
		tie( %MTM::Legacy::Lists::sv_domain, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_domain{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_domain, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read domain pronunciations
sub read_en_domain {	# return: 1

	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_domain.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	#$do_build = 1;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_domain\n";
		unlink $db;
		%MTM::Legacy::Lists::en_domain = ();
		tie( %MTM::Legacy::Lists::en_domain, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_domain{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_domain, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# read_sv_special_character
sub read_sv_special_character {
	my $file = shift or die "Missing file!";
	my $do_build = shift;

	my $db = &get_db_filename( $file );

	my $sv_special_character_obj = tie %MTM::Legacy::Lists::sv_special_character, "DB_File", $db;
	$sv_special_character_obj->Filter_Push('utf8'); # this is the magic bit

	if( $do_build == 1 ) {
		print STDERR "Reading $file\n";
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			chomp;
			s/\r//;
			my $line = $_;
			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::sv_special_character{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	}

	$MTM::Legacy::Lists::sv_special_character_list = &create_sorted_scalar( \%MTM::Legacy::Lists::sv_special_character );
#	print "I $MTM::Legacy::Lists::specialCharactersList\n";
#	use utf8;
#	my $test = 'δ';
#	while(my($k,$v)=each(%MTM::Legacy::Lists::specialCharacters)){ print "ttttttttt $test\tk $k\tv $v\n"; }
	return 1;
}
#*******************************************************************************************#
# read_en_special_character
sub read_en_special_character {
	my $file = shift or die "Missing file!";
	my $do_build = shift;

	my $db = &get_db_filename( $file );

	my $en_special_character_obj = tie %MTM::Legacy::Lists::en_special_character, "DB_File", $db;
	$en_special_character_obj->Filter_Push('utf8'); # this is the magic bit

	if( $do_build == 1 ) {
		print STDERR "Reading $file\n";
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			chomp;
			s/\r//;
			my $line = $_;
			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::en_special_character{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	}

	$MTM::Legacy::Lists::en_special_character_list = &create_sorted_scalar( \%MTM::Legacy::Lists::en_special_character );
	return 1;
}
#*******************************************************************************************#
# CT 2025-02-27	Read Braxen
sub read_sv_braxen {	# return: 1
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_braxen.txt';

	my $db = $file;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading sv_braxen\n";
		unlink $db if -e $db;
		%MTM::Legacy::Lists::sv_braxen = ();

		my $sv_braxen_obj = tie %MTM::Legacy::Lists::sv_braxen, "DB_File", $db;
		#$sv_dict_main_obj->Filter_Push('utf8');

		my $i = 0;
		while(<$fh_FILE>) {
			$i++;
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;

			my ( $k, @v ) = split/\t+/, $line;
			
			if(
				$k =~ /(ī|¢|©|®|°|´|µ|¸|½|¾|À|Á|Ã|Æ|Ç|È|É|Ì|Í|Î|Ï|Ð|Ó|Ô|Ø|Ú|Ü|Þ|ß|à|á|â|ã|æ|ç|è|é|ê|ë|ì|í|î|ï|ð|ñ|ò|ó|ô|õ|ø|ù|ú|û|ü|ý|þ|ā|ă|ć|ċ|Č|č|Ď|đ|ē|ė|ę|ě|ğ|ī|ı|ł|ń|Ņ|ņ|ŋ|ō|ő|œ|ř|Ś|ś|Ş|ş|Š|š|ţ|ū|ů|ű|ź|Ž|ž|ɑ|ɪ|ʌ|ʻ|ʿ|̈|̊|έ|ή|ί|α|β|γ|δ|ε|η|ι|κ|λ|μ|ν|ο|ρ|ς|σ|τ|υ|φ|χ|ό|ύ|ώ|ϰ|Б|В|Г|Д|К|П|С|Ф|Х|Ш|Ю|а|б|в|г|д|е|ж|з|и|й|к|л|м|н|о|п|р|с|т|у|х|ц|ч|ш|ы|ь|я|Ḥ|Ṣ|ẏ|\’|ﬀ|ﬁ|ﬂ|ﬃ)/
			) {
				#my  $found = $1;
				utf8::encode( $k );
				#print "encode $k	$found\n";
			}


			# $pron, $posmorph, $ortlang, $pronlang, $decomposed, $id
			my $val = "$v[0]	$v[1]	$v[2]	-	-	$v[25]";
			
			#print "$k\t$val\n";
			if( exists( $MTM::Legacy::Lists::sv_braxen{ $k } )) {
				$MTM::Legacy::Lists::sv_braxen{ $k } .= '<SPLIT>' . $val;
			} else {
				$MTM::Legacy::Lists::sv_braxen{ $k } = $val;
			}
			
			print "$i\n" if $i =~  /00000/;
		}
		close $fh_FILE;
	} else {
		my $sv_braxen_obj = tie %MTM::Legacy::Lists::sv_braxen, "DB_File", $db;
		#$sv_braxen_obj->Filter_Push('utf8');
	}
	return 1;
}
#*******************************************************************************************#
# CT 2025-02-27	Read Braxen
sub read_en_braxen {	# return: 1
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_braxen.txt';

	my $db = $file;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading en_braxen\n";
		unlink $db if -e $db;
		%MTM::Legacy::Lists::en_braxen = ();

		my $en_braxen_obj = tie %MTM::Legacy::Lists::en_braxen, "DB_File", $db;
		#$sv_dict_main_obj->Filter_Push('utf8');

		my $i = 0;
		while(<$fh_FILE>) {
			$i++;
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;

			my ( $k, @v ) = split/\t+/, $line;
			
			if( $k =~ /(ﬂ|ﬁ)/ ) {
				utf8::encode( $k );
			}

			#print "$k\n";
			# $pron, $posmorph, $ortlang, $pronlang, $decomposed, $id
			my $val = "$v[0]	$v[1]	$v[2]	-	-	$v[25]";
			
			#print "$k\t$val\n";
			if( exists( $MTM::Legacy::Lists::en_braxen{ $k } )) {
				$MTM::Legacy::Lists::en_braxen{ $k } .= '<SPLIT>' . $val;
			} else {
				$MTM::Legacy::Lists::en_braxen{ $k } = $val;
			}
			
			print "$i\n" if $i =~  /00000/;
		}
		close $fh_FILE;
	} else {
		my $en_braxen_obj = tie %MTM::Legacy::Lists::en_braxen, "DB_File", $db;
		#$en_braxen_obj->Filter_Push('utf8');
	}
	return 1;
}
#*******************************************************************************************#
## read_sv_dict_english
#sub read_sv_dict_english {
#	my $path = shift or die "Missing path!";
#	my $do_build = shift;
#
#	my $file = $path . 'sv_dict_english.txt';
#
#	my $db = $file;
#	$db =~ s/legacy/legacy\/db/;
#	$db =~ s/\.txt/\.db/;
#
#	#$do_build = 1;
#
#	if( $do_build == 1 ) {
#		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
#		print STDERR "Reading sv_dict_english\n";
#		%MTM::Legacy::Lists::sv_dict_english = ();
#		unlink $db;
#
#		my $sv_dict_english_obj = tie %MTM::Legacy::Lists::sv_dict_english, "DB_File", $db;
#		#$sv_dict_english_obj->Filter_Push('utf8');
#		while(<$fh_FILE>) {
#			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
#			next if /\#/;
#			my $line = $_;
#			$line =~ s/\r//g;
#			chomp $line;
#			$line =~ s/\r//g;
#
#			my ( $k, @v ) = split/\t+/, $line;
#
#			if( exists( $MTM::Legacy::Lists::sv_dict_english{ $k } )) {
#				$MTM::Legacy::Lists::sv_dict_english{ $k } .= '<SPLIT>' . join"\t", @v;
#			} else {
#				$MTM::Legacy::Lists::sv_dict_english{ $k } = join"\t", @v;
#			}
#		}
#		close $fh_FILE;
#	} else {
#		my %tmp = ();
#		tie( %MTM::Legacy::Lists::sv_dict_english, "DB_File", $db ) or die "Cannot tie sv_dict_english: $!";
#
#		#$sv_dict_english_obj->Filter_Push('utf8');
#	}
#	return 1;
#}
#*******************************************************************************************#
# Read NST lexicon
sub read_nst_dict {

	my $do_build = shift;

	my $file = $MTM::Vars::nst_path . '/sv_nst_dict_utf8.txt';
	my $addon = $MTM::Vars::nst_path . '/sv_nst_dict_addon.txt';

	my $db = $file;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	#$do_build = 1;

	### TODO Reading main nst lex and addon is same procedure. Merge.

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading sv_nst_dict\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_nst_dict = ();

		my $sv_dict_main_obj = tie %MTM::Legacy::Lists::sv_nst_dict, "DB_File", $db;
		#$sv_dict_main_obj->Filter_Push('utf8');

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			next if $. == 1;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;

			#utf8::encode( $line );
			my @line = split/\;/, $line;
			next if $line[7] eq 1;	# Garbage
			my $key = $line[0];
			# $pron, $posmorph, $ortlang, $pronlang, $decomposed, $id

			# posmorph
			my $pos = $line[1];
			my $morph = $line[2];
			$pos =~ s/^PM\|.+$/PM/;
			$morph =~ s/\|+/\|/g;
			$morph =~ s/^\|+//g;
			$morph =~ s/\|/ /g;
			my $posmorph = "$pos $morph";
			$posmorph = &MTM::Legacy::cleanBlanks( $posmorph );
			$posmorph =~ s/^PM$/PM NOM/g;
			$posmorph =~ s/ (MAS|FEM)$//;

			# lang
			my $ortlang = &MTM::Case::makeLowercase( $line[6] );
			my $pronlang = &MTM::Case::makeLowercase( $line[14] );

			my $val = "$line[11]\t$posmorph\t$ortlang\t$pronlang\t$line[3]\t$line[50]";

			if( exists( $MTM::Legacy::Lists::sv_nst_dict{ $key })) {
				if( $MTM::Legacy::Lists::sv_nst_dict{ $key } ne $val ) {
					$MTM::Legacy::Lists::sv_nst_dict{ $key } .= '<SPLIT>' . $val;
				}
			} else {
				$MTM::Legacy::Lists::sv_nst_dict{ $key } = $val;
			}
		}
		close $fh_FILE;

		# Read NST lexicon addon (missing high-frequent words)
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_ADDON, '<:encoding(UTF-8)', $addon or die "Cannot open $addon: $!\n";
		## use critic
		
		print STDERR "Reading sv_nst_dict_addon\n";
		while(<$fh_ADDON>){
			chomp;
			next if $. == 1;
			my $line = $_;
			my @line = split/\;/, $line;
			next if $line[7] eq 1;	# Garbage
			my $key = $line[0];

			# posmorph
			my $pos = $line[1];
			my $morph = $line[2];
			$pos =~ s/^PM\|.+$/PM/;
			$morph =~ s/\|+/\|/g;
			$morph =~ s/^\|+//g;
			$morph =~ s/\|/ /g;
			my $posmorph = "$pos $morph";
			$posmorph = &MTM::Legacy::cleanBlanks( $posmorph );
			$posmorph =~ s/^PM$/PM NOM/g;
			$posmorph =~ s/ (MAS|FEM)$//;

			# lang
			my $ortlang = &MTM::Case::makeLowercase( $line[6] );
			my $pronlang = &MTM::Case::makeLowercase( $line[14] );

			my $val = "$line[11]\t$posmorph\t$ortlang\t$pronlang\t$line[3]\t$line[50]";
			#print "K $key\t$val\n";
			if( exists( $MTM::Legacy::Lists::sv_nst_dict{ $key })) {
				if( $MTM::Legacy::Lists::sv_nst_dict{ $key } ne $val ) {
					$MTM::Legacy::Lists::sv_nst_dict{ $key } .= '<SPLIT>' . $val;
				}
			} else {
				$MTM::Legacy::Lists::sv_nst_dict{ $key } = $val;
			}
		}
		close $fh_ADDON;

	} else {
		my $sv_nst_dict_obj = tie %MTM::Legacy::Lists::sv_nst_dict, "DB_File", $db;
	}
	return 1;
}
#*************************************************************************#
# read_sv_suffix
sub read_sv_suffix {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_suffix.txt';

	my $db1 = "$path/db/sv_suffix.db";
	my $db2 = "$path/db/sv_suffix_pos.db";

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading sv_suffix\n";
		unlink $db1;
		unlink $db2;
		%MTM::Legacy::Lists::sv_dict_english = ();
		%MTM::Legacy::Lists::sv_suffix_pos = ();
		tie(%MTM::Legacy::Lists::sv_suffix, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::sv_suffix_pos, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $suffix, $suffixPron, $suffixPos ) = split/\t+/, $line;

			$MTM::Legacy::Lists::sv_suffix{ $suffix } = $suffixPron;
			$MTM::Legacy::Lists::sv_suffix_pos{ $suffix } = $suffixPos;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_suffix, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::sv_suffix_pos, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";
	}

	$MTM::Legacy::Lists::sv_suffix_list = &create_sorted_scalar( \%MTM::Legacy::Lists::sv_suffix );
	return 1;
}
#*************************************************************************#
# read_en_suffix
sub read_en_suffix {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_suffix.txt';

	my $db1 = "$path/db/en_suffix.db";
	my $db2 = "$path/db/en_suffix_pos.db";

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading en_suffix\n";
		unlink $db1;
		unlink $db2;
		%MTM::Legacy::Lists::sv_dict_english = ();
		%MTM::Legacy::Lists::en_suffix_pos = ();
		tie(%MTM::Legacy::Lists::en_suffix, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::en_suffix_pos, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $suffix, $suffixPron, $suffixPos ) = split/\t+/, $line;

			$MTM::Legacy::Lists::en_suffix{ $suffix } = $suffixPron;
			$MTM::Legacy::Lists::en_suffix_pos{ $suffix } = $suffixPos;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_suffix, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::en_suffix_pos, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";
	}

	$MTM::Legacy::Lists::en_suffix_list = &create_sorted_scalar( \%MTM::Legacy::Lists::en_suffix );
	return 1;
}
#*******************************************************************************************#
# Read clusters
sub read_sv_initial_c {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_initial_c.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_sv_initial_c\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_initial_c = ();
		tie( %MTM::Legacy::Lists::sv_initial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_initial_c{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_initial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_sv_initial_v {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_initial_v.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_sv_initial_v\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_initial_v = ();
		tie( %MTM::Legacy::Lists::sv_initial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_initial_v{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_initial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_sv_medial_c {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_medial_c.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_sv_medial_c\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_medial_c = ();
		tie( %MTM::Legacy::Lists::sv_medial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_medial_c{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_medial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_sv_medial_v {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_medial_v.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_sv_medial_v\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_medial_v = ();
		tie( %MTM::Legacy::Lists::sv_medial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_medial_v{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_medial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
sub read_sv_final_c {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_final_c.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_sv_final_c\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_final_c = ();
		tie( %MTM::Legacy::Lists::sv_final_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_final_c{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_final_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_sv_final_v {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'sv_final_v.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_sv_final_v\n";
		unlink $db;
		%MTM::Legacy::Lists::sv_final_v = ();
		tie( %MTM::Legacy::Lists::sv_final_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::sv_final_v{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_final_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_en_initial_c {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_initial_c.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_en_initial_c\n";
		unlink $db;
		%MTM::Legacy::Lists::en_initial_c = ();
		tie( %MTM::Legacy::Lists::en_initial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_initial_c{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_initial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_en_initial_v {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_initial_v.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_en_initial_v\n";
		unlink $db;
		%MTM::Legacy::Lists::en_initial_v = ();
		tie( %MTM::Legacy::Lists::en_initial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_initial_v{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_initial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_en_medial_c {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_medial_c.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_medial_c\n";
		unlink $db;
		%MTM::Legacy::Lists::en_medial_c = ();
		tie( %MTM::Legacy::Lists::en_medial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_medial_c{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_medial_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_en_medial_v {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_medial_v.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_medial_v\n";
		unlink $db;
		%MTM::Legacy::Lists::en_medial_v = ();
		tie( %MTM::Legacy::Lists::en_medial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_medial_v{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_medial_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}

	#while(my($k,$v)=each(%MTM::Legacy::Lists::en_medial_c)) { print "MTM::Legacy::Lists::en_medial_c\t$k\t$v\n"; }
	return 1;
}
sub read_en_final_c {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_final_c.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_final_c\n";
		unlink $db;
		%MTM::Legacy::Lists::en_final_c = ();
		tie( %MTM::Legacy::Lists::en_final_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_final_c{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_final_c, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}

sub read_en_final_v {
	my $path = shift or die "Missing path!";
	my $do_build = shift;

	my $file = $path . 'en_final_v.txt';

	my $db = $file;
	$db =~ s/\.txt/\.db/;
	$db =~ s/legacy/legacy\/db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_en_final_v\n";
		unlink $db;
		%MTM::Legacy::Lists::en_final_v = ();
		tie( %MTM::Legacy::Lists::en_final_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my ( $k, $v ) = split/\t+/, $line;
			$MTM::Legacy::Lists::en_final_v{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_final_v, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read compound parts
sub read_sv_initial_dec_parts {
	my $path = shift or die "Missing path!";
	my $SRLPATH = shift;
	my $do_build = shift;

	my $file = $path . 'sv_initial_comp_parts.txt';

	my $db = $file;
	$db =~ s/comp/dec/;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	my $db1 = $db;
	$db1 =~ s/dec/orth_dec/;

	#$do_build = 1;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading sv_initial_comp_parts\n";
		unlink $db;

		%MTM::Legacy::Lists::sv_initial_dec_parts = ();
		%MTM::Legacy::Lists::sv_initial_orth_dec_parts = ();

		tie( %MTM::Legacy::Lists::sv_initial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::sv_initial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

			#my ( $k, @v ) = split/\t+/, $line;
			my( $o, $p, $f ) = split/\t+/, $line;

			$MTM::Legacy::Lists::sv_initial_dec_parts{ $o } = $p;
			$MTM::Legacy::Lists::sv_initial_orth_dec_parts{ $o } = $f;
		}
		close $fh_FILE;

	} else {
		tie( %MTM::Legacy::Lists::sv_initial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::sv_initial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
	}

	#$MTM::Legacy::Lists::sv_initial_dec_parts_list = join'|', keys %MTM::Legacy::Lists::sv_initial_dec_parts;
	my $decoder = Sereal::Decoder->new;
	$MTM::Legacy::Lists::sv_initial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/sv_initial_dec_parts_list.srl" );	# Scalar

	return 1;
}
#*******************************************************************************************#
# Read compound parts
sub read_sv_medial_dec_parts {	# return: 1

	my $path = shift or die "Missing path!";
	my $SRLPATH = shift;
	my $do_build = shift;

	my $file = $path . 'sv_medial_comp_parts.txt';

	my $db = $file;
	$db =~ s/comp/dec/;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	my $db1 = $db;
	$db1 =~ s/dec/orth_dec/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading sv_medial_dec_parts\n";
		unlink $db;

		%MTM::Legacy::Lists::sv_medial_dec_parts = ();
		%MTM::Legacy::Lists::sv_medial_orth_dec_parts = ();

		tie( %MTM::Legacy::Lists::sv_medial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::sv_medial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

			#my ( $k, @v ) = split/\t+/, $line;
			my( $o, $p, $f ) = split/\t+/, $line;

			$MTM::Legacy::Lists::sv_medial_dec_parts{ $o } = $p;
			$MTM::Legacy::Lists::sv_medial_orth_dec_parts{ $o } = $f;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_medial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::sv_medial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
	}

	my $decoder = Sereal::Decoder->new;
	$MTM::Legacy::Lists::sv_medial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/sv_medial_dec_parts_list.srl" );	# Scalar

	return 1;
}
#*******************************************************************************************#
# Read compound parts
sub read_sv_final_dec_parts {	# return: 1

	my $path = shift or die "Missing path!";
	my $SRLPATH = shift;
	my $do_build = shift;

	my $file = $path . 'sv_final_comp_parts.txt';

	my $db = $file;
	$db =~ s/comp/dec/;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	my $db1 = $db;
	$db1 =~ s/dec/orth_dec/;

	my $db2 = $db;
	$db2 =~ s/dec_parts/orth_meta/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading sv_final_dec_parts\n";
		unlink $db;

		%MTM::Legacy::Lists::sv_final_dec_parts = ();
		%MTM::Legacy::Lists::sv_final_orth_dec_parts = ();
		%MTM::Legacy::Lists::sv_final_orth_meta = ();

		tie( %MTM::Legacy::Lists::sv_final_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::sv_final_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::sv_final_orth_meta, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

			my( $o, $p, $m, $f ) = split/\t+/, $line;
			$m =~ s/\|/\t/g;

			$MTM::Legacy::Lists::sv_final_dec_parts{ $o } = $p;
			$MTM::Legacy::Lists::sv_final_orth_dec_parts{ $o } = $f;
			$MTM::Legacy::Lists::sv_final_orth_meta{ $o } = $m;


			#my ( $k, @v ) = split/\t+/, $line;
			#$MTM::Legacy::Lists::sv_final_dec_parts{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::sv_final_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::sv_final_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::sv_final_orth_meta, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";
	}

	my $decoder = Sereal::Decoder->new;
	$MTM::Legacy::Lists::sv_final_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/sv_final_dec_parts_list.srl" );	# Scalar

	return 1;
}
#*******************************************************************************************#
# Read compound parts
sub read_en_initial_dec_parts {
	my $path = shift or die "Missing path!";
	my $SRLPATH = shift;
	my $do_build = shift;

	my $file = $path . 'en_initial_comp_parts.txt';

	my $db = $file;
	$db =~ s/comp/dec/;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	my $db1 = $db;
	$db1 =~ s/dec/orth_dec/;

	#$do_build = 1;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading en_initial_comp_parts\n";
		unlink $db;

		%MTM::Legacy::Lists::en_initial_dec_parts = ();
		%MTM::Legacy::Lists::en_initial_orth_dec_parts = ();

		tie( %MTM::Legacy::Lists::en_initial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::en_initial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

			#my ( $k, @v ) = split/\t+/, $line;
			my( $o, $p, $f ) = split/\t+/, $line;

			$MTM::Legacy::Lists::en_initial_dec_parts{ $o } = $p;
			$MTM::Legacy::Lists::en_initial_orth_dec_parts{ $o } = $f;
		}
		close $fh_FILE;

	} else {
		tie( %MTM::Legacy::Lists::en_initial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::en_initial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
	}

	#$MTM::Legacy::Lists::en_initial_dec_parts_list = join'|', keys %MTM::Legacy::Lists::en_initial_dec_parts;
	my $decoder = Sereal::Decoder->new;
	$MTM::Legacy::Lists::en_initial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/en_initial_dec_parts_list.srl" );	# Scalar

	return 1;
}
#*******************************************************************************************#
# Read compound parts
sub read_en_medial_dec_parts {	# return: 1

	my $path = shift or die "Missing path!";
	my $SRLPATH = shift;
	my $do_build = shift;

	my $file = $path . 'en_medial_comp_parts.txt';

	my $db = $file;
	$db =~ s/comp/dec/;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	my $db1 = $db;
	$db1 =~ s/dec/orth_dec/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading en_medial_dec_parts\n";
		unlink $db;

		%MTM::Legacy::Lists::en_medial_dec_parts = ();
		%MTM::Legacy::Lists::en_medial_orth_dec_parts = ();

		tie( %MTM::Legacy::Lists::en_medial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::en_medial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

			#my ( $k, @v ) = split/\t+/, $line;
			my( $o, $p, $f ) = split/\t+/, $line;

			$MTM::Legacy::Lists::en_medial_dec_parts{ $o } = $p;
			$MTM::Legacy::Lists::en_medial_orth_dec_parts{ $o } = $f;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_medial_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::en_medial_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
	}

	my $decoder = Sereal::Decoder->new;
	$MTM::Legacy::Lists::en_medial_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/en_medial_dec_parts_list.srl" );	# Scalar

	return 1;
}
#*******************************************************************************************#
# Read compound parts
sub read_en_final_dec_parts {	# return: 1

	my $path = shift or die "Missing path!";
	my $SRLPATH = shift;
	my $do_build = shift;

	my $file = $path . 'en_final_comp_parts.txt';

	my $db = $file;
	$db =~ s/comp/dec/;
	$db =~ s/legacy/legacy\/db/;
	$db =~ s/\.txt/\.db/;

	my $db1 = $db;
	$db1 =~ s/dec/orth_dec/;

	my $db2 = $db;
	$db2 =~ s/dec_parts/orth_meta/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading en_final_dec_parts\n";
		unlink $db;

		%MTM::Legacy::Lists::en_final_dec_parts = ();
		%MTM::Legacy::Lists::en_final_orth_dec_parts = ();
		%MTM::Legacy::Lists::en_final_orth_meta = ();

		tie( %MTM::Legacy::Lists::en_final_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::en_final_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::en_final_orth_meta, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom

			my( $o, $p, $m, $f ) = split/\t+/, $line;
			$m =~ s/\|/\t/g;

			$MTM::Legacy::Lists::en_final_dec_parts{ $o } = $p;
			$MTM::Legacy::Lists::en_final_orth_dec_parts{ $o } = $f;
			$MTM::Legacy::Lists::en_final_orth_meta{ $o } = $m;


			#my ( $k, @v ) = split/\t+/, $line;
			#$MTM::Legacy::Lists::en_final_dec_parts{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::en_final_dec_parts, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		tie( %MTM::Legacy::Lists::en_final_orth_dec_parts, 'DB_File', $db1, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db1: $!";
		tie( %MTM::Legacy::Lists::en_final_orth_meta, 'DB_File', $db2, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db2: $!";
	}

	my $decoder = Sereal::Decoder->new;
	$MTM::Legacy::Lists::en_final_dec_parts_list = $decoder->decode_from_file( "$SRLPATH/en_final_dec_parts_list.srl" );	# Scalar

	return 1;
}
#*******************************************************************************************#
# POS TAGGER FILES
#*******************************************************************************************#
# Read p2s
sub read_p2s {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_p2s\n";
		unlink $db;
		%MTM::Legacy::Lists::p2s = ();
		tie( %MTM::Legacy::Lists::p2s, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my( $k, $v ) = split/\t/, $line;
			$MTM::Legacy::Lists::p2s{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p2s, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}


	#while(my($k,$v)=each(%MTM::Legacy::Lists::p2s)){print "p2s $k\t$v __\n"; }

	return 1;
}
#*******************************************************************************************#
# Read s2p
sub read_s2p {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		# use critic
		
		print STDERR "Reading read_s2p\n";
		unlink $db;
		%MTM::Legacy::Lists::s2p = ();
		tie( %MTM::Legacy::Lists::s2p, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my( $k, $v ) = split/\t/, $line;
			$MTM::Legacy::Lists::s2p{ $k } = $v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::s2p, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}

	return 1;
}
#*******************************************************************************************#
# Read bigrams
sub read_p_bigram {
	my $file = shift;
	my $do_build = shift;

	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		# use critic
		
		print STDERR "Reading read_p_bigram\n";
		unlink $db;
		%MTM::Legacy::Lists::p_bigram = ();
		tie( %MTM::Legacy::Lists::p_bigram, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my @line = split/\t/, $line;
			$MTM::Legacy::Lists::p_bigram{ "$line[0]\t$line[1]" } = $line[2];
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p_bigram, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read trigrams
sub read_p_trigram {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		## no critic (InputOutput::RequireBriefOpen)
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		## use critic
		
		print STDERR "Reading read_p_trigram\n";
		unlink $db;
		%MTM::Legacy::Lists::p_trigram = ();
		tie( %MTM::Legacy::Lists::p_trigram, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my @line = split/\t/, $line;
			$MTM::Legacy::Lists::p_trigram{ "$line[0]\t$line[1]" } = $line[2];
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p_trigram, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read word probabilities
sub read_p_wordprob {
	my $file = shift;
	my $do_build = shift;

	my $db = &get_db_filename( $file );

	#my $p_wordprob_obj = tie %MTM::Legacy::Lists::p_wordprob, "DB_File", $db;
	#$p_wordprob_obj->Filter_Push('utf8');

	# $do_build = 1;

	if( $do_build == 1 ) {
		print STDERR "Reading $file\n";
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		unlink $db;

		%MTM::Legacy::Lists::p_wordprob = ();
		my $p_wordprob_obj = tie( %MTM::Legacy::Lists::p_wordprob, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
#		$p_wordprob_obj->Filter_Push('utf8');

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /#/;
			chomp;
			my $line = $_;
			my @line = split/\t/, $line;
			#if( $line =~ /Nilsson/ ) { print "k $line[0]\t$line[1]	v $line[2]\n"; }
			$MTM::Legacy::Lists::p_wordprob{ "$line[0]\t$line[1]" } = $line[2];
		}
		close $fh_FILE;
	} else {
		my $p_wordprob_obj = tie( %MTM::Legacy::Lists::p_wordprob, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
#		$p_wordprob_obj->Filter_Push('utf8');
	}

	return 1;
}
#*******************************************************************************************#
# Read backup word probabilities
sub read_p_backup_wordprob {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_p_backup_wordprob\n";
		unlink $db;
		%MTM::Legacy::Lists::p_backup_wordprob = ();

		my $p_backup_wordprob_obj = tie( %MTM::Legacy::Lists::p_backup_wordprob, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
#		$p_backup_wordprob_obj->Filter_Push('utf8');

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my @line = split/\t/, $line;
			$MTM::Legacy::Lists::p_backup_wordprob{ "$line[0]\t$line[1]" } = $line[2];
		}
		close $fh_FILE;
	} else {
		my $p_backup_wordprob_obj = tie( %MTM::Legacy::Lists::p_backup_wordprob, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
#		$p_backup_wordprob_obj->Filter_Push('utf8');
	}
	return 1;
}
#*******************************************************************************************#
# Read word tags
sub read_p_wordtags {
	my $file = shift;
	my $do_build = shift;

	my $db = &get_db_filename( $file );

	if( $do_build == 1 ) {
		print STDERR "Reading $file\n";
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";

		%MTM::Legacy::Lists::p_wordtags = ();
		my $p_wordtags_obj = tie( %MTM::Legacy::Lists::p_wordtags, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
#		$p_wordtags_obj->Filter_Push('utf8');

		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /#/;
			chomp;
			s/\r//g;
			my $line = $_;
			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::p_wordtags{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	} else {
		my $p_wordtags_obj = tie( %MTM::Legacy::Lists::p_wordtags, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		#print "DB $db\n";
		#while(my($k,$v)=each(%MTM::Legacy::Lists::p_wordtags)){ print "K $k\t$v\n"; }
#		$p_wordtags_obj->Filter_Push('utf8');
	}

	return 1;
}
#*******************************************************************************************#
# Read suffixes
sub read_p_main_suffix {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_p_main_suffix\n";
		unlink $db;
		%MTM::Legacy::Lists::p_suffix = ();
		tie( %MTM::Legacy::Lists::p_suffix, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my @line = split/\t/, $line;
			$MTM::Legacy::Lists::p_suffixtag{ "$line[0]\t$line[1]" } = $line[2];
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p_suffix, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read suffixes
sub read_p_backup_suffix {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_p_backup_suffix\n";
		unlink $db;
		%MTM::Legacy::Lists::p_backup_suffix = ();
		tie( %MTM::Legacy::Lists::p_backup_suffix, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my @line = split/\t/, $line;
			$MTM::Legacy::Lists::p_backup_suffix{ "$line[0]\t$line[1]" } = $line[2];

		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p_backup_suffix, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#************************************************************#
# Read suffixes
sub read_p_main_suffixtag {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_p_main_suffixtag\n";
		unlink $db;
		%MTM::Legacy::Lists::p_suffixtag = ();
		tie( %MTM::Legacy::Lists::p_suffixtag, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::p_suffixtag{ $k } = join"\t", @v;

		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p_suffixtag, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#*******************************************************************************************#
# Read suffixes
sub read_p_backup_suffixtag {
	my $file = shift;
	my $do_build = shift;


	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	if( $do_build == 1 ) {
		open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
		print STDERR "Reading read_p_backup_suffixtag\n";
		unlink $db;
		%MTM::Legacy::Lists::p_backup_suffixtag = ();
		tie( %MTM::Legacy::Lists::p_backup_suffixtag, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
		while(<$fh_FILE>) {
			last if $. == $MTM::Legacy::Lists::READERCUTOFF;
			next if /^\#/;
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/^\xEF\xBB\xBF//g;	# Remove bom
			#utf8::decode( $line );

			my( $k, @v ) = split/\t/, $line;
			$MTM::Legacy::Lists::p_backup_suffix{ $k } = join"\t", @v;
		}
		close $fh_FILE;
	} else {
		tie( %MTM::Legacy::Lists::p_backup_suffixtag, 'DB_File', $db, O_RDWR|O_CREAT, '0666' ) or die "Cannot tie $db: $!";
	}
	return 1;
}
#***************************************************************************#
## Read multiword list
#sub readMultiwordList {	# return: 1
#	my $path = shift or die "Missing path!";
#	my $do_build = shift;

#	# k = orthography, $v = pronunciation
#	my $file = file($path, 'sweDictMultiwordDB.txt');
##	my %sweMultiword = &create_hash( $file, $SRLPATH );
#	&populate_hash( $file, \%MTM::Legacy::Lists::sweDictMultiword );
#
#	#while(my($k,$v)=each(%sweDictMultiword)) { print "sweDictMultiword\t$k\t$v\n"; } exit;
#	$MTM::Legacy::Lists::multiwordList = join'|', keys( %MTM::Legacy::Lists::sweDictMultiword );
#
#	$MTM::Legacy::Lists::multiwordList =~ s/\|den (I|V)\|/\|/g;			# 191106 ugly fix.
#	$MTM::Legacy::Lists::multiwordList =~ s/([\{\}])/\\\$1/g;			# 190613 ugly fix.
#
#	# NB!! JE move out!
#	#&srl_scalar_file( 'multiwordList.txt', $MTM::Legacy::Lists::multiwordList );
#
#	return 1;
#}
#***************************************************************************************************#
sub create_scalar {
	my $hash = shift;
	my %hash = %$hash;

	my @list = keys %hash;

	return join'|', @list;
}
#***************************************************************************************************#
sub create_sorted_scalar {
	my $hash = shift;
	my %hash = %$hash;

	my @list = keys %hash;

	my @sorted_list = sort { length($b) <=> length($a) || $a cmp $b } keys %hash;

	return join'|', @sorted_list;
}
#***************************************************************************************************#
sub create_hash {
	my $file = shift;

	print STDERR "Reading $file\n";
	open my $fh_FILE, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!\n";
	my %hash = ();
	while(<$fh_FILE>) {
		chomp;
		my $line = $_;
		&utf8_check( $line, $file );

		if( $file =~ /(specialCharacters)/ ) {
			my( $k, $v ) = split/\t/, $line;
			print "K $k\t$v\n";
			$hash{ $k } = $v;
		}
	}
	close $fh_FILE;

	return \%hash;
}
#*******************************************************************************************#
sub utf8_check {
	my( $line, $file ) = @_;
	my $flag = utf8::valid($line);
	if( $flag == 0 ) {
		warn "$file:\t$line is utf8: $flag\n";
	}
	return 1;
}
#*******************************************************************************************#
sub get_db_filename {
	my $file = shift;
	my $db = $file;
	$db =~ s/_db_file//;
	$db =~ s/^(.+)\/(.+)\.txt$/$1\/db\/$2\.db/;

	return $db;
}
#***************************************************************************************************#
1;
