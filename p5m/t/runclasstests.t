#!/usr/bin/perl -w

use v5.32;                    # We assume pragmas and such from 5.32.0
# This is loaded at the end of the script in order to allow "done_testing"
#use Test::More tests=>3241;   # Explicitly load modules - no Test::Most
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

use lib 't/classtests';

# 220922: The tests are undergoing a structural overhaul as a
# step towards a stable release. The following improvements 
# should apply to each test that's been fixed:
# - Can be executed using 'prove'
# - Can be executed in bulk
# - Loads the libraries to be tested auomatically
# - Contains the SBTal boilerplate code, to deal with e.g. encoding
# - Is sturctured into Class test subs and subtests
# In some cases, we're also making the tests a little
# more programmatic, in order to make extensions
# easier and faster.
#
# These are the modules we test
use Test::MTM;                                             # 220922 Dolled up to use new ClassTestBase
use Test::MTM::Tie::CursorArray;                           # 220922 Dolled up to use new ClassTestBase
use Test::MTM::TTSNodeFactory;                             # 221102 Dolled up to utilise Test::Class
use Test::MTM::TTSPreprocessor;                            # 220922 Dolled up to use new ClassTestBase
use Test::MTM::TTSDocument;                                # 221102 Dolled up to utilise Test::Class

### 210831 We test tagger in POSTagger.pm termporarily.	use Test::MTM::TPBTag;


use Test::MTM::TTSDocument::SplitSentence;                 # 220922 Dolled up to utilise Test::Class

# SplitTokens
use Test::MTM::Tokenisation::SplitTokens;                  # 220922 Dolled up to utilise Test::Class

# Legacy
use Test::MTM::Legacy;                                     # 220922 Dolled up to utilise Test::Class

# PoS tagger
use Test::MTM::POSTagger;                       # 220922 Dolled up to utilise Test::Class

# Markup
use Test::MTM::Analysis::Reference;
use Test::MTM::Analysis::Abbreviation;
use Test::MTM::Analysis::Initial;
use Test::MTM::Analysis::Date;
use Test::MTM::Analysis::Time;
use Test::MTM::Analysis::Email;
use Test::MTM::Analysis::URL;
use Test::MTM::Analysis::Filename;
use Test::MTM::Analysis::RomanNumber;
use Test::MTM::Analysis::Acronym;
use Test::MTM::Analysis::Decimal;
use Test::MTM::Analysis::PhoneNumber;
### No tests in file:	use Test::MTM::Analysis::Ordinal;
use Test::MTM::Analysis::Year;
use Test::MTM::Analysis::Interval;
use Test::MTM::Analysis::Currency;
use Test::MTM::Analysis::LanguageDetection2;

# Expansion
use Test::MTM::Expansion::ReferenceExpansion;
use Test::MTM::Expansion::CharacterExpansion;
use Test::MTM::Expansion::NumeralExpansion;
use Test::MTM::Expansion::AbbreviationExpansion;


# Pronunciation
use Test::MTM::Pronunciation;				# 220922 Dolled up to utilise Test::Class
use Test::MTM::Pronunciation::Autopron;			# 220922 Dolled up to utilise Test::Class
use Test::MTM::Pronunciation::AutopronEspeak;		# 240510

# Conversion	240816
### CT241217 use Test::MTM::Pronunciation::Conversion::ACA;
### CT241217 use Test::MTM::Pronunciation::Conversion::CP;
### CT241217 use Test::MTM::Pronunciation::Conversion::CP_EN;
### CT241217 use Test::MTM::Pronunciation::Conversion::IPA;
### CT241217 use Test::MTM::Pronunciation::Conversion::TPA;

# Validation	240816
### CT241217 use Test::MTM::Pronunciation::Validation::Base;
### CT241217  use Test::MTM::Pronunciation::Validation::ACA;
### CT241217 use Test::MTM::Pronunciation::Validation::CP;
### CT241217 use Test::MTM::Pronunciation::Validation::CP_EN;
### CT241217 use Test::MTM::Pronunciation::Validation::IPA;
### CT241217 use Test::MTM::Pronunciation::Validation::TPA;



# Pause
use Test::MTM::Pause;


# NB!!! Ugly trick until we can get test plans sorted
use Test::More;
done_testing();
