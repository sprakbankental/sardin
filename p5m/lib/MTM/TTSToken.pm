package MTM::TTSToken;
#
# Pod documentation after __END__ below.
#
#*****************************************************************************#
#
# MTM::TTSToken - Perl data object holding a TTS token and its characteristics
#
# MTM::TTSTokens should not be expected to exist or function outside of
# an MTM::TTSChunk array.
#
# TODO The token will in time hold a list of MTM::TTSCharacter objects.
#
# ****************************************************************************#
use strict;
use warnings;

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM);
##### NB for TTSCharacter implementation
# use parent qw(MTM::TTSNodeFactory);

use MTM::TPBTag;

use MTM::Analysis::Abbreviation;
use MTM::Analysis::Acronym;
use MTM::Analysis::Currency;
use MTM::Analysis::Date;
use MTM::Analysis::Decimal;
use MTM::Analysis::Email;
use MTM::Analysis::Filename;
use MTM::Analysis::Initial;
use MTM::Analysis::Interval;
use MTM::Analysis::LanguageDetection;
use MTM::Analysis::LanguageDetection2;
use MTM::Analysis::Reference;
use MTM::Analysis::Ordinal;
use MTM::Analysis::PhoneNumber;
use MTM::Analysis::RomanNumber;
use MTM::Analysis::Time;
use MTM::Analysis::PhoneNumber;
use MTM::Analysis::URL;
use MTM::Analysis::Year;

use MTM::Expansion::ReferenceExpansion;
use MTM::Expansion::CharacterExpansion;
use MTM::Expansion::NumeralExpansion;
use MTM::Expansion::AbbreviationExpansion;

use MTM::Pronunciation;
# The above call is a shortcut to load all of the Pronunciation modules
# If there is need to unload any module, use
# no MODULE;
# or uncomment and edit the list below.
#use MTM::Pronunciation::Pronunciation;
#use MTM::Pronunciation::Compound;
#use MTM::Pronunciation::NumeralPronunciation;
#use MTM::Pronunciation::Decomposition;
#use MTM::Pronunciation::PronunciabilityCheck;
#use MTM::Pronunciation::AcronymPronunciation;
#use MTM::Pronunciation::Stress;
#use MTM::Pronunciation::Dictionary;
#use MTM::Pronunciation::Conversion;
#use MTM::Pronunciation::Affixation;
#use MTM::Pronunciation::Syllabify;
#use MTM::Pronunciation::Swedify;
#use MTM::Pronunciation::Autopron;
#use MTM::Pronunciation::AutopronVars;

use MTM::Pause;

use MTM::SSML;
use MTM::SSML::create_SSML;
use MTM::SSML::PLS;
#use MTM::SSML::SSML_sentence;
#print "$MTM::SSML::SSML_sentence::pioupoiu\n";
#exit;

use MTM::Validation::Pronunciation;

### MTMInternal
#use MTM::MTMInternal::VAC::VACsubs;
#use MTM::MTMInternal::VAC::validateCereprocTranscription;
#use MTM::MTMInternal::VAC::InsertionSubs::insertionSubs;

##### CT 21-05-19 New modules	MTM internal!
#use MTM::Frequency::Frequency;
#use MTM::Frequency::GraphemesPhonemes;
#use MTM::Frequency::Entropy;
#use MTM::Frequency::Readability;
### use MTM::MTMInternal::CereprocLists;
### use MTM::MTMInternal::OutputFolders;

#***************************************************************************#
#
# Constructor is inherited from MTM::Tie::CursorArray
#
# Object specific initialization
#
# Data hashes from original codebase
#	%pos = ();            # OO CHANGE 201106
#	%morph = ();          # OO CHANGE 201106
#	%pron = ();           # OO CHANGE 201106
#	%lang = ();           # OO CHANGE 201106
#	%exprType = ();	      # OO CHANGE 201106
#	%exp = ();            # OO CHANGE 201106
#	%isInDictionary = (); # OO CHANGE 201106
#	%pause = ();          # OO CHANGE 201106
#	%ssml = ();           # OO CHANGE 201106
#	%textType = ();       # OO CHANGE 201106
#	%dec = ();            # OO CHANGE 201106
#
# JE/CT 2020-11-10 refactoring decision: leave all names above as is
#                  for the first iteration - change once everything runs
sub _init {
	my $self = shift;
	##### (TODO) Keep this structure as a backup until new resource management works robustly
	##### (TODO) Then, remove it and release new version
	my $legacydata = {
		pos			=> '-',
		morph			=> '-',
		pron			=> '-',
		lang			=> '-',
		exprType		=> '-',
		exp 			=> '-',
		isInDictionary 		=> '-',
		pause 			=> '-',
		ssml 			=> '-',
		textType 		=> '-',
		dec 			=> '-',
		orth 			=> '-',
		freq_no_case		=> '-',
		g_entropy		=> '-',
		p_entropy		=> '-',
		self_distance		=> '-'
	};
	$self->{LEGACYDATA} = $legacydata;
	return $self->SUPER::_init;
}

#
sub pos_tag {
	my $self = shift;
	##### (NB) This should live elsewhere in time
### CT 210917	MTM::TPBTag::postag($self);
#	die "YEEEEHAAAAW!";
	return $self;
}

##### (NB) This is hacky, and should be neatened up before initial public release
##### (TODO) - decide exactly what test representations we keep and how they're defined
##### (TODO) - make sensible access methods at a sensible level of detail
##### (TODO) - generalize to work over more than one class if that makes sense
sub set_text {
	my $self = shift; 	# The token object
	my $text = shift;	#
	$self->{RAW} = $text;
	$self->{LEGACYDATA}->{orth} = $text;
	return $self;
}

