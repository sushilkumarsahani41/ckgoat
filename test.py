import firebase_admin
from firebase_admin import credentials, firestore

# Path to your service account key file
SERVICE_ACCOUNT_FILE = 'ck-goatfarm-firebase-adminsdk-mel04-9adbdf05d7.json'

# Initialize Firebase Admin SDK
cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
firebase_admin.initialize_app(cred)

# Initialize Firestore DB
db = firestore.client()

# A helper function to update the URLs in the document (only replacing http with https)
def update_url_in_document(doc_data):
    updated_data = {}
    for key, value in doc_data.items():
        # Check if the value is a list (array of URLs)
        if isinstance(value, list):
            updated_list = []
            for item in value:
                if isinstance(item, str) and "http://" in item:
                    # Change http to https in the URL string
                    updated_list.append(item.replace("http://", "https://"))
                else:
                    updated_list.append(item)
            updated_data[key] = updated_list
        elif isinstance(value, str) and "http://" in value:
            # Change http to https in single URL strings
            updated_data[key] = value.replace("http://", "https://")
        else:
            # Leave other fields unchanged
            updated_data[key] = value
    return updated_data

# Firestore collection and batch update
def update_collection_urls(collection_name):
    # Fetch all documents from the collection
    collection_ref = db.collection(collection_name)
    docs = collection_ref.stream()

    # Process each document
    for doc in docs:
        doc_data = doc.to_dict()
        updated_data = update_url_in_document(doc_data)

        # Update the document with the new URLs (if changed)
        if updated_data != doc_data:
            collection_ref.document(doc.id).set(updated_data)
            print(f"Updated document {doc.id} with https URLs.")
        else:
            print(f"No URL changes for document {doc.id}.")

# Example: Update URLs in the 'animals' collection
update_collection_urls('animals')
