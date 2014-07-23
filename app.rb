require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'json'
Dir.glob(File.dirname(__FILE__)+"/models/*.rb").each{|f| require f}




configure do
	set :public_folder, Proc.new { File.join(root, "static") }
	set :files, File.join(settings.public_folder, 'files')
	enable :sessions
end

helpers do

	def username
		if !session[:current_user].nil?
		      return session[:current_user].name
		else
		  	return '请登录'
		end
	end

	def sign_in(user)
		#cookies.permanent[:remember_token] = user.remember_token
		session[:current_user] = user
	end

	def sign_out()
		session[:current_user] = nil
		#cookies.delete(:remember_token)
	end
end

before do
 @part = :timeline
 @part_teacher = :timeline
 @part_student = :timeline
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
	user=session[:current_user]
	if !user.nil?
		if user.utype == 0
			redirect to  "/secure/students/#{user.id}"
		elsif user.utype ==1
			redirect to "/secure/teachers/#{user.id}"
		elsif user.utype == 2
			redirect to "/secure/admins/#{user.id}"
		end
	else
		erb :login_form
	end

end

get '/login/form' do
	erb :login_form
end

post '/login/attempt' do
	type = params['type']
	case type
	when '学生'
		student= Student.find_by_login(params[:username])
		#student = Student.find(:all,:conditions=>["login=?",session[:username]])
		if student && student.auth(params[:password])
			sign_in(student)
			redirect "/secure/students/#{student.id}"
		else
			flash.now[:error] = '用户名或密码错误！'
			redirect "/login/form"
		end
	when '教师'
		teacher= Teacher.find_by_login(params[:username])
		#student = Student.find(:all,:conditions=>["login=?",session[:username]])
		if teacher && teacher.auth(params[:password])
			sign_in(teacher)
			redirect "/secure/teachers/#{teacher.id}"
		else
			flash.now[:error] = '用户名或密码错误！'
			redirect "/login/form"
		end
	when '管理员'
		admin= Admin.find_by_login(params[:username])
		#student = Student.find(:all,:conditions=>["login=?",session[:username]])
		if admin && admin.auth(params[:password])
			sign_in(admin)
			redirect "/secure/admins/#{admin.id}"
		else
			flash.now[:error] = '用户名或密码错误！'
			redirect "/login/form"
		end
	end
end

get '/logout' do
	session.delete(:current_user)
	erb "<div class='alert alert-message'>已退出</div>"
end


##
#学生、管理员、教师操作
#
before '/secure/*' do
	if !session[:current_user] then
		session[:previous_url] = request.path
		@error = '对不起，要访问该网页请先登录。' + request.path
		halt erb(:login_form)
	else
		@tips = Tip.limit(30).order("tip_date ASC")
	end
end
##
#管理员
#

before '/secure/admin*' do
	user = session[:current_user]
	if (user.utype==2)
		@iadlevel=user.adlevel
	end
end

get '/secure/admin/timeline' do
	@part = :timeline
	erb :admin
end

get '/secure/admin/admin_admin' do
	@part = :admin_admin
	erb :admin
end

get '/secure/admin/admin_student' do
	@part = :admin_student
	erb :admin
end

get '/secure/admin/admin_teacher' do
	@part = :admin_teacher
	erb :admin
end

get '/secure/admin/admin_tips' do
	@part = :admin_tips
	erb :admin
end

get '/secure/admin/edit_tip' do
	@part = :edit_tip
	erb :admin
end


get '/secure/admins/:id' do
	@part = :timeline
	erb :admin
end
#查
post '/secure/admin/all' do
	result = Hash.new()
	str=Array.new()
	Admin.select("id, aid, name, login, adlevel").each{ |admin|
		# str <<  {id:admin.id,aid: admin.aid, name: admin.name, login: admin.login,adlevel: admin.adlevel}
		str <<[admin.aid, admin.name, admin.login,admin.adlevel, admin.id]
	}
	result[:data]=str
	result.to_json
end

post '/secure/student/all' do
	result = Hash.new()
	str=Array.new()
	Student.select("id, sid, name, stype, dept, login").each{ |student|
		# str <<  {id:student.id,sid: student.sid, name: student.name, stype: student.stype, dept: student.dept,login: student.login}
		str << [student.sid, student.name, student.stype,student.dept,student.login, student.id]
	}
	result[:data]=str
	result.to_json
