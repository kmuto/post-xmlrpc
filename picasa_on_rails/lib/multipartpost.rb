#--
# Helper class to prepare an HTTP POST request with a file upload
# Mostly taken from http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/113774
# Anything that's broken and wrong probably the fault of Bill Stilwell (bill@marginalia.org)
#++

  require 'rubygems'
  require 'mime/types'
  require 'net/http'
  
  class Param
    attr_accessor :k, :v
    def initialize( k, v )
      @k = k
      @v = v
    end
    
    def to_multipart
      return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
    end
  end
  
  class FileParam
    attr_accessor :k, :filename, :content
    def initialize( k, filename, content )
      @k = k
      @filename = filename
      @content = content
    end
    
    def to_multipart
      return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{@filename}\"\r\n" +
	"Content-Transfer-Encoding: binary\r\n" +
	"Content-Type: #{MIME::Types.type_for(@filename)}\r\n\r\n" + @content + "\r\n"
    end
  end

  class MultipartPost
    BOUNDARY = 'flickrrocks-aaaaaabbbb0000'
    HEADER = {"Content-type" => "multipart/form-data, boundary=" + BOUNDARY + " "}
    
    def prepare_query ( params )
      fp = []
      params.each do |k,v|
	if v.respond_to?(:read)
	  fp.push(FileParam.new(k,v.path,v.read))
	else
	  fp.push(Param.new(k,v))
	end
      end
      query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, HEADER
    end
  end


