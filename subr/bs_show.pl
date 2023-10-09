#
#  bs_show.pl
#
# Last updated $Date: 2007-12-09 21:08:53 JST$

my %bsvalsdesc =
    ( "CandC" => "Contraction &amp; Convergence (C&amp;C)",
      "revCC" => "Revised C&amp;C",
      "IIT" => "Intensity Improvement Target (IIT)",
      "IC" => "Intensity Convergence",
      "BP" => "Brazilian Proposal",
      "CECP" => "Cumulative Emission per Cumulative Population" );

my $scheme_style; # "simple" or "contrib"

## sub bs_option_read で ${bs}_option*.txt から読み込み.
my @bs_opt;           # オプションとして表示させる値
my %bs_opt_val;       # 計算プログラムに渡す値
my $bs_opt_title;     # オプションの概要
my $bs_opt_default;   # オプションのディフォルト in (0..$#bs_opt)

#================
# BS結果表示画面
#================
sub bs_show {
    my @ss_bsvals = ("CandC", "revCC", "IIT", "IC");
    my @cs_bsvals = ("BP", "CECP");

    $path   = "$in{'path'}";
    $bs     = "$in{'bs'}";

    if ( arrindex( \@cs_bsvals, "$in{'bs'}") >= 0 ) {
        $bs = "$in{'bs'}";
        $scheme_style = "contrib";
        &bs_option_read;
        &contribScheme_show;
    } else {
        if ( arrindex( \@ss_bsvals, "$in{'bs'}") >= 0 ) {
            $bs = "$in{'bs'}";
        } else {
            $bs = $bsvals[0];
        }
        $scheme_style = "simple";
        &bs_option_read;
        &simpleScheme_show;
    }
}



sub simpleScheme_show {
    my @yaxisvals = ("emission", "emissionSA", "percapita", "intensity",
                     "comparison_BaU","comparison_90", "pop", "BaU", "GDP");
    my %yaxisvals_desc = (
        "emission" => "Emission (line)",
        "emissionSA" => "Emission (stacked area)",
        "percapita" => "Percapita emission",
        "intensity" => "Intensity",
        "comparison_BaU" => "Comparison with BaU emission",
        "comparison_90" => "Comparison with 90\'s emission",
        "pop" => "Population of this scenario",
        "BaU" => "BaU emission of this scenario",
        "GDP" => "GDP of this scenario",
        );
    my %yaxisvals_fileprefix = (
        "emission" => "emission",
        "emissionSA" => "emission",
        "percapita" => "percapita",
        "intensity" => "intensity",
        "comparison_BaU" => "comparison_BaU",
        "comparison_90" => "comparison_90",
        "pop" => "pop",
        "BaU" => "BaU",
        "GDP" => "GDP");

    &is_same_set(\@yaxisvals,[keys(%yaxisvals_desc)] ) or die "Internal error!";
    &is_same_set(\@yaxisvals,[keys(%yaxisvals_fileprefix)] ) or die "Internal error!";

    my @regionvals = ("Major18", "AIM21", "EDGAR13", "SRES9", "SRES4", "AnnexB", "CC");
    my %regionvals_desc = (
        "Major18" => "Major18",
        "AIM21" => "AIM21",
        "EDGAR13" => "EDGAR13",
        "SRES9" => "SRES9",
        "SRES4" => "SRES4",
        "AnnexB" => "Annex B, non-Annex B",
        "CC" => "Countries");

    &is_same_set(\@regionvals,[keys(%regionvals_desc)] ) or die "Internal error!";

    $yaxis  = "$in{'yaxis'}";

    if ($#bs_opt>=0) {
        if ( arrindex(\@bs_opt, "$in{'option'}") < 0 ) {
            $option = $bs_opt[$bs_opt_default];
        } else {
            $option = "$in{'option'}";
        }
    } else {
        $option = "-";
    }

    if ( arrindex( \@regionvals, "$in{'region'}") < 0 ) {
      $region = $regionvals[0];
    } else {
      $region = "$in{'region'}";
    }

    if ( arrindex( \@yaxisvals, "$in{'yaxis'}") < 0 ) {
      $yaxis = $yaxisvals[0];
    } else {
      $yaxis = "$in{'yaxis'}";
    }

    if ( $yaxis =~ /^pop/ or $yaxis =~ /^GDP/ or $yaxis =~ /^BaU/ ) {
      $bsfile = "$yaxisvals_fileprefix{$yaxis}_${region}";
      $bsimgfile = "${yaxis}_${region}";
    } else {
      $bsfile = "$yaxisvals_fileprefix{$yaxis}_${path}_${bs}_$bs_opt_val{$option}_${region}";
      $bsimgfile = "${yaxis}_${path}_${bs}_$bs_opt_val{$option}_${region}";
    }

    my @preloadimages = map { sprintf "$imgpath/${bsimgfile}_%s.png", $_ } @ymaxarr;

    my $js;
    unless ($region eq "CC") {
        $js = <<"EOM";
  <script type="text/javascript">
    // <![CDATA[
    var urlOpt = "path=$path&bs=$bs&optionval=$bs_opt_val{$option}&yaxisval=$yaxisvals_fileprefix{$yaxis}";
    // ]]>
  </script>
  <script type="text/javascript" src="$jsdir/$region.js"></script>
  <script type="text/javascript" src="$jsdir/bs_show_sort.js"></script>
  <script type="text/javascript" src="$jsdir/bs_show_simple.js"></script>
EOM
    }

    &header (\$js,\@preloadimages);

    # 該当するファイルがなければ計算を行う
    # emission_$path_$bs_$bs_opt_val{$option}.txt を作成
    unless ( -e "$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.txt" ) {
        &bs_calc_simple ("$path", "$bs", "$bs_opt_val{$option}");
        print "<p>check bs_calc_simple (${path}_${bs}_$bs_opt_val{$option})</p>\n"  if $verbose;
    }
    unless ( -e "$datapath/$bsfile.txt" ) {
      SWITCH: {
          $yaxis =~ /^pop/ and $yaxisd = "percapita", last SWITCH;
          $yaxis =~ /^GDP/ and $yaxisd = "intensity", last SWITCH;
          $yaxis =~ /^BaU/ and $yaxisd = "comparison_BaU", last SWITCH;
          $yaxisd = $yaxisvals_fileprefix{$yaxis};
        }
        print "<p>check capin_calc (\"${path}_${bs}_$bs_opt_val{$option}\", $yaxisd, $region)</p>\n"  if $verbose;
        &capin_calc ("${path}_${bs}_$bs_opt_val{$option}", $yaxisd, $region);
        &capin_calc ("${path}_${bs}_$bs_opt_val{$option}", $yaxisd, "CC") unless $region eq "CC";
    }
    
    print <<"EOM";
    <h1>$modevalsdesc{$mode}</h1>
    <p>Your setting:</p>
    <table class="setting">
      <tr><th>Path</th><td>$path</td></tr>
      <tr><th>Burden sharing scheme</th><td>$bsvalsdesc{$bs}</td></tr>
EOM
      if ($#bs_opt>=0) {
          print "      <tr><th>$bs_opt_title</th><td>$option</td></tr>\n";
      }

      print <<"EOM";
      <tr><th>Region classification</th><td>$regionvals_desc{$region}</td></tr>
      <tr><th>Object</th><td>$yaxisvals_desc{$yaxis}</td></tr>
    </table>
EOM

    unless ( $region eq "CC" ) {
      # 該当する画像がなければ画像出力を行う ！パス注意
      # unless ( -e "./../../public_html/sebs/$bsfile.png" ) { &graph; }
      unless ( -e "$imgpath/$bsimgfile.png" ) { &graph; }

      print "    <h3><a id=\"BSGraph\">BS Graph : $bsimgfile</a></h3>\n";
      &graph_show ("BSGraphImg",$bsimgfile);
    } else {
      print "    <h3>Graph generation not supported</h3>\n";
    }

    print <<"EOM";
    <form method="$method" action="$script">
      <div class="optbox">
        <p class="optbox_left">
          Object<br />
EOM
    print "          <select name=\"yaxis\" size=\"", $#yaxisvals+1 ,"\">\n";
    foreach (0..$#yaxisvals) {
      print "            <option value=\"$yaxisvals[$_]\"";
      print " selected=\"selected\"" if ( $yaxis eq $yaxisvals[$_] );
      print ">$yaxisvals_desc{$yaxisvals[$_]}</option>\n";
    }
    print <<"EOM";
          </select>
        </p>
        <p class="optbox_center">
          Region classification<br />
EOM
    print "          <select name=\"region\" size=\"", $#regionvals+1 ,"\">\n";
    foreach (0..$#regionvals) {
      print "            <option value=\"$regionvals[$_]\"";
      print " selected=\"selected\"" if ( $region eq $regionvals[$_] );
      print ">$regionvals_desc{$regionvals[$_]}</option>\n";
    }
    print <<"EOM";
          </select>
        </p>
        <p class="optbox_right">
          <input type="hidden" name="mode" value="bs_show" />
          <input type="hidden" name="path" value="$path" />
          <input type="hidden" name="bs" value="$bs" />
          <input type="hidden" name="option" value="$option" />
          <input type="submit" value=" Change this figure " />
        </p>
      </div>
    </form>
EOM

    print "    <h3>BS Table : $bsfile</h3>\n";

    $tableid="BSTable";
    $tablefile = "./$datapath/$bsfile.txt";
    $zeroNA = "NA";
    $indent = "    ";
    $out_maxexp = true;
    &table;

    if ($bs eq "IIT") {
      print "    <h3>IIT : Intensity improvement rate</h3>\n";
      $tablefile = "./$datapath/rate_${path}_${bs}_$bs_opt_val{$option}.txt";
      $zeroNA = "-";
      $indent = "    ";
      &table;
    } elsif ($bs eq "revCC") {
      print "    <h3>Revised C&amp;C : Stage of 170 countries</h3>\n";
      print "    <p><a href=\"$script?mode=stageRevCC&amp;bs=$bs&amp;option=$option&amp;region=$region&amp;yaxis=$yaxis&amp;path=$path\" rel=\"external\">open in new window</a></p>\n";
    }

    &bs_option_show;

    &footer;
    exit;
}

sub contribScheme_show {
    my @contrib_yaxisvals = ("contrib","contribSA","contribpercapita");
    my %contrib_yaxisvals_desc = (
        "contrib" => "Contribution (line)",
        "contribSA" => "Contribution (stacked area)",
        "contribpercapita" => "Percapita contribution");
    my %contrib_yaxisvals_fileprefix = (
        "contrib" => "contribution",
        "contribSA" => "contribution",
        "contribpercapita" => "contribpercapita" );

    &is_same_set(\@contrib_yaxisvals,[keys(%contrib_yaxisvals_desc)] ) or die "Internal error!";
    &is_same_set(\@contrib_yaxisvals,[keys(%contrib_yaxisvals_fileprefix)] ) or die "Internal error!";

    my @yaxisvals = ("emission","emissionSA","percapita","intensity",
                     "comparison_BaU","comparison_90","pop","BaU","GDP");
    my %yaxisvals_desc = (
        "emission" => "Emission (line)",
        "emissionSA" => "Emission (stacked area)",
        "percapita" => "Percapita emission",
        "intensity" => "Intensity",
        "comparison_BaU" => "Comparison with BaU emission",
        "comparison_90" => "Comparison with 90\'s emission",
        "pop" => "Population of this scenario",
        "BaU" => "BaU emission of this scenario",
        "GDP" => "GDP of this scenario");
    my %yaxisvals_fileprefix = (
        "emission" => "emission",
        "emissionSA" => "emission",
        "percapita" => "percapita",
        "intensity" => "intensity",
        "comparison_BaU" => "comparison_BaU",
        "comparison_90" => "comparison_90",
        "pop" => "poplong",
        "BaU" => "BaU",
        "GDP" => "GDP");
    my %yaxis_short = (
        "emission" => "",
        "emissionSA" => "",
        "percapita" => "",
        "intensity" => ".short",
        "comparison_BaU" => ".short",
        "comparison_90" => ".short",
        "pop" => "",
        "BaU" => "",
        "GDP" => "");
    my %yaxis_denom = (
        "percapita" => "poplong",
        "intensity" => "GDP",
        "comparison_BaU" => "BaU",
        "comparison_90" => "90" );

    &is_same_set(\@yaxisvals,[keys(%yaxisvals_desc)] ) or die "Internal error!";
    &is_same_set(\@yaxisvals,[keys(%yaxisvals_fileprefix)] ) or die "Internal error!";
    &is_same_set(\@yaxisvals,[keys(%yaxis_short)] ) or die "Internal error!";

    if ($#bs_opt>=0) {
        if ( arrindex(\@bs_opt, "$in{'option'}") < 0 ) {
            $option = $bs_opt[$bs_opt_default];
        } else {
            $option = "$in{'option'}";
        }
    } else {
        $option = "-";
    }

    if ( arrindex(\@contrib_yaxisvals, "$in{'contrib_yaxis'}") < 0 ) {
        $contrib_yaxis = $contrib_yaxisvals[2];
    } else {
        $contrib_yaxis = "$in{'contrib_yaxis'}";
    }

    if ( arrindex(\@yaxisvals, "$in{'yaxis'}") < 0 ) {
        $yaxis = $yaxisvals[0];
    } else {
        $yaxis = "$in{'yaxis'}";
    }

    my $contrib_basename = "$contrib_yaxisvals_fileprefix{$contrib_yaxis}_${path}_${bs}_$bs_opt_val{$option}";
    my $contrib_baseimgname = "${contrib_yaxis}_${path}_${bs}_$bs_opt_val{$option}";
    my $obj_basename;
    my $obj_baseimgname;
    if ( $yaxis =~ /^pop/) {
      $obj_basename = "$yaxisvals_fileprefix{$yaxis}_EDGAR13";
      $obj_baseimgname = "$yaxisvals_fileprefix{$yaxis}_EDGAR13";
    } elsif ($yaxis =~ /^GDP|^BaU/) {
      $obj_basename = "$yaxisvals_fileprefix{$yaxis}_EDGAR13";
      $obj_baseimgname = "${yaxis}_EDGAR13";
    } else {
      $obj_basename = "$yaxisvals_fileprefix{$yaxis}_${path}_${bs}_$bs_opt_val{$option}";
      $obj_baseimgname = "${yaxis}_${path}_${bs}_$bs_opt_val{$option}";
    }

    my @preloadimages1 = map { sprintf "$imgpath/${contrib_baseimgname}_%s.png", $_ } @ymaxarr;
    my @preloadimages2 = map { sprintf "$imgpath/${obj_baseimgname}_%s.png", $_ } @ymaxarr;
    my @preloadimages = (@preloadimages1, @preloadimages2);

    my $js = <<"EOM";
  <script type="text/javascript" src="$jsdir/EDGAR13.js"></script>
  <script type="text/javascript" src="$jsdir/bs_show_sort.js"></script>
  <script type="text/javascript" src="$jsdir/bs_show_contrib.js"></script>
EOM
    
    &header(\$js,\@preloadimages);

    # 該当するファイルがなければ計算を行う
    unless ( -e "$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.output.txt"
             and
             -e "$datapath/contribution_${path}_${bs}_$bs_opt_val{$option}.output.txt") {
        print "<p>check bs_calc_contrib (${path}_${bs}_$bs_opt_val{$option})</p>\n"  if $verbose;
        &bs_calc_contrib ("$path", "$bs", "$bs_opt_val{$option}");
    }

    my @longyarr;
    foreach (190..220) {
        push @longyarr, 10*$_;
    }
    my @shortyarr = (1990,2000,2010,2020,2030,2050,2100);

    &transpose_file ("./past_pop.txt", "$datapath/poplong_EDGAR13.txt",\@longyarr) unless -e "$datapath/poplong_EDGAR13.txt";
    &transpose_file ("$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.output.txt","$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.txt",\@longyarr) unless -e "$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.txt";
    &transpose_file ("$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.output.txt","$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.short.txt", \@shortyarr) unless -e "$datapath/emission_${path}_${bs}_$bs_opt_val{$option}.short.txt";
    &transpose_file ("$datapath/contribution_${path}_${bs}_$bs_opt_val{$option}.output.txt","$datapath/contribution_${path}_${bs}_$bs_opt_val{$option}.txt",\@longyarr) unless -e "$datapath/contribution_${path}_${bs}_$bs_opt_val{$option}.txt";
    &division_file ("$datapath/contribution_${path}_${bs}_$bs_opt_val{$option}.txt","$datapath/poplong_EDGAR13.txt","$datapath/contribpercapita_${path}_${bs}_$bs_opt_val{$option}.txt") unless -e "$datapath/contribpercapita_${path}_${bs}_$bs_opt_val{$option}.txt";

    foreach my $var ( ("BaU", "GDP", "90") ) {
        unless (-e "$datapath/${var}_EDGAR13.short.txt") {
            unless (-e "$datapath/${var}_EDGAR13.txt") {
                my $cmd = "$perlexec ./aggr.pl -l ./$var.txt $datapath/${var}_EDGAR13.txt EDGAR13";
                system($cmd) unless $cmd =~ /[^-a-zA-Z.\/ 0-9_]/;
            }
            &yfilter_file ("$datapath/${var}_EDGAR13.txt","$datapath/${var}_EDGAR13.short.txt",\@shortyarr);
        }
    }

    if ( $yaxis_denom{$yaxis} and not -e "$datapath/$obj_basename$yaxis_short{$yaxis}.txt" ) {
        &division_file ("$datapath/emission_${path}_${bs}_$bs_opt_val{$option}$yaxis_short{$yaxis}.txt", "$datapath/$yaxis_denom{$yaxis}_EDGAR13$yaxis_short{$yaxis}.txt", "$datapath/$obj_basename$yaxis_short{$yaxis}.txt");
    }

     print <<"EOM";
    <h1>$modevalsdesc{$mode}</h1>
    <p>Your setting:</p>
    <table class="setting">
      <tr><th>Path</th><td>$path</td></tr>
      <tr><th>Burden sharing scheme</th><td>$bsvalsdesc{$bs}</td></tr>
EOM
    if ($#bs_opt>=0) {
      print "      <tr><th>$bs_opt_title</th><td>$option</td></tr>\n";
    }
    print "    </table>\n";

    unless ( -e "$imgpath/$contrib_baseimgname.png" ) {
        local $bsfile = $contrib_basename;
        local $bsimgfile = $contrib_baseimgname;
        &graph;
    }
    print "    <h3><a id=\"BSGraph_Contrib\">BS Graph (Contribution) : $contrib_baseimgname </a></h3>\n";
    &graph_show("BSGraphImg_Contrib", "$contrib_baseimgname");

    print <<"EOM";
    <form method="$method" action="$script">
      <div class="optbox">
        <p class="optbox_left">
            Contribution<br />
EOM
    print "          <select name=\"contrib_yaxis\" size=\"", $#contrib_yaxisvals+1 ,"\">\n";
    foreach (0..$#contrib_yaxisvals) {
      print "            <option value=\"$contrib_yaxisvals[$_]\"";
      print " selected=\"selected\"" if ( $contrib_yaxis eq $contrib_yaxisvals[$_] );
      print ">$contrib_yaxisvals_desc{$contrib_yaxisvals[$_]}</option>\n";
    }
    print <<"EOM";
          </select>
        </p>
        <p class="optbox_right">
          <input type="hidden" name="mode" value="bs_show" />
          <input type="hidden" name="path" value="$path" />
          <input type="hidden" name="bs" value="$bs" />
          <input type="hidden" name="option" value="$option" />
          <input type="hidden" name="yaxis" value="$yaxis" />
          <input type="submit" value=" Change this figure " />
        </p>
      </div>
    </form>
EOM

    unless ( -e "$imgpath/$obj_baseimgname.png" ) {
        local $bsfile = "$obj_basename$yaxis_short{$yaxis}";
        local $bsimgfile = $obj_baseimgname;
        &graph;
    }
    print "    <h3><a id=\"BSGraph\">BS Graph (Object) : $obj_baseimgname</a></h3>\n";
    &graph_show("BSGraphImg", "$obj_baseimgname");

    print <<"EOM";
    <form method="$method" action="$script">
      <div class="optbox">
        <p class="optbox_left">
            Object<br />
EOM
    print "          <select name=\"yaxis\" size=\"", $#yaxisvals+1 ,"\">\n";
    foreach (0..$#yaxisvals) {
      print "            <option value=\"$yaxisvals[$_]\"";
      print " selected=\"selected\"" if ( $yaxis eq $yaxisvals[$_] );
      print ">$yaxisvals_desc{$yaxisvals[$_]}</option>\n";
    }
    print <<"EOM";
          </select>
        </p>
        <p class="optbox_right">
          <input type="hidden" name="mode" value="bs_show" />
          <input type="hidden" name="path" value="$path" />
          <input type="hidden" name="bs" value="$bs" />
          <input type="hidden" name="option" value="$option" />
          <input type="hidden" name="contrib_yaxis" value="$contrib_yaxis" />
          <input type="submit" value=" Change this figure " />
        </p>
      </div>
    </form>
EOM

    print "    <h3>BS Table (Contribution) : $contrib_basename</h3>\n";

    $tableid="BSTable_Contrib";
    $tablefile = "./$datapath/$contrib_basename.txt";
    $indent = "    ";
    $out_maxexp = true;
    &table;

    print "    <h3>BS Table (Object) : $obj_basename</h3>\n";

    $tableid="BSTable";
    $tablefile = "./$datapath/$obj_basename$yaxis_short{$yaxis}.txt";
    $indent = "    ";
    $out_maxexp = true;
    &table;

    &bs_option_show;

    &footer;
    exit;
}

sub graph_show {
    my $imgid = $_[0];
    my $filebasename = $_[1];

    print "    <img width=\"$width\" height=\"$height\" id=\"$imgid\" alt=\"$filebasename.png\" src=\"$imgpath/$filebasename.png\" />\n";
    print "    <p>Scale change:\n";
    print "      <a ";
    print "href=\"$imgpath/$filebasename.png\" rel=\"external\" ";
#      print "href=\"#BSGraph\" ";
    print "onmouseover=\"setImage('$imgid', '$imgpath/$filebasename.png')\">100%</a>\n";
    foreach (0..$#ymaxarr) {
        print "      | <a ";
        print "href=\"$imgpath/${filebasename}_${ymaxarr[$_]}.png\" rel=\"external\" ";
        print "onmouseover=\"setImage('$imgid', '$imgpath/${filebasename}_${ymaxarr[$_]}.png')\">${ymaxarrdesc[$_]}</a>\n";
    }
    print "    </p>\n";

#    my @preloadimages = map { sprintf "$imgpath/${filebasename}_%s.png", $_ } @ymaxarr;
#    print &preloadimgs_js(\@preloadimages);
}


######################################## under construction
sub bs_calc_contrib {
#    use File::Copy;
#     my $suffix = "$_[0]_$_[1]_$_[2]";

#     copy("./sampledata/BP_emission.txt", "$datapath/emission_$suffix.output.txt");
#     copy("./sampledata/BP_contribution.txt","$datapath/contribution_$suffix.output.txt");

    my $path = $_[0];
    my $bs = $_[1];
    my $option = $_[2];

    if ($option =~ /[^\.0-9]/) {
        &error(" Invalid option specification: " . $option);
    }

    my $bs_script;
    if ($bs eq "BP") { $bs_script = "./bp.pl"; }
#    elsif ($bp eq "CECP") {$bs_script = "./cecp.pl"; }
    else {&error(" Valid BS scheme was not selected! : $bs ");}
    
#    open CMD, $bs_script;
#    my @arr = <CMD>;
#    close CMD;
#    my $script = join ("",@arr);

    my $outfile = "./$datapath/emission_${path}_${bs}_$option.output.txt";
    my $pathgraphfile = "./$datapath/pathgraph-emission_$path.txt";
    my $cmd = "$perlexec $bs_script $pathgraphfile $outfile";

#    $script =~ s/\$ARGV\[0\]/\"$pathgraphfile\"/g;
#    $script =~ s/\$ARGV\[1\]/\"$outfile\"/g;

    print "<p>$cmd</p>" if $verbose;
#    print "<pre>$script</pre>";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
#        eval($script);
        system($cmd);
#        if ($@) {
#            &error($@);
#        }
    } else {
        &error($cmd);
    }
    unless  (-e $outfile ) {
        &error("$bs_script execution error: no output files generated!");
    }
}

######################################## under construction
sub division_file {
    my $numfile = $_[0];
    my $denomfile = $_[1];
    my $outfile = $_[2];

    my $normalizer = 1;
    $normalizer = 100 if $outfile =~ /comparison/;
    $normalizer = 1000 if $outfile =~ /contribpercapita/;

    open IN, $numfile or die "Sub division_file: cannot open $numfile";
    my @numdata = <IN>;
    close IN;
    my $l = $numdata[0];
    chomp $l;
    my @year = split (/\t/,$l);
    shift @year;

    open IN, $denomfile or die "Sub division_file: cannot open $denomfile";
    my @denomdata = <IN>;
    close IN;
    my $l = $denomdata[0];
    chomp $l;
    my @y = split(/\t/,$l);
    shift @y;

    my $msg = "Sub division_file: array of years don't match in $numfile & $denomfile";
    die $msg unless $#y == $#year;
    foreach (0..$#y) {
        die $msg unless     $y[$_] == $year[$_];
    }

    my %numhash;
    foreach (1..$#numdata) {
        my $l = $numdata[$_];
        chomp $l;
        my @arr = split(/\t/,$l);
        my $key = shift @arr;
        $numhash{$key} = \@arr;
    }

    my %denomhash;
    foreach (1..$#denomdata) {
        my $l = $denomdata[$_];
        chomp $l;
        my @arr = split(/\t/,$l);
        my $key = shift @arr;
#        print join ("\t", @arr);
        $denomhash{$key} = \@arr;
    }

    my %hash;
    foreach my $key (keys(%denomhash)) {
        my @narr = @{$numhash{$key}};
        my @darr = @{$denomhash{$key}};
        my @arr;
        foreach my $i (0..$#narr) {
            $arr[$i] = $narr[$i]/$darr[$i] * $normalizer;
#            print $arr[$i] . " ";
        }
        $hash{$key} = \@arr;
    }

    my @sortedkeys = sort {
        our $a, $b;
        $hash{$b}->[$#year] <=> $hash{$a}->[$#year]
    } keys %hash;

    open OUT, ">$outfile" or die "Sub division_file: cannot open $outfile";
    print OUT "Region\t" . join("\t",@year) . "\n";
    foreach my $key (@sortedkeys) {
        print OUT $key ;
        my @arr = @{$hash{$key}};
        foreach my $i (0..$#arr) {
            print OUT "\t" . $arr[$i];
        }
        print OUT "\n";
    }
    close OUT;
}

sub yfilter_file {
    my $infile = $_[0];
    my $outfile = $_[1];
    my @yarr = @{$_[2]};

    open (IN, "$infile") or die "Sub yfilter_file: Open Error: $infile";
    my @file = <IN>;
    close IN;

    my $l = $file[0];
    chomp $l;
    my @arr = split (/\t/, $l);

    my @outyidx;
    push @outyidx, 0;
    foreach my $i (1..$#arr) {
        if ($arr[$i] == $yarr[0]) {
            push @outyidx, $i;
            shift @yarr;
        }
    }

    open (OUT, ">$outfile") or die "Sub yfilter_file: Open Error: $outfile";
    foreach (@file) {
        chomp;
        @arr = split (/\t/);

        foreach (@outyidx) {
            print OUT ($_==0)?"":"\t";
            print OUT $arr[$_];
        }
        print OUT "\n";
    }
    close OUT;
}

# transpose をかけ, @yarr に含まれる year のみ出力.
# 入力: $_[0].output.txt
# 出力: $_[0].txt
sub transpose_file {
    my $infile = shift @_;
    my $outfile = shift @_;

    my $yarr;
    if (ref $_[0] eq "ARRAY") {
        @yarr = @{$_[0]};
    }

    open (IN, "$infile") or die "Sub transpose_file: Open Error: $infile";
    my @array;
    my $i = 0;
    while (<IN>) {
        chomp;
        my @arr = split(/\t/);
        $array[$i] = \@arr;
        $i++;
    }
    close IN;

    unless ($array[0]->[0]) {
        $array[0]->[0] = "Region";
    }

    my $l = $#{$array[0]};
    foreach (1..$#array) {
        if ($#{$array[$_]} != $l) {
            die "Sub transpose_file: Line $i has a different number of columns!";
        }
    }

    my @outyidx;
    if ($#yarr >=0) {
        push @outyidx, 0;
        foreach my $i (1..$#array) {
            if ($array[$i]->[0] == $yarr[0]) {
                push @outyidx, $i;
                shift @yarr;
            }
        }
    } else {
        @outyidx = (0..$#array);
    }

    open (OUT, ">$outfile") or die "Sub transpose_file: Open Error: $outfile";
    foreach my $i (0..$l) {
        foreach my $j (@outyidx) {
            print OUT ($j==0?"":"\t") ;
            print OUT ($array[$j]->[$i]);
        }
        print OUT "\n";
    }
    close OUT;
}

#===================
# BS計算
#===================
sub bs_calc_simple {

    # BSスキーム毎の外部ファイルにて emission_${path}_${bs}_${option}.txt を作成
    # &bs_calc ("${path}", "${bs}", "$bs_opt_val{$option}");
    # my @bsvals = ('CandC', 'revCC', 'CDC', 'IIT', 'IC');

    print "<p>bs_calc_simple 1 :: path, bs, option_var : $_[0], $_[1], $_[2]</p>\n" if $verbose;

    my $bs = $_[1];
    my $bs_script;
    if ( $bs eq 'CandC' or $bs eq 'revCC' or $bs eq 'IC' ) { $bs_script = './conv.pl'; }
    elsif ( $bs eq 'CDC' ) { $bs_script = './conv.pl'; }
    elsif ( $bs eq 'IIT' ) { $bs_script = './iit.pl'; }
#    elsif ( $bs eq 'BP'  ) { $bs_script = './conv.pl'; }
#    elsif ( $bs eq 'D'   ) { $bs_script = './conv.pl'; }
    else { &error(" BS scheme was not selected! : $bs "); }
    print "<p>bs_calc_simple 2 :: \$bs_script : $bs_script </p>\n"  if $verbose;

    my $cmd = "$perlexec $bs_script ./$datapath/pathgraph-emission_$_[0].txt ./$datapath/emission_$_[0]_$_[1]_$_[2].txt";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
        system($cmd);
        print "<p>bs_calc_simple 3 :: $cmd</p>\n"  if $verbose;
    } else {
        &error($cmd);
    }
}

#===========================
# Percapita, Intensity計算, (追加) Region aggregate
#===========================
sub capin_calc {
  # Obsolete----------------------------------------------------------------------
    # emission_${path}_${bs}_$bs_opt_val{$option}_$region.txt から percapita, または Intensityを作成
    # ARGV[0] : "$yaxis"

  # 変更--------------------------------------------------------------------------
    # emission_${path}_${bs}_$bs_opt_val{$option}.txt から percapita, または Intensityを作成,
    #                                               region aggregate を行う.
    # ARGV[0] : "${path}_${bs}_$bs_opt_val{$option}"
    # ARGV[1] : "$yaxis"
    # ARGV[2] : "$region"
    my $opt = $_[0];
    my $yaxis = $_[1];
    my $region = $_[2];
    my $aggropt = "";

    SWITCH: {
        $yaxis eq "percapita"      and $denom = "pop", last SWITCH;
        $yaxis eq "intensity"      and $denom = "GDP", last SWITCH;
        $yaxis eq "comparison_BaU" and $denom = "BaU" and $aggropt = "-l", last SWITCH;
        $yaxis eq "comparison_90"  and $denom = "90" and $aggropt = "-l", last SWITCH;
        $yaxis eq "pop"            and $aggropt = "-l", last SWITCH;
    }

    my $cmd = "$perlexec ./aggr.pl $aggropt ./$datapath/emission_$opt.txt ./$datapath/${yaxis}_${opt}_${region}.txt $region $denom";
    print "<p>capin_calc :: $cmd</p>\n" if $verbose;
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
      system($cmd);
    } else {
      &error($cmd);
    }
}

