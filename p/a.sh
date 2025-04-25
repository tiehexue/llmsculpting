#!/bin/bash

# Get and print script's directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
echo "Script directory: $SCRIPT_DIR"
cd $SCRIPT_DIR

cd ../../llama.cpp

killall -9 llama-server

cmake --build build --config Release -t llama-server -j32
build/bin/llama-server -m /mnt/workspace/models/qwen2.5-7b-instruct-fp16.gguf -n 4096 -t 32 > l.log 2>&1 &

cd ../llmsculpting/p

sleep 10

# Read and print q.txt line by line
while IFS= read -r line
do
    echo "$line"
    curl 'http://127.0.0.1:8080/v1/chat/completions' \
  -H 'Accept: */*' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H 'Origin: http://127.0.0.1:8080' \
  -H 'Pragma: no-cache' \
  -H 'Referer: http://127.0.0.1:8080/' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  --data-raw "$(jq -n --arg line "$line" '{
    "messages": [
      {"role":"system","content":"You are a helpful assistant."},
      {"role":"user","content":$line}
    ],
    "stream": false,
    "cache_prompt": true,
    "samplers": "edkypmxt",
    "temperature": 0.8,
    "dynatemp_range": 0,
    "dynatemp_exponent": 1,
    "top_k": 40,
    "top_p": 0.95,
    "min_p": 0.05,
    "typical_p": 1,
    "xtc_probability": 0,
    "xtc_threshold": 0.1,
    "repeat_last_n": 64,
    "repeat_penalty": 1,
    "presence_penalty": 0,
    "frequency_penalty": 0,
    "dry_multiplier": 0,
    "dry_base": 1.75,
    "dry_allowed_length": 2,
    "dry_penalty_last_n": -1,
    "max_tokens": -1,
    "timings_per_token": false
  }')" >> output.txt

  echo >> output.txt

done < "q.txt"

echo >> output.txt
echo >> output.txt
