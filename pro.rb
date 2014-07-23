#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-06 12:14:52
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-06 12:20:22
Dir.glob(File.dirname(__FILE__)+"/models/*.rb").each(){|f| require f}

student= Student.find_by_login("yixiangyu")
p student