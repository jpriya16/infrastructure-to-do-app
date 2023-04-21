pipeline {
    agent any
     parameters {
            string(name: image_id, defaultValue: '', description:'output from to-do-app pipeline')
     }
    stages {
        stage ('Build') {
            steps {
            withAWS(region: 'ap-southeast-1', credentials: 'awsecr') {
                // let's explode something
                script {
                    echo  "image_id"
                    echo "${params.image_id}"
                }
                  sh "terraform init"
                  sh "terraform plan"
            }

                }
        }
        stage ('Deploy') {
            steps {
                   withAWS(region: 'ap-southeast-1', credentials: 'awsecr') {
                    sh "terraform apply  -var image_id = ${params.image_id} --auto-approve"
                    }
                 }
        }
    }
 }
