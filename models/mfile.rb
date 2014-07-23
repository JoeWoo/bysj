#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:41:05
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-06 12:18:48
require File.expand_path("../../db/db_init", __FILE__)

class Mfile < ActiveRecord::Base
	belongs_to :student
	belongs_to :teacher
	belongs_to :selected
end

# a = File.new(
# 	sid: "1103710321",
# 	name: "易翔宇",
# 	dept: "软件工程",
# 	stype: "本科",
# 	login: "yixiangyu",
# 	pwd: "yixiangyu",
# )
# a.save