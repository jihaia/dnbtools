module AdminAccess
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  def authenticate
    authenticate_admin!
  end

end
