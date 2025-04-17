.PHONY: start stop restart status help

# Start the AI Scientist service
start:
	@echo "Starting AI Scientist service..."
	@docker-compose up -d
	@echo ""
	@echo "✅ AI Scientist service is now running"

# Stop the AI Scientist service
stop:
	@echo "Stopping AI Scientist service..."
	@docker-compose down
	@echo ""
	@echo "✅ AI Scientist service stopped"

# Restart the AI Scientist service
restart: stop start

# Check service status
status:
	@docker ps | grep ai_scientist_service || echo "AI Scientist service is not running"

# Display help
help:
	@echo "AI Scientist Makefile Commands:"
	@echo "-------------------------------"
	@echo "make start      - Start the AI Scientist service"
	@echo "make stop       - Stop the AI Scientist service"
	@echo "make restart    - Restart the AI Scientist service"
	@echo "make status     - Check if the service is running"
