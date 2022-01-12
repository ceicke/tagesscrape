#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'dotenv'
require 'pry'

Dotenv.load

Dir['./images/2022-01-*'].each do |file|
  p file
  client = Aws::Rekognition::Client.new
  resp = client.detect_faces(
    image: { bytes: File.read(file) }
  )
  p resp['face_details']
  # resp.labels.each do |label|
  #   puts "#{label.name}-#{label.confidence.to_i}"
  # end
end
