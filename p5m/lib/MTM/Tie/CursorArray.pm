 package MTM::Tie::CursorArray;
#
# POD documentation after __END__ below.
#
# ****************************************************************************#
#
# Trace printouts
#
# This is _only_ used under active development, and coded out manually
# at release time.
# Uncomment the next line for development trace printouts
#use Smart::Comments '###', '####', '#####';
# use Smart::Comments '###';
#*****************************************************************************#
#
# MTM::Tie::CursorArray - Perl tied array that keeps track of the cursor (a
# current position). Simplifies iterations when easy access to left and right
# context is desireable. Note that this functionality can easilly be coded
# more efficiently. Here we're aiming for code that is readily readable for
# non-coders.
#
# Extra methods:
# $arrayref->current;     # returns the current cursor's position in the array
# $arrayref->next;        # moves cursor one step to the right
# $arrayref->cursor;      # returns the object at the current cursor
# $arrayref->context($n); # returns the object $n steps away from the cursor
#
# ****************************************************************************#
use strict;
use warnings;

#*****************************************************************************#
#
# Load dependencies and inherit standard array methods
#
#*****************************************************************************#
#
# This is ugly, but Perl (or Tie::Array rather) has a design flaw
# that makes it impossible to use "use parent qw(Tie::StdArray)",
# which would be the better choice.
# See e.g. https://www.perlmonks.org/?node_id=1221954
#
# We want to inheret methods from MTM::Tie as well.
use parent qw(MTM::Tie);

##### (TODO) Implement $Skeletonkey when proper locking is turned on
# So that the "locked" test returns unlocked at all times when $Skeletonkey
# is set. But: we were after a locked=ro unlocked=wo solution, in which case
# we'd want everything to be rw when Skeletonkey is set. So more code or
# different locking mechanism. Maybe simply ro, wo, and skeletonkey (rw)

CONSTRUCTION: {
	# Constructor

	# TIEARRAY creates a new object and an array tied to the object.
	sub TIEARRAY  {
		my $proto = shift;
		my $class = ref($proto) || $proto;
		# Set up the data structure
		my $self = {
			ARRAY	=> [], # This holds the actual array
		};
		bless $self, $class;
		$self->_init;
		### Successfully tied array to $class at <here>...
		return $self;
	}

	# Initialization method (also inherits _init from parent)
	sub _init {
		my $self = shift;
		$self->reset;
		$self->unlock;
		return $self->SUPER::_init;
	}
}

#CONFIGURATION: {
#	# No configuration options are currently implemented in this package
#}

