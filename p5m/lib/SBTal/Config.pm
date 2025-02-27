package SBTal::Config;

# SBTal boilerplate
use v5.32;
use utf8;
use strict;
use autodie;
use warnings;
use warnings  qw< FATAL  utf8 >;
use open      qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames qw< :full :short >;    # autoenables in v5.16 and above
use feature   qw< unicode_strings >;
no feature qw< indirect >;
use feature qw< signatures >;
no warnings qw< experimental::signatures >;

use Carp qw< carp croak confess cluck >;

use version 0.77; our $VERSION = version->declare('v0.1.0');

# Smart comments are used as follows in SBTal
# ###    Flow, progress and light variables
# ####   Large variables
# #####  Important TODOs and such
# ###### Debugging: checks and assertions, expressions
# Uncomment to use (NB this is a source filter and will affect performance):
#use Smart::Comments ('###');
### Warning - Smart comments are in use
# We use this core Perl alternative to Keyword::DEVELOPMENT;
# In SBTal P5M Docker images, use convenience alias p5mdev_on/p5mdev_off to switch
use constant SBTAL_P5M_DEV => !!$ENV{SBTAL_P5M_DEV};
# do {expensive_debugging_code()} if SBTAL_P5M_DEV;
# We use Params::Validate for parameter validation in our methods;
use Params::Validate 1.30 qw();
# NB! These are candidates for inclusion in the P5M template.
use Log::Any qw($log), default_adapter => 'Stderr';  # Create generic logger for this module
Params::Validate::validation_options(
	on_fail => sub { $log->critical(@_); die ''; }, );

use Getopt::Long;
use Pod::Usage ();                                   # This is under testing for now
use Pod::Find  ();
use Clone;
use String::ShellQuote qw();
# NB!!! We should do better shell quoting. See
# https://www.perl.com/article/quoting-the-shell/
# for ideas

