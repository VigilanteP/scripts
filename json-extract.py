#!/usr/bin/python3
import sys
import json
import re

# Regular expression to capture JSON objects in the log stream
json_pattern = re.compile(r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}')


def extract_and_print_json(log_stream):
    for line in log_stream:
        matches = json_pattern.findall(line)
        for match in matches:
            try:
                json_object = json.loads(match)
                formatted_json = json.dumps(json_object, indent=4)
                print(formatted_json)
                print()  # Newline for readability
            except json.JSONDecodeError:
                continue


if __name__ == "__main__":
    extract_and_print_json(sys.stdin)
