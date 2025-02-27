package Test::MTM::TPBTag;

use Test::More;

use Test::More;
use Test::Class;
use parent 'ClassTestBase';

sub class {'MTM::TPBTag'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
}

sub is_numeral : Tests(13) {
	my $test  = shift;
	my $class = $test->class;

	##### CT 210701
	# Do not perform these tests, the rule is just a stand-in for the real tagger.


#        ok(&{"${class}::is_numeral"}("1"), "'1' is numeral");
#        ok(&{"${class}::is_numeral"}("11"), "'11' is numeral");
#        ok(&{"${class}::is_numeral"}("11,1"), "'11,1' is numeral");
#        ok(&{"${class}::is_numeral"}("11.1"), "'11.1' is numeral");
#        ok(&{"${class}::is_numeral"}(".1"), "'.1' is numeral");
#        ok(&{"${class}::is_numeral"}("0123456789"), "'0123456789' is numeral");
#        ok(!&{"${class}::is_numeral"}(''), "'' is not numeral");
#        ok(!&{"${class}::is_numeral"}("i"), "'i' is not numeral");
#        ok(!&{"${class}::is_numeral"}("1a"), "'1a' is not numeral");
#        ok(&{"${class}::is_numeral"}("."), "'.' is not numeral");
#        ok(&{"${class}::is_numeral"}(","), "',' is not numeral");
#        ok(&{"${class}::is_numeral"}(".."), "'..' is not numeral");
#        ok(&{"${class}::is_numeral"}(",,"), "',,' is not numeral");
}


1;
