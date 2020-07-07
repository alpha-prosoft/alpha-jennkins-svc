#!/bin/bash 

jira_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/jira-http" \
	                  --query "SecretString" --output text)"

export JiraHttpUser="$(echo ${jira_http} | jq -r '.username')"
export JiraHttpPassword="$(echo ${jira_http} | jq -r '.password')"

echo "JiraHttpUser=${JiraHttpUser}" >> /etc/environment
echo "JiraHttpPassword=${JiraHttpPassword}" >> /etc/environment

docker_push_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/docker-push-http" \
	                  --query "SecretString" --output text)"

export DockerPushHttpUser="$(echo ${docker_push_http} | jq -r '.username')"
export DockerPushHttpPassword="$(echo ${docker_push_http} | jq -r '.password')"

echo "DockerPushHttpUser=${DockerPushHttpUser}" >> /etc/environment
echo "DockerPushHttpPassword=${DockerPushHttpPassword}" >> /etc/environment




echo "Preparing configuration"
envsubst < /etc/jenkins/jenkins-configuration-template.yml | tee /etc/jenkins/jenkins-configuration.yml
sed -e 's/§/$/g' -i /etc/jenkins/jenkins-configuration-template.yml 

envsubst < /etc/jenkins/gerrit-trigger-template.xml | tee /var/lib/jenkins/gerrit-trigger.xml

chown jenkins:jenkins /var/lib/jenkins -R

echo "Starting jenkins"

systemctl start jenkins
