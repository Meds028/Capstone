class ApplicationController < ActionController::Base
    protect_from_forgery
    include SessionHelper
    helper :all
end
