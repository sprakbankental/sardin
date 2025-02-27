package MTM::TextContainer;
#***************************************************************************#
#
# MTM/TextContainer.pm 
#
# Base class for holding various text formats for use with 
# MTM's TTS preprocessing system
# 
# This is an abstract class providing generic methods for other classes. 
#
#***************************************************************************#
use strict;		# NB!!! remove before release
use warnings;	# NB!!! remove before release

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM);

#***************************************************************************#
#
# Factory methods
#
# NB! These could be generalised, but we expect them to differ in 
# contents in time
EPUB: {
	require MTM::TextContainer::EPUB;
   my $count = 0;
   sub newepub { 
		my $epub = MTM::TextContainer::EPUB->new(@_); 
       $epub->{INDEX} = ++$count; # start book count on 1
		$epub->{TEXT} = MTM::Text->new;
		return $epub;
	}
	sub epub_since_boot { return $count }
}
XHTML: {
	require MTM::TextContainer::XHTML;
   my $count = 0;
   sub newxhtml { 
		my $xhtml = MTM::TextContainer::XHTML->new(@_); 
       $xhtml->{INDEX} = ++$count; # start book count on 1
		$xhtml->{TEXT} = MTM::Text->new;
		return $xhtml;
	}
	sub xhtml_since_boot { return $count }
}
XML: {
	require XML::LibXML; 
	# Create new XPath context (just a convenience method)
	sub newxpc {
		my $self = shift;
		my %namespaces = @_;
		# For object creation, we fail completely on fail.
		my $xpc = XML::LibXML::XPathContext->new() or die "Could not create XPath context";
		while (my ($prefix, $ns) = each %namespaces) {
			# XML::LibXML::XPathContext::registerNs dies on fail all by itself
			# which is what we want here, no extra error handling required
			$xpc->registerNs($prefix, $ns);
		}
		return $xpc;
	}
}
#***************************************************************************#
#
# The methods are used by most (all?) format specific sub-classes
SETGET: {
	# Access method to the underlying text object that holds extracted,
	# pure text for any MTM::TextContainer object, regardless of its 
	# original format.
	##### JE 20210926 Setting this should likely not be a public method (but getting
	#####             likely should). 
	sub text {
		return $_[0]->{TEXT};
	}
	# Sets (and gets) the current infile
	# This should check for existance and readbility and warn + return undef if this fails 
	# if either of these fail
	##### JE 20210926 Setting this should likely not be a public method (but getting
	#####             likely should). We should view the objects as containers, not
	#####             as parsers or container creators. So they parsing happens once
	#####             at creation time, and the object factory is akin to a parser.
	#####             Meaning that the infile is set once and not changed.
	sub infile {
		my $self = shift;
		my $file = shift;
		return exists($self->{INFILE})?$self->{INFILE}:undef
			unless $file;
		# Check file existance and readbility
		# We'll be better off parsing the path into a Path::Class::File object in some future version
		if (! -e $file) {
			$self->result("$file does not exist");
			return undef;
		}
		elsif (! -r $file) {
			$self->result("$file is not readable");
			return undef;
		}
		# Chatty feedback
		$self->fb(ref($self) . " setting infile to $file");
		# Store the filename and path_info
		return $self->{INFILE} = $file; # This returns the set value, which is standard for a setget method
	}
	# XPath contexts won't be relevant for all subclasses, but it is for the two main ones at the time 
	# of implementation: XHTML and EPUB. So we place it here in the parent.
	sub xpc {
		my $self = shift;
		my $xpc = shift;
		return exists($self->{XPC})?$self->{XPC}:undef
			unless $xpc;
		# Store the filename and path_info
		return $self->{XPC} = $xpc; # This returns the set value, which is standard for a setget method
	}

}

1;

package MTM::Text;

# This is placeholder code for the Text package. The package will be responsible for 
# holding pure text and keeping track of the indeces of each specific character
# in the text.
# For now, it just holds text.

# Note that currently, this 'new' method blocks calling the abstract parent MTM*s _init method.
# Or rather the class doesn't even inherit MTM...
sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = [];
	return bless $self, $class;

}

sub append {
	my $self = shift;
	push @{ $self}, @_;
	return $self;
}

sub string {
	return join '', @{ $_[0] };
}


__END__

=pod

=encoding utf8

=head1 NAME 

MTM::TextContainer - abstraction class for text containers 

=head1 SYNOPSIS

C<use MTM::TextContainer>

C<my $epub = MTM::TextContainer-E<gt>newepub(%PARAMS)>

C<my $epubcount = MTM::TextContainer-E<gt>epub_since_boot>

C<my $xhtml = MTM::TextContainer-E<gt>newxhtml(%PARAMS)>

C<my $xhtmlcount = MTM::TextContainer-E<gt>xhtml_since_boot>

C<my $xpc = MTM::TextContainer-E<gt>newxpc>

C<my $anytextcontainer-E<gt>infile($INFLILE)>

C<my $infile = $anytextcontainer-E<gt>infile>

C<my $anytextcontainer-E<gt>infile($xpc)>

C<my $xpc = $anytextcontainer-E<gt>xpc>

C<my $plaintext = $anytextcontainer-E<gt>text>

Synopses for object specific methods are found under the objects'
respective modules.

=head1 DESCRIPTION

The C<MTM::TextContainer> abstraction class holds text to be processed by 
the MTM text processing system. It provides object factories for EPUB and 
XHTML containers, as well as access methods for MTM-relevant data contained 
in these formats. B<It does not> strive to be a generic, full-featured access 
object for either EPUB (here there seems to be a lack of good options on 
CPAN) or XML (here, LibXML does an excellent job, and is also what the XHTML 
object inherits from).

=head2 EPUB OBJECT FACTORY

For details, see L<MTM::TextContainer::EPUB>.

=head3 C<my $epub = MTM::TextContainer-E<gt>newepub(%PARAMS)>

Creates a new TextContainer from an EPUB file. 

=head3 C<my $count = MTM::TextContainer-E<gt>epub_since_boot>

Returns the count of EPUB objects created inb the factory since boot.

=head2 XHTML OBJECT FACTORY

For details, see L<MTM::TextContainer::XHTML>.

=head3 C<my $xhtml = MTM::TextContainer-E<gt>newxhtml(%PARAMS)>

Creates a new TextContainer from an XHTML file. 

=head3 C<my $count = MTM::TextContainer-E<gt>xhtml_since_boot>

Returns the count of XHTML objects created inb the factory since boot.

=head2 Convenience methods

=head3 C<my $xpc = MTM::TextContainer-E<gt>newxpc(%NAMESPACES)>

A convenience method that creates a XPath context with the namespaces
passed in. XPath contexts are used by the XHTML portion of EPUB objects
and by the XHTML objects. If called without an argument, they all return 
C<undef> if called before they've been set, otherwise they return their
value. If called with an argument, they attempt to set the value, 
potentially after some validation.

=head2 Setget methods

The abstraction layer implements some setget methods that are useful for 
many or all C<MTM::TextContainer>s.

=head3 C<$tc-E<gt>infile($INFLILE)>, C<my $infile = $tc-E<gt>infile>

C<infile> is usually not called explicitly by an application, but is used 
by the specific C<MTM::TextContainer> to set the infile at creation time 
(at which it is passed as an argument), as well as whenerver the original 
file location is required. Changing the infile value of an already initialised
object may have unpredictable results. B<It is possible that (setting) this 
should be an internal method.>

=head3 C<$tc-E<gt>text($TEXT)>, C<my $text = $tc-E<gt>text>

C<text> is usually not set explicitly by an application, but is used 
by the specific C<MTM::TextContainer> to set the text after it has been 
prepared. Changing the text value of an already initialised object may 
have unpredictable results. B<It is possible that (setting) this should be 
an internal method.>

=head3 C<$tc-E<gt>text($XPC)>, C<my $xpc = $tc-E<gt>xpc>

C<xpc> is usually not of interest to an application. B<It is highly possible 
that this should be an internal method.>

=head1 ERRORS

The module currently C<die>s on critical errors and returns undef on 
non-critical errors. No more fine-grained error handling is implemented, but 
this is in the pipeline for the MTM text processing system as a whole and 
the C<MTM::TextContainer> code will follow.

=head1 EXAMPLES



=head1 CAVEATS

The C<MTM::TextContainer> does not provide a full interface to any text container
formats, nor does it aspire to do so. It provides only the functionality necessary
to work with text containers from a speech science poiunt of view.

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

=head1 SEE ALSO

=over

=item L<MTM::TextContainer::EPUB>

=item L<MTM::TextContainer::XHTML>

=back

=cut

