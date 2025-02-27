#!/usr/bin/perl -w

use strict;
use warnings;
use 5.010;

use vars qw($Debug);
# to 0 to skip debug messages
# to 1 for normal debug
# to 2 to halt during processing
$Debug = 1; 

# Handle compressed files
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

# XML::LibXML module declaration
use XML::LibXML;

$|=1;

my ($infile, $process_dir) = @ARGV; 
die "Usage: $0 INFILE PROCESSDIR\n" if not $process_dir;

my $tmp_dir = "/tmp";
my $zipDir  = "$tmp_dir/$process_dir";
my $epubDir = "EPUB";
my $fullDir = "$zipDir/$epubDir";
my $zip      = Archive::Zip->new();
my @files_with_path = ();
my $files_with_path = "";
my $pre_validation_file = "preprocessing.xml";
my $post_validation_file = "postprocessing.xml";
my $epubcheck = "epubcheck-4.2.4/epubcheck.jar";
my $textnodecounter = 0;
my $charcounter = 0;

# SSML Specific
my $nsuri = 'http://www.w3.org/2001/10/synthesis';
my $nspref = 'ssml';
#my $nstag = 'ssml:phoneme';
my $nstag = 'phoneme';
my $ssmlAttrKey = 'ssml:alphabet';
my $ssmlAttrVal = 'x-sampa';

# EPub check specific
my $epubxpath = '//jhove:status';
my $epubns = 'jhove';
my $epubnsuri = 'http://schema.openpreservation.org/ois/xml/ns/jhove';

#my %attrhash = (
#	alphabet => "ipa",
#	ph => "k u0 m uux4 n",
#);

#alphabet => "cprc",
my %attrhash = (
	"ssml:alphabet" , "ipa",
	"ssml:ph" , "k u0 m uux4 n",
);

my @attr = keys %attrhash;

my %atthash = (
	"ssml:alphabet" , "ipa",
	"ssml:ph" , "j aa4 g",
);

my @att = keys %atthash;

# Unpack the Epub with perl ZIP library module
my $status = $zip->read($infile);

# Main subroutine
# This will:
# a) create the temporal directory where the ePub book will be processed
# b) copy the original 
# c) unpack the ePub file 
# d) place the files into the specific directory 
# e) call the next subroutine for further processing
sub main {
	
	# Make sure that process directory exists
	# otherwise create it and move the ePub book there
	# for further processing
	if (-d $zipDir) {
		mkdir $zipDir;
	}
	
	# Check that ZIP uncompression was successful,
	# otherwise finish the execution inmediately!
	unless ( $status == AZ_OK ) {
		die "Read of $zip failed\n" if $status != AZ_OK;
	}

    # Store the uncompressed files into an array
    my @members = $zip->memberNames();
	foreach my $member (@members) {
		$zip->extractMember($member, "$zipDir/$member");
	}
	
	# Call the subroutine that will obtain all 
	# the uncompressed files from the directory
	read_files_from_dir( $zipDir );
	
	# This will compress the directory where the book was processed
	# and save it with the name of the book
	packepubbook();
}

# Subroutine that will parse xthml files from
# the specified directory
sub read_files_from_dir {
	
		# Read the files from the specified directory
		my @files = get_files_from_dir($fullDir);
		
		# Iterate over the files found in the directory
		# and push them into an array
		foreach my $file(@files) {
			push @files_with_path, "$fullDir/$file";
			#print STDERR "$file\n";
		}
		
		if (-e $zipDir) {
			system("java -jar $tmp_dir/$epubcheck -out $tmp_dir/$pre_validation_file $zipDir -m exp");
			
			if ( -f "$tmp_dir/$pre_validation_file" ) {
				my $validationFile = XML::LibXML->load_xml(location => "$tmp_dir/$pre_validation_file");
				my $validationxpc = XML::LibXML::XPathContext->new();
				$validationxpc->registerNs( $epubns, $epubnsuri );
				
				my $valstatus = $validationxpc->find( $epubxpath, $validationFile );
				
				if ( $valstatus->to_literal() eq 'Not well-formed' ) {
					print STDERR 'This Epub is ' . $valstatus->to_literal() . " stopping processing\n";
					exit 1;
				}
				
				if ( $valstatus->to_literal() eq 'Well-formed' ) {
					print STDERR 'This Epub is ' . $valstatus->to_literal() . " continue processing\n";
				}
			}
		}
		
		# Call the subroutine that will start parsing the files
		process_epub_files(@files_with_path);
		
		return;
}

# Listing the files in the specified directory
# and returning them in an array after sort them,
# since the reading order is of high importance
sub get_files_from_dir {
	
	unless( opendir( INPUTDIR, $fullDir ) ) {
		die "\nUnable to open directory '$fullDir' \n";
	}
	
	my @files = readdir( INPUTDIR );
	closedir( INPUTDIR );
	@files = grep( /DTB(\d{5})-(\d{3})-(\w*).xhtml$/i, @files );
	
	my @sorted_files = sort @files;
	# Print the files for debugging purposes
	# foreach my $sorted_files ( @sorted_files ) {
	#	print STDERR $sorted_files;
	# }
	
	return @sorted_files;
}


