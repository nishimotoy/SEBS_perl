var regionArray_sn = {};
var regionArrProced = {};
var table_data_desc = {};

function toggle_BSTable_desc (region) {
    if (!regionArrProced[region]) {
        regionArrProced[region] = true;
        var ccs = regionArray_sn[region];
        var upsymbol = "&#9651;"; // or = "&uarr;"
        var downsymbol = "&#9661;"; // or ="&darr;"

        $("#main").append("<tbody id=\"table_BSTable_tbody_desc_" + region + "\" class=\"table_BSTable_tbody_desc\"></tbody>");
        $("#table_BSTable_tbody_desc_" + region).insertAfter("#table_BSTable_tbody_" + region).hide();

        if (ccs.length>1) {
            read_table_desc(region);
            $("#table_BSTable_tbody_desc_" + region).append("<tr id=\"desc_" + region + "_head\"></tr>");
            for (var i=0;i<$("#BSTable>thead>tr>th").length;i++) {
                $("#desc_" + region + "_head").append("<th><a href=\"javascript:sort_table_desc('" + region +"'," + i +",0)\">" + upsymbol + "</a><a href=\"javascript:sort_table_desc('"+region+"'," + i +",1)\">" + downsymbol + "</a></th>");
            }
        }
        for (var i=0;i < ccs.length; i++) {
            var t = $("#table_CC_row_" + ccs[i]);
            t.appendTo("#table_BSTable_tbody_desc_" + region);
            if (ccs[i].substring(0,5) == "Other") {
                var th = $("#table_CC_row_" + ccs[i] + ">th");
                var text = $(th).text();
                $(th).empty();
                $(th).append("<a href=\"javascript:toggle_otherCCs_desc('"+ccs[i]+"');\">"+text+"</a><span id=\"BSTable_" + ccs[i] +"_desc\"><br />" + otherCCsDesc[ccs[i]] + "</span>");
                $("#BSTable_" + ccs[i] + "_desc").hide();
            }
        }
    }
    $("#table_BSTable_tbody_desc_" + region ).toggle();
}

function toggle_otherCCs_desc(cc) {
    $("#BSTable_" + cc + "_desc").toggle();
}


function hide_all_BSTable_desc() {
    $("tbody.table_BSTable_tbody_desc:visible").hide();
}

function read_table_desc (region) {
    var ccs = regionArray_sn[region];
    var tab = {};
//    alert(ccs);
    for (var i in ccs) {
        var arr = new Array();
        var tds = $("#table_CC_row_" + ccs[i] + ">td");
        for (var j=0;j<tds.length;j++) {
            arr.push( eval($(tds[j]).text()) );
        }
        tab[ccs[i]] = arr;
    }
    table_data_desc[region] = tab;
}

function sort_table_desc (region,col,a) {
    var ccs = regionArray_sn[region];
    if ( col == 0 ) {
        for (var i in ccs) {
            ccs[i] = ccs[i].replace("Other","|Other");
        }
        ccs.sort();
        for (var i in ccs) {
            ccs[i] = ccs[i].replace("|","");
        }
    } else {
        ccs.sort(function(a,b) {return table_data_desc[region][a][col-1] - table_data_desc[region][b][col-1];});
    }
    if (a == 0) {
        ccs.reverse();
    }
    for (var i=0;i<ccs.length;i++) {
        $("#table_CC_row_" + ccs[i]).insertAfter("#desc_" + region + "_head");
    }
}

function regionArray_preproc () {
    for (var region in regionArray) {
        var reg = region.replace(/ /g,"").replace(/,/g,"");
        var arr = new Array();
        for (var cc in regionArray[region]) {
            arr.push(regionArray[region][cc].replace(/ /g,"").replace(/,/g,""));
        }
        regionArray_sn[reg] = arr;
    }
}

$(function() {
    regionArray_preproc();
    var url = "sebs.cgi?mode=cctable&" + urlOpt + "&maxexp=" + table_BSTable_maxexp;
//    alert(url);
    $.get(url,'get',function(cont,status) {
        $("table#BSTable").append(cont);
        $('#table_CC_tbody').hide();
        for (var i in regionArray_sn) {
            $("table[id='BSTable']>tbody[id='table_BSTable_tbody_" + i + "']>tr>th>span").wrap("<a href=\"javascript:toggle_BSTable_desc('" + i + "')\"></a>");
        }
        $("#main").append("<p id=\"hide_BSTable_desc_link\"><a href=\"javascript:hide_all_BSTable_desc()\">Hide all region description in the table above.</a></p>");
        $("#hide_BSTable_desc_link").insertAfter("#BSTable");
    });
});