# Some prepratory work here
# Note that we'll only ever get here at compiletime, except
# for reaching the argv access methods, hich are available in
# this and inheriting packages at any time.
# This means that post-startup commands cannot trigger modules
# using this system to shut down using e.g. --help or --compileonly
# help and man are accessible during runtime though, but will not kill
{
	# (1) We steal any actionable, non-module specific
	#     things here and react to them.
	my %triggers;
	my @full;
	my $podfrom;

	# Tuck away the original @ARGV (minus compile-time stuff) for safe keeping,
	# and make it available to developers
	BEGIN {
		my $preconfig = [qw(pass_through)];
		my $prespec   = [qw(usage help|? man compileonly)];
		my $preparser = Getopt::Long::Parser->new( config => $preconfig );
		$preparser->getoptions( \%triggers, @$prespec );
		@full = @ARGV;
	}

	# Pod::Usage settings
	# Define help subs
	sub usage {
		$podfrom ||= $0;
		Pod::Usage::pod2usage {
			-input   => $podfrom,
			-message => "Usage:",
			-exitval => 2,
			-verbose => 0,
			-output  => \*STDERR,
		};
	}

	sub help {
		$podfrom ||= $0;
		Pod::Usage::pod2usage {
			-input   => $podfrom,
			-exitval => 2,
			-verbose => 1,
			-output  => \*STDERR,
		};
	}

	sub man {
		$podfrom ||= $0;
		Pod::Usage::pod2usage {
			-input   => $podfrom,
			-exitval => 2,
			-verbose => 2,
			-output  => \*STDERR,
		};
	}

	# Check if we should duck out early
	# NB! Using an INIT block here yields "too late to run init"
	BEGIN {
		if ( $triggers{help} )        { print STDERR help(); exit }
		if ( $triggers{usage} )       { print STDERR usage(); exit }
		if ( $triggers{man} )         { print STDERR man(); exit; }
		if ( $triggers{compileonly} ) { exit; }
	}

	# Define argv access methods
	sub argv { return \@full }

	sub displayargv {
		print STDERR join( "|", @full ), "\n";
	}

	sub argvstring {
		warn
			"Current implementation of @ARGV stringification escapes everything with Bourne shell qouting!\n";
		return String::ShellQuote::shell_quote(@full);
	}

	sub import ( $class, $p = {} ) {
		if ( exists( $p->{podfrom} ) ) {
			$podfrom = Pod::Find::pod_where( { -inc => 1 }, $p->{podfrom} );
		}

		# We use this to set up --help and --usage. Note however
		# that we really should only take the OPTIONS from the
		# SBTal::Config subclass, and the rest of the script
		# information from the script, that is $0. So some tailoring
		# is required (see Pod::Usage for possibilities).
	}
}

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
# SBTal::Config->new(%params)
sub new ( $proto, %params ) {

	### Entering new: $proto
	### Params: %params
	my $self  = {};
	my $class = ref($proto) || $proto;

	# If we have an object, we'll clone and reset
	if ( ref($proto) ) {

		# NB! We should merge the settings instead of losing what may be sent in!
		$params{defaults}      = $proto->_defaults;
		$params{parseroptions} = $proto->_parseroptions,;
		$params{specification} = $proto->_specification;
	}
	bless $self, $class;
	$self->_init(%params);

	### Leaving new: $self
	return $self;
}
#
# ***
# $self->_init()
# Parameter treatment, validation
sub _init ( $self, @params ) {

	# Specify validator here (state ensures this only happens once)
	state $spec = {
		parser => {
			can      => [ 'getoptionsfromarray', 'configure' ],
			optional => 1,
		},
		parseroptions => {
			type    => Params::Validate::ARRAYREF,
			default => [],
		},
		defaults => {
			type    => Params::Validate::HASHREF,
			default => {},
		},
		specification => {
			type    => Params::Validate::ARRAYREF,
			default => [],
		},
		order => {
			type    => Params::Validate::ARRAYREF,
			default => [],
		},
	};

	# (-1) Rescue ARGV already at startup
	# (0) These are the default Getopt::Long options.
	# If we want to override them, this should be done
	# using the parseroptions parameter (which will override
	# these defaults as it is applied later)
	# (We're currently using defaults only!)
	my $gopconfig = [
		qw(
		)
	];

	# (1) Validate params and add to self
	# Note that we _clone_ all arguments to break any ties
	# to the calling code.
	my $valid = Clone::clone { Params::Validate::validate( @params, $spec ) };

	# we only set things that were actually passed in
	foreach my $k (%$valid) {
		$self->{$k} = $valid->{$k};
	}

	# (2) If we have no option parser, create one
	$self->{parser} = Getopt::Long::Parser->new( config => $gopconfig, )
		unless exists( $self->{parser} );

	# (3) Now call configure on the parser with
	# whatever config we got
	$self->{parser}->configure( @{ $self->_parseroptions } );

	# (4) Set up current data using the defaults
	# NB This is supposed to be a set of named data structures in time
	$self->reset;

	# We're now set up to parse an option array using the specification.
	return $self;
}

# ---------------------------------------------------------------------
# Methods
#
# Access Methods
# --------------
# data returns the data structure holding the current configuration
sub data ($self) {
	return $self->{data};
}
# Generic access method
# This proivdes som error handling and such
# but is a slow method, so mileage may vary
#
sub get ( $self, $key, $subkey = undef ) {

	# NB!! Add error handling and fb
	my $data = $self->data;
#	print STDERR "Getting $key\n";
#	use Data::Dumper; print STDERR Dumper $self;
	do {
		$log->critical("No such parameter: $key");
		die '';
	} unless exists( $data->{$key} );
	defined $subkey or return $data->{$key};
	do {
		$log->critical("No such parameter: $key, $subkey");
		die '';
	} unless exists( $data->{$key}->{$subkey} );
	return $data->{$key}->{$subkey};
}

