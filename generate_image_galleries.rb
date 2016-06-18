#!/usr/bin/env ruby

# From tutorial here :
# https://developers.google.com/drive/v3/web/quickstart/ruby#step_3_set_up_the_sample

# gem install google-api-client
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Drive API Ruby Quickstart'
# To download here: https://console.developers.google.com/apis/credentials :
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
service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize


# Convert file id to URL
def file_id_to_url file_id
  "https://drive.google.com/uc?export=view&id=#{file_id}"
end


# First, we get the root directory of the pictures we want
file = service.get_file("0B31-CIvNW1LdQjdTcnRNY0pmSXM")  # id of "portfolio" folder
puts "#{file.name} (#{file.id})"

# Then, we list all files in that folder,
# and for each picture, we get url and picture size (needed by PhotoSwipe.js)
response = service.list_files(q: "'0B31-CIvNW1LdQjdTcnRNY0pmSXM' in parents")
puts 'No files found' if response.files.empty?
response.files.each do |file|
  # could not find a proper way to check if file is folder or regular file
  # so I check if there is a "." in filename
  if file.name.include? "."  # picture
    metadata = service.get_file(file.id, fields: "image_media_metadata").image_media_metadata

    filename = file.name.split(".")[0]  # remove extension

    puts "<figure>"
    puts "  <img src='#{file_id_to_url(file.id)}' data-size='#{metadata.width},#{metadata.height}'>"
    puts "  <figcaption>#{filename}</figcaption>"
    puts "</figure>"
  else  # folder
    puts "Folder: #{file.name} (#{file.id})"
  end
end

