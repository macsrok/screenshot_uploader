# frozen_string_literal: true

require './uploader'
require 'optparse'

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-f', '--file_path FILEPATH', 'The File Path of file to be uploaded.') { |o| options.file_path = o }
end.parse!

return unless options.file_path

Uploader.new(options.file_path).upload
