#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/config_file'
require 'json'
require 'rest_client'
require 'base64'

enable :sessions

config_file 'config.yml'

set :port, settings.port

get '/' do
  display_images
end

post '/mmslistener' do
  mms_listener
end

get '/getImageData' do
  get_image_data
end

def display_images
  response = RestClient.get  settings.images_url + '/getImageData'
  json = JSON.parse response

  @images_total = json['totalNumberOfImagesSent']
  @images_list = json['imageList']

  erb :mms3
end

def mms_listener
  input   = request.env["rack.input"].read
  address = /\<SenderAddress\>tel:([0-9\+]+)<\/SenderAddress>/.match(input)[1]
  parts   = input.split "--Nokia-mm-messageHandler-BoUnDaRy"
  body    = parts[2].split "BASE64"
  type    = /Content\-Type: image\/([^;]+)/.match(body[0])[1];
  date    = Time.now

  random  = rand(10000000).to_s

  File.open("#{settings.momms_image_dir}/#{random}.#{type}", 'w') { |f| f.puts Base64.decode64 body[1] }

  # TODO: tokenizer stuff

  text = parts.length > 4 ? Base64.decode64(parts[3].split("BASE64")[1]).strip : ""
  File.open("#{settings.momms_data_dir}/#{random}.#{type}.txt", 'w') { |f| f.puts address, date, text } 
end

def get_image_data
  content_type :json
  images = []

  Dir.glob(settings.momms_image_dir+"/*").each do |entry|
    if File.file? entry
      data = entry.sub(settings.momms_image_dir, settings.momms_data_dir)+".txt";
      if File.exists? data
        File.open(data, "r") { |f| images.push( {:path => entry.sub('public/',''), :senderAddress => f.gets.strip, :date => f.gets.strip, :text => f.gets.strip} ) }
      end
    end
  end
  { :totalNumberOfImagesSent => images.length, :imageList => images }.to_json
end


get '/test' do
  RestClient.post settings.listener_url, '--MIMEBoundary_08b1d81c790c90ac553e8984a9e404cebce0f820564bd221
Content-Transfer-Encoding: 8bit
Content-ID: <rootpart@beta-api.att.com>
Content-Type: text/xml; charset=UTF-8

<inbound-MMS-message>
<sender-address>tel:+18588228604</sender-address><priority>Normal</priority><subject></subject>
</inbound-MMS-message>
--MIMEBoundary_08b1d81c790c90ac553e8984a9e404cebce0f820564bd221
Content-Type: multipart/related; Type="application/smil"; Start=0.smil; boundary="Nokia-mm-messageHandler-BoUnDaRy-=_-1130087643"
Content-Transfer-Encoding: binary
Content-ID: <#1Attachment>


--Nokia-mm-messageHandler-BoUnDaRy-=_-1130087643
Content-Type: application/smil
Content-ID: 0.smil
Content-Transfer-Encoding: BASE64

PHNtaWw+CjxoZWFkPgo8bGF5b3V0PgogPHJvb3QtbGF5b3V0Lz4KPHJlZ2lvbiBpZD0iVGV4dCIg
dG9wPSI3MCUiIGxlZnQ9IjAlIiBoZWlnaHQ9IjMwJSIgd2lkdGg9IjEwMCUiIGZpdD0ic2Nyb2xs
Ii8+CjxyZWdpb24gaWQ9IkltYWdlIiB0b3A9IjAlIiBsZWZ0PSIwJSIgaGVpZ2h0PSI3MCUiIHdp
ZHRoPSIxMDAlIiBmaXQ9Im1lZXQiLz4KPC9sYXlvdXQ+CjwvaGVhZD4KPGJvZHk+CjxwYXIgZHVy
PSIxMHMiPgo8aW1nIHNyYz0iSU1HXzc3NTEuanBnIiByZWdpb249IkltYWdlIi8+CjwvcGFyPgo8
L2JvZHk+Cjwvc21pbD4K

--Nokia-mm-messageHandler-BoUnDaRy-=_-1130087643
Content-Type: image/jpeg; Name=IMG_7751.jpg
Content-Disposition: Attachment; Filename=IMG_7751.jpg
Content-ID: 1
Content-Location: IMG_7751.jpg
Content-Transfer-Encoding: BASE64

