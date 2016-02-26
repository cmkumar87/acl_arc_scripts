#!/usr/bin/perl -w
use strict;
require 5.0;

##
#
# Author : Muthu Kumar C
# Created in Feb, 2015
#
##

my $path;	# Path to binary directory

#BEGIN 
#{
#	if ($FindBin::Bin =~ /(.*)/) 
#	{
#		$path  = $1;
#	}
#}

#use String::Util 'trim';
use Getopt::Long;

### USER customizable section
$0 =~ /([^\/]+)$/; my $progname = $1;
my $outputVersion = "1.0";
### END user customizable section

sub License{
	#print STDERR "# Copyright 2014 \251 Muthu Kumar C\n";
}

sub Help{
	print STDERR "Usage: $progname -h\t[invokes help]\n";
  	print STDERR "       $progname [-stem -q -debug]\n";
	print STDERR "Options:\n";
	print STDERR "\t-q \tQuiet Mode (don't echo license).\n";
	print STDERR "\t-debug \tPrint additional debugging info to the terminal.\n";
}

my $help	= 0;
my $quite	= 0;
my $debug	= 0;

$help = 1 unless GetOptions(
				'debug'		=> \$debug,
				'h' 		=> \$help,
				'q' 		=> \$quite
			);
		
if ( $help ){
	Help();
	exit(0);
}

if (!$quite){
	License();
}


chdir("/home/antho/public_html/");
my $writedir = "/mnt/compute/muthu/antho_pdf2xml";
# read from config file for top level directories
#my @topdirectories =('A','H','M','T','X','N','I','R','J','W','E','L','P','C','S','K','F','D','O','U','Q','Y');
my @topdirectories =('Y','R','U','W','D','J','S');
my $omni_total		= 0;
my $pdf_total		= 0;
my $parsCit_total	= 0;

foreach my $dir (@topdirectories){
	if(! -e "$writedir/$dir"){
		print "creating dir \"$writedir/$dir\" ";
		mkdir("$writedir/$dir");
	}
	my $pdf_count = `ls -lR $dir/*15/*[0-9][0-9][0-9][0-9]\.pdf| wc -l`;
	my $omni_count = `ls -lR $dir/*15/*[0-9][0-9][0-9][0-9]*omni*| wc -l`;

	$pdf_count	=~ s/\s(.*)\s/$1/;
	$omni_count	=~ s/\s(.*)\s/$1/;

	my $parsCit_count	= `ls -lR $writedir/$dir/*15/*[0-9][0-9][0-9][0-9]*parscit*| wc -l`;
	$parsCit_count	=~ s/\s(.*)\s/$1/;

	$omni_total	+= $omni_count;
	$pdf_total	+= $pdf_count;
	$parsCit_total	+= $parsCit_count;

	print "\n$dir \t #PDF: $pdf_count \t #Omni:$omni_count \t #parsCit:$parsCit_count";
	
	my $omni_list = `ls -R $dir/*15/*omni*`;
	my @omni_files = split ( /\s/, $omni_list);
	foreach my $omni_file (@omni_files){
		my $basename = (split(/\//,$omni_file))[2];
		$basename =~ s/\-omni\.xml//;
		my $parscit_output_file = $basename."-parscit.130908.xml";
		
		my $basedir = (split(/\//,$omni_file))[1];
       		#print "\n $basedir \n";
		
		if(! -e "$writedir/$dir/$basedir"){
			mkdir("$writedir/$dir/$basedir");
		}
		
		if(! -f "$omni_file"){
			print "\n Omni file: \"$omni_file\" not found";
			exit(0);
		}
		
		#Failure
		if(! -f "$writedir/$dir/$basedir/$parscit_output_file"){
			print "\n creating \"$writedir/$dir/$basedir/$parscit_output_file\"";
			print "\n $omni_file \t $parscit_output_file";
			#call parscit
			print "\nCalling parscit";
			my $parscit_cmd = "/home/wing.nus/tools/citationTools/parscit/bin/citeExtract.pl -m extract_all -i xml $omni_file $writedir/$dir/$basedir/$parscit_output_file";
			print "\n$parscit_cmd\n";
			my $parscit_exit_status = system($parscit_cmd);
			if($parscit_exit_status ne 0){
				print "\n$parscit_output_file Failed";
			}
			else{
				print "\n $parscit_output_file Success";
			}
			
		}
	}
}

print "\n$pdf_total\t$omni_total \t $parsCit_total";