#
# Encoding/decoding/fusion
# ------------------------
#
# fuse a compliant data object or an argv array into
# the current configuration
# The method parses and option array or a config data object
# and adds them to the data structure. In future versions, we
# will use clone and an array of named data structures to
# achieve rolback of the incremental config buildup, but
# right now we just overwrite.
sub toconf ( $self, @params ) {

	# Specify validator here (state ensures this only happens once)
	state $spec = {

		# We can run either by a compliant object,
		# which then must be able to produce a
		# ARGV version of itself
		obj => {

			#type => Params::Validate::OBJECT,
			# can => [qw( toargv )],
			optional => 1,
		},

		# Or by an ARGV list
		argv => {
			type     => Params::Validate::ARRAYREF,
			optional => 1,
		},
		method => {
			type    => Params::Validate::SCALAR,
			default => 'reset',
			regex   => qr/^(reset|fuse)$/,
		}
	};
	my %valid = Params::Validate::validate( @params, $spec );

	# Check that only one config is passed
	exists( $valid{obj} )
		&& exists( $valid{argv} )
		&& die "Cannot specify both 'argv' and 'obj'";

	# Check that one config is passed
	die "Must specify one of 'argv' or 'obj'"
		unless ( exists( $valid{obj} ) or exists( $valid{argv} ) );
	my $tofuse = exists( $valid{obj} ) ? $valid{obj}->toargv : $valid{argv};

	# If reset, reset self, otherwise no
	$valid{method} eq 'reset' && $self->reset;

	# Now do the fusion
	# Get the default data (this is the data as it is before
	# this addition, so not necesarily the initial default)
	my $data = Clone::clone( $self->data );

	# Get the specification
	my $confspec = $self->_specification;

	# Get the parser
	my $parser = $self->_parser;

	# And go
	$parser->getoptionsfromarray( $tofuse, $data, @$confspec );

	# Now we return data to its object container - but again, this
	# should be done differently when we implement rollbacks.
	$self->{data} = $data;
}

# reset the current configuration to its default
# config object settings remain
sub reset ($self) {
	$self->{data} = Clone::clone( $self->_defaults );
}
#
# clone the object, with a new copy of the current configuration
# cloning includes a reset to defaults and a new call to toconf
# with the appropriate ARGV, meaning that any callbacks or hooks
# will trigger.
# NB!!! There's a problem here with additions to list params
# NB!!! The ones in default will multiply
# NB!!! One solution is to unique the list, but that
# NB!!! goes against the idea of letting standard Getopt::Long do
# NB!!! all the work. Figure it out though.
# NB!!! Likely the default sequence should be removed from the
# NB!!! sequence in 'toargv'. So def 1 2 3 and data 1 2 3 4 5
# NB!!! gives 4 5 only in argv.
sub clone ($self) {

	# Create the new object with the same settings:
	my $clone = $self->new;

	# The get the ARGV from the old object
	my $argv = $self->toargv;

	# And fuse that onto the new object
	$clone->toconf( argv => $argv );
	return $clone;
}

# NB! This should change name. It's sbtalconf2argv
#     (or possible sbtalconf2gnu)
# Name change from decode2gnu => toargv
# Note that what comes out here need not be what
# was put in to create the config at all. The same
# configuration can be reached through any mnumber
# of cascading instructions changing and cancelling
# each other.
# 'toargv' creates a minimal ARGV sequence that will
# create the same config when parsed.
sub toargv ($self) {
	my $data = $self->data;
	my @gnu;

	# Data will always be a hash, and it's keys, with '--'
	# prepended, are the options.
	while ( my ( $key, $val ) = each %$data ) {
		if ( ref($val) eq 'ARRAY' ) {

			# Note that the order, here, may be significant
			foreach my $v (@$val) {

				# print STDERR "--$key $v\n";
				push @gnu, "--$key", $v;
			}
		}
		elsif ( ref($val) eq 'HASH' ) {
			while ( my ( $k, $v ) = each %$val ) {

				# print STDERR "--$key $k=$v\n";
				push @gnu, "--$key", "$k=$v";
			}
		}
		else {
			# print STDERR "--$key, $val\n";
			push @gnu, "--$key", $val;
		}
	}
	return \@gnu;
}

# ---------------------------------------------------------------------
# Helpers
#

# ---------------------------------------------------------------------
# Internal access methods
# These are mainly used for test suites, are not part
# of the public API and cannot be expected to remain in place across
# versions
sub _parser ($self) {
	return $self->{parser};
}

