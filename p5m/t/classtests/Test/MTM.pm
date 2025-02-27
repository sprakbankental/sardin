package Test::MTM; # Testing MTM package

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
	ok my $o = $class->new,
		'... and the constructor should succeed';
	isa_ok $o, $class, '... and the object it returns';
}

# Test if we can open all methods used by this class
sub methods : Tests(7) {
	my $test  = shift; 					# The preprocessor object
	my $class = $test->class;

	my @methods = qw(
		new
		fb fb_level
		now get_created
		get_legacy set_legacy
	);
	foreach my $m (@methods) {
		can_ok $class, $m;
	}
}

1;



