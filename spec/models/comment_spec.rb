require "spec_helper"

describe Comment do
  context 'relationships' do
    it { should belong_to(:site) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:email) }
    it { should validate_format_of(:email) }

    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:text) }
  end
  
  it "has a valid factory" do
    FactoryGirl.build(:comment).should be_valid
  end
end