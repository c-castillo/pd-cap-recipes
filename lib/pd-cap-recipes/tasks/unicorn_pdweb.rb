Capistrano::Configuration.instance(:must_exist).load do |config|
  namespace :unicorn_pdweb do
    Array(fetch(:unicorn_pdweb_roles, :app)).each do |role|
      namespace role do
         %w(start stop reload restart).each do |action|
          desc "#{action} Unicorn_pdweb"
          task action.to_sym, :roles => role, :on_error => :continue do
            # Use nohup because otherwise nginx dies when the connection is severed 
            run  "cd ${RAILS_ROOT} && RAILS_ENV=#{stage} APP=#{application} sudo nohup /etc/init.d/unicorn #{action} || \
                  RAILS_ENV=#{stage} sudo nohup /etc/init.d/unicorn_pdweb #{action}"
          end
        end
      end
    end
  end
end
