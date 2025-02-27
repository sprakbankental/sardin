#!/usr/bin/perl -w

# Comment this out to get TODO comments in the output
# use Smart::Comments qw(#####);


# There's a bunch of flags used in the original MTM codebase
# that are now available through specific 'legacy' methods
# on all MTM objects. This code simply tests for these.

use Test::More tests => 60;

use MTM::TTSPreprocessor;
use MTM::TTSDocument;
use MTM::TTSChunk;
use MTM::TTSToken;

my @objects = (
	MTM::TTSPreprocessor->new,
	MTM::TTSDocument->new,
	MTM::TTSChunk->new,
	MTM::TTSToken->new,
);

my %defaults = (
		debug 			=> 1,
		insert_rate		=> 0,
		tts				=> 'mtm',
		runmode			=> 'normal',
		docontextcheck	=> 0,
);

foreach my $obj (@objects) {
	foreach my $key (sort keys %defaults) {
		is $obj->get_legacy($key), $defaults{$key}, 
			"Legacy default for $key";
	} 
}

my %changed = (
		debug 			=> 2,
		insert_rate		=> 1,
		tts				=> 'ptb',
		runmode			=> 'abnormal',
		docontextcheck	=> 1,
);

foreach my $obj (@objects) {
	foreach my $key (sort keys %changed) {
		is $obj->set_legacy($key,$changed{$key}), $changed{$key}, 
			"Legacy set key $key";
	} 
}

foreach my $obj (@objects) {
	foreach my $key (sort keys %changed) {
		is $obj->get_legacy($key), $changed{$key}, 
			"Legacy get key $key";
	} 
}

##### (TODO) Should add a few tests of attempts to setget bad keys
##### (TODO) This should result in undef return and no change in the object

