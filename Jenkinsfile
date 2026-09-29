pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        AWS_REGION = 'ap-south-1'

        RESERVATION_REPO = 'flight-reservation-dev-reservation'
        CHECKIN_REPO     = 'flight-reservation-dev-checkin'
        FRONTEND_REPO    = 'flight-reservation-dev-frontend'

        GIT_REPO = 'https://github.com/AnuragPatil-cloud/flight-reservation-app-AWS.git'
        GIT_BRANCH = 'main'

        SONARQUBE_ENV = 'Sonarqube'

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Verify AWS') {
            steps {
                sh '''
                    set -e

                    echo "Checking AWS identity..."
                    aws sts get-caller-identity

                    echo "Checking ECR repositories..."
                    aws ecr describe-repositories \
                        --region "$AWS_REGION" \
                        --repository-names "$RESERVATION_REPO"

                    aws ecr describe-repositories \
                        --region "$AWS_REGION" \
                        --repository-names "$CHECKIN_REPO"

                    aws ecr describe-repositories \
                        --region "$AWS_REGION" \
                        --repository-names "$FRONTEND_REPO"

                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                        --query Account \
                        --output text)

                    echo "AWS Account: $AWS_ACCOUNT_ID"
                    echo "AWS Region : $AWS_REGION"
                '''
            }
        }

        stage('Backend Build') {
            steps {

                dir('FlightReservationApplication') {
                    sh '''
                        set -e

                        echo "Building Flight Reservation backend..."
                        mvn -B clean package -DskipTests
                    '''
                }

                dir('FlightCheckInApplication') {
                    sh '''
                        set -e

                        echo "Building Flight Check-In backend..."
                        mvn -B clean package -DskipTests
                    '''
                }
            }
        }

        stage('Frontend Build') {
            steps {
                dir('frontend') {
                    sh '''
                        set -e

                        echo "Configuring frontend API URL..."
                        printf "VITE_API_URL=/api\\n" > .env

                        echo "Installing frontend dependencies..."
                        npm ci

                        echo "Building frontend..."
                        npm run build
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {

                dir('FlightReservationApplication') {
                    withSonarQubeEnv("${SONARQUBE_ENV}") {
                        withCredentials([
                            string(
                                credentialsId: 'sonarqube-token',
                                variable: 'SONAR_TOKEN'
                            )
                        ]) {
                            sh '''
                                set -e

                                echo "Running SonarQube analysis for reservation backend..."

                                mvn -B sonar:sonar \
                                    -DskipTests \
                                    -Dsonar.token="$SONAR_TOKEN"
                            '''
                        }
                    }

                    timeout(time: 10, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }

                dir('FlightCheckInApplication') {
                    withSonarQubeEnv("${SONARQUBE_ENV}") {
                        withCredentials([
                            string(
                                credentialsId: 'sonarqube-token',
                                variable: 'SONAR_TOKEN'
                            )
                        ]) {
                            sh '''
                                set -e

                                echo "Running SonarQube analysis for check-in backend..."

                                mvn -B sonar:sonar \
                                    -DskipTests \
                                    -Dsonar.token="$SONAR_TOKEN"
                            '''
                        }
                    }

                    timeout(time: 10, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {

                    sh '''
                        set -e

                        echo "Building Reservation image..."
                        docker build \
                            -t "$RESERVATION_REPO:$IMAGE_TAG" \
                            ./FlightReservationApplication

                        echo "Building Check-In image..."
                        docker build \
                            -t "$CHECKIN_REPO:$IMAGE_TAG" \
                            ./FlightCheckInApplication

                        echo "Building Frontend image..."
                        docker build \
                            -t "$FRONTEND_REPO:$IMAGE_TAG" \
                            ./frontend
                    '''
                }
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                    set -e

                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                        --query Account \
                        --output text)

                    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    echo "Logging into ECR..."

                    aws ecr get-login-password \
                        --region "$AWS_REGION" |
                    docker login \
                        --username AWS \
                        --password-stdin "$ECR_REGISTRY"
                '''
            }
        }

        stage('Tag Images') {
            steps {
                sh '''
                    set -e

                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                        --query Account \
                        --output text)

                    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    docker tag \
                        "$RESERVATION_REPO:$IMAGE_TAG" \
                        "$ECR_REGISTRY/$RESERVATION_REPO:$IMAGE_TAG"

                    docker tag \
                        "$CHECKIN_REPO:$IMAGE_TAG" \
                        "$ECR_REGISTRY/$CHECKIN_REPO:$IMAGE_TAG"

                    docker tag \
                        "$FRONTEND_REPO:$IMAGE_TAG" \
                        "$ECR_REGISTRY/$FRONTEND_REPO:$IMAGE_TAG"
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                sh '''
                    set -e

                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                        --query Account \
                        --output text)

                    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    echo "Pushing Reservation image..."
                    docker push \
                        "$ECR_REGISTRY/$RESERVATION_REPO:$IMAGE_TAG"

                    echo "Pushing Check-In image..."
                    docker push \
                        "$ECR_REGISTRY/$CHECKIN_REPO:$IMAGE_TAG"

                    echo "Pushing Frontend image..."
                    docker push \
                        "$ECR_REGISTRY/$FRONTEND_REPO:$IMAGE_TAG"
                '''
            }
        }

        stage('Update GitOps') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -e

                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account \
                            --output text)

                        ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                        RESERVATION_IMAGE="${ECR_REGISTRY}/${RESERVATION_REPO}:${IMAGE_TAG}"
                        CHECKIN_IMAGE="${ECR_REGISTRY}/${CHECKIN_REPO}:${IMAGE_TAG}"
                        FRONTEND_IMAGE="${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}"

                        echo "Updating GitOps image references..."

                        find gitops -type f \
                            \\( -name "*.yaml" -o -name "*.yml" \\) \
                            -exec sed -i \
                            "s#\\(flight-reservation-dev-reservation:\\)[^[:space:]]*#\\1${IMAGE_TAG}#g" {} +

                        find gitops -type f \
                            \\( -name "*.yaml" -o -name "*.yml" \\) \
                            -exec sed -i \
                            "s#\\(flight-reservation-dev-checkin:\\)[^[:space:]]*#\\1${IMAGE_TAG}#g" {} +

                        find gitops -type f \
                            \\( -name "*.yaml" -o -name "*.yml" \\) \
                            -exec sed -i \
                            "s#\\(flight-reservation-dev-frontend:\\)[^[:space:]]*#\\1${IMAGE_TAG}#g" {} +

                        git config user.name "$GIT_USERNAME"
                        git config user.email "$GIT_USERNAME@users.noreply.github.com"

                        git status --short

                        git add gitops

                        if git diff --cached --quiet; then
                            echo "No GitOps changes detected."
                        else
                            git commit -m "Update application images to build ${IMAGE_TAG}"

                            set +x
                            git push \
                                "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/AnuragPatil-cloud/flight-reservation-app-AWS.git" \
                                "HEAD:${GIT_BRANCH}"
                            set -x
                        fi
                    '''
                }
            }
        }

        stage('Docker Cleanup') {
            steps {
                sh '''
                    set +e

                    docker rmi "$RESERVATION_REPO:$IMAGE_TAG" 2>/dev/null
                    docker rmi "$CHECKIN_REPO:$IMAGE_TAG" 2>/dev/null
                    docker rmi "$FRONTEND_REPO:$IMAGE_TAG" 2>/dev/null

                    docker image prune -f
                '''
            }
        }
    }

    post {
        success {
            echo '''
            ==========================================
            Jenkins Pipeline SUCCESS
            ==========================================
            Build: ${BUILD_NUMBER}
            Images pushed to ECR.
            GitOps manifests updated.
            Argo CD can now synchronize the changes.
            ==========================================
            '''
        }

        failure {
            echo '''
            ==========================================
            Jenkins Pipeline FAILED
            ==========================================
            Check the failed stage and Jenkins console.
            ==========================================
            '''
        }

        always {
            echo "Pipeline completed: ${BUILD_NUMBER}"
        }
    }
}
