#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:42:04
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-10 00:06:03
require File.expand_path("../../db/db_init", __FILE__)

class Title < ActiveRecord::Base
	belongs_to :teacher
	has_many :tempselects
	has_many :selecteds
	has_many :reports
end

