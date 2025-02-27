package Test::MTM::TextContainer::ZipSubs;

use Test::More;
# We do not call Test::Class directly, but do it through our parent
# classes corresponding class test. That way we also inheret all testing.
#use parent qw(Test::MTM::TextContainer);
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

use MTM::TextContainer::ZipSubs;
use Archive::Zip qw(:ERROR_CODES :CONSTANTS);

my $infile = "t/data/test/unsupervised_ssml_test_epub.epub";
my $unzipped_path = "tmp/test";

#*******************************************************************************#
# unzip_files
MTM::TextContainer::ZipSubs::unzip_files( $infile, $unzipped_path );

# Check dirs
opendir my $dir_fh, $unzipped_path or die $!;
my $dirs = join"\t", readdir( $dir_fh );
ok( $dirs =~ /EPUB/, "$infile contains EPUB directory." );
ok( $dirs =~ /META-INF/, "$infile contains META-INF directory." );
ok( $dirs =~ /mimetype/, "$infile contains mimetype directory." );
closedir $dir_fh;

# Check files
opendir my $epub_fh, "$unzipped_path/EPUB" or die $!;
my $epub_files = join"\t", readdir( $epub_fh );
ok( $epub_files =~ /V00005-003-chapter\.xhtml/, "$infile contains EPUB chapter." );
closedir $epub_fh;

#*******************************************************************************#
# zip_files
MTM::TextContainer::ZipSubs::zip_files( $infile, $unzipped_path );

 