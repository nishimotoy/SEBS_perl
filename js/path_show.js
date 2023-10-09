function columnize (id) {
    if ($("#"+id+">thead>tr>th").length >= 18) {
        $("#main").append("<p id=\""+id+"_columnintv_links\">Display columns only at every <a href=\"javascript:column_hide('"+id+"',1)\">1</a>, <a href=\"javascript:column_hide('"+id+"',2)\">2</a> or <a href=\"javascript:column_hide('"+id+"',3)\">3</a>.</p>");
        $("#"+id+"_columnintv_links").insertBefore("#"+id);
        column_hide(id,2);
    }
}

function column_hide (id,n) {
    var lst = $("#"+id+" tr");
    for (var i=0;i<lst.length;i++) {
        var l = $(lst[i]).children();
        for (var j=0;j<l.length;j++) {
            if (j!=0 && j!=l.length-1 && (j-1) % n != 0) {
                $(l[j]).hide();
            } else {
                $(l[j]).show();
            }
        }
    }
    $("#"+id+"_columnintv_links>a").attr("style","");
    $("#"+id+"_columnintv_links>a:contains("+n+")").attr("style","color: red;");
}

$(function () {
    columnize("PathTable");
});

