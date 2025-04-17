#!/bin/bash
# Script to run experiments from a JSON ideas file

# Function to check if the AI Scientist service is running
check_service_status() {
  if ! docker ps | grep -q ai_scientist_service; then
    echo "❌ Error: AI Scientist service is not running"
    echo "Please start the service first with: make start"
    exit 1
  fi
}

# Check if file parameter is provided
if [ -z "$1" ]; then
  echo "Error: No JSON ideas file specified."
  echo "Usage: ./run_experiment.sh path/to/ideas.json [idea_index] [writeup_model] [citation_model]"
  exit 1
fi

# Check if the service is running before proceeding
check_service_status

# Default parameters
IDEAS_FILE=$1
IDEA_IDX=${2:-0}
MODEL_WRITEUP=${3:-"o1-preview-2024-09-12"}
MODEL_CITATION=${4:-"gpt-4o-2024-11-20"}

# Execute the command in the running container
docker exec ai_scientist_service python launch_scientist_bfts.py \
  --load_ideas "$IDEAS_FILE" \
  --idea_idx "$IDEA_IDX" \
  --add_dataset_ref \
  --model_writeup "$MODEL_WRITEUP" \
  --model_citation "$MODEL_CITATION" \
  --model_review "$MODEL_CITATION" \
  --model_agg_plots "o3-mini-2025-01-31" \
  --num_cite_rounds 20

echo ""
echo "✅ Experiment completed for idea #$IDEA_IDX from $IDEAS_FILE"
echo "Results are available in the experiments directory" 