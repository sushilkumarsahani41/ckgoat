import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from urllib.parse import urlparse, urlunparse

# Path to your Firebase admin SDK key
cred_path = '/home/sushil/Downloads/ck-goatfarm-firebase-adminsdk-mel04-9adbdf05d7.json'
try:
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    print("Firebase Admin initialized successfully.")
except Exception as e:
    print(f"Failed to initialize Firebase Admin: {e}")
    exit()

# Get the Firestore client
db = firestore.client()

# Function to find and replace in URL
def find_and_replace_in_url(url, find_text, replace_text):
    try:
        if find_text in url:
            return url.replace(find_text, replace_text)
        return url
    except Exception as e:
        print(f"Error in modifying URL: {e}")
        return url

# Text to find and replace
find_text = 'api.ckgoat.greatshark.in'
replace_text = 'api-ckgoat.greatshark.in'

# Reference to the collection
collection_name = 'animals'
try:
    collection_ref = db.collection(collection_name)
    print(f"Accessing collection: {collection_name}")
except Exception as e:
    print(f"Error accessing collection {collection_name}: {e}")
    exit()

# Retrieve and update all documents in the collection
updated_document_ids = []
try:
    for doc in collection_ref.stream():
        data = doc.to_dict()
        update_data = {}
        updated = False  # Flag to check if any URL was updated

        if 'thumbnail' in data:
            updated_url = find_and_replace_in_url(data['thumbnail'], find_text, replace_text)
            if updated_url != data['thumbnail']:
                update_data['thumbnail'] = updated_url
                updated = True

        if 'uploadedUrls' in data:
            updated_urls = [find_and_replace_in_url(url, find_text, replace_text) for url in data['uploadedUrls']]
            if updated_urls != data['uploadedUrls']:
                update_data['uploadedUrls'] = updated_urls
                updated = True

        if update_data:
            doc.reference.update(update_data)
            if updated:  # Only log if there were actual changes
                updated_document_ids.append(doc.id)
                print(f"Updated document {doc.id}")

    print("All documents updated successfully. Updated document IDs:")
    for doc_id in updated_document_ids:
        print(doc_id)
except Exception as e:
    print(f"Failed during document processing: {e}")
