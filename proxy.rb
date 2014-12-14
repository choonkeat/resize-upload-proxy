require 'rest_client'
require 'rack/proxy'
require 'paperclip'
require 'logger'
require 'uri'
require 'cgi'

$logger = Logger.new(STDOUT)
Cocaine::CommandLine.logger = $logger

class Proxy < Rack::Proxy
  def call(env)
    # setup
    request     = Rack::Request.new(env)
    params      = request.params
    geometry    = params.delete('style')
    backend_url = params.delete('url')

    # rewrite
    uri = URI.join('http:/', backend_url)
    env['HTTP_HOST'] = uri.host
    env['SERVER_NAME'] = uri.host
    env['SERVER_PORT'] = (uri.port || '80').to_s

    # handle
    return super unless request.post?

    thumb = Paperclip::Thumbnail.new(params['file'][:tempfile], geometry: geometry)
    output = thumb.make
    params['file'] = Rack::Multipart::UploadedFile.new(output, params['file'][:type])

    t = Time.now
    RestClient.post uri.to_s, params, self.class.extract_http_request_headers(request.env) do |res, req, result, &block|
      $logger.info "#{output.size} bytes to #{uri.to_s} took #{Time.now.to_f - t.to_f}s"
      rack_compatible_headers = result.to_hash.inject({}) {|sum,(k,v)| sum.merge(k => v.join("\n")) }
      [result.code, rack_compatible_headers, [res]]
    end
  rescue Exception
    [500, {'X-Exception' => $!.to_s}, []]
  end
end
