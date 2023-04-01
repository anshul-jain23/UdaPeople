touch inventory
echo "[all]" > inventory
aws ec2 describe-instances \
   --query 'Reservations[*].Instances[*].PublicIpAddress' \
   --filters "Name=tag:Project, Values=Udacity" \
   --output text >> inventory