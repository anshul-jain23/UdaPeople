start=`date +%s.%N`
echo $start
echo "Deleting stack if already present"
aws cloudformation delete-stack --stack-name udaPeople-Prometheus
aws cloudformation wait stack-delete-complete --stack-name udaPeople-Prometheus
echo "create new stack"
aws cloudformation deploy --stack-name udaPeople-Prometheus --template-file ./cdond-c3-projectstarter/Prometheus/setup.yml
aws cloudformation wait stack-create-complete --stack-name udaPeople-Prometheus
SERVER=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-Server" --output text)
ExporterSERVER=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-node-exporter" --output text)

echo "prometheus-server : $SERVER "
echo " Prometheus  node-exporter: $ExporterSERVER"

echo "copying installPrometheus.sh to $SERVER"
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/installPrometheus.sh ubuntu@$SERVER:/home/ubuntu

echo "copying startPrometheus.sh to $SERVER"
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/startPrometheus.sh ubuntu@$SERVER:/home/ubuntu

echo "Changing file permissions"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/installPrometheus.sh'
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/startPrometheus.sh'

echo "Running installPrometheus.sh"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER /home/ubuntu/installPrometheus.sh
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/prometheus.yml ubuntu@$SERVER:/etc/prometheus/
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/prometheus.service ubuntu@$SERVER:/etc/systemd/system/

echo "Setting up Node exporter server now..."
echo "copying installNodeExporter.sh to $ExporterSERVER"
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/installNodeExporter.sh ubuntu@$ExporterSERVER:/home/ubuntu

echo "Changing file permissions"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$ExporterSERVER 'sudo chmod +x /home/ubuntu/installNodeExporter.sh'

echo "Running installNodeExporter.sh"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$ExporterSERVER /home/ubuntu/installNodeExporter.sh

echo "copying node-exporter service"
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/node-exporter.service ubuntu@$ExporterSERVER:/etc/systemd/system/

echo "copying StartNodeExporter.sh to $ExporterSERVER"
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/StartNodeExporter.sh ubuntu@$ExporterSERVER:/home/ubuntu
echo "Changing file permissions"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$ExporterSERVER "sudo chmod +x /home/ubuntu/StartNodeExporter.sh"
echo "Running StartNodeExporter.sh"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$ExporterSERVER /home/ubuntu/StartNodeExporter.sh

Prometheus_node_exporter=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicDnsName' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-node-exporter" --output text)

echo "editing /etc/prometheus/prometheus.yml file"
echo "cat /etc/prometheus/prometheus.yml|sed -e 's/prometheus-server:9100/$Prometheus_node_exporter:9100/g'"

ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER "cat /etc/prometheus/prometheus.yml|sed -e 's/prometheus-server:9100/$Prometheus_node_exporter:9100/g'"

echo "Starting Prometheus service"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER  /home/ubuntu/startPrometheus.sh

echo "fetching prometheus server dns name"
Prometheus_Server=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicDnsName' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-Server" --output text)
echo "$Prometheus_Server:9090"

end=`date +%s.%N`
echo $end
echo "$end - $start"