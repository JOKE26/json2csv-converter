require 'csv'
require 'json'
require 'fileutils'
require_relative 'profile_parser'

class Json2CsvConverter
  def initialize(input_dir, output_dir)
    @input_dir = input_dir
    @output_dir = output_dir
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
  end

  def process_all
    json_files = Dir.glob("#{@input_dir}/*.json")
    json_files.each {|file| process_file(file)}
  end

  private

  def process_file(json_file)
    json_data = JSON.parse(File.read(json_file))

    unless json_data.is_a?(Array)
      raise "Invalid JSON format: root element must be an array"
    end

    output_file = File.join(@output_dir, "#{File.basename(json_file, '.json')}.csv")

    sample_profile = ProfileParser.parse(json_data.first)
    CSV.open(output_file, 'w', headers: dynamic_headers(sample_profile), write_headers: true) do |csv|
      json_data.each do |profile_hash|
        profile = ProfileParser.parse(profile_hash)
        csv << csv_row(profile)
      end
    end
    rescue JSON::ParserError => e
      raise "Invalid JSON format in #{json_file}: #{e.message}"
    end

  def dynamic_headers(sample_profile)
    base_headers = %w[id email tags]
    social_headers = sample_profile.social_profiles.flat_map do |network, _|
      ["profiles.#{network}.id", "profiles.#{network}.picture"]
    end
    base_headers + social_headers
  end

  def csv_row(profile)
    base_values = [profile.id, profile.email, profile.tags.join(',')]
    social_values = profile.social_profiles.flat_map do |network, data|
      [data.id, data.picture]
    end
    base_values + social_values
  end

end