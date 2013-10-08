# Pagerduty Capistrano Recipes Collection

These are various capistrano recipes used at [PagerDuty Inc.](http://www.pagerduty.com/). Feel free to fork and contribute to them.

## Running tests

    $ bundle install
    $ bundle exec rspec spec

## Install

Add the following to your Gemfile.

    group :capistrano do 
      # Shared capistrano recipes
      gem 'pd-cap-recipes', :git => 'git://github.com/PagerDuty/pd-cap-recipes.git'
    
      # extra dependencies for some tasks
      gem 'git', '1.2.5'
      gem 'hipchat', :git => 'git://github.com/smathieu/hipchat.git'
      gem 'cap_gun'
      gem 'grit'
    end

Then run 
    bundle install
    
## Usage

### Git 

One of the main feature of these recipes is the deep integration with Git and added sanity check to prevent your from deploying the wrong branch. 

The first thing to know is that we at PagerDuty always deploy of a tag, never from a branch. You can generate a new tag by running the follwing command:

    cap production deploy:prepare
    
This should generate a tag in a format like master-1328567775. You can then deploy the tag with the following command:

cap production deploy -s tag=master-1328567775

The following sanity check will be performed automatically:

* Validate the master-1328567775 as the latest deploy as an ancestor
* Validate that you have indeed checkout that branch before deploying

Another nice thing this recipe does is keep an up to date tag for each environment. So the production tag is what is currently deployed to production. So if you ever need to diff a branch and what is already deploy you can do something like:

    git diff production

### Deploy Comments

When you deploy, you will prompted for a comment. This will be used to notify your coworkers via email and HipChat. 

### Improved Logging

The entire output produced by capistrano is logged to log/capistrano.log.

### Assets

When using the Rails 3.1 assets pipeline, we enhance the default capistrano task with two features. 

First, we only trigger an asset compillation when assets have changes. This is a huge time saver if you have a lot of assets. If you want to force the compilation of your assets, you can force it by setting the COMPILE_ASSETS environment variable to 'true'. You can also set the following capistrano variable:

    set :always_compile_assets, true

The other feature is pushing your assets to a CDN using rsync. You can enable this functionality by adding this line to your capistrano config:

    set :asset_cdn_host, "<you_cdn_user>@<your_cdn_url>"

You'll have to make sure that rsync can access your CDN without being prompter for a password.


### Benchmarking your deploys

There's also a performance report printed at the end of every deploy to help you find slow tasks in your deployments and keep things snappy.


