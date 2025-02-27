package Test::EN_MTM; # Testing MTM package

use 5.010;                    # We assume pragmas and such from 5.10.0
use Test::More;               # Explicitly load modules - no Test::Most
use parent qw(ClassTestBase); # Local class which inherits from Test::Class
use strict;

sub class {'MTM_EN'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
}

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



