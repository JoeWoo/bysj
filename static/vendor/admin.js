
$(document).ready(function() {
    var path = window.location.pathname;

    var site;
    for (var i = path.length-1; i >= 0 ; i--) {
        if (path.charAt(i)=="/"){
            site = i;
            break;
        }
    };
    console.log(site);
    var page = path.substring(site+1,path.length);
    console.log(page);
    if (page=="admin_admin"){
        init_admin();
    }else if(page =="admin_teacher"){
        init_teacher();
    }else if(page == "admin_student"){
        init_student();
    }else if(page == "admin_tips"){
        init_tip();
    }else if(page == "edit_tip"){
         render_editor();
    }

});

function expand_adlevel(value) {
    console.log(value);
    for (var i = 0; i < 5; i++) {
        var temp = $("#hidden-add #adlevel" + i);
        temp.val(value.charAt(i));
        if (value.charAt(i) == "1") {
            temp.attr("checked", true);
        } else {
            temp.attr("checked", false);
        }
    };
    var checkboxlist = $('#hidden-add').html();
    return checkboxlist;
};

function init_admin() {
    $('#admin').dataTable({
        "language": {
                "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/admin/all",
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                console.log(data);
                for (var i = 0, ien = data.length; i < ien; i++) {
                    data[i][0] = "<input type='text' id='aid-" + data[i][4] + "' name='aid-" + data[i][4] + "' value='" + data[i][0] + "'>";
                    data[i][1] = "<input type='text' id='name-" + data[i][4] + "' name='name-" + data[i][4] + "' value='" + data[i][1] + "'>";
                    data[i][2] = "<input type='text' id='login-" + data[i][4] + "' name='login-" + data[i][4] + "' value='" + data[i][2] + "'>";
                    data[i][3] = expand_adlevel(data[i][3]);
                    data[i][4] = "<div><a id=\"a" + data[i][4] + "\" class=\"btn btn-success btn-sm\" onclick=\"update_admin(" + data[i][4] + ");\">更改</a><a id=\"a" + data[i][4] + "\" class=\"btn btn-danger btn-sm\" onclick=\"delete_admin(" + data[i][4] + ");\">删除</a></div>";
                }
                return data;
            }
        }
    });
    var head3 = $('#a-new tbody');
    var adminaddtr = "<tr id=\"adminadd\" class=\"\"><td><input id=\"aid\" value=\"\" class=\"form-control\"></td><td><input id=\"name\" value=\"\" class=\"form-control\"></td><td><input id=\"login\" value=\"\" class=\"form-control\"></td><td><label class=\"checkbox-inline\"><input type=\"checkbox\"  class=\"adle\" id=\"adlevel0\" value=\"0\">管理员管理</label><label class=\"checkbox-inline\"><input type=\"checkbox\"  class=\"adle\" id=\"adlevel1\" value=\"0\">教师管理</label><label class=\"checkbox-inline\"><input type=\"checkbox\" id=\"adlevel2\" value=\"0\" class=\"adle\" >学生管理</label><label class=\"checkbox-inline\"><input type=\"checkbox\" id=\"adlevel3\" value=\"0\" class=\"adle\" >公告管理</label><label class=\"checkbox-inline\"><input type=\"checkbox\" id=\"adlevel4\" value=\"0\" class=\"adle\" >公告发布</label></td><td><a id=\"add_admin\"  onclick=\"add_admin();\" class=\"btn btn-primary btn-sm col-md-11\" >添加</a></td></tr>";
    head3.html(adminaddtr);
};

