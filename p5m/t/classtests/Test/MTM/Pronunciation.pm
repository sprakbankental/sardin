package Test::MTM::Pronunciation;

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

# We do not need to load the module to be tested explicitly.
# If it is not the same as the current test package name minus the initial 'Test::',
# use the following form to provide the class name. It will then be loaded safely.
#sub class {'MTM::Pronunciation::Autopron'};
# If it is the same as the current package name minus the initial 'Test::', as it
# should be, it will be loaded safely automatically by our parent ClassTestBase
# ==============================================================================
#
# If this is needed by Autopron it should be loaded by Autopron (and it is now)
# use MTM::Case;

# This is legacy code, and not needed for loading modules, as this is dealt with by
# the parent class now. It can be used to set up module specific things, such as
# loading a module with non-default settings
#sub startup : Test(startup) {
#	my $test  = shift;
#	my $class = $test->class;
#	eval "use $class";
#	die $@ if $@;
#}
#**************************************************#
# Function	spell_all'
# Gets wide character	240512
#sub spell_all : Test(1) {
#	my $pron = &MTM::Pronunciation::Pronunciation::spell_all( 'mm–1μm' );
#	is( $pron, "\'e m \| \'e m \| \'e t \| m \'i: \| \'e m" ), 'spell_all pron mm–1μm: correct.'
#}
#**************************************************#
# Function	createCompoundPronunciation
sub createCompoundPronunciation : Test(4) {
	my $triplets = {
		general => [
			[
				'nasal+nasal',
				'n a . s "a: l - n a . s ,a: l',
				'compound numeral pron (nasal+nasal): correct.'
			],
			[
				'nasal+nasal+nasal',
				'n a . s "a: l - n a . s a: l - n a . s ,a: l',
				'compound numeral pron (nasal+nasal+nasal): correct.'
			],
		],
		initial => [
			[
				'1928+-+kvarleva',
				'n "i . t ,o n | h \'uu n . d r a | c uu: . g u ~ "o . t a - k v a: r - l ,e: . v a',
				'compound year pron (1928+-+kvarleva): correct.'
			],
			[
				'5+-+nasal',
				'f "e m - n a . s ,a: l',
				'compound initial numeral pron (5+-+nasal): correct.'
			],
			[
				'LO+-+nasal',
				'"ä l ~ u: - n a . s ,a: l',
				'compound initial acronym pron (LO+-+nasal): correct.'
			],
			[
				'δ+-+nasal',
				'd "e l . t a - n a . s ,a: l',
				'compound initial special pron (δ+-+nasal): correct.'
			],

			# TODO: change to 'tj "i: - t v å: - t ,e s t' when fixed.
			#[
			#	'χ2+-+test',
			#	't e s t',
			#	'compound initial special pron (χ2+-+test): correct.'
			#],
			[
				'LPPRT+-+nasal',
				'ä l ~ p e: ~ p e: ~ "ae r ~ t e: - n a . s ,a: l',
				'compound initial spell pron (LPPRT+-+nasal): correct.'
			],
			[
				'katt"+-+figur',
				'k "a t - f i . g ,uu: r',
				'compound initial spell pron (katt\"-figur): correct.'
			],
		],
		medial => [
			[
				'Bell+mans+eken',
				'b "e l - m a n s - ,e: . k ex n',
				'compound medial numeral pron (Bell+mans+eken): correct.'
			],
			[
				'nasal+-+5+-+nasal',
				'n a . s "a: l - f e m - n a . s ,a: l',
				'compound medial numeral pron (nasal+-+5+-+nasal): correct.'
			],
			[
				'nasal+-+ADHD+-+nasal',
				'n a . s "a: l - a: ~ d e: ~ h o: ~ d e: - n a . s ,a: l',
				'compound medial acronym pron (nasal+-+ADHD+-+nasal): correct.'
			],
			[
				'nasal+-+δ+-+nasal',
				'n a . s "a: l - d e l . t a - n a . s ,a: l',
				'compound medial special pron (nasal+-+δ+-+nasal): correct.'
			],
			[
				'nasal+-+LPPRT+-+nasal',
				'n a . s "a: l - ä l ~ p e: ~ p e: ~ ae r ~ t e: - n a . s ,a: l',
				'compound medial spell pron (nasal+-+LPPRT+-+nasal): correct.'
			],
			[
				'Barn+-+samhälle',
				'b "a: rn - s a m - h ,ä . l ex',
				'compound (Barn+-+samhälle): correct.'
			],
			[
				'intäktse+-+ring',
				'"i n . t e k t . s ex - r ,i ng',
				'compound (intäktse+-+ring): correct.'
			],
		],
		final => [
			[
				'nasal+-+5',
				'n a . s "a: l - f ,e m',
				'compound final numeral pron (nasal+-+5): correct.'
			],
			[
				'nasal+-+ADHD',
				'n a . s "a: l - a: ~ d e: ~ h ,o: ~ d e:',
				'compound final acronym pron (nasal+-+ADHD): correct.'
			],
			[
				'nasal+-+δ',
				'n a . s "a: l - d ,e l . t a',
				'compound final special pron (nasal+-+δ): correct.'
			],
			[
				'nasal+-+LPPRT',
				'n a . s "a: l - ä l ~ p e: ~ p e: ~ ,ae r ~ t e:',
				'compound final spell pron (nasal+-+LPPRT): correct.'
			],
		],
	};
	### TODO 210823	When autopron is up working.
	#$pron = &MTM::Pronunciation::Compound::createCompoundPronunciation( 'sprölk+nasal' );
	#is( $pron, "s p r \"ö l k - n a \$ s \,a: l", 'compound initial autopron pron (sprölk+-+nasal): correct.' );

	### TODO 210823	When autopron is up working.
	#$pron = &MTM::Pronunciation::Compound::createCompoundPronunciation( 'nasal+-+sprölk' );
	#is( $pron, "n a \$ s \"a: l - s p r \,ö l k", 'compound final autopron pron (nasal+-+sprölk): correct.' );

	### TODO 210823	When autopron is up working.
	#$pron = &MTM::Pronunciation::Compound::createCompoundPronunciation( 'nasal+-+sprölk+-+nasal' );
	#is( $pron, "n a \$ s \"a: l - s p r ö l k - n a \$ s \,a: l", 'compound medial autopron pron (nasal+-+sprölk+-+nasal): correct.' );
	foreach my $type (keys %$triplets) {
#		diag("createCompoundPronunciation ($type)");
		subtest "Test createCompoundPronunciation ($type)" => sub {
			# We know programatically here how many tests we run
			plan tests => $#{ $triplets->{$type} }+1;
			foreach my $triplet (@{ $triplets->{$type} }) {
				is(
					&MTM::Pronunciation::Compound::createCompoundPronunciation( $triplet->[0] ),
					$triplet->[1],
					$triplet->[2],		
				);
			}
		}
	}
}