sub _parseroptions ($self) {
	return $self->{parseroptions};
}

sub _defaults ($self) {
	return $self->{defaults};
}

sub _specification ($self) {
	return $self->{specification};
}

sub _order ($self) {
	return $self->{order};
}

1;  # Magic true value required at end of module

__END__

=pod

=encoding utf-8

=head1 NAME

SBTal::Config - Generic config system for SBTal Perl5 modules

=head1 VERSION

This document describes SBTal::Config v0.1.0

=head1 SYNOPSIS

use SBTal::Config;

my $c = SBTal::Config->new;

=head1 DESCRIPTION

C<SBTal::Config> allows module authors to set up a coherent
system for script configuration. It is designed to meet the
following requirements:

=over

=item Complex configs can be defaulted, saved persistantly,
and be overridden both by partial config files and by command
line arguments

=item Consistent functionality over command line, XML, JSON,
and other formats.

=item Robust code avoidning reinvention of the wheel

=item But no reliance on major frameworks - light-weight,
simple, and with minimal restrictions on the calling code

=item Potential support for subcommands

=back

We achieve this by basing the whole system on C<Getopt::Long>
(and potentially C<Getopt::Long::Subcommand>). This is expanded
to create a encoder/decoder system from and to
L<GNU ARGV sequences|http://www.gnu.org/software/libc/manual/html_node/Getopt.html#Getopt>.

Persistancy is added through other well-known modules such as C<Sereal>.

New formats are, whenever possible, also added with the help
of well-known packages such as C<XML::LibXML>. See
L</"FORMATS AND CONVERSIONS">.

The C<GNU ARGV> sequence (which stringifies readily by a
space C<join>) is the I<Lingua Franca> of the system. And the
parse instructions given to the C<Getopt::Long> is the
reference specification of this Lingua Franca. Other formats
and implementations are to conform.

=head2 BUILT-IN COMMAND LINE OPTIONS

A script using the C<SBTal::Config> module will remove and act
on the following options before anything else is done, when
loaded.

=over

=item --help/-?

=item --usage

=item --man

=item --compileonly

=back

It will then exit, meaning that the loading script will terminate as
well. This behaviour is currently not configurable, but it probably
should be.

This means that C<help>, C<usage>, C<man>, and C<compileonly> should
be considered I<reserved words> in SBTal option and configuration,
and should be avoided in any other capacity than to trigger
start-up help and testing.

=head2 DATA STRUCTURES

The module implements three major data structures:

=over

=item A C<Getopt::Long> option specification.

=item A hash that holds parse results from C<Getopt::Long>. This
can be overwritten in layers, or duplicated for the possibility to
rollback configs. The hash is initially populated by defaults that
can be passed at object creation time.

=item A system for ordering config data, so that we parse and add in
the correct order. (B<This id not implementet and may never be - we'll
see if the need arises.>)

=back

=head2 PROCESS FLOW

The building of a configuration system using
C<SBTal::Config> follows this process:

=over

=item Select option parser (defaults to
C<Getopt::Long>). The alternative is to pass
a preconfigured object that is capable of
C<getoptionsfromarray> and C<config> to
C<parser>. This is so far untested, but the
idea is mainly to support sub-classing of C<Getopt::long>.

=item Configure the option parser (defaults to
C<Getopt::Long>). There are some default settings
provided, and the rest comes from an optional
configuration string passed in C<parseroptions>.
Be careful if changing this in existing code,
as the C<Getopt::Long> parsing constitutes, in
practice, the reference specification for the
configuration, and changes to it changes the core
of the system. Potential effects may include rendering
stored configurations useless.

=back

Note that although C<data> and C<specification>
(and C<order>) are all passed as references,
they are deep copied into the object
on creation and the backlink is destroyed. This is
a deliberate choice intended to avoid hard-to-follow
bugs, in particular having to do with persistancy.


=head2 CASCADING CONFIGURATIONS

