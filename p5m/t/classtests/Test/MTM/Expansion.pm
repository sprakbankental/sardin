package Test::MTM::Expansion;

use warnings;
use Scalar::Util qw( reftype );

use Test::More;
use Test::Class;

require MTM::TTSNodeFactory;

use Data::Dumper;

use parent qw(ClassTestBase);


#*****************************************************************************#
# Set the expansion step to work on.
#*****************************************************************************#
sub set_expansion {
	my $test = shift;

	$test->{expansion} = shift;
}

#*****************************************************************************#
#
# Assert the resulting chunk of an analysis class.
#
# $assert = $test->chunk_assert($text, $type, $offset, @expectations);
#
# Execute the function $func in the target class using the tokenized for of $text as input and assert
# that the resulting @expectations are matched and that the corresponding tokens have exprType $type.
#
# The expectations can be specified either
# - strings, where the orth attribute of the token is compared to the expected string and other attributes are asserted to have the default value, asserted to be the
# default, or
# - hash refs where expectations for all token attributes can be specified.  Omitted attributes are compared to the default values.
#
# This will add 1 + number of assertions in @expected_chunk tests.
#
#*****************************************************************************#
sub chunk_assert {
	my ($test, $text, $type, $offset, @expected_chunk) = @_;


	my @text = split $/, $text;
	my $document = MTM::TTSNodeFactory->newdocument;
	$document->{RAW} = \@text;

	$document->normalise;
	$document->chunk;
	$document->tokenise;
	$document->pos_tag($test->{expansion});


	my @chunks = @{$document->{ARRAY}};

	my $expansion = $test->{expansion};

	my $i = $offset;
	my $c = 0;
	my $seq = 1;
	my $unexpected = 0;
	for my $chunk (@chunks) {

		my @chunk = @{$chunk->{ARRAY}};

		# CT 210810 Why this?
		#foreach my $token (@{ $chunk->{ARRAY} }) {
		#	$token->{LEGACYDATA}->{PossibleTags} = [] unless defined $token->{LEGACYDATA}->{PossibleTags};
		#}

		for (; $i < scalar @chunk; $i++) {

			my $ti = $i - $offset;
			if ($ti < @expected_chunk) {
				$c++;

				my $expect = $expected_chunk[$ti];
				my $orth;
				my $pos;
				my $morph;
				my $pron;
				my $lang;
				my $exprType;
				my $exp;
				my $isInDictionary;
				my $pause;
				my $ssml;
				my $textType;
				my $dec;
				my $possibleTags;
				my $tagConf;

				if (!reftype $expect) {
					$expect = { orth => $expect };
				}

				# Main feature to test
				$exp = $type if defined $type && $expansion;

				$orth = $expect->{orth} if exists $expect->{orth};
				$pos = $expect->{pos} if exists $expect->{pos};
				$morph = $expect->{morph} if exists $expect->{morph};
				$pron = $expect->{pron} if exists $expect->{pron};
				$lang = $expect->{lang} if exists $expect->{lang};
				$exprType = $expect->{exprType} if exists $expect->{exprType};
				$exp = $expect->{exp} if exists $expect->{exp};
				$isInDictionary = $expect->{isInDictionary} if exists $expect->{isInDictionary};
				$pause = $expect->{pause} if exists $expect->{pause};
				$ssml = $expect->{ssml} if exists $expect->{ssml};
				$textType = $expect->{textType} if exists $expect->{textType};
				$dec = $expect->{dec} if exists $expect->{dec};
				$possibleTags = $expect->{PossibleTags} if exists $expect->{PossibleTags};
				$tagConf = $expect->{tagConf} if exists $expect->{tagConf};

				my $tn = $ti + $offset + 1;

				# print STDERR "HEY $expansion $chunk[$i]->{LEGACYDATA}->{orth}\t$chunk[$i]->{LEGACYDATA}->{exp}\t$chunk[$i]->{LEGACYDATA}->{exprType}\n";

				is $chunk[$i]->{LEGACYDATA}->{orth}, $orth, "($expansion) token orth is '" . $orth . "' (token " . $tn . " of '$text')" if defined $orth;

				# CT 210810 No reason $pos should be treated differently.
				#ok $chunk[$i]->{LEGACYDATA}->{pos} =~ /\b$pos\b/, "($analysis) token pos (" . $chunk[$i]->{LEGACYDATA}->{pos} . ") matches '" . $pos . "' (token " . $tn . " of '$text')" if defined $pos;
				is $chunk[$i]->{LEGACYDATA}->{pos}, $pos, "($expansion) token pos is '" . $pos . "' (token " . $tn . " of '$text')" if defined $pos;

				is $chunk[$i]->{LEGACYDATA}->{morph}, $morph, "($expansion) token morphh is '" . $morph . "' (token " . $tn . " of '$text')" if defined $morph;
				is $chunk[$i]->{LEGACYDATA}->{pron}, $pron, "($expansion) token pron is '" . $pron . "' (token " . $tn . " of '$text')" if defined $pron;
				is $chunk[$i]->{LEGACYDATA}->{lang}, $lang, "($expansion) token lang is '" . $lang . "' (token " . $tn . " of '$text')" if defined $lang;
				is $chunk[$i]->{LEGACYDATA}->{exprType}, $exprType, "($expansion) token exprType is '" . $exprType . "' (token " . $tn . " of '$text')" if defined $exprType; ### see analysis.pm && !(defined $chunk[$i]->{LEGACYDATA}->{WHITESPACE} && $chunk[$i]->{LEGACYDATA}->{WHITESPACE});
				is $chunk[$i]->{LEGACYDATA}->{exp}, $exp, "($expansion) token exp is '" . $exp . "' (token " . $tn . " of '$text')" if defined $exp;
				is $chunk[$i]->{LEGACYDATA}->{isInDictionary}, $isInDictionary, "($expansion) token isInDictionary is '" . $isInDictionary . "' (token " . $tn . " of '$text')" if defined $isInDictionary;
				is $chunk[$i]->{LEGACYDATA}->{pause}, $pause, "($expansion) token morph is '" . $pause . "' (token " . $tn . " of '$text')" if defined $pause;
				is $chunk[$i]->{LEGACYDATA}->{ssml}, $ssml, "($expansion) token ssml is '" . $ssml . "' (token " . $tn . " of '$text')" if defined $ssml;
				is $chunk[$i]->{LEGACYDATA}->{textType}, $textType, "($expansion) token textType is '" . $textType . "' (token " . $tn . " of '$text')" if defined $textType;
				is $chunk[$i]->{LEGACYDATA}->{dec}, $dec, "($expansion) token dec is '" . $dec . "' (token " . $tn . " of '$text')" if defined $dec;
				is $chunk[$i]->{LEGACYDATA}->{tagConf}, $dec, "($expansion) token tagConf is '" . $tagConf . "' (token " . $tn . " of '$text')" if defined $tagConf;
				if (defined $possibleTags) {
					my @pts = ();
					for my $pt (@possibleTags) {
						ok grep { $_ eq $pt } @{$chunk[$i]->{LEGACYDATA}->{PossibleTags}}, "($expansion) token has possible tag '$pt'" .   "' (token " . $tn . " of '$text')";
					}
				}
			}
		}
	}

	my $n = scalar(@expected_chunk);
	is $c, $n, "($expansion) there should be at least $n tokens in '$text' starting at token with index $offset.";
}

1;
