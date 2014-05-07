# namespace :assets do
#   task :precompile, :roles => :web, :except => { :no_release => true } do
#     # Check if assets have changed. If not, don't run the precompile task - it takes a long time.
#     force_compile = false
#     changed_asset_count = 0
#     begin
#       from = source.next_revision(current_revision)
#       asset_locations = 'app/assets/ lib/assets vendor/assets'
#       changed_asset_count = capture("cd #{latest_release} && #{source.local.log(from)} #{asset_locations} | wc -l").to_i
#     rescue Exception => e
#       logger.info "Error: #{e}, forcing precompile"
#       force_compile = false
#     end
#     if changed_asset_count > 0 || force_compile
#       logger.info "#{changed_asset_count} assets have changed. Pre-compiling"
#       run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
#     else
#       logger.info "#{changed_asset_count} assets have changed. Skipping asset pre-compilation"
#     end
#   end
# end