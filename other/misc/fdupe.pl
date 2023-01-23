#!/usr/bin/perl
#
# fdupe tool - finding duplicate files
#
# $Id: fdupe,v 1.5 2004/04/09 11:06:33 root Exp root $
#
# Source code Copyright (c) 1998 Bernhard Schneider.
# May be used only for non-commercial purposes with
# appropriate acknowledgement of copyright.
#
# FILE :        fdupe
# DESCRIPTION : find duplicate Files.
# AUTOR:        Bernhard Schneider <b.schneider@fh-wolfenbuettel.de>
# hints, crrections & ideas are welcome
#
# usage: $0 <path> <path> ...
#
# hint: redirect output to >file, edit the file and
#       mark lines you wish to move/delete with an -.
#       Use following script to delete marked files:
#       #!/usr/bin/perl -n
#       chomp; unlink if s/^-//;
#
# history: (dd.mm.yy)
# 12.05.99 - goto statment replaced with next
# 14.05.99 - minor changes
# 18.05.99 - removed confusing 'for $y'
#            included hash-search 
# 20.05.99 - minor changes
# 02.03.00 - some functions rewritten, optimized for speed
# 10.01.01 - hint-fix by Ozzie <ozric@kyuzz.org>
# 05.03.02 - fixed hangups by reading block/char-Devices
# 09.04.04 - some cosmetics
#
#
#
#use strict; # uncomment for debugging

$|=1; 
local (*F1,*F2); my %farray = ();
print "searching dir's...\n";

$ARGV[0] = '.' unless $ARGV[0];  # use wd if no arguments given

map scan($_), @ARGV;

sub scan {
    my ($dir) = $_[0];
opendir (DIR, $dir) or die "$!:$@";
map {
  (-d) ? scan($_) : push @{$farray{-s $_}},$_
             unless (-l or -S  or -p or -c or -b);
    } map "$dir/$_", grep !/^\.\.?$/, readdir (DIR); closedir (DIR);
}

print "now comparing files ...\n";
for my $fsize (sort {$a <=> $b} keys %farray) {

  my ($i,$fptr,$fref,$pnum,%pair,%index,$chunk);

  # skip files without pairs
  next if (scalar @{$farray{$fsize}} == 1); 
  
  $pnum  = 0;
  %pair  = ();
  %index = ();
  
  nx:
  for (my $nx=0;$nx<=$#{$farray{$fsize}};$nx++) # $nx now 1..count of files 
  {                                             # with the same size
$fptr = \$farray{$fsize}[$nx];              # ref to the first file
    $chunk = getchunk($fsize,$fptr);
    if ($pnum) {
  for $i (@{$index{$chunk}}) {
         $fref = ${$pair{$i}}[0];
     unless (mycmp($fsize,$fptr,$fref)) {
            # found duplicate, collecting
        push @{$pair{$i}},$fptr;
next nx;
     }
  }
    }

    # nothing found, collecting 
    push @{$pair{$pnum}},$fptr;
    push @{$index{$chunk}}, $pnum++;
  }
  # show found pairs for actual size
  for $i (keys %pair) {
    $#{$pair{$i}} || next;
    print "\n size: $fsize\n\n";
    for (@{$pair{$i}}) {
        print $$_,"\n"; 
    }
  }
}

close F1;
close F2;

# end

# get chunk of bytes from a file
sub getchunk {
  my ($fsize,$fname) = (@_);
  my $chunksize = 32;
  my ($nread,$buff);
  
  return undef 
      unless (open(F1,$$fname));
  binmode F1;
  $nread = read (F1,$buff,$chunksize);
  ($nread == $chunksize || $nread == $fsize) ? "$buff" : undef;
}  


# compare two files

sub mycmp {
  my ($size,$filea,$fileb) = @_;
  my ($buffa, $buffb);
  my ($nread1,$nread2);
  my ($buffsize) = 16*1024;
  
  unless (open(F2,"<$$fileb")) {
    return -1;
  }
  
  binmode F2;
  seek (F1,0,0);
  
  do {  $nread1 = read (F1,$buffa,$buffsize);
    $nread2 = read (F2,$buffb,$buffsize);

    if (($nread1 != $nread2) || ($buffa cmp $buffb)) {
        return -1;
        }
  } while ($nread1);
  
  return 0;
}
