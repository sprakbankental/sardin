package MTM::SSML::SSML_insertion;

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
# SSML_insertion
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
	my( $self, $chunk, $phoneme_types, $sub_types, $break_types ) = @_;

	my @ssml_string = ();

	# <phoneme>
	# Pronunciations	Do this one first: <phoneme> has higher prio than <sub>
	my ( $ssml, $orth ) = &doPhonemeInsertions( $self, $chunk, $phoneme_types );

	# <sub>
	# Expression _types
	( $ssml, $orth ) = &doSubInsertions( $self, $chunk, $sub_types );

	# Special <sub>
	( $ssml, $orth ) = &doSpecialInsertions( $self, $chunk, $sub_types );

	# <break>
	# Pauses
	( $ssml, $orth ) = &doPauseInsertions( $self, $chunk, $break_types );

	#print "RETURN @ssml_string\n";
	return $self;

}
#**************************************************************#
# SSML for page numbers
sub doSpecialInsertions {
	my $self = shift;
	my $chunk = shift;
	my $triggers = shift;
	my @triggers = @$triggers;

	my $t = $self->{LEGACYDATA};

	my $to_push = $t->{orth};

	# Return if SSML already set
	return $t->{ssml} if &MTM::Legacy::isDefault( $t->{ssml} ) == 0;


	foreach my $trigger( @triggers ) {

		my $do_insertion = 0;
		if( $trigger eq 'PAGE' && $t->{orth} =~ /^s\.?$/ && $t->{exp} =~ /^sid/i ) {
			$do_insertion = 1;
		}

		if( $trigger eq 'REFERENCE' && $t->{exprType} =~ /REFERENCE/ ) {
			$do_insertion = 1;
		}

		if( $trigger eq 'HYPHEN' && $t->{orth} eq '-' && $t->{exp} ne '-' ) {
			$do_insertion = 1;
		}

		if( $trigger eq 'HYPHEN_INTERVAL' && $t->{orth} eq '-' && $t->{exp} eq 'till' ) {
			$do_insertion = 1;
		}


		if( $do_insertion == 1 ) {
			my $start_tok_char_id = 0;
			my $char_tok_len = length( $t->{orth} ) -1;
			my $start_orthography = $t->{orth};
			my $ssml_type = '<sub>';
			my $ssml_value = $t->{exp};

			return '-' if $ssml_value eq '-';

			# Insert SSML values in object
			$to_push = &insert_ssml_values( $self, $chunk, $start_tok_char_id, $char_tok_len, $start_orthography, $ssml_type, $ssml_value );

			# print "TRIGGER $trigger\tTEXT $t->{orth}\t$t->{ssml}\tdo $do_insertion\n";
		}
	}


#	print "IN SPECIAL SUB $t->{orth}\t$to_push\n";
	return( $to_push, $t->{orth} );
}
#**************************************************************#
# SSML for tokens tagged with certain expression _types
sub doPauseInsertions {
	my $self = shift;
	my $chunk = shift;
	my $pause_types = shift;
	my @pause_types = @$pause_types;

	my $t = $self->{LEGACYDATA};

	return $t->{orth} if $#pause_types < 0;


	my $start_tok_char_id = 0;
	my $char_tok_len = 0;
	my $start_orthography = 'void';
	my $ssml_type = '-';
	my $ssml_value = '-';

	my $to_push = $t->{orth};

	if( &MTM::Legacy::isDefault( $t->{pause} ) == 0 ) {
		$start_tok_char_id = 0;
		$char_tok_len = length( $t->{orth} ) -1;
		$start_orthography = $t->{orth};
		$ssml_type = '<break>';
		$ssml_value = $t->{pause};

		return '-' if $ssml_value eq '-';

		$to_push = &insert_ssml_values( $self, $chunk, $start_tok_char_id, $char_tok_len, $start_orthography, $ssml_type, $ssml_value );
	}
	return( $to_push, $t->{orth} );
}
#**************************************************************#
# SSML for tokens tagged with certain expression_types
sub doSubInsertions {
	my $self = shift;
	my $chunk = shift;
	my $sub_types = shift;
	my @sub_types = @$sub_types;

	my $t = $self->{LEGACYDATA};
	my $to_push = $t->{orth};

	foreach my $exprType( @sub_types ) {

		# Return if SSML already set
		return $t->{ssml} if &MTM::Legacy::isDefault( $t->{ssml} ) == 0;
		return $t->{ssml} if &MTM::Legacy::isDefault( $t->{exp} ) == 1;

		if( $t->{exprType} =~ /(^|\|)$exprType($|\|)/i ) {

			my $start_tok_char_id = 0;
			my $char_tok_len = length( $t->{orth} ) -1;
			my $start_orthography = $t->{orth};
			my $ssml_type = '<sub>';
			my $ssml_value = $t->{exp};

			return '-' if $ssml_value eq '-';

			### TODO: shouldn't be necessary!
			if( $MTM::Legacy::Lists::list_mode eq 'DB_File' ) {
				utf8::decode( $ssml_value );
			}

			# Insert SSML values in object
			$to_push = &insert_ssml_values( $self, $chunk, $start_tok_char_id, $char_tok_len, $start_orthography, $ssml_type, $ssml_value );
		}
	}
	return( $to_push, $t->{orth} );
}
#**************************************************************#
# SSML for all tokens with pronunciations
sub doPhonemeInsertions {
	my $self = shift;
	my $chunk = shift;
	my $phoneme_types = shift;
	my @phoneme_types = @$phoneme_types;

	my $t = $self->{LEGACYDATA};

	foreach my $value( @phoneme_types ) {

		print "IOUPOIUPOIUPOIU\t$value\t$t->{orth}\t$t->{pron}\n";
		# Return if SSML already set
		#return $t->{ssml} if &MTM::Legacy::isDefault( $t->{ssml} ) == 0;
		return $t->{ssml} if &MTM::Legacy::isDefault( $t->{pron} ) == 1;



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
			$t->{ssml} = '<phoneme alphabet="ipa" ph="' . $t->{pron} . '>' . $t->{orth} . '</phoneme>';
			#print "hOHO $t->{ssml}\n";

			#return '-' if $ssml_value eq '-';

			# Insert SSML values in object
			#$to_push = &insert_ssml_values( $self, $chunk, $start_tok_char_id, $char_tok_len, $start_orthography, $ssml_type, $ssml_value );
		}
	}
	#return( $to_push, $t->{orth} );
	return 1;
}
#**************************************************************#
sub insert_ssml_values {
	my ( $self, $chunk, $start_tok_char_id, $char_tok_len, $start_orthography, $ssml_type, $ssml_value ) = @_;

	# print "insert_ssml_values $start_tok_char_id, $char_tok_len, $start_orthography, $ssml_type, $ssml_value\n";

	my $t = $self->{LEGACYDATA};

	my $to_push = $t->{orth};

	### For now: insert all info in ssml slot.	CT 210902

	# If ssml_type is <break>: add the ssml
	if( $ssml_type eq '<break>' && $t->{ssml} ne '-' ) {
		if( $ssml_value =~ /^(.+)\|(.+)$/ ) {
			my $ssml_value_1 = $1;
			my $ssml_value_2 = $2;

			# <break> <phoneme> <break>: <break> parentes <break>
			my $new_ssml = "$ssml_type $ssml_value_1 $start_tok_char_id $char_tok_len\|$t->{ssml}\|$ssml_type $ssml_value_2 $start_tok_char_id $char_tok_len";

			$t->{ssml} = $new_ssml;
			$to_push = $t->{ssml};
		} else {
			$t->{ssml} .= "\|$ssml_type\t$ssml_value\t$start_tok_char_id\t$char_tok_len";
			$to_push = $t->{ssml};
		}
	# ssml was empty
	} else {
		# Remove double pauses at e.g. parenthesis
		$ssml_value =~ s/^(\d+)\|\d+$/$1/ if $ssml_type eq '<break>';

		$t->{ssml} = "$ssml_type\t$ssml_value\t$start_tok_char_id\t$char_tok_len";
		$to_push = $t->{ssml};

		#print "NNNN $t->{ssml}\n";

	}

	return( $to_push );
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
	push @sub_types, ( 'ABBREVIATION', 'DATE', 'TIME', 'YEAR', 'YEAR INTERVAL', 'CURRENCY', 'DECIMAL', 'PHONE', 'ORDINAL', 'INTERVAL', 'FRACTION' ) if defined($hp{sub}{exprtypes}) && $hp{sub}{exprtypes} ==  1;

	# All expression _types concerning numerals
	push @sub_types, ( 'DATE', 'TIME', 'YEAR', 'YEAR INTERVAL', 'CURRENCY', 'DECIMAL', 'PHONE', 'ORDINAL', 'INTERVAL', 'FRACTION' ) if defined($hp{sub}{numeral}) && $hp{sub}{numeral} ==  1;

	push @sub_types, 'DATE' 			if defined($hp{sub}{date}) && $hp{sub}{date} == 1;
	push @sub_types, 'TIME' 			if defined($hp{sub}{time}) && $hp{sub}{time} == 1;
	push @sub_types, ( 'YEAR', 'YEAR INTERVAL' ) 	if defined($hp{sub}{year}) && $hp{sub}{year} == 1;
	push @sub_types, 'CURRENCY' 			if defined($hp{sub}{currency}) && $hp{sub}{currency} == 1;
	push @sub_types, 'DECIMAL' 			if defined($hp{sub}{decimal}) && $hp{sub}{decimal} == 1;
	push @sub_types, 'PHONE' 			if defined($hp{sub}{phone}) && $hp{sub}{phone} == 1;
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
