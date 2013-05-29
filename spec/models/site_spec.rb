require "spec_helper"

describe Site do
  context 'relationships' do
    it { should have_many(:comments) }
  end

  context 'validations' do
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:url) }
    it { should allow_mass_assignment_of(:tags).as(:admin) }
    it { should allow_mass_assignment_of(:published).as(:admin) }

    it { should_not allow_mass_assignment_of(:likes) }
    it { should_not allow_mass_assignment_of(:dislikes) }
    it { should_not allow_mass_assignment_of(:visits) }
    it { should_not allow_mass_assignment_of(:site_crawled) }
  end
  
  it "has a valid factory" do
    FactoryGirl.build(:site).should be_valid
  end

  let(:site){ FactoryGirl.build(:site) }
  
  describe 'validates existence and format of url' do
    it 'if wrong format site is not valid' do
      site.url = 'http://asdf'
      site.should_not be_valid
    end
    it 'if url not exists site is not valid' do
      site.url = 'http://xt.at'
      site.should_not be_valid
    end
    it 'if clean url site is valid' do
      site.should be_valid
    end
  end
end