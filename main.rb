require 'sinatra'
# require 'sinatra/reloader'
require 'pg'
require 'pry'
require 'omniauth'
require 'bcrypt'

require_relative 'db_config'
require_relative 'models/ride'
require_relative 'models/user'

enable :sessions

# HELPERS ///////////////////

helpers do

  def logged_in?

    if User.find_by(id: session[:user_id])
      return true
    else
      return false
    end
  end

  def current_user
    User.find(session[:user_id])
  end

end

get '/' do
  @rides = Ride.all
  erb :index
end

# LOGIN / SESSION ///////////////////

get '/login' do
  erb :user_login
end

post '/login' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect to '/'
  else
    erb :user_login
  end
end

delete '/login' do
  session[:user_id] = nil
  redirect to '/'
end

# SIGNUP ///////////////////

get '/signup' do
  erb :user_signup_stageone
end

post '/signup' do
  user = User.new
  user.email = params[:email]
  user.password = params[:password]
  user.save

  user = User.find_by(email: params[:email])
  session[:user_id] = user.id

  erb :user_signup_stagetwo
end

post '/signup/profile' do
  user_profile = User.find_by(id: session[:user_id])
  user_profile.first_name = params[:first_name]
  user_profile.last_name = params[:last_name]
  user_profile.dob = params[:dob]
  user_profile.driver = params[:driver]
  user_profile.save
  if params[:driver] == "true"
    erb :user_signup_driver
  else
    redirect to '/'
  end
end

# SIGNUP DRIVER ///////////////////

get '/signup/driver' do
  erb :user_signup_drivers
end

post '/signup/driver' do
  user_driver = User.find_by(id: session[:user_id])
  user_driver.drivers_license = params[:drivers_license]
  user_driver.location = params[:location]
  user_driver.car_brand = params[:car_brand]
  user_driver.car_model = params[:car_model]
  user_driver.car_year = params[:car_year]
  user_driver.car_colour = params[:car_colour]
  user_driver.car_plate = params[:car_plate]
  user_driver.save
  redirect to '/'
end

# VIEW / EDIT USER ///////////////////

get '/profile' do
  @user_profile = User.find_by(id: session[:user_id])
  erb :user_profile
end

get '/profile/edit' do
  @user_edit = User.find_by(id: session[:user_id])
  erb :user_profile_edit
end

put '/profile/edit' do
  user_update = User.find_by(id: session[:user_id])
  user_update.email = params[:email]
  user_update.password = params[:password]
  user_update.first_name = params[:first_name]
  user_update.last_name = params[:last_name]
  user_update.dob = params[:dob]
  user_update.drivers_license = params[:drivers_license]
  user_update.location = params[:location]
  user_update.car_brand = params[:car_brand]
  user_update.car_model = params[:car_model]
  user_update.car_year = params[:car_year]
  user_update.car_colour = params[:car_colour]
  user_update.car_plate = params[:car_plate]
  user_update.save
  redirect to '/profile'
end

delete '/profile/edit' do
  user_delete = User.find_by(id: session[:user_id])
  user_delete.destroy
  redirect to '/'
end


# HANDLE RIDES

get '/ride/create' do
  if !logged_in?
    redirect to '/'
  end
  erb :ride_create
end

post '/ride/create' do
  ride = Ride.new
  ride.origin = params[:origin]
  ride.destination = params[:destination]
  ride.when_date = params[:when_date]
  ride.when_time = params[:when_time]
  ride.price_ask = params[:price]
  ride.creator_id = session[:user_id]
  ride.save
  redirect to '/'
end

get '/ride/:id' do
  @ride = Ride.find_by(id: params[:id])
  @ride_requester = User.find_by(id: @ride['creator_id'])
  erb :ride_view
end

# DRIVER DASHBOARD

get '/driver_dashboard' do
  @user_profile = User.find_by(id: session[:user_id])
  erb :user_driver_dashboard
end

get '/ride/:id/edit' do
  @ride = Ride.find_by(id: params[:id])
  @ride_requester = User.find_by(id: @ride['creator_id'])
  erb :ride_edit
end

put '/ride/:id/edit' do
  ride_edit = Ride.find_by(id: params[:id])
  ride_edit.origin = params[:origin]
  ride_edit.destination = params[:destination]
  ride_edit.when_date = params[:when]
  ride_edit.when_time = params[:time]
  ride_edit.price_ask = params[:price]
  ride_edit.save
  redirect to "/ride/#{ params[:id] }"
end

delete '/ride/:id/edit' do
  ride_delete = Ride.find_by(id: params[:id])
  ride_delete.destroy
  redirect to '/'
end
