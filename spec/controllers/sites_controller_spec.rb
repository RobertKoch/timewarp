require 'spec_helper'

describe SitesController do
  let(:site) { FactoryGirl.create(:site) }
  let(:comment) { FactoryGirl.create(:comment, :site => site) }
  
  before do
    Site.stub(:find_by_token).with("#{site.token}").and_return(site)
    Site.stub(:find_by_token).with(site.token).and_return(site)
  end

  describe "GET show" do
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