#
#  cctable.pl
#
# Last updated $Date: 2007-12-04 18:00:14 JST$

sub cctable {
    my @yaxisvals = ("emission", "percapita", "intensity",
                     "comparison_BaU","comparison_90", "pop", "BaU", "GDP");
    my @bsvals = ("CandC", "revCC", "IIT", "IC");

    $path   = "$in{'path'}";
    $optionval = "$in{'optionval'}";
    $region = "CC";

    if ( arrindex( \@bsvals, "$in{'bs'}") < 0 ) {
      $bs = $bsvals[0];
    } else {
      $bs = "$in{'bs'}";
    }
    if ( arrindex( \@yaxisvals, "$in{'yaxisval'}") < 0 ) {
      $yaxis = $yaxisvals[0];
    } else {
      $yaxis = "$in{'yaxisval'}";
    }

    if ( $yaxis eq "pop" or $yaxis eq "GDP" or $yaxis eq "BaU" ) {
      $bsfile = "${yaxis}_$region";
    } else {
      $bsfile = "${yaxis}_${path}_${bs}_${optionval}_${region}";
    }

    $tableid="CC";
	$tablefile = "./$datapath/$bsfile.txt";
    $zeroNA = "NA";

    print "Content-type: text/html\n\n";
    &partial_table;
    exit;
}

sub partial_table {
  open(TABLE,"$tablefile") or &error("Open Error : $tablefile");
  my $line = <TABLE>;

  my @array;
  my @regions;
  my @data;
  my $head;

  while (<TABLE>) {
    chomp;
    @data = split(/\t/);
    $head = shift @data;
    push @array, [@data];
    push @regions, $head;
  }
  close(TABLE);

  $maxexp = $in{'maxexp'};

  print "  <tbody id=\"table_${tableid}_tbody\">\n";
  foreach (0..$#array) {
    my $aref = $array[$_];
    $head = $regions[$_];
    @data = @$aref;
    my $headmoded = $head;
    $headmoded =~ s/[ ,']//g;
    print "    <tr id=\"table_${tableid}_row_$headmoded\">\n";
    print "      <th><span>$head</span></th>";
    foreach (0..$#data) {
      print "<td>";
      print sprtnum($data[$_],$maxexp);
      print "</td>";
    }
    print "\n    </tr>\n";
  }
  print "  </tbody>\n";

}

1;

# Local Variables:
# coding: euc-jp
# End:
