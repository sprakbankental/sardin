package MTM::Pronunciation::Espeak;

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

use File::Which;

my $espeak_cmd="espeak-ng";

# espeakExists checks if the espeak software is installed. Returns 1
# if there is an external command corresponding to $espeak_cmd, 0
# otherwise.
sub espeakExists{
   if (which($espeak_cmd)) {
	return 1;
   }
   return 0;
};

# espeak performs a call to external command espeak-ng
sub espeak{
   (my $lang, my $text) = @_;
   # my $symSet = '--ipa';   
   # if ($symSet eq "ipa") {
   # 	$symSet = '--' . $symSet;
   # } else { # NL TODO
   # 	$symSet = '';
   # }
   
   my $cmd = "$espeak_cmd -q -v $lang --ipa -x \"$text\"" ;

   #print STDERR "G2P cmd $cmd\n";
   
   my $res = eval{
	`$cmd` || die "Can't exec $cmd";
   };
   if ($@) { # NL TODO is this a reasonable way to handle eval failures? 
	return ($res, $@);
   };

   #print "eval res $res\n";
   
   chomp($res);
   return ($res, undef);
}

1;
