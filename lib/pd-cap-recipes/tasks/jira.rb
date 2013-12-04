# A JIRA notification Capistrano task
#
# Does what it says on the tin - sends an email to your JIRA issue tracker
# for every issue you mention in a deploy message.  Assumes you're also
# using the Comment task.
#
# Variables to set in your config/deploy.rb:
#
# jira_default_from_address = "dev@example.com"
# jira_from_domain = "example.com"
# jira_mail_config = { standard Mail config hash }
# jira_to_address = "jira@tracker.example.com"
#

Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :email do
    desc "Send email to JIRA via SMTP"
    task :notify_jira do

      mail_config = HashWithIndifferentAccess.new(jira_mail_config).symbolize_keys
      Mail.defaults do
        delivery_method :smtp, mail_config
      end

      to_address   = jira_to_address
      from_address = jira_from_address
      message      = jira_message
      jira_issues  = find_jira_issues(message)

      jira_issues.each do |issue|
        puts 'Updating JIRA issue ' + issue + ' with this deploy note'
        Mail.deliver do
          to to_address
          from from_address
          subject issue
          body message
        end
      end
    end
  end

  set :jira_message do
    message = "#{jira_human} has deployed #{jira_deployment_name} to #{stage}.\n\n"
    message << comment
    message
  end

  def find_jira_issues(to_check)
    # FYI: This regex tries to balance between the overly-broad standard JIRA issue
    # ID, and what is in common use.  (ABC-123, etc).  Improvements welcomed.
    to_check.scan(/[a-z,A-Z]{2,4}-[0-9]{1,5}/)
  end

  def jira_from_address
    if (u = %x{git config user.email}.strip) =~ /#{jira_from_domain}/
      u
    else
      jira_default_from_address
    end
  end

  def jira_deployment_name
    if branch
      "#{application}/#{branch}"
    else
      application
    end
  end

  def jira_human
    if (u = %x{git config user.name}.strip) != ""
      u
    else
      "Someone"
    end
  end
end
