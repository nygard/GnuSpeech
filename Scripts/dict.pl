#!/usr/bin/perl

use strict;
use English;

#use Cwd;
#use POSIX qw(strftime);
use Getopt::Std;
use File::Basename;
#use Data::Dumper;

my %opts;
my %keys;

getopts('v', \%opts);

if (scalar @ARGV < 1) {
    my $short_program_name = basename($PROGRAM_NAME);

    print "$short_program_name 1.0 (2004-04-03)\n";
    print "Usage: $short_program_name <dictionary>\n\n";
    exit 0;
}

my %dictionary;
my %suffixes;
my @suffix_order;

&load_dictionary($ARGV[0]);
&load_suffixes();

#my $line = <STDIN>;
#chomp($line);
#$line = "The quick brown fox jumped over the lazy dog.";
my $line = "The quick brown fox jumped over the lazy dog";
print "line: '$line'\n";
&process($line);

sub load_dictionary {
    my $filename = shift;
    my $key;
    my $value;

    print "file: $filename\n";
    open(MAINDICT, $filename) || die "Couldn't open file: $filename";
    while (<MAINDICT>) {
	chomp;
	($key, $value) = split(/ /);
	# Strip off part of speech information from key
	$key =~ s|/([a-z]*)||g;
	# Strip off trailing percent stuff from value -- I'm not sure if or how it is used.
	$value =~ s/%.*//g;
	#print "removed part of speech: $1\n";
	if ($dictionary{$key} && $opts{'v'}) {
	    print "Replacing value for $key, old value: $dictionary{$key}, new value: $value\n";
	}
	$dictionary{$key} = $value;
    }
    close(MAINDICT);
}

sub load_suffixes {
    my $line;

    open(SUFFIXES, "suffix_list.txt") || die "Couldn't open suffix_list.txt";
    while ($line = <SUFFIXES>) {
	chomp($line);
#	print "line: $line\n";
	if ($line =~ /^[a-z]/) {
	    my ($suffix, $replacement, $tail_pronunciation) = split(/\t/, $line);
#	    print "$suffix, $replacement, $tail_pronunciation\n";
	    $suffixes{$suffix} = [$replacement, $tail_pronunciation];
	    push(@suffix_order, $suffix);
	}
    }
    close(SUFFIXES);
}

sub process {
    my $line = shift;
    my @words;
    my $word;
    my @prons;

    @words = split(/ +/, $line);
    foreach my $word (@words) {
	my $pronunciation;

	$word = lc $word;
	$pronunciation = &lookup_word($word);
#	print "word: '$word' -> $pronunciation\n";
	push(@prons, $pronunciation);
    }

    print join(" ", @prons), "\n";
}

sub lookup_word {
    my $word = shift;
    my $pronunciation;
    my $base_pron;

    $pronunciation = $dictionary{$word};
    if (!defined($pronunciation)) {
#	print "Couldn't find pronunciation for $word, checking suffixes...\n";
	for my $suffix (@suffix_order) {
	    if ($word =~ /^(.+)$suffix$/) {
		my $base = $1;
		my $array_ref = $suffixes{$suffix};
		my  ($replace, $tail) = @$array_ref;
#		print "base: $base\n";
#		print "suffix: $suffix, replace: '$replace', tail: '$tail'\n";
		$base .= $replace;
#		print "base now: $base\n";
#		print "matched suffix $suffix, base: $base\n";
		$base_pron = $dictionary{$base};
		if (defined($base_pron)) {
		    return $base_pron . $tail;
		}
	    }
	}
    }

    $pronunciation;
}
