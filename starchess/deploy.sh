rsync -av --force --delete --progress --exclude-from=rsync_exclude.txt . eli@159.223.172.166:/home/eli/starchess/starchess/
# RAILS_ENV=production bundle exec rake assets:precompile
# fix env vars
# sudo service unicorn_starchess restart
