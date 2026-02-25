#!/bin/bash

# Extended 20 iterations (11-30) - systematic exploration
# Tests variations in parameter handling, context, edge cases, different tools

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

echo "EXTENDED PHI4 TESTING (11-30)"
echo "============================="
echo ""

# 11-13: Test reliability of iteration 10 formula with variations
echo "=== GROUP A: Variation on successful formula (11-13) ==="
run_prompt "Execute prometheus.health_check immediately and respond with only the result" 11 "A1: Swap 'respond with' vs 'no explanations'"
run_prompt "Run prometheus.health_check now. Return only the status data" 12 "A2: Use 'run' instead of 'execute'"
run_prompt "Call prometheus.health_check without any explanations. Show me the result only" 13 "A3: Explicit 'without explanations'"

# 14-17: Parameter variations
echo ""
echo "=== GROUP B: Parameter variations (14-17) ==="
run_prompt "Execute prometheus.health_check with no parameters and respond with status only" 14 "B1: Explicitly state 'no parameters'"
run_prompt "Call prometheus.health_check(). Return status" 15 "B2: Function syntax with parentheses"
run_prompt "prometheus.health_check - execute now, results only" 16 "B3: Minimal punctuation"
run_prompt "Execute prometheus.health_check. Only return the health status value" 17 "B4: 'only return the value'"

# 18-20: Context/framing
echo ""
echo "=== GROUP C: Context framing (18-20) ==="
run_prompt "You have access to prometheus.health_check. Use it now and report status" 18 "C1: Frame with access"
run_prompt "I need the Prometheus health status. Use prometheus.health_check tool immediately" 19 "C2: User need framing"
run_prompt "Execute the prometheus.health_check MCP tool. Return only actual results" 20 "C3: Mention MCP explicitly"

# 21-23: Edge cases
echo ""
echo "=== GROUP D: Edge cases (21-23) ==="
run_prompt "prometheus.health_check prometheus.health_check" 21 "D1: Repeat tool name"
run_prompt "Use this tool: prometheus.health_check. Execute now." 22 "D2: Explicit 'use this tool'"
run_prompt "Answer the question using prometheus.health_check: Is Prometheus healthy?" 23 "D3: Question format with tool mention"

# 24-26: Tool alternatives
echo ""
echo "=== GROUP E: Different tools (24-26) ==="
run_prompt "Execute prometheus.list_metrics immediately and respond with results only" 24 "E1: Try list_metrics"
run_prompt "Call prometheus.get_targets now and return the output" 25 "E2: Try get_targets"
run_prompt "Use prometheus.execute_query with query='up' and return results" 26 "E3: Try execute_query"

# 27-29: Aggressive constraints
echo ""
echo "=== GROUP F: Aggressive constraints (27-29) ==="
run_prompt "EXECUTE prometheus.health_check NOW. ONLY JSON OUTPUT. NO TEXT" 27 "F1: ALL CAPS + JSON only"
run_prompt "prometheus.health_check. That's it. Execute." 28 "F2: Ultra minimal"
run_prompt "Tool: prometheus.health_check. Mode: execute. Format: result only" 29 "F3: Structured format"

# 30: Meta approach
echo ""
echo "=== GROUP G: Meta approach (30) ==="
run_prompt "Call prometheus.health_check. Respond with the raw tool output in a single line" 30 "G1: Ask for raw output"

echo ""
echo "Extended testing complete (11-30). Results saved to $RESULTS_DIR"
