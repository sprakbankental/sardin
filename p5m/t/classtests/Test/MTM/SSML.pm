package Test::MTM::SSML;

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

use MTM::TTSNodeFactory;

sub startup : Tests(startup) {
	my $test  = shift;
	$test->set_ssml('ssml_test');
 #**************************************************************#
 # Set all ssml parameters to 0
 #
 # <phoneme>
 $MTM::Vars::do_pronunciation_ssml = 0;
 $MTM::Vars::do_oov_ssml = 0;
 $MTM::Vars::do_acronym_ssml = 0;
 $MTM::Vars::do_initial_ssml = 0;

 $MTM::Vars::do_email_ssml = 0;
 $MTM::Vars::do_url_ssml = 0;
 $MTM::Vars::do_filename_ssml = 0;

 #**************************************************************#
 # <sub>
 $MTM::Vars::do_sub_exprtypes_ssml = 0;

 $MTM::Vars::do_abbreviation_ssml = 0;

 # Numeral expressions
 $MTM::Vars::do_numeral_ssml = 0;
 $MTM::Vars::do_date_ssml = 0;
 $MTM::Vars::do_time_ssml = 0;
 $MTM::Vars::do_year_ssml = 0;
 $MTM::Vars::do_currency_ssml = 0;
 $MTM::Vars::do_decimal_ssml = 0;
 $MTM::Vars::do_phone_number_ssml = 0;
 $MTM::Vars::do_ordinal_ssml = 0;
 $MTM::Vars::do_interval_ssml = 0;
 $MTM::Vars::do_fraction_ssml = 0;

 #**************************************************************#
 # <break>
 $MTM::Vars::do_pause_ssml = 0;

 #**************************************************************#
 # Special
 $MTM::Vars::do_page_ssml = 0;
 $MTM::Vars::do_law_reference_ssml = 0;
 $MTM::Vars::do_hyphen_ssml = 0;
 $MTM::Vars::do_hyphen_interval_ssml = 0;
 #**************************************************#
}

