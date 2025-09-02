pipeline {
  agent any
  environment {
    APP_NAME = 'socgen-usecases'
    TA_NAME  = 'TA_aws_cloudtrail_custom'
    APP_DIR  = "apps/${APP_NAME}"
    TA_DIR   = "apps/${TA_NAME}"
    VERSION  = "${env.BUILD_NUMBER}"
    SPLUNK_HOST = credentials('splunk_host')
    SPLUNK_AUTH = credentials('splunk_auth')
  }
  options { timestamps() }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Generate savedsearches.conf from YAML') {
      steps { sh 'python3 ci/gen_savedsearches.py src/splunk/usecases > apps/socgen-usecases/default/savedsearches.conf' }
    }
    stage('Validate configs') {
      steps { sh 'bash ci/validate_splunk_conf.sh apps/socgen-usecases' }
    }
    stage('Package TA & App') {
      steps {
        sh 'bash ci/package_app.sh ${TA_DIR} ${VERSION}'
        sh 'bash ci/package_app.sh ${APP_DIR} ${VERSION}'
        archiveArtifacts artifacts: "dist/*-${VERSION}.tgz", fingerprint: true
      }
    }
    stage('Deploy DEV (TA puis App)') {
      when { branch 'dev' }
      steps {
        sh 'bash ci/deploy/deploy_standalone.sh dist/${TA_NAME}-${VERSION}.tgz "$SPLUNK_HOST" "$SPLUNK_AUTH"'
        sh 'bash ci/deploy/deploy_standalone.sh dist/${APP_NAME}-${VERSION}.tgz "$SPLUNK_HOST" "$SPLUNK_AUTH"'
      }
    }
    stage('Smoke tests') {
      when { branch 'dev' }
      steps {
        sh 'curl -sk -u $SPLUNK_AUTH $SPLUNK_HOST/servicesNS/-/-/saved/searches | grep -E "IAM Policy Change - Suspicious|AWS Console Login - Failure Burst" || exit 1'
      }
    }
    stage('Deploy PROD') {
      when { branch 'main' }
      steps {
        input message: "Confirmer déploiement PROD ?", ok: "Déployer"
        sh 'bash ci/deploy/deploy_shcluster.sh dist/${TA_NAME}-${VERSION}.tgz "$SPLUNK_HOST" "$SPLUNK_AUTH"'
        sh 'bash ci/deploy/deploy_shcluster.sh dist/${APP_NAME}-${VERSION}.tgz "$SPLUNK_HOST" "$SPLUNK_AUTH"'
      }
    }
  }
}
