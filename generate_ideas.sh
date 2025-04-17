#!/bin/bash
# Script to generate ideas from a markdown file

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
  echo "Error: No markdown file specified."
  echo "Usage: ./generate_ideas.sh path/to/your/topic.md [model] [num_generations] [num_reflections]"
  exit 1
fi

# Check if the service is running before proceeding
check_service_status

# Default parameters
MD_FILE=$1
MODEL=${2:-"gpt-4o-2024-05-13"}
MAX_GEN=${3:-20}
NUM_REF=${4:-5}

# Get just the filename without extension
FILENAME=$(basename "$MD_FILE" .md)

# Copy user's markdown file to the mounted volume if not already there
mkdir -p ./ai_scientist/ideas
cp "$MD_FILE" "./ai_scientist/ideas/$FILENAME.md"

# Execute the command in the running container
docker exec ai_scientist_service python ai_scientist/perform_ideation_temp_free.py \
  --workshop-file "ai_scientist/ideas/$FILENAME.md" \
  --model "$MODEL" \
  --max-num-generations "$MAX_GEN" \
  --num-reflections "$NUM_REF"

echo ""
echo "✅ Ideas generated and saved to ai_scientist/ideas/$FILENAME.json"
echo ""
echo "To run experiments with these ideas, use:"
echo "./run_experiment.sh ai_scientist/ideas/$FILENAME.json [idea_index]" 