# This subroutine will:
# a) Define the XPath expression
# b) Define some methods for output to STDERR, obtain metainfo, count of text and paragraph nodes 
# c) Call XML::LibXML to process the serialized XML file
# d) Define the xPath expression that will be used for this task, i.e. '//text()'
# e) Define the regular expression that will be used for search $string =~ / (\bkommun\b)|(\bkommun(.{1})\b) /
# f) Perform the substitution based on searched value
sub process_epub_files {
	
	my $doc;

	#Iterate over all the xhtml files in the array
	foreach $files_with_path(@files_with_path) {		
		$doc = readxml($files_with_path) or die;
		$doc->documentElement->setNamespace( $nsuri, $nspref, 0 );
		$doc->documentElement->setAttribute( $ssmlAttrKey, $ssmlAttrVal );
		
		# Validate the document against DTD XHTML strict
		dtd_validation( $doc, $files_with_path );
		
		# Print all the document(s) inside this EPUB book
		#print STDERR $doc . "\n";

		# Query information of this file as:
		# a) DOM metadata info
		#epub_metainfo( $doc );

		# Find all text nodes
		my $textnodes = textnodes( $doc );
		
		# Work with an specific file just to demonstrate the word counter and index, start and length function
		if ( $files_with_path eq "/tmp/epubProcess/EPUB/DTB34710-005-introduction.xhtml") {

			# In each content file, create a counter and start the count from 1 and continue for each character in the body
			# memorize what character index is the first in each text node
			# Note: line breaks ( \n ) are also counted as a character
			my ( $charindex, $chunkstarts ) = charactercounter_index( $textnodes );
			
			# Start sequence $start and $length characters defined:
			# <ssml: phoneme alphabet = "cprc" ph = "j aa4 g">
			my $start = 131;
			my $length = 3;
			
			# Make sure the first and last characters are in the same text node, otherwise warn and stop processing
			unless ( issamenode( $charindex, $start, $length ) ) {
				print STDERR "The $length characters from $start are not all from the same text node. We do not know how to deal with this yet!\n";
				die "TODO: multi-node spans";
			}
			
			my $newnode = createnewnode( $nstag, $nsuri, $nspref, @att );
			
			insertnode( $textnodes, $charindex, $chunkstarts, $newnode, $start, $length );
		}
		
		# When the search of Textnodes return with a List filled then the
		# next step is to process it and replace with ssml elements
		foreach my $textnode ($textnodes->get_nodelist) {

			# Here we look at each text node from the incoming list and 
			# with the help of a regex filter and send to the subroutine that
			# has the logic to work the textnode
			if($textnode =~ / (\bkommun\b)|(\bkommun(.{1})\b) / ) {
				textnodetoreplace($textnode, $nsuri, $nspref, $nstag, $1, @attr) or die "Insertion failed";
			}

			#print STDERR "And now it is '$textnode'\n" if $Debug;
			<> if $Debug > 1;
		}
		
		# print STDERR $doc . "\n";
		
		# Once the file has been processed, i.e. its nodes, namespaces, etc.
		# save it into the same file or another one.
		open my $out_fh, '>', $files_with_path or die;
		print {$out_fh} $doc;
		close $out_fh;
	}
	
	if ( -e $zipDir ) {
		system( "java -jar $tmp_dir/$epubcheck -out $tmp_dir/$post_validation_file $zipDir -m exp" );
		
		if ( -f "$tmp_dir/$post_validation_file" ) {
				my $validationFile = XML::LibXML->load_xml( location => "$tmp_dir/$post_validation_file" );
				my $validationxpc = XML::LibXML::XPathContext->new();
				$validationxpc->registerNs( $epubns, $epubnsuri );
				
				my $valstatus = $validationxpc->find( $epubxpath, $validationFile );

				if ( $valstatus->to_literal() eq 'Not well-formed' ) {
					print STDERR 'This Epub is ' . $valstatus->to_literal() . "\n";
				}

				if ( $valstatus->to_literal() eq 'Well-formed' ) {
					print STDERR 'This Epub is ' . $valstatus->to_literal() . "\n";
				}
		}
	}
	
	return 1;
}

# This subroutine will:
# a) Open filehandle to read XML file
sub readxml {
	my $docfile = shift;
	open my $fh, '<', $docfile or die "$!";
	binmode $fh; 
	my $doc = XML::LibXML->load_xml(IO => $fh) or die "Couldn't read XML";
	return $doc;
}

