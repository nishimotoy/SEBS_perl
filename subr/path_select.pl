#
#  path_select.pl
#
# Last updated $Date: 2007-12-09 18:01:32 JST$

#================
# パス選択画面
#================
sub path_select {
	$mode = "path_select";

    %formvals = (
        scenario => ["B2"],
        ghg => ["-", "450", "475", "500", "550", "600"],
#        temp_rise => ["-","2.0","2.2","2.4","2.6","2.8","3.0","3.2","3.4","3.6","3.8","4.0"],
        temp_rise => ["-","17","23","29","35"],
        climate_sensitivity => ["-"],
#        climate_sensitivity => ["1.760","2.113","2.412","2.498","2.700","3.000","3.334","3.603","3.732","4.259","5.114"],
        StartEmission => ["KyotoBaU"],
#        start_year => [2010,2020,2030],
        start_year => [2010],
        target_year => [2030,2050,2100],
#        base_year => [1990,2000,2004,2007,2010],
        base_year => [1990,2000],
        factor => [20,30,40,50,60,70,80,90,100],
        );
    %formdefval = (
        scenario => "B2",
        ghg => "-",
        temp_rise => "-",
#        climate_sensitivity => "3.000",
        climate_sensitivity => "-",
        StartEmission => "KyotoBaU",
        start_year => 2010,
        target_year => 2050,
        base_year => 1990,
        factor => 50,
        );

    @nullaqrr = ("","","","","","","","","","","","","","","","","","","","");

    foreach (keys(%formvals)) {
        $formarr{$_} = @nullarr[0..$#{$formvals{$_}} ];
        $i = arrindex($formvals{$_},$in{$_});
        if ($i == -1) {
            $i = arrindex($formvals{$_}, $formdefval{$_});
        }
#        print $_, "  ", $i, "<br>\n";
        if (1) {
            $formarr{$_}[$i] = 'selected="selected" ';
        } else {
            $formarr{$_}[$i] = 'checked="checked" ';
        }
    }

    my $js = <<"EOM";
  <script type="text/javascript">
    // <![CDATA[
    var emissiontarget = "$in{'emissiontarget'}";
    // ]]>
  </script>
  <script type="text/javascript" src="$jsdir/path_select.js"></script>
EOM

	&header(\$js);

    print <<"EOM";
    <h1>$modevalsdesc{$mode}</h1>

EOM
    print << "EOM";
    <div id="selectBox" class="hidden">
      <form id="selectRadio" action="#">
        <div>
          <input type="radio" name="path_select_radio" id="path_Scenario" /><label for="path_Scenario" class="inline">Scenario &amp; climate targets</label>
          or
          <input type="radio" name="path_select_radio" id="path_EmissionTarget" /><label for="path_EmissionTarget" class="inline">Emission targets</label>
        </div>
      </form>
    </div>

    <div id="scenarioForm">
      <h2>Future Scenario &amp; Climate Targets</h2>
      <p>
        Please select a future scenario and climate targets.
      </p>
      <form id="scForm" method="$method" action="$script">
        <fieldset>
          <legend>Future Scenario (SRES storyline)</legend>
          <label for="input_scenario_A1B"><input name="scenario" id="input_scenario_A1B" value="A1B" type="radio" disabled="disabled" />A1B (in preparation)</label>
          <label for="input_scenario_A2"><input name="scenario" id="input_scenario_A2" value="A2" type="radio" disabled="disabled" />A2 (in preparation)</label>
          <label for="input_scenario_B1"><input name="scenario" id="input_scenario_B1" value="B1" type="radio" disabled="disabled" />B1 (in preparation)</label>
          <label for="input_scenario_B2"><input name="scenario" id="input_scenario_B2" value="B2" type="radio" checked="checked" />B2</label>
        </fieldset>
        <fieldset>
          <legend>Climate Targets (multiple selection allowed)</legend>
          <table class="select">
            <tr>
              <th>Stabilized GHG concentration (<a href="#note1">*1</a>) level:<br /><span class="note">(<a name="note1">*1</a>) : total GHGs including 6GHGs by Kyoto protocol</span></th>
              <td>
                <select name="ghg" size="4">
EOM
    my $i = 0;
    foreach (@{$formvals{"ghg"}}) {
        print "                  <option value=\"$_\" $formarr{'ghg'}[$i]>" . (($_ eq "-")?"no specification":($_ . " ppm"))  . "</option>\n";
        $i++;
    }
    print << "EOM";
                </select>
              </td>
            </tr>
            <tr>
              <th>Limit to global temperature (<a href="#note2">*2</a>) increase:<br /><span class="note">(<a name="note2">*2</a>) : from pre-industrial level to stablizaiton level</span></th>
              <td>
                <select name="temp_rise" size="4">
EOM
    my $i = 0;
    foreach (@{$formvals{"temp_rise"}}) {
#        print "                  <option value=\"$_\" $formarr{'temp_rise'}[$i]>" . ($_ eq "-"?"no specification":"$_ &deg;C" ."</option>\n";
        print "                  <option value=\"$_\" $formarr{'temp_rise'}[$i]>" . ($_ eq "-"?"no specification":((sprintf "%.1f", $_/10) . " &deg;C")) ."</option>\n";
        $i++;
    }
    print << "EOM";
                </select>
              </td>
            </tr>
<!--
            <tr>
              <th>Climate Sensitivity:</th>
              <td>
                <select name="climate_sensitivity" size="4">
EOM
    my $i = 0;
    foreach (@{$formvals{"climate_sensitivity"}}) {
        print "                  <option value=\"$_\" $formarr{'climate_sensitivity'}[$i]>$_ &deg;C</option>\n";
        $i++;
    }
    print << "EOM";
                </select>
              </td>
            </tr>
-->
          </table>
        </fieldset>
        <p>
          <input type="hidden" name="start_year" value="2010" />
          <input type="hidden" name="mode" value="path_show" />
          <input type="submit" value=" NEXT " />
        </p>
      </form>
    </div><!-- id="scenarioForm" -->

    <div id="emissiontargetForm">
      <h2>Emission Targets</h2>
      <form id="etForm" method="$method" action="$script">
        <table class="select">
          <tr>
            <th>Start year emission:</th>
            <td>
              <select name="StartEmission">
                <option value="KyotoBaU" $formarr{'StartEmission'}[0]>KyotoBaU</option>
              </select>
            </td>
          </tr>
          <tr>
            <th>Start year:</th>
            <td>
              <select name="start_year">
                <option value="2010" $formarr{'start_year'}[0]>2010</option>
<!--
                <option value="2020" $formarr{'start_year'}[1]>2020</option>
                <option value="2030" $formarr{'start_year'}[2]>2030</option>
-->
              </select>
            </td>
          </tr>
          <tr>
            <th>Target year:</th>
            <td>
              <select name="target_year">
                <option value="2030" $formarr{'target_year'}[0]>2030</option>
                <option value="2050" $formarr{'target_year'}[1]>2050</option>
                <option value="2100" $formarr{'target_year'}[2]>2100</option>
              </select>
            </td>
          </tr>
          <tr>
            <th>Target emission:</th>
            <td>
              <select name="factor">
                <option value="20" $formarr{'factor'}[0]>20 %</option>
                <option value="30" $formarr{'factor'}[1]>30 %</option>
                <option value="40" $formarr{'factor'}[2]>40 %</option>
                <option value="50" $formarr{'factor'}[3]>50 %</option>
                <option value="60" $formarr{'factor'}[4]>60 %</option>
                <option value="70" $formarr{'factor'}[5]>70 %</option>
                <option value="80" $formarr{'factor'}[6]>80 %</option>
                <option value="90" $formarr{'factor'}[7]>90 %</option>
                <option value="100" $formarr{'factor'}[8]>100 %</option>
              </select> of the emission of 
              <select name="base_year">
                <option value="1990" $formarr{'base_year'}[0]>1990</option>
                <option value="2000" $formarr{'base_year'}[1]>2000</option>
              </select>
            </td>
          </tr>
        </table>
        <p>
          <input type="hidden" name="mode" value="path_show" />
          <input type="hidden" name="emissiontarget" value="true" />
          <input type="submit" value=" NEXT " />
        </p>
      </form>
    </div><!-- id="emissiontargetForm" -->
EOM

	&footer;
	exit;
}

1;

# Local Variables:
# coding: euc-jp
# End:
