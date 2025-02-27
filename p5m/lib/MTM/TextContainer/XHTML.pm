package MTM::TextContainer::XHTML;
#*****************************************************************************#
#
# MTM/TextContainer/XHTML.pm 
#
# EPUB management handling class for use with MTM's TTS preprocessing system
# 
#*****************************************************************************#
use strict;		# NB!!! remove before release
use warnings;	# NB!!! remove before release

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM::TextContainer);


sub _init {
	my $self = shift;
	# Set up the Xpath context. We keep this visible here, as the details will be made configurable in time.
	# The actual context creation is placed in the parent, since it's shared by EPUB and XHTML.
	# Object creation that dies on fail, which is what we want. 
	# No extra error handling required
	my $xpc = $self->newxpc(
		# Setup an XPath context object for namespace management 
		# in XPath search. We set the XHTML namespace to use the 
		# 'x' prefix here (as the XMTML docs we read uses the default
		# namespace for XHTML, but we need to name it explicitly)
		'x',          'http://www.w3.org/1999/xhtml',
	);
	$self->xpc($xpc) or die "Cannot set Xpath context";
	# And allow for the parents _init to run as well...
	return $self->SUPER::_init;
}

SETGET: {
	##### JE: These will be generalised before release - see issue #73
	sub dom {
		my $self = shift;
		my $dom = shift;
		return exists($self->{DOM})?$self->{DOM}:undef
			unless $dom;

		# This returns the set value, which is standard for a setget method
		return $self->{DOM} = $dom;
	}
}


1;

__END__

=pod

=head1 Name MTM::TextContainer::XHTML

Class to handle XHTML documents for the MTM TTS preprocessing system

=head1 Methods

=head2 $o->dom;

Setget for the XML DOM object.

=cut

