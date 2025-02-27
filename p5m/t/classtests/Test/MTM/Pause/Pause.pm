package Test::MTM::Pause::Pause;

# There's something very odd with the relationship of this and the
# Pause test one level above. We don't want to throw this away, but it
# needs to be called in a sensible manner.
# See issue 157

1;

__DATA__
use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Pause';

require MTM::TTSChunk;

sub class {'MTM::Pause'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Pause');
}

sub pause : Tests(23) {
	my $test = shift;

	$test->chunk_assert('Ett kommatecken, och (parenteser).', 'PAUSE', 0,
						{orth => 'Ett', pause => '-'},
						{orth => ' ', pause => '-'},
						{orth => 'kommatecken', pause => '-'},
						{orth => ',', pause => '150'},
						{orth => ' ', pause => '-'},
						{orth => 'och', pause => '-'},
						{orth => ' ', pause => '-'},
						{orth => '(', pause => '150'},
						{orth => 'parenteser', pause => '-'},
						{orth => ')', pause => '150'},
						{orth => '.', pause => '-'}
		);
}
