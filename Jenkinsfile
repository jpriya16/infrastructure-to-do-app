pipeline {
    agent any
    stages {
        stage ('Build') {
            steps {
            withAWS(region: 'ap-southeast-1', credentials: 'awsecr') {
                // let's explode something
                script {
                    echo  "image_id"
                    echo "${env.image_id}"
                }
                  sh "terraform init"
                  sh "terraform plan -var image_id = ${env.image_id}"
            }

                }
        }
        stage ('Deploy') {
            steps {
                   withAWS(region: 'ap-southeast-1', credentials: 'awsecr') {
                    sh "terraform apply  -var image_id = ${env.image_id} --auto-approve"
                    }
                 }
        }
    }
 }
