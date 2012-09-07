 
#!/usr/bin/perl
if(@ARGV == 4)
{
   if($ARGV[0] == "-R")
   {
      $recurse = 1;
      shift(@ARGV);
   }else{
      $recurse=0;
   }
}

if(@ARGV == 3)
{
   if($ARGV[2] eq "all")
   {
      opendir(DOT, $ENV{'PWD'})|| die "Cannot opendir .";
      @filenamesIn = readdir(DOT);
      closedir(DOT);

      FILE:
      foreach $filenamesIn (@filenamesIn)
      {
         print "going through file $filenamesIn\n";
         unless($filenamesIn eq "." || $filenamesIn eq ".."){ 

            unless((-f $filenamesIn) && (!(-T filenamesIn)))
            {
               print "Can't open $filenamesIn\n\t$filenamesIn is not a text file\n";
               if(-d $filenamesIn && $recurse){
                  print STDERR "adding $filenamesIn contents to end of list\n";
                  opendir(DOT, $filenamesIn) || print "cannont open $filenamesIn";
                  @dirfiles = grep(!/^\.\.?$/, readdir(DOT));
                  closedir(DOT);
                  foreach $dirfile (@dirfiles)
                  {
                     $dirfile = $filenamesIn."/".$dirfile;
                     if(-T $dirfile || -d $dirfile){
                        push(@filenamesIn, $dirfile);
                     }
                  }

               }
               next FILE;
               # do some flag for recursion and put the files of a 
               # new directory on to filenamesIn
            }

            srand(time|$$);
            $tmpfile = "/tmp/replace".rand(time/2);
            open(TEMP, ">$tmpfile")|| die "cant open $tmpfile";
            if(-e $filenamesIn && -e $tmpfile)
            {
                       open(READ, "$filenamesIn")|| die "cant open $filenamesIn";

            $i=1;
            $foundOne=0;
               while(<READ>)
               {
                     if($_ =~ /$ARGV[0]/){
                  print "\tFound a match on line num $i\n";
                           s/$ARGV[0]/$ARGV[1]/g;
                  $foundOne++;
                           print TEMP $_;
               }else{
                       print TEMP $_;
                    }
               $i++;
               }
               close(READ);
               close(TEMP);
               open(LOG, ">>/tmp/cplog.replace");
               print LOG "$filenamesIn and $tmpfile\n";
               close(LOG);
               if($foundOne){
                  system"cp $tmpfile $filenamesIn";
               }
               system "rm $tmpfile";
            }
            else{
               close($tmpfile);
               print STDERR "\tProblem with $filenamesIn and $tmpfile\n";
            }
         }
      }
   } else { # we are working only on one file

      # check to see if the file exsists 
      if(-e $ARGV[2])
      {
         $filenamesIn = $ARGV[2];
         open(READ, $filenamesIn) || die "cant open $filenamesIn";
         srand(time|$$);
         $tmpfile = "/tmp/replace".rand(time/2);
         open(TEMP, ">$tmpfile");
         $i=1;
         while(<READ>)
         {
            if($_ =~ /$ARGV[0]/){
               print "Found a match on line num $i\n";
               s/$ARGV[0]/$ARGV[1]/g;
               print TEMP $_;
            }else{
               print TEMP $_;
            }
            $i++;
         }
         close(READ);
         close(TEMP);
         system"cp $tmpfile $filenamesIn";
         system "rm $tmpfile";
      }
   }

} else { # this is the end of the check for three args

   print "  Usage: replace [string to find] [string to replace it with] [fileName]\n";
   print "  'all' may be subtituted for [fileName] to do all files in directory.\n"
}