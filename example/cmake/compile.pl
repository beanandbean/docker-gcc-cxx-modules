#!/usr/bin/env perl

use File::Copy;
use File::Path qw(make_path);
use File::Basename;
use File::Spec::Functions;

my ($headers_directory, $module_map, @command) = @ARGV;
if (!-e $headers_directory) {
  make_path($headers_directory);
}

if (grep(m/^-fmodules-ts$/, @command)) {
  my $source_count = 0;
  foreach $param (reverse @command) {
    # Temporary method to detect source files.
    # May break in some cases.
    if ($param =~ m/^(\/[\w+\-. ]+)*\/[\w+\-. ]*\.(c|cc|cxx|cpp)$/) {
      $source_count++;
    } else { last; }
  }

  my ($executable, @args) = @command;
  my @header_args, $skip_next = 0;
  for (my $i = 0; $i < @args - $source_count; $i++) {
    if (!$skip_next) {
      if (!($args[$i] eq "-c" || $args[$i] eq "-fmodules-ts")) {
        if ($args[$i] eq "-o") {
          $skip_next = 1;
        } else {
          push @header_args, $args[$i];
        }
      }
    } else { $skip_next = 0; }
  }

  my $source_dummy_map = catfile($headers_directory, "__source_dummy_map__");
  copy($module_map, $source_dummy_map);

  my $header_map = catfile($headers_directory, "__header_map__");
  my %headers;
  if (!-e $header_map) {
    open HEADER_MAP, ">", $header_map;
  } else {
    open HEADER_MAP, "+<", $header_map;
    for my $line (<HEADER_MAP>) {
      if ($line =~ m/^((\/[\w+\-. ]+)+)\s+((\/[\w+\-. ]+)+)$/) {
        $headers{$1} = $3;
      }
    }
  }

  my $header_dummy_src = catfile($headers_directory, "__header_dummy__.hpp");
  
  open SOURCE_DUMMY, ">>", $source_dummy_map;
  for (my $i = @args - $source_count; $i < @args; $i++) {
    if (open INPUT, "<", $args[$i]) {
      for my $line (<INPUT>) {
        while ($line =~ m/(^|;)\s*import\s+(<[\/\w+\-. ]+>)\s*(?=;)/g) {
          my $include_name = $2;
          open HEADER_DUMMY, ">", $header_dummy_src;
          print HEADER_DUMMY "#include $include_name\n";
          close HEADER_DUMMY;
          my @detection = ($executable, @header_args, "-M", "-H", $header_dummy_src, "2>&1", "1>/dev/null");
          if ($ENV{'CXX_MODULES_VERBOSE'}) {
            print "@detection\n";
          }
          my @includes = qx(@detection);
          for my $include (@includes) {
            if ($include =~ m/^\.\s+((\/[\w+\-. ]+)+)$/) {
              if (!exists $headers{$1}) {
                $headers{$1} = canonpath(catfile($headers_directory, "$1.gcm"));
                print HEADER_MAP "$1 $headers{$1}\n";
              }
              print SOURCE_DUMMY "$1 $headers{$1}\n";
              if (!-e $headers{$1} || (stat($headers{$1}))[9] < (stat($1))[9]) {
                my (undef, $directory) = fileparse($headers{$1});
                make_path($directory);
                my @generation = ($executable, @header_args, "-x", "c++-header", "-fmodule-mapper=$header_map", "-fmodule-header", $1);
                print "[cxx-modules] Generating header unit $include_name...\n";
                if ($ENV{'CXX_MODULES_VERBOSE'}) {
                  print "@generation\n";
                }
                system(@generation);
              }
              last;
            }
          }
        }
      }
      close INPUT;
    }
  }
  close SOURCE_DUMMY;

  close HEADER_MAP;

  @compile = ($executable, "-fmodule-mapper=$source_dummy_map", @args);
  if ($ENV{'CXX_MODULES_VERBOSE'}) {
    print "@compile\n";
  }
  exec @compile or exit 1;
} else { exec @command or exit 1; }
