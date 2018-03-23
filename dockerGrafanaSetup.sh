#update
sudo yum update

#install node
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 9.3
node -e "console.log('Running Node.js ' + process.version)"

#install artillery
npm install -g artillery

#update and install docker
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

#create docker network
docker network create statsdnetwork

#allow network forwarding
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT

#create statsd volumes
mkdir -p ~/statsd/opt/statsd
#create graphite volume
mkdir -p ~/graphite/opt/graphite/conf
mkdir -p ~/graphite/opt/graphite/storage
#create grafana volume
mkdir -p ~/grafana/var/lib/grafana

#start statsd, graphite and grafana
#see documentation: https://github.com/hopsoft/docker-graphite-statsd
docker run -d --name graphite --restart=always --network statsdnetwork -p 80:80 -p 2003-2004:2003-2004 -p 2023-2024:2023-2024 -p 8125:8125/udp -p 8126:8126 -v ~/graphite/opt/graphite/conf:/opt/graphite/conf -v ~/graphite/opt/graphite/storage:/opt/graphite/storage -v ~/statsd/opt/statsd:/opt/statsd graphiteapp/graphite-statsd
docker run -d -p 3000:3000 --network statsdnetwork --name grafana -e"GF_SECURITY_ADMIN_PASSWORD=password" -v ~/grafana/var/lib/grafana:/var/lib/grafana grafana/grafana

#verify setup
docker ps -a
echo "grafana login: admin, password.  set data source to http://graphite"