#!/usr/bin/perl -w

use strict;
use warnings;
use vars qw($Debug);
use XML::LibXML;

# Set to 0 to skip debug messages, 
# to 2 to halt during processing,
# to 1 for normal debug
$Debug = 1; 

# Read the file given as a command line argument
# Always check I/O for errors, even in test code!
#my $infile = shift @ARGV or die "Please provide an infile"; 
my ($infile, $outfile) = @ARGV; 
die "Usage: $0 INFILE OUTFILE\n" if not $outfile;

my $nsuri = 'http://www.w3.org/2001/10/synthesis';
my $nspref = 'ssml';
my $nstag = 'phoneme';

# XML (XHTML) file is now read with appr. encoding and parsed into a DOM
my $doc = readxml($infile) or die;
$doc->documentElement->setNamespace( $nsuri, $nspref, 0 );

#print STDERR $doc if $Debug;

# Set up an XPath object 
my $xpc = setupxpath();

# Simplistic test search using the prefix xPath object
print STDERR "Found " . count($doc, $xpc, '//x:p') . " paragraphs\n";

# Find all text nodes 
my $textnodes = textnodes($doc, $xpc);

# When the search of Textnodes return with a List filled then the
# next step is to process it and replace with ssml elements
foreach my $textnode ($textnodes->get_nodelist) {

	# Here we look at each text node from the incoming list and 
	# with the help of a regex filter and send to the subroutine that
	# has the logic to work the textnode
	if($textnode =~ / (\bkommun\b)|(\bkommun(.{1})\b) /) {
		textnodetoreplace($textnode, $nsuri, $nspref, $nstag, $1) or die "Insertion failed";
	}
	
	#print STDERR "And now it is '$textnode'\n" if $Debug;
	<> if $Debug > 1;
}

# And since we worked directly on textnodes, which are still 
# in the DOM, rather than on copies, the DOM is now changed:
#print STDERR $doc;

# Once the file has been processed, i.e. its nodes, namespaces, etc.
# save it into the same file or another one.
open my $out_fh, '>', $outfile or die;
print {$out_fh} $doc;
close $out_fh;

#***************************** Subroutines *****************************
#
# This performs the actual search and replace after the match
# has been performed with a regex
sub textnodetoreplace {
	
	my $node = shift;
	my $ns = shift;
	my $prefix = shift;
	my $tag = shift;
	my $seq = shift;
	my ($lc, $rc);
	
	my $aname_0 = 'alphabet';
	my $avalue_0 = 'cprc';
	my $aname_1 = 'ph';
	my $avalue_2 = 'k u0 m uux4 n';
	
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
	$newnode->setNamespace( $ns, $prefix );
	$newnode->setAttributeNS( '', $aname_0, $avalue_0);
	$newnode->setAttributeNS( '', $aname_1, $avalue_2);
	
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

# Since the search looks only for _textnodes_ and by default 
# they're not namespaced, so there is no need to set up an XPath context
sub textnodes {	
	my $d = shift;
	my $xpath = '//text()';
	my $nodelist = $d->findnodes($xpath);
	print STDERR "Found " .  $nodelist->size . " text nodes\n" if $Debug;
	return $nodelist;
}

# Simple test to check that X-path seems to work
sub count {
	my $doc = shift;
	my $xpc = shift;
	my $xpath = shift;
	# XPath searches on XPath objects return an XML::LibXML::Nodelist
	# (See https://metacpan.org/pod/XML::LibXML::NodeList)
	my $nodelist = $xpc->find($xpath, $doc) or die "Could not find $xpath";
	return $nodelist->size;
}

# Open filehandle to read XML filefield
# Ensure encoding is handled ny LibXML2 rather than PerlIO
# (See https://metacpan.org/pod/XML::LibXML)
sub readxml {
	my $docfile = shift;
	open my $fh, '<', $docfile or die "$!";
	binmode $fh; 
	# drop all PerlIO layers possibly created by a use open pragma	
	# with , no_blanks => 1 switch it excludes text nodes that contain only whitespace
	$doc = XML::LibXML->load_xml(IO => $fh) or die "Couldn't read XML";
	return $doc;
}

# Set up an XPath object to simplify namespace management 
# in XPath search. We set the XHTML namespace to use the 
# 'x' prefix here (as the XMTML docs we read uses the default
# namespace for XHTML, but we need to name it explicitly)
# See https://metacpan.org/pod/XML::LibXML::Node)
sub setupxpath {
	my $xpc = XML::LibXML::XPathContext->new();
	$xpc->registerNs('x', 'http://www.w3.org/1999/xhtml');
	return $xpc;
}

__END__