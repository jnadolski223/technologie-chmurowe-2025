from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify({ "status": "ok" }), 200

@app.route("/hello")
def hello():
    return jsonify({ "message": "Hello World!" }), 200

@app.route("/goodbye")
def goodbye():
    return jsonify({ "message": "Goodbye!" }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
