import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hi! This is basic Flask app!"

if __name__ == "__main__":
    port = int(os.environ.get("SERVER_PORT", 3000))
    app.run(host="0.0.0.0", port=port)
