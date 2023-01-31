// auth wsm
// 声明式Pipeline
pipeline {
    agent {
        kubernetes {
        cloud 'kubernetes'
        slaveConnectTimeout 1200
        //defaultContainer 'nodejs'
        //inheritFrom 'mypod' // 指定pod 模板, 如果不指定可以通过yamlfile指定文件
        workspaceVolume hostPathWorkspaceVolume(hostPath: "/home/jenkins/agent", readOnly: false)   //持久化本地目录
        yamlFile 'pod.yaml'
        }
    }
    environment { 
            REPO_HTTP = 'http://10.4.56.155/lumanman/performance-task-assessment-web.git'
            GIT_AUTH_ID = 'ea2f709f-9cac-4978-aeb2-9fc37e8e9667'
            HARBOR_ADDRESS = 'myregistry.io:8088'
            HARBOR_AUTH = credentials('harborAuth')
            IMAGE_NAME = 'my-test-nginx'
    }
    parameters {
        // https://plugins.jenkins.io/git-parameter  用useRepository指定SCM
        gitParameter branchFilter: 'origin.*/(.*)', defaultValue: 'master', name: 'Name', type: 'PT_BRANCH', useRepository: '.*web.git'
        choice(
        name: 'ACTION',  //ACTION 选择参数名称
        description: '执行动作: \nbuild: 只构建镜像，不发布\ndeploy: 构建镜像并发布更新到开发环境',
        choices: ['deploy','build']
        )
    }
    stages {
        stage('Run nodejs test') {
            steps {
                container('nodejs') { 
                    sh 'node --version && npm --version && yarn --version'
                    sh "echo Workspace dir is ${pwd()}"
                }
            }
        }
        stage("Pulling Code"){
            steps{
                // sh '''
                // pwd && id
                // '''
                //检出指定分支代码
                dir('project'){
                    git branch: "${params.Name}", credentialsId: "${GIT_AUTH_ID}", url: "${REPO_HTTP}"
                }
                script {
                    COMMIT_ID = sh(
                        returnStdout: true,
                        script: "git log -n 1 --pretty=format:'%h'"
                    ).trim()
                    TAG = "${params.Name}" + '-' + COMMIT_ID
                     println "Current branch is ${params.Name}, Commit ID is ${COMMIT_ID}, Image TAG is ${TAG}"
                }
        
            }
        }
        stage('Building') {
            when {
                expression { params.ACTION ==~ /(build|deploy)/ }
            }
            steps {
                container(name: 'nodejs') {
                sh '''
                cd project && pwd
                npm config set registry https://registry.npm.taobao.org
                npm config get registry
                export CI=false
                yarn install --https-proxy=http://10.4.56.230:3128
                yarn run build
                ls -l
                '''
                }
            }
        }
        stage("Docker build for creating image"){
            when {
                expression { params.ACTION ==~ /(build|deploy)/ }
            }
            steps {
                container('nerdctl') {   //指定容器
                    sh '''
                    set +x
                    cd project && id && pwd
                    update-ca-certificates
                    nerdctl login -u ${HARBOR_AUTH_USR} -p ${HARBOR_AUTH_PSW}  ${HARBOR_ADDRESS}
                    '''
                    sh "nerdctl build  -t ${HARBOR_ADDRESS}/library/${IMAGE_NAME}:${TAG} ../"
                    sh "nerdctl push ${HARBOR_ADDRESS}/library/${IMAGE_NAME}:${TAG}"
                }
            }
        }



    }

}


