package MTM::SSML::SSML_vars;

#*****************************************************************#
# ssml_vars.pm
#
# Variables for SSML
#
#*****************************************************************#
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


# <s> start and end tags
my $ssml_start = '<s:speak xml:lang="SV" version="1.0">';
my $ssml_end = '</s:speak>';

# <span> start and end tags
my $span_start = '<span class="sentence">';
my $span_end = '</span>';


# Header (MTM)
our $header_txt = "<\?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE dtbook PUBLIC \"-//NISO//DTD dtbook 2005-3//EN\" \"http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd\" [
           <!ENTITY % SSML.prefixed \"INCLUDE\">
           <!ENTITY % SSML.prefix \"s\">
           <!ENTITY % ssmlspeak PUBLIC \"-//MTM//DTD SYNTHESIS 1.0//EN\"
          \"http://pipeutv1.mtm.se/TR/speech-synthesis/synthesis-mtm.dtd\">
           %ssmlspeak;
           <!ENTITY % externalFlow \"| s:speak\">
           <!ENTITY % externalNamespaces \"xmlns:s CDATA #FIXED 'http://pipeutv1.mtm.se/TR/speech-synthesis/synthesis-mtm.dtd'\">
]>
<dtbook xmlns=\"http://www.daisy.org/z3986/2005/dtbook/\" version=\"2005-3\" xml:lang=\"sv\" xmlns:s=\"http://pipeutv1.mtm.se/TR/speech-synthesis/synthesis-mtm.dtd\">";
#************************************************************#
1;