package Test::MTM::Analysis::Filename;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::Filename'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('Filename');
}

sub markup : Tests(13) {
	my $test = shift;

	$test->chunk_assert('A:/boot/vmlinuz', 'FILENAME', 0, 'A', ':', '/', 'boot', '/', 'vmlinuz');

	# TODO Non-Windows filenames
	#$test->chunk_assert('/boot/vmlinuz', 'FILENAME', 0, 'A', ':', '/', '/', 'boot', '/', 'vmlinuz');
	# TODO Filename as URL
	#$test->chunk_assert('file:///boot/vmlinuz', 'FILENAME', 0, '/', 'boot', '/', 'vmlinuz');
}
