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

# read from config file for top level directories
#my @topdirectories =('A','H','M','T','X','N','I','R','J','W','E','L','P','C','S','K','F','D','O','U','Q','Y');
my @topdirectories =('Y','R','U','W','D','J','S');

foreach my $dir (@topdirectories){
	my $pdf_count = `ls -R $dir/*15/*[0-9][0-9][0-9][0-9]\.pdf| wc -l`;
	my $omni_count = `ls -R $dir/*15/*[0-9][0-9][0-9][0-9]*omni*| wc -l`;
	#$pdf_count = trim($pdf_count);
	#$omni_count = trim($omni_count);
	$pdf_count	=~ s/\s(.*)\s/$1/;
	$omni_count =~ s/\s(.*)\s/$1/;
	print "\n$dir \t #PDF: $pdf_count \t #Omni:$omni_count";
	
	if ($omni_count >= $pdf_count){
		next;
	}

	my $pdf_list = `ls -R $dir/*15/*[0-9][0-9][0-9][0-9]\.pdf`;
	my @pdf_files = split ( /\s/, $pdf_list);
	
	my $omni_list = `ls -R $dir/*15/*omni*`;
	my @omni_files = split ( /\s/, $omni_list);
	foreach my $pdf_file ( @pdf_files ){
		my $basename = (split(/\//,$pdf_file))[2];
		$basename =~ s/\.pdf//;
		my $omni_output_file = $basename."-omni.xml";
		
		my $basedir = (split(/\//,$pdf_file))[1];
                #print "\n $basedir \n";

		#my $cmd = "ls -l $dir/$basedir/$omni_output_file";
		#my $exit_status = system($cmd);
		#Failure
		#if ($exit_status ne 0){
		if(! -f "$dir/$basedir/$omni_output_file"){
			print "\n \"$dir/$basedir/$omni_output_file\" does not exist";
			print "\n $pdf_file \t $omni_output_file";
			#call omnipage
			print "\nCalling Omnipage";
			my $omni_cmd = "/home/cmkumar/local/bin/ocr/bin/ocr $pdf_file $dir/$basedir/$omni_output_file xml tpe.ddns.comp.nus.edu.sg:31586";
			print "\n$omni_cmd\n";
			my $omni_exit_status = system($omni_cmd);
			if($omni_exit_status ne 0){
				print "\n$omni_output_file Failed";
			}
			else{
				print "\n $omni_output_file Success";
			}
			
		}
	}
}
