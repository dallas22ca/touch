Pusher.url = "http://#{CONFIG["pusher_key"]}:#{CONFIG["pusher_secret"]}@api.pusherapp.com/apps/#{CONFIG["pusher_app_id"]}"
Pusher.logger = Rails.logger