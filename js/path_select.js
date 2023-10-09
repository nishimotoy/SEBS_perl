function selectForm(v) {
    var s = $("#scenarioForm");
    var e = $("#emissiontargetForm");
    if (v == 'scenario') {
        s.show();
        e.hide();
    } else {
        s.hide();
        e.show();
    }
}
$(function(){
    $("#selectBox").show();
    if (emissiontarget == "true") {
        $("#path_EmissionTarget").attr("checked","checked");
        selectForm('emissiontarget');
    } else {
        $("#path_Scenario").attr("checked","checked");
        selectForm('scenario');
    }

    $("#path_Scenario").click(function(){
        selectForm('scenario');
    });
    $("#path_EmissionTarget").click(function(){
        selectForm('emissiontarget');
    });
    $("#main").attr("style","width: 75%;");
});
