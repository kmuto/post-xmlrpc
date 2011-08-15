# encoding: utf-8
# 内容を変更し、~/.post-xmlrpc.rb という名前で保存する
@config = {
  "ratio" => 0.7, # 画面高さに対するウィンドウ比率
  "thumbsize" => 200, # サムネールの幅ピクセル数
  "pictdir" => "#{ENV["HOME"]}/Pictures/cooking", # ローカルに写真を保存するフォルダ
  "thumbdir" => "#{ENV["HOME"]}/Pictures/cooking/thumbnail", # ローカルにサムネールを保存するフォルダ
  "posturi" => "http://REMOTESERVER/xmlrpc.rb", # XML-RPCを投稿するURI
  "username" => "MYUSERNAME", # 投稿ユーザ名
  "password" => "PASSWORD", # 投稿パスワード
  "testcmd" => "ssh REMOTESERVER test -f /var/www/pictures/", # ファイルの重複を確認するためのコマンド。この後にファイル名が付き、ファイルの存在を確認する。ローカルだけで完結させたい場合は「test -f /var/www/pictures/」のようにすればよい
  "putcmd" => "scp %OFILE REMOTESERVER:/var/www/pictures/%DFILE", # ローカルからリモートにコピーするコマンド。%OFILE、%DFILEは置き換えられる
  "putthumbcmd" => "scp %OFILE REMOTESERVER:/var/www/pictures/thumbnail/%DFILE", # ローカルからリモートにサムネールをコピーするコマンド。%OFILE、%DFILEは置き換えられる
}
