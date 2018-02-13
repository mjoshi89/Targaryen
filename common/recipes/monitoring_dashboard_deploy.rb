#
# Cookbook Name:: common
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
common_app = search("aws_opsworks_app", "name:common").first
influxdb_admin_username = common_app[:environment][:DBUsername]
influxdb_admin_password = common_app[:environment][:DBPassword]
influxdb_username = common_app[:environment][:DBUsername]
influxdb_password = common_app[:environment][:DBPassword]
instance = search("aws_opsworks_instance", "self:true").first
pub_ip = instance[:public_ip]


docker_service 'default' do
  action [:create, :start]
end

docker_image 'influxdb' do
  tag "#{node['influxdb']['release_version']}"
  action :pull
end

docker_image 'grafana/grafana' do
  action :pull
end

create_dir("#{node['common']['install_path']}/influxdb/data",0777)

create_dir("#{node['common']['install_path']}/grafana",0777)

cookbook_file "#{node['common']['install_path']}/influxdb/influxdb.conf" do
    source "default/influxdb.conf"
    mode "0644"
    owner 'root'
    group 'root'
end

cookbook_file "#{node['common']['install_path']}/grafana/docker-metrics-per-container_rev2.json" do
    source "default/docker-metrics-per-container_rev2.json"
    mode "0644"
    owner 'root'
    group 'root'
end


docker_container "influxdb" do
  repo "influxdb"
  tag "#{node['influxdb']['release_version']}"
  volumes ["#{node['common']['install_path']}/influxdb/data:/var/lib/influxdb", "#{node['common']['install_path']}/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro" ]
  env ["INFLUXDB_ADMIN_PASSWORD=#{influxdb_admin_password}", "INFLUXDB_ADMIN_USER=#{influxdb_admin_username}", "INFLUXDB_USER_PASSWORD=#{influxdb_password}", "INFLUXDB_USER=#{influxdb_username}", "INFLUXDB_DB=telegraf", "INFLUXDB_ADMIN_ENABLED=true" ]
  port '8086:8086'
  restart_policy 'always'
  action :run
end

docker_container "grafana" do
  repo "grafana/grafana"
  port '3000:3000'
  restart_policy 'always'
  action :run
end

bash "Grafana init" do
    code <<-EOH
    curl --user admin:admin 'http://#{pub_ip}:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"telegraf","isDefault":true ,"type":"influxdb","url":"http://#{pub_ip}:8086","database":"telegraf","access":"proxy","basicAuth":false}'

    curl --user admin:admin 'http://#{pub_ip}:3000/api/dashboards/import' -X POST -H 'Content-Type: application/json' -d '@#{node['common']['install_path']}/grafana/docker-metrics-per-container_rev2.json'
    EOH
end
