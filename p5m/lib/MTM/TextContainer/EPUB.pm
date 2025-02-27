package MTM::TextContainer::EPUB;
#*****************************************************************************#
#
# MTM/TextContainer/EPUB.pm 
#
# EPUB management handling class for use with MTM's TTS preprocessing system
# 
#*****************************************************************************#
use strict;      # NB!!! remove before release
use warnings;  # NB!!! remove before release

use Path::Class;
use XML::LibXML;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM::TextContainer);

sub _init {
	my $self = shift;

	# Set up the Xpath context. We keep this visible here, as the details will be made configurable in time.
	# The actual context creation is placed in the parent, since it's shared by EPUB and XHTML.
	# Object creation that dies on fail, which is what we want. 
	# No extra error handling required
	# NB!!! These are the prefix mappings according to the spec. We lileky should use tem:
	# https://www.w3.org/publishing/epub3/epub-packages.html#sec-overview-pfx

	my $xpc = $self->newxpc(
		# Setup XPath for EPUB META-INF/container Namespace
		'container',  'urn:oasis:names:tc:opendocument:xmlns:container',
		# Setup XPath for EPUB OPF standard
		'opf',        'http://www.idpf.org/2007/opf',
	);

	$self->xpc($xpc) or die "Cannot set Xpath context";

	# And allow for the parents _init to run as well.
	return $self->SUPER::_init;
}

SETGET: {
	##### JE: These will be generalised before release - see issue #73
	sub archive {
		my $self = shift;
		my $archive = shift;
		return exists($self->{ARCHIVE})?$self->{ARCHIVE}:undef
			unless $archive;
		# Check existance and readbility

		# Store the filename and path_info
		# This returns the set value, which is standard for a setget method
		return $self->{ARCHIVE} = $archive;
	}
	sub contentfiles {
		my $self = shift;
		my $contentfiles = shift;
		return exists($self->{CONTENTFILES})?$self->{CONTENTFILES}:undef
			unless $contentfiles;
		# Check existance and readbility

		# Store the filename and path_info
		# This returns the set value, which is standard for a setget method
		return $self->{CONTENTFILES} = $contentfiles;
	}
	### JE This should be moved up to more genral level for error/result feedback
	### JE in a later version
	sub result {
		my $self = shift;
		my $result = shift;
		return exists($self->{RESULT})?$self->{RESULT}:undef
			unless $result;
		# Check existance and readbility

		# Store the filename and path_info
		# This returns the set value, which is standard for a setget method
		return $self->{RESULT} = $result;
	}
}

# This sub:
# a) Will open the Zip archive that infile points to
# b) It's assumed that file from $file exists and can be read
sub read {
	my $self = shift;
	my $file = $self->infile;

	# Open Zip with error handling.
	# Create the Zip object
	my $zip = Archive::Zip->new();

	# Archive::Zip encodes the actual error message, and this is what should be used instead
	unless ( $zip->read( $file ) == AZ_OK ) {
		$self->result("$file could not be opened"), 
		return undef;
	}

	# Store the open archive object and return;
	return $self->archive($zip);
}

# This sub:
# a) Set up XPtach context
# b) Browse the content files and builds a list out of them
sub browse {
	my $self = shift;

	# Find the content files and store
	# EPUB3 standard (get the reference and add here)
	# Will be moved out to config in later version
	my $meta_inf_file = Path::Class::File->new('META-INF/container.xml');

	# Feedback on most chatty level
	$self->fb(ref($self) . " looking for $meta_inf_file to find pointer to OPF");
	my $meta_inf_contents = $self->archive->memberNamed( $meta_inf_file )->contents;

	# DOM parsning
	my $meta_inf_dom = XML::LibXML->load_xml(string => $meta_inf_contents);

	# Find the "Package document", 
	# @see <https://www.w3.org/publishing/epub3/epub-packages.html#sec-package-content-conf>
	# And pick up the correct full-path attribute pointing at the OPF file
	# Make part of config in later version
	my $search = 'string(//container:rootfile/@full-path)';
	# Should add some error handling here, but since we'll be doing this kind of thing 
	# several times, we'd be better off with a helper method e.g. _zip_path
	# that also checks for existance
	my $opf_file = Path::Class::File->new( $self->xpc->find($search , $meta_inf_dom) );
	$self->fb(ref($self) . " will look in the Package document ($opf_file) for content pointers");

	my $opf_contents = $self->archive->memberNamed($opf_file)->contents;
	my $opf_dom = XML::LibXML->load_xml(string => $opf_contents);

	# Obtain the XHTML content which is part of the href attribute
	# of item elements with media-type application/xhtml+xml
	# Make part of config later
	$search =  '/opf:package/opf:manifest/opf:item[@media-type="application/xhtml+xml"]/@href';
	my $nodelist = $self->xpc->find($search, $opf_dom);

	# We have two possibilities for each pointer here: absolute or relative (the
	# latter then _must_ be relative to the location of the package document - see
	# https://www.w3.org/publishing/epub3/epub-packages.html#bib-rfc3987)
	my @contentfiles;
	foreach my $cf ( $nodelist->get_nodelist ) {
		my $cf_parsed = Path::Class::File->new( $cf->getValue );
		if ($cf_parsed->is_absolute) {
			print STDERR "ABS! $cf_parsed\n";
#			push @contentfiles, $cf_parsed;
		}
		else {
			my $abs = Path::Class::File->new($opf_file->dir, $cf_parsed);
			push @contentfiles, Path::Class::File->new($abs);
#			print STDERR "REL! $abs\n";
		}
	}
	$self->contentfiles(\@contentfiles);
	return $self;
}

