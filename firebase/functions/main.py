# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn
from firebase_admin import initialize_app
import flask
from flask_cors import CORS
from routes.machines import bp as bp_machines

initialize_app()
app = flask.Flask(__name__)
CORS(app)

app.register_blueprint(bp_machines, url_prefix='/machines')

@app.get("/")
def root():
    return flask.Response(status=200, response="Hello World!")

@https_fn.on_request()
def appy(req: https_fn.Request) -> https_fn.Response:
    with app.request_context(req.environ):
        return app.full_dispatch_request()