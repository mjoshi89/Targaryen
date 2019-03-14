ruby_block 'chaos_deployment' do
  block do
    def deploy(n)
      while n >= 1

        docker_container "wordpress-app" do
          action :stop
        end

        sleep n

        docker_container "wordpress-app" do
          action :start
        end
        n = n-1
      end
    end
    n = rand(1..12)
    deploy(n)
  end
end
