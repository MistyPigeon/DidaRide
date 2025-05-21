#!/usr/bin/perl
# packager.pl
# A Perl script (134 lines) to package a file/folder into a .zip or .exe (self-extracting archive)
# Usage:
#   perl packager.pl --input <file_or_dir> --output <output_file> [--exe]
#   If --exe is given, output will be a self-extracting .exe (requires zip & zip2exe or 7zS.sfx)

use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use File::Basename;
use File::Temp qw(tempfile tempdir);
use File::Copy;
use Cwd 'abs_path';

my $input;
my $output;
my $make_exe = 0;
my $help = 0;

sub print_help {
    print <<"USAGE";
packager.pl - Package a file or directory into a ZIP archive (and optionally EXE)

Usage:
  perl packager.pl --input <file_or_dir> --output <output_file> [--exe]
Options:
  --input    Path to input file or directory to package
  --output   Path to output .zip or .exe file
  --exe      Create a self-extracting exe (Windows; requires 7z/zip2exe)
  --help     Show this help

Examples:
  perl packager.pl --input project/ --output project.zip
  perl packager.pl --input script.py --output script.zip
  perl packager.pl --input project/ --output project.exe --exe

USAGE
}

GetOptions(
    'input=s'  => \$input,
    'output=s' => \$output,
    'exe'      => \$make_exe,
    'help'     => \$help,
) or die("Error in command line arguments\n");

if ($help || !defined $input || !defined $output) {
    print_help();
    exit 1 unless $help;
    exit 0;
}

# Ensure input exists
$input = File::Spec->rel2abs($input);
die "Input file or directory '$input' not found.\n" unless -e $input;

# Detect output type
my $is_zip = ($output =~ /\.zip$/i) ? 1 : 0;
my $is_exe = ($output =~ /\.exe$/i) ? 1 : 0;
$is_exe = 1 if $make_exe;

# Temp zip file if needed
my $zipfile;
if ($is_zip && !$is_exe) {
    $zipfile = $output;
} else {
    my ($fh, $tmpzip) = tempfile(SUFFIX => '.zip');
    $zipfile = $tmpzip;
    close $fh;
}

# Create zip archive
print "[*] Zipping '$input' -> '$zipfile'...\n";
my $zip_cmd;
if (-d $input) {
    # Directory
    my $dir = $input;
    my $base = basename($dir);
    my $cwd = abs_path();
    chdir(dirname($dir)) or die "Cannot chdir: $!";
    $zip_cmd = "zip -r \"$zipfile\" \"$base\"";
    system($zip_cmd) == 0 or die "zip failed: $!";
    chdir($cwd);
} else {
    # Single file
    my $file = $input;
    my $dir = dirname($file);
    my $base = basename($file);
    my $cwd = abs_path();
    chdir($dir) or die "Cannot chdir: $!";
    $zip_cmd = "zip \"$zipfile\" \"$base\"";
    system($zip_cmd) == 0 or die "zip failed: $!";
    chdir($cwd);
}

# Optionally, create EXE (self-extracting)
if ($is_exe) {
    print "[*] Creating self-extracting EXE...\n";
    # Try 7z/7zS.sfx if available
    my $exe_tool = '';
    my $sfx_module = '';
    # Try to find 7zS.sfx in PATH or current directory
    for my $try (qw(7zS.sfx ./7zS.sfx /usr/lib/p7zip/7zS.sfx C:/Program\ Files/7-Zip/7zS.sfx)) {
        if (-e $try) {
            $exe_tool = '7z';
            $sfx_module = $try;
            last;
        }
    }
    if ($exe_tool eq '7z') {
        # Create 7z archive then concatenate SFX
        my $tmp7z = $zipfile;
        my $tmp_exe = $output;
        # On Windows, you could use 'copy /b'
        open(my $out, ">", $tmp_exe) or die "Can't write $tmp_exe: $!";
        open(my $sfx, "<", $sfx_module) or die "Can't read $sfx_module: $!";
        binmode $sfx; binmode $out;
        print $out $_ while <$sfx>;
        close $sfx;
        open(my $zipin, "<", $zipfile) or die "Can't read $zipfile: $!";
        binmode $zipin;
        print $out $_ while <$zipin>;
        close $zipin;
        close $out;
        print "[+] Created self-extracting EXE: $tmp_exe\n";
    } else {
        # Fallback to zip2exe if available
        my $zip2exe = `which zip2exe`;
        chomp $zip2exe;
        if ($zip2exe && -x $zip2exe) {
            system("$zip2exe \"$zipfile\" \"$output\"") == 0 or die "zip2exe failed!";
            print "[+] Created self-extracting EXE: $output\n";
        } else {
            print "[!] 7zS.sfx or zip2exe not found. Cannot create EXE.\n";
            print "[*] Leaving zip archive at: $zipfile\n";
        }
    }
} elsif (!$is_zip) {
    # If output is not .zip or .exe, just move zip to output
    move($zipfile, $output) or die "Cannot move $zipfile to $output: $!";
    print "[+] Output written to $output\n";
} else {
    print "[+] Zip archive created at $output\n";
}

print "[*] Done.\n";
exit 0;

# End of script (134 lines)
