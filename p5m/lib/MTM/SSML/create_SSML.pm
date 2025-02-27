package MTM::SSML::create_SSML;

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
# create_SSML
#
# Language	sv_se
#
# Unsupervised SSML insertion.
#
# Return: pronunciation
#
#
# 1. Read parameters for when to help TTS by inserting SSML (e.g. pagenumbers "s. 32", law paragraphs "32a-33b §§").
# 2. Preprocess text.
# 3. Find the targets and the appertunant values (in object).
# 4. Send charcount_id's, orthography, SSML type (<phoneme>, <break> etc.) + value, to SSML inserter.
#
#
# --analysis pagenum=1 --analysis lawref=1
#
#
# (c) Swedish Agency for Accessible Media, MTM 2024
#**************************************************************#
sub insert_SSML {
	my $self = shift;
	my $chunk = shift;

	#my( $phoneme_types, $sub_types, $break_types ) = @_;

	my $t = $self->{LEGACYDATA};

	#print "insert_SSML\n\t@MTM::Vars::phoneme_types\tnow $t->{pron}\n@MTM::Vars::sub_types\tnow $t->{exprType}\n";

	# 1. Pronunciations <phoneme>
	if( &MTM::Legacy::isDefault( $t->{pron} ) == 0 ) {
		foreach my $value( @MTM::Vars::phoneme_types ) {
			# All tokens
			if(
				# All tokens
				$value eq 'TOKEN'
				||
				# OOV
				( $value eq 'OOV' && $t->{isInDictionary} !~ /(dict|\d+|autonumeral)/ )
				||
				# Expression type
				$t->{exprType} eq $value
			) {
				my $ssml_start = "<phoneme alphabet\=\"ipa\" ph\=\"$t->{pron}\">";
				my $ssml_end = '</phoneme>';
				my $ssml_value = "";

				my $ret_ssml = $ssml_start . $t->{orth} . $ssml_end;

				$t->{ssml} = $ret_ssml;
				return $self;
			}
		}
	}

	# 2. Substitution <sub>
	if( &MTM::Legacy::isDefault( $t->{exp} ) == 0 ) {
		foreach my $exprType( @MTM::Vars::sub_types ) {
			if( $t->{exprType} =~ /(^|\|)$exprType($|\|)/i ) {
				my $ssml_start = "<sub alias\=$t->{exp}\">";
				my $ssml_end = '</sub>';
				my $ssml_value = "";

				my $ret_ssml = $ssml_start . $t->{orth} . $ssml_end;

				$t->{ssml} = $ret_ssml;
				#$self->{ARRAY}[0]->{ARRAY}[0]->{ARRAY}[0]->{LEGACYDATA}{ssml} = $ret_ssml;
			}
		}
	}

	# 3. Pauses <break>
	if( $t->{pause} =~ /\d/ ) {
		foreach my $break( @MTM::Vars::break_types ) {

			#my $ssml_start = '<break time="' . $t->{pause} . '">';
			#my $ssml_end = '</break>';

			# <break time="150ms"/>,
			my $ret_ssml = '<break time="150ms"/>' . $t->{orth};

			#my $ret_ssml = $ssml_start . $t->{orth} . $ssml_end;

			$t->{ssml} = $ret_ssml;
		}
	}
	return $self;
}
#**************************************************************#
### TODO change vars from Vars to %hp
sub createTypeLists {

	my $hp = shift;
	my @phoneme_types = ();
	my @sub_types = ();
	my @break_types = ();

	my %hp = %$hp;


	#print "IUPOIUPOIU  $hp{phoneme}{pronunciation}\n";

	#**************************************************************#
	# <phoneme>
	# All tokens
	push @phoneme_types, 'TOKEN', 			if defined($hp{phoneme}{pronunciation}) && $hp{phoneme}{pronunciation} ==  1;

	# OOV tokens
	push @phoneme_types, 'OOV', 			if defined($hp{phoneme}{oov}) && $hp{phoneme}{oov} ==  1;

	# Expression _types resulting in <phoneme>
	push @phoneme_types, 'EMAIL' 			if defined($hp{phoneme}{email}) && $hp{phoneme}{email} ==  1;
	push @phoneme_types, 'URL' 			if defined($hp{phoneme}{url}) && $hp{phoneme}{url} ==  1;
	push @phoneme_types, 'FILENAME' 		if defined($hp{phoneme}{filename}) && $hp{phoneme}{filename} ==  1;
	push @phoneme_types, 'ACRONYM' 			if defined($hp{phoneme}{acronym}) && $hp{phoneme}{acronym} ==  1;
	push @phoneme_types, 'INITIAL' 			if defined($hp{phoneme}{initial}) && $hp{phoneme}{initial} ==  1;

	#**************************************************************#
	# <sub>
	# All expression _types resulting in <sub>
	push @sub_types, ( 'ABBREVIATION', 'DATE', 'TIME', 'YEAR', 'YEAR INTERVAL', 'CURRENCY', 'DECIMAL', 'PHONE', 'NUMERAL', 'ORDINAL', 'INTERVAL', 'FRACTION' ) if defined($hp{sub}{exprtypes}) && $hp{sub}{exprtypes} ==  1;

	# All expression _types concerning numerals
	push @sub_types, ( 'DATE', 'TIME', 'YEAR', 'YEAR INTERVAL', 'CURRENCY', 'DECIMAL', 'PHONE', 'NUMERAL', 'ORDINAL', 'INTERVAL', 'FRACTION' ) if defined($hp{sub}{numeral}) && $hp{sub}{numeral} ==  1;

	push @sub_types, 'DATE' 			if defined($hp{sub}{date}) && $hp{sub}{date} == 1;
	push @sub_types, 'TIME' 			if defined($hp{sub}{time}) && $hp{sub}{time} == 1;
	push @sub_types, ( 'YEAR', 'YEAR INTERVAL' ) 	if defined($hp{sub}{year}) && $hp{sub}{year} == 1;
	push @sub_types, 'CURRENCY' 			if defined($hp{sub}{currency}) && $hp{sub}{currency} == 1;
	push @sub_types, 'DECIMAL' 			if defined($hp{sub}{decimal}) && $hp{sub}{decimal} == 1;
	push @sub_types, 'PHONE' 			if defined($hp{sub}{phone}) && $hp{sub}{phone} == 1;
	push @sub_types, 'NUMERAL' 			if defined($hp{sub}{numeral}) && $hp{sub}{numeral} == 1;
	push @sub_types, 'ORDINAL' 			if defined($hp{sub}{ordinal}) && $hp{sub}{ordinal} == 1;	### This one is not used (much). Better to look for pos=RO?
	push @sub_types, 'FRACTION' 			if defined($hp{sub}{fraction}) && $hp{sub}{fraction} == 1;
	push @sub_types, ( 'INTERVAL', 'YEAR INTERVAL' ) if defined($hp{sub}{interval}) && $hp{sub}{interval} == 1;
	push @sub_types, 'ABBREVIATION' 		if defined($hp{sub}{abbreviation}) && $hp{sub}{abbreviation} == 1;

	#print STDERR "\nMTM::Vars::do_hyphen_ssml $MTM::Vars::do_hyphen_ssml\n\n";
	#print STDERR "\nMTM::Vars::do_oov_ssml $MTM::Vars::do_oov_ssml\n\n";

	#**************************************************************#
	# Misc
	push @sub_types, 'PAGE' 			if defined($hp{misc}{pagenum}) && $hp{misc}{pagenum} ==  1;
	push @sub_types, 'REFERENCE' 			if defined($hp{misc}{lawref}) && $hp{misc}{lawref} ==  1;
	push @sub_types, 'HYPHEN' 			if defined($hp{misc}{hyphen}) && $hp{misc}{hyphen} ==  1;
	push @sub_types, 'HYPHEN_INTERVAL' 		if defined($hp{misc}{hypheninterval}) && $hp{misc}{hypheninterval} ==  1;

	# print STDERR "STST @sub_types\n";

	#**************************************************************#
	# <break>
	push @break_types, 'PAUSE' 			if defined($hp{break}{pause}) && $hp{break}{pause} ==  1;

	# print STDERR "P @phoneme_types\nS @sub_types\nB @break_types\n";


	return( \@phoneme_types, \@sub_types, \@break_types );
}
#**************************************************************#
1;
