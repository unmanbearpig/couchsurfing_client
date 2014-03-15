require 'helper'

describe 'Basic features' do
  attr_reader :cs

  before do
    @cs = new_cs
  end

  it 'Gets profile by id' do
    vcr do
      cs.sign_in
      profile = cs.get_profile_by_id '1PGVKSK'
      assert_equal profile.name, 'HARRYHARRISON'
    end
  end

  it 'Gets profile by absolute url' do
    vcr do
      cs.sign_in
      profile = cs.get_profile_by_url 'https://www.couchsurfing.org/people/harryharrison/'
      assert_equal profile.name, 'HARRYHARRISON'
    end
  end

  it 'Gets profile by relative url' do
    vcr do
      cs.sign_in
      profile = cs.get_profile_by_url 'people/harryharrison/'
      assert_equal profile.name, 'HARRYHARRISON'
    end
  end
end
