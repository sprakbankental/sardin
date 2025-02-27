package MTM::Data;
#***************************************************************************#
#
# This module is a superclass for MTM data structures.
# Each data structure should implement, minimally, the following:
# - Conversion to/from some simple text format (e.g. CSV)
# - Conversion to/from a binary storage format (e.g. Sereal serialistion)
# - Object data statistics
# - Well-documented standard access methods
# - Reasonable error management
# - Tests (e.g. of all conversions)
# Optional functionality:
# - Off memory data
# - Conversion to/from DB
# - DB tied data
#
# The MTM::Data object in itself holds data structures of any kind (as long
# as their passed by reference). Each data structure is given the following
# on assignment/creation:
# - Creation and/or assignment time
# - A switch for the existance of a number of standard methods (not access
#   methods)
#
# The following needs to be given at assignment/creation
# - Name (this is how the data is then accessed through the data object)
# - Type (custom for external types)
#
# The MTM::Data module delivers a number of predefined data formats through
# object factories. There's also a generic object factory where the standard
# methods required to be MTM::Data compliant are registered as callbacks at
# object registration.
#
#***************************************************************************#
use strict;
use warnings;
use parent qw(MTM);

sub _init {
	my $self = shift;
	$self->SUPER::_init;
	return 1;
}

# Generic data structure factory
{
	require MTM::Data::Generic;
	my $count = 0;
	sub newgeneric {
		my $generic = MTM::Data::Generic->new(@_);
		$generic->{index} = ++$count; # start chunk count on 1
		return $generic;
	}
	sub generic_since_boot { return $count }
}

1;