#!/usr/bin/env ruby

# From tutorial here :
# https://developers.google.com/drive/v3/web/quickstart/ruby#step_3_set_up_the_sample

# gem install google-api-client
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'
require 'colorize'  # gem install colorize

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Drive API Ruby Quickstart'
# To download the credentials needed in 'client_secret.json':
# 1. Go here: https://console.developers.google.com/apis/credentials :
# 2. Select "OAuth 2.0 client IDs" and not "Service account keys"
# 3. Select "Other" for the type of application
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "drive-ruby-quickstart.yaml")
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
$service = Google::Apis::DriveV3::DriveService.new
$service.client_options.application_name = APPLICATION_NAME
$service.authorization = authorize


# Convert file id to URL
def file_id_to_url file_id
  "https://drive.google.com/uc?export=view&id=#{file_id}"
end


# First, we get the root directory of the pictures we want
root = $service.get_file("0B2WPhuS14TrdMjFsV1lMSG85dnM")  # id of "portfolio" folder
# puts "#{root.name} (#{root.id})"

# clear summary
File.open("_includes/summary.html", "w").close

# A function to get the number of pictures in a folder
def pictures_number folder
  counter = 0
  response = $service.list_files(q: "'#{folder.id}' in parents")
  response.files.each do |file|
    counter += 1 if file.name.include? "."  # picture
  end
  return counter
end

# The routes to register in AngularJS
$routes = []

# Then, we list all files in that folder,
# and for each picture, we get url and picture size (needed by PhotoSwipe.js)
def analyse_folder folder, filename, level
  puts "[+] analysing folder #{folder.name} (content/#{filename}.html)".green

  response = $service.list_files(q: "'#{folder.id}' in parents")
  puts '[-] no files found'.yellow if response.files.empty?

  subfolders = []
  pictures = []

  response.files.each do |file|
    # could not find a proper way to check if file is folder or regular file
    # so I check if there is a "." in filename
    if file.name.include? "."  # picture
      puts "[+] found #{file.name}"
      pictures << file
    else  # folder
      subfolders << file
    end
  end

  if pictures.size > 0
    $routes << folder.name.downcase
    File.open "content/#{folder.name.downcase}.html", "w" do |f_out|
      f_out.write "<h1>#{folder.name}</h1>\n\n"
      f_out.write "<div id='columns' class='ps-gallery'>\n"

      for file in pictures
        metadata = $service.get_file(file.id, fields: "image_media_metadata").image_media_metadata
        filename = file.name.split(".")[0]  # remove extension

        f_out.write "  <figure>\n"
        f_out.write "    <img src='#{file_id_to_url(file.id)}' data-size='#{metadata.width},#{metadata.height}'>\n"
        f_out.write "    <figcaption>#{filename}</figcaption>\n" if not filename.start_with?("DSC")
        f_out.write "  </figure>\n"
      end

      f_out.write "</div><!-- end #columns -->\n"
    end
  end

  subfolders.each_with_index do |folder, index|
    File.open "_includes/summary.html", "a" do |f_out|
      f_out.write "    "*(level*2-1) + "<ul>\n" if level > 0 && index == 0
      f_out.write "    "*level*2 + "<li>\n"
      if pictures_number(folder) > 0
        f_out.write "    "*(level*2+1) + "<a href='#/#{folder.name.downcase}'>#{folder.name}</a>\n"
      else
        f_out.write "    "*(level*2+1) + "<div>#{folder.name}</div>\n"
      end
    end

    analyse_folder folder, folder.name.gsub(" ", "_").downcase, level+1

    File.open "_includes/summary.html", "a" do |f_out|
      f_out.write "    "*level*2 + "</li>\n"
      f_out.write "    "*(level*2-1) + "</ul>\n" if level > 0 && index == subfolders.size-1
    end
  end
end


analyse_folder root, "", 0


# we generate the AngularJS routing code
File.open "js/routes.js", "w" do |f_out|
  f_out.write "angular.module('portfolioApp').config(['$routeProvider',\n"
  f_out.write "  function($routeProvider) {\n"
  f_out.write "    $routeProvider.\n"
  
  routes_code = []  
  for route in $routes
    s  = "      when('/#{route}', {\n"
    s += "        templateUrl: 'content/#{route}.html'\n"
    s += "      })"
    routes_code << s
  end

  f_out.write routes_code.join ".\n"

  f_out.write ";\n"
  f_out.write "  }\n"
  f_out.write "]);\n"
end


