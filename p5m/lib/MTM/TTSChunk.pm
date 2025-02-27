package MTM::TTSChunk;
#
 # Pod documentation after __END__ below.
#
#*****************************************************************************#
# 
# MTM::TTSChunk - Perl data object holding TTS tokens and tokenization 
# settings
#
# The implementation is a tied array (MTM::Tie::CursorArray) holding 
# the tokens.
#
# ****************************************************************************#
use strict;
use warnings;
use utf8;

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM::TTSNodeFactory);
use MTM::Tokenisation::SplitTokens;


require MTM::Legacy;

#*****************************************************************************#
#
# Constructor
#
# The constructor is simply an alias for
# my $obj = tie(my @documentarray, 'MTM::Tie::CursorArray');
# 
sub new {
	my $proto = shift;
	return tie(my @a, $proto);
}

#*****************************************************************************#
#
# Chunk management methods 
# 
# The management of chunks is broadly divided into a series of process 
# steps:
# 
# - Setting chunk text
# - Tokenizing
# - TTS Processing
# - Output
# 
#*****************************************************************************#
#
# Add new document object
#
##### (TODO) We want to support a wide range of documents loading methods here
#
# Currently, we take in each document from a separate file handle that is 
# passed from the calling script. We will add convenience methods later.
#
sub set_text {
	my $self = shift; 	# The chunk object
	my $text = shift;	# 
	$self->{RAW} = $text;
	return $self;
}
sub tokenise {
	my $self = shift;
	##### (TODO) This is a temporary dummy method
	my $string = $self->{RAW};

	# CT 210812 Sub moved to MTM::Tokenisation::SplitTokens
	##### Don't send anything to $self	my @tokens = MTM::TTSChunk::Tokenize->MTM::Tokenisation::SplitTokens::splitTokens($string, $self->get_legacy('runmode'));
	# CT 210901
	my @tokens = MTM::Tokenisation::SplitTokens::splitTokens($string, $self->get_legacy('runmode'));

	# print STDERR "TTT @tokens\n";

	foreach my $token (@tokens) {
		#print STDERR "TTT $token\n";
		my $tobj = MTM::TTSNodeFactory->newtoken;
		$tobj->set_text($token);
		$self->PUSH($tobj);
	}

	##### ********************************************************************#####
	##### Temporary PoS tagging can be done here!	CT 210824
	use MTM::POSTagger;
	use DB_File;
	#my ( $bestTag, $prob, $TagConf ) = MTM::POSTagger::TagWords( 'void', @tokens);
	my( $poslist, $morphlist ) = &MTM::POSTagger::runPosTagger( @tokens, 'void' );
	my @poslist = @$poslist;
	my @morphlist = @$morphlist;

	##### INSERT POS AND MORPH
	my $c = 0;
	foreach my $token (@{ $self->{ARRAY} }) {
		MTM::POSTagger::insert_postags($token, $self, \@poslist, \@morphlist, $c);
		$c++; 
	}
	##### ********************************************************************#####

	return $self;
}

my @analysis;
my @expansion;
BEGIN {

	@analysis = ();

	for my $analysis (
		'Reference',
		'Abbreviation',
		'Initial',
		'Date',
		'Time',
		'Email',
		'URL',
		'Filename',
		'RomanNumber',
		'Acronym',
		'Decimal',
		'PhoneNumber',
		'Ordinal',
		'Year',
		'Interval',
		'Currency',
		'LanguageDetection',
		'LanguageDetection2'
		) {

		eval "push \@analysis, { name => '$analysis', markup => \\\&MTM::Analysis::${analysis}::markup }";

		die $@ if ($@);
	}

	@expansion = ();

	for my $expansion (
		'ReferenceExpansion',
		'CharacterExpansion',
		'NumeralExpansion',
		'AbbreviationExpansion',

		) {

		eval "push \@expansion, { name => '$expansion', markup => \\\&MTM::Expansion::${expansion}::expand }";

		die $@ if ($@);
	}

}

