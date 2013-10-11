namespace :db do
  desc 'Populate and erase databse'
  task :populate => :environment do
    require 'populator'
    require 'faker'

    [Team,User].each(&:delete_all)

    User.populate 20 do |user|
      user.email = Faker::Internet::email
      user.encrypted_password = User.new(:password => "password").encrypted_password
      user.sign_in_count = 1
    end

    User.create(:email => "foo@bar.com", :password => "password")

    Team.populate 10 do |team|
      team.name = Populator.words(1..3).titleize

    end

    Team.all.each do |team|
      User.where(:team_id => nil ).shuffle[1,2].each { |u| u.team = team ; u.save! }
    end
  end
end
