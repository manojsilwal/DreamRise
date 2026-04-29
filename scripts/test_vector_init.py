import os
import logging
from backend.knowledge_store import KnowledgeStore

logging.basicConfig(level=logging.INFO)

print("--- Testing Vector Backend Init ---")
ks = KnowledgeStore()
backend = ks._vector_backend
print(f"Active Backend: {ks._active_vector_backend}")
if hasattr(backend, '_embedding_function'):
    print(f"Embedding Function: {type(backend._embedding_function).__name__}")
    if backend._embedding_function:
        print(f"Model Name: {getattr(backend._embedding_function, '_model_name', 'unknown')}")
else:
    print("Backend has no _embedding_function attribute")
