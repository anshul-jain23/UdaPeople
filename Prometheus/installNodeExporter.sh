sudo useradd --no-create-home node_exporter
pid=$!
wait $pid
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
pid=$!
wait $pid
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
pid=$!
wait $pid
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
pid=$!
wait $pid
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64
pid=$!
wait $pid
sudo chmod o+w /etc/systemd/system/
pid=$!
wait $pid
echo "Installation complete"