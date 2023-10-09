#
#  path_show.pl
#
# Last updated $Date: 2007-12-09 18:01:51 JST$

sub path_show {
    if ($in{'emissiontarget'} eq "true") {
        &path_show_emissiontarget;
    } else {
        &path_show_scenario;
    }
}

#================
# パス表示画面
#================
sub path_show_emissiontarget {
    %formvals = (
#        StartEmission => ["WorldBaU","KyotoBaU"],
        StartEmission => ["KyotoBaU"],
#        start_year => [2010,2020,2030],
        start_year => [2010],
        target_year => [2030,2050,2100],
#        base_year => [1990,2000,2004,2007,2010],
        base_year => [1990,2000],
        factor => [20,30,40,50,60,70,80,90,100],
        );
    %formdefval = (
        StartEmission => "KyotoBaU",
        start_year => 2010,
        target_year => 2050,
        base_year => 1990,
        factor => 50,
        );

    # set illegal values to the default value.
    foreach my $key (keys(%formvals)) {
        my $hit = 0;
        for (my $i=0;$i<=$#{$formvals{$key}};$i++) {
            if ($in{$key} eq $formvals{$key}[$i]) {
                $hit = 1;
            }
        }
        if ($hit == 0) {
            $in{$key} = $formdefval{$key};
        }
    }
    if ($in{'start_year'} == $in{'target_year'}) { # == 2030
        $in{'target_year'} = "2050";
    }

    $path = "$in{'StartEmission'}_"."$in{'start_year'}_"."$in{'target_year'}_"."$in{'base_year'}_"."$in{'factor'}";
    $bau_of_scenario = "B2_2010_-_-_-";

    my $js = <<"EOM";
  <script type="text/javascript" src="$jsdir/path_show.js"></script>
EOM

    &header (\$js);

    print <<"EOM";
    <h1>$modevalsdesc{$mode}</h1>
    <p>Your setting:</p>
    <table class="setting">
      <tr><th>Start year emission</th><td>$in{'StartEmission'}</td></tr>
      <tr><th>Start year</th><td>$in{'start_year'}</td></tr>
      <tr><th>Target year</th><td>$in{'target_year'}</td></tr>
      <tr><th>Target emission</th><td>$in{'factor'} % of the emission of $in{'base_year'}</td></tr>
    </table>
EOM

    unless ( -e "$imgpath/pathgraph-emission_$path.png" ) { &path_graph_emissiontarget; }

    print "    <h3><a name=\"Pathgraph\">Path Graph : $path</a></h3>\n";
    print "    <img width=\"$width\" height=\"$height\" id=\"PathgraphImg\" src=\"$imgpath/pathgraph-emission_$path.png\" alt=\"Pathgraph $path\" />\n";

    print "    <h3><a name=\"Pathtable\">Path Table : $path</a></h3>\n";
    $tablefile = "./$datapath/pathgraph-emission_$path.txt";
    $indent = "    ";
    $tableid = "PathTable";
    &table;

    print <<"EOM";
    <form method="$method" action="$script">
      <p>
        <input type="hidden" name="mode" value="bs_select" />
        <input type="hidden" name="path" value="$path" />
        <input type="submit" value=" NEXT : burden-sharing of this path " />
      </p>
    </form>
EOM

    &footer;
    exit;

}

