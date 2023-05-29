def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]

pipeline {
  agent {
    docker {
      image 'node:16.17-alpine3.15'
    }
  }

  stages {
    stage('Checkout') {
        steps {
            sh 'echo passed'
            // git branch: 'main', url: 'https://github.com/dineshtamang14/Todo-Web-App.git'
        }
    }

    stage('Build and Test') {
        steps {
            sh 'ls -ltr'
            sh 'yarn install'
        }
    }
        
    stage('Static Code Analysis') {
        environment {
            SONAR_URL = 'sonarserver'
        }
        steps {
           withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                sh 'yarn global add sonarqube-scanner' // Install SonarQube scanner
                sh 'sonar-scanner -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}' // Run SonarQube scanner
            }
        }
    }

    stage('Build and Push Docker Image') {
        environment {
            DOCKER_IMAGE = "dineshtamang14/todo-app:${BUILD_NUMBER}"
            REGISTRY_CREDENTIALS = credentials('docker-cred')
        }
        steps {
            script {
                sh 'docker build -t ${DOCKER_IMAGE} .'
                def dockerImage = docker.image("${DOCKER_IMAGE}")
                docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                    dockerImage.push()
                }
            }
        }
    }
        
    stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "Todo-Web-App"
            GIT_USER_NAME = "dineshtamang14"
        }
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    git config user.email "dineshtamang7263@gmail.com"
                    git config user.name "Dinesh Tamang"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s/latest/${BUILD_NUMBER}/g" kubernetes/todo-deployment.yml
                    git add kubernetes/todo-deployment.yml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    '''
                }
            }
        }
    }
        
    post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#jenkinscicd',
            color: COLOR_MAP[currentBuild.currentResult],
            message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}
