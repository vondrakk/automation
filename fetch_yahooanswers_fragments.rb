#!/usr/bin/ruby

require 'mechanize'
require 'mysql2'

dbh = Mysql2::Client.new(:host => "localhost", :username => "root")
dbh.select_db('db')

urls=[
	'http://answers.yahoo.com/;_ylt=Au6.Mc6Xquqhvp_44oTfapfj1KIX;_ylv=3?link=popular#yan-questions',
	'http://answers.yahoo.com/;_ylt=AhRjPsnstWiTPw7fSf1zfEjj1KIX;_ylv=3?link=recent#yan-questions'
]

web = Mechanize.new { |agent| 
    agent.user_agent_alias = 'Windows Chrome'
}

urls.each do |url| 
	web.get(url) do |page|
		page.content.scan(/<h3><a .*? href="\/question\/.*?".*?>(.*?)<\/a><\/h3>/).each do |msg|
			m = msg[0].gsub(/&.*?;/,'').gsub(/#.*?;/,'').gsub(/\.\.\./,'')
			next if m == ""
			dbh.query("insert ignore into fragments values(0,'"+dbh.escape(m)+"','UNUSED')")
			puts m
		end
	end
end
