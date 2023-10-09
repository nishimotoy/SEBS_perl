var regionArrProced = {};
var regionArray_sn={};
var twd_BSTable;
var twd_BSTable_Contrib;

var TableWithDescription = function () {
    this.initialize.apply(this, arguments);
}
TableWithDescription.prototype = {
    initialize: function (id) {
        this.id = id;
        this.regionArrProced = {};
        for (var region in regionArray_sn) {
            $("table[id="+this.id+"]>tbody[id=table_"+this.id+"_tbody_"+region+"]>tr>th>span").wrap("<a href=\"javascript:twd_"+this.id+".toggle_desc('"+region+"')\"></a>");
        }
        $("#main").append("<p id=\"hide_"+this.id+"_desc_link\"><a href=\"javascript:twd_"+this.id+".hide_all_desc()\">Hide all region description in the table above.</a></p>");
        $("#hide_"+this.id+"_desc_link").insertAfter("#"+this.id);
    },
    hide_all_desc: function () {
        $("tbody.table_"+this.id+"_tbody_desc:visible").hide();
    },
    toggle_desc: function (region) {
        if (!this.regionArrProced[region]) {
            this.regionArrProced[region] = 1;
            var cols = $("#"+this.id+">thead>tr>th").length;

            var ccs_with_desc = new Array();
            var content = "";
            for (var i in regionArray[region]) {
                if (i>0) {
                    content = content + ", ";
                }
                if (regionArray[region][i].substring(0,5) == "Other") {
                    var cc = regionArray[region][i].replace(/ /g,"").replace(/,/g,"");
                    content = content + "<a href=\"javascript:toggle_otherCCs_desc('"+this.id+"','"+regionArray_sn[region][i]+"');\">"+regionArray[region][i]+"</a><span id=\""+this.id+"_"+cc+"_desc\"> ("+otherCCsDesc[regionArray_sn[region][i]]+")</span>";
                    ccs_with_desc.push(cc);
                } else {
                    content = content + regionArray[region][i];
                }
            }
            content = content + ".";

            $("#" + this.id).append("<tbody id=\"table_"+this.id+"_tbody_desc_" + region + "\" class=\"table_"+this.id+"_tbody_desc\"><tr><th colspan=\""+ cols + "\"  style=\"text-align:left;\">"+content+"</th></tr></tbody>");
            $("#table_"+this.id+"_tbody_desc_" + region).insertAfter("#table_"+this.id+"_tbody_" + region).hide();
            for (i in ccs_with_desc) {
                $("#"+this.id+"_"+ccs_with_desc[i]+"_desc").hide();
            }
        }
        $("#table_"+this.id+"_tbody_desc_" + region ).toggle();
    }
}

function toggle_otherCCs_desc(id,cc) {
    $("#"+id+"_" + cc + "_desc").toggle();
}

function regionArray_preproc () {
    for (var region in regionArray) {
        var reg = region.replace(/ /g,"").replace(/,/g,"");
        var arr = new Array();
        for (var cc in regionArray[region]) {
            arr.push(regionArray[region][cc].replace(/ /g,"").replace(/,/g,""));
        }
        regionArray[reg] = regionArray[region];
        regionArray_sn[reg] = arr;
    }
}

function columnize (id) {
    if ($("#"+id+">thead>tr>th").length >= 18) {
        $("#main").append("<p id=\""+id+"_columnintv_links\">Display columns only at every <a href=\"javascript:column_hide('"+id+"',1)\">1</a>, <a href=\"javascript:column_hide('"+id+"',2)\">2</a> or <a href=\"javascript:column_hide('"+id+"',3)\">3</a>.</p>");
        $("#"+id+"_columnintv_links").insertBefore("#"+id);
        column_hide(id,3);
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
    regionArray_preproc();
    twd_BSTable = new TableWithDescription("BSTable");
    twd_BSTable_Contrib = new TableWithDescription("BSTable_Contrib");
    columnize("BSTable");
    columnize("BSTable_Contrib");
});