The system is designed to accept sequences of configurations
to be processed one after the other, with merging and/or
overwriting of data as the result. In practice, for each
iteration, the previous state of the configuration is
taken as the default, and any new options are added while
changed options are overridden. This makes for a robust
and generic system, albeit with some limitations.

=head2 FORMATS AND CONVERSIONS

We allow for an arbitrary number of formats. At the same
time we want to make sure that conversions between formats
do not introduce differences in how configurations and
options are interpreted.

One way of ensuring this would be to create an unambiguous
specification for a reference format, and then state that
all other formats must have their own equivalent specification,
and some set of conversion rules. This, however, could force
us to create a very large number of conversion rules. It would
also land us in specification hell, potentially.

=head3 INTERNAL DATA STRUCTURE

Instead our only hard reference is a single, quite simple
internal structure as the common structure for SBTal
configurations.

CONFIG (TOP NODE) C
OPTION O
KEY K (string)
VAL V (string|integer)
ARRAY A
HASH H

C => O*
O => K V
K => string
V => (string|integer)
O => K A
A => V+
O => K H
H => (K V)+

The (sloppy) grammar above describes a three-tier (maximally, two is
also possible) tree where C is the root, the first tier consists of
keys only, and the second is either values (leaves), arrays (groups
of leaves), or hashes. If hashes are present, these consist of
new, second-tier keys, which are associated with single values
(leaves on the third tier). That's it.

Note that a valid implementation of this structure does not
necessarily distinguish between e.g.

=over

=item a second tier  value or a single second tier value that
is part of a group (an array)

=item  a second tier value of 1 that is a toggle or one that is an integer

=back

=head3 ARGV PARSING SPECIFICATION

There is, however, some typing of such values present.
We use the C<Getopt::Long> parsing specification as a
refining layer of the reference specification of a
configuration. This provides all information necessary to
understand what the single value or the 1 in the examples
above are (mainly a concern when it comes to decide
whether to merge, add or overwrite L</CASCADING CONFIGURATIONS>.)
We I<really> do not want to duplicate these rules, and we
I<do> need them in the L<Getlong::Opt> option parsing, so we
use that description as the reference and ensure that they
are enforced by including L<Getlong::Opt>'s parsing as part
all conversion chains.

=head3 MINIMAL FORMAT REQUIREENTS

In general, in order for a new format C<FORMAT> to be acceptable
as a C<SBTal::Config> format, the following must be in place:

=over

=item An encoder, typically implemented as a constructor:
C<< $formatobj = FORMAT->new(data=>$sbtalconfighash) >>. This reads the
internal data structure and produces the C<FORMAT> data structure.

=item A decoder, typically implemented as
C<< $formatobj->toargv >>. This creates an C<ARGV> style
array that, if parsed by L<Getopt::Long> with the current
module's settings, will generate a data structure that
correspondsto the C<FORMAT> data structure. Decoding is
completed using the inherent C<toconf> conversion (which
is in essence a L<Getopt::long> C<getoptionsfromarray>
call with the right settings).

=back

=head3 FORMAT MODULE DEPENDENCIES

Note that encoding into ARGV is module insensitive - it is
the same regardless of the settings of the specific module
that uses C<SBTal::Config>.

Whereas decoding from ARGV is module sensitive, as it uses
rules that are set by a specific module. From this it should
be evident that any access methods provided by the specific
module will not work directly on anything but the sbtalconf
data, and potentially it will break if this structure has
not been built through option parsing (which may include
callbacks that e.g. sets up access methods).

The following should hold:

my $c1 = SBTal::Config->new(SETTINGS);
my $c2 = SBTal::Config->new(SETTINGS);
my $sbtalconf1 = $c1->toconf(argv=>\@ARGV)->data;
my $FORMATconf = FORMAT->new(data=>$sbtalconf1);
my $argv = $FORMATconf->toargv;
my $sbtalconf2 = $c2->toconf(argv=>$argv)->data;
is_deeply($sbtalconf1, $sbtalconf2);

So this means that the only module specific info is encoded in
the L<Getopt::Long> specification, which also allows us to add
specific hooks and such into that code, while relying on the
hooks to always be called when options are set. Meaning we need
not and should not implement our own callback systems for config
setup, ever.

