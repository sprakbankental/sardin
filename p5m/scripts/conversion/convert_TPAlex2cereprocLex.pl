#!/usr/bin/perl -w
#**************************************************************#
# Convert TPAdictionary.txt to acapelaDictionary.txt
#
# TPA -> Base -> ACA
# 
# CT 2024
#**************************************************************#
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

#**************************************************************#
use MTM::Pronunciation::Conversion::TPA;
use MTM::Pronunciation::Conversion::ACA;
use MTM::Pronunciation::Validation::ACA;

my %aca = ();
&read_acapelaDictionary();

open my $fh_in, "data/dictionaries/TPAdictionary.txt";
open my $fh_out, ">data/dictionaries/ACA_TPAdictionary.txt";

my $i = 0;
while(<$fh_in>) {
	chomp;
	my $line = $_;
	
	next if $line =~ /^\s*\#/;
	$i++;
	
	my( $orth, $pron, $pos, $ortlang, $pronlang, $case, $decomp, $status, $comment ) = split/\t/, $line;

	my $Base_pron = MTM::Pronunciation::Conversion::TPA->decode( $pron, $pos );
	
	my $ACA_pron = MTM::Pronunciation::Conversion::ACA->encode( $Base_pron, $orth, $pos );

	my $validated = MTM::Pronunciation::Validation::ACA->validate( $ACA_pron );

	if( $validated !~ /^VALID/ ) {
		print STDERR "$orth	$pron	$Base_pron	$ACA_pron	$validated\n";	
	} else {
		
		# Compare to original acapelaDictionary (test that perhaps shouldn't be repeated).
		#my $newline = "$orth	$ACA_pron	$case";
		#if( exists( $aca{ $i } )) {
		#	if( $aca{ $i } ne $newline ) {
		#		print STDERR "DIFF\naca $aca{ $i }\nnew $newline\n\n";
		#	}
		#} else {
		#	print STDERR "no $i\n";
		#}
		print $fh_out "$orth\t$ACA_pron\t$case\n";
	}
}
#**************************************************************#
sub read_acapelaDictionary {
	open my $fh_aca, "data/dictionaries/acapelaDictionary.txt";
	my $i = 0;
	while(<$fh_aca>) {
		chomp;
		$i++;
		my $line = $_;
		$aca{ $i } = $line;
	}
}
#**************************************************************#
