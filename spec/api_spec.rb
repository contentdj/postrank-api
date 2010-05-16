require 'spec'
require 'lib/postrank/api'
require 'pp'

describe PostRank::API do
  IGVITA = '421df2d86ab95100de7dcc2e247a08ab'
  EVERBURNING = 'cb3e81ac96fb0ada1212dfce4f329474'

  let(:api) { PostRank::API.new(:appkey => 'test') }

  it "should initialize with appkey" do
    lambda {
      PostRank::API.new(:appkey => 'test')
    }.should_not raise_error
  end

  describe "FeedInfo API" do
    it "should query for feed info" do
      EM.synchrony do
        igvita = api.feed_info(:feed => 'igvita.com')

        igvita.class.should == Hash
        igvita['tags'].class.should == Array
        igvita['xml'].should match(/igvita/)

        EM.stop
      end
    end

    it "should query for feed info for multiple feeds" do
      EM.synchrony do
        feeds = api.feed_info(:feed => ['igvita.com', 'everburning.com'])
        feeds.class.should == Array
        feeds.size.should == 2

        EM.stop
      end
    end

    it "should return feed info data in-order"
  end

  describe "Feed API" do
    it "should retrieve content of a feed" do
      EM.synchrony do
        igvita = api.feed_info(:feed => 'igvita.com')
        feed = api.feed(:feed => igvita['id'])

        feed.class.should == Hash
        feed['meta']['title'].should match(/igvita/)
        feed['items'].size.should == 10

        EM.stop
      end
    end

    it "should retrieve 1 entry from a feed" do
      EM.synchrony do
        feed = api.feed(:feed => IGVITA, :num => 1)

        feed.class.should == Hash
        feed['meta']['title'].should match(/igvita/)
        feed['items'].size.should == 1

        EM.stop
      end
    end

    it "should retrieve entries matching a query" do
      EM.synchrony do
        feed = api.feed(:feed => IGVITA, :q => 'abrakadabra')

        feed.class.should == Hash
        feed['meta']['title'].should match(/igvita/)
        feed['items'].size.should == 0

        EM.stop
      end
    end
  end

  describe "Top Posts API" do
    it "should fetch top posts for a feed" do
      EM.synchrony do
        feed = api.top_posts(:feed => IGVITA, :num => 1)

        feed.class.should == Hash
        feed['meta']['title'].should match(/igvita/)
        feed['items'].size.should == 1

        EM.stop
      end
    end
  end

  describe "Feed Engagement API" do
    it "should fetch top posts for a feed" do
      EM.synchrony do
        eng = api.feed_engagement(:feed => IGVITA)

        eng.class.should == Hash
        eng.keys.size.should == 1
        eng[IGVITA]['sum'].class.should == Float

        EM.stop
      end
    end

    it "should fetch top posts for a feed" do
      EM.synchrony do
        eng = api.feed_engagement({
                                    :feed => [IGVITA, EVERBURNING],
                                    :summary => false,
                                    :start_time => 'yesterday'
        })

        eng.class.should == Hash
        eng.keys.size.should == 2
        eng[IGVITA].keys.size.should == 1
        eng[EVERBURNING].keys.size.should == 1

        EM.stop
      end
    end
  end
end
