#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:41:59
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-07 15:23:33
require File.expand_path("../../db/db_init", __FILE__)

class Admin < ActiveRecord::Base
	has_many :tips

	def auth(password)
		if (password == self.pwd)
			return true
		else
			return false
		end
	end
end

# begin
# 	a = Admin.create(
# 	aid: "0002",
# 	name: "长东",
# 	login: "foo",
# 	pwd: "bar",
# 	utype: "2",
# 	adlevel: "11111",
# )
# rescue Exception => e
# 	return false
# end


