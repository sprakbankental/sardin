#!/usr/bin/env perl -w

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
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;

use Carp        qw< carp croak confess cluck >;

use version 0.77; our $VERSION = version->declare('v0.1.0');

# Smart comments are used as follows in SBTal
# ###    Flow, progress and light variables
# ####   Large variables
# #####  Important TODOs and such
# ###### Debugging: checks and assertions, expressions
# Uncomment to use (NB this is a source filter and will affect performance):
# use Smart::Comments ('###');
### Warning - Smart comments are in use
# We use this core Perl alternative to Keyword::DEVELOPMENT;
# In SBTal P5M Docker images, use convenience alias p5mdev_on/p5mdev_off to switch
use constant SBTAL_P5M_DEV => !!$ENV{SBTAL_P5M_DEV};
# do {expensive_debugging_code()} if SBTAL_P5M_DEV;
# Create generic logger
use Log::Any qw($log);
use Log::Any::Adapter;
# Log to STDERR and set log level
Log::Any::Adapter->set('Stderr', log_level => 'trace');
# End SBTal boilerplate

use Test::More tests => 2;
# We see to it that the current script dir is in lib
use FindBin 1.51 qw( $RealBin );
use lib $RealBin;
# Then we load the test specific helpers
use LDTest::Common;

# Load all Legacy at once
use MTM::Legacy;

# Copy DATA contents to a temporary file, get a handle to 
# that file (DATA is reset and can be read again)
my $copyhandle = LDTest::Common::copyhandle(\*DATA);

ok(LDTest::Common::cmphandles(
	$copyhandle, 
	*DATA), 
	"Pretest: preparatory copy to temp file"
);


# Copy DATA to file for use as the Legacy DB text dump
# with the populate method
my $ldbtd = LDTest::Common::copyhandle_tofile(\*DATA);


# The next step is to deserialise the text DB using Legacy::Lists, 
# to serialise is again using the counterpart, and then to compare
# these two.
my $testhash = {};
MTM::Legacy::Lists::Build::populate_single_key_hash($ldbtd, $testhash);

if (1) {
	use utf8;
	use Data::Dumper;
	print STDERR Dumper $testhash;
	no utf8;
}

my $correcthash = {
	'a' => '\'a2:',
	'b' => 'b \'e2:',
	'c' => 's \'e2:',
	'd' => 'd \'e2:',
	'e' => '\'e2:',
	'h' => 'h \'å2:',
	'f' => '\'ä f',
	'g' => 'g \'e2:',
	'i' => '\'i2:',
  'j' => 'j \'i2:',
  'k'	=> 'k \'å2:',
  'l'	=> '\'ä l',
  'm'	=> '\'ä m',
  'n'	=> '\'ä n',
  'o'	=> '\'o2:',
  'p'	=> 'p \'e2:',
  'q'	=> 'k \'u2:',
  'r'	=> '\'ä3 r',
  's'	=> '\'ä s',
  't'	=> 't \'e2:',
  'u'	=> '\'u2:',
  'v'	=> 'v \'e2:',
  'w'	=> 'd "u $ b ë l $ v `e2:',
  'x'	=> '\'ä k s',
  'y'	=> '\'y2:',
  'z'	=> 's "ä2: $ t `a',
  'ä'	=> '\'ä2:',
  'å'	=> '\'å2:',
  'ö'	=> '\'ö2:',
};

is_deeply($testhash, $correcthash, "Populate from Legacy DB text dump");

# From /data/legacy/alphabetDB.txt
__DATA__
a	'a2:
b	b 'e2:
c	s 'e2:
d	d 'e2:
e	'e2:
f	'ä f
g	g 'e2:
h	h 'å2:
i	'i2:
j	j 'i2:
k	k 'å2:
l	'ä l
m	'ä m
n	'ä n
o	'o2:
p	p 'e2:
q	k 'u2:
r	'ä3 r
s	'ä s
t	t 'e2:
u	'u2:
v	v 'e2:
w	d "u $ b ë l $ v `e2:
x	'ä k s
y	'y2:
z	s "ä2: $ t `a
ä	'ä2:
å	'å2:
ö	'ö2:
