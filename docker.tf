resource "null_resource" "docker_build_dev" {
  triggers = {
    dockerfile_hash = filemd5("Dockerfile")
    source_hash = md5(join("", [
      filemd5("src/app.py"),
      filemd5("src/requirements.txt"),
      filemd5("aws-lambda-rie")
    ]))
  }

  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -euo pipefail
      
      echo "=== Starting Docker build process ==="
      
      # Clean up any existing containers
      docker system prune -f
      
      # Build with cache and output logs
      echo "--- Building image with cache ---"
      docker build \
        --progress plain \
        --no-cache \
        -t product-service-dev . > docker-build.log 2>&1 || (echo "ERROR: Docker build failed - see docker-build.log" && exit 1)
      
      # Tag and push
      echo "--- Tagging and pushing image ---"
      docker tag product-service-dev:latest ${module.ecr.repository_urls["dev"]}:latest
      
      aws ecr get-login-password --region ${var.region} | \
        docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
      
      docker push ${module.ecr.repository_urls["dev"]}:latest > docker-push.log 2>&1 || (echo "ERROR: Docker push failed - see docker-push.log" && exit 1)
      
      echo "=== Successfully built and pushed Docker image ==="
    EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}