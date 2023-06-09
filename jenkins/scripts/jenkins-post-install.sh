#!/bin/bash

Jenkins_server="10.0.6.45"
jenkins_agent="10.0.6.112"
jenkins_key="terraform/keys/jenkins_key.pem"



# run on server 

echo "Configiring jenkins Server:"
echo "##########################"
echo 'download jenkins-cli.jar'
ssh -i $jenkins_key -o StrictHostKeyChecking=no  ubuntu@$Jenkins_server "curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar"
# "curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar"


echo 'installing plugins'
#sudo apt install openjdk-11-jre-headless
ssh -i $jenkins_key  ubuntu@$Jenkins_server "java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket install-plugin Git GitHub github-branch-source  pipeline-model-extensions build-monitor-plugin pipeline-build-step docker-workflow Swarm -deploy"
# java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket install-plugin Git GitHub github-branch-source  pipeline-model-extensions build-monitor-plugin pipeline-build-step docker-workflow Swarm -deploy

echo 'submit and create jenkins job'
scp -i $jenkins_key kandulaDeployment.xml ubuntu@$Jenkins_server:~
ssh -i $jenkins_key  ubuntu@$Jenkins_server "java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket create-job kandulaDeployment < kandulaDeployment.xml"


# scp -i "jenkins_key.pem" kandulaDeployment.xml ubuntu@$10.0.6.45:~

# run on node:
echo "Configiring jenkins Node:"
echo "##########################"
echo "download node client"
ssh -i $jenkins_key -o StrictHostKeyChecking=no ubuntu@$jenkins_agent "curl http://$Jenkins_server:8080/swarm/swarm-client.jar -o swarm-client.jar"
                 #   curl http://10.0.6.229:8080/swarm/swarm-client.jar -o swarm-client.jar

echo "install kubectl"
ssh -i $jenkins_key  ubuntu@$jenkins_agent "sudo apt install -y docker.io; sudo usermod -aG docker ubuntu; sudo snap install kubectl --classic; mkdir /home/ubuntu/.kube/"
# scp -i $jenkins_key  /Users/marinapr/.kube/config ubuntu@$jenkins_agent:~/.kube/config
ssh -i $jenkins_key  ubuntu@$jenkins_agent "aws eks --region=us-east-2 update-kubeconfig --name f-project-eks-cluster-2"

echo "install aws cli"
ssh -i $jenkins_key  ubuntu@$jenkins_agent "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip "
ssh -i $jenkins_key  ubuntu@$jenkins_agent "sudo apt install -y openjdk-11-jre-headless; sudo apt install unzip; unzip -o awscliv2.zip"
ssh -i $jenkins_key  ubuntu@$jenkins_agent "sudo ./aws/install"
kubectl apply -f ~/mysecret.yaml;

echo "install trivy"
ssh -i $jenkins_key  ubuntu@$jenkins_agent "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.18.3"


echo "connect node to Jenkins Server"
ssh -i $jenkins_key  ubuntu@$jenkins_agent "nohup java -jar swarm-client.jar -url http://$Jenkins_server:8080 -webSocket -name node1 -disableClientsUniqueId -retry 1 &"

#curl http://10.0.6.229:8080/swarm/swarm-client.jar -o swarm-client.jar
#nohup java -jar swarm-client.jar -url http://10.0.6.229:8080 -webSocket -name node1 -disableClientsUniqueId -retry 1 &