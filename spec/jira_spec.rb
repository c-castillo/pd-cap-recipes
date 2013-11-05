require 'spec_helper'

describe "JIRA updates", :recipe => true, :tag => true do
  before(:each) do
    config.set :jira_from_domain, "example.com"
    config.set :jira_default_from_address, "user@example.com"
    config.set :jira_to_address, "jira@example.com"
    config.set :stage, "testing"
  end

  it "should always define a From email address" do
    config.jira_from_address.should eq("user@example.com")
  end

  it "should always define a deployment name" do
    config.jira_deployment_name
  end

  it "should always define a deployment human" do
    config.jira_human
  end

  it "should find a JIRA issue when there is one" do
    valid_messages = ['omg OPS-123',
                      'OPS-123 bbq',
                      'omg OPS-123 bbq',
                      'OPS-123']

    valid_messages.each do |msg|
      config.find_jira_issues(msg).should have(1).items
      config.find_jira_issues(msg).should include("OPS-123")
    end

    multiple_issues = "omg OPS-123 ENG-456 bbq"
    config.find_jira_issues(multiple_issues).should have(2).items
    config.find_jira_issues(multiple_issues).should include("OPS-123")
    config.find_jira_issues(multiple_issues).should include("ENG-456")
  end

  it "should NOT find a JIRA issue when there isn't one" do
    config.find_jira_issues("foo bar baz").should have(0).items
  end
end
