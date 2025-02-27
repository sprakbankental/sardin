#!/use/bin/perl -w

use warnings;
use strict;

#BEGIN {
#	# just in case someone turned this one
#	$ENV{PERL_KEYWORD_DEVELOPMENT} = 0;
#
#	# Redirect stderr to file
#	#open STDERR, ">data/stderr.txt";
#}

#use Keyword::DEVELOPMENT;

#DEVELOPMENT {
#	print STDERR "expensive_debugging_code()\n"; 
#	print ("Pelle ", "\n");
#};

use MTM::TTSNodeFactory;

my $p = MTM::TTSNodeFactory->newpreprocessor;

my $file = $ARGV[0];
open my $fh, '<:utf8', $file or die $!;

my $doc = $p->read_document_from_handle($fh);
$p->add_document($doc);

$p->normalise;

$p->chunk;
$p->tokenise; 
$p->pos_tag; 

pretty_print( "data/output.txt", $p );

#use Data::Dumper; print STDERR Dumper $p; exit;

print STDERR MTM::TTSNodeFactory->preprocessors_since_boot . " preprocessors\n";
print STDERR MTM::TTSNodeFactory->documents_since_boot . " documents\n";
print STDERR MTM::TTSNodeFactory->chunks_since_boot . " chunks\n";
print STDERR MTM::TTSNodeFactory->tokens_since_boot . " tokens\n";

#exit;
sub pretty_print {
	my $filename = shift;
	my $obj = shift;

	open my $output, ">:utf8", $filename  or die "could not open '$filename': $!";

        $obj->print_legacy($output);
}


$p->print_tokens;
#&MTM::TTSToken::printOut( "data/output.txt", $p );

