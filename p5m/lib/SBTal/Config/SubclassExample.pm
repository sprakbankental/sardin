package SBTal::Config::SubclassExample;

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
# We use Params::Validate for parameter validation in our methods;
use Params::Validate 1.30 qw();

use SBTal::Config {podfrom=>__PACKAGE__};
use parent -norequire, qw(SBTal::Config);

=pod

=head1 NAME

SBTal::Config::SubclassExample

=head1 DESCRIPTION

Example of thin subclass containing settings and POD for
scripts using SBTal::Config configuration.


