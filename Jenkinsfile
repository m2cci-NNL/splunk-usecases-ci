pipeline {
  agent any
  environment {
    APP_NAME = 'socgen-usecases'
    APP_DIR  = "apps/${APP_NAME}"
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
    stage('AppInspect (optional)') {
      steps {
        sh 'bash -lc "cd apps && tar -czf ${APP_NAME}.tgz ${APP_NAME} && (splunk-appinspect inspect ${APP_NAME}.tgz --mode precert --output-file appinspect_report.json || true)"'
        archiveArtifacts artifacts: "apps/${APP_NAME}.tgz,apps/appinspect_report.json", fingerprint: true, allowEmptyArchive: true
      }
    }
    stage('Package') {
      steps {
        sh 'bash ci/package_app.sh apps/socgen-usecases ${VERSION}'
        archiveArtifacts artifacts: "dist/${APP_NAME}-${VERSION}.tgz", fingerprint: true
      }
    }
    stage('Deploy DEV') {
      when { branch 'dev' }
      steps {
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
        sh 'bash ci/deploy/deploy_shcluster.sh dist/${APP_NAME}-${VERSION}.tgz "$SPLUNK_HOST" "$SPLUNK_AUTH"'
      }
    }
  }
}
