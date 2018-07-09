require 'Intercom'
require 'rubygems'
require 'sinatra'

  get '/' do
    erb :index
  end

  post '/inbox' do
    operation = params[:operation]
    pat = params[:pat]
    inbox_id = params[:inbox_id]
    @admin_id = params[:admin_id]

    # Set up Intercom Ruby SDK
    @intercom = Intercom::Client.new(token: pat);

    # Grab the list of conversation id values based on the Open / Close toggle
    if operation == "true"
      puts "The value passed was: #{operation} | The user wants to OPEN this inbox. Now grabbing all the CLOSED conversation"
      convos = @intercom.conversations.find_all(:type => 'admin', :id => @admin_id, :open => false)
    else
      puts "The value passed was: #{operation} | The user wants to CLOSE this inbox. Now grabbing all the OPEN conversation"
      convos = @intercom.conversations.find_all(:type => 'admin', :id => @admin_id, :open => true)
    end

    # Put those values into an array
    @convo_ids = []
      convos.each do |convo|
        @convo_ids.push(convo.id)
      end
    puts "Grabbed #{@convo_ids.count} conversations"
    puts "============================="

    # Run the selected function
    if operation == "true"
      open_inbox
    end

    if operation == "false"
      close_inbox
    end

    # Return to the home page
    puts "COMPLETE"
    erb :index
  end

  # FUNCTIONS USED BY THE APP
  def check_rate
    if not @intercom.rate_limit_details[:remaining].nil? and @intercom.rate_limit_details[:remaining] < 2
        sleep_time = @intercom.rate_limit_details[:reset_at].to_i - Time.now.to_i
        puts("Waiting for #{sleep_time} seconds to allow for rate limit to be reset")
        sleep sleep_time
      end
    else
  end

  def open_inbox
    @convo_ids.each do |convo|
      @intercom.conversations.open(id: convo, admin_id: @admin_id)
      puts "opening convo: #{convo}"
      check_rate()
    end
  end

  def close_inbox
    @convo_ids.each do |convo|
      @intercom.conversations.close(id: convo, admin_id: @admin_id)
      puts "closing convo: #{convo}"
      check_rate()
    end
  end
