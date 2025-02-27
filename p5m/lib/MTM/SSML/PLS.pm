package MTM::SSML::PLS;

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings	qw< FATAL  utf8 >;
use open		qw< :std  :utf8 >;	 # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;	# autoenables in v5.16 and above
use feature	 qw< unicode_strings >;
no feature	  qw< indirect >;
use feature	 qw< signatures >;
no warnings	 qw< experimental::signatures >;
# END SBTal boilerplate

use XML::LibXML;
# NL TODO How to install needed modules in Docker?
# cpanm --sudo XML::LibXML::PrettyPrint

my $libXMLPP = eval
{
 require XML::LibXML::PrettyPrint;
 XML::LibXML::PrettyPrint->import();
 1;
};
#*****************************************************************#
# Create PLS lexicon from list
sub create_pls {
	my( $infile, $outfile, $lexicon_uri ) = @_;

	my @lexemes = ();
	my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
	my $lexic = $doc->createElement('lexicon');
	$lexic->setAttribute("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance");
	$lexic->setAttribute("xsi:schemaLocation", "http://www.w3.org/2005/01/pronunciation-lexicon http://www.w3.org/TR/2007/CR-pronunciation-lexicon-20071212/pls.xsd");
	$lexic->setAttribute("version", "1.0");
	$lexic->setAttribute("alphabet", "ipa");
	$lexic->setAttribute("xml:lang", "sv-SE");
	$lexic->setAttribute("xmlns", "http://www.w3.org/2005/01/pronunciation-lexicon");

	my $pp;
	if ($libXMLPP) {
	    $pp = XML::LibXML::PrettyPrint->new(indent_string => " ", element => { compact => [qw/grapheme phoneme/] });
	}
# 	my $pls_start = '<?xml version="1.0" encoding="UTF-8"?>
# <lexicon version="1.0"
# 	xmlns="http://www.w3.org/2001/10/synthesis"
# 	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
# 	xsi:schemaLocation="http://www.w3.org/2001/10/synthesis
# 		http://www.w3.org/TR/speech-synthesis/synthesis.xsd"
# 	xml:lang="sv-SE">';


	#my $pls_start = '<lexicon xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2005/01/pronunciation-lexicon http://www.w3.org/TR/2007/CR-pronunciation-lexicon-20071212/pls.xsd" version="1.0" alphabet="ipa" xml:lang="sv-SE" xmlns="http://www.w3.org/2005/01/pronunciation-lexicon">';
	#my $pls_end = '</lexicon>';

	# Prepare outfile

	# Read infile
	## no critic (InputOutput::RequireBriefOpen)
	open my $fh_in, '<', $infile or die();
	## use critic
	while(<$fh_in>) {
		chomp;
		my $line = $_;
		$line =~ s/  /\t/g;
		$line =~ s/\t /\t/g;
		$line =~ s/ \t/\t/g;
		$line =~ s/\t+/\t/g;
		my( $grapheme, $x, $type ) = split/\t/, $line;

		$x =~ s/\'/\\\'/g;

		# $type = phoneme	<lexeme><grapheme>...</grapheme><phoneme>...</phoneme></lexeme>
		# $type = alias		<lexeme><grapheme>...</grapheme><alias>...</alias></lexeme>

		my $lexemeElement = $doc->createElement('lexeme');
		my $graphemeElement = $doc->createElement('grapheme');
		my $phonemeElement = $doc->createElement('phoneme');
		my $aliasElement = $doc->createElement('alias');

		$graphemeElement->appendTextNode($grapheme);
		$lexemeElement-> appendChild($graphemeElement);
		if ($type eq 'phoneme') {
		    $phonemeElement->appendTextNode($x);
		    $lexemeElement-> appendChild($phonemeElement);
		} elsif ($type eq 'alias') {
		    $aliasElement->appendTextNode($x);
		    $lexemeElement-> appendChild($aliasElement);
		} else {
		    # NL TODO How to handle errors?
		    print STDERR "PLS.pm: Expected 'phoneme' or 'alias', got unknown element type: $x\n";
		}

		#print $fh_out "<lexeme>\n\t\t<grapheme>$grapheme<\/grapheme>\n\t\t<$type>$x<\/$type>\n<\/lexeme>\n";

		#TODO How to insall needed modules?
		#$pp->pretty_print($lexemeElement);
		#print $fh_out $lexemeElement->toString . "\n";
		push(@lexemes, $lexemeElement);
	}
	close $fh_in;

	@lexemes = remDupes(@lexemes);
	# lexemes in alphabetic order
	@lexemes = sort { lc($a->findvalue('./grapheme')) cmp lc($b->findvalue('./grapheme')) } @lexemes;

	for my $l (@lexemes) {
	    $lexic->appendChild($l);
	}

	open my $fh_out, '>', $outfile or die();
	print $fh_out '<?xml version="1.0" encoding="UTF-8"?>' . "\n";

	if ($libXMLPP) {
	print $fh_out $pp->pretty_print($lexic) . "\n";
	} else {
	    print $fh_out $lexic->toString() . "\n";
	}
	close $fh_out;

	# Validate
	&validate_pls( $outfile );

	return 1;
}
#*****************************************************************#
use Data::Dumper;
sub remDupes {
   my @lexes = @_;
   my @res;

   my %homographs;
   my %found;

   foreach my $l (@lexes) {

	my $g = $l->findvalue('./grapheme');
	my $p = $l->findvalue('./phoneme');

	$homographs{$g}{$p} = 1;

	if (exists $found{$g}) {
	    # NL TODO How to log info?
	    print STDERR "INFO: skipped dulicate grapheme $g\n";

	    next;
	}
	push(@res, $l);
	$found{$g} = 1;
   }

   # NL TODO Go through %homograps and delete all keys that have only
   # a single phoneme, i.e. a hash value of size 1

   return @res;#, %homographs;
}


sub validate_pls {
	my $pls = shift;
	my $size = -s $pls;

	printf( "Size %.2f kb\n",  $size/1025);

	if ($size/1025 > 100) {
	    print "Warning: PLS file size is larger than 100 kb!\n";
	}

	# XML validation
#	XML::Parser->new->parse($pls);

#	my $parser = XML::LibXML->new;
#	my $doc = $parser->parse_file( $xmlfile );


	use XML::LibXML;
	my $parser = XML::LibXML->new;
	$parser->validation(1);
	$parser->parse_file($pls);

	print "File is valid\n";
	return 1;
}
#*****************************************************************#
1;