=head2 INTERNAL STRUCTURE SPECIFICATION VERSIONING

The specification's version number is part of the config settings,
and must be given when the C<SBTal::Config> object is created
(it is currently preset to v1, as no breaking updates exist).
Old specs will be supported for at least several breaking version
updates.

A structure validator is in the works - this will validate
internal data structures against a specific version of the specs.

=head2 SUPPORTED FORMATS

The formats that are supported in the standard distribution are:

=over

=item C<argv> - this is an array of command line options, as they
are parsed by a shell scripted. It is the fundamental input
format for all other formats, which should always be constructed
by building the internal data through ARGV parsing, then
converting.
Note that this should conform to GNU argv, and that this format
is the public Lingua Franca of our configuration system.

=item C<sbtalconf> - this is a hash which complies with the
active specification version above. (NB This is an internal format
and should only be discussed when implementing scripts... so isn't
part of the public API or reference!)

=item C<argvstring> - this is C<argv> stringified. The format, then,
is underspecified, as stringification will depend on which shell is
considered in order to escape e.g. control characters and spaces. In
the current distribution, this format uses Bourne shell quotes only.

=item C<argvfile> - argv divied up in one or more files. We use
L<Getopt::Agrvfile> to do the initial decoding, and custom code
to decode from the sbtalconf internal format.

=item C<xml> - this is a generic XML format that complies with the
specification. The same format is used for all configuration types,
but other XML formats that are more specific to specific
applications can be added, and it should always be possible to go
from them to the generic XML with a straightforward XSL
transformation.

<config>
 <key name="key1">
  <value>value1</value>
 </key>
 <key name="key2">
  <value>arrayval1</value>
  <value>arrayval2</value>
  <value>arrayval3</value>
 </key>
 <key name="key3">
  <key name="hashkey1">
   <value>hashval1</value>
  </key>
  <key name="hashkey2">
   <value>hashval2</value>
  </key>
 </key>
</config>

Both encoding and decoding are straightforward here.

=item C<json> - same principle as C<xml>.

=back

=head2 NAMING SCHEME FOR CONVERSIONS

The naming scheme is straightforward. Each format should
have a unique name (this will likely double as the format's
module name, in CamelCase, and the format name in conversion
naming, in lowercase). For example, the built-in, generic XML
format is implemented in C<SBTal::Config::XML> and its
conversion name is simply "xml". The following conversions
can be expected to exist, then:

=over

