#!/bin/bash

# Initial 10 iterations - baseline and early exploration
# Tests simple prompts to identify baseline patterns

RESULTS_DIR="${1:-.}/data/responses"
mkdir -p "$RESULTS_DIR"

run_prompt() {
  local prompt="$1"
  local iteration=$2
  local description=$3

  response=$(curl -s -X POST http://localhost:8000/api/chat \
    -H "Content-Type: application/json" \
    -d "{\"messages\":[{\"role\":\"user\",\"content\":\"$prompt\"}],\"model\":\"phi4-mini:latest\"}")

  echo "$response" | jq . > "$RESULTS_DIR/phi4-iter-$iteration.json"

  # Check for actual tool invocation with results
  has_actual_result=$(echo "$response" | jq -r '.message.content' | grep -q "healthy\|version\|status\|uptime" && echo "1" || echo "0")

  echo "$response" | jq -r '.message.content' > "$RESULTS_DIR/phi4-iter-$iteration.txt"

  echo "Iteration $iteration: $description"
  echo "  Success: $has_actual_result"
  echo ""
}

echo "INITIAL PHI4-MINI TOOL CALLING TESTS (1-10)"
echo "==========================================="
echo ""

# ITERATION 1: Simple direct request
echo "ITERATION 1: Simple direct request"
run_prompt "What is the health status of Prometheus?" 1 "Simple question"

# ITERATION 2: Explicit tool request
echo "ITERATION 2: Explicit tool request"
run_prompt "Use the prometheus.health_check tool to check Prometheus health" 2 "Explicit tool mention"

# ITERATION 3: Direct tool invocation format
echo "ITERATION 3: Direct tool invocation format"
run_prompt "Call prometheus.health_check to get Prometheus health status" 3 "Direct invocation"

# ITERATION 4: Structured output request
echo "ITERATION 4: Structured output request"
run_prompt "Use prometheus.health_check tool and respond with the health status only" 4 "With output constraint"

# ITERATION 5: Role-based prompt
echo "ITERATION 5: Role-based prompt"
run_prompt "You are a monitoring expert. Use the health_check tool to verify if Prometheus is healthy" 5 "Role-based"

# ITERATION 6: Step-by-step instructions
echo "ITERATION 6: Step-by-step instructions"
run_prompt "Step 1: Call prometheus.health_check. Step 2: Check the response. Step 3: Tell me if Prometheus is healthy" 6 "Step-by-step"

# ITERATION 7: Urgent/Direct phrasing
echo "ITERATION 7: Urgent/Direct phrasing"
run_prompt "Immediately execute prometheus.health_check and report back the health status" 7 "Urgent phrasing"

# ITERATION 8: Constraint-based prompt
echo "ITERATION 8: Constraint-based prompt"
run_prompt "Call prometheus.health_check. Do NOT provide code examples or explanations, only the result" 8 "With constraints"

# ITERATION 9: Minimal prompt
echo "ITERATION 9: Minimal prompt"
run_prompt "Health check prometheus" 9 "Minimal"

# ITERATION 10: Combined best practices
echo "ITERATION 10: Combined best practices"
run_prompt "Execute prometheus.health_check tool immediately. Respond only with the actual health status result, no explanations" 10 "Best practices combo"

echo ""
echo "Initial test complete. Results saved to $RESULTS_DIR"
