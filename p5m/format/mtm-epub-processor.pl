#!/usr/bin/perl -w

use strict;
use warnings;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use XML::LibXML;
use Getopt::Long;
use vars qw( $infile $Out $Validate $validation $Debug );

# SSML specific
my $nsuri = 'http://www.w3.org/2001/10/synthesis';
my $nspref = 'ssml';
#my $nstag = 'phoneme';
my $nstag = 'span';
my $ssmlAttrKey = 'ssml:alphabet';
my $ssmlAttrVal = 'x-sampa';

my %atthash = (
	"ssml:alphabet" , "ipa",
	"ssml:ph" , "j aa4 g",
);
my @att = keys %atthash;

# Indexes for character counter
my $textnodecounter = 0;
my $charcounter = 0;

$infile = '';
$Out  = '';
$Validate = 1;
$validation = '';
$Debug = 0;

GetOptions (
	'infile=s'   => \$infile,
	'outfile=s'  => \$Out,
	'validate=s' => \$Validate,
	'val=s'  => \$validation,
	'debug' => \$Debug,
	'help'           => sub { pod2usage(-verbose => 1); exit },
)  or pod2usage(-verbose => 1) && exit;;


### start MTM::TextContainer::EPUB::validate
#system("java -jar ../epubcheck-4.2.4/epubcheck.jar $infile") if $Validate;
###   end MTM::TextContainer::EPUB::validate

### start MTM::TextContainer::EPUB::infile
###       MTM::TextContainer::EPUB::read
###       MTM::TextContainer::EPUB::archive
# Get access to the contents of the EPUB Zip file
my $epub = read_zip($infile);
###   end MTM::TextContainer::EPUB::infile
###       MTM::TextContainer::EPUB::read
###       MTM::TextContainer::EPUB::archive


### start MTM::TextContainer::EPUB::browse
###       MTM::TextContainer::EPUB::contentfiles
# Set the goblal XPath for querying DOM object
my $xpc = setupxpath();

# Get the content file listing
my @contentfiles = get_content_filenames($epub);
### end   MTM::TextContainer::EPUB::browse
###       MTM::TextContainer::EPUB::contentfiles

# Process EPUB files
foreach my $contentfile (@contentfiles) {
	my $dom = dom_from_zip($contentfile, $epub);
	$dom->documentElement->setNamespace( $nsuri, $nspref, 0 );
	$dom->documentElement->setAttribute( $ssmlAttrKey, $ssmlAttrVal );
	
	# Query information of this file as:
	# a) DOM metadata info
	#epub_metainfo( $dom );
	
	# Validate the document content against 
	# DTD'n or XML Schema
	if ( $validation eq "schema" ) {
		schema_validation( $dom );
	} else {
		if ( $validation eq "dtd" ) {
			dtd_validation( $dom );
		}
	}
	
	# Find all text nodes
	my $textnodes = textnodes( $dom );	
	
	if ( $contentfile eq "EPUB/DTB34710-005-introduction.xhtml") {
		my ( $charindex, $chunkstarts ) = charactercounter_index( $textnodes );
		
		# Start sequence $start and $length characters defined:
		# <ssml: phoneme alphabet = "cprc" ph = "j aa4 g">
		my $start = 131;
		my $length = 3;
				
		# Make sure the first and last characters are in the same text node, otherwise warn and stop processing
		unless ( issamenode( $charindex, $start, $length ) ) {
			print STDERR "The $length characters from $start are not all from the same text node. We do not know how to deal with this yet!\n";
			warn "TODO: multi-node spans";
		}
		
		my $newnode = createnewnode( $nstag, $nsuri, $nspref, @att );
		my $node = insertnode( $textnodes, $charindex, $chunkstarts, $newnode, $start, $length );
	}
	replace_content($contentfile, $epub, $dom);
}

open OUT, ">$Out" or die $!;
print STDERR "Writing to $Out\n";

unless ( $epub->writeToFileHandle( \*OUT ) == AZ_OK ) {
	print STDERR "There was a problem with the writing\n";
}

#system("java -jar ../epubcheck-4.2.4/epubcheck.jar $Out") if $Validate;

# This subroutine will:
# a) Setup an XPath object to simplify namespace management 
#     in XPath search. We set the XHTML namespace to use the 
#     'x' prefix here (as the XMTML docs we read uses the default
#     namespace for XHTML, but we need to name it explicitly)
# b) Setup XPath for EPUB META-INF/container Namespace
# c) Setup XPath for EPUB OPF standard
# @see https://metacpan.org/pod/XML::LibXML::Node)
sub setupxpath {	
	my $xpc = XML::LibXML::XPathContext->new();
	$xpc->registerNs( 'container', 'urn:oasis:names:tc:opendocument:xmlns:container' );
	$xpc->registerNs( 'opf', 'http://www.idpf.org/2007/opf' );
	$xpc->registerNs( 'x', 'http://www.w3.org/1999/xhtml');
	return $xpc;
}

