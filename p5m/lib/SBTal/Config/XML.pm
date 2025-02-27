package SBTal::Config::XML;

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

use Log::Any qw($log), default_adapter => 'Stderr'; # Create generic logger for this module
Params::Validate::validation_options(
	on_fail => sub { $log->critical(@_); die '';},
);

# =====================================================================
#
# Module implementation
#
# =====================================================================
use XML::LibXML;

# ---------------------------------------------------------------------
# Object construction
#
# Minimal construction from class or object
#
# SBTal::Config::XML->new(%params)
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
	# No parameters allowed, for the time being
	state $spec = {
		# These are the defaults for data structure based construction
		# They should really only be changed if the format is subclassed
		namespace => {
			# Only override namespace if subclassing while reusing the same
			# new method
			type => Params::Validate::SCALAR,
			default => 'http://sprakbanken.speech.kth.se/xmlns/2022/config/',
		},
		rootelementname => {
			# Only override if subclassing while reusing the same
			# new method
			type => Params::Validate::SCALAR,
			default => 'config',
		},
		encoding => {
			type => Params::Validate::SCALAR,
			default => 'UTF-8',
		},
		# If set to '', we use a default namespace (searchable as 'xsbtc')
		# Otherwise whatever string is set here is used as the namespace prefix
		nsprefix => {
			# Only override namespace if subclassing while reusing the same
			# new method
			type => Params::Validate::SCALAR,
			default => '',
		},
		# If 'data' is set, we use the data structure from an
		# SBTal::Config compliant object to build the XML
		data => {
			# This the data structure from an SBTal::Config object
			type => Params::Validate::HASHREF,
			optional => 1,
		},
		# This is a string holding the XML. Auxiliary params are the same, and are
		# tested for consistancy with th etring parsing.
		string => {
			type => Params::Validate::SCALAR,
			optional => 1,
		},
		# This is a string holding a pointer to the XML file. Auxiliary params are
		# the same, and are tested for consistancy with th etring parsing.
		location => {
			type => Params::Validate::SCALAR,
			optional => 1,
		},
#		io => {
#			# This should be an uri that can be gotten over the internets
#			optional => 1,
#		},
	};
	my %valid = Params::Validate::validate(@params, $spec);
	# NB! There should be a check for more than one source type here
	# NB! Sum of exists() should be exactly 1, I guess?
	%{ $self } = %valid;
	# From here, we use different population subs for
	# the each different source types
	if (exists($valid{data})) {
		$self->_buildfromdata;
	}
	elsif (exists($valid{string})) {
		$self->_buildfromstring;
	}
	elsif (exists($valid{location})) {
		$self->_buildfromlocation;
	}
	return $self;
}

# ---------------------------------------------------------------------
# Methods
#
# Access methods
#
# namespace
sub namespace ($self) {
	# NB!!! Some error handling would help
	return $self->{namespace};
}
# namespace prefix (used for internal XPath searches)
sub nsprefix ($self) {
	# NB!!! Some error handling would help
	return $self->{nsprefix};
}
sub rootelementname ($self) {
	# NB!!! Some error handling would help
	return $self->{rootelementname};
}
sub encoding ($self) {
	# NB!!! Some error handling would help
	return $self->{encoding};
}
sub dom ($self) {
	# NB!!! Some error handling would help
	return $self->{dom};
}
sub rootelement ($self) {
	# NB!!! Some error handling would help
	return $self->{dom}->documentElement();
}
sub xpathcontext ($self) {
	# NB!!! Some error handling would help
	return $self->{xpc};
}
sub xpathcontextprefix ($self) {
	# NB!!! Some error handling would help
	return $self->{xpcprefix};
}

