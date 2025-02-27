#!/usr/bin/perl -w
#**************************************************************#
# Convert TPAdictionary.txt to cppelaDictionary.txt
#
# TPA -> Base -> cp
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
use MTM::Pronunciation::Conversion::base;
use MTM::Pronunciation::Conversion::CP;
use MTM::Pronunciation::Validation::CP;

my %cp = ();
&read_cereprocDictionary();

open my $fh_in, "data/dictionaries/TPADictionary.txt";
open my $fh_out, ">data/dictionaries/CP_TPAdictionary.txt";

my $i = 0;
while(<$fh_in>) {
	chomp;
	my $line = $_;
	
	next if $line =~ /^\s*\#/;
	$i++;
	
	my( $orth, $pron, $pos, $ortlang, $pronlang, $case, $decomp, $status, $comment ) = split/\t/, $line;

	my $Base_pron = MTM::Pronunciation::Conversion::CP->decode( $pron, $pos );
	
	my $CP_pron = MTM::Pronunciation::Conversion::CP->encode( $Base_pron, $orth, $pos );

	my $validated = MTM::Pronunciation::Validation::CP->validate( $CP_pron );

	if( $validated !~ /^VALID/ ) {
		print STDERR "$orth	$pron	$Base_pron	$CP_pron	$validated\n";	
	} else {
		
		# Compare to original cppelaDictionary (test that perhaps shouldn't be repeated).
		#my $newline = "$orth	$CP_pron	$case";
		#if( exists( $cp{ $i } )) {
		#	if( $cp{ $i } ne $newline ) {
		#		print STDERR "DIFF\ncp $cp{ $i }\nnew $newline\n\n";
		#	}
		#} else {
		#	print STDERR "no $i\n";
		#}
		print $fh_out "$orth\t$CP_pron\t$case\n";
	}
}
#**************************************************************#
sub read_cereprocDictionary {
	open my $fh_cp, "data/dictionaries/cereprocDictionary.txt";
	my $i = 0;
	while(<$fh_cp>) {
		chomp;
		$i++;
		my $line = $_;
		$cp{ $i } = $line;
	}
}
#**************************************************************#
