package Test::MTM::Analysis::URL;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::URL'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('URL');
}

sub markup : Tests(66) {
	my $test = shift;

	$test->chunk_assert('www.tpb.se', 'URL', 0, 'www', '.', 'tpb', '.', 'se');
	$test->chunk_assert('https://php.net', 'URL', 0, 'https', ':', '/', '/', 'php', '.', 'net');
	$test->chunk_assert('http://gnuheter.org', 'URL', 0, 'http', ':', '/', '/', 'gnuheter', '.', 'org');

	$test->chunk_assert('php.net', 'URL', 0,  'php', '.', 'net');
	$test->chunk_assert('gnuheter.org', 'URL', 0, 'gnuheter', '.', 'org');
	$test->chunk_assert('yomiuri.co.jp', 'URL', 0, 'yomiuri', '.', 'co', '.', 'jp');
}
