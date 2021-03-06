class HerokuConfigVars::ApplicationController < ApplicationController

  before_filter :recommend_https, :if => :insecure?
  before_filter :require_authenticated

  layout 'heroku_config_vars/application'

  AUTH_METHOD = :heroku_config_authorized?

  def env
    @env = ENV
  end

  private

    def require_authenticated
      # This is where we shell out to ApplicationController
      # raising RoutingError will render 404 in production
      if not respond_to? AUTH_METHOD
        raise ActionController::RoutingError.new <<-ERROR.strip_heredoc
          `#{AUTH_METHOD}` must be implemented in ApplicationController and return true for authorized users.

          e.g.
          class ApplicationController < ActionController::Base
            ...
            
            def #{AUTH_METHOD}
              current_user.admin?
            end
            
            ...
          end
        ERROR
      elsif not send AUTH_METHOD
        raise ActionController::RoutingError.new ":#{AUTH_METHOD} returned false"
      end
    end


    def recommend_https
      render :recommend_https
    end

    def insecure?
      not request.ssl? and (session[:insecure] ||= params[:insecure]) != 'ok'
    end

end