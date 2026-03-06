pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['8289 Golden', '8342','8365','8645','8665','8666','8667','8731'],
            description: 'Choose the environment to run the test suite on.'
        )

        choice(
            name: 'SANITY_TYPE',
            choices: ['Basic', 'Extended'],
            description: 'Choose out of short sanity or extended sanity.'
        )

        string(
            name: 'TESTER',
            description: 'Enter your name.'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build SanityRunner') {
            steps {
                dir('java/local') {
                    bat 'mvn clean package'
                }
            }
        }

        stage('Run Tests') {
            steps {
                bat 'scripts\\run_tests.bat'
            }
        }

        stage('Reports Creation') {
            steps {
                bat 'scripts\\prepare_reports.bat'
            }
        }
    }

    post {
        always {
            emailext(
                subject: "${env.JOB_NAME} - Env #${params.ENV} Build #${env.BUILD_NUMBER}",
                from: "jenkins@localhost",
                to: "AQE-OffShoreGTM_Testing@int.amdocs.com",
                replyTo: "kartikve@amdocs.com",
                body: readFile("${env.BUILD_NUMBER}/summary-report.html"),
                mimeType: 'text/html',
                attachmentsPattern: "${env.BUILD_NUMBER}\\*.*"
            )
        }
    }
}
