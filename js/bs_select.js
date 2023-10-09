function append_reset_link() {
    var desc_box = $("#bs_desc");
    $("#howto_desc",desc_box).append("<p>Please click the burden sharing scheme name on the left side.</p>");
    $("div[id!='howto_desc']",desc_box).append("<p><a href=\"javascript:disp_desc('howto')\">Reset this description part</a></p>");
}

function disp_desc(s) {
    var desc_box = $("#bs_desc");
    $(".bs_desc_s",desc_box).hide();
    $("#" + s + "_desc",desc_box).show();
}

$(function () {
    append_reset_link();
    disp_desc("howto");
});
