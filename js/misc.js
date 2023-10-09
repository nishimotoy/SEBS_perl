String.prototype.replaceAll = function (b,a) {
    return this.split(b).join(a);
};

Array.prototype.uniq = function () {
    var r = [];
    for (var i = 0, s = {}; i < this.length; i++) {
        if (!s[this[i]])
            r.push(this[i]);
        s[this[i]] = true;
    }
    return r;
};

function arrindex(array, val) {
    var idx = -1;
    for (var i=0; i<array.length; i++) {
        if (array[i] == val)
            idx = i;
    }
    return idx;
}

function array_equal(a1,a2) {
    if (a1.length != a2.length) {
//        alert("array_equal length mismatch!" + a1.length + "vs" + a2.length);
        return false;
    } else {
        var tf = true;
        for (var i=0; i<a1.length; i++) {
            if (a1[i]!=a2[i]) {
//                alert("array_equal " + a1[i] + " " + a2[i] + "<br>");
                tf=false;
            }
        }
        return tf;
    }
}

