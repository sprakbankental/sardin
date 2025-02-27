package Test::MTM::Tie::CursorArray; # Testing MTM package
#***************************************************************************#
#
# MTM::Tie::CursorArray class tests
#
# MTM::Tie::CursorArray is the base class of several tied arrays used in the
# MTM preprocessing codebase. We use this test class as a template for the
# other class tests in the repo, so keep it up-to-date and well maintained.
#
# The class tests mostly follow the guidelines presented in Ovid's series
# of five article in Modern Perl Programming:
# http://www.modernperlbooks.com/mt/2009/03/reusing-test-code-with-testclass.html
#
#***************************************************************************#
use v5.32;                    # We assume pragmas and such from 5.32.0
use Test::More;               # Explicitly load modules - no Test::Most
use parent qw(ClassTestBase); # Local class which inherits from Test::Class

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;
# END SBTal boilerplate

##### (TODO) Check how to solve this.
# We can't use this setup for tests that require direct access to the tied array,
# such as the POPULATION tests. So they simply ignore these objects for now and
# tie their own arrays. The do use the seed list for an initial list though.
sub setup : Tests(setup) {
	my $test        = shift;
	my $class       = $test->class;
	my @a           = ();
	$test->{obj}    = tie(@a, $class);
	$test->{seed}   = [qw( a b c )];
	@a              = @{ $test->{seed} };
}

# These code blocks (CONSTRUCTION, etc.) currently have no real functional
# purpose, but only serve to create hunks that map to the code in the class
# implementation
CONSTRUCTION: {
	sub TIEARRAY : Tests(3) {
		my $test  = shift;
		my $class = $test->class;
		diag "Running constructor tests on $class";
		can_ok $class, 'TIEARRAY';
		ok my $arrayobject = tie(my @a, $class),
			'... and the constructor succeeded';
		isa_ok $arrayobject, $class, '... and the object it returns';
	}
}

CONFIGURATION: {
	sub config : Tests(0) {
		diag "No config tests available";
	}
}

