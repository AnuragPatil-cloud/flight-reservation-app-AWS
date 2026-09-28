pipeline {
  agent any

  environment {
    AWS_REGION       = 'ap-south-1'
    ECR_ACCOUNT_ID   = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
    ECR_REGISTRY     = "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    RESERVATION_REPO = 'flight-reservation-dev-reservation'
    CHECKIN_REPO     = 'flight-reservation-dev-checkin'
    FRONTEND_REPO    = 'flight-reservation-dev-frontend'
    TAG              = "${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Backend Build') {
      steps {
        sh """
          set -e

          DB_CONTAINER="ci-mysql-${BUILD_NUMBER}"

          docker run -d \
            --name "\${DB_CONTAINER}" \
            -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
            -e MYSQL_DATABASE=flightdb \
            -p 3307:3306 \
            mysql:8.4

          for i in \$(seq 1 60); do
            if docker exec "\${DB_CONTAINER}" \
              mysqladmin ping -h 127.0.0.1 -uroot --silent; then
              echo "MySQL is ready"
              break
            fi

            if [ "\$i" -eq 60 ]; then
              echo "MySQL failed to start"
              docker logs "\${DB_CONTAINER}" || true
              exit 1
            fi

            sleep 2
          done

          docker exec "\${DB_CONTAINER}" \
            mysql -uroot \
            -e "CREATE DATABASE IF NOT EXISTS checkin_db;"

          cd FlightReservationApplication

          mvn clean verify \
            -Dspring.datasource.url="jdbc:mysql://127.0.0.1:3307/flightdb?createDatabaseIfNotExist=true" \
            -Dspring.datasource.username=root \
            -Dspring.datasource.password=""

          cd ../FlightCheckInApplication

          mvn clean package -DskipTests
        """
      }
    }

    stage('Frontend Checks') {
      steps {
        dir('frontend') {
          sh 'npm ci'

          sh """
            set +e
            npm run lint
            LINT_STATUS=\$?

            if [ "\$LINT_STATUS" -ne 0 ]; then
              echo "WARNING: ESLint reported issues. Continuing."
            fi

            exit 0
          """

          sh 'VITE_API_URL= VITE_API_CHECKIN_URL= npm run build'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('Sonarqube') {
          withCredentials([
            string(
              credentialsId: 'sonarqube-token',
              variable: 'SONAR_TOKEN'
            )
          ]) {
            dir('FlightReservationApplication') {
              sh """
                mvn -DskipTests sonar:sonar \
                  -Dsonar.token="\${SONAR_TOKEN}" \
                  -Dsonar.host.url="\${SONAR_HOST_URL}"
              """
            }
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh """
          set -e

          docker build \
            -t \${ECR_REGISTRY}/\${RESERVATION_REPO}:\${TAG} \
            -t \${ECR_REGISTRY}/\${RESERVATION_REPO}:latest \
            FlightReservationApplication

          docker build \
            -t \${ECR_REGISTRY}/\${CHECKIN_REPO}:\${TAG} \
            -t \${ECR_REGISTRY}/\${CHECKIN_REPO}:latest \
            FlightCheckInApplication

          docker build \
            --build-arg VITE_API_URL= \
            --build-arg VITE_API_CHECKIN_URL= \
            -t \${ECR_REGISTRY}/\${FRONTEND_REPO}:\${TAG} \
            -t \${ECR_REGISTRY}/\${FRONTEND_REPO}:latest \
            frontend
        """
      }
    }

    stage('Push Images to ECR') {
      steps {
        sh """
          set -e

          aws ecr get-login-password --region \${AWS_REGION} | \
            docker login --username AWS --password-stdin \${ECR_REGISTRY}

          docker push \${ECR_REGISTRY}/\${RESERVATION_REPO}:\${TAG}
          docker push \${ECR_REGISTRY}/\${RESERVATION_REPO}:latest

          docker push \${ECR_REGISTRY}/\${CHECKIN_REPO}:\${TAG}
          docker push \${ECR_REGISTRY}/\${CHECKIN_REPO}:latest

          docker push \${ECR_REGISTRY}/\${FRONTEND_REPO}:\${TAG}
          docker push \${ECR_REGISTRY}/\${FRONTEND_REPO}:latest
        """
      }
    }

    stage('Update GitOps') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'github',
            usernameVariable: 'GITHUB_USER',
            passwordVariable: 'GITHUB_TOKEN'
          )
        ]) {
          sh """
            set -e

            sed -i -E \
              "s|^([[:space:]]*image:)[[:space:]].*flight-reservation-dev-reservation.*|\\\\1 \${ECR_REGISTRY}/\${RESERVATION_REPO}:\${TAG}|" \
              gitops/reservation-deployment.yaml

            sed -i -E \
              "s|^([[:space:]]*image:)[[:space:]].*flight-reservation-dev-checkin.*|\\\\1 \${ECR_REGISTRY}/\${CHECKIN_REPO}:\${TAG}|" \
              gitops/checkin-deployment.yaml

            sed -i -E \
              "s|^([[:space:]]*image:)[[:space:]].*flight-reservation-dev-frontend.*|\\\\1 \${ECR_REGISTRY}/\${FRONTEND_REPO}:\${TAG}|" \
              gitops/frontend-deployment.yaml

            git config user.name "jenkins"
            git config user.email "jenkins@local"

            git add gitops/

            if ! git diff --cached --quiet; then
              git commit -m "Update images to build \${TAG} [skip ci]"

              git -c credential.helper='!f() { echo username="\$GITHUB_USER"; echo password="\$GITHUB_TOKEN"; }; f' \
                push origin HEAD:main
            else
              echo "No GitOps changes required"
            fi
          """
        }
      }
    }
  }

  post {
    always {
      sh """
        docker logout \${ECR_REGISTRY} || true
        docker rm -f ci-mysql-\${BUILD_NUMBER} 2>/dev/null || true
        docker image prune -f || true
      """
    }
  }
}