# This subroutine will:
# a) Set up an XPath object to simplify namespace management 
#     in XPath search. We set the XHTML namespace to use the 
#     'x' prefix here (as the XMTML docs we read uses the default
#     namespace for XHTML, but we need to name it explicitly)
# @see https://metacpan.org/pod/XML::LibXML::Node)
sub setupxpath {
	my $xpc = XML::LibXML::XPathContext->new();
	$xpc->registerNs('x', 'http://www.w3.org/1999/xhtml');
	return $xpc;
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
	#my $dtd = XML::LibXML::Dtd->new( $public_id_trans, $system_id_trans );
								
	my $docfile = shift;
	my $file = shift;
	
	#if ( ! $docfile->validate($dtd) ) {
	#	print STDERR "The following document is not valid: $file";
	#}
	
	eval { $docfile->validate($dtd) }; warn "The following document is not valid: $file";
}

# This subroutine will:
# a)
sub charactercounter_index {
	my $textnodes = shift;
	my @chars = ();
	my @chunks;
	foreach my $tnode ( $textnodes->get_nodelist() ) {
		push @chunks, $charcounter;
		#print STDERR "$textnodecounter\t>>>\t$tnode\n" if $Debug > 0;
		foreach my $char (split('', $tnode->data)) {
			#print STDERR "$textnodecounter\t$charcounter\t>>>\t'$char'\n" if $Debug > 1;
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
	#print STDERR "Char $s is in textnode " . $chars->[$s]->[1] . "\n" if $Debug;
	#print STDERR "Char $e is in textnode " . $chars->[$e]->[1] . "\n" if $Debug;
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
# a) Finds all the text nodes from the document(s)
# b) It also performs a next, and the reason is that it could happen
#     that a specific xPath won't be found so we continue the search.
# XPath searches on XPath objects return an XML::LibXML::Nodelist
#@ see https://metacpan.org/pod/XML::LibXML::NodeList
sub textnodes {	
	my $doc = shift;
	my $bodynode_xpath = '/x:html/x:body';
	my $xpath = '//text()';
	
	# Set up XPath object for ePub documents
	my $xpc = setupxpath();
	
	my $topnode = $xpc->find($bodynode_xpath, $doc)->item(0) or die "Could not find $bodynode_xpath";
	my $nodelist = $xpc->find($xpath, $topnode) or die "Could not find $xpath";
	return $nodelist;
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

# This performs the actual search and replace after the match
# has been performed with a regex
sub textnodetoreplace {	
	my $node = shift;
	my $ns = shift;
	my $prefix = shift;
	my $tag = shift;
	my $seq = shift;
	my ($lc, $rc);
	
	# Note that this test should have already been done when we 
	# come to this point, and a failure to match like this 
	# should return undef. But this is just an example so we test here.	
	$node =~ m!^(.*)$seq(.*)$! or return 1;
	
	# Tuck contexts away (safeguard against future match operations)
	$lc = $1;
	$rc = $2;

	# Create new element
	my $newnode = XML::LibXML::Element->new($tag);
	
	# Set NS and corresponding attributes, if any
	#$newnode->setNamespace( $ns, $prefix, 0 );
	#$newnode->setAttributeNS( '', $aname_0, $avalue_0);
	#$newnode->setAttributeNS( '', $aname_1, $avalue_1);
	for my $attr (@_) {
		$newnode->setAttribute( $attr, $attrhash { $attr });
		#$newnode->setAttributeNS( '', $attr, $attrhash { $attr });
	}
	
	# And add a newly created text node with the sequence to it
	$newnode->appendChild(XML::LibXML::Text->new($seq));
	
	# Now replace the entire textnode with the new element
	$node->replaceNode($newnode) or die "$!";
	
	# We're now missing the left and right contexts (if they existed)
	# If left context existed, stick it in a textnode and insert before the 
	# new node
	$newnode->parentNode->insertBefore(XML::LibXML::Text->new($lc), $newnode) if $lc ne '';
	
	# If right context existed, stick it in a textnode and insert after the 
	# new node
	$newnode->parentNode->insertAfter(XML::LibXML::Text->new($rc), $newnode) if $rc ne '';
	
	# Done.
	return 1;
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
}

# This subroutine will:
# a)
sub packepubbook {	
	my $epubzip = Archive::Zip->new();
	$epubzip->addTree( "$zipDir/.", "" );
	$epubzip->writeToFileNamed( "$zipDir/$infile" );
}

# Call the main subroutine to start this script
main();

=pod 

=head1 NAME

mtm-epub-ssml-processor.pl - 
	This PERL script process XHTML files and based on index counter inserts
	specific 
	
=head1 SYNOPSIS

C<perl mtm-epub-ssml-processor.pl OPTIONS

=head1 OPTIONS

=head2 C<--debug>

Prints trace to STDERR. Defaults to off.

=head2 C<--help>

Random-first - prints help to STDERR.

=head1 Description
	a) Read two parameters as: a) ePub to process, b) directory where the book will be processed
	b) Extract content of the ePub file
	c) Process ePub file(s) in the directory where it was moves to be processed
	d) With the use of PERL process the documents with extention XHTML	
    e) Process of content files with goal to get textnodes, index of words in the document, obtain XPath element, etc. 
	f) Validate the book prior and after processing
	g) Package the files and ensure that are valid ePub book(s)

=cut

__END__