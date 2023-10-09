$( function() {
    $("#clear_button").click(function(){
        $("#obj_scenario").get(0).value = "";
        $("#pop_scenario").get(0).value = "";
        $("#objpop_base").get(0).value = "";
        $("#base_year").get(0).value = "";
        $("#conv_year").get(0).value = "";
        $("input[type=checkbox]","#tools").attr("checked",false);
        return false;
    });
    $("#reset_button").click(function(){
        $("#tools").get(0).reset();
        return false;
    });
    $("input[type=radio]","#scenario_inputs").click(function(){
        if ( $("input[type=radio]","#scenario_inputs").attr("checked") ) {
            $("#scenario_obj_and_pop").show();
            $("#scenario_obj_per_pop").hide();
        } else {
            $("#scenario_obj_and_pop").hide();
            $("#scenario_obj_per_pop").show();
        }
    });
    $("#obj_scenario_gr").click(function(){
        $("#obj_s_gf_opt").toggle();
    });
    $("#pop_scenario_gr").click(function(){
        $("#pop_s_gf_opt").toggle();
    });
    $("#objpop_scenario_gr").click(function(){
        $("#objpop_s_gf_opt").toggle();
    });
    $("#s_input_2or3_3").attr("checked","checked");
    $("#scenario_obj_and_pop").show();
    $("#scenario_obj_per_pop").hide();
    $("#obj_s_gf_opt").hide();
    $("#pop_s_gf_opt").hide();
    $("#objpop_s_gf_opt").hide();
});
