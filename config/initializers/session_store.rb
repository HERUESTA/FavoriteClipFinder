Rails.application.config.session_store :cookie_store, key: "_favorite_clip_finder_session", same_site: :lax, secure: Rails.env.production?
