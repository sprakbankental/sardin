package Test::MTM::TTSNodeFactory; 

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
sub methods : Tests(8) {
	my $test  = shift; 					# The preprocessor object
	my $class = $test->class;
	my @methods = qw(
		newpreprocessor preprocessors_since_boot
   newdocument documents_since_boot
   newchunk chunks_since_boot
		newtoken tokens_since_boot
	);
	foreach my $m (@methods) {
		can_ok $class, $m;
	}
}

# The test repåetition below is kind of annoying and
# should probably be fixed in a more compact manner
sub preprocessorfactory : Tests(6) { 
   my $test = shift;
   my $factory = $test->class->new;

   my $prep = $factory->newpreprocessor;

   isa_ok $prep, 'MTM::TTSPreprocessor', 'newpreprocessor returns a preprocessor';
   is ($prep->{index}, 1, '... and first preprocessor has index 1 ...');
   $prep = $factory->newpreprocessor;
   is ($prep->{index}, 2, '... the second has index 2');

   is ($test->class->preprocessors_since_boot, 2, '... and we keep track of preprocessors since boot ... ');
   my $factory2 = $test->class->new;
   $prep = $factory2->newpreprocessor;
	$TODO = 'Object scoped counter not implemented';
   is ($prep->{index}, 1, '... and the first preprocessor in a new factory has index 1 ...');
	undef $TODO;
   is ($test->class->preprocessors_since_boot, 3, '... while the total count increases. ');

}
sub documentfactory : Tests(6) {
   my $test = shift;
   my $factory = $test->class->new;

   my $doc = $factory->newdocument;

   isa_ok $doc, 'MTM::TTSDocument', 'newdocument returns a document';
   is ($doc->{index}, 1, '... and first document has index 1 ...');
   $doc = $factory->newdocument;
   is ($doc->{index}, 2, '... the second has index 2');

   is ($test->class->documents_since_boot, 2, '... and we keep track of documents since boot ... ');
   my $factory2 = $test->class->new;
   $doc = $factory2->newdocument;
	$TODO = 'Object scoped counter not implemented';
   is ($doc->{index}, 1, '... and the first document in a new factory has index 1 ...');
   is ($test->class->documents_since_boot, 3, '... while the total count increases. ');

}

sub chunkfactory : Tests(6) {
   my $test = shift;
   my $factory = $test->class->new;

   my $chunk = $factory->newchunk;

   isa_ok $chunk, 'MTM::TTSChunk', 'newchunk returns a chunk';
 	$TODO = 'Counter tests do not reset, and object scoped counters aren not implemented';
   is ($chunk->{index}, 1, '... and first chunk has index 1 ...');
   $chunk = $factory->newchunk;
   is ($chunk->{index}, 2, '... the second has index 2');

   is ($test->class->chunks_since_boot, 2, '... and we keep track of chunks since boot ... ');
   my $factory2 = $test->class->new;
   $chunk = $factory2->newchunk;
   is ($chunk->{index}, 1, '... and the first chunk in a new factory has index 1 ...');
   is ($test->class->chunks_since_boot, 3, '... while the total count increases. ');

}

sub tokenfactory : Tests(6) {
   my $test = shift;
   my $factory = $test->class->new;

   my $token = $factory->newtoken;

   isa_ok $token, 'MTM::TTSToken', 'newtoken returns a token';
 	$TODO = 'Counter tests do not reset, and object scoped counters aren not implemented';
   is ($token->{index}, 1, '... and first token has index 1 ...');
   $token = $factory->newtoken;
   is ($token->{index}, 2, '... the second has index 2');

   is ($test->class->tokens_since_boot, 2, '... and we keep track of tokens since boot ... ');
   my $factory2 = $test->class->new;
   $token = $factory2->newtoken;
   is ($token->{index}, 1, '... and the first token in a new factory has index 1 ...');
   is ($test->class->tokens_since_boot, 3, '... while the total count increases. ');

}

1;

__DATA__
foo bar. foo beer
foo bear

__END__

