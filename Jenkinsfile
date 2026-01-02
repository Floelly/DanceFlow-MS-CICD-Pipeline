def backendChanged() {
    return currentBuild.changeSets.any { cs ->
        cs.items.any { entry ->
            entry.affectedFiles.any { f ->
                f.path.startsWith('springboot-backend/') ||
                f.path.startsWith('ci/') ||
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
                f.path.startsWith('ci/') ||
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

        GCP_PROJECT_ID = 'danceflow-ms'
        REGION = 'europe-west3'
        REPO_NAME = 'danceflow-ms'
        STAGING_BACKEND_SERVICE  = 'danceflow-ms-backend-staging'
        STAGING_FRONTEND_SERVICE = 'danceflow-ms-frontend-staging'
        STAGING_CLOUD_SQL_DB = 'danceflow-ms-staging-db'
        STAGING_DB_INSTANCE_CONNECTION_NAME = "${GCP_PROJECT_ID}:${REGION}:${STAGING_CLOUD_SQL_DB}"
        PROD_BACKEND_SERVICE  = 'danceflow-ms-backend'
        PROD_FRONTEND_SERVICE = 'danceflow-ms-frontend'
        PROD_CLOUD_SQL_DB = 'danceflow-ms-prod-db'
        DATABASE_SCHEMA_NAME = 'danceflow_ms'

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
            when {  // TODO: ACTIVATE
                    expression { false }
                }
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
            when {  // TODO: ACTIVATE
                expression { false }
            }
            steps {
                script {
                    sh "gcloud auth configure-docker \${REGION}-docker.pkg.dev"

                    parallel (
                        "backend": {
                            if (backendChanged() || previousBuildNotSuccessful()) {
                                sh "docker push \${BACKEND_IMAGE_TAG}"
                                sh "docker tag \${BACKEND_IMAGE_TAG} \${BACKEND_IMAGE_LATEST} && docker push \${BACKEND_IMAGE_LATEST}"
                            }
                        },
                        "frontend": {
                            if (frontendChanged() || previousBuildNotSuccessful()) {
                                sh "docker push \${FRONTEND_IMAGE_TAG}"
                                sh "docker tag \${FRONTEND_IMAGE_TAG} \${FRONTEND_IMAGE_LATEST} && docker push \${FRONTEND_IMAGE_LATEST}"
                            }
                        }
                    )
                }
            }
        }

        stage('Staging: DB Backup & Migration') {
            when {  // TODO: ACTIVATE
                expression { false }
            }
            environment {
                    CLOUD_SQL_INSTANCE = "${STAGING_CLOUD_SQL_DB}"
                    DB_INSTANCE_CONNECTION_NAME = "${STAGING_DB_INSTANCE_CONNECTION_NAME}"

                    FLYWAY_CREDS = credentials('danceflow-ms-staging-db-flyway-user')
                }
            steps {
                sh 'bash ci/migrate-cloud-sql.sh'
            }
        }

        stage('Staging: Deploy Services') {
            steps {
                echo 'deploy new backend service to staging (soon)'
                //sh 'ci/deploy-staging-backend.sh'
                echo 'deploy new frontend service to staging (soon)'
                //sh 'ci/deploy-staging-frontend.sh'
            }
        }

        stage('Staging: Smoke Tests') {
            steps {
                echo 'not implemented! add smoke tests or integration tests here later'
            }
        }

        stage('deploy to production') {
            when {
                expression { false }
            }
            steps {
                echo 'wait for manual approval'
                echo 'Deploy soon'
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