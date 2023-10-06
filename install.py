from dotenv import dotenv_values, set_key
from getpass import getpass

# Load existing .env if it exists
env_file_path = ".env"
env_data = dotenv_values(dotenv_path=env_file_path)

def get_input_for_key(key):
    return getpass(f"Enter your {key}: ")

# Collect new values
keys = ["HUGGINGFACE_API_KEY", "OPENAI_API_KEY", "ANTHROPIC_API_KEY"]
for key in keys:
    if key == "DOCKER_BUILDKIT":
        set_key(env_file_path, key, "")
    new_value = get_input_for_key(key)
    set_key(env_file_path, key, new_value)

run_sh="""
#! /bin/bash
sudo docker run --rm -it -v $(pwd):/app/server -p 8888:8888 python:3.8-slim bash
"""
run_path = "run.sh"

build_sh = """
# build.sh
#!/bin/bash

# Export variables from .env to the shell
export $(grep -v '^#' .env | xargs)

# Build Docker image
docker build --build-arg $HUGGINGFACE_API_KEY --build-arg $OPENAI_API_KEY --build-arg $ANTHROPIC_API_KEY -t .

print("Configuration saved to .env")
"""
build_path = "build.sh"

def write_scripts(script, file_path):
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(script)

    if file_path.is_file() or file_path.is_dir():
        file_path.chmod(0o777)

print("Building build and run script")

write_scripts(build_sh, build_path)

write_scripts(run_sh, run_path)

print("Build Docker image")
