node("master") {
    stage("run") {
        timestamps { 
            ansiColor('xterm') { 
            
                properties([
                    buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')), 
                    pipelineTriggers([pollSCM('H/15 * * * *')])])
                
                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: '*/master']], 
                    doGenerateSubmoduleConfigurations: false, extensions: 
                    [
                        [$class: 'RelativeTargetDirectory', 
                            relativeTargetDir: 'integration-tests']
                    ], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [
                        [url: 'https://github.com/maestro-performance/integration-tests.git']]])
        
                
                stage('prepare') {
                    sh 'cd integration-tests && ./prepare.sh'
                }
                
                
                stage('All Out Tests') {
                    sh "cd $WORKSPACE/integration-tests/work && ./test-all-out.sh all"
                }
                
                stage('Incremental Tests') {
                    sh "cd $WORKSPACE/integration-tests/work && ./test-fair-incremental.sh all"
                }

                stage('Fixed Rate Tests') {
                    sh "cd $WORKSPACE/integration-tests/work && ./test-fixed-rate.sh all"
                }

                stage('Warmed Up Fixed Rate Tests') {
                    sh "cd $WORKSPACE/integration-tests/work && ./test-fixed-rate.sh all"
                }
                
                xunit testTimeMargin: '7200000',
                    thresholds: [
                        failed(failureThreshold: '2'), 
                        skipped(failureThreshold: '5')], 
                    tools: [
                        Custom(customXSL: 'https://issues.jenkins-ci.org/secure/attachment/43984/custom-to-junit.xsl', 
                        deleteOutputFiles: true, 
                        failIfNotNew: true, 
                        pattern: 'integration-tests/work/results/**/*.xml', 
                        skipNoTestFiles: false, 
                        stopProcessingIfError: false)]
            }
        }
        
        cleanWs()
    }
}