POPULATION: {
	##### (TODO) Block calls on locked arrays!
	# The tied array can either be populated like any array after the
	# call to "tie". There are currently no special methods defined.
	# (Mandatory for tied arrays)
	sub STORE		{ $_[0]->{ARRAY}->[$_[1]] = $_[2] }
	sub STORESIZE	{ $#{$_[0]->{ARRAY}} = $_[1]-1 }
	sub EXISTS		{ exists $_[0]->{ARRAY}->[$_[1]] }
	sub DELETE		{ delete $_[0]->{ARRAY}->[$_[1]] }
	# (Optional for tied arrays)
	sub CLEAR		{ @{$_[0]->{ARRAY}} = () }
	sub POP			{ pop(@{$_[0]->{ARRAY}}) }
	sub PUSH		{ push(@{$_[0]->{ARRAY}}, $_[1]) }
	sub SHIFT		{ shift(@{$_[0]->{ARRAY}}) }
	sub UNSHIFT		{ my $self = shift; unshift(@{ $self->{ARRAY} },@_) }

	sub SPLICE {
		my $self  = shift;
		my $sz  = $self->FETCHSIZE;
		my $off = @_ ? shift : 0;
		$off   += $sz if $off < 0;
		my $len = @_ ? shift : $sz-$off;
		return splice(@{ $self->{ARRAY} },$off,$len,@_);
	}


}

LOCKING: {
	sub lock {
		my $self = shift;
		##### (NB) Validation code here!
		##### (NB) Indexing and self-linking here
		$self->{LOCKED} = 1;
		# Both locking and unlocking resets the array cursor
		$self->reset;
		return $self;
	}
	sub unlock {
		my $self = shift;
		$self->{LOCKED} = 0;
		# Both locking and unlocking resets the array cursor
		$self->reset;
		return $self;
	}
	sub locked {
		my $self = shift;
		return $self->{LOCKED};
	}
}
PROCESS: {
	# This is mainly navigation and lookups
	##### (TODO) Block when unlocked
	##### (TODO) Checks for out of bound access attempts - what happens?
	# This is where the magic happens:
	# Each time a list item is accessed, the cursor is set to that item
	# (Not true if the peek method is used)
	sub FETCH {
		my $self   = shift;
		my $i      = shift;
		$self->{CURSOR} = $i;
		return $self->{ARRAY}->[$i];
	}
	sub FETCHSIZE	{ scalar @{$_[0]->{ARRAY}} }
	# Get a list item relative to the cursor, without moving the cursor

	# If we are pos tagging and orth = whitespace, go one step further.	CT 2020-11-18
	sub peek {
		my $self   = shift;
		my $steps  = shift;
		my $i  = $self->{CURSOR} + $steps;
		return undef if $i < 0; # since e.g. -1 will otherwise fetch the last list item...
		return $self->{ARRAY}->[$i];
	}
	sub reset { $_[0]->{CURSOR} = 0; }
	sub cursor { return $_[0]->{CURSOR}; }
	sub current { $_[0]->peek(0) }
	sub move {
		my $self   = shift;
		my $steps  = shift;
		$self->{CURSOR} += $steps;
		return $self;
	}
	sub array { ... }

}




PERLARRAY: {
	# Most methods are in POPULATION and PROCESS

	sub DESTROY {
		my $self = shift;
		%$self = ();	# Unset data
		##### NB!!! (Open issue) Should we clean up contained objects recursively? (<here>)
		##### NB!!! (TODO) Should unbless as well (<here>)
		### Object $self destroyed at <here>...
	}
	sub EXTEND  {  }
}

return 1;

__END__

=pod

=head1 NAME

C<MTM::Tie::CursorArray> - Class underlying MTM tied arrays

=head1 SYNOPSIS

C<use MTM::Tie::CursorArray;>

C<my @array = ();>

C<my $obj = tie(@array, 'MTM::Tie::CursorArray');>

C<@array = ($subobj1, ... , $subobjN);>

C<$obj-E<gt>lock;>

=head1 OPTIONS

No options in the current implementation.

=head1 DESCRIPTION

This class is the superclass of several MTM preprocessing classes
holding arrays. It imposes a number of restrictions on the arrays,
and extends tha array functionality in several ways.

Objects in this class has a welldefined life cycle:

=over

=item B<Create> - create the object (which is write-only at this stage)

=item B<Configure> - pass configuration settings to the object

=item B<Populate> - add objects to the array

=item B<Lock> - lock the object, making it read-only

=item B<Process> - to processing on the object and on the contained array

=item B<Print/save results> - pretty-print or save the results, or potentially the entire object

=item B<Destroy> - destroy the object

=back

B<Note that there are very specific restrictions on what these
arrays may contain (see L<Population> below).>

=head1 METHODS

=head2 CREATION (CONSTRUCTORS)

=head3 C<my $o = tie(@a, MTM::Tie::CursorArray);>

The creation method is intended to be B<inherited as is>. Ineriting
classes with the need for special options is better of reimplementing
the private method C<_init> (see L<Configuration> below).

=head2 CONFIGURATION

Apart from the population (see L<Population>) there is currently no
run-time options available.

Objects inheriting this class can add their own initialisation by defining
their own C<_init>. In most cases, you would still want the inheretid
initialisation to run (as well), so end the _init method will a call to
C<$self-E<gt>SUPER::_init;>.

=head2 POPULATION

These arrays are intended to be populated once, at creation time, and
then locked. The tied arrays are populated just like any other array,
e.g. with assignment or push.

C<@a = (OBJ1, OBJ2, ... ,OBJN);>

or

C<push @a. OBJ1, OBJ2, ... ,OBJN;>

=head2 LOCKING

=head2 C<$o-E<gt>lock>;

Locks the array for writing.  Returns the array object, so that
C<$o-E<gt>lock-E<gt>locked == 1> holds.


=head2 C<$o-E<gt>unlock>;

Opens a locked array for manipulation/writing. Note that as manipulating the
array may have unexpected effects on the cursor position, locking and unlocking
automatically resets the array (i.e. moves the cursor to 0).

Returns the array object, so that
C<$o-E<gt>lock-E<gt>locked == 0> holds.

=head2 C<$o-E<gt>locked or die 'Unlocked!';>

The C<locked> method returns 1 if the array is locked, otherwise 0;

=head2 PROCESSING

Processing is a question of traversing the array, one way or another,
and performing actions on its contents. An added feature here is the
cursor, which keeps track of the index of last item we looked at. This is
true for any standard list lookup operation i.e. C<$a[0];>, C<print
"@a\n";> or a foreach statement on the array (this would move the cursor
from 0 to the end of the array with each iteration).

However: if the array is created inside an object and stored by
reference (as is the case for thenested lists in this codebase),
the calling script doesn't have access to the original tied array.
And dereferencing it will bypass the overloaded C<FETCH> so the
cursor will not be set (this is how th eC<peek> method works.

Instead, looping around an entire cursor array can be done as
follows:

C<my $o = tie(my @hidden, 'MTM::Tie::CursorArray');>
C<# Populate (in the normal case in the preprocessor code,>
C<# this would be populated by objects, but this works as >
C<# an illustration:>
C<@hidden = qw(a b c);>

C<for ($o->reset; my $val = $o->current; $o->move(1)) {>
C<  print STDERR "Cursor is at " . $o->cursor; # We normally do _not_ need to look at this...>
C<  print STDERR  " and the token is $val\n";>
C<}>

C<$o-E<gt>reset> sets the cursor to the beginning of the array.
C<my $val = $o-E<gt>current> both sets $val to the current array
item and kicks us out when the list is at its end (or when we
hit an unititialized array item, mind...). And
C<$o-E<gt>move(1)> moves the cursor oen step befor the next
iteration. There will be some extra functionality in this last
part in time - we implement SKIPWHITESPACE and such as a flag to
C<move>, and this allows us to do a lot more with the traversal.

=head3 C<my $currentindex = $a-E<gt>cursor;>

The C<cursor> method returns the index of the current cursor. In most
cases, this should not be relevant to a script using this class, but
the method is provided for testing and completeness.

=head3 C<my $currentitem = $a-E<gt>current;>

Returns the list item currently pointed to by the cursor.

=head3 C<$a-E<gt>reset;>

Resets the cursor (i.e. sets it to 0).

Returns the object if successful, otherwise undef.

=head3 C<$a-E<gt>move(STEPS);>

Moves the cursor C<STEPS> steps.

Returns the object if successful, otherwise undef.

Resets the cursor (i.e. sets it to 0).

=head3 C<my $listitem = $a-E<gt>peek(STEPS);>

A central purpose of this package is to allow easy access to neighbouring
list elements without complex code. This implementation provides a C<peek>
method which tages an integer as its argument and returns the list item
that lives that many steps away from the current cursor:

C<@a = qw( a b c);>

C<my $i = $a[1}; # red index 1 (b) and set cursor to 1>

C<my $j = $o-E<gt>peek(-1); # get the preceding item (a) without moving the cursor>

=head2 PROCESSING (AUTOLOADED)

This class has one more feature in addition to the cursor. It implements
B<a method to call a method on each item in the array> On B<nested arrays>,
this is B<can be done recursively>. We use the Perl core's AUTOLOAD
functionality for this, but filter the autoloader so that only
calls that are permitted (this is hard-coded in this release) can be
turned into (recursive) calls over each contained list item.

Currently, the following methods are defined:

=over

=item C<normalise>

=item C<chunk>

=item C<tokenise>

=item C<pos_tag>

=item C<print_tokens>

=back

B<These are somewhat arbitrary, expect the list to change before release>.
Also, this is something that in a later edition will likely be B<turned into
a configurable option on class level>.

The way the recursion works:

Assume that we have a tied array A1 filled with tied arrays A2, which is
again filled with tied arrays A3. We then call e.g. C<chunk> on A1: C<$a1->chunk;>

If A1 does not implement a chunk method, the call is passed in to the inhereted
AUTOLOAD method, which accepts C<chunk> as a recursive method, and calls it on
each of the items in A1. These are all A2s, so the same thing happens in A2 if
A2 also does not implement a C<chunk> method. The method is then passed onto each
A3 object in each A2 in A1's list.

If A3 implements C<chunk>, then it is called on A3. If it doesn't, it is called
on A3 using AUTOLOAD, which fizzles with a warning as the recursive call checks that
objects C<can> the method before calling. For this reason, make sure that any
recursive call you make is actually implemented on one of the nested arrays, or
the recursion will be B<a very processor comsuming nothing>.

For inheriting classes, it is possible to implement a method and still not break
the recursion - just C<use NEXT;> end the method implementation with a call
to C<$self->NEXT::METHODNAME(@_);> (this is untested and may contain a bug but
works in principle).

=head2 PRINTING/SAVING

=head2 DESTRUCTION

=head1 EXPORTS

Nothing.

=head1 TODO

=head1 BUGS

=over

=item B<Out of bounds assignment and access> - we need to check what happens if a
caller tries to access items that are out of bounds, especially with peek.

=back

=head1 AUTHOR

Jens Edlund (edlund@speech.kth.se>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 Jens Edlund

This is part of a open source repo at L<https://github.com/sprakbankental/mtmpreproc> under the same license as the rest of that repo.

=head1 SEE ALSO


=cut


