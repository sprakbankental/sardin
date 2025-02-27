package  MTM::Expansion::AbbreviationExpansion;

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


#**************************************************************#
# Abbreviation
#
# Language	sv_se
#
# Rules for abbreviation expansions
#
# Return: expansion
#
# (c) Swedish Agency for Accessible Media, MTM 2021
#**************************************************************#
sub expand {
	my $self = shift;
	my $chunk = shift;

	my $t = $self->{LEGACYDATA};

	if(
		&MTM::Legacy::isDefault( $t->{exp} ) eq '-'
		||
		$t->{exp} eq '<none>'		# Field is blocked, e.g. when '§' or 'kap.' are moved to beginning of law reference expression.
	) {
		return $self;
	}

	# Swedish
	# jan.-apr.
	if(
		$MTM::Vars::lang eq 'sv'
		&&
		$t->{exprType} =~ /(DATE|INTERVAL)/
		&&
		$t->{orth} =~ /^($MTM::Vars::sv_month_abbreviation|$MTM::Vars::sv_weekday_abbreviation)$/i
	) {
		my $lc = MTM::Case::makeLowercase( $1 );



		#while(my($k,$v)=each(%MTM::Vars::sv_weekday_abbreviation)){print"$k\t$v\n";}

		if( exists( $MTM::Vars::sv_month_abbreviation{ $lc } )) {
			$t->{exp} = $MTM::Vars::sv_month_abbreviation{ $lc };

		} elsif( exists( $MTM::Vars::sv_weekday_abbreviation{ $lc } )) {
			$t->{exp} = $MTM::Vars::sv_weekday_abbreviation{ $lc };
		}

	# English
	} elsif(
		$MTM::Vars::lang eq 'en'
		&&
		(
			$t->{exprType} =~ /(DATE|INTERVAL)/
			&&
			$t->{orth} =~ /^($MTM::Vars::en_month_abbreviation|$MTM::Vars::en_weekday_abbreviation)$/i
		)
	) {
		my $lc = MTM::Case::makeLowercase( $1 );

		# while(my($k,$v)=each(%MTM::Vars::en_month_abbreviation)){print STDERR "$k\t$v\n";}

		if( exists( $MTM::Vars::en_month_abbreviation{ $lc } )) {
			$t->{exp} = $MTM::Vars::en_month_abbreviation{ $lc };
		} elsif( exists( $MTM::Vars::en_weekday_abbreviation{ $lc } )) {
			$t->{exp} = $MTM::Vars::en_weekday_abbreviation{ $lc };
		}
	}
	return $self;
}
#**************************************************************#
1;
