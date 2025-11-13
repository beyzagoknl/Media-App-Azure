import os
import uuid
from flask import Flask, request, jsonify
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, ContentSettings

app = Flask(__name__)

ACCOUNT_NAME = os.environ["STORAGE_ACCOUNT_NAME"]
RAW_CONTAINER = os.environ.get("RAW_CONTAINER", "rawfiles")

credential = DefaultAzureCredential()
bsc = BlobServiceClient(
    account_url=f"https://{ACCOUNT_NAME}.blob.core.windows.net",
    credential=credential
)

@app.route("/upload", methods=["POST"])
def upload():
    if "file" not in request.files:
        return jsonify({"error": "file field is required"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "empty filename"}), 400

    name = f"{int(uuid.uuid4().int % 1e10)}-{file.filename}"
    blob = bsc.get_blob_client(container=RAW_CONTAINER, blob=name)
    content_type = file.mimetype or "application/octet-stream"

    blob.upload_blob(
        file.stream,
        overwrite=True,
        content_settings=ContentSettings(content_type=content_type)
    )

    return jsonify({"stored": f"{RAW_CONTAINER}/{name}"}), 200


@app.route("/healthz", methods=["GET"])
def health():
    return "ok", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