sub pos_tag {
	my $self = shift;
 # 221102 JE This does not seem to be used at all, at least not for 
 #           SSML tests. So there's a lost of conditional tests for no reason.
	my $stop_after = shift; # For testing
	$self->NEXT::pos_tag;

	#my $t = localtime;
	#print STDERR "POS_TAG_IN_CONTEXT START\t$t\n";	##### PRINT

	##### ********************************************************************#####
	##### This is commented out since proper pos tagging + pos and morph insertion
	##### is done in the tokenise sub above.	CT 210825
	# The following should use 
	#my $i = 0; # FIX!!
	#foreach my $token (@{ $self->{ARRAY} }) {
	#	MTM::TPBTag::postag_in_context($token, $self);
	#}

	#my $t = localtime;
	#print STDERR "POS_TAG_IN_CONTEXT DONE\t$t\n";	##### PRINT

	for my $analysis (@analysis) {
		for ($self->reset; my $token = $self->current; $self->move(1)) {
			&{$analysis->{markup}}($token, $self);
		}
		return if defined $stop_after && $stop_after eq $analysis->{name};
	}

	for my $expansion (@expansion) {
		for ($self->reset; my $token = $self->current; $self->move(1)) {
			&{$expansion->{markup}}($token, $self);
		}
		return if defined $stop_after && $stop_after eq $expansion->{name};
	}

	#$t = localtime;
	#print STDERR "EXPANSIONS DONE\t$t\n";	##### PRINT

	# PRONUNCIATION
	for ($self->reset; my $token = $self->current; $self->move(1)) {
		MTM::Pronunciation::Pronunciation::pronounce_and_insert( $token, $self, '-' );
	}

	# PAUSES
	for ($self->reset; my $token = $self->current; $self->move(1)) {
		MTM::Pause::pause( $token, $self, '-' );
	}

	##### SSML		CT 210902	This one should live somewhere else!
	#for ($self->reset; my $token = $self->current; $self->move(1)) {
	#	MTM::SSML::unsupervisedSSML( $token, $self, '-' );
	#}

	##### SSML_sentence		CT 240207	This one should live somewhere else!
	for ($self->reset; my $token = $self->current; $self->move(1)) {
		MTM::SSML::create_SSML::insert_SSML( $token, $self, '-' );
	}

	return $self;
}
#***********************************************************#
# print_legacy
#
# Print out the information for this token in a table row.
#
# - $ph File handle
# - $format Format for printf
# - $output_header function for outputting the header
#***********************************************************#
sub print_legacy {
	my $self = shift;
	my $ph = shift || \*STDERR;
	my $format = shift;
	my $output_header = shift;

	$output_header->();

	$self->NEXT::print_legacy($ph, $format);
}

package MTM::TTSChunk::Tokenize;

use strict;
use locale;

# JE 2020-11-09 refactoring - removing these one by one in the proecess
# our $MTM::Legacy::Lists::sv_abbreviation_list;
# our $MTM::Legacy::Lists::sv_abbreviation_list_case;
# our $MTM::Vars::sv_acronym_endings;
# our $MTM::Vars::fraction;
# our $MTM::Vars::delimiter;
# our $MTM::Vars::characters;
# our $MTM::Vars::singleQuote;
# our $MTM::Vars::month;
# our $MTM::Vars::sv_month_abbreviation;
# our $MTM::Vars::sv_units;
# our $MTM::Vars::sv_weekday;
# our $MTM::Vars::sv_weekday_abbreviation;
# our $MTM::Vars::sv_ordinal_endings;
# our $MTM::Vars::sv_word_endings;
# our $letter;               
# our $MTM::Legacy::Lists::multiwordList;        ##### (NB) Is needed and is likely built elsewhere

# our $runmode;




return 1;

__END__

=pod

=head1 NAME

C<MTM::TTSChunk>

=head1 SYNOPSIS

   use MTM::TTSNodeFactory cc(newchunk);

   my $chunk = newchunk();

   $chunk->set_text($chunktext);

   $chunk->tokenise;

   $chunk->pos_tag;

=head1 DESCRIPTION

=head2 METHODS

=head2 C<new>

C<new> is the constructor method.  Don't call the this directly, use L<TTSNodeFactory::newchunk>.

=head2 C<$chunk->pos_tag([ $stop_after ])

Analyze the chunk and and classify and tag the with possible attributes.

The chunk must be normalized and tokenized before this method can be called.  Normally this method is
called from the document level and it is propagated to the chunks via the recursion mechanism in
L<MTM::Tie::CursorArray>.

For testing purposes the processing can be terminated after the step specified by the parameter C<$stop_after>.

=head2 C<$chunk->print_legacy($filehandle, $format, $output_header)

C<print_legacy> prints a table comprised by the column headers specified in the array ref
C<$output_header> followed by one row for each token.

Normally the method <print_legacy> in L<MTM::TTSPreprocessor> called to produce a complete table of all
tokens in the processing session.  The C<$output_header> and the printf format string C<$format> is
produces by the method C<print_legacy> in L<MTM::TTSDocument>.

=head3 PARAMETERS

=over

=item C<$filehandle> - the file handle to print to.

=item C<$format> - the printf format string to use.

=item C<$output_header> - the row that contains the table headers.

=back

=head2 C<$chunk->set_text($text)>

C<set_text> sets the text of the chunk.  The chunk must be normalized and tokenized after the text have
been set by calling the appropriate methods.  The parameter C<$text> is a plain text string.

=head2 C<$chunk->tokenise>

Tokenize the string.

NOTE: inconsistent use of British vs. American spelling.

=cut
