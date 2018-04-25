#!/usr/bin/ruby
# Copyright 2018 Kenshi Muto
# メールからinstagramのURL、記事内容を取り出して、投稿する
require 'mail'
require 'uri'
require 'cgi'
require 'net/http'
require_relative '.post-instadiary.rb'

content = ''
ARGF.each do |l|
  content << l
end

mail = Mail.new(content)
if !@config['allow_from'].include?(mail.from[0]) ||
   @config['allow_to'] != mail.to[0]
  exit 1
end

subject = []
com = []
insta = nil
mail.body.to_s.split("\n").each do |l|
  l.chomp!
  if l =~ /\A\-\-/
    break
  end

  if l =~ /\Ahttps:/
    insta = l.match(/\/p\/(.+?)\/\Z/)[1]
    next
  end

  if insta
    com << l
  else
    subject << l
  end
end

cont = <<EOT
! [cooking] #{subject.join}
{{instagram '#{insta}'}}

#{com.join("\n\n")}
EOT

t = Time.now
uriobj = URI.parse(@config['posturi'])
data = {
  'title' => '',
  'year' => t.year,
  'month' => t.month,
  'day' => t.day,
  'body' => cont,
  'append' => 'true',
  'makerss_update' => 'true'
}

req = Net::HTTP::Get.new(uriobj)
req.basic_auth(@config['username'], @config['password'])

res = Net::HTTP.start(uriobj.host, uriobj.port, :use_ssl => uriobj.scheme == 'https') do |http|
  http.request(req)
end

if %r|<input type="hidden" name="csrf_protection_key" value="([^"]+)">| =~ res.body
  data['csrf_protection_key'] = $1
end

req = Net::HTTP::Post.new(uriobj)
req.basic_auth(@config['username'], @config['password'])
req.set_form_data(data)
req['Referer'] = @config['posturi']

res = Net::HTTP.start(uriobj.host, uriobj.port, :use_ssl => uriobj.scheme == 'https') do |http|
  http.request(req)
end
# puts res.body
