#!/usr/bin/perl -w

# This contains tests of the Perl prerequisites for this repo
# It merely checks that the required Perl modules are 
# installed. That means that the module list below can be taken 
# as a module manifest for the repo.

use Test::More tests => 11;

require_ok( 'Test::Class' );	             # Used to run basic OO module tests
require_ok( 'Archive::Zip' );	             # Used for archiving and EPUB management
require_ok( 'DateTime' );	                 # UseDate and time management
require_ok( 'DateTime::Format::ISO8601' ); # ISO format
require_ok( 'Tie::Array' );	               # Tied arrays
require_ok( 'XML::LibXML' );	             # Most if not all XML tasks
require_ok( 'Sereal' );	                   # Local object persistancy
require_ok( 'Pod::Find' );	               # Used for --help in scripts
require_ok( 'Smart::Comments' );	         # For inline docs
require_ok( 'Log::Any' );                  # For generic logging  
require_ok( 'Path::Class' );               # Cleaner path management



