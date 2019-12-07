pipeline {
  environment {
    registry = "mirrmurr/l2tp-ipsec-vpn-server"
    registryCredential = 'dockerhub'
  }
  agent any
  stages {
    stage('Clone Git repo') {
        steps {
            git 'https://github.com/MirrMurr/l2tp-ipsec-vpn-server.git'
        }
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":latest"
        }
      }
    }
    stage('Deploy image') {
        steps {
            script {
                docker.withRegistry('', registryCredential) {
                    dockerImage.push()
                }
            }
        }
    }
    stage('Remove unused docker image') {
        steps {
            sh "docker rmi $registry:latest"
        }
    }
  }
}