#!/bin/bash

TRAIN_VAL_DIR=data/instructions/train_val
# Configuration - Change these variables to test different models and output directories
EMBEDDING_DIR=data/embeddings/llama3.1  # Output directory for embeddings
NICKNAME=llama3.1
MODEL_NAME=meta-llama/Llama-3.1-8B-Instruct  # Model name from HuggingFace

DEVICE=cuda:0

# Steering!
GENERATE_CONFIG_DIR=config/llama3.1
echo "Generating response for $NICKNAME"
for file in $GENERATE_CONFIG_DIR/*.yaml; do
    filename=$(basename "$file" .yaml)
    echo "Generating response for $file"
    python src/generate_response.py --config_path $file
done