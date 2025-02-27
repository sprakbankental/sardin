package Test::MTM::Expansion::NumeralExpansion;

use Test::More;
use Test::Class;
use Data::Dumper;

use utf8;

use parent 'Test::MTM::Expansion';

require MTM::TTSChunk;

sub class {'MTM::Expansion::NumeralExpansion'}

sub startup : Tests(startup) {
	my $test  = shift;
	my $class = $test->class;
	eval "use $class";
	die $@ if $@;
	$test->set_expansion('NumeralExpansion');
}

sub expand : Tests(335) {
	my $test = shift;

	#*******************************************************************************************************#
	# Cardinals

	# 0-9
	$test->chunk_assert('0', 'noll', 0, {orth => '0', pos => 'RG'} );
	$test->chunk_assert('1', 'ett', 0, {orth => '1', pos => 'RG'} );
	$test->chunk_assert('9', 'nio', 0, {orth => '9', pos => 'RG'} );

	# 10-19
	$test->chunk_assert('10', 'tio', 0, {orth => '10', pos => 'RG'} );
	$test->chunk_assert('19', 'nitton', 0, {orth => '19', pos => 'RG'} );

	# 20-99
	$test->chunk_assert('20', 'tjugo', 0, {orth => '20', pos => 'RG'} );
	$test->chunk_assert('99', 'nittionio', 0, {orth => '99', pos => 'RG'} );

	# 100-999
	$test->chunk_assert('100', 'ett|hundra', 0, {orth => '100', pos => 'RG'} );
	$test->chunk_assert('505', 'fem|hundra|fem', 0, {orth => '505', pos => 'RG'} );
	$test->chunk_assert('999', 'nio|hundra|nittionio', 0, {orth => '999', pos => 'RG'} );

	# 1 000-9 999
	$test->chunk_assert('1000', 'ett|tusen', 0, {orth => '1000', pos => 'RG'} );;
	$test->chunk_assert('9999', 'nio|tusen|nio|hundra|nittionio', 0, {orth => '9999', pos => 'RG'} );;
	$test->chunk_assert('1 000', 'ett|tusen', 0, {orth => '1 000', pos => 'RG'} );
	$test->chunk_assert('9 999', 'nio|tusen|nio|hundra|nittionio', 0, {orth => '9 999', pos => 'RG'} );

	# 10 000-99 999
	$test->chunk_assert('10000', 'tio|tusen', 0, {orth => '10000', pos => 'RG'} );;
	$test->chunk_assert('99999', 'nittionio|tusen|nio|hundra|nittionio', 0, {orth => '99999', pos => 'RG'} );
	$test->chunk_assert('10 000', 'tio|tusen', 0, {orth => '10 000', pos => 'RG'} );;
	$test->chunk_assert('99 999', 'nittionio|tusen|nio|hundra|nittionio', 0, {orth => '99 999', pos => 'RG'} );

	# 100 000-999 999
	$test->chunk_assert('100000', 'ett|hundra|tusen', 0, {orth => '100000', pos => 'RG'} );
	$test->chunk_assert('999999', 'nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '999999', pos => 'RG'} );
	$test->chunk_assert('100 000', 'ett|hundra|tusen', 0, {orth => '100 000', pos => 'RG'} );
	$test->chunk_assert('999 999', 'nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '999 999', pos => 'RG'} );

	# 1 000 000-9 999 999
	$test->chunk_assert('1000000', 'en|miljon', 0, {orth => '1000000', pos => 'RG'} );
	$test->chunk_assert('9999999', 'nio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '9999999', pos => 'RG'} );
	$test->chunk_assert('1 000 000', 'en|miljon', 0, {orth => '1 000 000', pos => 'RG'} );
	$test->chunk_assert('9 999 999', 'nio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '9 999 999', pos => 'RG'} );

	# 10 000 000-99 999 999
	$test->chunk_assert('10000000', 'tio|miljoner', 0, {orth => '10000000', pos => 'RG'} );
	$test->chunk_assert('99999999', 'nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '99999999', pos => 'RG'} );
	$test->chunk_assert('10 000 000', 'tio|miljoner', 0, {orth => '10 000 000', pos => 'RG'} );
	$test->chunk_assert('99 999 999', 'nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '99 999 999', pos => 'RG'} );

	# 100 000 000-999 999 999
	$test->chunk_assert('100000000', 'ett|hundra|miljoner', 0, {orth => '100000000', pos => 'RG'} );
	$test->chunk_assert('999999999', 'nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '999999999', pos => 'RG'} );
	$test->chunk_assert('100 000 000', 'ett|hundra|miljoner', 0, {orth => '100 000 000', pos => 'RG'} );
	$test->chunk_assert('999 999 999', 'nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '999 999 999', pos => 'RG'} );

	# 1 000 000 000-9 999 999 999
	$test->chunk_assert('1000000000', 'en|miljard', 0, {orth => '1000000000', pos => 'RG'} );
	$test->chunk_assert('9999999999', 'nio|miljarder|nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '9999999999', pos => 'RG'} );
	$test->chunk_assert('1 000 000 000', 'en|miljard', 0, {orth => '1 000 000 000', pos => 'RG'} );
	$test->chunk_assert('9 999 999 999', 'nio|miljarder|nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '9 999 999 999', pos => 'RG'} );

	# 10 000 000 000-99 999 999 999
	$test->chunk_assert('10000000000', 'tio|miljarder', 0, {orth => '10000000000', pos => 'RG'} );
	$test->chunk_assert('99999999999', 'nittionio|miljarder|nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '99999999999', pos => 'RG'} );
	$test->chunk_assert('10 000 000 000', 'tio|miljarder', 0, {orth => '10 000 000 000', pos => 'RG'} );
	$test->chunk_assert('99 999 999 999', 'nittionio|miljarder|nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '99 999 999 999', pos => 'RG'} );

	# 100 000 000 000-999999999999
	$test->chunk_assert('100000000000', 'ett|hundra|miljarder', 0, {orth => '100000000000', pos => 'RG'} );
	$test->chunk_assert('999999999999', 'nio|hundra|nittionio|miljarder|nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '999999999999', pos => 'RG'} );;
	$test->chunk_assert('100 000 000 000', 'ett|hundra|miljarder', 0, {orth => '100 000 000 000', pos => 'RG'} );;
	$test->chunk_assert('999 999 999 999', 'nio|hundra|nittionio|miljarder|nio|hundra|nittionio|miljoner|nio|hundra|nittionio|tusen|nio|hundra|nittionio', 0, {orth => '999 999 999 999', pos => 'RG'} );

	#*******************************************************************************************************#
	# Ordinals
	$test->chunk_assert('1:a', 'första', 0, {orth => '1:a', pos => 'RO'} );
	$test->chunk_assert('1:e', 'förste', 0, {orth => '1:e', pos => 'RO'} );
	$test->chunk_assert('2:a', 'andra', 0, {orth => '2:a', pos => 'RO'} );
	$test->chunk_assert('2:e', 'andre', 0, {orth => '2:e', pos => 'RO'} );
	$test->chunk_assert('3:e', 'tredje', 0, {orth => '3:e', pos => 'RO'} );
	$test->chunk_assert('4:e', 'fjärde', 0, {orth => '4:e', pos => 'RO'} );
	$test->chunk_assert('5:e', 'femte', 0, {orth => '5:e', pos => 'RO'} );
	$test->chunk_assert('6:e', 'sjätte', 0, {orth => '6:e', pos => 'RO'} );
	$test->chunk_assert('7:e', 'sjunde', 0, {orth => '7:e', pos => 'RO'} );
	$test->chunk_assert('8:e', 'åttonde', 0, {orth => '8:e', pos => 'RO'} );
	$test->chunk_assert('9:e', 'nionde', 0, {orth => '9:e', pos => 'RO'} );
	$test->chunk_assert('10:e', 'tionde', 0, {orth => '10:e', pos => 'RO'} );
	$test->chunk_assert('11:e', 'elfte', 0, {orth => '11:e', pos => 'RO'} );
	$test->chunk_assert('12:e', 'tolfte', 0, {orth => '12:e', pos => 'RO'} );
	$test->chunk_assert('13:e', 'trettonde', 0, {orth => '13:e', pos => 'RO'} );
	$test->chunk_assert('14:e', 'fjortonde', 0, {orth => '14:e', pos => 'RO'} );
	$test->chunk_assert('15:e', 'femtonde', 0, {orth => '15:e', pos => 'RO'} );
	$test->chunk_assert('16:e', 'sextonde', 0, {orth => '16:e', pos => 'RO'} );
	$test->chunk_assert('17:e', 'sjuttonde', 0, {orth => '17:e', pos => 'RO'} );
	$test->chunk_assert('18:e', 'artonde', 0, {orth => '18:e', pos => 'RO'} );
	$test->chunk_assert('19:e', 'nittonde', 0, {orth => '19:e', pos => 'RO'} );
	$test->chunk_assert('20:e', 'tjugonde', 0, {orth => '20:e', pos => 'RO'} );
	$test->chunk_assert('21:a', 'tjugoförsta', 0, {orth => '21:a', pos => 'RO'} );
	$test->chunk_assert('32:a', 'trettioandra', 0, {orth => '32:a', pos => 'RO'} );
	$test->chunk_assert('43:e', 'fyrtiotredje', 0, {orth => '43:e', pos => 'RO'} );
	$test->chunk_assert('54:e', 'femtiofjärde', 0, {orth => '54:e', pos => 'RO'} );
	$test->chunk_assert('65:e', 'sextiofemte', 0, {orth => '65:e', pos => 'RO'} );
	$test->chunk_assert('76:e', 'sjuttiosjätte', 0, {orth => '76:e', pos => 'RO'} );
	$test->chunk_assert('87:e', 'åttiosjunde', 0, {orth => '87:e', pos => 'RO'} );
	$test->chunk_assert('98:e', 'nittioåttonde', 0, {orth => '98:e', pos => 'RO'} );
	$test->chunk_assert('1000:e', 'ett|tusende', 0, {orth => '1000:e', pos => 'RO'} );
	$test->chunk_assert('10 000:e', 'tio|tusende', 0, {orth => '10 000:e', pos => 'RO'} );
	$test->chunk_assert('100000:e', 'ett|hundra|tusende', 0, {orth => '100000:e', pos => 'RO' } );
	$test->chunk_assert('1 000 000:e', 'miljonte', 0, {orth => '1 000 000:e', pos => 'RO' } );
	$test->chunk_assert('109:e', 'ett|hundra|nionde', 0, {orth => '109:e', pos => 'RO' } );
	$test->chunk_assert('1111:e', 'ett|tusen|ett|hundra|elfte', {orth => '1111:e', pos => 'RO' } );

	$test->chunk_assert('28.06.2013', 'sjätte', 2, {orth => '06', pos => 'RO' } );


	#*******************************************************************************************************#
	# Spell
	$test->chunk_assert('0580', 'noll|fem|åtta|noll', 0, '0580');
	$test->chunk_assert('http://test_is56789.com', 'fem|sex|sju|åtta|nio', 7, '56789');


	#*******************************************************************************************************#
}

 