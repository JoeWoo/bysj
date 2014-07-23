#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:41:24
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-10 13:44:05
require File.expand_path("../../db/db_init", __FILE__)

class Teacher < ActiveRecord::Base
	#attr_accessor :tid, :name, :login, :pwd

	has_many :titles
	has_many :messages
	has_many :tempselects
	has_many :selecteds
	has_many :mfiles
	has_many :reports

	def auth(password)
		if (password == self.pwd)
			return true
		else
			return false
		end
	end
end

# a = Teacher.new(
# 	tid: "0002",
# 	name: "陈鄞",
# 	login: "chenyin",
# 	pwd: "chenyin",
# 	utype: "1"
# )
# a.save
