package SBTal::Config::GetOpt;

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

use version 0.77; our $VERSION = version->declare('v0.1.0');

# Smart comments are used as follows in SBTal
# ###    Flow, progress and light variables
# ####   Large variables
# #####  Important TODOs and such
# ###### Debugging: checks and assertions, expressions
# Uncomment to use (NB this is a source filter and will affect performance):
# use Smart::Comments ('###');
### Warning - Smart comments are in use
# We use this core Perl alternative to Keyword::DEVELOPMENT;
# In SBTal P5M Docker images, use convenience alias p5mdev_on/p5mdev_off to switch
use constant SBTAL_P5M_DEV => !!$ENV{SBTAL_P5M_DEV};
# do {expensive_debugging_code()} if SBTAL_P5M_DEV;
# We use Params::Validate for parameter validation in our methods;
use Params::Validate 1.30 qw();

# =====================================================================
#
# Module implementation
#
# =====================================================================
# ---------------------------------------------------------------------
# Object construction
#
# Minimal construction from class or object
#
# SBTal::Config::GetOpt->new(%params)
	sub new ($proto, %params) {
	### Entering new: $proto
	### Params: %params
	my $class = ref($proto)||$proto;
	my $self = {};
	bless $self, $class;
	$self->_init(%params);
	### Leaving new: $self
	return $self;
}
#
# ***
# $self->_init()
# Parameter treatment, validation
	sub _init ($self, @params) {
	# Specify validator here (state ensures this only happens once)
	state $spec = {
		examples => {
			type => Params::Validate::ARRAYREF,
			optional => 0,
		},
		def => {
			default => 'defval',
		},
	};
	my %valid = Params::Validate::validate(@params, $spec);
	%{ $self } = %valid;
#	use Data::Dumper; print STDERR Dumper $self;
	return $self;
}

# ---------------------------------------------------------------------
# Methods
#

# ---------------------------------------------------------------------
# Helpers
#


1; # Magic true value required at end of module

__END__

=pod

=encoding utf-8

=head1 NAME

SBTal::Config::GetOpt - [One line description of module's purpose here]

=head1 VERSION

This document describes SBTal::Config::GetOpt v0.1.0

=head1 SYNOPSIS

use SBTal::Config::GetOpt;

=for author to fill in:
Brief code example(s) here showing commonest usage(s).
This section will be as far as many users bother reading
so make it as educational and exeplary as possible.

=head1 DESCRIPTION

=for author to fill in:
Write a full description of the module and its features here.
Use subsections (=head2, =head3) as appropriate.


=head1 CONSTRUCTORS

=head2 C<< my $o = ($obj|SBTal::Config::GetOpt)->new(%PARAMS); >>

%PARAMS = (
	examples => ['example'],
);


=head3 C<examples>

Describe C<examples> param.

=over

=item C<example>: sets an example.

=back

=head1 ACCESS METHODS

=for author to fill in:
Write a separate section listing the public components of the modules
interface. These normally consist of either subroutines that may be
exported, or methods that may be called on objects belonging to the
classes provided by the module.

=head1 METHODS

=for author to fill in:
Write a separate section listing the public components of the modules
interface. These normally consist of either subroutines that may be
exported, or methods that may be called on objects belonging to the
classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
List every single error and warning message that the module can
generate (even the ones that will "never happen"), with a full
explanation of each problem, one or more likely causes, and any
suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
A full explanation of any configuration system(s) used by the
module, including the names and locations of any configuration
files, and the meaning of any environment variables or properties
that can be set. These descriptions must also include details of any
configuration language used.

SBTal::Config::GetOpt requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
A list of all the other modules that this module relies upon,
including any restrictions on versions, and an indication whether
the module is part of the standard Perl distribution, part of the
module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
A list of any modules that this module cannot be used in conjunction
with. This may be due to name conflicts in the interface, or
competition for system or program resources, or due to internal
limitations of Perl (for example, many modules that use source code
filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
A list of known problems with the module, together with some
indication Whether they are likely to be fixed in an upcoming
release. Also a list of restrictions on the features the module
does provide: data types that cannot be handled, performance issues
and the circumstances in which they may arise, practical
limitations on the size of data sets, special cases that are not
(yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<hojta@sprakbanken.speech.kth.se>, or through the web interface at
L<www.github.org>.


=head1 AUTHOR

Språkbanken Tal  C<<< hojta@sprakbanken.speech.kth.se >>>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2022, Språkbanken Tal  C<<<hojta@sprakbanken.speech.kth.se>>>. All rights reserved.

Licensed to Språkbanken Tal (SBTal) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  SBTal licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

L<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.

SPDX-License-Identifier: C<Apache-2.0>

=head1 SEE ALSO

=over

=item L<Link to other module here>

=back

=cut