# Encoding/decoding
#
sub _buildfromdata ($self) {
	# We do not want the data object to remain stored
	# after building. It is not part of this object.
	my $data = delete($self->{data});
	# Now set up a namespace compliant XML document
	# Create doc (we use a local var here for speed)
	my $dom = $self->{dom} = XML::LibXML::Document->new('1.0',$self->encoding);
	$self->_xpathcontext;
	# And create the top node
	my $root = $dom->createElement($self->rootelementname);
	$root->setNamespace($self->namespace, $self->nsprefix, 1);
	$dom->addChild($root);

	# This code is analogous to the ARGV building code in
	# SBTal::Config. It just loops through an SBTal::Config
	# structure and builds up the XML.
	while (my ($key, $val) = each %$data) {
#		my $keynode = $dom->createElementNS($self->namespace,'key');
		my $keynode = $dom->createElement('key');
		$keynode->setAttribute('id', $key);
		$root->addChild($keynode);
		$keynode->setNamespace($self->namespace, $self->nsprefix, 1);
		if (ref($val) eq 'ARRAY') {
			# Note that the order, here, may be significant
			foreach my $v (@$val) {
				my $valnode = $dom->createElement('value');
				$keynode->addChild($valnode);
				my $tn = XML::LibXML::Text->new($v);
				$valnode->addChild($tn);
				$valnode->setNamespace($self->namespace, $self->nsprefix, 1);
			}	
		}
		elsif (ref($val) eq 'HASH') {
			while (my ($k, $v) = each %$val) {
				my $subkeynode = $dom->createElement('subkey');
				$subkeynode->setAttribute('id', $k);
				$keynode->addChild($subkeynode);
				my $valnode = $dom->createElement('value');
				$subkeynode->addChild($valnode);
				$subkeynode->setNamespace($self->namespace, $self->nsprefix, 1);
				my $tn = XML::LibXML::Text->new($v);
				$valnode->addChild($tn);
				$valnode->setNamespace($self->namespace, $self->nsprefix, 1);
			}	
		}
		else {
			my $valnode = $dom->createElement('value');
			$keynode->addChild($valnode);
			my $tn = XML::LibXML::Text->new($val);
			$valnode->addChild($tn);
			$valnode->setNamespace($self->namespace, $self->nsprefix, 1);
		}
	}
	#print STDERR "OOOOO\n$dom\n";
}
sub _buildfromstring ($self) {
	# We do not want the data object to remain stored
	# after building. It is not part of this object.
	my $string = delete($self->{string});
	# Create a parser
	my $parser = XML::LibXML->new(
		no_blanks => 1,
		clean_namespaces => 1,
	);
	# Create the document by parsing the string (and use a local copy
	# for some speed)
	my $dom = $self->{dom} = $parser->load_xml(string=>$string);
	$self->_validateparseddom;
	# We now feel confident to create the XPath context
	$self->_xpathcontext;
	return $self;
}
sub _buildfromlocation ($self) {
	# We do not want the data object to remain stored
	# after building. It is not part of this object.
	my $location = delete($self->{location});
	# Create a parser
	my $parser = XML::LibXML->new(
		no_blanks => 1,
		clean_namespaces => 1,
	);
	# Create the document by parsing the string (and use a local copy
	# for some speed)
	my $dom = $self->{dom} = $parser->load_xml(location=>$location);
	$self->_validateparseddom;
	# We now feel confident to create the XPath context
	$self->_xpathcontext;
	return $self;
}
# $argv => $obj->toargv;
sub toargv ($self) {
	# We're assuming that this object has an approriate dom
	# with an appropriate document root element set
	# We're then walking through the tree, rather than e.g. catching
	# all "key" elements with an XPath. This method makes strong
	# assumptions about structure, which is fine - the whole idea
	# with this XML format is that it should be subclassed and toargv
	# as well as toxml overridden if some other format is needed.
	my $root = $self->rootelement;
	my $nspref = $self->nsprefix;
	if ($nspref) {$nspref.=':';}
#	print STDERR "$nspref\n$root\n";
	my @argv;
	foreach my $keynode ($root->getChildNodes()) {
		my $key = $keynode->getAttribute('id');
		foreach my $childnode ($keynode->getChildNodes()) {
			# If this is a value node, we have either a single val or an array
			if ($childnode->nodeName eq "${nspref}value") {
				# NB! This (and the next use of the same expression) may
				# NB! cause a bug, of several text nodes have somehow been created
				push @argv, "--$key", $childnode->getChildNodes->[0]->textContent;
			}
			elsif ($childnode->nodeName eq "${nspref}subkey") {
				# We need to do some more work
				my $subkey = $childnode->getAttribute('id');
				foreach my $subkeynode ($childnode->getChildNodes) {
					#$subkeynode->nodeName eq "${nspref}value" or die;
					push @argv, "--$key", "$subkey=".$subkeynode->getChildNodes->[0]->textContent;
				}
			}
		}
	}
#	print STDERR "HERE\t".join(".", @argv) . "\n";
	return [@argv];
}
# ---------------------------------------------------------------------
# Helpers
#
sub _xpathcontext ($self) {
	# Create the xpath object
	# Set up an XPath object to simplify namespace management
	# in XPath search. We use a default namespace declaration
	# on the XML root element, but we need to name it explicitly
	# in order to make xpath searches work.
	# See https://metacpan.org/pod/XML::LibXML::Node)
	$self->{xpc} = XML::LibXML::XPathContext->new($self->dom);
	$self->{xpcprefix} = $self->nsprefix || 'xsbtc';
	$self->xpathcontext->registerNs($self->xpathcontextprefix, $self->namespace);
	return $self;
}
sub _validateparseddom ($self) {
	# Now lets do some tests. The assumption is that the parsed
	# document should conform to what is set in the SBTal::Config::XML
	# construction call (though all of these params have defaults) or
	# we raise an error
	my $dom = $self->dom;
	# Check encoding
	if ($dom->encoding ne $self->encoding) {
		$log->critical("Encoding mismatch. Expected " . $self->encoding . ", got " . $dom->encoding);
		die;
	}
	# Check root element (just the name, w/o namespace)
	my $rootname = $dom->documentElement()->localname;
	if ($rootname ne $self->rootelementname) {
		$log->critical("Root element mismatch. Expected " . $self->rootelementname . ", got " . $rootname);
		die;
	}
	# Check namespace and namespaceprefix
	# The only check we do here is to see that the prefix and namespace
	# given in the params exist in the document, and that they are matched
	# to each other
	# We start by looking up the prefix defined for our namespace, if any
	my $nsprefix = $dom->documentElement()->lookupNamespacePrefix($self->namespace);
	# Did it exist at all?
	unless (defined($nsprefix)) {
		$log->critical("Namespace mismatch. The expected " . $self->nsprefix . " namespace does not exist in XML");
		die;
	}
	# Does its prefix match
	if ($nsprefix ne $self->nsprefix) {
		$log->critical("Namespace prefix mismatch. Expected '" . $self->nsprefix . "', got '" . $nsprefix . "'");
		die;
	}
	return $self;
}

