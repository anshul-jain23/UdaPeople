wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz
pid=$!
wait $pid
tar xvfz alertmanager-0.21.0.linux-amd64.tar.gz
pid=$!
wait $pid
sudo cp alertmanager-0.21.0.linux-amd64/alertmanager /usr/local/bin
pid=$!
wait $pid
sudo cp alertmanager-0.21.0.linux-amd64/amtool /usr/local/bin/
pid=$!
wait $pid
sudo mkdir /var/lib/alertmanager
pid=$!
wait $pid
rm -rf alertmanager*
pid=$!
wait $pid
sudo chmod o+w /etc/systemd/system
echo "Install AlertManager complete!!"