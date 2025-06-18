from flask import Flask, jsonify, request
import os
import boto3
from boto3.dynamodb.conditions import Key
from aws_wsgi import AWSLambdaHandler

app = Flask(__name__)

# Environment configuration
ENV = os.getenv('ENVIRONMENT', 'dev')
TABLE_NAME = f'product-catalog-{ENV}'
DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

@app.route('/products', methods=['GET'])
def get_products():
    try:
        response = table.scan()
        return jsonify(response['Items'])
    except Exception as e:
        app.logger.error(f"Error scanning products: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/products/<product_id>', methods=['GET'])
def get_product(product_id):
    try:
        response = table.get_item(Key={'productId': product_id})
        if 'Item' not in response:
            return jsonify({'error': 'Product not found'}), 404
        return jsonify(response['Item'])
    except Exception as e:
        app.logger.error(f"Error getting product {product_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/products', methods=['POST'])
def create_product():
    try:
        product_data = request.json
        if not product_data or 'productId' not in product_data:
            return jsonify({'error': 'Invalid product data'}), 400
            
        table.put_item(Item=product_data)
        return jsonify(product_data), 201
    except Exception as e:
        app.logger.error(f"Error creating product: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# AWS Lambda handler
handler = AWSLambdaHandler(app)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=DEBUG)