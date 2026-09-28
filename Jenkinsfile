
pipeline {

    agent any

    environment {
        AWS_REGION = 'ap-south-1'

        ECR_REGISTRY = ''
        ECR_ACCOUNT_ID = ''

        RESERVATION_REPO = 'flight-reservation-dev-reservation'
        CHECKIN_REPO     = 'flight-reservation-dev-checkin'
        FRONTEND_REPO    = 'flight-reservation-dev-frontend'

        IMAGE_TAG = "${BUILD_NUMBER}"

        SONARQUBE_ENV = 'Sonarqube'

        GITOPS_DIR = 'gitops'
    }

    stages {

        // =========================================================
        // 1. CHECKOUT
        // =========================================================
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // =========================================================
        // 2. VERIFY AWS
        // =========================================================
        stage('Verify AWS') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Checking AWS authentication"
                    echo "======================================"

                    aws sts get-caller-identity

                    echo ""
                    echo "AWS Region:"
                    echo "${AWS_REGION}"

                    echo ""
                    echo "Checking ECR repositories..."

                    aws ecr describe-repositories \
                        --region "${AWS_REGION}" \
                        --query 'repositories[*].repositoryName' \
                        --output table

                    echo ""
                    echo "AWS verification completed successfully."
                '''

                script {
                    ECR_ACCOUNT_ID = sh(
                        script: 'aws sts get-caller-identity --query Account --output text',
                        returnStdout: true
                    ).trim()

                    ECR_REGISTRY = "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    echo "ECR Registry: ${ECR_REGISTRY}"
                }
            }
        }

        // =========================================================
        // 3. BACKEND BUILD & TEST
        // =========================================================
        stage('Backend Build & Test') {
            steps {
                sh '''
                    set -e

                    echo "Building Reservation Application..."

                    cd FlightReservationApplication

                    mvn clean test package -DskipTests=false

                    cd ..

                    echo "Building Check-In Application..."

                    cd FlightCheckInApplication

                    mvn clean test package -DskipTests=false

                    cd ..

                    echo "Backend build and tests completed."
                '''
            }
        }

        // =========================================================
        // 4. FRONTEND BUILD
        // =========================================================
        stage('Frontend Build') {
            steps {
                sh '''
                    set -e

                    cd frontend

                    echo "Installing frontend dependencies..."
                    npm ci

                    echo "Running frontend lint..."
                    npm run lint

                    echo "Building frontend..."
                    npm run build

                    cd ..

                    echo "Frontend build completed."
                '''
            }
        }

        // =========================================================
        // 5. SONARQUBE ANALYSIS
        // =========================================================
        stage('SonarQube Analysis') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'sonarqube-token',
                        variable: 'SONAR_TOKEN'
                    )
                ]) {

                    withSonarQubeEnv("${SONARQUBE_ENV}") {

                        sh '''
                            set -e

                            echo "Running SonarQube analysis..."

                            cd FlightReservationApplication

                            mvn sonar:sonar \
                                -Dsonar.token="${SONAR_TOKEN}"

                            cd ..

                            cd FlightCheckInApplication

                            mvn sonar:sonar \
                                -Dsonar.token="${SONAR_TOKEN}"

                            cd ..

                            echo "SonarQube analysis completed."
                        '''
                    }
                }
            }
        }

        // =========================================================
        // 6. SONARQUBE QUALITY GATE
        // =========================================================
        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {

                    script {
                        def qualityGate = waitForQualityGate(
                            abortPipeline: true
                        )

                        echo "SonarQube Quality Gate: ${qualityGate.status}"
                    }
                }
            }
        }

        // =========================================================
        // 7. DOCKER BUILD
        // =========================================================
        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "Building Reservation Docker image..."

                    docker build \
                        -t ${RESERVATION_REPO}:${IMAGE_TAG} \
                        -t ${RESERVATION_REPO}:latest \
                        ./FlightReservationApplication

                    echo "Building Check-In Docker image..."

                    docker build \
                        -t ${CHECKIN_REPO}:${IMAGE_TAG} \
                        -t ${CHECKIN_REPO}:latest \
                        ./FlightCheckInApplication

                    echo "Building Frontend Docker image..."

                    docker build \
                        -t ${FRONTEND_REPO}:${IMAGE_TAG} \
                        -t ${FRONTEND_REPO}:latest \
                        ./frontend

                    echo "Docker images built successfully."
                '''
            }
        }

        // =========================================================
        // 8. ECR LOGIN
        // =========================================================
        stage('ECR Login') {
            steps {
                sh '''
                    set -e

                    echo "Logging in to Amazon ECR..."

                    aws ecr get-login-password \
                        --region "${AWS_REGION}" \
                    | docker login \
                        --username AWS \
                        --password-stdin "${ECR_REGISTRY}"

                    echo "ECR login successful."
                '''
            }
        }

        // =========================================================
        // 9. PUSH IMAGES TO ECR
        // =========================================================
        stage('Push Images to ECR') {
            steps {
                sh '''
                    set -e

                    echo "Tagging Reservation image..."

                    docker tag \
                        ${RESERVATION_REPO}:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/${RESERVATION_REPO}:${IMAGE_TAG}

                    docker tag \
                        ${RESERVATION_REPO}:latest \
                        ${ECR_REGISTRY}/${RESERVATION_REPO}:latest


                    echo "Tagging Check-In image..."

                    docker tag \
                        ${CHECKIN_REPO}:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/${CHECKIN_REPO}:${IMAGE_TAG}

                    docker tag \
                        ${CHECKIN_REPO}:latest \
                        ${ECR_REGISTRY}/${CHECKIN_REPO}:latest


                    echo "Tagging Frontend image..."

                    docker tag \
                        ${FRONTEND_REPO}:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    docker tag \
                        ${FRONTEND_REPO}:latest \
                        ${ECR_REGISTRY}/${FRONTEND_REPO}:latest


                    echo "Pushing Reservation image..."

                    docker push \
                        ${ECR_REGISTRY}/${RESERVATION_REPO}:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/${RESERVATION_REPO}:latest


                    echo "Pushing Check-In image..."

                    docker push \
                        ${ECR_REGISTRY}/${CHECKIN_REPO}:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/${CHECKIN_REPO}:latest


                    echo "Pushing Frontend image..."

                    docker push \
                        ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    docker push \
                        ${ECR_REGISTRY}/${FRONTEND_REPO}:latest


                    echo "All images pushed successfully."
                '''
            }
        }

        // =========================================================
        // 10. UPDATE GITOPS
        // =========================================================
        stage('Update GitOps') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'github',
                        usernameVariable: 'GITHUB_USER',
                        passwordVariable: 'GITHUB_TOKEN'
                    )
                ]) {

                    sh '''
                        set -e

                        echo "Updating GitOps image tags..."

                        cd ${GITOPS_DIR}

                        sed -i "s|newTag:.*|newTag: ${IMAGE_TAG}|g" kustomization.yaml

                        echo "Updated GitOps configuration:"

                        cat kustomization.yaml

                        cd ..

                        git config user.name "${GITHUB_USER}"
                        git config user.email "${GITHUB_USER}@users.noreply.github.com"

                        git add ${GITOPS_DIR}/

                        git diff --cached --quiet || \
                        git commit -m "Update application images to build ${IMAGE_TAG}"

                        git push \
                            https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git \
                            HEAD:${GIT_BRANCH}

                        echo "GitOps changes pushed successfully."
                    '''
                }
            }
        }

        // =========================================================
        // 11. CLEANUP
        // =========================================================
        stage('Docker Cleanup') {
            steps {
                sh '''
                    echo "Cleaning unused Docker images..."

                    docker image prune -f || true

                    echo "Docker cleanup completed."
                '''
            }
        }
    }

    // =============================================================
    // POST ACTIONS
    // =============================================================
    post {

        success {
            echo '''
            ==========================================
            Jenkins Pipeline Completed Successfully
            ==========================================

            Build: ${BUILD_NUMBER}

            Images pushed to:
            - Reservation ECR
            - Check-In ECR
            - Frontend ECR

            GitOps repository updated.

            Argo CD should now detect the Git change
            and synchronize the application to EKS.
            ==========================================
            '''
        }

        failure {
            echo '''
            ==========================================
            Jenkins Pipeline FAILED
            ==========================================

            Build: ${BUILD_NUMBER}

            Check the failed stage and Jenkins console
            output for the exact error.
            ==========================================
            '''
        }

        always {
            echo "Pipeline finished: ${BUILD_NUMBER}"
        }
    }
}
