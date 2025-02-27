package MTM;
#*****************************************************************************#
#
# MTM.pm
#
# Base class for Perl speech technology software developed at Swedish Agency
# for Accessible Media (MTM)
#
# This is an abstract class providing generic  methods for other classes.
#
#*****************************************************************************#
use strict;		# NB!!! remove before release
use warnings;	# NB!!! remove before release

#*****************************************************************************#
#
# Module initialization
#
#*****************************************************************************#
#
# Pull in supporting modules
#
use DateTime; # Platform and zone independent time
use DateTime::Format::ISO8601;

#*****************************************************************************#
#
# Inhereted constructors
#
#*****************************************************************************#

sub new {
	my $proto = shift;
#	print STDERR "$proto\n";
	my $class = ref($proto) || $proto;
	my $index = shift;
	my $self = {
	##### (NB) This should go - just make sure it really isn't used
		DATA	=> {
			DOCUMENTS => [],
		},
	};
	bless($self, $class);
	$self->_init(@_);
	$self->fb(level=>0, msg=>"Create $class object");
	return $self;
}

# General initialize method for all objmeects of the MTM family
sub _init {
	my $self = shift;
	# Built initialization hash
	my %init = (
		CREATED		=> $self->now,	# Store time using ISO standard
		FB_LEVEL	=> 6,			# Feedback turned off by default (max level = 5)
		FB_CHANNEL	=> \*STDERR,	# Feedback written to STDERR by default
	);
	$self->{INIT} = \%init;
	# MTM original codebase legacy flags, with defaults
	$self->_legacy;
	# Initialize error data
	$self->_success;
	return $self;
}
#*****************************************************************************#
#
# Legacy flags
#
# There are a number of flags that where present in the original codebase that
# for the time being are left more or less untouched. We have however moved
# them from being 'our' scoped parameters to MTM object scope - so they'read
# tucked away in the abstract MTM class
###### (TODO) These flags have not been moved in properly yet
###### (TODO) our $pathLanguageTools = dirname(File::Spec->rel2abs(__FILE__));
###### (TODO) $pathLanguageTools =~ s/languagetools.*$/languagetools/i;
sub _legacy {
	my $self = shift;
	my $legacy = {
		DEBUG          => 1,
		INSERT_RATE    => 0,
		TTS            => 'mtm',
		RUNMODE        => 'normal',
		DOCONTEXTCHECK => 0,
		READERCUTOFF   => -1, # Set to -1 to read all posts, otherwise at #posts
		# For initial building, these have to be 'SRL' and 'retrieve'
		LISTMODE       => 'DB_File',  # SRL/DB_File
		LISTMETHOD     => 'retrieve', # build/retreive
	};
	$self->{LEGACY} = $legacy;
	return $self;
}
# The get/set legacy methods are restricted to predefined flags
sub get_legacy {
	my $self = shift;
	my $flag = shift;
	$flag = uc($flag);
	return exists($self->{LEGACY}->{$flag})?
		$self->{LEGACY}->{$flag}:
		undef;
}
sub set_legacy {
	my $self = shift;
	my $flag = shift;
	my $val = shift;
	$flag = uc($flag);
	return exists($self->{LEGACY}->{$flag})?
		($self->{LEGACY}->{$flag} = $val):
		undef;
}
#*****************************************************************************#
#
# Feedback and error handling
#
#*****************************************************************************#
#
# fb - simple tiered feedback system
##### NB! Make this a binary switch instead, e.g. 000010 2
#
sub fb {
	my $self = shift;
	my %params;
	if (@_>1) {
		%params = @_;
	}
	else {
		# This is the short form with only one parameter
		$params{level}=0; # We default level to 0, i.e. the least severe level
		$params{msg} = shift;
	}
	if (my $p = $self->_fb_channel($params{level})) {
		print $p ($params{msg}, "\n");
		return $p;
	}
	return undef;
}
#
# fb_level - set/get feedback level (anything of same or higher level gets through)
#
sub fb_level {
	my $self = shift;
	my $level = shift;
	return $self->{INIT}->{FB_LEVEL}
		unless defined($level);
	return $self->{INIT}->{FB_LEVEL} = $level;
}
#
# _fb_channel - currently a hidden method for getting the current feedback channel
# if fb_level is set low enough, otherwise this returns undef.
sub _fb_channel {
	my $self = shift;
	my $level = shift;
	return $self->{INIT}->{FB_CHANNEL}
		unless $self->{INIT}->{FB_LEVEL} > $level;
	return undef;
}
sub _error {
	my $self = shift;
	$self->{ERROR}->{ERROR_CODE} = shift;
	$self->{ERROR}->{ERROR} = shift;
}
sub _success {
	my $self = shift;
	$self->{ERROR}->{ERROR_CODE} = 0;
	$self->{ERROR}->{ERROR} = 'ok';
}

#*****************************************************************************#
#
# Access and manipulation methods
#
# Access created time
sub get_created {
	my $self = shift;
	return $self->{INIT}->{CREATED};
}


# Convenience method returning the current time (UTC) in ISO 8601 format.
# This is used bu the initialization code to timestamp objects.
sub now {
	# no need to pop $self really
	return DateTime::Format::ISO8601->format_datetime(DateTime->now(time_zone=>'UTC'));
}


1;


__END__

=pod

=cut
