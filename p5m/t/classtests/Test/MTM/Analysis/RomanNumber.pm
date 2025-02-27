package Test::MTM::Analysis::RomanNumber;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::RomanNumber'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('RomanNumber');
}

sub markup : Tests(7) {
	my $test = shift;

	# TODO
	#$test->chunk_assert('sidan xv-xix.', 'ROMAN INTERVAL', 2, 'xv-xix', '.');

	$test->chunk_assert('II', 'ROMAN', 0, {orth => 'II', morph => 'NOM'});

	# TODO
	#$test->chunk_assert('IV Påvekyrkans uppgång och fall', 'ROMAN', 0, 'IV');

	# TODO
	# $test->chunk_assert('I. Påvekyrkans uppgång och fall', 'ROMAN', 0, 'I', '.');

	# TODO This is not handled by RomanNumber?  Seems to be a straight dictionary match.
	# $test->chunk_assert('Karl XII', 'ROMAN', 0, 'Karl XII');

	$test->chunk_assert('notreferens I', 'ROMAN', 2, 'I');
}
