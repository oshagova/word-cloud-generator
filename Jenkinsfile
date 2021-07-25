pipeline {
    agent none

    options {
        timestamps()
    }

    stages{
        stage('Create docker-agent for building project'){
            agent{
                dockerfile{
                    filename 'Dockerfile'
                    args '--network host'
                }
            }
            stages{
                stage('Using Make tests'){
                    steps{
                        sh '''export GOPATH=$WORKSPACE
                        export PATH="$PATH:$(go env GOPATH)/bin"
                        go get github.com/GeertJohan/go.rice/rice
                        go get github.com/oshagova/word-cloud-generator/wordyapi
                        go get github.com/gorilla/mux
                        make lint
                        make test'''
                    }
                }
                stage('Build job'){
                    steps{
                        sh '''export GOPATH=$WORKSPACE
                        export PATH="$PATH:$(go env GOPATH)/bin"
                        go get github.com/tools/godep
                        go get github.com/smartystreets/goconvey
                        go get github.com/GeertJohan/go.rice/rice
                        go get github.com/oshagova/word-cloud-generator/wordyapi
                        go get github.com/gorilla/mux
                        GOOS=linux GOARCH=amd64 go build -o ./artifacts/word-cloud-generator -v .
                        gzip -c ./artifacts/word-cloud-generator > ./artifacts/word-cloud-generator.gz
                        rm ./artifacts/word-cloud-generator
                        mv ./artifacts/word-cloud-generator.gz ./artifacts/word-cloud-generator
                        ls -l artifacts'''
                    }
                }
                stage('Upload artifacts'){
                    steps{
                        nexusArtifactUploader artifacts: [[artifactId: 'word-cloud-generator', classifier: '', file: 'artifacts/word-cloud-generator', type: 'gz']], credentialsId: 'nexus-creds', groupId: 'web-app-pipeline', nexusUrl: '192.168.33.11:8081/', nexusVersion: 'nexus3', protocol: 'http', repository: 'word-cloud-generator', version: '1.$BUILD_NUMBER'
                    }
                }
            }
        }
        stage('Create new docker-agent for making tests'){
            agent{
                dockerfile{
                    dir 'alpine_image'
                    filename 'Dockerfile'
                    args '--network host'
                }
            }
            stages{
                stage('Download and start app'){
                    steps{
                        sh '''curl -X GET -u admin:admin "http://192.168.33.11:8081//repository/word-cloud-generator/web-app-pipeline/word-cloud-generator/1.$BUILD_NUMBER/word-cloud-generator-1.$BUILD_NUMBER.gz" -o /opt/wordcloud/word-cloud-generator.gz
                        gunzip -f /opt/wordcloud/word-cloud-generator.gz
                        rm -f artifacts/*
                        chmod +x /opt/wordcloud/word-cloud-generator
                        sudo service wordcloud start'''
                    }
                }
                stage('Making tests'){
                    steps{
                        sh '''res=`curl -s -H "Content-Type: application/json" -d \'{"text":"ths is a really really really important thing this is"}\' http://192.168.33.30:8888/version | jq \'. | length\'`
                        if [ "1" != "$res" ]; then
                          exit 99
                        fi
                        res=`curl -s -H "Content-Type: application/json" -d \'{"text":"ths is a really really really important thing this is"}\' http://192.168.33.30:8888/api | jq \'. | length\'`
                        if [ "7" != "$res" ]; then
                          exit 99
                        fi'''
                    }
                }
            }
        }
    }
}
