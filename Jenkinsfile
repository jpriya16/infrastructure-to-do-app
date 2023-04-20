pipeline {
    agent any
    stages {
        stage ('Build') {
            steps {
            withAWS(region: 'ap-southeast-1', credentials: 'awsecr') {
                // let's explode something
                  sh "terraform init"
                   sh "terraform plan"
            }

                }
        }
        stage ('Deploy') {
            steps {
                   withAWS(region: 'ap-southeast-1', credentials: 'awsecr') {
                    sh 'terraform apply --auto-approve'
                    }
                 }
        }
    }
 }
