require 'rest_client'
require 'paperclip'
require 'logger'
require 'uri'
require 'cgi'

$logger = Logger.new(STDOUT)
Cocaine::CommandLine.logger = $logger

class Proxy
  def call(env)
    request = Rack::Request.new(env)
    if request.post?
      params = request.params
      thumb = Paperclip::Thumbnail.new(params['file'][:tempfile], geometry: params.delete('style'))
      output = thumb.make
      params['file'] = Rack::Multipart::UploadedFile.new(output, params['file'][:type])

      uri = URI.join('http:/', params.delete('url'))
      t = Time.now
      RestClient.post uri.to_s, params do |res, req, result, &block|
        $logger.info "POST #{output.size} bytes to #{uri.to_s} took #{Time.now.to_f - t.to_f}s"
        rack_compatible_headers = result.to_hash.inject({}) {|sum,(k,v)| sum.merge(k => v.join("\n")) }
        [result.code, rack_compatible_headers, [res]]
      end
    else
      [200, {"Content-Type" => "text/plain"}, []]
    end
  end
end