#================
# パス表示画面
#================
sub path_show_scenario {
    %formvals = (
        scenario => ["B2"],
        ghg => ["-", "450", "475", "500", "550", "600"],
#        temp_rise => ["-","2.0","2.2","2.4","2.6","2.8","3.0","3.2","3.4","3.6","3.8","4.0"],
        temp_rise => ["-","17","23","29","35"],
#        climate_sensitivity => ["1.760","2.113","2.412","2.498","2.700","3.000","3.334","3.603","3.732","4.259","5.114"],
        climate_sensitivity => ["-"],
        );
    %formdefval = (
        scenario => "B2",
        ghg => "-",
        temp_rise => "-",
#        climate_sensitivity => "3.000",
        climate_sensitivity => "-",
        );

    foreach my $key (keys(%formvals)) {
        if (&arrindex($formvals{$key}, $in{$key}) < 0) {
            $in{$key} = $formdefval{$key};
        }
    }
    
    $path = "$in{'scenario'}_"."$in{'start_year'}"."_$in{'ghg'}_$in{'temp_rise'}_$in{'climate_sensitivity'}";
    $bau_of_scenario = "$in{'scenario'}_"."$in{'start_year'}"."_-_-_$in{'climate_sensitivity'}";


    my @pgobj = ("emission", "ghg", "temp");
    my @pgobjdesc = ("Emission", "GHG Concentration", "Temperature");

    my @preloadimages = map { sprintf "$imgpath/pathgraph-%s_$path.png", $_ } @pgobj;

    my $js = <<"EOM";
  <script type="text/javascript" src="$jsdir/path_show.js"></script>
EOM

    &header (\$js,\@preloadimages);
    
#    my $temp_rise_string = $in{'temp_rise'};
    my $temp_rise_string =$in{'temp_rise'}eq"-"?"-":(sprintf ("%.1f", $in{'temp_rise'}/10));
    my $climate_sensitivity_string = $in{'climate_sensitivity'}; #=="-"?"-":(sprintf ("%.1f", $in{'temp_speed'}/10));

    print <<"EOM";
    <h1>@modevalsdesc{$mode}</h1>
    <p>Your setting:</p>
    <table class="setting">
      <tr><th>Future Scenario</th><td>$in{'scenario'}</td></tr>
      <tr><th>Stabilized GHG concentration (ppm)</th><td>$in{'ghg'}</td></tr>
      <tr><th>Limit to global temperature increase (&deg;C)</th><td>$temp_rise_string</td></tr>
<!--
      <tr><th>Climate sensitivity (&deg;C)</th><td>$climate_sensitivity_string</td></tr>
-->
    </table>
EOM

    unless ( -e "$imgpath/pathgraph-emission_$path.png" and -e  "$imgpath/pathgraph-ghg_$path.png" and -e  "$imgpath/pathgraph-temp_$path.png" ) { &path_graph_scenario; }

    print "    <h3><a name=\"Pathgraph\">Path Graph : $path</a></h3>\n";
    print "    <img width=\"$width\" height=\"$height\" id=\"PathgraphImg\" src=\"$imgpath/pathgraph-emission_$path.png\" alt=\"Pathgraph $path\" />\n";

    print "    <p>Object: \n";
    foreach (0..$#pgobj) {
      print "      " . (($_==0)?"":"|") . " <a ";
#      print "href=\"#Pathgraph\" ";
#      print "href=\"$imgpath/pathgraph-${pgobj[$_]}_$path.png\" target=\"_blank\" ";
      print "href=\"$imgpath/pathgraph-${pgobj[$_]}_$path.png\" rel=\"external\" ";
      print "onmouseover=\"setImage('PathgraphImg', '$imgpath/pathgraph-${pgobj[$_]}_$path.png')\">${pgobjdesc[$_]}</a>\n";
    }
    print "    </p>\n";

    print "    <h3><a name=\"Pathtable\">Path Table : $path</a></h3>\n";
    $tableid = "PathTable";
    $tablefile = "./$datapath/pathgraph-emission_$path.txt";
    $indent = "    ";
    my $entries = &table;

    if ( $path eq $bau_of_scenario ) { 
#      &error("気候制約を選択していません。前のページに戻って選択し直してください");
      &error("You have to select some climate targets. Back to previous page and retry.");
    }
    if ($entries <= 1) {
        &error("We could not provode the specified path. Please try other combinations of targets.");
    }

    print <<"EOM";
    <form method="$method" action="$script">
      <p>
        <input type="hidden" name="mode" value="bs_select" />
        <input type="hidden" name="path" value="$path" />
        <input type="submit" value=" NEXT : burden-sharing of this path " />
      </p>
    </form>
EOM

    &footer;
    exit;
}

sub path_graph_emissiontarget {
    my $cmd = "$perlexec ./lininterp.pl $path $bau_of_scenario ./$datapath/pathgraph-emission_$path.txt";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
      print "path_graph: $cmd\n" if $verbose;
      system($cmd);
    } else {
      &error($cmd);
    }

    my $cmd = "$perlexec ./$drawgraph ./$datapath/pathgraph-emission_$path.txt $imgpath/pathgraph-emission_$path.png";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
      print "path_graph: $cmd\n" if $verbose;
      system($cmd);
    } else {
      &error($cmd);
    }
}

#============================
# パスグラフ作成
#============================
sub path_graph_scenario {

  sub pathextract {
    my $pathyear = <IN>;
#    $pathyear =~ s/path|ghg|temp//;
    print PATHOUT $pathyear;
    while (<IN>) {
      if (/$bau_of_scenario/) { 
        s/$bau_of_scenario\t//;
        print PATHOUT "BaU\t";
        print PATHOUT; 
        # $bau = $_;
        # print "\$bau_of_scenario 2 : "; print; print "<br>\n"; 
      }
      if (/$path/) {
        s/$path\t//;
        print PATHOUT "Pathway\t";
        print PATHOUT;
        # print PATHOUT "BaU\t$bau";
        # chomp;
        # @global_allowance = split(/\t/);
        # print "<p>\@global_allowance : @global_allowance</p>\n";
        # last;
      }
    }
  }

#   print "<p>\$bau_of_scenario : $bau_of_scenario</p>\n";

  unless ( -e "./$datapath/pathgraph-emission_$path.txt" ) {
      open(IN,"$pathfile") || &error("Open Error : $pathfile");
      open(PATHOUT,">./$datapath/pathgraph-emission_$path.txt") || &error("Open Error : ./$datapath/pathgraph-emission_$path.txt");
      &pathextract();
      close(PATHOUT);
      close(IN);
  }

  unless ( -e "./$datapath/pathgraph-ghg_$path.txt" ) {
      open(IN,"$ghgfile") || &error("Open Error : $ghgfile");
      open(PATHOUT,">./$datapath/pathgraph-ghg_$path.txt") || &error("Open Error : ./$datapath/pathgraph-ghg_$path.txt");
      &pathextract();
      close(PATHOUT);
      close(IN);
  }

  unless ( -e "./$datapath/pathgraph-temp_$path.txt" ) {
      open(IN,"$tempfile") || &error("Open Error : $tempfile");
      open(PATHOUT,">./$datapath/pathgraph-temp_$path.txt") || &error("Open Error : ./$datapath/pathgraph-temp_$path.txt");
      &pathextract();
      close(PATHOUT);
      close(IN);
  }

  # my $pathcheck = @global_allowance ;
  # unless ( $pathcheck ) { &error("指定した条件のpathwayが存在しません"); }

  foreach ( ("emission", "ghg", "temp") ) {
    my $cmd = "$perlexec ./$drawgraph ./$datapath/pathgraph-${_}_$path.txt $imgpath/pathgraph-${_}_$path.png";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
      print "path_graph: $cmd\n" if $verbose;
      system($cmd);
    } else {
      &error($cmd);
    }
  }
}



1;

# Local Variables:
# coding: euc-jp
# End:
