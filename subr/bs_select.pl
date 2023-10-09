#
#  bs_select.pl
#
# Last updated $Date: 2007-12-11 23:41:35 JST$

#====================
# BSスキーム選択画面
#====================
sub bs_select {
	my @bsvals  = ('CandC', 'revCC', 'IIT', 'IC', 'BP', 'CECP' , 'CDC', 'D');
	my @bsnames = ('Contraction &amp; Convergence (C&amp;C)',
			  'Revised C&amp;C',
			  'Intensity Improvement Target(IIT)',
			  'Intensity Convergence',
			  'Brazilian Proposal',
			  'Cumulative Emission per Cumulative Population',
			  'Common Differentiated Convergence (CDC)',
			  'Specify Participating Countries and Participating Year');

	$path = "$in{'path'}";
	if ( arrindex(\@bsvals,$in{'bs'}) == -1 || arrindex(\@bsvals,$in{'bs'}) >= $#bsvals-2 ) {
        $in{'bs'} = 'CandC';
    }

    my $js = <<"EOM";
  <script type="text/javascript" src="$jsdir/bs_select.js"></script>
EOM

	&header(\$js);


	print <<"EOM";
    <h1>@modevalsdesc{$mode}</h1>
      <div id="bs_sel_box">
        <div id="bs_select">
          <p>Please select a burden sharing scheme.</p>
          <form method="$method" action="$script">
            <fieldset>
              <legend>Burden sharing schemes</legend>
EOM
	foreach (0..$#bsvals) {
		print "              <label for=\"input_bs_$bsvals[$_]\"><input name=\"bs\" id=\"input_bs_$bsvals[$_]\" value=\"$bsvals[$_]\" type=\"radio\"";
        print " checked=\"checked\"" if ( $in{'bs'} eq $bsvals[$_] );
        print " disabled=\"disabled\"" if $_ >= $#bsvals-2;

#		print " /><a onclick=\"disp_desc('$bsvals[$_]')\" href=\"\#\" >";
#		print " /><a onclick=\"disp_desc('$bsvals[$_]')\" href=\"\#$bsvals[$_]_desc\" >";
		print " /><a href=\"javascript:disp_desc('$bsvals[$_]')\" >";
#		print " /><a href=\"./docs/$bsvals[$_].html\" target=\"bs_docs\">";

		print "$bsnames[$_]</a>";
        print " <span class=\"emph\">New!</span>" if $bsvals[$_] eq "BP";
        print "</label>\n";
	}
# 	foreach ($#bsvals-2..$#bsvals) {
# 		print "              <label><input name=\"bs\" value=\"$bsvals[$_]\" type=\"radio\"";
# 		print " disabled=\"\disabled\"";
# #		print " /><a onclick=\"disp_desc('$bsvals[$_]')\" href=\"\#\" >";
# 		print " /><a href=\"javascript:disp_desc('$bsvals[$_]')\" >";
# #		print " /><a href=\"./docs/$bsvals[$_].html\">";
# #		print " /><a href=\"./docs/$bsvals[$_].html\" target=\"bs_docs\">";
# 		print " $bsnames[$_]</a> (in preparation)</label>\n";
# 	}
	print <<"EOM";
            </fieldset>
            <p>
              <input type="hidden" name="mode" value="bs_show" />
              <input type="hidden" name="path" value="$path" />
              <input type="submit" value=" NEXT : Result of burden-sharing " />
            </p>
          </form>
        </div><!-- id="bs_select" -->
        <div id="bs_desc">
          <div id="howto_desc" class="bs_desc_s">
          </div>
          <div id="CandC_desc" class="bs_desc_s">
            <h4>Contraction &amp; Convergence (C&amp;C)</h4>
            <p>
              C&amp;C is a proposal in which country per capita
              emissions become the same after a convergence year.
              After convergence year, the emission allowance of a country
              is decided by the country\'s population.
              Before convergence year, the emission 
              allowance of a countey is interpolated 
              between the emission of the start year 
              and the emission of the convergence 
              year in the following figure.
            </p>
            <p>
              <img src="docs/CandC.png" alt="CandC.png" width="447" height="245" />
            </p>
          </div>
          <div id="revCC_desc" class="bs_desc_s">
            <h4>Revised C&amp;C</h4>
            <p>
              There is a disadvantages in the convergence process for the developping 
              countries under the C&amp;C. A small emission country in the start year 
              (red dotted line) is allocated a small emission less than global per capita 
              emission(grey line) until convergence year.
              Resived C&amp;C provides the diffenrent convergence process for the 
              developping countries. 
              Before convergence year, the projected BaU emission is allocated for a 
              developing country till exceeding the global per capita emission.
              After exceeding it, the global per capita emission is allocated for a 
              developing country.
            </p>
            <p>
              Revesed area of this scheme comparing to the simple C&amp;C is derected 
              in the following figure.
            </p>
            <p>
              <img src="docs/revised.png" alt="revised.png" width="447" height="245" />
            </p>
          </div>
          <div id="IIT_desc" class="bs_desc_s">
            <h4>Intensity Improvement Target (IIT)</h4>
            <p>
              Here, the intensity means the GHG emission per GDP. 
              IIT is based on the assumption that all countries should improve 
              their emission intensity.
              The annual improvement rate of the emission intensity is introduced 
              and is decided by the global emission allowance pathway and the 
              world GDP growth.
              All countries should reduce their emission intensity at the above 
              annual improvement rate. 
              A region with larger emission intensity, i.e., an inefficient region, 
              is required larger reduction, whereas a region with smaller emission 
              intensity, i.e., an efficient region, is given a relatively small 
              reduction requirement.
            </p>
          </div>
          <div id="IC_desc" class="bs_desc_s">
            <h4>Intensity Convergence</h4>
            <p>
              Here, the intensity means the GHG emission per GDP. 
              Intensity Convergence is based on the assumption that all countries 
              improves their emission intensity and the intensity of all countries 
              become same after the convergence year. 
            </p>
            <p>
              After convergence year, the emission allowance of a country is decided by 
              the country\'s GDP.
              Before convergence year, the emission allowance of a countey is interpolated 
              between the intensity of the start year and the intensity of the convergence 
              year.
            </p>
          </div>
          <div id="BP_desc" class="bs_desc_s">
            <h4>Brazilian Proposal</h4>
            <p>
              The Brazilian proposal is that the regional
              emission reduction target should be decided based on the contribution
              to the temperature rise originating from the past GHG emissions.
              In SEBS, using the regional contributions to temperature rise
              estimated from the regional historical emissions, the regional future
              emissions are distributed to decrease the regional gap of the percapita
              contributions therefore, a region with large historical emission has
              small future emission and a region with small historical emission has
              relatively large future emission.
            </p>
            <p>
              SEBS provides one option on Brazilian proposal. The option is the
              ratio of percapita contributions in 2200 between the region with the
              most highist percapita contribution and the most lowest region
              percapita contribution. You can change the ratio from the range SEBS
              prepared.
            </p>
            <p>
              <img src="docs/BP.png" alt="BP.png" width="447" height="245" />
            </p>
          </div>
          <div id="CECP_desc" class="bs_desc_s">
            <h4>Cumulative Emission per Cumulative Population</h4>
            <p>
              in preparation
            </p>
          </div>
          <div id="CDC_desc" class="bs_desc_s">
            <h4>Common Differentiated Convergence (CDC)</h4>
            <p>
              in preparation
            </p>
          </div>
          <div id="D_desc" class="bs_desc_s">
            <h4>Specify Participating Countries and Participating Year</h4>
            <p>
              in preparation
            </p>
          </div>
        </div><!-- id="bs_desc" -->
      </div><!-- id="bs_sel_box" -->
EOM
	&footer;
	exit;
}


1;

# Local Variables:
# coding: euc-jp
# End:
