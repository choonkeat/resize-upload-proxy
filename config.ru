require 'rack/cors'
use Rack::Cors do
  allow do
    origins  ENV['CORS_ORIGINS_HOSTNAME'] || '*'
    resource ENV['CORS_RESOURCE']         || '/*', :headers => :any, :methods => [:head, :get, :post, :put, :options]
  end
end

require './proxy.rb'
run Proxy.new