1; # Magic true value required at end of module

__END__

=pod

=encoding utf-8

=head1 NAME

SBTal::Config::XML - Defines XML format for SBTal::Config

=head1 VERSION

This document describes SBTal::Config::XML v0.1.0

=head1 SYNOPSIS

use SBTal::Config::XML;

# Encode XML from SBTal::Conf
my $conf = SBTal::Config->new(%params);
$conf->toconf(argv=>$argv);
my $xmlconf = SBTal::Config::XML->new(data=>$conf->data);

# Decode XML to SBTal::Conf
my $conf2 = = SBTal::Config->new(%params);
$conf2->toconf(argv=>$xmlconf->toargv);

# Other ways of building the XML conf
# From stringified XML
my $xmlconf2 = SBTal::Config::XML->new(string=>$stringifiedxml);
# From file
my $xmlconf3 = SBTal::Config::XML->new(location=>$xmlfile);

=head1 DESCRIPTION

See L<SBTal::Config/"FORMATS AND CONVERSIONS"> for more info.

This module implements the generic XML format specification for
L<SBTal::Config>. It also doubles as a reference implementation
of a format module.

=head1 CONSTRUCTORS

=head2 C<< $o = SBTal::Config::XML->new() >>

my $o = ($obj|SBTal::Config::XML)->new(%PARAMS);