/9j/4R9fRXhpZgAATU0AKgAAAAgADgEAAAMAAAABA+wAAAEBAAMAAAABAooAAAECAAMAAAADAAAA
tgEGAAMAAAABAAIAAAESAAMAAAABAAEAAAEVAAMAAAABAAMAAAEaAAUAAAABAAAAvAEbAAUAAAAB
AAAAxAEoAAMAAAABAAIAAAExAAIAAAAcAAAAzAEyAAIAAAAUAAAA6AITAAMAAAABAAEAAIdpAAQA
AAABAAAJCOocAAcAAAgMAAAA/AAAEdIACAAIAAgAAABIAAAAAQAAAEgAAAABQWRvYmUgUGhvdG9z
aG9wIENTNSBXaW5kb3dzADIwMTA6MDc6MTMgMTI6MTc6MzgAHOoAAAAIAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADJAAAAcAAAAEMDIy
MZADAAIAAAAUAAAJnpAEAAIAAAAUAAAJspEBAAcAAAAEAQIDAJKRAAIAAAADMDAAAJKSAAIAAAAD
MDAAAKAAAAcAAAAEMDEwMKABAAMAAAAB//8AAKACAAQAAAABAAADXqADAAQAAAABAAABQ6QGAAMA
AAABAAAAAOocAAcAAAgMAAAJxgAAAAAyMDEwOjA1OjE0IDAwOjM0OjQxADIwMTA6MDU6MTQgMDA6
MzQ6NDEAHOoAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAABgEDAAMAAAABAAYAAAEaAAUAAAABAAASIAEbAAUAAAABAAASKAEoAAMA
AAABAAIAAAIBAAQAAAABAAASMAICAAQAAAABAAANJQAAAAAAAABIAAAAAQAAAEgAAAAB/9j/2wBD
AAIBAQIBAQICAQICAgICAwUDAwMDAwYEBAMFBwYHBwcGBgYHCAsJBwgKCAYGCQ0JCgsLDAwMBwkN
Dg0MDgsMDAv/2wBDAQICAgMCAwUDAwULCAYICwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsL
CwsLCwsLCwsLCwsLCwsLCwsLCwv/wAARCAA8AKADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAA
AAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKB
kaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZn
aGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT
1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcI
CQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAV
YnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6
goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk
5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9/KKKKACikLYGTXAfE39qXwD8IfGujeGfHfib
TrXxP4icx6Zo6MZb++YKWOyFAWxtVjuIA461M5xgrydkbUMPVxMuSjBye9kr6Ld6dup6BRX56z/8
HM37Ndtr72VxL45SOOQxvcNoThFIODld2/8A8dr6q/ZZ/b3+Ef7aGmS3H7OPjbSfEM1uu6eyDGC9
tx6vbyBXA98Y965aOYYbES5adRN9rnu5lwjneT0ViMbg6kKf8zi7fN7L5nsFFJupQc12HzgUUUUA
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
AAAAAAAAAQIDBAUGBwgJCgv/xAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEU
MoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2Rl
ZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK
0tPU1dbX2Nna4eLj5OXm5+jp6vHy8/T19vf4+fr/xAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUG
BwgJCgv/xAC1EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS
8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4
eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri
4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP7+KKKKACiiigAooooAKKKKACiiigAooooA
KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAr5Z/bB/bI+BP7Dnwb1j42fHzxSuheHbKT
7PoWi2SCbVdb1JlJjsrC3yDLMwUk8hUUFnZVBNfU1f5tv/BwP+1h41/aH/4KE/FD4dahqV0nw4/Z
pvz4S8B+G1m/0eO6iRG1S8ZMAGaa5LqWOT5cMS5wK+Q424mfC2TOtBXqSfLFPa+ru/JJfN2R/R30
XvAyPj14lxyyvUdPB0YOrWlH4nBSjFQhfRSnKSV38MeaVm0k/wBpP2Lf+CxX7TH/AAUw/wCCj/gD
4GyzR/sz/s16t4T8VappXgXwztbxBr0MGm3QszdatLHvZgzrPttREmbY8vtyf5uP24tI/bv/AGN/
2lvHvwb+NPx0/aCl8R+Hdbnm8LeNL/4p6u0Wu6Q8hNpqVpO0/wAySJtJ28o4ZDhlIr9fP+CcH7IV
t/wUR/ZF+DfxJ/Zj+Mel/s+f8FEP+Cfniu50nSvEstsRa6z4fuLyfUNHe/Eas4Cm6v7dZgkisqSx
SI6Fdv8AReP2TviB/wAFDfgpP8Gf+CsP7Jvwz0Pxj4MtY/8AhGPjb8GPifDdG8vMBZLvSsILrTWb
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

--Nokia-mm-messageHandler-BoUnDaRy-=_-1130087643--
Content-Transfer-Encoding: BASE64

--MIMEBoundary_08b1d81c790c90ac553e8984a9e404cebce0f820564bd221--
'

redirect '/'
end
