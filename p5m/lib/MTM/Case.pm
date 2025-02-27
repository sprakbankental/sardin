package MTM::Case;

# CT 2024-01-30 wait with SBtal boilerplate, something's wrong when running news scripts.
# CT 2024-08-19 trying anyway, tests work
#**************************************************************#
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

#****************************************************************************#
# Get case
sub getCase {	# Return: list of case options
	
	my $case = shift;
	my @case = ();
	
	if ( $case =~ /all/ ) {
		@case = ( 'original', 'lc', 'ucf', 'uc' );
	} else {
		push @case, $case;
	}
	
	return \@case;
}

sub makeLowercase {
	my $string = shift;
	
	$string =~ s/Å/_aa_/g;
	$string =~ s/Ä/_ae_/g;
	$string =~ s/Ö/_oe_/g;
	$string =~ s/å/_aa_/g;
	$string =~ s/ä/_ae_/g;
	$string =~ s/ö/_oe_/g;
	$string =~ s/É/_eee_/g;
	$string =~ s/é/_eee_/g;
	$string =~ s/Ó/_oo_/g;
	$string =~ s/ó/_oo_/g;
	$string =~ s/Á/_aaa_/g;
	$string =~ s/á/_aaa_/g;
	$string =~ s/È/_ee_/g;
	$string =~ s/è/_ee_/g;
	$string =~ s/Ü/_uu_/g;
	$string =~ s/Ñ/_nn_/g;
	$string =~ s/ü/_uu_/g;
	$string =~ s/Æ/_ae2_/g;
	$string =~ s/Ø/_oe2_/g;
	$string =~ s/æ/_ae2_/g;
	$string =~ s/ø/_oe2_/g;

	
	$string = lc($string);
	
	$string =~ s/_aa_/å/g;
	$string =~ s/_ae_/ä/g;
	$string =~ s/_oe_/ö/g;
	$string =~ s/_eee_/é/g;
	$string =~ s/_ee_/è/g;
	$string =~ s/_oo_/ó/g;
	$string =~ s/_aaa_/á/g;
	$string =~ s/_uu_/ü/g;
	$string =~ s/_nn_/ñ/g;
	$string =~ s/_ae2_/æ/g;
	$string =~ s/_oe2_/ø/g;
	
	return $string;	
	
}
#*************************************************************#
sub makeUppercaseFirst {
	my $string = shift;
	
	$string =~ s/å/_aa_/g;
	$string =~ s/ä/_ae_/g;
	$string =~ s/ö/_oe_/g;
	$string =~ s/é/_eee_/g;
	$string =~ s/è/_ee_/g;
	$string =~ s/ó/_oo_/g;
	$string =~ s/á/_aaa_/g;
	$string =~ s/ü/_uu_/g;
	$string =~ s/ñ/_nn_/g;
	$string =~ s/æ/_ae2_/g;
	$string =~ s/ø/_oe2_/g;

	$string =~ s/Å/_AA_/g;
	$string =~ s/Ä/_AE_/g;
	$string =~ s/Ö/_OE_/g;
	$string =~ s/É/_EEE_/g;
	$string =~ s/È/_EE_/g;
	$string =~ s/Ó/_OO_/g;
	$string =~ s/Á/_AAA_/g;
	$string =~ s/Ü/_UU_/g;
	$string =~ s/Ñ/_NN_/g;
	$string =~ s/Æ/_AE2_/g;
	$string =~ s/Ø/_OE2_/g;

	$string = lc( $string );	# CT 110808		
	$string = ucfirst($string);
	
	$string =~ s/^_aa_/Å/g;
	$string =~ s/^_ae_/Ä/g;
	$string =~ s/^_oe_/Ö/g;
	$string =~ s/^_eee_/É/g;
	$string =~ s/^_ee_/È/g;
	$string =~ s/^_oo_/Ó/g;
	$string =~ s/^_aaa_/Á/g;
	$string =~ s/^_uu_/Ü/g;
	$string =~ s/^_nn_/Ñ/g;
	$string =~ s/^_AE2_/Æ/g;
	$string =~ s/^_OE2_/Ø/g;

	$string =~ s/_aa_/å/g;
	$string =~ s/_ae_/ä/g;
	$string =~ s/_oe_/ö/g;
	$string =~ s/_eee_/é/g;
	$string =~ s/_ee_/è/g;
	$string =~ s/_oo_/ó/g;
	$string =~ s/_aaa_/á/g;
	$string =~ s/_uu_/ü/g;
	$string =~ s/_nn_/ñ/g;
	$string =~ s/_ae2_/æ/g;
	$string =~ s/_oe2_/ø/g;

	return $string;	
	
}
#*************************************************************#
sub makeUppercase {
	my $string = shift;

	$string =~ s/Å/_AA_/g;
	$string =~ s/Ä/_AE_/g;
	$string =~ s/Ö/_OE_/g;
	$string =~ s/å/_AA_/g;
	$string =~ s/ä/_AE_/g;
	$string =~ s/ö/_OE_/g;
	$string =~ s/É/_EEE_/g;
	$string =~ s/È/_EE_/g;
	$string =~ s/é/_EEE_/g;
	$string =~ s/è/_EE_/g;
	$string =~ s/Ó/_OO_/g;
	$string =~ s/ó/_oo_/g;
	$string =~ s/Á/_AAA_/g;
	$string =~ s/á/_aaa_/g;
	$string =~ s/Ü/_UU_/g;
	$string =~ s/ü/_UU_/g;
	$string =~ s/Ñ/_NN_/g;
	$string =~ s/ñ/_NN_/g;
	$string =~ s/æ/_AE2_/g;
	$string =~ s/ø/_OE2_/g;
	$string =~ s/Æ/_AE2_/g;
	$string =~ s/Ø/_OE2_/g;

	$string = uc($string);
	
	$string =~ s/_AA_/Å/g;
	$string =~ s/_AE_/Ä/g;
	$string =~ s/_OE_/Ö/g;
	$string =~ s/_EEE_/É/g;
	$string =~ s/_EE_/È/g;
	$string =~ s/_OO_/Ó/g;
	$string =~ s/_AAA_/Á/g;
	$string =~ s/_UU_/Ü/g;
	$string =~ s/_NN_/Ñ/g;
	$string =~ s/_AE2_/Æ/g;
	$string =~ s/_OE2_/Ø/g;
	
	return $string;	
	
}

#***************************************************#
# Returns a list of orthography in different cases
#***************************************************#
sub caseLookup {
	my ( $orth, $case ) = @_;
	my @caseOrth = ();
	
	# Case sensitive
	if ( $case =~ /casesensitive/ ) {
		push @caseOrth, $orth;
		return ( @caseOrth );

	# Case insensitive
	} elsif ( $case =~ /caseInsensitive/i ) {
		push @caseOrth, $orth;
		push @caseOrth, &MTM::Case::makeLowercase( $orth );
		push @caseOrth, &MTM::Case::makeUppercase( $orth );
		push @caseOrth, &MTM::Case::makeUppercaseFirst( $orth );
		
		return ( @caseOrth );
	
	# Lower case	
	} elsif ( $case =~ /lc/ ) {
		push @caseOrth, &MTM::Case::makeLowercase( $orth );
		return @caseOrth;

	# Uppercase first
	} elsif ( $case =~ /ucfirst/ ) {
		push @caseOrth, &MTM::Case::makeUppercaseFirst( $orth );
		return @caseOrth;
	
	# Upper case
	} elsif ( $case =~ /uc/ ) {
		push @caseOrth, &MTM::Case::makeUppercase( $orth );
		return @caseOrth;
	}
	
	

	
	
}
#***************************************************#

1;