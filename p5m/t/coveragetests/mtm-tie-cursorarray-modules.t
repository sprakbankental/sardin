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
    plan tests => 6;
	
}

note "POD coverage tests - note that these tests do not check coverage for autoloaded methods!";

# For control, we explicitly call each relevant module here
# 
# For the time being, we skip MTM and MTM::Tie, however
# pod_coverage_ok('MTM');
# pod_coverage_ok('MTM::Tie');
# Check parent module
# This module reimplements the Perl imherent 'can' to  
# make it pick up on its autoloaded methods. We do not
# require a POD entry for this, of course.
my $podless = { trustme => [qr/^(can)$/] };
# Let human testers know the exceptions
# (Harnessed tests won't be bothered):
note explain $podless;
pod_coverage_ok('MTM::Tie::CursorArray', $podless);

# Then check the rest of the relevant modules
# For the inheriting class modules, we may want to
# permit skipping of some inhereted methods
$podless = { trustme => [qr/^(can)$/] };
note explain $podless;
pod_coverage_ok('MTM::TTSNodeFactory', $podless);
pod_coverage_ok('MTM::TTSPreprocessor', $podless);
pod_coverage_ok('MTM::TTSDocument', $podless);
pod_coverage_ok('MTM::TTSChunk', $trustme);
pod_coverage_ok('MTM::TTSToken', $trustme);
# note explain $podless;

