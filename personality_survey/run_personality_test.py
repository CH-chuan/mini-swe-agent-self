import argparse
import json
import os
import csv
try:
    import litellm
except ImportError:
    litellm = None
from tqdm import tqdm
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def load_trajectory(trajectory_path):
    """Loads the trajectory JSON file."""
    with open(trajectory_path, 'r') as f:
        return json.load(f)

def load_inventory(inventory_path):
    """Loads the inventory CSV file."""
    inventory = []
    with open(inventory_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            inventory.append(row)
    return inventory

def get_contexts(trajectory):
    """Extracts the three contexts from the trajectory as lists of messages."""
    messages = trajectory.get('messages', [])
    if not messages:
        logger.warning("No messages found in trajectory.")
        return [], [], []

    # Condition 1: System Prompt Only
    # Find the first system message
    system_msg = next((m for m in messages if m['role'] == 'system'), None)
    messages_system = [system_msg] if system_msg else []

    # Condition 2: System + Task (First User Message)
    # Assuming the task is the first user message after the system prompt
    messages_system_task = []
    system_found = False
    user_found = False
    
    temp_messages = []
    for m in messages:
        if m['role'] == 'system' and not system_found:
            temp_messages.append(m)
            system_found = True
        elif m['role'] == 'user' and not user_found:
            temp_messages.append(m)
            user_found = True
        
        if system_found and user_found:
            break
    
    # If we didn't find both, we might just take the first 2 messages if they exist
    if not (system_found and user_found):
        # Fallback: just take first 2
        temp_messages = messages[:2]
    
    messages_system_task = temp_messages

    # Condition 3: Full History
    messages_full = messages

    return messages_system, messages_system_task, messages_full

def query_model(model_name, api_base, messages, dry_run=False):
    """Queries the model using litellm."""
    if dry_run:
        logger.info(f"Dry run: Skipping model query. Messages length: {len(messages)}")
        return "MOCK_RESPONSE_A"

    if litellm is None:
        logger.error("litellm module not found. Please install it to run the test.")
        raise ImportError("litellm module not found")

    # Configure litellm
    if api_base:
        litellm.api_base = api_base
    
    try:
        response = litellm.completion(
            model=model_name,
            messages=messages,
            temperature=0.0, # Deterministic for testing
            max_tokens=100 # Short answer expected (A-E)
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f"Error querying model: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Run personality test on agent.")
    parser.add_argument("--trajectory_path", required=True, help="Path to the trajectory JSON file.")
    parser.add_argument("--inventory_path", required=True, help="Path to the inventory CSV file.")
    parser.add_argument("--output_dir", required=True, help="Path to save the results.")
    parser.add_argument("--item_template_path", required=True, help="Path to the item template file.")
    parser.add_argument("--api_base", default="http://localhost:8000/v1", help="Base URL for VLLM.")
    parser.add_argument("--model_name", default="hosted_vllm/Qwen3-Coder", help="Model name to query.")
    parser.add_argument("--dry_run", action="store_true", help="Run without querying the model (for testing).")
    
    args = parser.parse_args()

    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)

    # Load data
    logger.info("Loading data...")
    trajectory = load_trajectory(args.trajectory_path)
    inventory = load_inventory(args.inventory_path)
    
    with open(args.item_template_path, 'r') as f:
        item_template_content = f.read()

    # Extract contexts
    messages_system, messages_system_task, messages_full = get_contexts(trajectory)
    
    results = []

    # Condition 1: System Only
    logger.info("Running Condition 1: System Only...")
    results_system = []
    for row in tqdm(inventory, desc="System Only"):
        item_text = row['text']
        question = item_template_content.format(item_text.lower())
        
        question_message = {"role": "user", "content": question}
        current_messages = messages_system + [question_message]
        response_system = query_model(args.model_name, args.api_base, current_messages, args.dry_run)
        
        results_system.append({
            "item_text": item_text,
            "label_ocean": row['label_ocean'],
            "key": row['key'],
            # "question_message": question_message,
            "response": response_system,
        })
    
    output_file_system = os.path.join(args.output_dir, "personality_test_results_system.json")
    with open(output_file_system, 'w') as f:
        json.dump(results_system, f, indent=2)
    logger.info(f"Results for System Only saved to {output_file_system}")

    # Condition 2: System + Task
    logger.info("Running Condition 2: System + Task...")
    results_task = []
    for row in tqdm(inventory, desc="System + Task"):
        item_text = row['text']
        question = item_template_content.format(item_text.lower())
        
        question_message = {"role": "user", "content": question}
        current_messages = messages_system_task + [question_message]
        response_task = query_model(args.model_name, args.api_base, current_messages, args.dry_run)

        results_task.append({
            "item_text": item_text,
            "label_ocean": row['label_ocean'],
            "key": row['key'],
            # "question_message": question_message,
            "response": response_task,
        })

    output_file_task = os.path.join(args.output_dir, "personality_test_results_task.json")
    with open(output_file_task, 'w') as f:
        json.dump(results_task, f, indent=2)
    logger.info(f"Results for System + Task saved to {output_file_task}")

    # Condition 3: Full History
    logger.info("Running Condition 3: Full History...")
    results_full = []
    for row in tqdm(inventory, desc="Full History"):
        item_text = row['text']
        question = item_template_content.format(item_text.lower())
        
        question_message = {"role": "user", "content": question}
        current_messages = messages_full + [question_message]
        response_full = query_model(args.model_name, args.api_base, current_messages, args.dry_run)

        results_full.append({
            "item_text": item_text,
            "label_ocean": row['label_ocean'],
            "key": row['key'],
            # "question_message": question_message,
            "response": response_full,
        })

    output_file_full = os.path.join(args.output_dir, "personality_test_results_full.json")
    with open(output_file_full, 'w') as f:
        json.dump(results_full, f, indent=2)
    logger.info(f"Results for Full History saved to {output_file_full}")

if __name__ == "__main__":
    main()
