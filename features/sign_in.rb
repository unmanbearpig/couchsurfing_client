require 'helper'

describe 'Signing In/Out' do
  attr_reader :cs

  before do
    @cs = new_cs
  end

  def assert_cs_signed_in cs_instance
    assert cs_instance.signed_in?, 'CouchSurfing reports that it is not signed in'
    page = cs_instance.get ''
    assert page.link_with(text: 'Log out'), 'CouchSurfing returned not logged in root page'
  end

  def refute_cs_signed_in cs_instance
    refute cs_instance.signed_in?, 'CouchSurfing reports that it is signed in'
    page = cs_instance.get ''
    refute page.link_with(text: 'Log out'), 'CouchSurfing returned logged in root page'
  end

  it 'Signes in' do
    vcr do
      cs.sign_in
      assert_cs_signed_in cs
    end
  end

  it 'Is signed out if sign_in was not called' do
    vcr do
      refute_cs_signed_in cs
    end
  end

  it 'Signes in and out' do
    vcr do
      cs.sign_in
      assert_cs_signed_in cs
      cs.sign_out
      refute_cs_signed_in cs
    end
  end

  it 'Is not signed in if credentials are wrong' do
    vcr do
      cs = new_cs 'wrong_name', 'wrong_pass'
      refute_cs_signed_in cs
    end
  end

  it 'Uses provided cookie to sign in' do
    vcr do
      cs.sign_in
      cookies = cs.cookie_jar
      cs.sign_out

      cs = new_cs 'wrong_name', 'wrong_pass'
      refute_cs_signed_in cs
      cs.cookie_jar = cookies
      assert_cs_signed_in cs
    end
  end
end
