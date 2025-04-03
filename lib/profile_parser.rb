class ProfileParser
  attr_reader :id, :email, :tags, :social_profiles

  def initialize(id, email, tags, social_profiles)
    @id = id
    @email = email
    @tags = tags || []
    @social_profiles = social_profiles
  end

  def self.parse(profile_hash)
    validate!(profile_hash)

    social_profiles = profile_hash['profiles'].each_with_object({}) do |(network, data), hash|
      hash[network] = SocialProfile.new(data['id'], data['picture'])
    end

    new(
      profile_hash['id'],
      profile_hash['email'],
      profile_hash['tags'],
      social_profiles
    )
  end

  private

  def self.validate!(profile)
    raise "Missing 'id'" unless profile.key?('id')
    raise "Missing 'email'" unless profile.key?('email')
    raise "Invalid 'tags' format" if profile['tags'] && !profile['tags'].is_a?(Array)
    unless profile['profiles'].is_a?(Hash)
      raise "Invalid 'profiles' format: must be an object"
    end
  end
end

SocialProfile = Struct.new(:id, :picture)