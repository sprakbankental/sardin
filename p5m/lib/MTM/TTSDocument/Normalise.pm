package MTM::TTSDocument::Normalise;

##### (TODO) First step of moving original basecode normalization to new structure
##### (TODO) Resource variables for hyphens and runmode needs fixing
##### (TODO) All normalizarion in this package is likely going to be removed
##### (TODO) since we're not supposed to chacge the text. We may add an extra 
##### (TODO) tier but that means a lot of token mapping.

#**************************************************************************#
# normalizeText_preproc.pl
#
# Call: &normalizeTextPreproc( $text );
#
#**************************************************************************#
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
##### (DEPRECATED) Use of legacy variables
# We're sourcing this package to get hold of MTM::Vars
# which holds all variables that were defined in
# old/languagetools/LexiconTools/Vars/vars.pl
# They should in time be handled differently, as an MTM resource object
use MTM::Legacy;

# our $hyphens; # Most likely not used here, just removed
# our $runmode; # Now passed as argument to normalizeTextPreproc
#**************************************************************************#
sub normaliseTextPreproc {

	my $text = shift;

	$text =~ s/^\xEF\xBB\xBF//g;	# Remove bom


	##### (DEPRECATED) Use of legacy flags
	# This is a legacy flag that scoped with 'our' in the original basecode
	# It is now taken from the calling object's legacy methods and passed
	# as an argument.
	my $runmode = shift; 

	# Remove bom
	$text =~ s/^\x{FEFF}//;
	$text =~ s/^\xEF\xBB\xBF//g;

	### 220511
	### return $text;

	$text =~ s/\”/\"/g;

	# Hyphens
	# Do not remove them, destroys orthography
	#$text =~ s/(^|\s)\-/$1/g;
	#$text =~ s/\-(\s|$)/$1/g;

#	$text =~ s/[\‘\’]/\'/g;

	# Commented out 200703
	#$text =~ s/(^| )\'+/$1/g;
	#$text =~ s/\'+( |$)/$1/g;


	$text =~ s/\s+/ /g;

	# Removing this. CT 200625
	# 200520 I don't know why the puncutation marks are removed, but we don't want it for unsupervisedSSML.
	#if( $runmode ne 'unsupervisedSSML') {
	#	$text =~ s/\.+(\s|$)/$1/g;		# Remove word final punctuation marks
	#}
# 191112 Destroys §?	$text =~ s/[\«\»]/ /g;

	$text =~ s/\x{201C}/\"/g;
	$text =~ s/\x{201D}/\"/g;

	#$text =~ s/\x{055A}/\'/g;

	$text =~ s/–/-/g;
#	$text =~ s/\’/\'/g;


	$text =~ s/\…/\./g;


	if( $runmode !~ /unsupervisedSSML/ ) {
		$text =~ s/\x{2212}/-/g;	# minus sign
		$text =~ s/\x{2012}/-/g;	# figure dash
		$text =~ s/\x{2013}/-/g;	# endash
		$text =~ s/\x{2014}/-/g;	# emdash
		$text =~ s/\x{2015}/-/g;	# horizontal bar
		$text =~ s/−/-/g;		# minus
		$text =~ s/‒/-/g;		# figure dash
		$text =~ s/―/-/g;		# horizontal bar

		#$text =~ s/\x{2020}/\†/g;	# dagger		# Uncommented 210701

		$text =~ s/\x{2022}/ /g;	# bullet
		$text =~ s/\x{00122}/ /g;	# &quot;
		$text =~ s/\x{25A0}/ /g;	# black square
		$text =~ s/\x{25A1}/ /g;	# white square
		$text =~ s/\x{25B2}/ /g;	# black up-pointing triangle
		$text =~ s/\x{25B6}/ /g;	# black right-pointing triangle
		$text =~ s/\x{25BA}/ /g;	# black right-pointing pointer
		$text =~ s/\x{25BC}/ /g;	# black down-pointing triangle
		$text =~ s/\x{2666}/ /g;	# black diamond suit
		$text =~ s/\x{2713}/ /g;	# check mark


		$text =~ s/\x{0026}/\&/g;	# &amp;
		$text =~ s/\x{0027}/\'/g;	# &prime;
		$text =~ s/\x{003C}/\</g;	# &lt;
		$text =~ s/\x{003E}/\>/g;	# &gt;
		$text =~ s/\x{007E}/\~/g;	# &sim;

		#$text =~ s/\x{24C7}/\&reg\;/g;	# ®
		#$text =~ s/\®/\&reg\;/g;	# ®
		$text =~ s/\x{2122}/\&trade\;/g;	# ™

		# This one destroys at least dagger (?)
		#$text =~ s/\x{00A0}/ /g;	# &nbsp;
		$text =~ s/\x{00B7}/ /g;	# middle dot

		$text =~ s/\x{2026}/ /g;	# horizontal ellipsis
	}

	$text =~ s/\x{E2809D}/\"/g;	# 

	$text =~ s/\x00D6/Ö/g;	# 

	# Clean spaces
	$text =~ s/\s+/ /g;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;


	# Clean spaces
	$text =~ s/\s+/ /g;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;

	return $text;
}
1;