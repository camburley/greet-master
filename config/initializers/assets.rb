# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += ["extras/*", "admin/*", "home/*"]
Rails.application.config.assets.precompile += %w(admin.css admin.js home/index.css home/index.js)
Rails.application.config.assets.precompile += %w(opensans pages-icon)
Rails.application.config.assets.precompile << /\.(?:png|jpg|jpeg|gif|mp4)\z/
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
