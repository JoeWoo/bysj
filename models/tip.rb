#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-06 09:44:59
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-06 09:52:38
require File.expand_path("../../db/db_init", __FILE__)

class Tip < ActiveRecord::Base
	belongs_to :admin
end