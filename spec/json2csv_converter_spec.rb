require 'spec_helper'

describe Json2CsvConverter do
  let(:input_dir) {'spec/fixtures/input'}
  let(:output_dir) {'spec/fixtures/output'}

  before do 
    FileUtils.mkdir_p(input_dir)
    FileUtils.mkdir_p(output_dir)
  end

  after do
    FileUtils.rm_rf(input_dir)
    FileUtils.rm_rf(output_dir)
  end

  it 'convertit un JSON valide en CSV' do
    valid_json = [
      {
        'id' => 1,
        'email' => 'user@example.com',
        'tags' => ['ruby', 'rails'],
        'profiles' => {
          'facebook' => {'id' => 'social1', 'picture' => 'pic1.jpg'},
          'twitter' => {'id' => 'social2'}
        }
      }
    ].to_json

    input_file = File.join(input_dir, 'valid.json')
    File.write(input_file, valid_json)

    converter = Json2CsvConverter.new(input_dir, output_dir)
    converter.process_all

    csv = CSV.read(File.join(output_dir, 'valid.csv'), headers: true)
    expect(csv.headers).to eq(%w[id email tags profiles.facebook.id profiles.facebook.picture profiles.twitter.id profiles.twitter.picture])
    expect(csv[0]['profiles.facebook.id']).to eq('social1')
    expect(csv[0]['profiles.twitter.id']).to eq('social2')
  end

  it 'erreur pour json invalide' do
    invalid_json = '{"id": "broken", "email": "test@example.com"}'
    input_file = File.join(input_dir, 'invalid.json')
    File.write(input_file, invalid_json)

    expect {
      Json2CsvConverter.new(input_dir, output_dir).process_all
  }.to raise_error(/Invalid JSON format/)
  end
end