=item C<$xmlobj->toargv> (and it is understood that this calls a
C<$xmlobj->toargv> conversion first, and then the current
C<SBTal::Config> object's standard C<toconf> method).

=item C<$conf->toxml> - en encodingmethod that reads a C<SBTal::Config>
object to output the generic XML format.

=back

=head1 CONSTRUCTORS

=head2 C<< my $o = ($obj|SBTal::Config)->new(%PARAMS); >>

The C<$obj->new()> version will copy defaults and settings from the
object on which new is called (in practice, new is implemented by
calling first C<clone>, then C<reset> on the clone object, and
finally applying any configuration passed).

%PARAMS = (
	parser => PARSEROBJECT, # defaults to a new Getopt::Long object
	parseroptions => [], # Passed to "configure" on the parser
	defaults => {
		integer => 1, # default
		array   => ['default1', 'default2'],
		hash    => {
			key1 => 'default3',
			key2 => 'default4',
		},
	},
	specification => [
		# These are standard Getopt::Long options
		# 'switch', NB!!! switches/value-less options are not permitted!
		'integer=i',
		'float=f',
		'array=s@',
		'hash=s%',
	],
	#order = [ # not currently implemented
	#	'name1',
	#	'name2',
	#	'@',
	#],
);

=head2 OPTIONS

=head3 parser

If no C<parser> option is passed, C<SBTal::Config> creates a
C<Getopt::Long> parser object with its own modified default
settings, then applies the C<parseroptions> options using
the parsers C<configure> method.

If a C<parser> option is passed, it has to be a class or
an object supporting the following methods:

=over

=item C<configure> (which will get called with the
C<parseroptions> option's contents.

=item C<getoptionsfromarray>, which is responsible for passing
arrays of options such as C<@ARGV>.

=back

Using a custom parser should not be necessary unless you have
very complex needs for your configuration.

=head3 parseroptions

An array reference pointing to parser options. If a custom parser
is passed in C<parser>, these påtions need to match its requirements.
Otherwise they should be valid C<Getopt::Long> options.

=head2 defaults

This is a hash reference. The hash holds default values for whatever keys it contains.
Nothe that the hash itself isn't used, but is cloned to make up the defaults for the
first hash to be filled by C<getoptionsfromarray>. If the options are set again through
a second process, the new option hash will be cloned and used as default. This way, we
safeguard the option setup after each step, which prepares the system for potential
roll-backs.

=head1 ACCESS METHODS

=head2 my $data = $o->data;

Returns the current data structure (a hash). Used to build script
specific access methods on top of the C<SBTal::Config> code.

=head2 my @argv = $o->toargv;

Returns the current data structure (a list) encoded as GNU
options.

# Note that what comes out here need not be what
# was put in to create the config at all. The same
# configuration can be reached through any mnumber
# of cascading instructions changing and cancelling
# each other.
# 'toargv' creates a minimal ARGV sequence that will
# create the same config when parsed.

# Note also that this should return the major version of
# C<SBTal::Config> used, so that the internal structure can be
# expected to work.

=head1 METHODS

=head2 $o->toconf(%PARAMS);

=head3 OPTION argv (ARRAYREF)

If C<argv> is passed, it should contain an array ref pointing
to an array that complies, in general, with C<@ARGV> as it would look
when it arrives from the shell, and specifically with the specification given to the
L<Getopt::Long> parser on C<@o>. Note that we assume that the flag
to use GNU style parameters is set.

C<object> should not be passed if C<argv> is set.

=head3 OPTION obj (OBJECT)

If C<obj> is passed, it should contain an object that provides a C<toargv> method, which is then used to access an argv array ref. C<argv> should not be passed if C<obj> is set.

=head3 OPTION method (fuse|reset, default reset)

Defaults to C<reset>. The config in C<$o> is reset to defaults
before the new options are added. If set to C<fuse>, the data is fused with the current configuration. (NB we should be clearer
about the rules of that).

=head2 $o->fuse($o2);

Convenience method. Translates to:

$o->toconf(object=>$o2, method=>'fuse');

Gets an option array from C<$o2> and fuses it with the the current
config in C<$o>.

If they option parsing specific callbacks or hooks, these are called.

=head2 my $o2 = $o->clone;

Creates a clone of an object. Note that the clone is reset then
reconstructed through a call to C<toconf>, so that any construction
callbacks are triggered properly.

=head2 help(), man(), usage()

These print out (parts of) the POD I<from the running script>.

=head1 HELPERS/TOOLS

=head2 SBTal::Config->argv(); $c->argv();

This returns a copy of the original, untouched C<@ARGV>. Useful when the calling script may have eddled with C<@ARGV> unwittingly.

=head2 SBTal::Config->argvstring(); $c->argvstring();

Returns a stringified copy of the untouched C<@ARGV>.

Currently, this uses C<String::ShellQuote> to escape
the string, which only supports Bourne shell. So your
mileage may vary.

=head2 SBTal::Config->displayargv(); $c->displayargv();

Convenience method printing the original, untouched
C<@ARGV> to STDERR. The ARGV parts are joined with
| in order to visualise the shell's interpretation
of the command line options.

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

SBTal::Config requires no configuration files or environment variables.


=head1 DEPENDENCIES

=head2 COMMON SBTAL MODULE DEPENDENCIES

To be listed.

=head2 MODULE SPECIFIC DEPENDENCIES

Dependencies in addition to what is required
for all SBTal modules.

=over

=item C<String::ShellQuote>. Not core.

=back

=head1 INCOMPATIBILITIES

=over

=item No module conflicts reported.

=back

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
