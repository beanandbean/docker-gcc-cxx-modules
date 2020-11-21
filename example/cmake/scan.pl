#!/usr/bin/env perl

use File::Spec::Functions;

my ($filename, $target_directory) = @ARGV;
open INPUT, "<$filename" or exit 1;
for my $line (<INPUT>) {
  if ($line =~ m/(^|;)\s*export\s+module\s+([\w.:]+)\s*;/) {
    my $path = catfile($target_directory, "$2.gcm");
    print "$2 $path\n";
    last;
  }
}
close INPUT;
