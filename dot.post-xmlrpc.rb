# encoding: utf-8
# 内容を変更し、~/.post-xmlrpc.rb という名前で保存する
@config = {
  "ratio" => 0.7, # 画面高さに対するウィンドウ比率
  "thumbsize" => 400, # サムネールの幅ピクセル数
  "posturi" => "http://REMOTESERVER/xmlrpc.rb", # XML-RPCを投稿するURI
  "username" => "MYUSERNAME", # tDiary投稿ユーザ名
  "password" => "PASSWORD", # tDiary投稿パスワード
  "pictdir" => "#{ENV["HOME"]}/Pictures/cooking", # ローカルに写真を保存するフォルダ
  #
  # 以下は Picasa 以外のアップロード時の設定
  #
  "thumbdir" => "#{ENV["HOME"]}/Pictures/cooking/thumbnail", # ローカルにサムネールを保存するフォルダ
  "testcmd" => "ssh REMOTESERVER test -f /var/www/pictures/", # ファイルの重複を確認するためのコマンド。この後にファイル名が付き、ファイルの存在を確認する。ローカルだけで完結させたい場合は「test -f /var/www/pictures/」のようにすればよい
  "putcmd" => "scp %OFILE REMOTESERVER:/var/www/pictures/%DFILE", # ローカルからリモートにコピーするコマンド。%OFILE、%DFILEは置き換えられる
  "putthumbcmd" => "scp %OFILE REMOTESERVER:/var/www/pictures/thumbnail/%DFILE", # ローカルからリモートにサムネールをコピーするコマンド。%OFILE、%DFILEは置き換えられる
  #
  # 以下は Picasa アップロード時の設定
  #
  "picasa" => true, # Picasaを利用する。利用しない場合はnilに
  "picasa_username" => "MYGOOGLEUSERNAME", # Googleアカウント名
  "picasa_passwd" => "MYGOOGLEPASSWD", # Googleパスワード。nilにして環境変数PICASA_PASSWDで指定することもできる
  "picasa_album" => "MYALBUM", # 投稿するアルバム。名前ルールがWeb上で見える「タイトル」と違うのが困りどころ
  "picasa_maxwidth" => 1600, # 幅のリサイズ閾値
}
