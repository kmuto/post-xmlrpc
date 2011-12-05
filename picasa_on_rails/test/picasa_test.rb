# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'picasa'

class PicasaTest < Test::Unit::TestCase
  
  PICASA_USER_ID = "you@gmail.com"
  PICASA_PASSWORD = "yourpass"
  
  def Xtest_login
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    #puts picasa.picasa_session.auth_key
  end
  
  def Xtest_get_private_albums
    # At first log in to picasa
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    albums = []
    albums = picasa.albums(:access => "private")
    albums.each do |album|
      puts "===== Album ======"
      puts album.id
      puts album.name
      puts album.number_of_photos
      puts album.number_of_comments
      puts album.is_commentable
      puts album.access
      
      puts album.author_name
      puts album.author_uri
      
      puts album.title
      puts album.title_type
      puts album.description
      puts album.description_type
      puts album.image_url
      puts album.image_type
      puts album.thumbnail.url
      puts album.thumbnail.width
      puts album.thumbnail.height       
    end  
  end
  
  def Xtest_get_album_using_name
    # At first log in to picasa
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    album = picasa.album(:name => "RubyAlbum1", :access => "private")
    puts "===== Album ======"
    puts album.id
    puts album.name
    puts album.number_of_photos
    puts album.number_of_comments
    puts album.is_commentable
    puts album.access
      
    puts album.author_name
    puts album.author_uri
      
    puts album.title
    puts album.title_type
    puts album.description
    puts album.description_type
    puts album.image_url
    puts album.image_type
    puts album.thumbnail.url
    puts album.thumbnail.width
    puts album.thumbnail.height
    
    assert_equal "RubyAlbum1", album.name
  end
  
  def Xtest_get_photos_of_album
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    album = picasa.album(:name => "RubyAlbum1", :access => "private")
    photos = album.photos
    if(photos.size > 0)
      puts "Retrived #{photos.size} photos" 
      photos.each do |photo|
        puts "====== Photo ====="
        puts photo.id
        puts photo.title
        puts photo.description
        puts photo.url
        puts photo.width
        puts photo.height
        puts photo.size
        puts photo.medium
        puts photo.type
        puts photo.client
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
  
  def Xtest_get_photos_from_picasa
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    photos = picasa.photos(:album => "RubyAlbum1")
    if(photos.size > 0)
      photos.each do |photo|
        puts "====== Photos ====="
        puts photo.id
        puts photo.title
        puts photo.description
        puts photo.url
        puts photo.width
        puts photo.height
        puts photo.size
        puts photo.medium
        puts photo.type
        puts photo.client
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
  
  def Xtest_post_photo_to_an_album
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    album = picasa.album(:name => "RubyAlbum1", :access => "private")
    
    fileName = "C:/Users/Public/Pictures/Sample Pictures/Waterfall.jpg"
    image_data = open(fileName, "rb").read
    photo = picasa.post_photo(image_data, :album_id => album.id, 
      :summary => "Upload from ruby api test module", :title => "From Ruby test module",
      :local_file_name => "Waterfall.jpg")
    puts photo.inspect
  end
  
  def Xtest_add_an_album
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    albums = picasa.albums(:access => "all")
    album_count = albums.size()
    album_count = 0 if(album_count == nil)
    
    album = picasa.create_album(:title => "Ruby Album #{album_count + 1}", :summary => "Summary of Ruby Album #{album_count+ 1}",
      :location => "VarsityDays", :access => "public", :commentable => true)
    
    puts album.inspect
  end
  
  def Xtest_update_photo
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    album = picasa.album(:name => "RubyAlbum1", :access => "private")
    photos = album.photos
    
    if(photos.size > 0)
      photo = photos[0]
      
      previous_title = photo.title
      previous_description = photo.description
      previous_version = photo.version_number
      photo.title = previous_title + " edited"
      photo.description = previous_description + " edited"
      photo.is_commentable = false
      
      is_updated = photo.update
      assert_equal(true, is_updated)
      assert_not_equal(previous_version, photo.version_number)
      
      previous_version = photo.version_number
      photo.title = previous_title + " edited again"
      photo.description = previous_description + " edited again"
      
      is_updated = photo.update
      assert_equal(true, is_updated)
      assert_not_equal(previous_version, photo.version_number)
      
    else
      puts "====== No photo for this album ====="
    end
  end
  
  def Xtest_change_album_of_photo()
    # At first log in to picasa
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    album1 = picasa.album(:name => "RubyAlbum1", :access => "private")
    album2 = picasa.album(:name => "RubyAlbum23", :access => "public")
    
    photos_of_album1 = album1.photos
    
    if(photos_of_album1.size > 0)
      photo = photos_of_album1[0]
      
      photos_of_album2 = album2.photos
      number_of_photos_before_move_in_album2 = photos_of_album2.nil? ? 0 : photos_of_album2.size
      
      puts photo.inspect
      photo.move_to_album(album2.id)
      puts photo.inspect
      
      photos_of_album2 = album2.photos
      number_of_photos_after_move_in_album2 = photos_of_album2.nil? ? 0 : photos_of_album2.size
      
      assert_equal(number_of_photos_before_move_in_album2 + 1 , number_of_photos_after_move_in_album2)
    else
      puts "====== No photo for this album to move ====="
    end
    
  end
  
  def Xtest_load_photo()
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    photo_url = "http://picasaweb.google.com/data/entry/api/user/picasaruby/albumid/5225014940769385249/photoid/5225015152899609730?authkey=dKwM3DpWLgU"
    
    photo = picasa.load_photo(photo_url)
    assert_not_nil(photo.self_xml_url)
    puts photo.inspect
    
    assert_not_nil(photo)
  end
  
  def Xtest_load_photo_with_id()
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    photo_url = "http://picasaweb.google.com/data/entry/api/user/picasaruby/albumid/5225014940769385249/photoid/5225015152899609730?authkey=dKwM3DpWLgU"
    
    photo = picasa.load_photo(photo_url)
    assert_not_nil(photo)
    assert_not_nil(photo.self_xml_url)
    
    photo2 = picasa.load_photo_with_id(photo.id, photo.album_id)
    assert_not_nil(photo2.self_xml_url)
    assert_equal(photo.xml, photo2.xml)
  end
  
  def Xtest_load_and_update_photo()
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    photo_url = "http://picasaweb.google.com/data/entry/api/user/picasaruby/albumid/5225014940769385249/photoid/5225015152899609730?authkey=dKwM3DpWLgU"
    
    photo = picasa.load_photo(photo_url)
    
    assert_not_nil(photo)
    
    previous_title = photo.title
    previous_description = photo.description
    previous_version = photo.version_number
    
    new_title = previous_title + " edited after loading"
    new_description = previous_description + " edited after loading"
    
    photo.title = new_title
    photo.description = new_description
      
    is_updated = photo.update
    
    assert_equal(true, is_updated)
    assert_not_equal(previous_version, photo.version_number)
    
      
  end
  
  def Xtest_delete_photo
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    #expecting there is an album of name "RubyAlbumDeleteTest" in specified picasa account
    album = picasa.album(:name => "RubyAlbumDeleteTest", :access => "private")
    
    fileName = "C:/Users/Public/Pictures/Sample Pictures/Waterfall.jpg"
    image_data = open(fileName, "rb").read
    photo = picasa.post_photo(image_data, :album_id => album.id, 
      :summary => "Upload from ruby api test module", :title => "From Ruby test module",
      :local_file_name => "Waterfall.jpg")
    photo_url = photo.self_xml_url
    #puts "Url of photo: " + photo_url
    
    is_deleted = picasa.delete_photo(photo)
    assert_equal(true, is_deleted)
    
    is_deleted = picasa.delete_photo(photo)
    assert_equal(false, is_deleted)
    
    deleted_photo = picasa.load_photo(photo_url)
    assert_nil(deleted_photo)    
    
  end
  
  def Xtest_delete_album
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    albums = picasa.albums(:access => "all")
    album_count = albums.size()
    album_count = 0 if(album_count == nil)
    
    #create an album to delete
    album = picasa.create_album(:title => "Delete This Album", :summary => "Summary of Ruby Album #{album_count+ 1}",
      :location => "VarsityDays", :access => "public", :commentable => true)
    
    is_deleted = picasa.delete_album(album)
    assert_equal(true, is_deleted)
    
    is_deleted = picasa.delete_album(album)
    assert_equal(false, is_deleted)
    
    deleted_album = picasa.album(:name => "DeleteThisAlbum")
    assert_nil(deleted_album)
    
  end
  
  def test_load_album_with_id()
    picasa = Picasa::Picasa.new
    picasa.login(PICASA_USER_ID, PICASA_PASSWORD)
    assert_not_nil picasa.picasa_session.auth_key, "Failed to log in to picasa"
    
    album_url = "http://picasaweb.google.com/data/entry/api/user/picasaruby/albumid/5225014940769385249"
    
    album = picasa.load_album(album_url)
    assert_not_nil(album)
    assert_not_nil(album.self_xml_url)
    
    album2 = picasa.load_album_with_id(album.id)
    assert_not_nil(album2.self_xml_url)
    assert_equal(album.xml, album2.xml)
  end
  
end
