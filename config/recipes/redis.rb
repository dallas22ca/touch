namespace :redis do

  desc "Install redis"
  task :install do
    ["wget http://download.redis.io/redis-stable.tar.gz",
      "tar xvzf redis-stable.tar.gz",
      "make -C redis-stable/src all",
      "#{sudo} cp redis-stable/src/redis-benchmark /usr/local/bin/",
      "#{sudo} cp redis-stable/src/redis-cli /usr/local/bin/",
      "#{sudo} cp redis-stable/src/redis-server /usr/local/bin/",
      "#{sudo} mkdir -p /etc/redis",
      "#{sudo} mkdir -p /var/redis/6379",
      "#{sudo} cp redis-stable/utils/redis_init_script /etc/init.d/redis_6379",
      "#{sudo} cp redis-stable/redis.conf /etc/redis/6379.conf",
      "#{sudo} sed -i 's/daemonize no/daemonize yes/' /etc/redis/6379.conf",
      "#{sudo} sed -i 's/loglevel verbose/loglevel notice/' /etc/redis/6379.conf",
      "#{sudo} sed -i 's/\\.\\//\\/var\\/redis\\/6379/' /etc/redis/6379.conf",
      "#{sudo} sed -i 's/\\/var\\/run\\/redis.pid/\\/var\\/run\\/redis_6379.pid/' /etc/redis/6379.conf",
      "#{sudo} update-rc.d redis_6379 defaults",
      "cd",
      "rm -rf redis-stable",
      "rm redis-stable.tar.gz"].each {|cmd| run cmd}
  end
  after "deploy:install", "redis:install"
  
  desc "Start the Redis server"
  task :start do
    run "redis-server /etc/redis/6379.conf"
  end
  after "deploy", "redis:start"
  
  desc "Stop the Redis server"
  task :stop do
    run 'echo "SHUTDOWN" | nc localhost 6379'
  end

end