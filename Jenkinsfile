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

    environment {
        PIPELINE_VERSION = '0.2'
        GCP_PROJECT_ID = 'danceflow-ms'  // Deine echte Projekt-ID
        REGION = 'europe-west3'
        REPO_NAME = 'danceflow-ms'
        ARTIFACT_REGISTRY = "${REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${REPO_NAME}"
        BACKEND_IMAGE = "${ARTIFACT_REGISTRY}/danceflow-backend"
        FRONTEND_IMAGE = "${ARTIFACT_REGISTRY}/danceflow-frontend"
        BACKEND_IMAGE_TAG = "${BACKEND_IMAGE}:pipeline-${PIPELINE_VERSION}.${env.BUILD_NUMBER}"
        FRONTEND_IMAGE_TAG = "${FRONTEND_IMAGE}:pipeline-${PIPELINE_VERSION}.${env.BUILD_NUMBER}"
        BACKEND_IMAGE_LATEST = "${ARTIFACT_REGISTRY}/danceflow-backend:latest"
        FRONTEND_IMAGE_LATEST = "${ARTIFACT_REGISTRY}/danceflow-frontend:latest"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        skipStagesAfterUnstable()
    }

    stages {
        stage('Test & Build') {
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
                                    sh "docker build -t ${BACKEND_IMAGE_TAG} ."
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
                                    sh "docker build -t ${FRONTEND_IMAGE_TAG} ."
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Publish Images') {
            steps {
                script {
                    sh "gcloud auth configure-docker \${REGION}-docker.pkg.dev"

                    parallel (
                        "backend": {
                            if (backendChanged() || previousBuildNotSuccessful()) {
                                sh "docker push \${env.BACKEND_IMAGE_TAG}"
                                sh "docker tag \${env.BACKEND_IMAGE_TAG} \${env.BACKEND_IMAGE_LATEST} && docker push \${env.BACKEND_IMAGE_LATEST}"
                            }
                        },
                        "frontend": {
                            if (frontendChanged() || previousBuildNotSuccessful()) {
                                sh "docker push \${env.FRONTEND_IMAGE_TAG}"
                                sh "docker tag \${env.FRONTEND_IMAGE_TAG} \${env.FRONTEND_IMAGE_LATEST} && docker push \${env.FRONTEND_IMAGE_LATEST}"
                            }
                        }
                    )
                }
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