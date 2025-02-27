package SBTal::Config::Examples::SardinVAC;

# SBTal boilerplate
use v5.32;
use utf8;
use strict;
use autodie;
use warnings;
use warnings	 qw< FATAL  utf8 >;
use open		  qw< :std  :utf8 >;	  # Should perhaps be :encoding(utf-8)?
use charnames	qw< :full :short >;	 # autoenables in v5.16 and above
use feature	  qw< unicode_strings >;
no feature		qw< indirect >;
use feature	  qw< signatures >;
no warnings	  qw< experimental::signatures >;

use Carp		  qw< carp croak confess cluck >;

use version 0.77; our $VERSION = version->declare('v0.1.0');

# Smart comments are used as follows in SBTal
# ###	 Flow, progress and light variables
# ####	Large variables
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

use Log::Any qw($log);
use Log::Any::Adapter;
# Log to STDERR and set log level
Log::Any::Adapter->set('Stderr', log_level => 'trace');
#Log::Any::Adapter->set('Stderr', log_level => 'info');

use SBTal::Config;

# =====================================================================
#
# Module implementation
#
# =====================================================================
# ---------------------------------------------------------------------
# Object construction
#
# Minimal construction from class or object
#
# This is hacky use of SBTal::Config in the current version,
# squeezed out to test principles in an initial release.
# The API should stay the same, but the code needs a lot of work
# to actually use SBTal::Config properly
# SBTal::Config::DataDumper->new(%params)
sub new ($proto, %params) {
	### Entering new: $proto
	### Params: %params
	my $class = ref($proto)||$proto;
	my $self = {};
	bless $self, $class;
	$self->_init(%params);
	### Leaving new: $self
	return $self;
}
#
# ***
# $self->_init()
# Parameter treatment, validation
	sub _init ($self, @params) {
	# Specify validator here (state ensures this only happens once)
	state $spec = {
		cmdpath => {
			type => Params::Validate::SCALAR,
			optional => 0,
		},
	};
	my %valid = Params::Validate::validate(@params, $spec);
	%{ $self } = %valid;
	$self->_setupparser();

#	if (exists($parser->data->{test})) {
#		test();
#		exit;
#	}
#	use Data::Dumper; print STDERR Dumper $self; exit;
	return $self;
}


