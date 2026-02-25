#!/bin/bash

# Analyze test results and generate summary statistics

RESULTS_DIR="${1:-.}/data/responses"

echo "=== ANALYSIS OF PHI4-MINI TOOL CALLING TESTS ==="
echo ""

count_group_success() {
  local start=$1
  local end=$2
  local name=$3

  success=0
  total=0

  for i in $(seq $start $end); do
    if [ -f "$RESULTS_DIR/phi4-iter-$i.json" ]; then
      result=$(jq -r '.message.content' "$RESULTS_DIR/phi4-iter-$i.json" | grep -q "healthy\|version\|status\|uptime" && echo "1" || echo "0")
      success=$((success + result))
      total=$((total + 1))
    fi
  done

  if [ $total -gt 0 ]; then
    percent=$((success * 100 / total))
    echo "$name: $success/$total (${percent}%)"
  fi
}

echo "SUCCESS RATES BY GROUP:"
echo "======================"
count_group_success 1 3 "Baseline (1-3)"
count_group_success 4 10 "Initial exploration (4-10)"
count_group_success 11 13 "Group A: Formula variations (11-13)"
count_group_success 14 17 "Group B: Parameter variations (14-17)"
count_group_success 18 20 "Group C: Context framing (18-20)"
count_group_success 21 23 "Group D: Edge cases (21-23)"
count_group_success 24 26 "Group E: Different tools (24-26)"
count_group_success 27 29 "Group F: Aggressive constraints (27-29)"
count_group_success 30 30 "Group G: Meta approach (30)"
count_group_success 31 34 "Group H: A micro-variations (31-34)"
count_group_success 35 37 "Group I: C micro-variations (35-37)"
count_group_success 38 41 "Group J: Hybrid approaches (38-41)"
count_group_success 42 45 "Group K: Stress test (42-45)"

echo ""
echo "OVERALL:"
success_total=0
total_tests=0
for i in $(seq 1 45); do
  if [ -f "$RESULTS_DIR/phi4-iter-$i.json" ]; then
    result=$(jq -r '.message.content' "$RESULTS_DIR/phi4-iter-$i.json" | grep -q "healthy\|version\|status\|uptime" && echo "1" || echo "0")
    success_total=$((success_total + result))
    total_tests=$((total_tests + 1))
  fi
done
overall_percent=$((success_total * 100 / total_tests))
echo "Total: $success_total/$total_tests (${overall_percent}%)"

echo ""
echo "FAILED ITERATIONS:"
echo "=================="
for i in $(seq 1 45); do
  if [ -f "$RESULTS_DIR/phi4-iter-$i.json" ]; then
    result=$(jq -r '.message.content' "$RESULTS_DIR/phi4-iter-$i.json" | grep -q "healthy\|version\|status\|uptime" && echo "1" || echo "0")
    if [ "$result" = "0" ]; then
      echo "  Iteration $i"
    fi
  fi
done

echo ""
echo "RESPONSE TIME ANALYSIS (fastest to slowest):"
echo "============================================"
echo "Sample response times (from select iterations):"
for i in 10 20 30 35 40 45; do
  if [ -f "$RESULTS_DIR/phi4-iter-$i.json" ]; then
    duration=$(jq -r '.total_duration' "$RESULTS_DIR/phi4-iter-$i.json" | awk '{printf "%.2f", $1/1000000000}')
    echo "  Iteration $i: ${duration}s"
  fi
done
