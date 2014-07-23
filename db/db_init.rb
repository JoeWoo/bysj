#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-06-01 22:43:56
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-02 10:23:24
require 'active_record'
require 'sqlite3'

$conn_db = {
	:adapter => "sqlite3",
	:database =>  File.dirname(__FILE__)+"/bysj.db"
}
ActiveRecord::Base.establish_connection($conn_db)
# CREATE TABLE students(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			sid TEXT   NOT NULL UNIQUE,
# 			name  TEXT     NOT NULL ,
# 			type TEXT not null,
# 			dept text not null,
# 			login text not null unique,
# 			pwd text not null
# 			);
# create table teachers(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			tid   text not null unique,
# 			name text not null,
# 			login text not null unique,
# 			pwd text not null
# 			);
# create table admins(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			aid   text not null unique,
# 			name text not null,
# 			login text not null unique,
# 			pwd text not null,
# 			adlevel text not null
# 			);
# create table titles(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			content   text not null,
# 			type text not null,
# 			teacher_id integer,
# 			tname text not null,
# 			FOREIGN KEY(teacher_id) REFERENCES teachers(id)
# 			);
# create table tempselects(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			student_id   integer,
# 			title_id integer,
# 			teacher_id integer,
# 			content text ,
# 			tname text,
# 			confirm integer,
# 			 FOREIGN KEY(teacher_id) REFERENCES teachers(id),
# 			 FOREIGN KEY(title_id) REFERENCES titles(id),
# 			 FOREIGN KEY(student_id) REFERENCES students(id)
# 			);
# create table selecteds(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			student_id   integer,
# 			title_id integer,
# 			teacher_id integer,
# 			content text ,
# 			tname text,
# 			 FOREIGN KEY(teacher_id) REFERENCES teachers(id),
# 			 FOREIGN KEY(title_id) REFERENCES titles(id),
# 			 FOREIGN KEY(student_id) REFERENCES students(id)
# 			);
# create table files(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			student_id   integer,
# 			selected_id integer,
# 			teacher_id integer,
# 			file_url text ,
# 			file_date text,
# 			tag integer,
# 			commits text,
# 			confirm integer,
# 			 FOREIGN KEY(teacher_id) REFERENCES teachers(id),
# 			 FOREIGN KEY(selected_id) REFERENCES selecteds(id),
# 			 FOREIGN KEY(student_id) REFERENCES students(id)
# 			);
# create table messages(
# 			id     INTEGER PRIMARY KEY NOT NULL,
# 			student_id   integer,
# 			teacher_id integer,
# 			commits text,
# 			message_date text,
# 			 FOREIGN KEY(teacher_id) REFERENCES teachers(id),
# 			 FOREIGN KEY(student_id) REFERENCES students(id)
# 			);


# class Student < ActiveRecord::Base
# 	establish_connection $conn_db


# end