# This subroutine will:
# a) Finds all the text nodes from the document(s)
# @ see https://metacpan.org/pod/XML::LibXML::NodeList
sub textnodes {	
	my $doc = shift;
	my $bodynode_xpath = '/x:html/x:body';
	my $xpath = '//text()';
	my $topnode = $xpc->find($bodynode_xpath, $doc)->item(0) or die "Could not find $bodynode_xpath";
	my $nodelist = $xpc->find($xpath, $topnode) or die "Could not find $xpath";
	return $nodelist;
}

# This subroutine will:
# a)
sub charactercounter_index {
	my $textnodes = shift;
	my @chars = ();
	my @chunks;
	foreach my $tnode ( $textnodes->get_nodelist() ) {
		push @chunks, $charcounter;
		print STDERR "$textnodecounter \t>>>\t $tnode \n" if $Debug;
		foreach my $char (split('', $tnode->data)) {
			print STDERR "$textnodecounter \t $charcounter \t>>>\t' $char '\n" if $Debug;
			push @chars, [$char, $textnodecounter+1];
			$charcounter++;
		}
		$textnodecounter++;
	}
	return (\@chars, \@chunks);
}

# This subroutine will:
# a)
sub issamenode {
	my $chars = shift;
	my $s = shift;
	my $l = shift;
	my $e = $s + $l;
	print STDERR "Char $s is in textnode " . $chars->[$s]->[1] . "\n" if $Debug;
	print STDERR "Char $e is in textnode " . $chars->[$e]->[1] . "\n" if $Debug;
	return $chars->[$s]->[1] == $chars->[$e]->[1]?1:0;
}

# This subroutine will:
# a)
sub createnewnode {
	my $tag = shift;
	my $ns = shift;
	my $prefix = shift;
	my @att = @_;
	my $newnode = XML::LibXML::Element->new( $tag );
	for my $att (@_) {
		$newnode->setAttribute( $att, $atthash { $att } );
	}
	return $newnode;	
}

# This subroutine will:
# a)
sub insertnode {	
	my $tns = shift;
	my $ci = shift;
	my $tnss = shift; # Text node starts
	my $node = shift;
	my $s = shift;
	my $l = shift;
	my $tni = $ci->[$s]->[1];
	my $tn = $tns->get_node( $tni );	
	$tns = $tnss->[$tni-1]; # the start position of the current text node
	
	my $innerstart = $s - $tns; # The start position within the text node
	
	# If $innerstart == 0 then we have no left context
	my $innerend = $innerstart + $l; # The end position within the text node
	
	# If $innerend == $tn->size then we have no right
	my $seq = $tn->substringData( $innerstart, $l );
	my $lc = $tn->substringData( 0, $innerstart );
	my $rc = $tn->substringData( $innerend, ( length( $tn->data ) - $innerend ) );
	
	# Add the currewnt sequence to the node
	$node->appendChild(XML::LibXML::Text->new( $seq ) );
	
	# Swap the text node for the new node
	$tn->replaceNode( $node );
	
	# If the contexts exist add them
	$node->parentNode->insertBefore(XML::LibXML::Text->new( $lc ), $node )
	
	if $lc ne '';	
	# If right context existed, stick it in a textnode and insert after the new node
	$node->parentNode->insertAfter( XML::LibXML::Text->new( $rc ), $node ) if $rc ne '';
	
	return $node;
}

# This subroutine will:
# a) Replaces a contentn file in an EPUB book 
# with the contents of a modified DOM
sub replace_content {
	my $file = shift;
	my $zip = shift;
	my $dom = shift;
	print STDERR "Replacing contents of $file\n" if $Debug;
	
	my $member = $zip->memberNamed($file);
	$member->contents($dom->toString);
	# This really should work as an in-place substitution
	# Using long-form of the call here for clarity
	#	$zip->contents(
	#		memberOrZipName => $file, 
	#		contents        => $dom->toString,
	#	);
	print STDERR $member->contents . "\n" if $Debug;
}

# This subroutine will:
# a) 
sub dtd_validation {
	
	# XHTML Strict
	# PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    # SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
	
	# XHTML Transitional
	# PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    # SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
	
	my $public_id_trans = "-//W3C//DTD XHTML 1.0 Transitional//EN";
	my $system_id_trans = "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd";
	
	my $public_id = "-//W3C//DTD XHTML 1.0 Strict//EN";
	my $system_id = "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd";
	my $dtd = XML::LibXML::Dtd->new( $public_id, $system_id );
								
	my $docfile = shift;
	eval { $docfile->validate($dtd) };
	my $eval_result = $@;
	print STDERR "DTD evaluation result: $eval_result\n" if $Debug;
}

