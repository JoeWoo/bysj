/*
* @Author: wujian
* @Date:   2014-06-07 19:02:44
* @Last Modified by:   wujian
* @Last Modified time: 2014-06-09 22:04:54
*/

/*
* @Author: wujian
* @Date:   2014-06-07 19:02:25
* @Last Modified by:   wujian
* @Last Modified time: 2014-06-08 18:56:20
*/

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
    if (page=="student_tempselect"){
        init_my_tempselect();
        init_titles();
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
function add_tempselect(id){
        var markers = {
            "title_id": id
        };
          console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/student/tempselect/new",
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("选题成功！");
                    update_my_tempselect();
                    update_titles();
                } else if(json.result == "no") {
                    alert("选题失败。请查重或完善字段！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
};

function delete_tempselect(id){
      $.ajax({
            url: "/secure/student/tempselect/delete/" + id,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    alert("删除成功！");
                    update_my_tempselect();
                    update_titles();
                } else {
                    alert("无记录，删除管理员失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
};

function init_my_tempselect(){
	$('#my_tempselect').dataTable({
             "language": {
                "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
             },
            "ajax": {
                "url": "/secure/student/my_tempselect",
                "type": "POST",
                "dataSrc": function(json) {
                    var data = json.data;
                    console.log(data);
                    for (var i = 0, ien = data.length; i < ien; i++) {
                    	if (data[i][8]=="已选"){
                        data[i][9] = "<div><a id=\"title" + data[i][9] + "\" class=\"btn btn-danger btn-sm\" onclick=\"delete_tempselect(" + data[i][9] + ");\">删除</a></div>";
                    	}else if(data[i][8]=="已被确认"){
                    		data[i][9] = "<div><a id=\"title" + data[i][9] + "\" class=\"btn btn-danger btn-sm disabled\">删除</a></div>";
                    	}
                    }
                    return data;
                }
            }
        });
};

function init_titles(){
	$('#titles').dataTable({
             "language": {
                "url": "//cdn.datatables.net/plug-ins/be7019ee387/i18n/Chinese.json"
             },
            "ajax": {
                "url": "/secure/student/titles",
                "type": "POST",
                "dataSrc": function(json) {
                    var data = json.data;
                    console.log(data);
                    for (var i = 0, ien = data.length; i < ien; i++) {
                    	if (data[i][8]=="yes"){
                        data[i][8] = "<div><a id=\"title" + data[i][0] + "\" class=\"btn btn-danger btn-sm\" onclick=\"add_tempselect(" + data[i][0] + ");\">报选</a></div>";
                    	}else if(data[i][8]=="no"){
                    		data[i][8] = "<div><a id=\"title" + data[i][0] + "\" class=\"btn btn-danger btn-sm disabled\">报选</a></div>";
                    	}
                    }
                    return data;
                }
            }
        });
};

function update_titles(){
	  $('#titles').dataTable()._fnAjaxUpdate();
};
function update_my_tempselect(){
	  $('#my_tempselect').dataTable()._fnAjaxUpdate();
};

function update_stu_files_record(){
    $.ajax({
            url: "/secure/student/student_files_record",
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    $('#stu_files_record').html(json.data);
                } else {
                    alert("无记录，删除管理员失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
};

function update_message(){
    $.ajax({
            url: "/secure/student/message",
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    $('#message_record').html(json.data);
                } else {
                    alert("获取聊天记录失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
};

function send_message(){
    var msg = $('#btn-input').val();
      var markers = {
            "commits": msg
        };
          console.log(JSON.stringify(markers));
        $.ajax({
            url: "/secure/student/message/new",
            type: "POST",
            data: JSON.stringify(markers),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(json) {
                if (json.result == "yes") {
                    update_message();
                } else if(json.result == "no") {
                    alert("消息发送失败！");
                }
            },
            error: function(xhr, status) {
                alert("获取已有目录列表失败！");
            }
        });
};