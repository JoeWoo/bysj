#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:41:24
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-10 02:47:28
require File.expand_path("../../db/db_init", __FILE__)

class Selected < ActiveRecord::Base
	belongs_to :student
	belongs_to :teacher
	belongs_to :title
	has_many :mfiles
	has_many :messages
	belongs_to :tempselect
	has_many :reports
end

#p Selected.delete_all(:tempselect_id == 3)
#p Selected.where(tempselect_id: ).count
#p selected_t = Selected.where(student_id:  2 )