#**************************************************#
# MODULE	MTM::Acronym.pm
sub acronym_pronounce : Test(1) {
	my $triplets = [
		[
			'AB',
			'"a: ~ b ,e:',
			'pronounce pron: correct.'
		],
		[
			'WZI',
			'd "uu . b ex l . v ,e: | s "ä: . t ,a | \'i:',
			'acronym pronounce pron (WZI): correct.'
		],
### 240512		[
#			'☒W',
#			'd "u . b ex l . v ,e:',
#			'acronym pronounce pron (☒W): correct.'
#		],
	];

	subtest "Test AcronymPronunciation::pronounce" => sub {
		# We know programatically here how many tests we run
		plan tests => $#{ $triplets }+1;
		foreach my $triplet (@$triplets) {
			is(
				&MTM::Pronunciation::AcronymPronunciation::pronounce( $triplet->[0] ),
				$triplet->[1],
				$triplet->[2],
			);
		}
	}
}

#**************************************************#
# MODULE	MTM::Pronunciation::Affixation.pm

# Function	affixation
sub affixation : Test(1) {
	my $quads = [
		[
			'nasal:j', 3,
			'void', 0,
		],
		[
			'jaxbru:s', 3,
			'void', 0,
		],
		[
			'jaxbru:s', 3,
			'void', 0,
		],
		[
			'ja:s', 3,
			'void', 0,
		],
		[
			'nasal:s', 3,
			'n a . s \'a: l s', 1,
		],
	];
	subtest "Test Affixation" => sub {
		# We know programatically here how many tests we run
		plan tests => ($#{ $quads }+1)*2;
		foreach my $quad (@$quads) {
			my ( $pron, $affixFlag, @rest ) = &MTM::Pronunciation::Affixation::affixation( $quad->[0], $quad->[1] );
			is(
				$pron, $quad->[2], "Affixation pron ($quad->[0], $quad->[1]): correct."
			);
			is(
				$affixFlag, $quad->[3], "Affixation affixFlag  ($quad->[0], $quad->[1]): correct."
			);
		}
	}
	#is( $pos, 'NN UTR SIN IND GEN', 'affixation pos (nasal:s, 3): correct.' );
	#is( $ortlang, 'swe', 'affixation ortlang (nasal:s, 3): correct.' );
	#is( $lang, 'swe', 'affixation lang (nasal:s, 3): correct.' );
	#is( $decomp, 'jaxbru:s', 'affixation decomp (nasal:s, 3): correct.' );
}

#**************************************************#
# MODULE	MTM::Pronunciation::Conversion.pm

#sub conversions : Test(2) {
#	subtest "General conversions" => sub {
#		plan tests => 26;
#		my $pron;
#
#		$pron = &MTM::Pronunciation::Conversion::convert( "sj ö \$ l \'e2: \$ n i3 \$ u s", 'PM NOM', 'tpa2mtm', 'sjölenius', 'sjölenius' );
#		is( $pron, "x ö \. l \'e: \. n ih \. uu s", 'convert pron (tpa2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä $ t ë - d `å2: $ l i $ a', 'JJ', 'tpa2mtm', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j "ä . t ex - d ,o: . l i . a', 'convert pron (tpa2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "e . t ex - d ,o: . l i . g a', 'JJ', 'mtm2acapela', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j E3 t @ d o:1 l I g a', 'convert pron (mtm2acapela): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "e . t ex - d ,o: . l i . g a', 'JJ', 'mtm2cp_swe', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j e3 t eh0 d oo2 l i0 g a0', 'convert pron (mtm2cp_swe): correct.' );
#
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä $ t ë - d `å2: $ l i $ a', 'JJ', 'tpa2sampa', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j ""E . t @ - d %o: . l I . a', 'convert pron (tpa2sampa): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j ""E . t @ - d %o: . l I . g a', 'JJ', 'sampa2acapela', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j E3 t @ d o:1 l I g a', 'convert pron (sampa2acapela): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä $ t ë - d `å2: $ l i $ a', 'JJ', 'tpa2acapela', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j E3 t @ d o:1 l I g a', 'convert pron (tpa2acapela): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 't r "a p `a', 'NN', 'tpa2acapela', 'trappa', 'trappa' );
#		is( $pron, 't_h r a3 p a', 'convert pron (tpa2acapela): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä $ t ë - d `å2: $ l i . a', 'JJ', 'tpa2cp', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j e3 t eh0 d oo2 l i0 g a0', 'convert pron (tpa2cp): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä $ t ë - d `å2: $ l i $ g a', 'JJ', 'tpa2cp_eng', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'y e1 t @0 d oo2 l i0 g uh0', 'convert pron (tpa2cp_eng): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j e3 t eh0 d oo2 l i0 g a0', 'JJ', 'cp2tpa', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j "e . t ë . d `å2: . l i . g a', 'convert pron (cp2tpa): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'p u0 $ r oox4 s', 'JJ', 'cp2tpa', 'porös', 'porös' );
#		is( $pron, "p o \$ r \'ö2: s", 'convert pron (cp2tpa): correct.' );
#
##		$pron = &MTM::Pronunciation::Conversion::convert( 'm u0 r ee4 ux0 s', 'JJ', 'cp2tpa', 'porös', 'porös' );
##		is( $pron, "m o \$ r \'e2: \$ u s", 'convert pron (cp2tpa): correct.' );
#
##		$pron = &MTM::Pronunciation::Conversion::convert( 'b ux0 $ t ii3 k s - x y2 l t', 'NN', 'cp2tpa', 'butiksskylt', 'butiks+skylt' );
##		is( $pron, "b u3 \$ t \"i2: k s - sj \`y l t", 'convert pron (cp2tpa): correct.' );
#
##		$pron = &MTM::Pronunciation::Conversion::convert( 'au0 . r ee4 . l i0 . ux0 s', 'PM', 'cp2tpa', 'aurelius', 'aurelius' );
##		is( $pron, "au \$ r \'e2: \$ l i \$ u s", 'convert pron (cp2tpa): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'aa3 v - b e0 . t aa2 . l a0', 'VB', 'cp2tpa', 'avbetala', 'av+betala' );
#		is( $pron, "\"a2: v - b e \$ t \`a2: \$ l a", 'convert pron (cp2tpa): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'b ox3 r j a0', 'JJ', 'cp2tpa', 'börja', 'börja' );
#		is( $pron, "b \"ö r \$ j \`a", 'convert pron (cp2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'j e3 t eh0 d oo2 l i0 g a0', 'JJ', 'cp2mtm', 'jättedåliga', 'jätte+dåliga' );
#		is( $pron, 'j "e t ex d ,o: l i g a', 'convert pron (cp_2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'f ae r rs rt a4 p eh n', 'JJ', 'cp2mtm', 'Verstappen', 'Verstappen' );
#		is( $pron, "f ae r rs rt \'a p ex n", 'convert pron (cp2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'b ox3 r j a0', 'JJ', 'cp2mtm', 'börja', 'börja' );
#		is( $pron, "b \"ö r \. j ,a", 'convert pron (cp2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'b e . s ee4', 'JJ', 'cp2mtm', 'börja', 'börja' );
#		is( $pron, "b eh \. s \'e:", 'convert pron (cp2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'a0 . m oo3 . n a0', 'PM', 'cp2mtm', 'Amona', 'Amona' );
#		is( $pron, "a \. m \"o: \. n ,a", 'convert pron (cp2mtm): correct.' );
#
#		$pron = &MTM::Pronunciation::Conversion::convert( 'b u . t ii4 k', 'NN', 'cp2mtm', 'butik', 'butik' );
#		is( $pron, "b uu \. t \'i: k", 'convert pron (cp2mtm): correct.' );
#
##		$pron = &MTM::Pronunciation::Conversion::convert( 'r aa4 d i u', 'NN', 'cp2mtm', 'radio', 'radio' );
##		is( $pron, "r \'a: d ih u", 'convert pron (cp2mtm): correct.' );
#
##		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä . t ë - d `å2: . l i . a', 'JJ', 'tpa2tacotron_1', 'jättedåliga', 'jätte+dåliga' );
##		is( $pron, 'j " e t ex d , å: l i a', 'convert pron (tpa2tacotron_1): correct.' );
#
##		$pron = &MTM::Pronunciation::Conversion::convert( 'j "ä . t ë - d `å2: . l i . a', 'JJ', 'tpa2ipa', 'jättedåliga', 'jätte+dåliga' );
##		is( $pron, 'j "ɛ . t ə . d ,oː . l ɪ . a', 'convert pron (tpa2ipa): correct.' );
#	};
#}
#**************************************************#
# MODULE	MTM::Pronunciation::Decomposition.pm

sub decomposition : Test(1) {

	$MTM::Legacy::Lists::sweFinalOrthDecParts{ 'artikel' } = 1;
	$MTM::Legacy::Lists::sweFinalOrthDecParts{ 'nasal' } = 1;
	$MTM::Legacy::Lists::sweFinalOrthMeta{ 'artikel' } = 'NN UTR SIN IND NOM	swe	swe';
	$MTM::Legacy::Lists::sweFinalOrthMeta{ 'nasal' } = 'JJ POS UTR SIN IND NOM      swe     swe';

	subtest "General conversions" => sub {
		plan tests => 8;
		my ( $decomp, $highMeta );

		( $decomp, $highMeta ) = &MTM::Pronunciation::Decomposition::decompose( 'jätte-nasal' );
		is( $decomp, 'jätte+-+nasal', 'decompose word (jätte-nasal): correct.' );
		is( $highMeta, "JJ POS UTR SIN IND NOM	swe	swe", 'decompose highMeta (jätte-nasal): correct.' );

		( $decomp, $highMeta ) = &MTM::Pronunciation::Decomposition::decompose( 'jätte-artikelartikel' );
		is( $decomp, 'jätte+-+artikel+artikel', 'decompose word (jätte-artikelartikel): correct.' );
		is( $highMeta, "NN UTR SIN IND NOM	swe	swe", 'decompose highMeta (jätte-artikelartikel): correct.' );

		( $decomp, $highMeta ) = &MTM::Pronunciation::Decomposition::decompose( 'barnstorm' );
		is( $decomp, 'barn+storm', 'decompose word (barnstorm): correct.' );
		is( $highMeta, "NN UTR SIN IND NOM	swe	swe", 'decompose highMeta (barnstorm): correct.' );

		( $decomp, $highMeta ) = &MTM::Pronunciation::Decomposition::decompose( 'Barn-samhälle' );
		is( $decomp, 'Barn+-+samhälle', 'decompose word (Barn-samhälle): correct.' );
		is( $highMeta, "NN NEU SIN IND NOM	swe	swe", 'decompose highMeta (Barn-samhälle): correct.' );
	}
}


#**************************************************#
# MODULE	MTM::Pronunciation::Dictionary.pm

# nasal all -		multiple results
#( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) =

sub dictionary : Test(11) {
	my @results = split/<SPLIT>/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'nasal', 'all', '-', '-' );
	subtest "Multiples" => sub {
		plan tests => 1;
		is( $#results, 1, 'dictionary multiple results (nasal): correct.' );
	};
	subtest "First result" => sub {
		plan tests => 3;
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, $results[0];
		is( $pos, 'JJ POS UTR SIN IND NOM', 'dictionary main pos JJ (nasal): correct.' );
		is( $ortlang, 'swe', 'dictionary main ortlang (nasal): correct.' );
		#is( $pronlang, 'swe', 'dictionary main pronlang (nasal): correct.' );
		#is( $convertedString, 'nasal', 'dictionary main convertedString (nasal): correct.' );
		is( $id, '320708', 'dictionary main id (nasal): correct.' );
	};
	subtest "First result" => sub {
		plan tests => 3;
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, $results[1];
		is( $pos, 'NN UTR SIN IND NOM', 'dictionary main pos JJ (nasal): correct.' );
		is( $ortlang, 'swe', 'dictionary main ortlang (nasal): correct.' );
		#is( $pronlang, 'swe', 'dictionary main pronlang (nasal): correct.' );
		#is( $convertedString, 'nasal', 'dictionary main convertedString (nasal): correct.' );
		is( $id, '320709', 'dictionary main id (nasal): correct.' );
	};

	subtest "nasal all NN" => sub {
		plan tests => 4;
		# nasal all NN
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'nasal', 'all', 'NN', 'swe' );
		is( $pron, "n a \. s \'a: l", 'dictionary main pron (nasal): correct.' );
		is( $pos, 'NN UTR SIN IND NOM', 'dictionary main pos NN (nasal): correct.' );
		is( $ortlang, 'swe', 'dictionary main ortlang (nasal): correct.' );
		#is( $pronlang, 'swe', 'dictionary main pronlang (nasal): correct.' );
		#is( $convertedString, 'nasal', 'dictionary main convertedString (nasal): correct.' );
		is( $id, '320709', 'dictionary main id (nasal): correct.' );
	};

	subtest "NASal all JJ" => sub {
		plan tests => 4;
		# NASal all JJ
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'NASal', 'all', 'JJ', 'swe' );
		is( $pron, "n a \. s \'a: l", 'dictionary main pron (nasal): correct.' );
		is( $pos, 'JJ POS UTR SIN IND NOM', 'dictionary main pos JJ (nasal): correct.' );
		is( $ortlang, 'swe', 'dictionary main ortlang (nasal): correct.' );
		#is( $pronlang, 'swe', 'dictionary main pronlang (nasal): correct.' );
		#is( $convertedString, 'nasal', 'dictionary main convertedString (nasal): correct.' );
		is( $id, '320708', 'dictionary main id (nasal): correct.' );
	};

	subtest "NASAL ucf NN" => sub {
		plan tests => 1;
		# NASAL ucf NN
		my ( $result, @rest ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'NASAL', 'ucf', 'NN', 'swe' );
		is( $result, '-', 'dictionary main pron (no ucf match): correct.' );
	};

	### TODO Take back if/when multilexicon is used.
	# nå ja all -		multiword
	#( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'nÅ ja', 'all', '-', 'swe' );
	#is( $pron, "n \'å: \$ j a", 'dictionary multi pron (nå ja): correct.' );
	#is( $pos, 'IN', 'dictionary multi pos IN (nå ja): correct.' );
	#is( $ortlang, 'swe', 'dictionary multi ortlang (nå ja): correct.' );
	#is( $pronlang, 'swe', 'dictionary multi pronlang (nå ja): correct.' );
	#is( $convertedString, 'nå ja', 'dictionary multi convertedString (nå ja): correct.' );
	#is( $id, '331158', 'dictionary multi id (nå ja): correct.' );

	subtest "zevin all" => sub {
		plan tests => 5;
		# zevin all -		name
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'zevin', 'all', '-', 'swe' );
		is( $pron, "s eh \. v \'i: n", 'dictionary name pron (zevin): correct.' );
		is( $pos, 'PM NOM', 'dictionary name pos (zevin): correct.' );
		is( $ortlang, 'kur', 'dictionary name ortlang (zevin): correct.' );
		is( $pronlang, 'swe', 'dictionary name pronlang (zevin): correct.' );
		#is( $convertedString, 'Zevin', 'dictionary name convertedString (zevin): correct.' );
		is( $id, '731241', 'dictionary name id (zevin): correct.' );
	};

	subtest "neurolinguistic all" => sub {
		plan tests => 5;
		# neurolinguistic all -		English
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'neurolinguistic', 'all', '-', 'swe' );
		is( $pron, "n j uex \. rh ou ~ l i ng \. g w \'i \. s t i k", 'dictionary main pron (neurolinguistic): correct.' );
		is( $pos, 'NN SIN NOM', 'dictionary English pos (neurolinguistic): correct.' );
		is( $ortlang, 'eng', 'dictionary English ortlang (neurolinguistic): correct.' );
		is( $pronlang, 'eng', 'dictionary English pronlang (neurolinguistic): correct.' );
		#is( $convertedString, 'neurolinguistic', 'dictionary English convertedString (neurolinguistic): correct.' );
		is( $id, '723742', 'dictionary English id (neurolinguistic): correct.' );
	};

	subtest "AAS uc" => sub {
		plan tests => 5;
		# AAS uc -		acronym
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'AAS', 'uc', '-', 'swe' );
		is( $pron, "a: ~ a: ~ \'ä s", 'dictionary acronym pron (AAS): correct.' );
		is( $pos, 'ACR NOM', 'dictionary acronym pos (AAS): correct.' );
		is( $ortlang, 'swe', 'dictionary acronym ortlang (AAS): correct.' );
		is( $pronlang, 'swe', 'dictionary acronym pronlang (AAS): correct.' );
		#is( $convertedString, '-', 'dictionary acronym convertedString (AAS): correct.' );
		is( $id, 'acronym', 'dictionary acronym id (AAS): correct.' );
	};

	### CT 210823 Extra lexicon not read yet.

	subtest "δ all" => sub {
		plan tests => 5;
		# δ all -		specialCharacters
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'δ', 'all', '-', 'swe' );
		is( $pron, "d \'e l \. t a", 'dictionary special pron (δ): correct.' );
		is( $pos, 'NN', 'dictionary special pos (δ): correct.' );
		is( $ortlang, 'swe', 'dictionary special ortlang (δ): correct.' );
		is( $pronlang, 'swe', 'dictionary special pronlang (δ): correct.' );
		#is( $convertedString, 'δ', 'dictionary special convertedString (δ): correct.' );
		is( $id, '-', 'dictionary special id (δ): correct.' );
	};

	subtest "א all" => sub {
		plan tests => 5;
		# א all -		specialCharacters
		my ( $pron, $pos, $ortlang, $pronlang, $convertedString, $id ) = split/\t/, &MTM::Pronunciation::Dictionary::dictionaryLookup( 'א', 'uc', '-', 'swe' );
		is( $pron, "\'a \. l ex f", 'dictionary special pron (א): correct.' );
		is( $pos, 'NN', 'dictionary special pos (א): correct.' );
		is( $ortlang, 'swe', 'dictionary special ortlang (א): correct.' );
		is( $pronlang, 'swe', 'dictionary special pronlang (א): correct.' );
		#is( $convertedString, 'א', 'dictionary special convertedString (א): correct.' );
		is( $id, '-', 'dictionary special id (א): correct.' );
	};
}

