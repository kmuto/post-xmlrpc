#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# Copyright 2018 Kenshi Muto
# メールからinstagramのURL、記事内容を取り出して、投稿する
require 'mail'
require 'uri'
require 'cgi'
require 'open-uri'
require 'net/http'
require 'nkf'
require_relative '.post-instadiary.rb'

content = ''
ARGF.each do |l|
  content << NKF.nkf('-w -B0', l)
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
  next if l.empty? || l =~ /\A\-\-Apple/ || l =~ /Content/ || l =~ /charset/
  if l =~ /\A\-\-/ || l =~ /=E2=80=94/
    break
  end

  if l =~ /\Ahttps:/
    if l =~ /\/\/ig\.me/
      ret = `curl -s -I #{l}`
      l = ret.match(/\nlocation: (.+)[\r\n]/)[1]
    end

    insta = l.match(/\/p\/(.+?)\//)[1]

    # download
    wc = open(l).read.force_encoding('utf-8')
    # Instagram: “タラノメとベーコンのパスタ、アスパラのグリル”
    # if wc =~ /利用しています：「(.+?)」/
    if wc =~ /Instagram: “(.+?)”/
      subject << $1
    end
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
