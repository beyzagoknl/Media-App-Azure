from flask import Flask, request, jsonify
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobClient
import os, uuid

app = Flask(__name__)

ACCOUNT_NAME = os.environ["STORAGE_ACCOUNT_NAME"]
CONTAINER = os.environ.get("RAW_CONTAINER", "rawfiles")
credential = DefaultAzureCredential()

@app.route("/upload", methods=["POST"])
def upload():
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "no file provided"}), 400

    blob_name = f"{uuid.uuid4().hex[:10]}-{file.filename}"
    blob = BlobClient(
        account_url=f"https://{ACCOUNT_NAME}.blob.core.windows.net",
        container_name=CONTAINER,
        blob_name=blob_name,
        credential=credential
    )
    blob.upload_blob(file.stream, overwrite=True)
    return jsonify({"stored": blob_name}), 200

@app.route("/healthz")
def health():
    return "ok"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)