require 'spec_helper'

describe SitesController do

  describe "GET index" do
    let(:published_sites) { Site.published }
    let(:tags) { get_tags_with_weight }

    def default_params
      [:get, :index]
    end

    before(:suite) do
      #create some entries and wait for sorting
      5.times do
        FactoryGirl.create(:crawled_site, :visits => rand(100), :likes => rand(100) )
        sleep 0.5
      end
    end

    it "should assign @sites" do
      call_action
      assigns[:sites] == published_sites
    end

    it "should assign @tags" do
      call_action
      assigns[:tags] == tags
    end

    context "archiv sites order" do
      it "should order with: created DESC" do
        get :index
        res = Site.published.order_by("created_at DESC")
        assigns[:sites].should match_array(res)
      end
      it "should order with: likes DESC" do
        get :index, {:sort => 'toprated'}
        res = Site.published.order_by("likes DESC")
        assigns[:sites].should match_array(res)
      end
      it "should order with: visits DESC" do
        get :index, {:sort => 'mostviewed'}
        res = Site.published.order_by("visits DESC")
        assigns[:sites].should match_array(res)
      end
    end
  end

  describe "GET show" do
    let(:site) { FactoryGirl.create(:site) }
    let(:comment) { FactoryGirl.create(:comment, :site => site) }
    
    before do
      Site.stub(:find_by_token).with("#{site.token}").and_return(site)
      Site.stub(:find_by_token).with(site.token).and_return(site)
    end
    
    def default_params
      [ :get, :show, { :id => site.token } ]
    end

    context "when site is published" do
      let(:site) { FactoryGirl.create(:crawled_site) }
      
      before do
        site.stub(:published?).and_return(true)
        site.stub(:site_crawled?).and_return(true)
      end

      it "should assign @site" do
        call_action
        assigns[:site].should == site
      end

      it "should call find_by_token on Site" do
        Site.should_receive(:find_by_token)
        call_action
      end

      it "should call published? on site" do
        site.should_receive(:published?)
        call_action
      end

      it "should increment site visits" do
        visits_after = site.visits + 1
        call_action
        site.visits.should == visits_after
      end

      it "should assign @tags" do
        call_action
        assigns[:tags].should == Site.tags_with_weight
      end
    end

    context "when site is unpublished" do
      let(:site) { FactoryGirl.create(:crawled_site) }
      
      before do
        site.stub(:published?).and_return(false)
        site.stub(:site_crawled?).and_return(true)
      end
      
      it "should assign @site" do
        call_action
        assigns[:site].should == site
      end
      
      it "should calls find_by_token on Site" do
        Site.should_receive(:find_by_token)
        call_action
      end

      it "should call published? on site" do
        site.should_receive(:published?)
        call_action
      end

      it "should redirect to root path" do
        call_action
        response.should redirect_to(root_path)
      end
    end
  end
end