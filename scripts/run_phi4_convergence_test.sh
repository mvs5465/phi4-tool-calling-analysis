#!/bin/bash

# Convergence testing (31-45) - fine-tuning optimal prompt format
# Tests micro-variations on best-performing formulas and repeats for reliability

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

  # Check for actual tool invocation with real results
  has_actual_result=$(echo "$response" | jq -r '.message.content' | grep -q "healthy\|version\|status\|uptime" && echo "1" || echo "0")

  content=$(echo "$response" | jq -r '.message.content')

  echo "[$iteration] $description"
  echo "  Success: $has_actual_result"
  echo "  Preview: ${content:0:100}..."
  echo ""
}

echo "CONVERGENCE TESTING - FINDING OPTIMAL PROMPT (31-45)"
echo "===================================================="
echo ""

# 31-34: Micro-variations on Group A (100% success)
echo "=== GROUP H: Micro-optimize Group A formula (31-34) ==="
run_prompt "Execute prometheus.health_check immediately. Return only the result" 31 "H1: Swap 'respond with' to 'Return'"
run_prompt "Call prometheus.health_check now. Result only" 32 "H2: Shorten to 'Call' + 'now' + 'Result only'"
run_prompt "Execute prometheus.health_check. Only the result" 33 "H3: Drop 'immediately', use 'Only the result'"
run_prompt "Execute prometheus.health_check immediately. Status only" 34 "H4: Replace 'result' with 'status'"

# 35-37: Micro-variations on Group C (100% success)
echo ""
echo "=== GROUP I: Micro-optimize Group C formula (35-37) ==="
run_prompt "You have access to prometheus.health_check. Execute now. Report only the result" 35 "I1: Add 'Report only the result'"
run_prompt "I need prometheus status. Use prometheus.health_check immediately. Results only" 36 "I2: Combine need framing + immediate + results only"
run_prompt "Access prometheus.health_check. Execute. Return status only" 37 "I3: Ultra-short context version"

# 38-41: Hybrid approaches combining A + C + F
echo ""
echo "=== GROUP J: Hybrid best practices (38-41) ==="
run_prompt "You have prometheus.health_check. Execute immediately. Only return status" 38 "J1: Access + execute + constraint"
run_prompt "Execute prometheus.health_check immediately. Return status only" 39 "J2: Action + constraint (simpler hybrid)"
run_prompt "You have access. Execute prometheus.health_check immediately. Status only" 40 "J3: Explicit access statement"
run_prompt "Execute prometheus.health_check NOW. Only status. No explanation" 41 "J4: ALL CAPS NOW + explicit no explanation"

# 42-45: Stress test the winner (repeat best formula 4 times)
echo ""
echo "=== GROUP K: Stress test - repeat best formula (42-45) ==="
run_prompt "Execute prometheus.health_check immediately. Return only the result" 42 "K1: Best formula (repeat 1)"
run_prompt "Execute prometheus.health_check immediately. Return only the result" 43 "K2: Best formula (repeat 2)"
run_prompt "Execute prometheus.health_check immediately. Return only the result" 44 "K3: Best formula (repeat 3)"
run_prompt "Execute prometheus.health_check immediately. Return only the result" 45 "K4: Best formula (repeat 4)"

echo ""
echo "Convergence testing complete (31-45). Results saved to $RESULTS_DIR"
