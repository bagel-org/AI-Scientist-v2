# AI Scientist-v2 Docker Workflow Guide

This guide explains how to use the containerized version of AI Scientist-v2 to generate research ideas and run experiments autonomously.

## 1. Environment Setup

Copy the example environment file and add your API keys:

```bash
# Copy the example file
cp .env.example .env

# Edit the .env file with your API keys
nano .env  # Or use any text editor
```

The `.env` file should contain:
- `OPENAI_API_KEY` (required for OpenAI models)
- `S2_API_KEY` (optional but recommended for literature search)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION_NAME` (only if using Claude models)

## 2. Container Management

Use the Makefile to manage the AI Scientist Docker container:

```bash
# Start the AI Scientist service (builds container if needed)
make start

# Check if the service is running
make status

# Stop the AI Scientist service
make stop

# Restart the service
make restart

# Display help for commands
make help
```

## 3. Research Workflow

### Step 1: Generate Research Ideas

1. Create a markdown file describing your research area (e.g., `my_topic.md`) with sections like `Title`, `Keywords`, `TL;DR`, and `Abstract`. See `ai_scientist/ideas/i_cant_believe_its_not_better.md` for an example.

2. Generate ideas with:

```bash
./generate_ideas.sh path/to/my_topic.md [model] [num_generations] [num_reflections]
```

Parameters:
- `path/to/my_topic.md`: Path to your topic description file
- `model`: LLM to use (default: "gpt-4o-2024-05-13")
- `num_generations`: Number of ideas to generate (default: 20)
- `num_reflections`: Refinement steps per idea (default: 5)

Example:
```bash
./generate_ideas.sh my_topic.md gpt-4o-2024-05-13 15 3
```

Output: `ai_scientist/ideas/my_topic.json` containing generated research ideas

### Step 2: Run Experiments

Run experiments on your generated ideas:

```bash
./run_experiment.sh path/to/ideas.json [idea_index] [writeup_model] [citation_model]
```

Parameters:
- `path/to/ideas.json`: Path to JSON file with generated ideas
- `idea_index`: Index of idea to use (default: 0)
- `writeup_model`: Model for paper writeup (default: "o1-preview-2024-09-12")
- `citation_model`: Model for citations (default: "gpt-4o-2024-11-20")

Example:
```bash
./run_experiment.sh ai_scientist/ideas/my_topic.json 0 o1-preview-2024-09-12 gpt-4o-2024-11-20
```

## 4. Finding Results

After running experiments:
1. Find your results in the `experiments/` directory
2. Each experiment creates a timestamped folder (e.g., `experiments/2023-09-01_12-34-56_MyIdea/`)
3. The tree visualization is at `experiments/timestamp_ideaname/logs/0-run/unified_tree_viz.html`
4. The final paper is in the experiment root directory
