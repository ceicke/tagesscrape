#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require 'open-uri'
require 'pry'

page_number = 1
page_size = 12
counter = 0
total_elements = 0

FileUtils.mkdir_p('./images')

def do_request(page_number = 1, page_size = 12)
  entry_url = 'https://api.ardmediathek.de/page-gateway/widgets/ard/asset/Y3JpZDovL2Rhc2Vyc3RlLmRlL3RhZ2Vzc2NoYXU'
  uri = URI.parse("#{entry_url}?pageNumber=#{page_number}&pageSize=#{page_size}")

  req = Net::HTTP::Get.new uri
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request req }

  if res.code == '200'
    JSON.parse(res.body)
  else
    p "HTTP error: #{res.code} on #{uri.to_s}"
  end
end

first_page = do_request()
total_elements = first_page['pagination']['totalElements']

while(counter < total_elements)
  begin
    current_page = do_request(page_number, page_size)

    current_page['teasers'].each do |teaser|
      if teaser['shortTitle'] == 'tagesschau, 20:00 Uhr'
        broadcasted_on = teaser['broadcastedOn']
        puts "#{counter} / #{total_elements}: #{broadcasted_on}"
        unless File.file?("./images/#{broadcasted_on}.png")
          image_url = "#{teaser['images']['aspect16x9']['src'].split('?').first}?w=668&f=&imwidth=668"

          download = URI.open(image_url)
          IO.copy_stream(download, "./images/#{broadcasted_on}.png")
        end
      end
    end
  rescue Exception => e
    puts e
  end

  counter += 1
  page_number += 1
end
