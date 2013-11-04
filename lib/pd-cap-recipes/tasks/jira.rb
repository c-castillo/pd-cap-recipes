Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :email do
    desc "Send email to JIRA via Mailgun SMTP"
    task :notify_jira do
      # This follows the same convention as cap_gun, and uses the prod config
      # to figure out what creds to use with Mailgun.
      mail_config = HashWithIndifferentAccess.new(YAML.load_file('config/drivers/mailgun.yml')['production']).symbolize_keys
      Mail.defaults do
        delivery_method :smtp, mail_config
      end

      as_user = jira_email
      message = jira_message
      jira_issues = find_jira_issues(message)
      jira_issues.each do |issue|
        puts 'Updating JIRA issue ' + issue + ' with this deploy note as ' + as_user
        Mail.deliver do
          to 'jira@pagerduty.atlassian.net'
          from as_user
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
    to_check.scan(/[A-Z]{2,4}-[0-9]{1,5}/)
  end

  def jira_email
    if (u = %x{git config user.email}.strip) =~ /pagerduty.com/
      u
    else
      "jira@pagerduty.com"
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
