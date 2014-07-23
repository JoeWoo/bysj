#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-02 09:41:24
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-09 21:37:59
require File.expand_path("../../db/db_init", __FILE__)

class Message < ActiveRecord::Base
	belongs_to :teacher
	belongs_to :student
	belongs_to :selected
end