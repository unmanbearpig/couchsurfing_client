# -*- coding: utf-8 -*-
require 'test_helper'

module CouchSurfingClient
  class TestFriendLinkParser < Minitest::Test
    attr_reader :html, :parser

    def setup
      @html = '<td width="50%" class="friends"><a href="/people/pennyfield/" data-hover-profile="MYID:77AHJ6U" class="profile-image img verified hover-profile" style="width: 45px;height: 60px"><img alt="Rik Sentveld" src="https://s3.amazonaws.com/images.couchsurfing.us/77AHJ6U/18218553_t_f1350304f05d0e8a6460260361a347e1.jpg" width="45" height="60"/><span class="verified-icon" title="This user is verified">&nbsp;</span></a><a href="/people/pennyfield/" class="bold" rel="met friend">Rik Sentveld</a><br />35, Male<br />Meppel, Drenthe<br /><strong>Netherlands</strong><br />Friends since July  2012<br clear="all" /><em>&quot;She and her friend stayed at my place for the night&quot;</em><br />Friendship Type: Couchsurfing Friend<br /><img src="/images/icon_in_person.gif" alt="Met in person" title="Met in person" width="20" height="20" border="0" align="top">&nbsp;&nbsp; <img src="/images/icon_hosted.gif" alt="Hosted" title="Hosted" width="20" height="20" border="0" align="top"><sup>1</sup>&nbsp;&nbsp; </td></tr><tr valign="top">'
      @parser = FriendLinkParser.new html
    end

    def test_parsed_hash
      expected_hash = {
        thumbnail: 'https://s3.amazonaws.com/images.couchsurfing.us/77AHJ6U/18218553_t_f1350304f05d0e8a6460260361a347e1.jpg',
        profile_url: '/people/pennyfield/',
        is_verified: true,
        name: 'Rik Sentveld',
        age: 35,
        gender: 'Male',
        city: 'Meppel, Drenthe',
        country: 'Netherlands',
        how_met: 'She and her friend stayed at my place for the night',
        friendship_type: 'Couchsurfing Friend',
        friends_since: 'July 2012',
        met_in_person: true,
        # hosted: 1,
        # surfed: 0,
        # travelled: 0
      }

      assert_equal expected_hash, parser.to_h
    end
  end
end
