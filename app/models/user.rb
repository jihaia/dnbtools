class User < ActiveRecord::Base

  devise :database_authenticatable, :rememberable, :trackable,
  :confirmable, :lockable, :timeoutable, :recoverable, :validatable,
  :registerable, request_keys: [:subdomain]

    ## IDENTIFIER (start) ======================================================
    self.primary_key = 'user_id'
    ## IDENTIFIER (end)

    ## ACCESSORS (start) =======================================================
    attr_accessor :subdomain
    ## ACCESSORS (end)

    ## DEFAULTS (start) ========================================================
    before_validation :set_defaults
    ## DEFAULTS (end)

    ## ASSOCIATIONS (start) ====================================================
    has_many :account_users, dependent: :destroy
    has_many :accounts, through: :account_users
    has_many :logins, dependent: :destroy
    ## ASSOCIATIONS (end)

    ## NESTED ATTRIBUTES (start) ===============================================
    ## NESTED ATTRIBUTES (end)

    ## VALIDATIONS (start) =====================================================
    validate :password_complexity
    validate :email_format

    def password_complexity
      if password.present? and not password.match(/(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[\W])/)
        errors.add :password, "must be 8-20 characters long and include 3 of the following: uppercase letters, lowercase letters, numbers and special characters (!, @, #, $, etc.)."
      end
    end

    def email_format
      unless email.include?('@') && email.include?('.')
        errors.add :email, "not a valid email address"
      end
    end
    ## VALIDATIONS (end)

    ## HOOKS (start) =====================================================
    ## HOOKS (end)

    ## SCOPES (start) =====================================================
    ## SCOPES (end)

    def full_name
      "#{first_name} #{last_name}"
    end


    def self.search(criteria, page = 1)
      # TODO
    end

    # Method performs a quick authentication of the user credentials without undergoing
    # the process of actually logging in. The email address and password in plain text
    # are provided. The email and password are required while the password_confirmation
    # is optional. If the password_confirmation is provided then the system will determine
    # if they match each other. If so then it will determine if the User exists for the
    # email and the password is valid.
    def self.is_authentic?(email, password, password_confirmation=nil)
      is_valid = true

      is_valid = (password == password_confirmation) unless password_confirmation.nil?

      if is_valid
        user = User.where(email: email).first
        if !(user && user.valid_password?(password))
          is_valid = false
        end
      end

      is_valid
    end # def is_authentic?


    private

    # Override determines if the user is permitted for the current subdomain
    def self.find_for_authentication(warden_conditions)
      subdomain = warden_conditions[:subdomain].split('.').first
      joins(:accounts).where(email: warden_conditions[:email]).where(accounts: {subdomain: subdomain}).first
    end

    # Helper sets all defaults on the current model prior to VALIDATIONS
    def set_defaults
      self.state ||= 'NEW'
      self.user_id ||= DnbTools::Util::Uuid.generate
    end # def set_defaults


    def passwords_provided
      if self.password.blank? || self.password_confirmation.blank?
        self.errors.add(:password, "password cannot be blank")
      end
    end

    def passwords_match
      unless self.password.blank?
        self.errors.add(:password_confirmation, "passwords do not match") if self.password != self.password_confirmation
      end
    end # def passwords_match


end # class User
