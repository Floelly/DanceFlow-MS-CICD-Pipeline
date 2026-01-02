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

def previousBuildNotSuccessful() {
    def prev = currentBuild.previousBuild
    // beim allerersten Lauf gibt es kein previousBuild
    if (prev == null) {
        return false
    }
    return prev.result != 'SUCCESS'
}

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        skipStagesAfterUnstable()
    }

    stages {
        stage('Test & Build') {
            parallel {

            }
        }

        stages {
            stage('Build & Test') {
                parallel {
                    stage('Backend') {
                        when {
                            expression { backendChanged() || previousBuildNotSuccessful() }
                        }
                        stages {
                            stage('Test Backend') {
                                agent {
                                    docker {
                                        image 'maven:3.9.9-eclipse-temurin-17'
                                        args '-v /tmp/m2:/root/.m2'
                                    }
                                }
                                steps {
                                    dir('springboot-backend') {
                                        echo 'Run Backend Unit Tests (Maven in Docker Agent)'
                                        sh 'mvn -B -ntp test'
                                        // junit 'target/surefire-reports/**/*.xml'
                                    }
                                }
                            }
                            stage('Build Backend Image') {
                                steps {
                                    dir('springboot-backend') {
                                        echo "Build Backend Docker image aus Dockerfile"
                                        sh "docker build -t danceflow-backend:pipeline-0.1-${env.BUILD_NUMBER} ."
                                    }
                                }
                            }
                        }
                    }

                    stage('Frontend') {
                        when {
                            expression { frontendChanged() || previousBuildNotSuccessful() }
                        }
                        stages {
                            stage('Test Frontend') {
                                agent {
                                    docker {
                                        image 'node:20-alpine'
                                        args '-u root:root'
                                    }
                                }
                                steps {
                                    dir('react-frontend') {
                                        echo 'Run Frontend Tests (npm in Docker Agent)'
                                        sh 'npm ci'
                                        sh 'npm run lint'
                                        sh 'npm run test'
                                    }
                                }
                            }
                            stage('Build Frontend Image') {
                                steps {
                                    dir('react-frontend') {
                                        echo "Build Frontend Docker image aus Dockerfile"
                                        sh "docker build -t danceflow-frontend:pipeline-0.1-${env.BUILD_NUMBER} ."
                                    }
                                }
                            }
                        }
                    }
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