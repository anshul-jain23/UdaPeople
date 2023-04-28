sudo useradd --no-create-home prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
pid=$!
wait $pid
tar xvfz prometheus-2.19.0.linux-amd64.tar.gz
pid=$!
wait $pid
sudo cp prometheus-2.19.0.linux-amd64/prometheus /usr/local/bin
pid=$!
wait $pid
sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
pid=$!
wait $pid
sudo cp -r prometheus-2.19.0.linux-amd64/consoles /etc/prometheus
pid=$!
wait $pid
sudo cp -r prometheus-2.19.0.linux-amd64/console_libraries /etc/prometheus
pid=$!
wait $pid
sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-2.19.0.linux-amd64.tar.gz prometheus-2.19.0.linux-amd64
pid=$!
wait $pid
sudo chmod o+w /etc/prometheus
sudo chmod o+w /etc/systemd/system/
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus
pid=$!
wait $pid
echo "exit and copy prometheus files"