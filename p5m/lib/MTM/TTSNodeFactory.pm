package MTM::TTSNodeFactory;
use strict;
use warnings;

# Uncomment this statement to check inline TODOs
# use Smart::Comments '#####';

use parent qw(MTM::Tie::CursorArray);

# We're using AUTOLOAD, and want to be able to 
# (1) pass unrecognized stuff along to the next module
# (2) use "can" tests, so we have to reimplement "can" to
#	properly list autoloaded stuff, but then we want
#	to pass failed "can" calls along too.
#	Enter use NEXT; 
use NEXT; 

##### TODO add node factory section here
# Set up a namespace for package scoped data
# Important to put the package scoped data where it should be 
# and the TTSPreprocessor engine (object) scoped data in 
# the TTSPreprocessor object
# Note also that we're not envisioning any plug-ins reimplementing 
# the data structure. We are envisioning plug-ins that adhere to 
# the structure but adds/swaps the processing methods, e.g. normalization,
# analysis, aso. Still, collecting the constructors here makes sense.

#*****************************************************************************#
#
# Factory methods
#
##### TODO: add straightforward subclassing option
# We'd want to be able to register these classes at runtime (in
# order to facilitate subclassing that overrides specific 
# methods - we should not expect any changes in the structure itself.
#
# NB! These could be generalised, but we expect them to differ in 
# contents in time
PREPROCESSOR: {
	require MTM::TTSPreprocessor;
	my $count = 0;
	sub newpreprocessor { 
		my $preprocessor = MTM::TTSPreprocessor->new(@_); 
		$preprocessor->{index} = ++$count; # start chunk count on 1
		return $preprocessor;
	}
	sub preprocessors_since_boot { return $count }
}
DOCUMENT: {
	require MTM::TTSDocument;
	my $count = 0;
	sub newdocument { 
		my $document = MTM::TTSDocument->new(@_); 
		$document->{index} = ++$count; # start chunk count on 1
		return $document;
	}
	sub documents_since_boot { return $count }
}
CHUNK: {
	require MTM::TTSChunk;
	my $count = 0;
	sub newchunk { 
		my $chunk = MTM::TTSChunk->new(@_); 
		$chunk->{index} = ++$count; # start chunk count on 1
		return $chunk;
	}
	sub chunks_since_boot { return $count }
}

TOKEN: {
	require MTM::TTSToken;
	my $count = 0;
	sub newtoken { 
		my $token = MTM::TTSToken->new(@_); 
		$token->{index} = ++$count; # start token count on 1
		return $token;
	}
	sub tokens_since_boot { return $count }
}

#*****************************************************************************#
# Setup autoloading
# 
	our $AUTOLOAD;
	use vars qw( $Recursivemethods );
	$Recursivemethods = {
			normalise	=> 1,
			chunk		=> 1,
			tokenise	=> 1,
			pos_tag	=> 1,
			print_tokens	=> 1,
			print_legacy	=> 1,
			legacy_print_width	=> 1
	};

RECURSIVE: {
	# The use of AUTOLOAD might be questionable here, given that we want
	# reasonably efficient code, but that could be said more strongly 
	# about Perl OO code in general. We're putting extendability and 
	# generality before efficiency here - as long as we maintain roughly 
	# the same efficiency as the original codebase. So:
	#
	# NB! AUTOLOADed mthods currently do not effect the array cursor
	# NB! when they're executed. They could, but they don't. If we ever 
	# NB! want that behavior, there should be a switch or two batches
	# NB! of recursive methods with different basic behaviours.
	# NB! As it is now, we could say that the execution of these methods,
	# NB! on the top leaf, is context independent.
	# NB! It seems sensible to execute on the containing level if we
	# NB! want context depencence, after all, the containing array is 
	# NB! what holds the context.
	#
	# We 
	# (1) use AUTOLOAD to catch any methods that aren't implemented 
	#	in classes that inherits MTM::Tie::CursorArray.
	sub AUTOLOAD {
		my $self = shift;
		# (2) Get the original method name and swiftly lose any qualifiers
		my $called = $AUTOLOAD;
		$called =~ s/.*:://;
		### AUTOLOAD reached by call from $self to $called...
		# (3) Check if this is something we can send along recursively
		if ($self->_is_recursive($called)) {
			# (3a) It is, so we call it recursively, provided we're holding 
			#	objects to call one
			return undef unless exists($self->{ARRAY});
			foreach my $obj (@{ $self->{ARRAY} }) { # A bit hard-coded
				unless (ref($obj)) {
					warn "Method $called called on non-object";
					next;
				}
				unless ($obj->can($called)) {
					warn "Method $called called on an object that cannot handle it";
					next;
				}
				$obj->$called(@_);
			}
		}
		# (3b) We currently only allow recursive launches, so if that doesn't
		#	work, we fail.
		else {
			return undef;
		}

	}
	# Fix "can" so that it reports AUTOLOADed methods as acceptable.
	sub can {
		my $self = shift;
		my $method = shift;
		#print STDERR "XXXXXXXXXXXX Looking for $method!!\n";
		$self->_is_recursive($method) && return 1;
		return $self->NEXT::can($method);
	}
	# This checks if a method is recursive
	###### (TODO) We could make this available for configuration at runtime
	sub _is_recursive {
		my $self = shift;
		my $method = shift;
		return exists($Recursivemethods->{$method});
	}
}



1;

__END__

=head1 NAME

C<MTM::TTSNodeFactory>

=head1 SYNOPSIS

	C<use MTM::TTSNodeFactory;>

	C<my $preprocessor	= newpreprocessor();>
	C<my $document	= newdocument();>
	C<my $chunk		= newchunk();>
	C<my $token		= newtoken();>

=head1 DESCRIPTION

C<MTM::TTSNodeFactory> - abstract Perl class assisting object creation for MTM TTS preprocessing data
structures.

The nodes created are tied arrays L<MTM::Tie::CursorArray> designed
to hold other (potential array) objects.

=head1 METHODS

The methods in this package are factory methods for the central objects of the preprocessing system.

=head2 C<my $preprocessor = newpreprocessor()>

C<newpreprocessor> instantiates a preprocessor object.

=head2 C<my $document = newdocument()>

C<newdocument> instantiates a document object.

=head2 C<my $chunk = newchunk()>

C<newchunk> instantiates a chunk object.

=head2 C<my $token = newtoken()>

C<newtoken> instantiates a token.

=head2 C<my $count = preprocessors_since_boot()>

C<preprocessors_since_boot> returns the number of instantiated preprocessors.

=head2 C<my $count = documents_since_boot()>

C<documents_since_boot> returns the number of instantiated documents.

=head2 C<my $count = chunks_since_boot()>

C<chunks_since_boot> returns the number of instantiated chunks.

=head2 C<my $count = tokens_since_boot()>

C<tokens_since_boot> returns the number of instantiated tokens.

=cut 

