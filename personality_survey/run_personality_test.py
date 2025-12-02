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
import concurrent.futures

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
    
    parser.add_argument("--resume", action="store_true", help="Resume from existing output files.")
    parser.add_argument("--dimensions", default="OCEAN", help="Dimensions to run (e.g., 'O' for Openness, 'OC' for Openness and Conscientiousness).")
    parser.add_argument("--max_workers", type=int, default=1, help="Maximum number of concurrent workers.")
    
    args = parser.parse_args()

    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)

    # Load data
    logger.info("Loading data...")
    trajectory = load_trajectory(args.trajectory_path)
    inventory = load_inventory(args.inventory_path)
    
    # Filter inventory by dimensions
    allowed_dimensions = set(args.dimensions.upper())
    inventory = [item for item in inventory if item['label_ocean'] in allowed_dimensions]
    logger.info(f"Filtered inventory to {len(inventory)} items with dimensions: {args.dimensions}")

    with open(args.item_template_path, 'r') as f:
        item_template_content = f.read()

    # Extract contexts
    messages_system, messages_system_task, messages_full = get_contexts(trajectory)
    
    def run_condition(condition_name, messages_context, output_filename_base):
        logger.info(f"Running Condition: {condition_name}...")
        
        jsonl_filename = f"{output_filename_base}.jsonl"
        json_filename = f"{output_filename_base}.json"
        
        output_path_jsonl = os.path.join(args.output_dir, jsonl_filename)
        output_path_json = os.path.join(args.output_dir, json_filename)
        
        current_results = []
        processed_keys = set()

        # Check for existing JSONL
        if os.path.exists(output_path_jsonl):
             logger.info(f"Resuming {condition_name} from {jsonl_filename}...")
             with open(output_path_jsonl, 'r') as f:
                for line in f:
                    try:
                        item = json.loads(line)
                        current_results.append(item)
                        processed_keys.add(item['key'])
                    except json.JSONDecodeError:
                        continue
        # Check for existing JSON and convert if JSONL doesn't exist
        elif os.path.exists(output_path_json):
            logger.info(f"Found existing JSON file {json_filename}. Converting to JSONL...")
            try:
                with open(output_path_json, 'r') as f:
                    data = json.load(f)
                    for item in data:
                        current_results.append(item)
                        processed_keys.add(item['key'])
                
                # Write converted data to JSONL
                with open(output_path_jsonl, 'w') as f:
                    for item in current_results:
                        f.write(json.dumps(item) + "\n")
                logger.info(f"Conversion complete. Created {jsonl_filename}.")
            except json.JSONDecodeError:
                 logger.warning(f"Could not parse existing JSON file {output_path_json}. Starting fresh.")

        items_to_process = [row for row in inventory if row['key'] not in processed_keys]
        
        if not items_to_process:
            logger.info(f"All items for {condition_name} already processed.")
            return

        # Open file in append mode
        with open(output_path_jsonl, 'a') as f_out:
            with concurrent.futures.ThreadPoolExecutor(max_workers=args.max_workers) as executor:
                future_to_item = {}
                for row in items_to_process:
                    item_text = row['text']
                    question = item_template_content.format(item_text.lower())
                    
                    question_message = {"role": "user", "content": question}
                    current_messages = messages_context + [question_message]
                    
                    future = executor.submit(query_model, args.model_name, args.api_base, current_messages, args.dry_run)
                    future_to_item[future] = row

                for future in tqdm(concurrent.futures.as_completed(future_to_item), total=len(items_to_process), desc=condition_name):
                    row = future_to_item[future]
                    try:
                        response = future.result()
                        result_item = {
                            "item_text": row['text'],
                            "label_ocean": row['label_ocean'],
                            "key": row['key'],
                            # "question_message": question_message, # Not saving this to save space
                            "response": response,
                        }
                        f_out.write(json.dumps(result_item) + "\n")
                        f_out.flush()
                    except Exception as e:
                        logger.error(f"Error processing item {row['key']}: {e}")
        
        logger.info(f"Results for {condition_name} saved to {output_path_jsonl}")

    # Condition 1: System Only
    run_condition("System Only", messages_system, "personality_test_results_system")

    # Condition 2: System + Task
    run_condition("System + Task", messages_system_task, "personality_test_results_task")

    # Condition 3: Full History
    run_condition("Full History", messages_full, "personality_test_results_full")

if __name__ == "__main__":
    main()
