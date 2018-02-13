#
# Cookbook Name:: common
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
common_app = search("aws_opsworks_app", "name:common").first
mysql_root_pass = common_app[:environment][:DBPassword]
mysql_username = common_app[:environment][:DBUsername]
mysql_password = common_app[:environment][:DBPassword]


docker_service 'default' do
  action [:create, :start]
end

docker_image 'wordpress:php7.2-apache' do
  action :pull
end

docker_image 'mysql:5.7' do
  action :pull
end

create_dir("/opt/mysql/datadir",0777)
create_dir("/opt/wordpress/wp-content",0777)

docker_container "mysql-wordpress" do
  repo "mysql"
  tag "5.7"
  volumes ["/opt/mysql/datadir:/var/lib/mysql" ]
  env ["MYSQL_ROOT_PASSWORD=#{mysql_root_pass}", "MYSQL_DATABASE=wordpress", "MYSQL_USER=#{mysql_username}", "MYSQL_PASSWORD=#{mysql_password}" ]
  restart_policy 'always'
  action :run
end

docker_container "wordpress-app" do
  repo "wordpress"
  tag "php7.2-apache"
  volumes ["/opt/wordpress/wordpress-app/wp-content:/var/www/html/wp-content" ]
  env ["WORDPRESS_DB_USER=#{mysql_username}", "WORDPRESS_DB_PASSWORD=#{mysql_password}" ]
  links ['mysql-wordpress:mysql']
  port '8080:80'
  restart_policy 'always'
  action :run
end
