SERVER="34.199.232.199"
scp -i ./.ssh/Udacity_keyPair.pem ./Prometheus/install.sh ubuntu@$SERVER:/home/ubuntu
scp -i ./.ssh/Udacity_keyPair.pem ./Prometheus/restart.sh ubuntu@$SERVER:/home/ubuntu
ssh -i ./.ssh/Udacity_keyPair.pem ubuntu@$SERVER
scp -i ./.ssh/Udacity_keyPair.pem ./Prometheus/prometheus.yml ubuntu@$SERVER:/etc/prometheus/
scp -i ./.ssh/Udacity_keyPair.pem ./Prometheus/prometheus.service ubuntu@$SERVER:/etc/systemd/system/
ssh -i ./.ssh/Udacity_keyPair.pem ubuntu@$SERVER