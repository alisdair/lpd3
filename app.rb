require "bundler/setup"
Bundler.require(:default)

require 'sinatra/asset_pipeline'

class App < Sinatra::Base
  register Sinatra::AssetPipeline

  configure do
    set :title, File.basename(File.expand_path(File.dirname(__FILE__)))

    set :haml, :format => :html5
  end

  get '/' do
    haml :index
  end
end
