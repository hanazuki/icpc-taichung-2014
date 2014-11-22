#!/usr/bin/env ruby

require 'csv'
require 'cgi'
require 'open-uri'

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'

uri = 'http://140.128.48.5/~tylee/summary.html'
#uri = './full.html'
csv = './taichung.csv'


doc = Nokogiri::HTML(open(uri))
teams = CSV.read(csv)

hd = doc.xpath('//table/tr[1]/th').map(&:text).map{|s| s.gsub(/\A[[:space:]]+|[[:space:]]+\Z/, '') }
time = Time.now.localtime('+08:00').to_s

hd.insert(2, 'Univ')

puts <<EOS
<!DOCTYPE html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>ACM-ICPC 2014 Asia Taichung Regional Contest</title>
<style>
table {
  border-collapse: collapse;
}
th, td {
  padding: 1px 3px
}

th {
  border-bottom: 2px solid black
}
tr {
  border-bottom: 1px solid black
}

.j-na { color: #aaa }
.j-wa { color: #f22; font-style: italic }
.j-ac { color: #292; font-weight: bold }
.s-odd { background: #eee }
</style>
<small>Scores retrieved at #{time} from #{uri}. Contest will be held on 2014-11-22 09:30--14:30 localtime.</small>
<table>
<tr>#{hd.map{|s|'<th>'+s+'</th>'}.join}</tr>
EOS

doc.xpath('//table/tr[td]').each do |e|
  r = e.xpath('td').map(&:text)
  name = nil
  univ = nil

  if /^team(\d+)$/ =~ r[1] and team = teams.find {|t| t[0] == $1 }
    name = team[1]
    univ = team[2]
    univ = "[#{team[3]}] #{univ}" if univ and team[3]
  end

  r[1] = name if name
  r.insert(2, univ || '')

  if r[3] =~ /(\d+)/
    if $1.to_i % 2 == 0
      puts "<tr class=s-even>"
    else
      puts "<tr class=s-odd>"
    end
  else
    puts '<tr>'
  end

  r.each_with_index do |s, i|
    c = nil
    if hd[i].length == 1
      if %r{^0/--$} =~ s
        c = 'j-na'
      elsif %r{^\d+/--$} =~ s
        c = 'j-wa'
      elsif %r{^\d+/\d+$} =~ s
        c = 'j-ac'
      end
    end
    if c
      puts "<td class=\"#{c}\">"+CGI.escapeHTML(s)+'</td>'
    else
      puts "<td>"+CGI.escapeHTML(s)+'</td>'
    end
  end
  puts "</tr>"
end
puts <<EOS
</table><address>This is an <strong>unofficial</strong> scoreboard. Please contact <a href="http://www.rollingapple.net/">Kasumi Hanazuki</a> for any problems.</address>
EOS
