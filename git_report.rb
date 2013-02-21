require 'git'
require 'pony'
#currently this program takes one date in the form of '2012-12-31'
#Then it retrieves the commits from loadmax and user management from said date to 6 days later.

def main(date_string)
  #If no date is provided use the current date.
  date_argument = date_string.split("-") unless date_string.match(/\d\d\d\d-\d\d-\d\d/).nil?
  start_of_week = Time.new(date_argument[0],date_argument[1],date_argument[2]) || Time.now
  end_of_week = start_of_week + (60*60*24*6) #add 6 days

  #Add more repos here.
  #TODO make method that searches an entire directory and dynamically inserts into hash.
  repos={}
  repos["Loadmax"] = Git.open('/Users/davidhahn/Dev/cta-projects/loadmax/')
  repos["AIT"] = Git.open('/Users/davidhahn/Dev/cta-projects/ait/')
  repos["AIT Outbound"] = Git.open('/Users/davidhahn/Dev/cta-projects/ait-outbound-leads/')
  repos["User Management"] = Git.open('/Users/davidhahn/Dev/cta-projects/user-management/')

  #Processing of repos
  subject = "Weekly Report #{start_of_week.strftime('%F')} to #{end_of_week.strftime('%F')}"
  #TODO build a hash and then add the ul's and li's
  html_body = "<ul>"
  repos.each do |repo_title,repo|
    html_body += "<li> " + repo_title.to_s.capitalize + "</li>"
    html_body += "<ul>"
    repo.log.since(start_of_week.strftime('%F')).each do |commit|
      html_body += "<li>" + commit.message.capitalize + "</li>" if commit.committer.name.include?('David') and !blacklist_included(commit)
    end
    html_body += "</ul>"
  end
  html_body += "</ul>"

  Pony.mail({
    :to => 'dhahn@ctatechs.com',
    :subject => subject,
    :html_body => html_body,
    :via => :smtp,
    :via_options => {
      :address              => 'smtp.gmail.com',
      :port                 => '587',
      :enable_starttls_auto => true,
      :user_name            => '',
      :password             => '',
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "ctatechs.com" # the HELO domain provided by the client to the server
    }
  })
end

#TODO FINISH THIS
#This method takes in a hash of Git objects. 
#It then removes unneccesary commits.
#It returns a hash of arrays of commits.
def remove_commits()
end

#This method adds ul and li tags to a hash of arrays.
#It returns a formatted html_body string
#Example: {foo: ["bar","baz","boo"],bar: ["foo","bar"]} converts to:
#<ul><li>foo</li><ul><li>bar</li><li>baz</li><li>boo</li></ul><li>bar</li><ul><li>foo</li><li>bar</li></ul></ul>
#TODO FINISH THIS
def format_body(options)
  html_body
  options.each do |option|
    html_body += "<li> " + option.to_s.capitalize + "</li>"
    html_body += "<ul>"
    repo.log.since(start_of_week).each do |commit|
      html_body += "<li>" + commit.message.capitalize + "</li>" unless !commit.committer.name.include?('Kyle') or blacklist(commit)
    end
    html_body += "</ul>"
  end
  html_body += "</ul>"
end

#This method take a commit
#It then returns false if the commit.message contains a  blacklisted item.
def blacklist_included(commit)
  black_list = ["Merge branch 'master'","Catch up"]
  black_list.each {|item| return true if commit.message.include?(item)}
  false
end

main(ARGV[0])
