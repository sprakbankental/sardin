package Test::MTM::TextContainer::XHTML;

use Test::More;
# We do not call Test::Class directly, but do it through our parent
# classes corresponding class test. That way we also inheret all testing.
use parent qw(Test::MTM::TextContainer);

#*****************************************************************************#
#
# Methods and Document management methods
#
#
# Test if we can open all methods used by this class
sub methods : Tests(2) {
	my $test  = shift; 					# The preprocessor object
	my $class = $test->class;

	my @methods = qw(
		dom
	);
	foreach $m (@methods) {
		can_ok $class, $m;
	}
	foreach $m (@methods) {
		can_ok $test->{obj}, $m;
	}
}

1;

__END__

