#!/usr/bin/env ruby

require "bundler/setup"
require './src/insert_front_matters'

insert_front_matters(ENV['PATH_TO_HTML'])