# This subroutine will:
# a) 
sub schema_validation {
	
	 # Schemat for XHTML1.0 located at xmlns - http://www.w3.org/1999/xhtml 
	 # http://www.w3.org/2002/08/xhtml/xhtml1-strict.xsd
	 
	 my $filename_or_url = "http://www.w3.org/2002/08/xhtml/xhtml1-strict.xsd";
	
	 my $xmlschema = XML::LibXML::Schema->new( location => $filename_or_url, no_network => 0 );
	 
	my $docfile = shift;
	print STDERR "Validating now : $docfile \n" if $Debug;
	
	eval { $xmlschema->validate($docfile) };
	my $eval_result = $@;
	print STDERR "Schema  evaluation result: $eval_result\n" if $Debug;
}

# This subroutine will:
# a) Reads in and parses one content file from a Epub book file
sub dom_from_zip {
	my $file = shift;
	my $zip = shift;
	print STDERR "Reading content file: $file\n" if $Debug;
	my $contentstring = $zip->memberNamed($file)->contents;
	my $contentdom = XML::LibXML->load_xml(string => $contentstring);
	die;
	return $contentdom;
}

# This subroutine will:
# a) Check where the OPF-file is, 
# b) Reads it looking for content files
# EPUB content file names. It returns a list of names.
sub get_content_filenames {
	
	my $zip = shift;
	
	# EPUB3 standard (get the reference and add here)
	my $meta_inf_file = 'META-INF/container.xml'; 
	print STDERR "Looking in $meta_inf_file for pointer to OPF\n" if $Debug;
	my $meta_inf_contents = $zip->memberNamed($meta_inf_file)->contents;
	
	# DOM parsning
	my $meta_inf_dom = XML::LibXML->load_xml(string => $meta_inf_contents);
	
	# And pick up the correct full-path attribute pointing at the OPF
	my $opf_file = $xpc->find( 'string(//container:rootfile/@full-path)', $meta_inf_dom);
	print STDERR "Will look in $opf_file for content pointers\n" if $Debug;
	
	my $opf_contents = $zip->memberNamed($opf_file)->contents;
	my $opf_dom = XML::LibXML->load_xml(string => $opf_contents);
	
	# Obtain the XHTML content which is part of the href attribute
	# of item elements with media-type application/xhtml+xml	
	my $nodelist = $xpc->find( '/opf:package/opf:manifest/opf:item[@media-type="application/xhtml+xml"]/@href', $opf_dom);	
	my @files = map { "EPUB/" . $_->getValue } $nodelist->get_nodelist;
	
	return @files;
}

# This is just a Zip file reading routine. It leaves the file 
# untouched on disk, and just picks up the structure so that it's
# accessible via the zip object.
sub read_zip {
	my $file = shift;
	# Open the test file
	# Read a Zip file
	my $zip = Archive::Zip->new(); # Create the Zip object

	# Shortcutting status check here, could be done better
	unless ( $zip->read( $file ) == AZ_OK ) {
		die 'read error';
	}
	return $zip;
}

# Print the document (file) metadata information,
# for instance:
# a) metadata
# b) type of document
# c) element information
sub epub_metainfo {
    my $doc = shift;
	my $element = $doc->documentElement;
    print STDERR 'Document encoding is: ', $doc->encoding . "\n";
    my $is_or_not = $doc->standalone ? 'is' : 'is not' . "\n";
    print STDERR "Document $is_or_not standalone" . "\n";
	print STDERR 'The $element is a: ', ref($element) . "\n";
    print STDERR 'The Node name $element->nodeName is: ', $element->nodeName . "\n\n";
}

=pod 

=head1 NAME

mtm-epub-processor.pl - Script to process XHTML files and insert SSML elements

=head1 SYNOPSIS

C<perl epub-pack-unpack.pl OPTIONS

=head1 OPTIONS

=head2 C<--infile>

The EPUB to be unpacked

=head2 C<--outfile>

The EPUB to be produced

=head2 C<--validate>

Set to 1 to perform validation of Epubcheck from W3C, otherwise 0 if wants to be skipped

=head2 C<--val>

The standard to validate against, e.g. DTD or Schema

=head2 C<--debug>

If desired to see specific debug output

=back

=head1 Description

	a) Read a number of parameters as: a) ePub to process, b) Epub to produce, c) Validate against W3C epubcheck, d) Validate against DTD or Schema
	c) Process ePub file(s) in the current directory
	d) With the use of PERL process the documents with extention XHTML	
    e) Process of content files with goal to get textnodes, index of words in the document, obtain XPath element, etc. 
	f) Validate the book prior and after processing
	g) Process the book with archive zip in place

=cut