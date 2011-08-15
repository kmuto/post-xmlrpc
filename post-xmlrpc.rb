#!/usr/bin/env ruby
# encoding: utf-8
#
# 写真ファイルを日付にリネームし、タイトルと内容を入力してtDiaryの記事として投稿する
#
# Copyright 2011 Kenshi Muto <kmuto@debian.org>
#
# Ruby: gtk2が必要
# サーバ: tDiary。xmlrpc.rbが動作するようにしておく
# コマンド: リモートアップロードの場合はsshが必要。
#          サムネールの作成にimagemagickが必要。
#
require 'xmlrpc/client'
require 'fileutils'
require 'gtk2'
require "#{ENV["HOME"]}/.post-xmlrpc.rb"

def cook_post(uri, login, pass, title, img, content, postdate)
  proxy = XMLRPC::Client.new_from_uri(uri)
  # TODO: サーバ側xmlrpc.rbのblogger.newPostを改変し、publishが空でない場合にはそれを日付けと見なすようにする
  # Wikiスタイルを前提。imageプラグインを改変し、image_cookで適切なURLエントリを作るようにしている
  return proxy.call("blogger.newPost", "", "tdiary", login, pass, "[cooking] #{title}\n{{image_cook \"#{img}\"}}\n#{content}", postdate)
end

def counttest(filename, testcmd)
  count = 1
  while true
    IO.popen("#{@config["testcmd"]}#{filename} && echo yes") do |p|
      if p.readlines.size == 0
        return filename
      else
        count += 1
        if count == 2
          filename = filename.sub(".", "-#{count}.")
        end
        filename.sub!(/-\d+\./, "-#{count}.")
        sleep(1)
      end
    end
  end
end

filename = ARGV.shift

if filename.nil? || !File.exist?(filename)
  d = Gtk::MessageDialog.new(nil, Gtk::Dialog::Flags::MODAL, Gtk::MessageDialog::Type::ERROR, Gtk::MessageDialog::ButtonsType::CLOSE, "ファイルが指定されていないか、該当ファイルが存在しません。")
  d.run
  d.destroy
  exit
end

ftime = File.mtime(filename)

newfilename = counttest(ftime.strftime("%Y-%m-%d.jpg"), @config["testcmd"])

window = Gtk::Window.new
window.set_title("#{filename}を#{newfilename}としてアップロード")
window.set_default_size(600, 400)

window.signal_connect("delete_event") {
  Gtk.main_quit
  false
}

window.signal_connect("destroy") {
  Gtk.main_quit
}

titletext = Gtk::Entry.new
contenttext = Gtk::TextView.new
contenttext.buffer.text = ""
begin
  contenttext.accept_tab = false
rescue
end

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.border_width = 5
scrolled_win.add(contenttext)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

button = Gtk::Button.new("書き込み")
button.signal_connect("clicked") {
  if titletext.text.strip.empty? || contenttext.buffer.text.strip.empty?
    d = Gtk::MessageDialog.new(window, Gtk::Dialog::Flags::MODAL, Gtk::MessageDialog::Type::ERROR, Gtk::MessageDialog::ButtonsType::CLOSE, "タイトルまたは内容が書き込まれていません。")
    d.run
    d.destroy
  else
    begin
      FileUtils.mv(filename, "#{@config["pictdir"]}/#{newfilename}") if filename != "#{@config["pictdir"]}/#{newfilename}"
      fork {
        # TODO: ネイティブで変換したほうがいい
        exec("convert", "-geometry", "#{@config["thumbsize"]}", "#{@config["pictdir"]}/#{newfilename}", "#{@config["thumbdir"]}/#{newfilename}")
      }
      Process.waitall

      # フル画像とサムネールのアップロード
      IO.popen(@config["putcmd"].gsub("%OFILE", "#{@config["pictdir"]}/#{newfilename}").gsub("%DFILE", newfilename)) do |p|
        puts p.readlines.join("\n")
      end
      IO.popen(@config["putthumbcmd"].gsub("%OFILE", "#{@config["thumbdir"]}/#{newfilename}").gsub("%DFILE", "#{newfilename}")) do |p|
        puts p.readlines.join("\n")
      end
      
      # 記事投稿
      puts cook_post(@config["posturi"], @config["username"], @config["password"], titletext.text.strip, newfilename, contenttext.buffer.text.strip, ftime.strftime("%Y%02m%02d"))
      Gtk.main_quit
    rescue Exception=>e
      puts e
      puts
      puts titletext.text.strip
      puts contenttext.buffer.text.strip
      Gtk.main_quit
    end
  end
}

cancel = Gtk::Button.new("キャンセル")
cancel.signal_connect("clicked") {
  Gtk.main_quit
}

hbox = Gtk::HBox.new(false, 0)
hbox.add(button)
hbox.add(cancel)

pixbuf = Gdk::Pixbuf.new(filename)

maxwidth = Gdk::Screen.default.width
maxheight = Gdk::Screen.default.height

height = pixbuf.height
width = pixbuf.width

# 縮小
if height > maxheight * @config["ratio"]
  height = maxheight * @config["ratio"]
  width = width * (height / pixbuf.height)
end

resizedimg = pixbuf.scale(width, height)
pixbuf = nil

image = Gtk::Image.new(resizedimg)

vbox = Gtk::VBox.new(false, 0)
vbox.add(titletext)
vbox.add(scrolled_win)
vbox.add(hbox)
vbox.add(image)

window.add(vbox)
window.border_width = 10
window.show_all

Gtk.main
