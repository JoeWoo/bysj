#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-09 23:59:52
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-10 13:51:37
require File.expand_path("../../db/db_init", __FILE__)

class Report < ActiveRecord::Base
	belongs_to :teacher
	belongs_to :title
	belongs_to  :student
	belongs_to :selected
end

