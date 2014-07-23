#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:41:32
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-09 12:27:25
require File.expand_path("../../db/db_init", __FILE__)

class Tempselect < ActiveRecord::Base
	belongs_to :student
	belongs_to :teacher
	belongs_to :title
	has_one :selected
end

#p Tempselect.where(title_id: 0, student_id: 0 ).count