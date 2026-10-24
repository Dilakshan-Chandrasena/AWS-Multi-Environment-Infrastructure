## CI/CD Pipeline

The GitHub Actions workflow runs unit tests, dependency vulnerability
scanning, and Docker image vulnerability scanning.

On successful pushes to `main`, the workflow can publish the
application image to Amazon ECR using GitHub OIDC authentication.
Image publishing is controlled by the `ENABLE_ECR_PUSH` repository variable.