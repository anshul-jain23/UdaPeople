start=`date +%s.%N`

AK="AKIA5RFDYNGU63YA7Q3E"
SK="dgUNIxX4r5+4N6PfXfegBtRgU+dD4mAHl6gKD4Fs"
cmnd="-i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no"
# echo $cmnd

echo $start

echo "Deleting stack if already present"
aws cloudformation delete-stack --stack-name udaPeople-Prometheus
aws cloudformation wait stack-delete-complete --stack-name udaPeople-Prometheus

echo "create new stack"
aws cloudformation deploy --stack-name udaPeople-Prometheus --template-file ./cdond-c3-projectstarter/Prometheus/setup.yml
aws cloudformation wait stack-create-complete --stack-name udaPeople-Prometheus
SERVER=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-Server" --output text)
ExporterSERVER=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-node-exporter" --output text)

#Prometheus-server
echo "copying installPrometheus.sh & startPrometheus.sh to $SERVER"
scp $cmnd ./Prometheus/installPrometheus.sh ubuntu@$SERVER:/home/ubuntu
scp $cmnd ./Prometheus/startPrometheus.sh ubuntu@$SERVER:/home/ubuntu

echo "Changing file permissions"
ssh $cmnd ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/installPrometheus.sh'
ssh $cmnd ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/startPrometheus.sh'

echo "Running installPrometheus.sh"
ssh $cmnd ubuntu@$SERVER /home/ubuntu/installPrometheus.sh

echo "copying Prometheus service files"
scp $cmnd ./Prometheus/prometheus.yml ubuntu@$SERVER:/etc/prometheus/
scp $cmnd ./Prometheus/prometheus.service ubuntu@$SERVER:/etc/systemd/system/

#start Prometheus
echo "Starting Prometheus service"
ssh $cmnd ubuntu@$SERVER  /home/ubuntu/startPrometheus.sh

#Setup Node-exporter
echo "copying installNodeExporter.sh & StartNodeExporter.sh to $ExporterSERVER"
scp $cmnd ./Prometheus/installNodeExporter.sh ubuntu@$ExporterSERVER:/home/ubuntu
scp $cmnd ./Prometheus/StartNodeExporter.sh ubuntu@$ExporterSERVER:/home/ubuntu

echo "Changing file permissions"
ssh $cmnd ubuntu@$ExporterSERVER 'sudo chmod +x /home/ubuntu/installNodeExporter.sh'
ssh $cmnd ubuntu@$ExporterSERVER "sudo chmod +x /home/ubuntu/StartNodeExporter.sh"

echo "Running installNodeExporter.sh"
ssh $cmnd ubuntu@$ExporterSERVER /home/ubuntu/installNodeExporter.sh

echo "copying node-exporter.service file"
scp $cmnd ./Prometheus/node-exporter.service ubuntu@$ExporterSERVER:/etc/systemd/system/

echo "Running StartNodeExporter.sh"
ssh $cmnd ubuntu@$ExporterSERVER /home/ubuntu/StartNodeExporter.sh

echo "Adding Node-ecporter target to Prometheus"
#Add Node-exporter link to Prometheus configs
Prometheus_node_exporter=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicDnsName' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-node-exporter" --output text)
echo "before=$Prometheus_node_exporter="
Prometheus_node_exporter=${Prometheus_node_exporter}
echo "after=$Prometheus_node_exporter="

echo "editing /etc/prometheus/prometheus.yml file"
target="sed -i 's/_prometheusserver/$Prometheus_node_exporter:9100/' /etc/prometheus/prometheus.yml"
target1="sed -i 's/prometheus_AK/$AK/' /etc/prometheus/prometheus.yml"
target2="sed -i 's/prometheus_SK/$SK/' /etc/prometheus/prometheus.yml"
echo "target string is |$target|"
echo "target1 string is |$target1|"
echo "target2 string is |$target2|"

echo "replacing prometheus variables"
ssh $cmnd ubuntu@$SERVER $target
ssh $cmnd ubuntu@$SERVER $target1
ssh $cmnd ubuntu@$SERVER $target2
ssh $cmnd ubuntu@$SERVER "cat /etc/prometheus/prometheus.yml"

echo "restart Prometheus service"
ssh $cmnd ubuntu@$SERVER  'sudo systemctl restart prometheus'

echo "setup AlertManager"
scp $cmnd ./Prometheus/installAlertManager.sh ubuntu@$SERVER:/home/ubuntu
ssh $cmnd ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/installAlertManager.sh'
ssh $cmnd ubuntu@$SERVER /home/ubuntu/installAlertManager.sh
scp $cmnd ./Prometheus/alertmanager.yml ubuntu@$SERVER:/etc/prometheus
scp $cmnd ./Prometheus/alertmanager.service ubuntu@$SERVER:/etc/systemd/system
scp $cmnd ./Prometheus/rules.yml ubuntu@$SERVER:/etc/prometheus
ssh $cmnd ubuntu@$SERVER 'sudo chown -R prometheus:prometheus /etc/prometheus'

echo "restart Prometheus service"
ssh $cmnd ubuntu@$SERVER  'sudo systemctl restart prometheus'
ssh $cmnd ubuntu@$SERVER  'sudo systemctl restart alertmanager'
#print server details
echo "fetching prometheus server dns name"
Prometheus_Server=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicDnsName' --filters "Name=tag:Name, Values=UdaPeople-Prometheus-Server" --output text)
Prometheus_Server=${Prometheus_Server:2}
echo "Printing server details"
echo "Prometheus-server $SERVER $Prometheus_Server:9090"
echo "Node-Exporter $ExporterSERVER $Prometheus_node_exporter:9100"

end=`date +%s.%N`
echo $end
echo "$end - $start"
