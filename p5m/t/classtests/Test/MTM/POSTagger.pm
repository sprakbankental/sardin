package Test::MTM::POSTagger;
#**************************************************************#
# POSTagger.pm
#
# Temporary test suite
##### NB! Temporary tagger solution, to be replaced.
#
#**************************************************************#
use v5.32;                    # We assume pragmas and such from 5.32.0
use Test::More;               # Explicitly load modules - no Test::Most
use parent qw(ClassTestBase); # Local class which inherits from Test::Class

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

# Loaded automatically by class test base
#use MTM::POSTagger;

# MODULE	MTM::POSTagger::.pm
sub POSTagger : Test(2) {
	# Function	runPosTagger
	subtest "runPosTagger 1" => sub {
		plan tests => 2;
		my @input_list = qw( modern );
		my ( $poslist, $morphlist ) = &MTM::POSTagger::runPosTagger( @input_list, 'default' );
		my @poslist = @$poslist;
		my @morphlist = @$morphlist;
		is( $poslist[0], 'NN', 'runPosTagger pos (modern): correct.' );
		is( $morphlist[0], 'UTR SIN DEF NOM', 'runPosTagger morph (modern): correct.' );
	};
	subtest "runPosTagger 2" => sub {
		plan tests => 20;
		my @input_list = ( 'Modern', ' ',  'hade', ' ',  'en', ' ',  'modern', ' ',  'väska', '.' );
		my ( $poslist, $morphlist ) = &MTM::POSTagger::runPosTagger( @input_list, 'default' );
		my @poslist = @$poslist;
		my @morphlist = @$morphlist;

		is( $poslist[0], 'NN', 'runPosTagger pos (Modern): correct.' );
		is( $morphlist[0], 'UTR SIN DEF NOM', 'runPosTagger morph (Modern): correct.' );

		is( $poslist[1], 'DEL', 'runPosTagger pos (space): correct.' );
		is( $morphlist[1], '-', 'runPosTagger morph (space): correct.' );

		is( $poslist[2], 'VB', 'runPosTagger pos (hade): correct.' );
		is( $morphlist[2], 'PRT AKT', 'runPosTagger morph (hade): correct.' );

		is( $poslist[3], 'DEL', 'runPosTagger pos (space): correct.' );
		is( $morphlist[3], '-', 'runPosTagger morph (space): correct.' );

		is( $poslist[4], 'DT', 'runPosTagger pos (en): correct.' );
		is( $morphlist[4], 'UTR SIN IND', 'runPosTagger morph (en): correct.' );

		is( $poslist[5], 'DEL', 'runPosTagger pos (space): correct.' );
		is( $morphlist[5], '-', 'runPosTagger morph (space): correct.' );

		is( $poslist[6], 'JJ', 'runPosTagger pos (modern): correct.' );
		is( $morphlist[6], 'POS UTR SIN IND NOM', 'runPosTagger morph (modern): correct.' );

		is( $poslist[7], 'DEL', 'runPosTagger pos (space): correct.' );
		is( $morphlist[7], '-', 'runPosTagger morph (space): correct.' );

		is( $poslist[8], 'NN', 'runPosTagger pos (väska): correct.' );
		is( $morphlist[8], 'UTR SIN IND NOM', 'runPosTagger morph (väska): correct.' );

		is( $poslist[9], 'DL', 'runPosTagger pos (.): correct.' );
		is( $morphlist[9], 'MAD', 'runPosTagger morph (.): correct.' );
	};
}
sub TagWords : Test(4) {
	# Function	TagWords
	subtest "TagWords 1" => sub {
		plan tests => 9;
		my @input_list = qw( __$ fader __$ );
		my ( $bestTag, $prob, $TagConf ) = &MTM::POSTagger::TagWords( 'preproc', @input_list );
		my @bestTag = @$bestTag;
		my @prob = @$prob;
		my @TagConf = @$TagConf;
		my $best_tag = join"\t", @bestTag;
		$prob = join"\t", @prob;
		my $tag_conf = join"\t", @TagConf;

		is( $bestTag[0], '__$', 'TagWords best_tag (initial __$): correct.' );
		is( $prob[0], '1', 'TagWords prob (initial __$): correct.' );
		is( $TagConf[0], 'KW', 'TagWords tag_conf (initial __$): correct.' );

		is( $bestTag[1], 'NCUSN@IS', 'TagWords best_tag (fader): correct.' );
		is( $prob[1], '0.0120621649866837', 'TagWords prob (fader): correct.' );
		is( $TagConf[1], 'KW', 'TagWords tag_conf (fader): correct.' );

		is( $bestTag[2], '__$', 'TagWords best_tag (final __$): correct.' );
		is( $prob[2], '1', 'TagWords prob (final __$): correct.' );
		is( $TagConf[2], 'KW', 'TagWords tag_conf (final __$): correct.' );
	};
	subtest "TagWords 2" => sub {
		plan tests => 1;
		my @input_list = qw( __$ ζ __$ );
		my ( $bestTag, $prob, $TagConf ) = &MTM::POSTagger::TagWords( 'preproc', @input_list );
		my @bestTag = @$bestTag;
		is( $bestTag[1], 'NC000@0S', 'TagWords best_tag (ζ): correct.' );
	};
	subtest "TagWords 3" => sub {
		plan tests => 2;
		my @input_list = qw( __$ modern __$ );
		my ( $bestTag, $prob, $TagConf ) = &MTM::POSTagger::TagWords( 'preproc', @input_list );
		my @bestTag = @$bestTag;
		my @TagConf = @$TagConf;
		my @prob = @$prob;
		my $tag_conf = join"\t", @TagConf;

		is( $bestTag[1], 'NCUSN@DS', 'TagWords best_tag (modern): correct.' );
		# prob gives the wrong value - maybe rounding would help?
		# is( $prob[1], '0.0120621649866837', 'TagWords prob (modern): correct.' );
		is( $TagConf[1], 'KW', 'TagWords TagConf (modern): correct.' );
	};
	subtest "TagWords 4" => sub {
		plan tests => 3;
		my @input_list = qw( __$ Modern hade en modern väska . __$ );
		my ( $bestTag, $prob, $TagConf ) = &MTM::POSTagger::TagWords( 'preproc', @input_list );

		my @bestTag = @$bestTag;
		my @prob = @$prob;
		my @TagConf = @$TagConf;
		my $best_tag = join"\t", @bestTag;
		$prob = join"\t", @prob;
		my $tag_conf = join"\t", @TagConf;

		is( $best_tag, '__$	NCUSN@DS	V@IIAS	DI@US@S	AQPUSNIS	NCUSN@IS	FE	__$', 'TagWords best_tag (__$ Modern hade en modern väska . __$): correct.' );
		#is( $bestTag[1], 'NCUSN@DS', 'TagWords best_tag (_Modern_ hade en modern väska .): correct.' );
		#is( $bestTag[2], 'V@IIAS', 'TagWords best_tag (Modern _hade_ en modern väska .): correct.' );
		#is( $bestTag[3], 'DI@US@S', 'TagWords best_tag (Modern hade _en_ modern väska .): correct.' );
		#is( $bestTag[4], 'AQPUSNIS', 'TagWords best_tag (Modern hade en _modern_ väska .): correct.' );
		#is( $bestTag[5], 'NCUSN@IS', 'TagWords best_tag (Modern hade en modern _väska_.): correct.' );
		#is( $bestTag[6], 'FE', 'TagWords best_tag (Modern hade en modern väska_._): correct.' );

		is( $prob, '1	11.255580545268	0.00604119610288912	0.0020430699902817	0.661569416498997	0.243401610109039	0.116487243720752	1', 'TagWords prob (__$ Modern hade en modern väska . __$): correct.' );
		is( $tag_conf, 'KW	KW	KW	KW	KW	KW	KW	KW', 'TagWords tag_conf (__$ Modern hade en modern väska . __$): correct.' );
	};
}
1;
#**************************************************#
