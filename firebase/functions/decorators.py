from flask import request, jsonify
from functools import wraps
import os

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        AUTH_TOKEN = os.getenv('AUTH_TOKEN')
        if not token or token != f"Bearer {AUTH_TOKEN}":
            return jsonify({"message": "Unauthorized access"}), 401
        return f(*args, **kwargs)
    return decorated