#**************************************************#
# MODULE	MTM::PronunciabilityCheck.pm

sub PronunciabilityCheck : Test(1) {
	subtest "checkPronunciability" => sub {
		plan tests => 5;
		my $result;
		# Function	checkPronunciability
		$result = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability('Brügge');
		is( $result, 1, 'checkPronunciability(Brügge): correct.' );

		$result = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability('storstruts');
		is( $result, 1, 'checkPronunciability(västkustskt): correct.' );

		$result = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability('pkr');
		is( $result, 0, 'checkPronunciability(pkr): correct.' );

		$result = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability('västkkustskt');
		is( $result, 0, 'checkPronunciability(västkkustskt): correct.' );

		$result = &MTM::Pronunciation::PronunciabilityCheck::checkPronunciability('aouå');
		is( $result, 0, 'checkPronunciability(västkkustskt): correct.' );
	};
}
#**************************************************#
# MODULE	MTM::Numeral.pm

sub Numeral : Test(1) {
	subtest "promounce numerals" => sub {
		plan tests => 2;
		my $pron;
		# Function	pronounce
		$pron = &MTM::Pronunciation::NumeralPronunciation::pronounce('ett');
		is( $pron, "\'e t", 'numeral pron: correct.' );

		$pron = &MTM::Pronunciation::NumeralPronunciation::pronounce('fem|hundra|nittiofyra');
		is( $pron, "f \'e m \| h \'uu n \. d r a \| n i \. t ih \. u \~ f \"y: \. r \,a", 'numeral pron: correct.' );
	};
}
#**************************************************#
# MODULE	MTM::Pronunciation::Stress.pm
sub Stress : Test(6) {
	subtest "numerals" => sub {
		plan tests => 1;
		my $pron;
		$pron = &MTM::Pronunciation::Stress::numeralStress( "n \'i \$ t i \$ u \~ f \"y: \$ r \,a" );
		is( $pron, "n i \$ t i \$ u \~ f \"y: \$ r \,a", "firstPartStress word (n \'i \$ t i \$ u \~ f \"y: \$ r \,a): correct." );
	};
	subtest "First part stress" => sub {
		plan tests => 2;
		my $pron;

		$pron = &MTM::Pronunciation::Stress::firstPartStress( 'b "i l . d ,ex r' );
		is( $pron, 'b "i l . d ex r', 'firstPartStress word (b "i l . d ,ex r): correct.' );

		$pron = &MTM::Pronunciation::Stress::firstPartStress( "b \'i l d" );
		is( $pron, 'b "i l d', "firstPartStress word (b \'i l d): correct." );
	};
	subtest "Last part stress" => sub {
		plan tests => 2;
		my $pron;

		$pron = &MTM::Pronunciation::Stress::lastPartStress( 'b "i l . d ,ex r' );
		is( $pron, 'b ,i l . d ex r', 'firstPartStress word (b "i l . d ,ex r): correct.' );

		$pron = &MTM::Pronunciation::Stress::lastPartStress( "b \'i l d" );
		is( $pron, 'b ,i l d', "firstPartStress word (b \'i l d): correct." );
	};
	subtest "Acronym stress" => sub {
		plan tests => 4;
		my $pron;

		$pron = &MTM::Pronunciation::Stress::acronymStress( "\'a: ~ b \'e:" );
		is( $pron, '"a: ~ b ,e:', "acronymStress word (\'a: ~ b \'e:): correct." );

		$pron = &MTM::Pronunciation::Stress::acronymStress( "\'a: ~ b \'e: ~ s \'e:" );
		is( $pron, "a: ~ b e: ~ s \'e:", "acronymStress word (\'a: ~ b \'e: ~ s \'e:): correct." );

		$pron = &MTM::Pronunciation::Stress::acronymStress( "\'a: ~ b \'e: ~ s \'e: ~ d \'e:" );
		is( $pron, "a: ~ b e: ~ s e: ~ d \'e:", "acronymStress word (\'a: ~ b \'e: ~ s \'e: ~ d \'e:): correct." );

		$pron = &MTM::Pronunciation::Stress::acronymStress( "\'a: ~ b \'e: ~ s \'e: ~ d \'e: ~ \'e:" );
		is( $pron, 'a: ~ b e: ~ s e: ~ d "e: ~ ,e:', "acronymStress word (\'a: ~ b \'e: ~ s \'e: ~ d \'e: ~ \'e:): correct." );
	};

	subtest "English acronym stress" => sub {
		plan tests => 1;
		my $pron;

		$pron = &MTM::Pronunciation::Stress::englishAcronymStress( "\'ei ~ b \'i: ~ s \'i:" );
		is( $pron, "ei ~ b i: ~ s \'i:", "englishAcronymStress word (\'ei: ~ b \'i: ~ s \'i:): correct." );
	};

	subtest "Swedish compund stress" => sub {
		plan tests => 2;
		my $pron;

		$pron = &MTM::Pronunciation::Stress::sv_compound_stress( "j \"e \. t \,ex - a \. rt \'i \. k ex l - n a \. s \'a: l" );
		is( $pron, 'j "e . t ex - a . rt i . k ex l - n a . s ,a: l', "sv_compound_stress word (j \"e \. t ex - a \. rt \'i \. k ex l - n a \$ s \'a: l): correct." );

		$pron = &MTM::Pronunciation::Stress::sv_compound_stress( "\'e n \| b \'i l d - b \"i l \$ d \,ex r" );
		is( $pron, "\'e n \| b \"i l d - b \,i l \$ d ex r", "sv_compound_stress word (\'e n \| b \'i l d - b \"i l \$ d \,ex r): correct." );
	};
}
#**************************************************#
# MODULE	MTM::Pronunciation::Swedify.pm

#sub Swedify : Test(1) {
#	subtest "swedify" => sub {
#		plan tests => 1;
#		my $result;
#
#		# Function	swedify
#		$result = &MTM::Pronunciation::Swedify::swedify( "r3 \'ei \$ d iex r3" );
#		is( $result, "r \'e j \$ d e: r", "swedify 1 (r \'e j \$ d e: r): correct." );
#	};
#}

#**************************************************#
# MODULE	MTM::Pronunciation::Syllabify.pm

sub Syllabify : Test(1) {
	subtest "syllabify" => sub {
		plan tests => 2;
		my $result;

		# Function	syllabify
		$result = &MTM::Pronunciation::Syllabify::syllabify( 's t "e p g n ,u: ex rn a', 'stäppgnuerna' );
		is( $result, 's t "e p . g n ,u: . ex . rn a', 'syllabify 1 (s t "e p g n ,u: ex rn a, stäppgnuerna): correct.' );

		$result = &MTM::Pronunciation::Syllabify::syllabify( 'r "y s s ,a k t a', 'ryssakta' );
		is( $result, 'r "y s . s ,a k . t a', 'syllabify 1 (r "y s s ,a k t a, ryssakta): correct.' );
	};
}

#**************************************************#
1;
