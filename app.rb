require 'Intercom'
require 'rubygems'
require 'sinatra'

  get '/' do
    erb :index
  end

  post '/close' do
    pat = params[:pat]
    inbox_id = params[:inbox_id]
    admin_id = params[:admin_id]

    # Auth Section For Client
    intercom = Intercom::Client.new(token: pat);
    # Choose Admin:
    convos = intercom.conversations.find_all(:type => 'admin', :id => 273930, :open => false)
    convo_ids = []
      convos.each do |convo|
        convo_ids.push(convo.id)
      end
    puts convo_ids
    puts "============================="
    puts "CLOSING..."
      convo_ids.each do |convo|
        intercom.conversations.open(id: convo, admin_id: 273930)
        puts "closing convo: #{convo}"
        # Handle Rate Limits
        if not intercom.rate_limit_details[:remaining].nil? and intercom.rate_limit_details[:remaining] < 2
          sleep_time = intercom.rate_limit_details[:reset_at].to_i - Time.now.to_i
          puts("Waiting for #{sleep_time} seconds to allow for rate limit to be reset")
          sleep sleep_time
      end
    end
    puts "COMPLETE"
    erb :index
  end
