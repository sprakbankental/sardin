package MTM::Legacy::Lists::Store;

use parent qw(MTM::Legacy::Lists);

use warnings;
use strict;

#*******************************************************************************************#
sub srl_scalar_file {
	my $file = shift;
	my $scalar = shift;

	my $SRLPATH = undef; # Temp fix - remove

	my $srl_file = $file;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;
	my $encoder = Sereal::Encoder->new;
	$encoder->encode_to_file( "$SRLPATH/$srl_file", $scalar, 0);
	return 1;
}
#*******************************************************************************************#
sub srl_hash_file {
	my $file = shift;
	my $hash = shift;

	my $SRLPATH = undef; # Temp fix - remove

	#my %hash = %$hash;

	my $srl_file = $file;
	$srl_file =~ s/^.*\///;
	$srl_file =~ s/\.txt/\.srl/;
	my $encoder = Sereal::Encoder->new;
	#my $hash = \%hash;
	$encoder->encode_to_file( "$SRLPATH/$srl_file", $hash, 0);
	return 1;
}
#*******************************************************************************************#
#
# 2021-02-14 JE General and specific subs for serializing *Legacy vars* and writing them 
#            into *Legacy DB text dumps*
#
# These are the reverse of the various *populate_hash* subs in MTM::Legacy::Lists::Build
#
##### TODO Naming cleanup
# These are better viewed as export functions than as storage, and we'll clean up the 
# naming and packages to reflect that.
#
# The subs take (minimally) a hash reference and a file name. Overwriting of existing files
# is disabled, and this won't change. It's to avoid risks, and is in keeping with the
# status of these functions as export, ratherers than saves.
#
#*******************************************************************************************#
# This is the generic Legacy DB text dump printers. It parses a key to see what type is to
# be used, then calls the specific writer
sub export_hash {

}

# This is one of three substitutes Legacy DB text dump printers.
# This one is used for single part keys and is quite straightforward.
sub export_single_key_hash {
	my $file    = shift;           # The Legacy DB text dump to be read
	my $hashref = shift;           # Ref to the hash we want to populate

	if (-e $file) {
		die "Cannot export to existing file $file";
	}

	print STDERR "OK we're ready to print to $file\n";
	return 1;
}
#*******************************************************************************************#
1;