#===================
# BS結果グラフ
#===================
sub graph {
    my $cmd;
    our @ymaxarr;

    my $script;
    if ( $bsimgfile =~ /^[a-zA-Z0-9]+SA_/ ) {
        $script = $drawgraph_area;
    } else {
        $script = $drawgraph;
    }
    
    $cmd = "$perlexec $script $datapath/$bsfile.txt $imgpath/$bsimgfile.png";
    unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
        system($cmd);
    } else {
        &error($cmd);
    }
    print "<p>graph :: $cmd</p>\n" if $verbose;
    print "<p>graph :: $imgpath/${bsimgfile}.png generated.</p>\n" if $verbose;
    foreach (@ymaxarr) {
        $cmd = "$perlexec $script -$_ ./$datapath/$bsfile.txt $imgpath/${bsimgfile}_${_}.png";
        unless ( $cmd =~ /[^-a-zA-Z.\/ 0-9_]/ ) {
            system($cmd);
        } else {
            &error($cmd);
        }
    }
}

sub bs_option_read {
    if ($scheme_style eq "simple") {
        my $optfile = "$optiondir/${bs}_option.txt";
        open OPT, $optfile or die "Cannot open option file!";
        my $l = <OPT>;
        chomp $l;
        ($bs_opt_title,undef,undef) = split (/\t/, $l);
        my $i = 0;
        while (<OPT>) {
            chomp;
            my @arr = split (/\t/);
            push @bs_opt, $arr[0];
            $bs_opt_val{$arr[0]} = $arr[1];
            if ($arr[2] eq "default") {
                $bs_opt_default = $i;
            }
            $i++;
        }
        close OPT;
        $bs_opt_val{"-"} = "-";
    } else { # $scheme_style eq "contrib"
        my $optfile = "$optiondir/${bs}_option.txt";
        open OPT, $optfile or die "Cannot open option file!";
        my $l = <OPT>;
        chomp $l;
        (undef,$bs_opt_title,undef,undef) = split(/\t/,$l);
        while (<OPT>) {
            chomp;
            my @arr = split(/\t/);
            if ($arr[0] eq $path) {
                @bs_opt = split (/,/,$arr[1]);
                $bs_opt_default = $arr[3];
                my @valarr = split(/,/,$arr[2]);
                for (my $i=0;$i<=$#bs_opt;$i++) {
                    $bs_opt_val{$bs_opt[$i]} = $valarr[$i];
                }
                last;
            }
        }
        close OPT;
        $bs_opt_val{"-"} = "-";
    }
}

#===================
# BSオプション選択
#===================
sub bs_option_show {
    # bs_option_read が既に実行されていること.

    print <<"EOM";
    <h2>$bsvalsdesc{$bs}: Scheme option</h2>
    <form method="$method" action="$script">
      <p>
EOM

    if ($#bs_opt>=0) {
        print <<"EOM";
        $bs_opt_title:
        <select name="option">
EOM
        foreach (0..$#bs_opt) {
            print "          <option value=\"$bs_opt[$_]\"";
            print " selected=\"selected\"" if ( $option eq $bs_opt[$_] );
            print ">$bs_opt[$_]</option>\n";
        }
        print <<"EOM";
        </select>
        <input type="hidden" name="mode" value="bs_show" />
        <input type="hidden" name="path" value="$path" />
        <input type="hidden" name="bs" value="$bs" />
        <input type="hidden" name="region" value="$region" />
        <input type="hidden" name="yaxis" value="$yaxis" />
        <input type="submit" value=" Recalculation with this option " />
EOM
    } else {
        print "        There is no option for this scheme.\n";
    }
    print <<"EOM";
      </p>
    </form>
EOM
}

sub is_same_set {
    my @arr1 = sort @{$_[0]};
    my @arr2 = sort @{$_[1]};

    if ($#arr1 != $#arr2) {
        return 0; # false
    }

    my $err = 0;
    for (my $i=0; $i<=$#arr1; $i++) {
        $err ++ if $arr1[$i] ne $arr2[$i];
    }
    if ($err > 0) {
        return 0; # false
    }
    return 1; # true
}


"Just another true value";

__END__

# Local Variables:
# coding: euc-jp
# End:
