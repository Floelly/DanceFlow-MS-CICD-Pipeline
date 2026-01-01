def backendChanged() {
    return currentBuild.changeSets.any { cs ->
        cs.items.any { entry ->
            entry.affectedFiles.any { f ->
                f.path.startsWith('springboot-backend/') ||
                f.path == 'Jenkinsfile' ||
                f.path == 'LICENSE'
            }
        }
    }
}

def frontendChanged() {
    return currentBuild.changeSets.any { cs ->
        cs.items.any { entry ->
            entry.affectedFiles.any { f ->
                f.path.startsWith('react-frontend/') ||
                f.path == 'Jenkinsfile' ||
                f.path == 'LICENSE'
            }
        }
    }
}

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        skipStagesAfterUnstable()
    }

    // triggers {}

    // environment {}

    stages {
        stage('Build Backend Image') {
            when {
                expression { backendChanged() }
            }
            steps {
                dir('springboot-backend') {
                    echo "Build Backend Docker image aus Dockerfile"
                    sh "docker build -t danceflow-backend:pipeline-0.1-${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Test Backend') {
            when {
                expression { backendChanged() }
            }
            steps {
                dir('springboot-backend') {
                    echo 'Test Backend (Maven)'
                    sh 'mvn -B -ntp test'
                    // später: junit 'target/surefire-reports/**/*.xml'
                }
            }
        }

        stage('Build Frontend') {
            when {
                expression { frontendChanged() }
            }
            steps {
                dir('react-frontend') {
                    echo 'Build Frontend (npm)'
                    sh 'npm ci'
                    sh 'npm run build'
                }
            }
        }

        stage('Test Frontend') {
            when {
                expression { frontendChanged() }
            }
            steps {
                dir('react-frontend') {
                    echo 'Test Frontend (npm)'
                    // z.B.:
                    // sh 'npm test -- --watch=false'
                }
            }
        }

        stage('Deploy') {
            when {
                expression { false }
            }
            steps {
                echo 'Deploy: hier kommt später cranke Deployments hin'
            }
        }
    }

    post {
        always {
            echo 'Post: läuft immer (Cleanup/Archivierung/Notifications)'
        }
        success {
            echo 'Post: Build erfolgreich'
        }
        failure {
            echo 'Post: Build fehlgeschlagen'
        }
    }
}
