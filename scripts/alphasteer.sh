#!/bin/bash

TRAIN_VAL_DIR=data/instructions/train_val
# Configuration - Change these variables to test different models and output directories
EMBEDDING_DIR=data/embeddings/llama3.1  # Output directory for embeddings
NICKNAME=llama3.1
MODEL_NAME=meta-llama/Llama-3.1-8B-Instruct  # Model name from HuggingFace

DEVICE=cuda:0


# Extract embeddings
for file in $TRAIN_VAL_DIR/*.json; do
    filename=$(basename "$file" .json)
    echo "Extracting embeddings for $file"
    
    # Set prompt_column based on filename
    if [[ "$filename" == *"coconot"* ]]; then
        prompt_column="prompt"
    else
        prompt_column="query"
    fi
    
    python src/extract_embeddings.py --model_name $MODEL_NAME \
                                    --input_file $file \
                                    --prompt_column "$prompt_column" \
                                    --output_file $EMBEDDING_DIR/embeds_$filename.pt \
                                    --batch_size 16 \
                                    --device $DEVICE
done

# Calculate steering matrix
STEERING_SAVE_PATH=data/steering_matrix/steering_matrix_${NICKNAME}.pt
echo "Calculating steering matrix for $NICKNAME"
python src/calc_steering_matrix.py --model_name $NICKNAME\
                                    --embedding_dir $EMBEDDING_DIR \
                                    --device $DEVICE \
                                    --save_path $STEERING_SAVE_PATH


# Steering!
GENERATE_CONFIG_DIR=config/llama3.1
echo "Generating response for $NICKNAME"
for file in $GENERATE_CONFIG_DIR/*.yaml; do
    filename=$(basename "$file" .yaml)
    echo "Generating response for $file"
    python src/generate_response.py --config_path $file
done