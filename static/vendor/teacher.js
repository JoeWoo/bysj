/*
 * @Author: wujian
 * @Date:   2014-06-07 19:02:25
 * @Last Modified by:   wujian
 * @Last Modified time: 2014-06-10 14:48:01
 */
$(document).ready(function() {
    var path = window.location.pathname;
    var site;
    for (var i = path.length - 1; i >= 0; i--) {
        if (path.charAt(i) == "/") {
            site = i;
            break;
        }
    };
    console.log(site);
    var page = path.substring(site + 1, path.length);
    console.log(page);
    if (page == "teacher_title") {
        init_my_titles();
        init_other_titles();
    } else if (page == "teacher_cores") {
        init_scores();
        init_pipe();
        init_tiao();
    } else if (page == "admin_student") {
        init_student();
    } else if (page == "admin_tips") {
        init_tip();
    } else if (page == "edit_tip") {
        render_editor();
    }
});

function add_my_title() {
    var content = $("#my_title_add #content").val();
    var stype = $("#my_title_add #stype").val();
    var capacity = $("#my_title_add #capacity").val();
    var markers = {
        "content": content,
        "stype": stype,
        "capacity": capacity,
    };
    console.log(JSON.stringify(markers));
    $.ajax({
        url: "/secure/teacher/title/new",
        type: "POST",
        data: JSON.stringify(markers),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                alert("添加成功！");
                update_my_titles();
            } else {
                alert("添加课题失败。请查重或完善字段！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function delete_my_title(id) {
    $.ajax({
        url: "/secure/teacher/title/delete/" + id,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                alert("删除成功！");
                update_my_titles();
            } else {
                alert("无记录，删除管理员失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function init_my_titles() {
    $('#my_titles').dataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/teacher/my_titles",
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                console.log(data);
                for (var i = 0, ien = data.length; i < ien; i++) {
                    data[i][4] = "<div><a id=\"title" + data[i][4] + "\" class=\"btn btn-danger btn-sm\" onclick=\"delete_my_title(" + data[i][4] + ");\">删除</a></div>";
                }
                return data;
            }
        }
    });
};

function init_other_titles() {
    $('#other_titles').dataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/teacher/other_titles",
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                return data;
            }
        }
    });
};

function init_teacher_tempselect(id) {
    $('#teacher_tempselect').dataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/teacher/teacher_tempselect/" + id,
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                console.log(data);
                for (var i = 0, ien = data.length; i < ien; i++) {
                    if (data[i][4] == "未确认") {
                        data[i][5] = "<div><a id=\"tmp" + data[i][5] + "\" class=\"btn btn-success btn-sm\" onclick=\"confirm_tempselect(" + data[i][5] + ");\">确认</a></div>";
                    } else if (data[i][4] == "已确认") {
                        data[i][5] = "<div><a id=\"title" + data[i][5] + "\" class=\"btn btn-danger btn-sm\" onclick=\"unconfirm_tempselect(" + data[i][5] + ");\">取消确认</a></div>";
                    }
                }
                return data;
            }
        }
    });
};

function confirm_tempselect(id) {
    $.ajax({
        url: "/secure/teacher/teacher_add_confirm/" + id,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                alert("确认成功！");
                update_teacher_tempselect();
            } else {
                alert("已满员，确认失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function unconfirm_tempselect(id) {
    $.ajax({
        url: "/secure/teacher/teacher_delete_confirm/" + id,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                alert("取消确认成功！");
                update_teacher_tempselect();
            } else {
                alert("取消确认失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function frozen_selected(id) {
    $.ajax({
        url: "/secure/teacher/teacher_forzen_selected/" + id,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                alert("所有信息已提交！（未被确认学生已释放重新选题权限）");
                update_teacher_tempselect();
            } else {
                alert("提交失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function update_teacher_tempselect() {
    $('#teacher_tempselect').dataTable()._fnAjaxUpdate();
};

function update_my_titles() {
    $('#my_titles').dataTable()._fnAjaxUpdate();
};

function update_other_titles() {
    $('#other_titles').dataTable()._fnAjaxUpdate();
};

function update_tea_files_record(id) {
    $.ajax({
        url: "/secure/teacher/teacher_files_record/" + id,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                $('#tea_files_record').html(json.data);
            } else {
                alert("无记录，删除管理员失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function update_t_message(id) {
    $.ajax({
        url: "/secure/teacher/message/" + id,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                $('#message_t_record').html(json.data);
            } else {
                alert("获取聊天记录失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function send_t_message(id) {
    var msg = $('#btn-input').val();
    var markers = {
        "commits": msg
    };
    console.log(JSON.stringify(markers));
    $.ajax({
        url: "/secure/teacher/message/new/" + id,
        type: "POST",
        data: JSON.stringify(markers),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                update_t_message(id);
            } else if (json.result == "no") {
                alert("消息发送失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function update_tea_report_record() {
    location.reload();
};

function submit(type, selected_id) {
    var score = $("#" + type + "_score").val();
    var addend = $("#" + type + "_addend").val();
    var markers = {
        "score": score,
        "addend": addend,
        "selected_id": selected_id
    };
    console.log(JSON.stringify(markers));
    $.ajax({
        url: "/secure/teacher/score/" + type,
        type: "POST",
        data: JSON.stringify(markers),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                update_tea_report_record();
            } else if (json.result == "no") {
                alert("消息发送失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function init_scores() {
    $('#scores').dataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
        },
        "ajax": {
            "url": "/secure/teacher/scores",
            "type": "POST",
            "dataSrc": function(json) {
                var data = json.data;
                return data;
            }
        }
    });
};

function update_scores() {
    $('#scores').dataTable()._fnAjaxUpdate();
};

function init_pipe() {
    $.ajax({
        url: "/secure/teacher/pipe",
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                draw_pipe(json.data);
            } else {
                alert("取消确认失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function draw_pipe(data) {
    var plotObj = $.plot($("#flot-pie-chart"), data, {
        series: {
            pie: {
                show: true
            }
        },
        grid: {
            hoverable: true
        },
        tooltip: true,
        tooltipOpts: {
            content: "%p.0%, %s", // show percentages, rounding to 2 decimal places
            shifts: {
                x: 20,
                y: 0
            },
            defaultTheme: false
        }
    });
};

function init_tiao(){
	 $.ajax({
        url: "/secure/teacher/bar",
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(json) {
            if (json.result == "yes") {
                draw_tiao(json.ticks, json.data);
            } else {
                alert("取消确认失败！");
            }
        },
        error: function(xhr, status) {
            alert("获取已有目录列表失败！");
        }
    });
};

function draw_tiao(ticks,data ) {

    var barOptions = {
        series: {
            bars: {
                show: true,
                barWidth: 0.5
            }
        },
        xaxis: {
           axisLabel: "World Cities",
                axisLabelUseCanvas: true,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial',
                axisLabelPadding: 10,
                ticks: ticks
        },
        grid: {
            hoverable: true,
            barWidth: 2
        },
        legend: {
            show: false
        },
        tooltip: true,
        tooltipOpts: {
            content: "x: %x, y: %y"
        }
    };
    var barData = {
        label: "bar",
        data: data
    };
    $.plot($("#flot-bar-chart"), [barData], barOptions);
};