function init_teacher() {
    $('#teacher').dataTable({
         "language": {
                "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/teacher/all",
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                console.log(data);
                for (var i = 0, ien = data.length; i < ien; i++) {
                    data[i][0] = "<input type='text' id='tid-" + data[i][3] + "' name='tid-" + data[i][3] + "' value='" + data[i][0] + "'>";
                    data[i][1] = "<input type='text' id='name-" + data[i][3] + "' name='name-" + data[i][3] + "' value='" + data[i][1] + "'>";
                    data[i][2] = "<input type='text' id='login-" + data[i][3] + "' name='login-" + data[i][3] + "' value='" + data[i][2] + "'>";
                    data[i][3] = "<div><a id=\"t" + data[i][3] + "\" class=\"btn btn-success btn-sm\" onclick=\"update_teacher(" + data[i][3] + ");\">更改</a><a id=\"t" + data[i][3] + "\" class=\"btn btn-danger btn-sm\" onclick=\"delete_teacher(" + data[i][3] + ");\">删除</a></div>";
                }
                return data;
            }
        }
    });
    var head = $('#t-new tbody');
    var teacheraddtr = "<tr id=\"teacheradd\"><td><input id=\"tid\" value=\"\" class=\"form-control\"></td><td><input id=\"name\" value=\"\" class=\"form-control\"></td><td><input id=\"login\" value=\"\" class=\"form-control\"></td><td><a id=\"add_admin\"  onclick=\"add_teacher();\" class=\"btn btn-primary btn-sm col-md-14\" >添加</a></td></tr>";
    head.html(teacheraddtr);
};

function init_student() {
    $('#student').dataTable({
         "language": {
                "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/student/all",
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                console.log(data);
                for (var i = 0, ien = data.length; i < ien; i++) {
                    data[i][0] = "<input type='text' id='sid-" + data[i][5] + "' name='sid-" + data[i][5] + "' value='" + data[i][0] + "'>";
                    data[i][1] = "<input type='text' id='name-" + data[i][5] + "' name='name-" + data[i][5] + "' value='" + data[i][1] + "'>";
                    data[i][2] = "<input type='text' id='stype-" + data[i][5] + "' name='stype-" + data[i][5] + "' value='" + data[i][2] + "'>";
                    data[i][3] = "<input type='text' id='dept-" + data[i][5] + "' name='dept-" + data[i][5] + "' value='" + data[i][3] + "'>";
                    data[i][4] = "<input type='text' id='login-" + data[i][5] + "' name='login-" + data[i][5] + "' value='" + data[i][4] + "'>";
                    data[i][5] = "<div><a id=\"s" + data[i][5] + "\" class=\"btn btn-success btn-sm\" onclick=\"update_student(" + data[i][5] + ");\">更改</a><a id=\"s" + data[i][5] + "\" class=\"btn btn-danger btn-sm\" onclick=\"delete_student(" + data[i][5] + ");\">删除</a></div>";
                }
                return data;
            }
        }
    });
    var head2 = $('#s-new tbody');
    var studentaddtr = "<tr id=\"studentadd\"><td><input id=\"sid\" value=\"\" class=\"form-control\"></td><td><input id=\"name\" value=\"\" class=\"form-control\"></td><td><input id=\"stype\" value=\"\" class=\"form-control\"></td><td><input id=\"dept\" value=\"\" class=\"form-control\"></td><td><input id=\"login\" value=\"\" class=\"form-control\"></td><td><a id=\"add_admin\"  onclick=\"add_student();\" class=\"btn btn-primary btn-sm col-md-11\" >添加</a></td></tr>";
    head2.html(studentaddtr);
};

