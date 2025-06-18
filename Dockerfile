# Build stage
FROM python:3.9-slim as builder
WORKDIR /app
COPY src/requirements.txt .

# Install build dependencies and Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev && \
    pip install --user -r requirements.txt && \
    apt-get remove -y gcc python3-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Runtime stage
FROM python:3.9-slim
WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgomp1 && \
    rm -rf /var/lib/apt/lists/*

# Install AWS Lambda Runtime Interface Client
RUN pip install --no-cache-dir \
    awslambdaric==1.1.0 \
    boto3==1.26.0 \
    aws-wsgi==0.2.0

# Copy RIE (for local testing)
COPY aws-lambda-rie /usr/local/bin/aws-lambda-rie
RUN chmod +x /usr/local/bin/aws-lambda-rie

# Copy application files
COPY --from=builder /root/.local /root/.local
COPY src/ .
ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py
ENV DEBUG=false

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["app.handler"]