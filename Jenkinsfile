#!/usr/bin/groovy

def registry = 'forgejo.sakul-flee.de'
def namespace = 'containers'
def name = 'hytale'

def target = "docker://${registry}/${namespace}/${name}"

pipeline {
  agent {
    kubernetes {
      yaml """
      apiVersion: v1
      kind: Pod
      metadata:
        name: buildah
        namespace: jenkins
      spec:
        containers:
        - name: buildah
          image: quay.io/buildah/stable
          command: ['cat']
          tty: true
          securityContext:
            privileged: true
          volumeMounts:
          - name: forgejo-token
            mountPath: /var/run/secrets/additional/secret-jenkins-forgejo-token
            readOnly: true
        volumes:
        - name: forgejo-token
          secret:
            secretName: secret-jenkins-forgejo
      """
    }
  }

  stages {
    stage('Login') {
      steps {
        container('buildah') {
          sh "cat /var/run/secrets/additional/secret-jenkins-forgejo-token/token | buildah login --username jenkins --password-stdin \"${registry}\""
        }
      }
    }

    stage('Build') {
      steps {
        container('buildah') {
          sh "buildah bud -t ${name} ."
        }
      }
    }

    stage('Push @Dev') {
      steps {
        container('buildah') {
          sh """
            buildah push --retry 10 "${name}" "${target}:dev"
          """
        }
      }
    }

    stage('Push @Release') {
      when {
        buildingTag()
      }
      steps {
        container('buildah') {
          sh """
            buildah push --retry 10 "${name}" "${target}:${env.TAG_NAME}"
            buildah push --retry 10 "${name}" "${target}:latest"
          """
        }
      }
    }
  }
}
