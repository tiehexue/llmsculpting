#!/bin/bash

# Process each line of input
while IFS= read -r line
do
    # Extract content and convert newlines
    echo "$line" | jq -r '.choices[0].message.content' | sed 's/\\n/\n/g' >> processed_output.txt
    echo "" >> processed_output.txt  # Add blank line between entries
    echo "" >> processed_output.txt
    echo "" >> processed_output.txt
done < "output.txt"

echo "Processing complete. Results saved to p/processed_output.txt"
