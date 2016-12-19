class ApplicationController < ActionController::Base
  protect_from_forgery

  def hello
    puts "Hi"
  end
end
