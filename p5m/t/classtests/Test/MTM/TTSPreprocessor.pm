package Test::MTM::TTSPreprocessor;

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

# POD documentation after __END__ below.
#
# ****************************************************************************#
#
# Trace printouts
#
# This is _only_ used under active development, and coded out manually
# at release time.
# Uncomment the next line for development trace printouts
# use Smart::Comments '###', '####', '#####';
# use Smart::Comments '###';
#*****************************************************************************#
#
# Test::MTM::TTSPreprocessor - Perl data object holding settings for TTS
# preprocessing as well as an array of TTS documents to be processed
#
# This is implemented as a tied array holding the documents
# non-coders.
#
# Extra methods:
# $arrayref->current;     # returns the current cursor's position in the array
# $arrayref->next;        # moves cursor one step to the right
# $arrayref->cursor;      # returns the object at the current cursor
# $arrayref->context($n); # returns the object $n steps away from the cursor
# $arrayref->class;		  # returns this class name (Test::MTM::TTSPreprocessor)
#
# ****************************************************************************#


#*****************************************************************************#
#
# Methods and Document management methods
#
#
##### (TODO) We want to support a wide range of documents loading methods here
#
# These are only methods specific to this class. Inhereted methods are
# tested automatically as we inherit these tests above.

# Test if we can open all methods used by this class
sub methods : Tests(1) {
	my $test  = shift; 					# The preprocessor object
	my $class = $test->class;
	my $aobj = tie(my @a, $class);

	my @methods = qw(read_document_from_handle);
	foreach my $m (@methods) {
		can_ok $class, $m;
	}
}

# Test if we can open all documents used by this class
sub read_documents : Tests() {
	my $test  = shift;					# The preprocessor object
	my $class = $test->class;
	my $aobj = tie(my @a, $class);
	$aobj->read_document_from_handle(\*DATA);

}

1;

__DATA__
foo bar. foo beer
foo bear

__END__