sub build ($self) {
	my $data = $self->{parser}->{data};
	$log->trace('Build command') if $log->is_trace;
	my $cmdline = [qw(perl)]; # This just sets up the 'perl' call that starts the command
	foreach my $cmdtype (qw(cmdtype cmd)) {
		unless (exists($data->{$cmdtype})) {
			$log->fatal("Missing --$cmdtype argument");
			die("Missing --$cmdtype argument\n");
		}
	}
	
	if ($data->{cmdtype} eq 'analysis') {
		# OLD	perl findOOV.pl <infile> <outfile> <statfile> <lang>
		# NEW	perl vac-sardin-launcher.pl --cmdtype "analysis" --cmd "oov" --lang <lang> --infile <infile> --outfile <outfile> --statfile <statfile>
		if ($data->{cmd} eq 'oov') {
			$log->trace("Found '$data->{cmd}' command");
			$self->_addscript($cmdline, qw(findOOV.pl));
			$self->_addargs($data, $cmdline, qw(infile outfile statfile lang)),
		} else {
			$log->fatal("Unknown --cmd argument '$data->{cmd}'");
			die("Unknown --cmd argument '$data->{cmd}'\n");	
		}
	}
	elsif ($data->{cmdtype} eq 'validation') {
		# OLD	perl validateCereprocTranscription.pl <pron> <orth> <pronlang> <pos> <decomp>
		# NEW	perl vac-sardin-launcher.pl --cmdtype "validation" --cmd "pron" --format "cereproc" --orth <orth> --pron <pron> --pronlang <pronlang> --pos <pos> --decomp <decomp>
		# NEW NEW	perl vac-sardin-launcher.pl --cmdtype "validation" --cmd "pron" --format "cereproc" --orth <orth> --pron <pron> --pronlang <pronlang> --pos <pos> --decomp <decomp> --lang <=pronlang>

		if ($data->{cmd} eq 'pron') {
			$log->trace("Found '$data->{cmd}' command");
			$self->_addscript($cmdline, qw(validateBaseTranscription.pl));
			$self->_addargs($data, $cmdline, qw(format pron orth pronlang pos decomp)),
		} else {
			$log->fatal("Unknown --cmd argument '$data->{cmd}'");
			die("Unknown --cmd argument '$data->{cmd}'\n");	
		}
	}
	elsif ($data->{cmdtype} eq 'insertion') {
		# OLD	perl InsertionSubs/approvedInsertion_en.pl <orth> <user> <timestamp>
		# NEW	perl vac-sardin-launcher.pl --cmdtype "insertion" --cmd "approved" --lang "en" --orth <orth> --user <user> --timestamp <timestamp>
		# OLD	perl InsertionSubs/approvedInsertion_sv.pl <orth> <user> <timestamp>
		# NEW	perl vac-sardin-launcher.pl --cmdtype "insertion" --cmd "approved" --lang "sv" --orth <orth> --user <user> --timestamp <timestamp>
		if ($data->{cmd} eq 'approved') {
			$log->trace("Found '$data->{cmd}' command");
			# NB! There's no test to see that lang is exactly 'sv' or 'en', but we'll do without - it's a transition solution in any case
			my $script = 'approvedInsertion_' . $data->{lang} . '.pl';
			$self->_addscript($cmdline, $script);
			$self->_addargs($data, $cmdline, qw(orth user timestamp)),
		# OLD	perl InsertionSubs/reportInsertion.pl <orth> <pron> <lang> <user> <timestamp>
		# NEW	perl vac-sardin-launcher.pl --cmdtype "insertion" --cmd "report" --lang "sv" --orth <orth> --pron <pron> --user <user> --timestamp <timestamp>
		} elsif ($data->{cmd} eq 'report') {
			$log->trace("Found '$data->{cmd}' command");
			$self->_addscript($cmdline, 'reportInsertion.pl');
			$self->_addargs($data, $cmdline, qw(orth pron lang user timestamp)),
		# OLD	perl InsertionSubs/textLexiconInsertion.pl <orth> <exp> <no_break_flag> <lang> <user> <timestamp>
		# NEW	perl vac-sardin-launcher.pl --cmdtype "insertion" --cmd "text" --lang <lang> --orth <orth> --exp <exp> --if-final-not-abbr <no_break_flag> --user <user> --timestamp <timestamp>
		} elsif ($data->{cmd} eq 'text') {
			$log->trace("Found '$data->{cmd}' command");
			$self->_addscript($cmdline, 'textLexiconInsertion.pl');
			$self->_addargs($data, $cmdline, qw(orth exp if-final-not-abbr lang allow-append user timestamp pronstatus)),
		} elsif ($data->{cmd} eq 'pron') {
			$log->trace("Found '$data->{cmd}' command");
			my $script;
			if ($data->{lang} eq 'en') {
				$script = 'userLexiconInsertion_en.pl'
			}
			else {
				$script = 'userLexiconInsertion.pl';
			}
			$self->_addscript($cmdline, $script);
			$self->_addargs($data, $cmdline, qw(orth pron pos orthlang pronlang exp decomp docfreq user allow-append timestamp pronstatus)),
		} elsif ($data->{cmd} eq 'textpron') {
			$log->trace("Found '$data->{cmd}' command");
			$self->_addscript($cmdline, 'textLexiconAndUserLexiconInsertion.pl');
			$self->_addargs($data, $cmdline, qw(orth pron pos orthlang pronlang exp decomp docfreq user if-final-not-abbr allow-append timestamp lang pronstatus)),
		} else {
			$log->fatal("Unknown --cmd argument '$data->{cmd}'");
			die("Unknown --cmd argument '$data->{cmd}'\n");
		}

	# Add rest here (issue 154)
	} elsif ($data->{cmdtype} eq 'conversion') {
	# OLD perl lib/MTM/MTMInternal/VAC/prepare_pron_for_cereproc.pl <pron>
	# NEW perl --cmdtype convert --cmd cereproc-list --pron <pron>
		if ($data->{cmd} eq 'cereproc-list') {
			
			
			$log->trace("Found '$data->{cmd}' command");
			$self->_addscript($cmdline, 'prepare_pron_for_cereproc.pl');
			$self->_addargs($data, $cmdline, qw(pron pronlang)),

			my $p = _addargs($data, $cmdline, qw(pron)),
			
#			print STDERR "UOUOUOUO $p\n";
			
			#my $pl = _addargs($data, $cmdline, qw(pron)),
			
		} else {
			$log->fatal("Unknown --cmd argument '$data->{cmd}'");
			die("Unknown --cmd argument '$data->{cmd}'\n");
		}
	} else {
		$log->fatal("Unknown --cmdtype argument '$data->{cmdtype}'");
		die("Unknown --cmdtype argument '$data->{cmdtype}'\n");
	}
	
	use Data::Dumper;
	$log->trace(Dumper $cmdline) if $log->is_trace;
	$log->trace('Command built') if $log->is_trace;
	$self->{cmdline} = $cmdline;
	return wantarray?@$cmdline:return join(' ', @$cmdline);
}

