SERVER="52.23.252.163"
scp -i ./.ssh/Udacity_keyPair.pem ./installPythonTools.sh ubuntu@$SERVER:/home/ubuntu
scp -i ./.ssh/Udacity_keyPair.pem ./index.html ubuntu@$SERVER:/home/ubuntu
ssh -i ./.ssh/Udacity_keyPair.pem ubuntu@$SERVER