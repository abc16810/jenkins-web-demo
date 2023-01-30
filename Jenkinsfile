// auth wsm
// 声明式Pipeline
pipeline {
    agent {
        kubernetes {
        cloud 'kubernetes'
        slaveConnectTimeout 1200
        defaultContainer 'nodejs'
        //inheritFrom 'mypod' // 指定pod 模板, 如果不指定可以通过yamlfile指定文件
        workspaceVolume hostPathWorkspaceVolume(hostPath: "/home/jenkins/agent", readOnly: false)   //持久化本地目录
        yamlFile 'pod.yaml'
        }
    }
    // environment { 
    //         REPO_HTTP = 'http://10.4.56.155/ops/jenkins-python-demo.git'
    //         GIT_AUTH_ID = 'ea2f709f-9cac-4978-aeb2-9fc37e8e9667'
    //         HARBOR_ADDRESS = 'myregistry.io:8088'
    //         HARBOR_AUTH = credentials('harborAuth')
    //         IMAGE_NAME = 'my-python-demo'
    // }
    stages {
        stage('Run nodejs') {
            steps {
                sh 'node --version'
                sh 'npm --version'
                sh 'yarn --version'
                sh "echo Workspace dir is ${pwd()}"
            }
            }
    }

}