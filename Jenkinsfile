pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        skipStagesAfterUnstable()
    }

    triggers {
        // Später z.B. pollSCM oder Git-Webhooks, vorerst leer
    }

    environment {
        // Platzhalter für ENV-Variablen (z.B. DOCKER_REGISTRY, MAVEN_OPTS)
    }

    stages {

        stage('Init') {
            steps {
                echo 'Init: Workspace vorbereiten'
            }
        }

        stage('Build') {
            steps {
                echo 'Build: noch kein echter Build konfiguriert'
            }
        }

        stage('Test') {
            steps {
                echo 'Test: Platzhalter für Unit-/Integrationstests'
            }
        }

        stage('Deploy') {
            when {
                expression { false }
            }
            steps {
                echo 'Deploy: hier kommt später Deployment hin'
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
