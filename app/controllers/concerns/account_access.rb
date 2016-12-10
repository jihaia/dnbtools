module AccountAccess
  extend ActiveSupport::Concern

  included do
    before_action :identify_account
  end

  # Helper preceedes all processing of the action and determines the current
  # tenant (Account). All actions are related to a tenant.
  def identify_account

    # extract all subdomains from the request
    subdomains = request.subdomains.dup

    # identify target subdomain as the first in the list of subdomains
    target_subdomain = subdomains.shift
    protocol = request.protocol

    # locate the base domain for the current environment
    base_domain = ENV["DNBTOOLS_BASE_DOMAIN"]


    if request.domain == base_domain
      @current_account = Account.where(subdomain: target_subdomain).first
    elsif request.host.include?("localhost")
      @current_account = Account.default_account
    else
      @current_account = Account.where(custom_domain: request.host).first
    end

    if @current_account
      Account.current = @current_account
      Account.current_subdomains = request.subdomains
      Account.current_port = request.port
      Account.current_protocol = protocol
    else
      # We do not know where the request was intended for - redirect to safe URI
      redirect_to "http://www.dnb.com"
    end


  end # def identify_account

end # module
