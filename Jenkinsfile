#!/usr/bin/groovy

def registry = 'forgejo.sakul-flee.de'
def namespace = 'container'
def name = 'hytale'

def full = "${registry}/${namespace}/${name}"

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

    stage('Push') {
      steps {
        container('buildah') {
          sh """
            buildah push --retry 10 \"${name}\" \"docker://${full}:latest"
          """
        }
      }
    }
  }
}
