var SortableTable = function () {
    this.initialize.apply(this, arguments);
}
SortableTable.prototype = {
    initialize: function (id) {
        this.id = id;
        this.table_data = {};
        var tbodys = $(".table_" + this.id +"_tbody");
        for (var i=0;i<tbodys.length;i++) {
            var region = tbodys[i]["id"].replace("table_" + this.id +"_tbody_","");
            this.table_data[region]=new Array();
        }
        for (var region in this.table_data) {
            var arr = new Array();
            var tds = $("#table_" + this.id + "_tbody_" + region + ">tr>td");
            for (var i=0;i<tds.length;i++) {
                arr.push( eval($(tds[i]).text()) );
            }
            this.table_data[region] = arr;
        }
        this.append_sort_link_to_thead();
    },
    append_sort_link_to_thead: function () {
        var ths = $("#" + this.id + ">thead>tr>th");
        var upsymbol = "&#9651;"; // or = "&uarr;"
        var downsymbol = "&#9661;"; // or ="&darr;"
        for (var i=0;i<ths.length;i++) {
            $(ths[i]).append("&nbsp;<a href=\"javascript:st_"+this.id+".sort_table(" + i +",0)\">" + upsymbol + "</a><a href=\"javascript:st_"+this.id+".sort_table(" + i +",1)\">" + downsymbol + "</a>");
        }
    },
    sort_table: function (col,order) {
        var regions = new Array();
        for (var region in this.table_data) {
            regions.push(region);
        }
        if ( col == 0 ) {
            regions.sort();
        } else {
            var data = this.table_data;
            regions.sort(function (a,b) { return data[a][col-1] - data[b][col-1]; });
        }
        if (order == 0) {
            regions.reverse();
        }
        for (var i=0;i<regions.length;i++) {
            $("#table_"+this.id+"_tbody_" + regions[i]).insertAfter("#"+this.id+">thead");
            if ($("#table_" + this.id + "_tbody_desc_" + regions[i]).length > 0) {
                $("#table_"+this.id+"_tbody_desc_" + regions[i]).insertAfter("#table_"+this.id+"_tbody_" + regions[i]);
            }
        }
    }
}

var st_BSTable;
var st_BSTable_Contrib;

$(function() {
    st_BSTable = new SortableTable("BSTable");
    if ($("#BSTable_Contrib").length > 0) {
        st_BSTable_Contrib = new SortableTable("BSTable_Contrib");
    }
});
