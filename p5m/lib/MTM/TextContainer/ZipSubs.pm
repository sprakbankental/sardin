package MTM::TextContainer::ZipSubs;
use v5.32;                    # We assume pragmas and such from 5.32.0

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

use Archive::Zip qw(:ERROR_CODES :CONSTANTS);

#*******************************************************************************#
sub unzip_files {
	my $infile = shift;
	my $unzipped_path = shift;

	my $zip = Archive::Zip->new();
	unless ( $zip->read( $infile ) == AZ_OK ) {
		die 'Read error: The file could not be unzipped';
	}
	$zip->extractTree( '', "$unzipped_path/" );
}
#*******************************************************************************#
sub list_files {
	my $dir = shift;

	my @DIRLIST = ();
	push @DIRLIST, $dir;

	use File::Find;
	#sub process_file {
	#    # do whatever;
	#}
	#print "DIR @DIRLIST\n";
	find(\&process_file, @DIRLIST);
}

sub process_file {
	#print "HO\t$_\n";
}

#*******************************************************************************#
sub zip_file {
	my $zipfile = shift;
	my @indir = @_;

	my $zip = Archive::Zip->new();
	$zip->read( $zipfile ) if -s $zipfile;

	foreach my $file ( @indir ) {
		$zip->addFile( $file );
	}

}
#*******************************************************************************#
# Unzip dir and return list of files
sub unzip_and_list {
	my $infile = shift;
	my $zip_path = shift;

	my $zip = Archive::Zip->new();
	unless ( $zip->read( $infile ) == AZ_OK ) {
		die 'Read error: The file could not be unzipped';
	}
 	$zip->extractTree( '', "$zip_path/" );
	print "Unzipped to $zip_path\n";

	exit;
#	# Unzip
#	my $zip = Archive::Zip->new( $infile );
#
#	foreach my $member ($zip->members) {
#		next if $member->isDirectory;
#		#( my $extractName = $member->fileName ) =~ s{.*/}{};
#		#$member->extractToFileNamed( "$zip_path/$extractName" );
#		print "ZZZ $member\t$zip_path/$extractName\n\n\n";
#	}
#
#	my $fh_zip;
#	#print "OPENING $tmpPath/$dir/$file_dir\n";
#	opendir $fh_zip, "$zip_path" or die "Cannot open $fh_zip $zip_path: $!\n";
#	my @zip_files = readdir( $fh_zip );
#	closedir $fh_zip;

#	return( @zip_files );
}
#*******************************************************************************#
sub zip_dir {
	my $zip_dir = shift;
	my $filename = shift;

	my $epubzip = Archive::Zip->new();
	$epubzip->addTree( "$zip_dir/.", "" );
	$epubzip->writeToFileNamed( "$zip_dir/$filename" );
}
#*******************************************************************************#
1;