# Note that we're not using SBTal::Config to its full potential here.
# A lot of this functionality should be moved back to that module,
# possibly by using two layers of command line parsing.
# There may still be a bug in that code though, and also there
# are a few outstanding design decisions left, so we'll put more of the
# code than necessary here in the launcher script for this first version.
sub _addargs ($self, $data, $cmdline, @args) {
	foreach my $arg (@args) {
		
		if (exists($data->{$arg})) {
			push @$cmdline, $data->{$arg};
		} else {
			$log->fatal("Missing --$arg argument");
			die("Missing --$arg argument\n");
		}
	}
}
sub _addscript ($self, $cmdline, @script) {
	push @$cmdline, File::Spec->catfile($self->{cmdpath}, @script);
}


sub parse ($self, $data) {
	$log->trace('Parse command line') if $log->is_trace;
	$self->{parser}->toconf(argv=>$data);
	$log->trace('Command line parsed') if $log->is_trace;
}

sub _setupparser ($self) {
	$log->trace('Create command line parser') if $log->is_trace;
	my $defaultoptions = {
		verbose => 1,
		debug	=> 0,
		lang => 'se',
	};
	my @spec = (
		'cmdtype=s',			  # analysis
		'cmd=s',					# oov
	'format=s',				# <format>
		'lang=s',				  # <lang>
		'infile=s',				# <infile>
		'outfile=s',			  # <outfile>
		'statfile=s',			 # <statfile>
		'orth=s',				  # <orth>
		'pron=s',				  # <pron>
		'pronlang=s',			 # <pronlang>
		'orthlang=s',			 # <ortlang>
		'docfreq=s',			  # <freq>
		'pos=s',					# <pos>
		'decomp=s',				# <decomp>
		'user=s',				  # <user>
		'timestamp=s',			# <timestamp>
		'exp=s',					# <exp>
		'if-final-not-abbr=s', # <no_break_flag>
		'pronstatus=s',		  # <status>
		'allow-append=s',		# <override_flag>
		'action=s',				# printout|execute
		'test=s@',				 #
	);
	my $c = SBTal::Config->new(
		defaults		=> $defaultoptions,
		specification => \@spec,
	);
	$log->trace('Command line parser created') if $log->is_trace;
	return $self->{parser} = $c;
}

# ---------------------------------------------------------------------
# Methods
#




1;

__END__