# This sub
# a) Takes a fully qualified pointer to a content file in the current
#     EPUB object
# b) Returns that content files as an MTM::TextContainer::XHTML object
sub contentdom {
	my $self = shift;
	my $contentfile = shift;

	# Feedback on most chatty level
	$self->fb(ref($self) . " reading for $contentfile for content");

	# NB!!! the processing fails here, with a 
	# NB!!! "Can't call method "contents" on an undefined value"
	# NB!!! that is due to EPUB/TOC.xhtml not being found in
	# NB!!! the archive (this is testing with data/epub/test.epub)
	# NB!!! Donät know if it's because 
	# NB!!! - we find a bad path
	# NB!!! - tes.epub is faulty (don't think it is)
	# NB!!! - or some other bug (not so likely)
	# NB!!! - but we need to find this before we go on!
	my $contents = $self->archive->memberNamed($contentfile)->contents;

	# DOM parsning
	my $dom = XML::LibXML->load_xml(string => $contents);

	##### NB!! This doesn't really contain useful meta-info, we'd be interested in the EPUB metiinfo.,
	# We'll move this to XHTML object though, where it may make sense
	# Query information of this file as:
	# a) DOM metadata info
	# contentfile_metainfo( $dom );

	# Create new XHMTL object (this uses MTM::TextContainers object factory newxhtml)
	my $xhtml = $self->newxhtml;

	# Set the dom
	$xhtml->dom($dom);

	# return the new object
	return $xhtml;
}

# This sub:
# a) Will perform an extrenal EPUB validation, with help of W3C epubcheck
sub validate {
	my $self = shift;
	my $file = shift;

	# Set up validation code here.
	# It is ok to assume the existance of java 
	# (or better still, check for it and warn) and of epubcheck (same, check+warn is best).

	##### NB!!! Can't allow this until our environment is set up with epubcheck...
	#	system("java -jar epubcheck-4.2.4/epubcheck.jar $file") if $Validation;

	# Temp fake var holding an ever positive validation result (change to 0 to see what a failed validation would look like)
	my $val = 1; 
	if ($val) {
		# If validation is ok, we just return the object
		return $self;
	}
	else {
		# If validation goes wrong, store validation results and return undef
		$self->result("Validation of $file failed");
		return undef;
	}
}

# Print the document (file) metadata information,
# for instance:
# a) metadata
# b) type of document
# c) element information
sub contentfile_metainfo {
   my $doc = shift;
   my $element = $doc->documentElement;
   print STDERR 'Document encoding is: ', $doc->encoding . "\n";
   my $is_or_not = $doc->standalone ? 'is' : 'is not' . "\n";
   print STDERR "Document $is_or_not standalone" . "\n";
   print STDERR 'The $element is a: ', ref($element) . "\n";
   print STDERR 'The Node name $element->nodeName is: ', $element->nodeName . "\n\n";
}

1;

__END__

### NB!!! Add at least a minimum of documentation!

=pod

=head1 Name MTM::TextContainer::EPUB 

Class to handle EPUB books for the  MTM TTS preprocessing system

=head3 Methods

=head2 $epub->archive;

=head2 $epub->browse;

=head2 $epub->contentdom;

=head2 $epub->contentfile_metainfo;

=head2 $epub->contentfiles;

=head2 $epub->read;

=head2 $epub->result;

=head2 $epub->validate;

=cut