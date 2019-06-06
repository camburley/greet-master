class Webhook::IntercomController < ApplicationController
  protect_from_forgery with: :null_session
  layout false

  def callback
    messaging_event = JSON.parse(request.body.read)
    verify_callback(payload_body)

    push = JSON.parse(payload_body)
    puts "Topic Recieved: #{push['topic']}"
  end

  def verify_callback
    secret = "secret"
    expected = request.env['HTTP_X_HUB_SIGNATURE']
    if expected.nil? || expected.empty? then
      puts "Not signed. Not calculating"
    else
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_body)
      puts "Expected: #{expected}"
      puts "Calculated: #{signature}"
      if Rack::Utils.secure_compare(signature, expected) then
        puts "Match"
      else
        puts "MISMATCH!!!!!!!"
        return halt 500, "Signatures didn't match!"
      end
    end
  end
end
