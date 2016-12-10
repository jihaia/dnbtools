class AccountBaseController < ApplicationController
  include AccountAccess
  include UserAccess
end
