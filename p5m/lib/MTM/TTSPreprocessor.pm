package MTM::TTSPreprocessor;
#
# Pod documentation after __END__ below.
#
#*****************************************************************************#
#
# MTM::TTSPreprocessor - Perl data object holding settings for TTS
# preprocessing as well as an array of TTS documents to be processed
#
# The implementation is a tied array (MTM::Tie::CursorArray) holding
# the documents.
#
# Note that an MTM::TTSPreprocessing object, when fully built, can
# be assumed to have th following structure:
# MTM::TTSPreprocessing object is an array populated with
# MTM::TTSDocument objects, each of which is an array populated with
# MTM::TTSChunk objects, each of which is an array populated with
# MTM::TTSToken objects, each of which is an array populated with
# MTM::TTSCharacter objects (this last step is currently not implemented).
#
# So as a data structure, the MTM::TTSPreprocessing object is arrays
# within arrays four layers down. Note that these objects do not inherit
# each other, but they do inherit the same abstact class
# MTM::Tie::CursorArray, which overloads the arrays with extra methods
# and data.
#
# Building the structure is done from top to bottom, layer by layer. Each
# layer has its own method to populate its array based on the non-array
# data it contains.
# The input(s) to TTSPreprocessor gets read, normalized and then populates
# documents. The text in documents gets segmented into chunks. The chunks get
# further segmented into tokens.
#
# MTM::Tie::CursorArray assumes an array in attay structure and implements
# a recursive method launcher permitting select method calls to be accepted
# by objects at any level in the data structure and then propagated top
# down from that level. Useful for e.g. displaying a branch of the tree.
# (NB! Som eof this is clearly better placed elsewhere)
#
# ****************************************************************************#

use strict;
use warnings;

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM::TTSNodeFactory);
# Load all Legacy
use MTM::Legacy;
#use MTM::Legacy::Lists;

#*****************************************************************************#
#
# Document management methods
#
# The management of documents is broadly divided into a series of process
# steps:
#
# - Loading
# - Chunking         (delegeted to MTM::TTSDocument)
# - Tokenization     (delegeted to MTM::TTSChunk)
# - TTS Processing   (delegeted to MTM::TTSChunk and MTM::TTSToken)
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
# This is still utterly temporary code - do not document too carefully
#
# The shift() function is used to remove and return the first element from an array,
# which reduces the number of elements by one.
# The first element in the array is the one with the lowest index.
# It's easy to confuse this function with pop (), which removes the last element from an array.
sub read_document_from_handle {
	my $self = shift; 	# The preprocessor object
	my $handle = shift;	# The handle to be read
	my $doc = MTM::TTSNodeFactory->newdocument; # Set the scalar variable $doc to inherite from MTM::TTSDocument but let it be empty at first.
	$doc->read_document_from_handle($handle);
}

sub add_document {
	my $self=shift;
	my $doc = shift;
	return $self->PUSH($doc);
}

return 1;

__END__

# Most of the functionality is inherited from MTM::Tie::CursorArray
# Need to decide how to deal with that in POD

=pod

=head1 NAME

C<MTM::TTSPreprocessor>


=head1 SYNOPSIS

   use MTM::TTSNodeFactory qw(newpreprocessor);

   my $preprocessor = newpreprocessor();

   $preprocessor->read_document_from_handle($filehandle);

   $preprocessor->add_document($document);

=head1 DESCRIPTION

The TTSPreprocessor is a container for an array of documents (L<MTM::TTSDocument>) which inherits the
delegation of method calls to the objects in the array from L<MTM::Tie::CursorArray>.


The only document source currently supported is a plain text document read from a file handle.

=head1 METHODS

=head2 C<$preprocessor->read_document_from_handle($filehandle)>

Instantiates a document and adds it to the array.  The document reads the file handle to produce its content.

=head2 C<$preprocessor->add_document($document)>

Append an already instantiated document to the document array.

=head1 FUTURE DEVELOPMENT

There should be a abstract package for modules that provide lines of input.  For instance, we can have
only a method add_input_source which adds a document that have an abstract view of an input source.


=cut
