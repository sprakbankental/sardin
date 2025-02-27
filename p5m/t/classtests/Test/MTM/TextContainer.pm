package Test::MTM::TextContainer;

use strict;
use warnings;

use Test::More;
use parent qw(ClassTestBase); # Local class which inherits from Test::Class

sub setup : Tests(setup) {
	my $test        = shift;
	my $class       = $test->class;
	$test->{obj}    = $class->new;
}


#*****************************************************************************#
#
# Methods
#
# Test if we can call all methods used by this class
sub methods : Tests(18) {
	my $test  = shift; 					# The preprocessor object
	my $class = $test->class;

	my @methods = qw(
		new
		newepub epub_since_boot
		newxhtml xhtml_since_boot
		newxpc
		text infile xpc
	);
	note "Test 'can' on class";
	foreach my $m (@methods) {
		can_ok $class, $m;
	}
	note "Test 'can' on object";
	foreach my $m (@methods) {
		can_ok $test->{obj}, $m;
	}
}
#
# EPUB factory
sub epub : Tests(18) {
	my $test  = shift; 					# The preprocessor object
	my $class = $test->class;

	my $epub = $class->newepub();

}

1;

__END__

# Steal some testing from MTM::NodeFactory

