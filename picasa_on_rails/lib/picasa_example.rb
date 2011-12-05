require "picasa"

picasa = Picasa::Picasa.new
puts picasa.login("you@gmail.com", "yourpass")
puts picasa.picasa_session.auth_key

albums = []
# get albums of logged in account
albums = picasa.albums(:access => "private")
albums.each do |album|
  puts "===== Album ======"
  puts album.id
  puts album.name
  
  puts album.thumbnail.url
  puts album.thumbnail.width
  puts album.thumbnail.height
  
  # get photos of an album
  photos = album.photos
  if(photos.size > 0)
    photos.each do |photo|
      puts "====== Photo ====="
      puts photo.id
      puts photo.title
      puts photo.url
      photo.thumbnails.each do |thumbnail|
        puts thumbnail.url
        puts thumbnail.width
        puts thumbnail.height
      end
    end
  else
    puts "====== No photo for this album ====="
  end
  
end

# get photos using album name
photos = picasa.photos(:album => "AlbumFromRuby")
puts "====== Photos of AlbumFromRuby ====="
if(photos.size > 0)
  photos.each do |photo|
    puts "====== Photos ====="
    puts photo.id
    puts photo.title
    puts photo.url
    photo.thumbnails.each do |thumbnail|
      puts thumbnail.url
      puts thumbnail.width
      puts thumbnail.height
    end
  end
else
  puts "====== No photo for this album ====="
end

# get photos using another user_id and album name
photos = []
photos = albums[0].photos(:user_id => "me")

photos.each do |photo|
  puts photo.id
  puts photo.title
  puts photo.description
  puts photo.url
  photo.thumbnails.each do |thumbnail|
    puts thumbnail.url
    puts thumbnail.width
    puts thumbnail.height
  end
  puts "====== Photo ====="
end

# Create an album
album = picasa.create_album(:title => "Album From Ruby", 
  :summary => "This album is created from ruby code",
  :location => "Bangladesh", :keywords => "keyword1, keyword2")
puts album.inspect

# Post photo to an album
fileName = "C:/Documents and Settings/All Users/Documents/My Pictures/Sample Pictures/Blue hills.jpg"
image_data = open(fileName, "rb").read
photo = picasa.post_photo(image_data, :album => "AlbumFromRuby", 
  :summary => "Upload2 from ruby api", :title => "From Ruby 2",
  :local_file_name => "Blue hills.jpg")
puts photo.inspect