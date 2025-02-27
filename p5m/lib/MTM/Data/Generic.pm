package MTM::Data::Generic;

# Note that for Sereal persistance, we need to provide
# the callbacks anew when retrieving the data. The 
# reason is that Sereal does not support serialisation
# of code references, so instead we remove the callback 
# code references before storing. And so they have to be 
# returned upon retrieval.
use strict;
use warnings;

use File::Temp;
use Sereal::Encoder;
use Sereal::Decoder;

use parent qw(MTM::Data);

sub _init {
	my $self = shift;
	print STDERR "in new with @_\n";
	my %params = @_;
	# We require a number of callbacks to be present:
	my @required = qw(to_csv from_csv);
	foreach my $cb (@required) {
		die "$cb callback required" unless exists $params{$cb};
		$self->{CB}->{$cb} = $params{$cb};
	}
	$self->SUPER::_init;
}

# Callback launchers
sub to_csv   { $_[0]->{CB}->{ to_csv   }(@_) }
sub from_csv { $_[0]->{CB}->{ from_csv }(@_) }

# Sereal store/retrieve (handling callback issues caused by the 
# mechanics of the Generic data structure.)
sub store {
	my $self = shift;
	my $file = shift or die "File storage requires a file\n";
	# -w $file or die "$file cannot be written";
	my $cb = delete($self->{CB});
	# store $self;
	$self->{CB} = $cb;
	return $self;
	# Remove callbacks before storing
}
sub retrieve {
	# If called on a class, we create the object
	# then call again on the object.
	# We retrieve a callbackless object, then add the 
	# callback methods from the object retrieve is 
	# called on. 
	my $proto = shift;
	my $file = shift or die "File retrieval requires a file\n";
	# If we're in an object, we still create a new object and 
	# just steal the callbacks from the object...
	my $obj;
	if (ref($proto)) {
		$obj = $proto;
	}
	# Otherwise we create the object then steal callbacks
	else {
		$obj = $proto->new(@_);
	}
	##### NB!! We should test some stuff here, the same as for 
	#     Generic creation, on $obj
	my $cb = $obj->{CB};

	# Now retrieve the data into a temporary object
	# my $self = retrieve, then add CB.
}

1;