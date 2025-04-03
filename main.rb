require_relative 'lib/json2csv_converter'

input_dir = ARGV[0]
output_dir = ARGV[1]

converter = Json2CsvConverter.new(input_dir, output_dir)
converter.process_all