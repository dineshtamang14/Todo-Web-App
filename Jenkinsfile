def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]

pipeline {
    agent any 
//   agent {
//     docker {
//       image 'node:latest'
//     }
//   }

  stages {
    stage('Checkout') {
        steps {
            sh 'echo passed'
            // git branch: 'main', url: 'https://github.com/dineshtamang14/Todo-Web-App.git'
        }
    }

    stage('Build and Test') {
        steps {
            sh "echo 'running unit tests: '"
            sh 'yarn install'
            // sh 'yarn run test'
        }
    }
        
    stage('Static Code Analysis') {
        steps {
            nodejs(nodeJSInstallationName: 'nodejs'){
                withSonarQubeEnv('sonar'){
                    sh "yarn run sonar"
                }
            }
        }
    }

    stage("Quality Gate") {
        steps {
            timeout(time: 1, unit: 'HOURS') {
                // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                // true = set pipeline to UNSTABLE, false = don't
                waitForQualityGate abortPipeline: true
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
            slackSend channel: '#cicd-jenkins',
            color: COLOR_MAP[currentBuild.currentResult],
            message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}
