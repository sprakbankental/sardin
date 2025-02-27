#!/usr/bin/env -S perl -wT

# SBTal boilerplate
use v5.32;
use utf8;
use strict;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;      

use Carp        qw< carp croak confess cluck >;
warn "Warning: running test $0 with taint mode off\n" unless ${^TAINT};
use Test::More;

diag( "Testing distro SBTal v0.1.0, Perl $], in $^X" );

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

my $min_tpc = 1.04;
eval "use Test::Pod::Coverage  $min_tpc";
plan skip_all => "Test::Pod::Coverage $min_tpc required for testing POD coverage" if $@;

use lib qw( lib ); # Not really clear in the Test::Pod::Coverage docs, but essential.

all_pod_coverage_ok();
