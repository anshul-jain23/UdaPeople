start=`date +%s.%N`
echo $start
aws cloudformation deploy --stack-name udaPeople-Prometheus --template-file ./cdond-c3-projectstarter/Prometheus/setup.yml
aws cloudformation wait stack-create-complete --stack-name udaPeople-Prometheus
SERVER=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --filters "Name=tag:Name, Values=UdaPeople-Prometheus" --output text)
echo $SERVER
echo "copying install.sh and restart.sh to $SERVER"
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/install.sh ubuntu@$SERVER:/home/ubuntu
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/restart.sh ubuntu@$SERVER:/home/ubuntu
echo "Changing file permissions"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/install.sh'
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER 'sudo chmod +x /home/ubuntu/restart.sh'
echo "installing Prometheus"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER /home/ubuntu/install.sh
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/prometheus.yml ubuntu@$SERVER:/etc/prometheus/
scp -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ./Prometheus/prometheus.service ubuntu@$SERVER:/etc/systemd/system/
echo "restarting server"
ssh -i .ssh/Udacity_keyPair.pem -o StrictHostKeyChecking=no ubuntu@$SERVER  /home/ubuntu/restart.sh
echo "fetching Ec2 dns name"
Prometheus_Server=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicDnsName' --filters "Name=tag:Name, Values=UdaPeople-Prometheus" --output text)
echo "$Prometheus_Server:9090"
end=`date +%s.%N`
echo $end
echo "$end - $start"