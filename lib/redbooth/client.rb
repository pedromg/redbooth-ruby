module Redbooth
  class Client
    RESOURCES = [:me, :user]

    attr_reader :session

    # Creates an client object using the given Redbooth session.
    # existing account.
    #
    # @param [String] client object to use the redbooth api.
    def initialize(session)
      raise Redbooth::AuthenticationError unless session.valid?
      @session = session
      self
    end

    # Metaprograming of every resource to execute it over the perform!
    # method just to add session tho the resource
    #
    # @param [String||Symbol] action name of the action to execute over
    # @param [Hash] options for the execution
    # @returns the execution return or nil
    #
    # @example
    #   session = Redbooth::Session.new(api_key: '_your_api_key_', auth_token: '_aut_token_for_the_user')
    #   client = Redbooth::Client.new(session)
    #   client.user.show # returns user profile
    #   client.files.all
    #
    RESOURCES.each do |resource|
      eval %{
        def #{resource.to_s}(action, options={})
          perform!(:#{resource.to_s}, action, options)
        end
      }
    end


    # Executes block with the access token
    #
    # @param [String||Symbol] resource_name name of the resource to execute over
    # @param [String||Symbol] action name of the action to execute over
    # @param [Hash] options for the execution
    # @returns the execution return or nil
    def perform!(resource_name, action, options = {})
      fail Redbooth::AuthenticationError unless session
      resource(resource_name).send(action, options_with_session(options))
    end
    protected :perform!

    # Merge the given options with the session for use the api
    #
    # @param [Hash] options options to merge with session
    # @return [Hash]
    def options_with_session(options={})
      options.merge(session: @session)
    end
    protected :options_with_session

    # Gest the api resource model class by his name
    #
    # @param [String||Symbol] name name of the resource
    # @return [Copy::Base] resource to use the api
    def resource(name)
      eval('Redbooth::' + name.to_s.capitalize) rescue nil
    end
    protected :resource

  end
end