POPULATION: {
	# We can't use the "setup" here, as we need direct access to the
	# tied array variable
	sub STORE : Tests(4) {
		my $test  = shift;
		my $class = $test->class;
		my @a     = ();
		my $o     = tie(@a, $class); # Can't use 'setup' here
		can_ok $class, 'STORE';
		can_ok $o, 'STORE';
		# This test uses knowledge about the internal storage of these
		# tied arrays, but it's the only way we can make the comparison
		# since the array is "locked" (see LOCKING below)
		my @b = qw( a b c );
		@a = @b;
		is_deeply($o->{ARRAY}, \@b);
		$a[0] = $b[0] = 'd';
		is_deeply($o->{ARRAY}, \@b);
	}
	sub PUSH : Tests(4) {
		my $test  = shift;
		my $class = $test->class;
		my @a     = ();
		my $o     = tie(@a, $class); # Can't use 'setup' here
		can_ok $class, 'PUSH';
		can_ok $o, 'PUSH';
		my @b = qw( a b c );
		foreach my $v (@b) { push @a, $v }
		# This test uses knowledge about the internal storage of these
		# tied arrays, but it's the only way we can make the comparison
		# since the array is "locked" (see LOCKING below)
		is_deeply($o->{ARRAY}, \@b);
		push @a, 1;
		push @b, 1;
		is_deeply($o->{ARRAY}, \@b);
	}
	##### (TODO) Add the remaining POPULATION methods here!
}
LOCKING: {
	sub lock : Tests(3) {
		my $test  = shift;
		my $class = $test->class;
		my $o = $test->{obj};
		can_ok $o, 'lock';
		ok $o->lock,
			'...and locking returns ok.';
		$TODO = 'Test that return value is the correct object is not in place';
		fail;
		undef($TODO);
	}
	sub unlock : Tests(3) {
		my $test  = shift;
		my $class = $test->class;
		my $o = $test->{obj};
		can_ok $o, 'unlock';
		ok $o->unlock,
			'..and unlocking returns ok.';
		$TODO = 'Test that return value is the correct object is not in place';
		fail;
		undef($TODO);
	}
	sub locked : Tests(4) {
		my $test  = shift;
		my $class = $test->class;
		my $o = $test->{obj};
		can_ok $o, 'locked';
		is $o->locked, 0,
			'...and a fresh object is unlocked (locked returns 0)...';
		is $o->lock->locked, 1,
			'...we can lock it so locked returns 1...';
		is $o->unlock->locked, 0,
			'...and unlock it again so locked returns 0.';
	}
	sub lock_resets_cursor : Tests(1) {
		##### (TODO) Check that locking resets cursor
		$TODO = 'Testing if locking resets cursor is not in place';
		fail;
		undef($TODO);
	}
	sub unlock_resets_cursor : Tests(1) {
		$TODO = 'Testing if unlocking resets cursor is not in place';
		fail;
		undef($TODO);
	}
}
PROCESS: {
	sub FETCH : Tests(5) {
		my $test  = shift;
		my $class = $test->class;
		my @a     = ();
		my $o     = tie(@a, $class); # Can't use 'setup' here
		my @b     = @{ $test->{seed} };
		@a        = @b;
		my $i     = 1;
		can_ok $o, 'FETCH';
		is $o->FETCH($i), $b[$i],
			'...FETCH gets the right thing...';
		is $a[$i], $b[$i],
			'..and accessing through index gets the right thing...';
		my @c;
		foreach my $v (@a) { push @c, $v }
		is_deeply \@c, \@b,
			'..as does accessing through foreach loop...';
		is_deeply \@a, \@b,
			'..and accessing the whole array.';
	}
	sub cursor : Tests(3) {
		my $test  = shift;
		my $class = $test->class;
		my @a     = ();
		my $o     = tie(@a, $class); # Can't use 'setup' here
		my @b     = @{ $test->{seed} };
		@a        = @b;
		can_ok $o, 'cursor';
		is $o->cursor, 0,
			'...and the cursor initiates at 0...';
		# Access element $i should set cursor to $identical
		my $i = 1;
		my $dummy = $a[$i];
		is $o->cursor, 1,
			'...and accessing items sets the cursor as it should.';

	}
	sub current : Tests(3) {
		my $test  = shift;
		my $class = $test->class;
		my @a     = ();
		my $o     = tie(@a, $class); # Can't use 'setup' here
		my @b     = @{ $test->{seed} };
		@a        = @b;
		can_ok $o, 'current';
		is $o->current, $b[0],
			'...and it returns the first list item initially...';
		# Access element $i should set cursor to $identical
		my $i = 1;
		my $dummy = $a[$i];
		is $o->current, $b[1],
			'...and the last accessed item when the array has been used.';
	}
	sub move : Tests(3) {
		my $test  = shift;
		my $class = $test->class;
		my $o = $test->{obj};
		can_ok $o, 'move';
		is $o->move(2)->cursor, 2,
			'...and moving forward works';
		is $o->move(-1)->cursor, 1,
			'...as does moving backwards.';
	}
	sub peek : Tests(9) {
		my $test  = shift;
		my $class = $test->class;
		my $o = $test->{obj};
		my @b     = @{ $test->{seed} };
		can_ok $o, 'peek';
		is $o->peek(2), $b[2],
			'...and peeking forward works...';
		is $o->cursor, 0,
			'...without moving the cursor...';
		is $o->move(2)->peek(-2), $b[0],
			'...as does peeking backwards...';
		is $o->cursor, 2,
			'...which also leaves the cursor intact.';
		# Check that out of bounds requests work as expected
		is $o->peek(1), undef,
			'Out of bound at right edge returns undef...';
		is $o->cursor, 2,
			'...and leaves the cursor intact...';
		is $o->peek(-3), undef,
			'as does out of bound at left edge...';
		is $o->cursor, 2,
			'...which also leaves the cursor intact.';
	}
	sub traversal : Tests(6) {
		# This sub tests the recommended method to loop through
		# an object inheriting this class
		my $test  = shift;
		my $class = $test->class;
		my $o = $test->{obj};
		my @b     = @{ $test->{seed} };
		$o->move(2); # Set the cursor to non-zero
		my $i = 0;
		for ($o->reset; my $val = $o->current; $o->move(1)) {
			is $o->cursor, $i,
				"A for-loop counts up properly ($i)...";
			is $val, $b[$i],
				"...and returns the right things ($val).";
			$i++;
		}
	}
}
##### (TODO)
# - The progerssion through an object - creation, config, population,
#   locking, processing, saving and destroying as a single sweep
# - Error handling - but we don't test that because it's not designed
#   yet. NB! should do that design test-first.
# - Failed calls - we have no calls that are supposed to fail, but should
#   have. See error handling above.
# - Autoloaded methods (mostly process)
# - Printing/saving
# - Destruction
# - Stdandard aray behaviours - some of them are in the code below __END__
#   in sloppy versions.

