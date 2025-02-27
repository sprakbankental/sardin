package ClassTestBase;

# SBTal boilerplate
use v5.32;
use utf8;
use strict;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;      
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;

use Carp        qw< carp croak confess cluck >;

# =====================================================================
#
# Base class for class tests of SBTalConfig
# 
# =====================================================================

use Test::More;
use parent qw(Test::Class Class::Data::Inheritable);

# ---------------------------------------------------------------------
# Convenience startup code
# Use Class::Data::Inheritable to create a class method. See
# http://www.modernperlbooks.com/mt/2009/03/making-your-testing-life-easier.html
#

BEGIN {
	__PACKAGE__->mk_classdata('class');
	__PACKAGE__->mk_classdata('object');
}

my $min_tc = 0.52;
eval "use Test::Class  $min_tc";
plan skip_all => "Test::Class $min_tc required for testing Perl module code" if $@;
# At startup, set class to the current class so that it is 
# available in all tests
sub base_startup : Test( startup=>1 ) {
	my $test = shift;
	( my $class = ref $test ) =~ s/^Test:://;
	subtest "Load module $class" => sub {
		plan tests => 1;
		return ok 1, "$class loaded" if $class eq __PACKAGE__;
		use_ok $class or die;
	};
	$test->class($class);
	# We're not creating an object here, but in the individual setups, 
	# as the parameters may differ
}



# ---------------------------------------------------------------------
# This allows us to run directly from the command line, 
# without driver. See
# http://www.modernperlbooks.com/mt/2009/03/making-your-testing-life-easier.html
#
INIT { Test::Class->runtests }

1;

__END__


=pod

=head1 NAME 

ClassTestBase - base class for Class::Test tests

=head1 SYNOPSIS

C<use Test::More;>

C<use parent qw(ClassTestBase);>

C<... TestClass tests>

=head1 DESCRIPTION

This class provides generic "startup" and "class" methods for class 
tests.

It also facilitates one-line tests of any class without the need for 
a driver. 


=head1 EXAMPLES

Run any test C<CLASS> class inheriting this class with:

C<perl -It/classtests t/classtests/Test/[PATH/]CLASS.pm>

Real world example: 

C<perl -It/classtests t/classtests/Test/MTM.pm>

The code is based on L<http://www.modernperlbooks.com/mt/2009/03/making-your-testing-life-easier.html>.

=head1 AUTHOR

Jens Edlund edlund@speech.kth.se

=head1 COPYRIGHT AND LICENSE

Copyright 2020, 2021 Jens Edlund

Licensed to Språkbanken Tal (SBTal) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  SBTal licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.

SPDX-License-Identifier: Apache-2.0


=cut
