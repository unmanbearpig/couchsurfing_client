require 'test_helper'

module CouchSurfingClient
  class TestProfileParser < Minitest::Test
    attr_reader :html, :parser

    def setup
      @html = get_asset 'profile.html'
      @parser = ProfileParser.new html
    end

    def test_smoke
      assert_kind_of Hash, parser.to_h
    end

    def test_success
      assert_equal Hash.new, parser.errors
      assert parser.success?
    end

    def test_all_keys_present
      empty_keys = [:wisdom] # key that are empty for this profile, find a better profile later
      parser.keys.each do |key|
        refute_equal nil, parser.send(key), "key #{key} is not filled" unless empty_keys.include? key
      end
    end

    def test_couch_info
      html = get_asset 'couch_info.html'
      parser = ProfileParser.new html

      expected_hash = {
        couch_available: :maybe,
        preferred_gender: Gender.any,
        has_children: :no,
        can_host_children: :no,
        has_pets: :no,
        can_host_pets: :no,
        max_surfers_per_night: 1,
        shared_sleeping_surface: :no,
        shared_room: :yes,
        smoking: :no_smoking_allowed
      }

      assert_equal expected_hash, parser.to_h.select { |k, v| expected_hash.key? k }
    end

    def test_profile_valid
      expected_hash = {
        age: 27,
        amazing_thing: "I delivered some kittens into the world a few times. It was intense. There was blood and guts and screaming, but I would do it again in a heart beat. I wish I could just travel the world delivering baby animals of differing species!<br><br>Also, a group of couchsurfers and I rode the Denver lightrail in our skivvies!! It was an Urban Prankster-organized stunt and it was splendiferous!!!<br><br>I just went skydiving a month ago and it was the BEST. THING. EVER.",
        birthday: "27 March",
        can_host_children: :yes,
        can_host_pets: :no,
        couch_available: :maybe,
        couch_description: "when we have parties, we encourage our friends to stay over if they have consumed alcohol. They usually sleep in our living room where our couches are.I live with four other awesome awesome people! three other ladies and one gent. There is also a dog named Roxie. She is loving, but mostly resides in the basement or outside. we have several couches. They are all comfortable!\n ! ! ! ! I M P O R T A N T ! ! ! ! ! \n+**Those who want to stay with us, please be sure to send us an actual CS request, not just a profile message**+\nAlso, because we have had about two \"no call, no shows\", we would like to let everyone know that\n ****if you decide not stay with us, you should CALL OR MESSAGE AND LET US KNOW****\n I have no respect for people who allow me to reserve space for them and turn other people down, and then decide, last minute, not to stay with me without letting me know. This is inconsiderate to both the host and the surfers who actually need hosting.\nThat probably comes off as bitchy, but it bites when a surfer says they want to stay with you and you hear nothing from them. You have given them your contact info and they don't let you know if they have changed plans. Meanwhile, someone that you turned down could have had a place to stay. Communication is KEY, folks!\n ! ! ! ! I M P O R T A N T ! ! ! ! ! \nSo out of respect for those hosting you, would you please please pleeeeease take the time to fill out your profile with a good amount of sincere information and a couple of pictures that actually show your face. If you wouldn't feel comfortable hosting someone whose face you don't recognize and whose personality you have no clue about, then have the respect to share a little bit about yourself with the person you want to stay with. Just take a good half hour out of your day and tell the world about your likes, dislikes, and share a few photos. I have gotten many many messages that don't define a date, don't have a picture, and don't give a blip of information about themselves. During times of high traffic, I may not respond to those specific \"requests\". Sorry.",
        couch_pic: "/images/website_icon.gif",
        cs_experience: "I have surfed twice through CS and both tims were amazing!! We mostly host, however. I have hosted some of the most interesting folks. I love people so much and to be around people who also love people is something I can do on a regular basis thanks to this organization. It makes me love life that much more.",
        gender: Gender.several_people,
        has_children: :no,
        has_pets: :no,
        hometown: "Cheyenne, Wyoming",
        how_i_participate: "I am offering my couch to travelers who need it. When I cannot offer a couch, I meet up with travelers and show them the town! I love showing them my fave spots and unique activities. I also love to attend CS events and gatherings. I love to volunteer whenever I can. I love to coordinate themed CS potlucks and other foodventures! I love people and anyway I can be around them or help connect them.",
        interests: "Food, Art, Life, Animals, Movies, Music, People, Languages, Science, Books. I am going to have to emphasize the language bit. I LOVE LOVE LOVE languages. I wish to learn as many as I can. I took French for six years and was nearly fluent, buuuut college happened and now I speak limited francais. I am back on the train again and trying to recapture French, tackle Russian, and pick up Spanish. I wish to be fluent in all of these.",
        is_verified: false,
        languages: {
          "English (United States)Expert" => "Expert",
          "French (France)" => "Beginner"
        },
        last_in_location: "Englewood, Colorado, United States ",
        last_in_time: "Jan 15",
        max_surfers_per_night: 4,
        member_name: "CONJAY",
        member_since: "March 24th, 2009",
        mission: "Inhale all life has to offer, laugh with strangers, learn as many languages as possible and share myself with the world!",
        music_movies_books: "Yes, Yes, and YES. I read constantly and watch movies every night and I am always going to concerts!! I am open to movie, book, and music recommendations. We love anything by Tim Burton (except for Charlie and the Chocolate Factory, boo!). I love horror and mystery. Chuck Palahnuik rocks my world.<br><br>All the folks in the house read quite a lot (mostly school books at this point). We are all music lovers and music-makers. Evin is a great bassist ans drummer, Aubrey is a bassist, Nick is a guitarist and probably a drummer as well. I am a bit of a vocalist trying to learn the conga drums :)",
        name: "Constance  James",
        occupation: "Gluten-free and vegan baker, artist, event coordinator",
        opinion_on_cs: "This is going to sound corny, but CouchSurfing has seriously changed my life in an extreme way. The people I have met through CS have opened my eyes and have allowed me to see and experience so many different conversations, foods, music, movies, places. It's been an interesting and wild ride and I can't wait for more. I've come to think that my heart simply is not big enough for all of the positive loving experiences I have--uh--experienced :) I made close friends thanks to this organization. It's humbling and empowering at the same time to think about couchsurfing and realize that there are many many friends out there you have yet to make through hosting, surfing, and other events. <br><br>by the way, those of you who are interested, my skype is bettythebadger !!!!",
        people_i_enjoy: "non-violent, exciting people. People who are open to new things. people who think and laugh. Someone who'll go streaking with me, try a new and interesting food with me, or someone who has an epic story to share. ",
        personal_description: "I paint, make cakes, tinker with gluten-free and vegan baked goods. I love to try raw/vegan recipes and just alternative cuisine in general. I make my own henna and love to henna people up! I am WAY into movie nights and making fancy meals. I love to paint portraits of food and research different religions and languages. I LOVE DANCING!! I like to climb trees. I want to hear your story. I take joy in coordinating and creating CS events I love just hanging out and doing off-the-wall things. ",
        preferred_gender: Gender.any,
        profile_id: "7LEPI80",
        profile_pic: "https://s3.amazonaws.com/images.couchsurfing.us/7LEPI80/6176054_m_12d44b706eae7f92c5492807e49738e0.jpg",
        profile_url: "/people/conjay/",
        profile_views: "3,986",
        requests_replied_to: "88%",
        shared_room: :yes,
        shared_sleeping_surface: :no,
        smoking: :no_smoking_allowed,
        total_references: 96,
        wisdom: nil
      }

      assert_equal expected_hash, parser.to_h
    end
  end
end