1;

__END__



sub std_array_behaviours : Tests(5) {
	my $test  = shift;
	my $class = $test->class;
	my @tiedarray;
	tie(@tiedarray, $class);
	my @stdarray;

	# We need all standard behaviours of the tied array to be
	# identical to those of a standard array
	##### (TODO) Fix this to peoperly reset arrays between tests
	@tiedarray = @stdarray = (1,2,3);
	is_deeply(\@tiedarray, \@stdarray, "Simple assignment");
	push(@tiedarray, 4);
	push(@stdarray, 4);
	is_deeply(\@tiedarray, \@stdarray, "Push");
	unshift(@tiedarray, 0);
	unshift(@stdarray, 0);
	is_deeply(\@tiedarray, \@stdarray, "Unshift");
	pop(@tiedarray);
	pop(@stdarray);
	is_deeply(\@tiedarray, \@stdarray, "Pop");
	shift(@tiedarray);
	shift(@stdarray);
	is_deeply(\@tiedarray, \@stdarray, "Shift");
	##### (TODO) Add tests here to cover all builtin functions
	##### (TODO) Extend to cover all cases
}

sub autoloaded : Tests(5) {
	my $test  = shift;
	my $class = $test->class;
	my $aobj = tie(my @a, $class);

	my @methods = qw(
		normalise
		chunk
		tokenise
		pos_tag
		print_tokens
	);
	foreach $m (@methods) {
		can_ok $class, $m;
	}
}

sub unimplemented : Tests(5) {
	my $test  = shift;
	my $class = $test->class;
	my $aobj = tie(my @a, $class);

	my @methods = qw(
		reset
		cursor
		peek
	);
	foreach $m (@methods) {
		can_ok $class, $m;
	}
}

sub cursor_behaviours : Tests(9) {
	my $test  = shift;
	my $class = $test->class;
	my @tied;
	my $aobj = tie(@tied, $class);
	@tied = ('a','b','c');
	is $aobj->cursor, -1,
		'Uninitiated cursor (-1)';
	$aobj->move;
	is $aobj->cursor, 0,
		'Cursor moves and initiates and...';
	is $aobj->current, 'a',
		'...current picks the right thing and...';
	is $aobj->context(2), 'c',
		'...context can pick several steps out and ...';
	$aobj->move;
	is $aobj->cursor, 1,
		'...cursor can move more than once and...';
	is $aobj->current, 'b',
		'...current still picks the right thing...';
	is $aobj->context(-1), 'a',
		'...as does context...';
	is $aobj->context(1), 'c',
		'...in both directions and...';
	is $aobj->reset_cursor->cursor, -1,
		'...reset cursor resets the cursor.';
}


1;



