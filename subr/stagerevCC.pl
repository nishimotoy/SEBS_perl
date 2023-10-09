#
#  stagerevCC.pl
#
# Last updated $Date: 2007-12-04 01:33:29 JST$

#============================
# Stage table É½¼¨ (revCC)
#============================
sub stageRevCC {
  $path = $in{'path'};
#  $bs = $in{'bs'}; # should be revCC
  $bs = "revCC";
  $option = $in{'option'};

  &header;

  print "    <h1>",$modevalsdesc{$mode},"</h1>\n";

  unless ( -e "./$datapath/flag_${path}_${bs}_${option}_CC.txt" ) {
    my $cmd = "$perlexec ./aggr.pl -n ./$datapath/flag_${path}_${bs}_${option}.txt ./$datapath/flag_${path}_${bs}_${option}_CC.txt CC flag";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
      print "<p>stageRevCC :: $cmd</p>\n"  if $verbose;
      system($cmd);
    } else {
      &error($cmd);
    }
  }
  $tablefile = "./$datapath/flag_${path}_${bs}_${option}_CC.txt";
  $inttable = 1;
  $indent="    ";
  &table;

  &footer;
  exit;
}


1;

# Local Variables:
# coding: euc-jp
# End:
