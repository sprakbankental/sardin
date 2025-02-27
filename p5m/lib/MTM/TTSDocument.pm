package MTM::TTSDocument;
#
# Pod documentation after __END__ below.
#
#*****************************************************************************#
#
# MTM::TTSDocument - Perl data object holding settings for TTS
# documents as well as an array of TTS chunks to be processed
#
# The implementation is a tied array (MTM::Tie::CursorArray) holding
# the chunks.
#
# ****************************************************************************#

use strict;
use warnings;

use MTM::TTSDocument::SplitSentence;
use MTM::TTSDocument::Normalise;

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM::TTSNodeFactory);

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
# Document management methods
#
# The management of documents is broadly divided into a series of process
# steps:
#
# - Loading
# - Chunking
# - Tokenization
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
sub read_document_from_handle {
	my $self = shift; 	# The preprocessor object
	my $handle = shift;	# The handle to be read
	my @raw = <$handle>;
	$self->{RAW} = \@raw;
	return $self;
}
# Normalize document
#
# Note that this normalises on document level, pre-chunking
# Mot also that settings are normally inherited from a superordinate document
# collection.
sub normalise {
	my $self = shift;
	# Hack just to test the flow
	my @normalised;
	my @raw = @{ $self->{RAW} };
	foreach my $line (@raw) {
		chomp $line;
		my $norm = MTM::TTSDocument::Normalise::normaliseTextPreproc(
			$line,
			$self->get_legacy('runmode'), # Legacy flag now passed as arument
		);
		push @normalised, $norm;
	}
	$self->{NORMALISED} = \@normalised;
	return $self;
}
# Chunk - split document into some sensible chunk size, e.g. sentences
sub chunk {
	my $self = shift;
	##### (TODO) Here we need to use a number of switches or some other method...
	##### (TODO) to plug in the chunking algorithm
	foreach my $line (@{ $self->{NORMALISED} }) {

		my $split = MTM::TTSDocument::SplitSentence::splitSentence($line);

		# CT 2022-05-10
		use MTM::Vars;
		if( $MTM::Vars::do_sent_split == 0 ) {
			$split =~ s/<SENT_SPLIT>//sg;
		}

		foreach my $chunktext (split('<SENT_SPLIT>', $split)) {
			my $chunk = MTM::TTSNodeFactory->newchunk;
			$chunk->set_text($chunktext);
			$self->PUSH($chunk);
		}
	}
}
# Tokenize
#sub tokenize_chunks {
#	my $self = shift;
#	foreach my $chunk (@{ $self->{ARRAY} })	 {
#		$chunk->tokenize;
#	}
#	return $self;
#}


#***********************************************************#
# print_legacy
#
# Print out the information for the tokens in this chunk.
#
# - $ph File handle
#***********************************************************#

# 20221104 JE this is some pretty obfuscated code, at least
#             outside of a C programme. And it does nothing
#             to use the facilites offered by the Sardin
#             code structure. There are places where functional
#             programming might help us (e.g. with speed or
#             robustness) but this isn't one of them.
#             At some point, code up a print that is simple
#             to configure and that runs on all Sardin structure
#             levels.
sub print_legacy {
	my $self = shift;
	my $ph = shift || \*STDERR;

	my @columns = (
		"INDEX",
		"ORTH",
		"POS",
		"MORPH",
		"DICT",
		"EXPRTYPE",
		"EXP",
		"PRON",
		"LANG",
		"DECOMP",
		"PAUSE",
		"TEXTTYPE",
		"SSML",
		"W_FREQ_SENT",
		"G_ENTROPY",
		"P_ENTROPY",
		"SELF_DIST"
		);

	my @print_width = map { length($_) + 1 } @columns;

	$self->legacy_print_width(sub {
		for (my $i = 0; $i < @print_width; $i++) {
			if ($_[$i] + 1 > $print_width[$i]) {
				$print_width[$i] = $_[$i] + 1;
			}
		}
	});

	my $print_format = '';

	for my $w (@print_width) {
		if ($print_format ne '') {
			$print_format .= "\t";
		}

		##### CT 2021-06-10
		$w = 1;

		$print_format .= "%-${w}s";
	}

	$print_format .= "\n";

	my $w = 0;
	map {  $w += $_ + 1; } @print_width;

	my $hr = "-" x $w;

	my $output_header = sub {
		print $ph $hr, "\n";

		printf $ph $print_format, @columns;

		print $ph "$hr\n";
	};

	$self->NEXT::print_legacy($ph, $print_format, $output_header);
}

return 1;

__END__

=pod

=head1 NAME

C<MTM::TTSDocument>

=head1 SYNOPSIS

   use MTM::TTSNodeFactory qw(newdocument);

   my $document = newdocument();

   $document->read_document_from_handle($filehandle);

   $document->normalise;
   $document->chunk;
   $document->print_legacy($filehandle);


=head1 DESCRIPTION

A document contains an array of chunks L<MTM::TTSChunk>.  C<MTM::TTSDocument> iherits delegation of
method calls to the chunks in the array from C<MTM::Tie::CursorArray>.

=head1 METHODS


=head2 C<new>

C<new> is the constructor method.  Don't call the this directly, use L<TTSNodeFactory::newdocument>.


=head2 C<$preprocessor->read_document_from_handle($filehandle)>

Reads input lines from a file handle into a buffer.

=head2 C<$document->normalise>

Normalize the document input in preparation for further processing.  See L</MTM::TTSDocument::Normalize>.

=head2 C<$document->chunk>

Divide the input into sentnences (see L</MTM::TTSDocument::SplitSentence>) and instantiate a
<MTM::TTSChunk> for each sentence and adds these to the array.

=head2 C<$document->print_legacy($filehandle)>

Print a formatted table of token attributes containing information about all tokens in the document's
chunks. C<$filehandle> can optionally be passed to direct the output to the given filehandle.  Default is
to print to stdout.

=head1 SUBPACKAGES

=head2 C<MTM::TTSDocument::Normalize>

This module provides a method for normalizing the input to prepare it for further processing.

=head2 C<MTM::TTSDocument::SplitSentence>

The module C<MTM::TTSDocument::SplitSentence> provides a method for determining how to split the input
into sentences.  All period characters do not terminate a sentence. For instance abbreviations may
contain period characters.

=cut
