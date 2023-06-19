#!bin/bash
set -e


jenkins_default_name="jenkins"
jenkins_home="/home/ubuntu/jenkins_home"
jenkins_home_mount="${jenkins_home}:/var/jenkins_home"
docker_sock_mount="/var/run/docker.sock:/var/run/docker.sock"
java_opts="JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"



sudo apt-get update -y
sudo apt install docker.io  -y
sudo systemctl start docker
sudo apt install openjdk-11-jre-headless -y
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
#mkdir -p ${jenkins_home}
mkdir -p /home/ubuntu/jenkins_home
#sudo chown -R 1000:1000 $jenkins_home
sudo chown -R 1000:1000 /home/ubuntu/jenkins_home
#sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${jenkins_home_mount} -v ${docker_sock_mount} --env ${java_opts} jenkins/jenkins
sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS='-Djenkins.install.runSetupWizard=false' jenkins/jenkins

#Configiring jenkins Server
curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar

#Plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket install-plugin Git GitHub github-branch-source  pipeline-model-extensions build-monitor-plugin pipeline-build-step docker-workflow Swarm -deploy

#Job
# vim or scp -i $jenkins_key kandulaDeployment.xml ubuntu@$Jenkins_server:~
java -jar jenkins-cli.jar -s http://localhost:8080/ -webSocket create-job kandulaDeployment < kandulaDeployment.xml
