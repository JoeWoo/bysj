#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:40:06
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-10 00:05:33
require File.expand_path("../../db/db_init", __FILE__)

class Student < ActiveRecord::Base
#	attr_accessor :sid, :name, :dept, :stype, :login, :pwd
	has_many :mfiles
	has_one :selected
	has_many :tempselects
	has_many :messages
	has_many :reports

	def auth(password)
		if (password == self.pwd)
			return true
		else
			return false
		end
	end
end

# a = Student.new(
# 	sid: "1103710321",
# 	name: "易翔宇",
# 	dept: "软件工程",
# 	stype: "本科",
# 	login: "yixiangyu",
# 	pwd: "yixiangyu",
# 	utype: "0"
# )
#  a.save