package Test::MTM::Analysis::PhoneNumber;

use Test::More;
use Test::Class;
use Data::Dumper;

use parent 'Test::MTM::Analysis';

require MTM::TTSChunk;

sub class {'MTM::Analysis::PhoneNumber'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_analysis('PhoneNumber');
}


sub markup : Test(61) {
	my $test = shift;

	# TODO country number marker
	#$test->chunk_assert('tel +46 77 7777777', 0, 'PHONE', '+', '77', ' ', '7777777');


	$test->chunk_assert('0', 'PHONE', 0);
	$test->chunk_assert('telefon 0-0 0', 'PHONE', 2,
						{orth => '0', pos => 'RG'},
						{orth => '-', pos => 'DL'},
						{orth => '0', pos => 'RG'},
						{orth => ' ', pos => 'DEL'},
						{orth => '0', pos => 'RG'});

	$test->chunk_assert('Tel. 08-444 44 44', 'PHONE', 2,
						{orth => '08', pos => 'RG'},
						{orth => '-', pos => 'DL'},
						{orth => '444', pos => 'RG'},
						{orth => ' ', pos => 'DEL'},
						{orth => '44', pos => 'RG'},
						{orth => ' ', pos => 'DEL'},
						{orth => '44', pos => 'RG'});

	# TODO wierd telephone word?
	$test->chunk_assert('textorderfaxnummer 08-444 44 44', 'PHONE', 2,
						{orth => '08', pos => 'RG'},
						{orth => '-',  pos => 'DL'},
						{orth => '444', pos => 'RG'},
						{orth => ' ', pos => 'DEL'},
						{orth => '44', pos => 'RG'},
						{orth => ' ', pos => 'DEL'},
						{orth => '44', pos => 'RG'});

}

1;

