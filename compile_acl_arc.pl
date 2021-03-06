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

# BEGIN 
# {
	# if ($FindBin::Bin =~ /(.*)/) 
	# {
		# $path  = $1;
	# }
# }

use Getopt::Long;
use Archive::Tar;

### USER customizable section
$0 =~ /([^\/]+)$/; my $progname = $1;
my $outputVersion = "1.0";
### END user customizable section

sub License{
	#print STDERR "# Copyright 2014 \251 Muthu Kumar C\n";
}

sub Help{
	print STDERR "Usage: $progname -h\t[invokes help]\n";
  	print STDERR "       $progname [-q -debug]\n";
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

## directories with proceedings from ACL events.
my @topdirectories =('J','Q','P','E','N','S','A','K','W');

my $omni_total		= 0;
my $pdf_total		= 0;
my $parsCit_total	= 0;
	
foreach my $topdir (@topdirectories){
	if(! -e "$topdir"){
		next;
	}
	opendir(my $dirdh, "$topdir")
		or warn "can't open $topdir \n $!";
	my @year_dirs = readdir($dirdh);
	closedir $dirdh;
	
	foreach my $dir (@year_dirs){
		if (!defined $dir){die;}
		my $year_suffix;
		if($dir =~ /^[A-Z]([0-9][0-9])$/ ){
			$year_suffix = $1;
		}
		else{
			next;
		}
		
		my $pdf_count		= `ls -lR $topdir/$dir/*[0-9][0-9][0-9][0-9]\.pdf| wc -l`;
		my $omni_count		= `ls -lR $topdir/$dir/*[0-9][0-9][0-9][0-9]*omni*| wc -l`;

		$pdf_count			=~ s/\s(.*)\s/$1/;
		$omni_count			=~ s/\s(.*)\s/$1/;

		my $parsCit_count	= `ls -lR $topdir/$dir/*[0-9][0-9][0-9][0-9]*parscit\.130908\.xml| wc -l`;
		$parsCit_count		=~ s/\s(.*)\s/$1/;

		$omni_total			+= $omni_count;
		$pdf_total			+= $pdf_count;
		$parsCit_total		+= $parsCit_count;

		print "\n$dir \t #PDF: $pdf_count \t #Omni:$omni_count \t #parsCit:$parsCit_count";
		
		#my $omni_list 		= `ls -R $topdir/$dir/*omni*`;
		#my @omni_files		= split ( /\s/, $omni_list);
		#my $omnitar		= Archive::Tar->new;
		#$omnitar->add_files(@omni_files);
		#$omnitar->write($dir.'.tgz', COMPRESS_GZIP);
		
		my $pdftar			= Archive::Tar->new;
		my $pdf_list 		= `ls -R $topdir/$dir/*[0-9][0-9][0-9][0-9]\.pdf`;
		my @pdf_files		= split ( /\s/, $pdf_list);
		$pdftar->add_files(@pdf_files);
		$pdftar->write($dir.'.tgz', COMPRESS_GZIP);
		
		#my $parsCittar		= Archive::Tar->new;
		#my $parsCit_list 	= `ls -R $topdir/$dir/*[0-9][0-9][0-9][0-9]*parscit\.130908\.xml`;
		#my @parsCit_files	= split ( /\s/, $parsCit_list);
		#$parsCittar->add_files(@parsCit_files);
		#$parsCittar->write($dir.'.tgz', COMPRESS_GZIP);
	}
}
print "\n$pdf_total\t$omni_total \t $parsCit_total";