%PARAMS = (
 # Come with good defaults, set only if subclassing
 namespace       => NAMESPACE,
 nsprefix        => NSPREFIX,
 rootelementname => ROOTNAME,
 encoding        => ENCODING,
 # One but not more of the following
 data            => SBTALCONFDATA,
 string          => STRINGIFIEDXML,
 location        => FILELOCATION,
 io              => FILEHANDLE,
);

=head2 OPTIONAL PARAMS

These are really only useful when subclassing, if the
generic L<SBTal::Config::XML> format is what's required,
then the defaults are good.

=head3 C<namespace (STRING, optional)>

Defaults to L<http://sprakbanken.speech.kth.se/xmlns/2022/config/>.

=head3 C<nsprefix (STRING, optional)>

Defaults to the empty string, in which case the namespace is
added as a default namespace on the document root element.

If a string is passed, then the namespace is added explicitly
to all element.

Note that the handling of searches with the XPath context object is
managed automatically. If the default namespace is used, then the
XPath context will silently define and register a C<xsbtc> prefix and
use it for internal XPath searches.

=head3 C<rootelementname (STRING, optional)>

Defaults to C<config>.

=head3 C<encoding (STRING, optional)>

Defaults to C<UTF-8>, which is the also strong recommendation for
all SBTal code. Departures from this recommendation mest be
documented together with a clear motivation.

=head2 CONFIG BUILDING PARAMS

One of these must be given, and more than one must not. These
params provide the contents for the XML configuration. Note that
in this system, there is no such thing as an empty format object -
format objects are always instantiated with an actual configuration.

Also, configurations are not manipulated in the format object. If
they are to bemanipulated, the L<SBTal::Config> object, which supports
cascading population of configs and overwriting, is used, and then a
new (XML) format object is built from the new configuration.

=head3 C<data (HASH, semi-mandatory)>

If the data parameter is given, it must contain a reference to a
data hash that conforms to L<SBTal::Config>'s L<internal data structure
specification|SBTal::Config/"INTERNAL DATA STRUCTURE">.

=head3 C<string (SCALAR, semi-mandatory)>

If given, a stringified, compliant XML should be passed.

=head3 C<location (SCALAR, semi-mandatory)>

If given, the locationof a compliant XML file should be passed.

=head1 ACCESS METHODS

=head2 ACCESS TO XML CONFIG

=head3 C<< $o->namespace >>

Access to the namespace used by the config XML. This will likely be the
default L<http://sprakbanken.speech.kth.se/xmlns/2022/config/> namespace
unless we're in a subclass format.

=head3 C<< $o->nsprefix >>

This is the namespace prefix. If the config namespace is set as the default
namespace, this returns the empty string. In that case, the associated prefix
to use with the XPath context object is C<xsbtc>.

=head3 C<< $o->rootelementname >>

The local name of the root element (i.e. without namespace).
Default is C<config> and that is likely only changes if we're in a subclass.

=head3 C<< $o->encoding >>

The encoding of the XML. This really should always return C<UTF-8>.

=head2 Access to XML objects

=head3 C<< $o->dom >>

This returns the XML document. Note that manipulating this in order to
change the configuration is against the L<SBTal::COnfig> specification.
Inspecting is fine, though, for example in order to do visualisation.

=head3 C<< $o->rootelement >>

This returns the root element node.

=head3 C<< $o->xpathcontext >>

This returns the XPath context. Use this to search the XML. If no
explicit namespace is set, then this object uses C<xsbtc> to refer to
the default namespace.

=head3 C<< $o->xpathcontextprefix >>

Returns the same as C<nsprefix> if an explicit namespace is used, otherwise
C<xsbtc>, which is used to refer to the default namespace.

=head1 METHODS

=head2 C<< my $argv = $o->toargv >>

Builds an ARGV style array and returns a reference to it. Feeding this
argv to and C<SBTal::Config> object's C<toconf> method's C<argv> param
is the only way an XML format object should be turned into an SBTal
configuration.


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

SBTal::Config::XML requires no configuration files or environment variables.


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

Jens Edlund C<<< edlund@speech.kth.se >>>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2022, Jens Edlund & Språkbanken Tal
C<< hojta@sprakbanken.speech.kth.se >>. All rights reserved.

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