# JE 2020-11-10
# This overrides the default inherited method (which simply loops recursively
# over contained arrays). Here' we're at road's end and print the token's
# content.
##### (TODO) We should be permitting a lot of configuration here.
# Either by setting it when the preprocessor object is condigured, or by
# passing configs when we call the method.
##### (TODO) This method name won't last. Change to something more descriptive when done.
##### (TODO) probably a good idea to generalise this
# Turn in into a call that performs an arbitrary action on all tokens under
# the object on which it was called.
sub print_tokens {
	my $self = shift;
	my $ph = shift || \*STDERR;
	my $text = $self->{LEGACYDATA}->{orth};
	$text =~ m/^\s+$/ && return;
#	print $ph "PT $text\n";
}
#***************************************************************************#
# print_legacy
#
# Print out the information for this token in a table row.
#
# - $ph File handle
# - $format Format for printf
#
#***************************************************************************#
sub print_legacy {
	my $self = shift;
	my $ph = shift || \*STDERR;
	my $format = shift;

	my $l = $self->{LEGACYDATA};

	#print STDERR "HEJ\t$l->{orth}\t$l->{p_entropy}\n";

	printf $ph $format,
		$self->{index},
		$l->{orth},
		$l->{pos},
		$l->{morph},
		$l->{isInDictionary},
		$l->{exprType},
		$l->{exp},
		$l->{pron},
		$l->{lang},
		$l->{dec},
		$l->{pause},
		$l->{textType},
		$l->{ssml},
		$l->{freq_no_case},
		$l->{g_entropy},
		$l->{p_entropy},
		$l->{self_distance}

}
#***************************************************************************#
# legacy_print_width
#
# Determine the minimum character width required for each
# column in a table printout.  These widths are used
# for building a printf format string.
#
# -  $acc Accumulator callback function.
#
#***************************************************************************#
sub legacy_print_width {
   my $self = shift;
   my $acc = shift;

   my $l = $self->{LEGACYDATA};

   $acc->(
       $self->{index} == 0 ? 1 : int(log($self->{index})/log(10)) + 1,
       length $l->{orth},
       length $l->{pos},
       length $l->{morph},
       length $l->{isInDictionary},
       length $l->{exprType},
       length $l->{exp},
       length $l->{pron},
       length $l->{lang},
       length $l->{dec},
       length $l->{pause},
       length $l->{textType},
       length $l->{ssml},
       length $l->{freq_no_case},
       length $l->{g_entropy},
       length $l->{p_entropy},
       length $l->{self_distance}
   );
}
#***************************************************************************#
#	Printing all information to file			#
#								#
#	CT 151112						#
#***************************************************************************#
sub printOut {

	my $output_file = shift;
	my $self = shift;

	use Data::Dumper;
	open my $fh_OUTPUT, '>', $output_file or die "Cannot open OUTPUT $output_file: $!\n";

	#print $fh_OUTPUT Data::Dumper->Dump($self);
	print $fh_OUTPUT Dumper $self;

	#print $fh_OUTPUT "\n---------------------------------------------------------------------------------------------------------------------\nINDEX\tORTH\tPOS\tMORPH\tDICT\tEXPRTYPE\tEXP\tPRON\tLANG\tDECOMP\tPAUSE\tTEXTTYPE\tSSML\n---------------------------------------------------------------------------------------------------------------------\n";
	# orth
	#foreach my $index (sort{ $a <=> $b } keys %orth ) {	# OO CHANGE 201106
	#	print $fh_OUTPUT "$index\t$orth{ $index }\t$pos{ $index }\t$morph{ $index }\t$isInDictionary{ $index }\t$exprType{ $index }\t$exp{ $index }\t$pron{ $index }\t$lang{ $index }\t$dec{ $index }\t$pause{ $index }\t$textType{ $index }\t$ssml{ $index }\n\n";	# OO CHANGE 201106
	#}

}
#***************************************************************************#

1;

__END__

=pod

=head1 NAME

C<MTM::TTSToken>

=head1 SYNOPSIS

   use MTM::TTSNodeFactory qw(newtoken);

   my $token = newtoken();

   $token->set_text($chunktext);

=head1 DESCRIPTION

=head1 METHODS

=head2 C<new>

C<new> is the constructor method.  Don't call the this directly, use L<TTSNodeFactory::newtoken>.

=head2 C<$token->set_text($text)>

Set the text of the token.  C<$text> is the normalized plain text of the token.

=head2 C<$token->pos_tag()>

Analyze the token in context and tag it with possible attributes.  See L<MTM::TTSChunk/pos_tag>.

=head2 C<$token->print_legacy($filehandle, $format)>

Print the tokens attribute as a table row to the file handle specfied by C<$filehandle> and format the
row using the printf format string C<$format>.

This method should be called from document or preprocessor level, where the appropriate format string
will be calculated from all tokens in the contents of the document or preprocessor.

=head2 C<$token->legacy_print_width($acc)>

Calculate the minimum widths needed for displaying the attributes of this token.  The parameter C<$acc>
is a reference to a subroutine that will be called with the minimum widths needed
(C<$acc->(@minium_widths)).  These widths can be used to produce a printf format string for L</print_legacy>.

=head2 C<$token->print_tokens($filehandle)>

Print the token orthogography to the specified file handle C<$filehandle>, or to C<STDERR> if no file handle is given.

Returns the value in LEGACYDATA

=head2 C<$token->printOut>

Debug print of C<$token>.  L</print_legacy> can be used instead to get a nicer output format.

=cut