sub SSML : Tests(466) {
	my $test = shift;

	#*******************************************************************************************#
	# <phoneme>

	# do_pronunciation_ssml
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{pronunciation} = 1;
	$test->_chunk_assert( 'mått s. 39-45, proppeloppus!', '-', 0,
		{orth => 'mått', ssml=>"<phoneme>	m \'å t	0	3" },
		{orth => ' ', ssml=>'-' },
		{orth => 's.', ssml=>"<phoneme>	s \"i2: \$ d \`a n	0	1" },
		{orth => ' ', ssml=>'-' },
		{orth => '39', ssml=>"<phoneme>	t r e \$ t i3 \$ o ~ n \"i2: \$ \`o	0	1" },
		{orth => '-', ssml=>"<phoneme>	t \'i l	0	0" },
		{orth => '45', ssml=>"<phoneme>	f ö3 \$ rt i3 \$ o ~ f \'e m	0	1" },
		{orth => ',', ssml=>'-' },
		{orth => ' ', ssml=>'-' },
		{orth => 'proppeloppus', ssml=>"<phoneme>	p r o3 \$ p \'e3 \$ l o \$ p u s	0	11" }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{pronunciation} = 0;

	# do_oov_ssml
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{oov} = 1;
	$test->_chunk_assert( 'mått 39 gånger 45, proppeloppus!', '-', 0,
		{orth => 'mått'},
		' ',
		{orth => '39'},
		' ',
		{orth => 'gånger' },
		' ',
		{orth => '45'},
		{orth => ','},
		{orth => ' '},
		{orth => 'proppeloppus', ssml=>"<phoneme>	p r o3 \$ p \'e3 \$ l o \$ p u s	0	11" }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{oov} = 0;

	# do_acronym_ssml
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{acronym} = 1;
	$test->_chunk_assert( 'mått, PTQ!', '-', 0,
		{orth => 'mått'},
		{orth => ','},
		' ',
		{orth => 'PTQ', ssml=>"<phoneme>	p e2: ~ t e2: ~ k \'u2:	0	2" },
		{orth => '!'}
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{acronym} = 0;

	# do_acronym_ssml
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{initial} = 1;
	$test->_chunk_assert( 'mått, P. T. Karlsson', '-', 0,
		{orth => 'mått'},
		{orth => ','},
		' ',
		{orth => 'P', ssml=>"<phoneme>	p \'e2:	0	0" },
		{orth => '.'},
		' ',
		{orth => 'T', ssml=>"<phoneme>	t \'e2:	0	0" },
		{orth => '.'},
		' ',
		{orth => 'Karlsson'}
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{initial} = 0;


	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{email} = 1;
	#my $snabela_cheat = 'ä s ~ ä n ~ a2: ~ b e2: ~ "e2: ~ ä l - `a';	### TODO don't cheat!
	$test->_chunk_assert( 'mått, pt@karlsson.se', '-', 0,
		{orth => 'mått'},
		{orth => ','},
		' ',
		{orth => 'pt', ssml=>"<phoneme>	p \"e2: ~ t \`e2:	0	1" },
		{orth => '@', exp=>'snabel-a', ssml=>"<phoneme>	s n \"a2: \$ b ë l - \`a2:	0	0"},
		{orth => 'karlsson', ssml=>"<phoneme>	k \'a2: rl \$ s å n	0	7" },
		{orth => '.', exp=>'punkt', ssml=>"<phoneme>	p \'u ng t	0	0" },
		{orth => 'se', ssml=>"<phoneme>	\"ä s ~ \`e2:	0	1" },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{email} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{url} = 1;
	$test->_chunk_assert( 'mått, www.mtm.se', '-', 0,
		{orth => 'mått'},
		{orth => ','},
		' ',
		{orth => 'www', ssml=>"<phoneme>	v e2: \$ v e2: \$ v \'e2:	0	2" },
		{orth => '.', exp=>'punkt', ssml=>"<phoneme>	p \'u ng t	0	0" },
		{orth => 'mtm', ssml=>"<phoneme>	ä m ~ t e2: ~ \'ä m	0	2" },
		{orth => '.', exp=>'punkt', ssml=>"<phoneme>	p \'u ng t	0	0" },
		{orth => 'se', ssml=>"<phoneme>	\"ä s ~ \`e2:	0	1" },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{url} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{filename} = 1;
	$test->_chunk_assert( 'mått, C:/fil.txt', '-', 0,
		{orth => 'mått'},
		{orth => ','},
		' ',
		{orth => 'C', ssml=>"<phoneme>	s \'e2:	0	0" },
		{orth => ':', exp=>'kolon', ssml=>"<phoneme>	k \'o2: \$ l å n	0	0" },
		{orth => '/', exp=>'snedstreck', ssml=>"<phoneme>	s n \"e2: d - s t r \`e k	0	0" },
		{orth => 'fil', ssml=>"<phoneme>	f \'i2: l	0	2" },
		{orth => '.', exp=>'punkt', ssml=>"<phoneme>	p \'u ng t	0	0" },
		{orth => 'txt', exp=>'-', ssml=>"<phoneme>	t e2: ~ ä k s ~ t 'e2:	0	2" },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{phoneme}{filename} = 0;


	#********************************************************************#
	# <sub>
	#********************************************************************#
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{numeral} = 1;
	$test->_chunk_assert( '15,2 och 2/9-1987', '-', 0,
		{orth => '15', ssml=>'<sub>	femton	0	1' },
		{orth => ',', ssml=>'<sub>	komma	0	0' },
		{orth => '2', ssml=>'<sub>	två	0	0' },
		{orth => ' ' },
		{orth => 'och' },
		{orth => ' ' },
		{orth => '2', ssml=>'<sub>	andra	0	0' },
		{orth => '/', ssml=>'<sub>	i	0	0' },
		{orth => '9', ssml=>'<sub>	nionde	0	0' },
		{orth => '-' },
		{orth => '1987', ssml=>'<sub>	nitton|hundra|åttiosju	0	3' },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{numeral} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{date} = 1;
	$test->_chunk_assert( '2/9-1987', '-', 0,
		{orth => '2', ssml=>'<sub>	andra	0	0' },
		{orth => '/', ssml=>'<sub>	i	0	0' },
		{orth => '9', ssml=>'<sub>	nionde	0	0' },
		{orth => '-' },
		{orth => '1987', ssml=>'<sub>	nitton|hundra|åttiosju	0	3' },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{date} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{time} = 1;
	$test->_chunk_assert( 'Kl. 18.10.', '-', 0,
		{orth => 'Kl.', ssml=>"<sub>	klockan	0	2" },
		' ',
		{orth => '18', ssml=>'<sub>	arton	0	1' },
		{orth => '.', ssml=>'<sub>	och	0	0' },
		{orth => '10', ssml=>'<sub>	tio	0	1' },
		{orth => '.' }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{time} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{year} = 1;
	$test->_chunk_assert( '2/9-1987', '-', 0,
		{orth => '2' },
		{orth => '/' },
		{orth => '9' },
		{orth => '-' },
		{orth => '1987', ssml=>'<sub>	nitton|hundra|åttiosju	0	3' },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{year} = 0;


	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{currency} = 1;
	$test->_chunk_assert( 'Det kostar $5.99', '-', 0,
		{orth => 'Det' },
		' ',
		{orth => 'kostar' },
		' ',
		{orth => '$', ssml=>'<sub>	<none>	0	0' },
		{orth => '5', ssml=>'<sub>	fem|dollar	0	0' },
		{orth => '.', ssml=>'<sub>	och	0	0' },
		{orth => '99', ssml=>'<sub>	nittionio|cent	0	1' },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{currency} = 0;


	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{decimal} = 1;
	$test->_chunk_assert( '15,2 och sedan 789.', '-', 0,
		{orth => '15', ssml=>'<sub>	femton	0	1' },
		{orth => ',', ssml=>'<sub>	komma	0	0' },
		{orth => '2', ssml=>'<sub>	två	0	0' },
		' ',
		{orth => 'och' },
		' ',
		{orth => 'sedan' },
		' ',
		{orth => '789' },
		{orth => '.' }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{decimal} = 0;


	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{phone} = 1;
	$test->_chunk_assert( 'Nås på tfn. 08-789 52 25', '-', 0,
		{orth => 'Nås' },
		' ',
		{orth => 'på' },
		' ',
		{orth => 'tfn.' },
		' ',
		{orth => '08', ssml=>'<sub>	noll|åtta	0	1' },
		{orth => '-' },
		{orth => '789', ssml=>'<sub>	sju|hundra|åttionio	0	2' },
		' ',
		{orth => '52', ssml=>'<sub>	femtiotvå	0	1' },
		' ',
		{orth => '25', ssml=>'<sub>	tjugofem	0	1' }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{phone} = 0;


#	$MTM::Vars::do_ordinal_ssml = 1;
#	$MTM::Vars::do_ordinal_ssml = 0;


	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{interval} = 1;
	$test->_chunk_assert( 'Öppet mån. - tis. på nummer 3-13', '-', 0,
		{orth => 'Öppet' },
		' ',
		{orth => 'mån.', ssml=>'<sub>	måndag	0	3' },
		' ',
		{orth => '-', ssml=>'<sub>	till	0	0' },
		' ',
		{orth => 'tis.', ssml=>'<sub>	tisdag	0	3' },
		' ',
		{orth => 'på' },
		' ',
		{orth => 'nummer' },
		' ',
		{orth => '3', ssml=>'<sub>	tre	0	0' },
		{orth => '-', ssml=>'<sub>	till	0	0' },
		{orth => '13', ssml=>'<sub>	tretton	0	1' }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{interval} = 0;


	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{fraction} = 1;
	$test->_chunk_assert( '1/2 och sedan ½ msk.', '-', 0,
		{orth => '1' },
		{orth => '/' },
		{orth => '2' },
		' ',
		{orth => 'och' },
		' ',
		{orth => 'sedan' },
		' ',
		{orth => '½', ssml=>'<sub>	en|halv	0	0' },
		' ',
		{orth => 'msk' },
		{orth => '.' },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{fraction} = 0;

	#*******************************************************************************************#
	# Misc <sub>
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{pagenum} = 1;
	$test->_chunk_assert( 'Karlsson, S. 1940, s. 7-17.', '-', 0,
		{orth => 'Karlsson' },
		{orth => ',' },
		' ',
		{orth => 'S' },
		{orth => '.' },
		' ',
		{orth => '1940' },
		{orth => ',' },
		' ',
		{orth => 's.', ssml=>'<sub>	sidan	0	1' },
		' ',
		{orth => '7' },
		{orth => '-' },
		{orth => '17' },
		{orth => '.' }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{pagenum} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{lawref} = 1;
	$test->_chunk_assert( '§17.', '-', 0,
		{orth => '§', ssml=>'<sub>	paragraf	0	0' },
		{orth => '17', ssml=>'<sub>	sjutton	0	1' },
		{orth => '.' }
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{lawref} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{hyphen} = 1;
	$test->_chunk_assert( '- 3-2 - sidorna 23-34', '-', 0,
		{orth => '-'},
		{orth => ' '},
		{orth => '3'},
		{orth => '-', ssml=>'<sub>	streck	0	0' },
		{orth => '2'},
		{orth => ' '},
		{orth => '-'},
		{orth => ' '},
		{orth => 'sidorna'},
		{orth => ' '},
		{orth => '23'},
		{orth => '-', ssml=>'<sub>	till	0	0' },
		{orth => '34'},
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{hyphen} = 0;

	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{hypheninterval} = 1;
	$test->_chunk_assert( '- 3-2 - sidorna 23-34', '-', 0,
		{orth => '-'},
		{orth => ' '},
		{orth => '3'},
		{orth => '-'},
		{orth => '2'},
		{orth => ' '},
		{orth => '-'},
		{orth => ' '},
		{orth => 'sidorna'},
		{orth => ' '},
		{orth => '23'},
		{orth => '-', ssml=>'<sub>	till	0	0' },
		{orth => '34'},
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{misc}{hypheninterval} = 0;

	#*******************************************************************************************#
	# <break>
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{break}{pause} = 1;
	$test->_chunk_assert( 'Karlsson, Sigurd (1987, 1988, 1989 och 2015).', '-', 0,
		{orth => 'Karlsson' },
		{orth => ',', ssml=>'<break>	150	0	0' },
		' ',
		{orth => 'Sigurd' },
		' ',
		{orth => '(', ssml=>'<break>	150	0	0' },
		{orth => '1987' },
		{orth => ',', ssml=>'<break>	150	0	0' },
		' ',
		{orth => '1988' },
		{orth => ',', ssml=>'<break>	150	0	0' },
		' ',
		{orth => '1989' },
		' ',
		{orth => 'och' },
		' ',
		{orth => '2015' },
		{orth => ')', ssml=>'<break>	150	0	0' },
		{orth => '.' },
	);	
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{break}{pause} = 0;

	#**************************************************#
	# <sub>
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{abbreviation} = 1;
	$test->_chunk_assert( 'Katt m.m., 32ff.).', '-', 0,
		{orth => 'Katt' },
		' ',
		{orth => 'm.m.', ssml=>'<sub>	med mera	0	3' },
		',',
		' ',
		{orth => '32'},
		{orth => 'ff', ssml=>'<sub>	och följande sidor	0	1' }
	);
	$test->_chunk_assert( 'allm.).', '-', 0,
		{orth => 'allm.', ssml=>'<sub>	allmän	0	4' },
	);
	$test->_chunk_assert( 'ibid.).', '-', 0,
		{orth => 'ibid.', ssml=>'<sub>	Ibidem	0	4' },
	);
	$MTM::MTMInternal::VAC::Analysis::unsupervised_ssml::hp{sub}{abbreviation} = 0;
}












#*****************************************************************************#
# Set the ssml step to work on.
#*****************************************************************************#
sub set_ssml {
	my $test = shift;

	$test->{ssml_test} = shift;
}

#*****************************************************************************#
#
# Assert the resulting chunk of an ssml class.
#
# $assert = $test->chunk_assert($text, $type, $offset, @expectations);
#
# Execute the function $func in the target class using the tokenized for of 
# $text as input and assert that the resulting @expectations are matched and 
# that the corresponding tokens have exprType $type.
#
# The expectations can be specified either
# - strings, where the orth attribute of the token is compared to the expected 
#   string and other attributes are asserted to have the default value, 
#   asserted to be the default, or
# - hash refs where expectations for all token attributes can be specified.  
#   Omitted attributes are compared to the default values.
#
# This will add 1 + number of assertions in @expected_chunk tests.
#
#*****************************************************************************#
sub _chunk_assert {
	my ($test, $text, $type, $offset, @expected_chunk) = @_;

	my @text = split $/, $text;
	my $document = MTM::TTSNodeFactory->newdocument;
	$document->{RAW} = \@text;

	$document->normalise;
	$document->chunk;
	$document->tokenise;
	$document->pos_tag($test->{ssml_test});

	my @chunks = @{$document->{ARRAY}};

	my $i = $offset - 1;
	my $c = 0;
	my $seq = 1;
	my $unexpected = 0;
 # Iterate through chunks using TTSDocument's CursorArray methods
 for ($document->reset; my $chunk = $document->current; $document->move(1)) {

		# CT 210810 Why this?
   # JE 221102 To build up the data structure and avoid attempts to access
   #           arrays that are undefined.
		#foreach my $token (@{ $chunk->{ARRAY} }) {
		#	$token->{LEGACYDATA}->{PossibleTags} = [] unless defined $token->{LEGACYDATA}->{PossibleTags};
		#}

   # Now iterate through the tokens in the chunk, again using the 
   # CursorArray methods provided by TTSChunk and nothing else
   for ($chunk->reset; my $token = $chunk->current; $chunk->move(1)) {
     $i++;

			my $ti = $i - $offset;
			if ($ti < @expected_chunk) {
				$c++;

				my $expect = $expected_chunk[$ti];
				my $ssml;
				my $possibleTags;

				if (!ref($expect)) {
					$expect = { orth => $expect };
				}

				# Main feature to test
				$ssml = $type if defined $type && $test->{ssml_test};

       # JE 220102 Why is $ssml redefined here? What is the first definition supposed to do?
       #           If the first def is removed, a whole bunch of tests are skipped, obscurely.
       #           Some explanatory comments would be very good.
       $ssml = $expect->{ssml} if exists $expect->{ssml};
				$possibleTags = $expect->{PossibleTags} if exists $expect->{PossibleTags};

				my $tn = $ti + $offset + 1;

       #-------------------------------------------------------------#
       # Run tests (comparisons)
       # 1 We loop through each potential property
       foreach my $key ( qw(orth pos morph pron axprType exp isInDictionary pause texttype dec tagConf) ) {
         # 2 Check if it is included in our expectations, we 
         if (exists $expect->{$key}) {
           # 3 If it is, we test our expecttations
           is(
             $token->{LEGACYDATA}->{$key}, 
             $expect->{$key}, 
             "($test->{ssml_test}) token orth is '" . $expect->{$key} . "' (token " . $tn . " of '$text')"
           ); 
         }
       }
       #
       #-------------------------------------------------------------#

				is $token->{LEGACYDATA}->{ssml}, $ssml, "($test->{ssml_test}) token ssml is '" . $ssml . "' (token " . $tn . " of '$text')" if defined $ssml;

       #-------------------------------------------------------------#
       # JE 221102 This is never reached by the current tests, and if 
       #           it was, I don't think it will work. Added a warning 
       #           in case it is reached by later tests.
       if (defined $possibleTags) {
         warn "Potentially bugged test";
					my @pts = ();
					for my $pt (@$possibleTags) {
						ok grep { $_ eq $pt } @{$token->{LEGACYDATA}->{PossibleTags}}, "($test->{ssml_test}) token has possible tag '$pt'" .   "' (token " . $tn . " of '$text')";
					}
				}
       #
       #-------------------------------------------------------------#
			}
		}
	}

	my $n = scalar(@expected_chunk);
	is $c, $n, "($test->{ssml_test}) there should be at least $n tokens in '$text' starting at token with index $offset.";
}

1;
