package Test::MTM::TTSDocument; # Test package

use v5.32;                    # We assume pragmas and such from 5.32.0
use Test::More;               # Explicitly load modules - no Test::Most
use parent qw(ClassTestBase); # Local class which inherits from Test::Class

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;
# END SBTal boilerplate

sub constructor : Tests(3) {
	my $test  = shift;
	my $class = $test->class;

	can_ok $class, 'new';
	ok my $arrayobject = tie(my @a, $class),
		'... and the constructor succeeded';
	isa_ok $arrayobject, $class, '... and the object it returns';
}

sub inhereted_methods : Tests(5) {
	my $test  = shift;
	my $class = $test->class;
	my $aobj = tie(my @a, $class);

	my @methods = qw(reset current cursor move);
	foreach my $m (@methods) {
		can_ok $class, $m;
	}
}

sub methods : Tests() {
	my $test  = shift;
	my $class = $test->class;
	my $aobj = tie(my @a, $class);

	my @methods = qw(read_document_from_handle);
	foreach my $m (@methods) {
		can_ok $class, $m;
	}
}

sub read_documents : Tests() {
	my $test  = shift;
	my $class = $test->class;
	my $aobj = tie(my @a, $class);
	$aobj->read_document_from_handle(\*DATA);
}

1;

__DATA__
foo bar
foo bear