end

post '/secure/teacher/all' do
	result = Hash.new()
	str=Array.new()
	Teacher.select("id, tid, name, login").each{ |teacher|
		# str <<  {id:teacher.id,tid: teacher.tid, name: teacher.name, login: teacher.login}
		str << [teacher.tid, teacher.name,teacher.login,teacher.id]
	}
	result[:data]=str
	result.to_json
end

post '/secure/tip/all' do
	result = Hash.new()
	str=Array.new()
	Tip.select("id, tip_title,tip_date,admin_id").each{ |tip|
		# str <<  {id:tip.id,tip_title: tip.tip_title, tip_date: tip.tip_date, admin_id: tip.admin_id}
		str << [tip.id, tip.tip_title, tip.tip_date, tip.admin_id,tip.id]
	}
	result[:data]=str
	result.to_json
end
#增
post '/secure/admin/new' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[0]=="1" then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			data["pwd"]=data["login"]
			data["utype"]="2"
			Admin.create(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作管理员权限。' + request.path
		halt erb(:login_form)
	end
end

post '/secure/student/new' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[2]=="1" then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			p data
			data["pwd"]=data["login"]
			data["utype"]="0"
			Student.create(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作学生权限。' + request.path
		halt erb(:login_form)
		puts "nimabi======"

	end
end

post '/secure/teacher/new' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[1]=="1" then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			data["pwd"]=data["login"]
			data["utype"]="1"
			Teacher.create(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作教师权限。' + request.path
		halt erb(:login_form)

	end
end

post '/secure/tip/new' do
	puts "fuclk"
	if session[:current_user].utype == 2 && session[:current_user].adlevel[4]=="1" then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			data["tip_date"]=Time.now.to_s
			data["admin_id"]=session[:current_user].id
			Tip.create(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有公告权限。' + request.path
		halt erb(:login_form)
	end
end
#删
post '/secure/admin/delete/:id' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[0]=="1" then
		begin
			Admin.delete(params[:id])
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作管理员权限。' + request.path
		halt erb(:login_form)

	end
end

post '/secure/student/delete/:id' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[2]=="1" then
		begin
			Student.delete(params[:id])
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作学生权限。' + request.path
		halt erb(:login_form)


	end
end

post '/secure/teacher/delete/:id' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[1]=="1" then
		begin
			Teacher.delete(params[:id])
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作教师权限。' + request.path
		halt erb(:login_form)

	end
end

post '/secure/tip/delete/:id' do
	if session[:current_user].utype == 2 && session[:current_user].adlevel[4]=="1" then
		begin
			Tip.delete(params[:id])
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有删除公告权限。' + request.path
		halt erb(:login_form)

	end
end
#改
post '/secure/admin/update/:id' do
	current_user = session[:current_user]
	if (current_user.utype == 2 && current_user.id == params[:id])|| (current_user.utype == 2 &&current_user.adlevel[0]=="1" )then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			u = Admin.find(params[:id])
			p data
			u.update_attributes(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作该管理员权限。' + request.path
		halt erb(:login_form)
	end
end

post '/secure/student/update/:id' do
	current_user = session[:current_user]
	if (current_user.utype == 0 && current_user.id == params[:id])|| (current_user.utype == 2 &&current_user.adlevel[2]=="1" )then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			u = Student.find(params[:id])
			p data
			u.update_attributes(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作该学生权限。' + request.path
		halt erb(:login_form)
	end
end

post '/secure/teacher/update/:id' do
	current_user = session[:current_user]
	if (current_user.utype == 1 && current_user.id == params[:id])|| (current_user.utype == 2 &&current_user.adlevel[1]=="1" )then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			u = Teacher.find(params[:id])
			p data
			u.update_attributes(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有操作该教师权限。' + request.path
		halt erb(:login_form)
	end
end




##
#教师
#

before '/secure/teacher*' do
	if session[:current_user].utype == 1 then
		@my_titles = session[:current_user].titles
	end

end

get '/secure/teacher/timeline' do
	@part_teacher = :timeline
	erb :teacher
end

get '/secure/teacher/teacher_title' do
	@part_teacher = :teacher_title
	erb :teacher
end

get '/secure/teacher/teacher_confirm/:id' do
	@t = Title.find(params[:id])
	@confirm_id = params[:id]
	@part_teacher = :teacher_confirm
	erb :teacher
end

get '/secure/teacher/teacher_selected/:id' do
	@kaiti = 1
	@kaitireport = Report.where(selected_id:params[:id],kind: "开题").first
	@kaiti = 0 if @kaitireport.nil?
	@zhongqi = 1
	@zhongqireport =  Report.where(selected_id:params[:id],kind: "中期").first
	@zhongqi = 0 if @zhongqireport.nil?
	@jieti = 1
	@jietireport = Report.where(selected_id:params[:id],kind: "结题").first
	@jieti = 0 if @jietireport.nil?
	@jielun = 1
	@jielunreport =  Report.where(selected_id:params[:id],kind: "结论").first
	@jielun = 0 if @jielunreport.nil?


	@selected_title = Selected.find(params[:id])
	@part_teacher = :teacher_selected
	erb :teacher
end

get '/secure/teacher/teacher_cores' do
	@part_teacher = :teacher_cores
	erb :teacher
end

post '/secure/teacher/my_titles' do
	result = Hash.new()
	str=Array.new()
	t = Teacher.find(session[:current_user].id)
	t.titles.each{ |title|
		str << [title.id, title.content, title.stype, title.capacity, title.id]
	}
	result[:data]=str
	result.to_json
end

post '/secure/teacher/other_titles' do
	result = Hash.new()
	str=Array.new()
	t = Title.where("teacher_id != #{session[:current_user].id}")
	t.each{ |title|
		str << [title.id, title.content, title.stype, title.capacity,title.tname]
	}
	result[:data]=str
	result.to_json
end

post '/secure/teacher/title/new' do
	if session[:current_user].utype == 1 then
		begin
			content_type :json
			request.body.rewind  # 如果已经有人读了它
			data = JSON.parse(request.body.read)
			data["teacher_id"]=session[:current_user].id
			data["tname"]=session[:current_user].name
			Title.create(data)
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有添加课题权限。' + request.path
		halt erb(:login_form)
	end
end

post '/secure/teacher/title/delete/:id' do
	t = Teacher.find(session[:current_user].id)
	if session[:current_user].utype == 1 && t.titles.find(params[:id])!=nil then
		begin
			t.titles.delete(params[:id])
			return {:result => "yes"}.to_json
		rescue Exception => e
			p e
			return {:result => "no"}.to_json
		end
	else
		session[:previous_url] = request.path
		@error = '对不起，您没有删除该课题权限。' + request.path
		halt erb(:login_form)

	end
end

post '/secure/teacher/teacher_tempselect/:id' do
	result = Hash.new()
	str=Array.new()
	t = session[:current_user]
	Title.find(params[:id]).tempselects.each{ |tmp|
		stu = Student.find(tmp.student_id)
		stat = "未确认"
		if tmp.confirm == 1
			stat = "已确认"
		end
		str << [stu.id, stu.name, stu.stype, stu.dept,stat, tmp.id]
	}
	result[:data]=str
	result.to_json
end

post '/secure/teacher/teacher_add_confirm/:id' do
	tmp = session[:current_user].tempselects.find(params[:id])
	confirmed = Selected.where(title_id: tmp.title_id).count
	begin
		if (!tmp.nil?) && tmp.confirm == 0 && confirmed < tmp.capacity
			tmp.update_attributes(confirm: 1)
			data = {}
			data[:student_id] = tmp.student_id
			data[:title_id] = tmp.title_id
			data[:teacher_id] = tmp.teacher_id
			data[:tempselect_id] = tmp.id
			data[:sname] = tmp.sname
			data[:content] = tmp.content
			data[:tname] = tmp.tname
			data[:stat] = "6%"
			data[:capacity] = tmp.capacity
			Selected.create(data)
			return{:result => "yes"}.to_json
		else
			return {:result => "no"}.to_json
		end
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end
end

post '/secure/teacher/teacher_delete_confirm/:id' do
	tmp = session[:current_user].tempselects.find(params[:id])
	begin
		if (!tmp.nil?) && tmp.confirm == 1
			tmp.update_attributes(confirm: 0)
			Selected.delete_all(tempselect_id: tmp.id)
			return{:result => "yes"}.to_json
		else
			return {:result => "no"}.to_json
		end
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end

end

post '/secure/teacher/teacher_forzen_selected/:id' do
	tmp = session[:current_user].titles.find(params[:id])
	begin
		if (!tmp.nil?)
			Tempselect.delete_all(title_id: tmp.id, confirm: 0)
			return{:result => "yes"}.to_json
		else
			return {:result => "no"}.to_json
		end
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end
end

post '/secure/teacher/teacher_files_record/:id' do
	result = Hash.new()
	str =""
	str.clear
	teacher = session[:current_user]

	teacher.selecteds.find(params[:id]).mfiles.order("file_date ASC").each{  |f|
		if (f.tag==1)
		str << "<li><div class=\"timeline-badge\"><i class=\"fa fa-check\"></i></div><div class=\"timeline-panel\"><div class=\"timeline-heading\"><h4 class=\"timeline-title\">#{f.file_subject}</h4><p><small class=\"text-muted\"><i class=\"fa fa-time\"></i>#{f.file_date}</small></p></div><div class=\"timeline-body\"><p>#{f.commits}</p><p>#{f.file_name}</p><hr>
<div class=\"btn-group\"><a href=\"/secure/download/#{f.download_url}\" class=\"btn btn-sm btn-primary\">下载文件</a></div></div></div></li>"
	elsif (f.tag==0)
		str << "<li class=\"timeline-inverted\"><div class=\"timeline-badge success\"><i class=\"fa fa-thumbs-up\"></i></div><div class=\"timeline-panel\"><div class=\"timeline-heading\"><h4 class=\"timeline-title\">#{f.file_subject}</h4><p><small class=\"text-muted\"><i class=\"fa fa-time\"></i>#{f.file_date}</small></p></div><div class=\"timeline-body\"><p>#{f.commits}</p><p>#{f.file_name}</p><hr>
<div class=\"btn-group\"><a href=\"/secure/download/#{f.download_url}\" class=\"btn btn-sm btn-primary\">下载文件</a></div></div></div></li>"
	end

 	}
 	result[:result] = "yes"
 	result[:data] = str
 	result.to_json
end

post '/secure/teacher/upload_files' do
		if params[:file]
			file_date = Time.now.to_s
		      filename = params[:file][:filename]
		      file = params[:file][:tempfile]
		      unipath ="#{filename}_#{Time.now.to_i}"
		      file_url = File.join(settings.files, unipath)
		      File.open(file_url, 'wb') do |f|
		        f.write file.read
		      end

		      data ={}
			teacher = session[:current_user]
			sel = teacher.selecteds.find(params[:selected_id])
			data[:student_id] = sel.student_id
			data[:selected_id] = sel.id
			data[:teacher_id] = teacher.id
			data[:file_name] =filename
			data[:file_url] =file_url
			data[:download_url] = unipath
			data[:file_date] = file_date
			data[:tag] = 1
			data[:commits] = params[:commits]
			data[:file_subject] = params[:subject]
			data[:milestone] = params[:milestone]
			Mfile.create(data)

		    redirect to "/secure/teacher/teacher_selected/#{params[:selected_id]}"
		  else
		    flash 'You have to choose a file'
		  end
end

post '/secure/teacher/message/:id' do
	result = Hash.new()
	str =""
	str.clear
	teacher = session[:current_user]

	teacher.selecteds.find(params[:id]).messages.order("message_date ASC").each{  |f|
		if (f.tag==1)
		str << "<li class=\"left clearfix\"><span class=\"chat-img pull-left\"><img src=\"/vendor/img/tea.png\" alt=\"User Avatar\" class=\"img-circle\"></span><div class=\"chat-body clearfix\"><div class=\"header\"><strong class=\"primary-font\">#{f.tname}</strong><small class=\"pull-right text-muted\"><i class=\"fa fa-clock-o fa-fw\"></i>#{f.message_date}</small></div><p>#{f.commits}</p></div></li>"
	elsif (f.tag==0)
		str << "<li class=\"right clearfix\"><span class=\"chat-img pull-right\"><img src=\"/vendor/img/stu.png\" alt=\"User Avatar\" class=\"img-circle\"></span><div class=\"chat-body clearfix\"><div class=\"header\"><small class=\" text-muted\"><i class=\"fa fa-clock-o fa-fw\"></i> #{f.message_date}</small><strong class=\"pull-right primary-font\">#{f.sname}</strong></div><p>#{f.commits}</p></div></li>"
	end

 	}
 	result[:result] = "yes"
 	result[:data] = str
 	result.to_json
end

post '/secure/teacher/message/new/:id' do
	teacher = session[:current_user]
	sel = teacher.selecteds.find(params[:id])
	begin
		content_type :json
		request.body.rewind  # 如果已经有人读了它
		data = JSON.parse(request.body.read)
		data[:student_id] = sel.student_id
		data[:teacher_id] = sel.teacher_id
		data[:selected_id] = sel.id
		data[:sname] = sel.sname
		data[:tname] = sel.tname
		data[:tag] = 1
		data[:message_date] = Time.now.to_s
		Message.create(data)
		return {:result => "yes"}.to_json
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end
end

post '/secure/teacher/score/:id' do
	kind = "开题"
	stat = "6%"
	if params[:id] == "kaiti"
		kind = "开题"
		stat = "25%"
	elsif params[:id] == "zhongqi"
		kind = "中期"
		stat = "50%"
	elsif params[:id] == "jieti"
		kind ="结题"
		stat = "75%"
	elsif params[:id] == "jielun"
		kind ="结论"
		stat = "100%"
	end
	begin
		content_type :json
		request.body.rewind  # 如果已经有人读了它
		data = JSON.parse(request.body.read)
		p  data["selected_id"]
		p kind
		t = Report.where(selected_id: data["selected_id"],kind: kind).first
		p t
		t.update_attributes(score: data["score"], addend: data["addend"])
		t.selected.update_attributes(stat: stat)
		return {:result => "yes"}.to_json
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end


end

get '/secure/teachers/:id' do
	@part_teacher =:timeline
	erb :teacher
end

##
#学生
#

get '/secure/student/timeline' do
	@part_student = :timeline
	erb :student
end

get '/secure/student/student_tempselect' do
	@part_student = :student_tempselect
	erb :student
end

get '/secure/student/student_project' do
	@part_student = :student_project
	@project_title = session[:current_user].selected
	erb :student
end

get '/secure/student/student_selected/start' do

	stu = session[:current_user]

	@report = Report.where(student_id: stu.id, kind: "开题").first

	@iselected = Selected.where(student_id: stu.id).first
	@part_student = :student_selected
	@milestone = :start
	@kind = "开题"
	erb :student
end

get '/secure/student/student_selected/middle' do
	stu = session[:current_user]

	@report = Report.where(student_id: stu.id, kind: "中期").first

	@iselected = Selected.where(student_id: stu.id).first
	@part_student = :student_selected
	@milestone = :middle
	@kind = "中期"
	erb :student
end

get '/secure/student/student_selected/end' do
	stu = session[:current_user]

	@report = Report.where(student_id: stu.id, kind: "结题").first

	@iselected = Selected.where(student_id: stu.id).first
	@part_student = :student_selected
	@milestone = :end
	@kind = "结题"
	erb :student
end

get '/secure/student/student_selected/final' do
	stu = session[:current_user]

	@report = Report.where(student_id: stu.id, kind: "结论").first

	@iselected = Selected.where(student_id: stu.id).first
	@part_student = :student_selected
	@milestone = :final
	@kind = "结论"
	erb :student
end

get '/secure/students/:id' do
	erb :student
end

post '/secure/student/my_tempselect' do
	result = Hash.new()
	str=Array.new()
	id = session[:current_user].id
	stu = Student.find(id)
	stu.tempselects.each{ |tmp|
		tit = Title.find(tmp.title_id)
		tit_tmp = tit.tempselects
		seleceted = tit_tmp.count
		confirmed = tit_tmp.where(confirm: 1).count
		my_stat = "已选"
		if (tmp.confirm == 1)
			my_stat = "已被确认"
		end
		str << [tmp.id, tit.content, tit.tname, tit.stype, tit.capacity, seleceted , confirmed , tit.capacity-confirmed,  my_stat, tmp.id ]
	}
	result[:data] = str
	result.to_json
end

post '/secure/student/tempselect/new' do
	id = session[:current_user].id
	begin
		content_type :json
		request.body.rewind  # 如果已经有人读了它
		data = JSON.parse(request.body.read)

		t = Title.find(data["title_id"])
		data[:student_id] = id
		data[:teacher_id] = t.teacher_id
		data[:content] = t.content
		data[:tname] = t.tname
		data[:capacity] = t.capacity
		data[:sname] = session[:current_user].name
		data[:confirm] = 0
		if Tempselect.where(student_id: id ).count == 0
			Tempselect.create(data)
			return {:result => "yes"}.to_json
		else
			return {:result => "no"}.to_json
		end
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end
end

post '/secure/student/tempselect/delete/:id' do
	id = session[:current_user].id
	begin
		tmp = Tempselect.find(params[:id])
		if tmp.nil? || tmp.confirm == 1 || tmp.student_id != id
			return {:result => "no"}.to_json
		else
			Tempselect.delete(params[:id])
			return {:result => "yes"}.to_json
		end
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end
end

post '/secure/student/titles' do
	result = Hash.new()
	str=Array.new()
	id = session[:current_user].id
	Title.all.each{   |t|
		seleceted =t.tempselects.count
		confirmed =t.tempselects.where(confirm: 1).count
		rest = t.capacity - confirmed
		could_select = ""
		if Tempselect.where(title_id: t.id, student_id: id ).count == 0
			could_select = "yes"
		else
			could_select = "no"
		end

		str <<[t.id, t.content, t.tname, t.stype, t.capacity, seleceted, confirmed, rest, could_select]
	}
	result[:data] = str
	result.to_json
end

post '/secure/student/upload_files' do
		if params[:file]
			file_date = Time.now.to_s
		      filename = params[:file][:filename]
		      file = params[:file][:tempfile]
		      unipath ="#{filename}_#{Time.now.to_i}"
		      file_url = File.join(settings.files, unipath)
		      File.open(file_url, 'wb') do |f|
		        f.write file.read
		      end

		      data ={}
			stu = session[:current_user]
			sel = stu.selected
			data[:student_id] = stu.id
			data[:selected_id] = sel.id
			data[:teacher_id] = sel.teacher_id
			data[:file_name] =filename
			data[:file_url] =file_url
			data[:download_url] = unipath
			data[:file_date] = file_date
			data[:tag] = 0
			data[:commits] = params[:commits]
			data[:file_subject] = params[:subject]
			data[:milestone] = params[:milestone]
			Mfile.create(data)

			if params[:report] == "yes"
				mdata = {}
				mdata[:student_id] = stu.id
				mdata[:selected_id] = sel.id
				mdata[:title_id] = sel.title_id
				mdata[:teacher_id] = sel.teacher_id
				mdata[:sname] = sel.sname
				mdata[:content] = sel.content
				mdata[:tname] = sel.tname
				mdata[:kind] = params[:milestone]
				mdata[:download_path] = unipath
				mdata[:file_name] =filename
				mdata[:file_date] = file_date
				mdata[:score] = 0
				Report.create(mdata)
			end
		    redirect to '/secure/student/student_project'
		  else
		    flash 'You have to choose a file'
		  end
end

post '/secure/student/student_files_record' do
	result = Hash.new()
	str =""
	str.clear
	stu = session[:current_user]

	stu.mfiles.order("file_date ASC").each{  |f|
		if (f.tag==0)
		str << "<li><div class=\"timeline-badge\"><i class=\"fa fa-check\"></i></div><div class=\"timeline-panel\"><div class=\"timeline-heading\"><h4 class=\"timeline-title\">#{f.file_subject}</h4><p><small class=\"text-muted\"><i class=\"fa fa-time\"></i>#{f.file_date}</small></p></div><div class=\"timeline-body\"><p>#{f.commits}</p><p>#{f.file_name}</p><hr>
<div class=\"btn-group\"><a href=\"/secure/download/#{f.download_url}\" class=\"btn btn-sm btn-primary\">下载文件</a></div></div></div></li>"
	elsif (f.tag==1)
		str << "<li class=\"timeline-inverted\"><div class=\"timeline-badge success\"><i class=\"fa fa-thumbs-up\"></i></div><div class=\"timeline-panel\"><div class=\"timeline-heading\"><h4 class=\"timeline-title\">#{f.file_subject}</h4><p><small class=\"text-muted\"><i class=\"fa fa-time\"></i>#{f.file_date}</small></p></div><div class=\"timeline-body\"><p>#{f.commits}</p><p>#{f.file_name}</p><hr>
<div class=\"btn-group\"><a href=\"/secure/download/#{f.download_url}\" class=\"btn btn-sm btn-primary\">下载文件</a></div></div></div></li>"
	end

 	}
 	result[:result] = "yes"
 	result[:data] = str
 	result.to_json
end

post '/secure/student/message' do
	result = Hash.new()
	str =""
	str.clear
	stu = session[:current_user]

	stu.messages.order("message_date ASC").each{  |f|
		if (f.tag==0)
		str << "<li class=\"left clearfix\"><span class=\"chat-img pull-left\"><img src=\"/vendor/img/stu.png\" alt=\"User Avatar\" class=\"img-circle\"></span><div class=\"chat-body clearfix\"><div class=\"header\"><strong class=\"primary-font\">#{f.sname}</strong><small class=\"pull-right text-muted\"><i class=\"fa fa-clock-o fa-fw\"></i>#{f.message_date}</small></div><p>#{f.commits}</p></div></li>"
	elsif (f.tag==1)
		str << "<li class=\"right clearfix\"><span class=\"chat-img pull-right\"><img src=\"/vendor/img/tea.png\" alt=\"User Avatar\" class=\"img-circle\"></span><div class=\"chat-body clearfix\"><div class=\"header\"><small class=\" text-muted\"><i class=\"fa fa-clock-o fa-fw\"></i> #{f.message_date}</small><strong class=\"pull-right primary-font\">#{f.tname}</strong></div><p>#{f.commits}</p></div></li>"
	end

 	}
 	result[:result] = "yes"
 	result[:data] = str
 	result.to_json
end

post '/secure/student/message/new' do
	stu = session[:current_user]
	sel = stu.selected
	begin
		content_type :json
		request.body.rewind  # 如果已经有人读了它
		data = JSON.parse(request.body.read)
		data[:student_id] = stu.id
		data[:teacher_id] = sel.teacher_id
		data[:selected_id] = sel.id
		data[:sname] = sel.sname
		data[:tname] = sel.tname
		data[:tag] = 0
		data[:message_date] = Time.now.to_s
		Message.create(data)
		return {:result => "yes"}.to_json
	rescue Exception => e
		p e
		return {:result => "no"}.to_json
	end
end

get '/secure/download/:name' do
	puts params[:name]
	site = params[:name].rindex('_')
	file_name = params[:name][0..site-1]

    content_type 'application/octet-stream'
    attachment file_name
    file_url = File.join(settings.files, params[:name])
    File.open(file_url, 'rb') do |f|
		  f.read
    end
end

post '/secure/teacher/scores' do
	tea = session[:current_user]
	result = {}
	data = []
	stus = Selected.select("student_id, content, sname").where(teacher_id: tea.id)
	stus.each{ |stud|
		tmp = Array.new(6) { 0 }
		tmp[0] = stud.sname
		tmp[1] = stud.content
		Report.select("kind,score").where(student_id: stud.student_id).each{
			|ni|
			if ni.kind=="开题"
				tmp[2] = ni.score
			elsif ni.kind =="中期"
				tmp[3] =ni.score
			elsif ni.kind =="结题"
				tmp[4] = ni.score
			elsif ni.kind =="结论"
				tmp[5] = ni.score
			end
		}
		data << tmp
	}
	result[:data] = data
	result[:result] ="yes"
	result.to_json
end



post '/secure/teacher/pipe' do
	tea = session[:current_user]
	result = {}
	data = []
	num = Selected.where(teacher_id: tea.id, stat: "6%").count
	data << {label: "准备", data: num}
	num = Selected.where(teacher_id: tea.id, stat: "25%").count
	data << {label: "开题", data: num}
	num = Selected.where(teacher_id: tea.id, stat: "50%").count
	data << {label: "中期", data: num}
	num = Selected.where(teacher_id: tea.id, stat: "75%").count
	data << {label: "结题", data: num}
	num = Selected.where(teacher_id: tea.id, stat: "100%").count
	data << {label: "结论", data: num}


	result[:data] = data
	result[:result] ="yes"
	result.to_json

end

post '/secure/teacher/bar' do
	tea = session[:current_user]
	result = {}
	data = []
	ticks = []
	stus = Selected.select("student_id, content, sname,stat").where(teacher_id: tea.id)
	i = 0
	stus.each{ |stud|
		ticks << [i,stud.sname]
		data << [i,stud.stat[0..-2].to_i]
		i+=1
	}
	result[:data] = data
	result[:ticks] = ticks
	result[:result] ="yes"
	result.to_json
end