function init_tip() {
    $('#tip').dataTable({
             "language": {
                "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
             },
            "ajax": {
                "url": "/secure/tip/all",
                "type": "POST",
                "dataSrc": function(json) {
                    var data = json.data;
                    console.log(data);
                    for (var i = 0, ien = data.length; i < ien; i++) {
                        data[i][4] = "<div><a id=\"ti" + data[i][4] + "\" class=\"btn btn-danger btn-sm\" onclick=\"delete_tip(" + data[i][4] + ");\">删除</a></div>";
                    }
                    return data;
                }
            }
        });
};

    function render_table(table_name) {
        if (table_name == "#admin") {
            $('#admin').dataTable()._fnAjaxUpdate();
        } else if (table_name == "#student") {
            $('#student').dataTable()._fnAjaxUpdate();
        } else if (table_name == "#teacher") {
            $('#teacher').dataTable()._fnAjaxUpdate();
        } else if (table_name == "#tip") {
            $('#tip').dataTable()._fnAjaxUpdate();
        }
    };

    function render_editor() {
        $('#summernote').summernote({
            height: 300,
            focus: true,
        });
    };

    function add_admin() {
        var aid = $("#adminadd #aid").val();
        var name = $("#adminadd #name").val();
        var login = $("#adminadd #login").val();
        var adlevel = "";
        for (var i = 0; i < 5; i++) {
            if ($("#adminadd #adlevel" + i).is(":checked") == true) {
                adlevel += "1";
            } else {
                adlevel += "0";
            }
        }
        var markers = {
            "aid": aid,
            "name": name,
            "login": login,
            "adlevel": adlevel
        };
        console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/admin/new",
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("添加成功！");
                    render_table('#admin');
                } else {
                    alert("新建管理员失败。请查重或完善字段！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function add_student() {
        var sid = $("#studentadd #sid").val();
        var name = $("#studentadd #name").val();
        var stype = $("#studentadd #stype").val();
        var dept = $("#studentadd #dept").val();
        var login = $("#studentadd #login").val();
        var markers = {
            "sid": sid,
            "name": name,
            "stype": stype,
            "dept": dept,
            "login": login,
        };
        console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/student/new",
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("添加成功！");
                    render_table('#student');
                } else {
                    alert("新建管理员失败。请查重或完善字段！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function add_teacher() {
        var tid = $("#teacheradd #tid").val();
        var name = $("#teacheradd #name").val();
        var login = $("#teacheradd #login").val();
        var markers = {
            "tid": tid,
            "name": name,
            "login": login,
        };
        $.ajax({
            url: "/secure/teacher/new",
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("添加成功！");
                    //render_table('#teacher');
                } else {
                    alert("重复，新建教师失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function delete_admin(id) {
        $.ajax({
            url: "/secure/admin/delete/" + id,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("删除成功！");
                    render_table('#admin');
                } else {
                    alert("无记录，删除管理员失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function delete_student(id) {
        $.ajax({
            url: "/secure/student/delete/" + id,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("删除成功！");
                    render_table('#student');
                } else {
                    alert("无记录，删除学生失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function delete_teacher(id) {
        $.ajax({
            url: "/secure/teacher/delete/" + id,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("删除成功！");
                    render_table('#teacher');
                } else {
                    alert("无记录，删除教师失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function delete_tip(id) {
        $.ajax({
            url: "/secure/tip/delete/" + id,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("删除成功！");
                    render_table('#tip');
                } else {
                    alert("无记录，删除教师失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function update_admin(id) {
        var row = $("#admin #a" + id).parents("tr");
        var aid = row.find("input[name='aid-" + id + "']").val();
        var name = row.find("input[name='name-" + id + "']").val();
        var login = row.find("input[name='login-" + id + "']").val();
        var adlevel = ""
        for (var i = 0; i < 5; i++) {
            if (row.find("#adlevel" + i).is(":checked") == true) {
                adlevel += "1";
            } else {
                adlevel += "0";
            }
        };
        var markers = {
            "aid": aid,
            "name": name,
            "login": login,
            "adlevel": adlevel,
        };
        console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/admin/update/" + id,
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("更新成功！");
                    render_table('#admin');
                } else {
                    alert("更新学生信息失败。请查重或完善字段！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function update_student(id) {
        var row = $("#student #s" + id).parents("tr");
        var sid = row.find("input[name='sid-" + id + "']").val();
        var name = row.find("input[name='name-" + id + "']").val();
        var stype = row.find("input[name='stype-" + id + "']").val();
        var dept = row.find("input[name='dept-" + id + "']").val();
        var login = row.find("input[name='login-" + id + "']").val();
        var markers = {
            "sid": sid,
            "name": name,
            "stype": stype,
            "dept": dept,
            "login": login,
        };
        console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/student/update/" + id,
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("更新成功！");
                    render_table('#student');
                } else {
                    alert("更新学生信息失败。请查重或完善字段！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function update_teacher(id) {
        var row = $("#teacher #t" + id).parents("tr");
        var tid = row.find("input[name='tid-" + id + "']").val();
        var name = row.find("input[name='name-" + id + "']").val();
        var login = row.find("input[name='login-" + id + "']").val();
        var markers = {
            "tid": tid,
            "name": name,
            "login": login,
        };
        console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/teacher/update/" + id,
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("更新成功！");
                    render_table('#teacher');
                } else {
                    alert("更新教师信息失败。请查重或完善字段！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };

    function report_tip() {
        var tip_title = $('#tip_title').val();
        var tip = $('#summernote').code();
        var markers = {
            "tip_title": tip_title,
            "tip": tip,
        };
        console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/tip/new",
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("发布成功！");
                } else {
                    alert("发布失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
    };