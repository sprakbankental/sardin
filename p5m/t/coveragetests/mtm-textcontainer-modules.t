#!/usr/bin/env perl
#*****************************************************#
#
# POD coverage tests for MTM::Tie::CursorArray and 
# classes inheriting MTM::Tie::CursorArray
#
#*****************************************************#
# We load Test::More to avoid making 
# Test::Pod::Coverage installation a prerequisite to
# run all tests...
use Test::More;

# ...then load Test::Pod::Coverage if it is installed...
eval "use Test::Pod::Coverage";

if( $@ ) {
	# ...and skip all tests it is not...
    plan skip_all => 'Test::Pod::Coverage required for testing POD coverage';
	
} else {
	# ...but if all is well, plan tests explicitly.
    plan tests => 3;
	
}

note "POD coverage tests";

# For control, we explicitly call each relevant module here
# 
# For the time being, we skip MTM, however
# pod_coverage_ok('MTM');

# Check parent module
my $podless = { trustme => [qr/^(nothing)$/] };
# Let human testers know the exceptions
# (Harnessed tests won't be bothered):
note explain $podless;
pod_coverage_ok('MTM::TextContainer', $podless);

# Then check the rest of the relevant modules
# For the inheriting class modules, we may want to
# permit skipping of some inhereted methods
$podless = { trustme => [qr/^(nothing)$/] };
note explain $podless;
pod_coverage_ok('MTM::TextContainer::EPUB', $podless);
pod_coverage_ok('MTM::TextContainer::XHTML', $podless);

