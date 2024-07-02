import os
import time
from datetime import datetime, timedelta
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import get_peft_model, LoraConfig, TaskType

# Configuration
MODEL_NAME = "path_to_your_model"  # Local path or Hugging Face model ID
SAVE_DIR = "lora_checkpoints"
SAVE_INTERVAL = 300  # 5 minutes in seconds

# Ensure save directory exists
os.makedirs(SAVE_DIR, exist_ok=True)

# Load model and tokenizer
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

# LoRA Configuration
lora_config = LoraConfig(
    task_type=TaskType.CAUSAL_LM,
    r=8,
    lora_alpha=32,
    lora_dropout=0.1,
    target_modules=["q_proj", "v_proj"]  # Adjust based on your model architecture
)

# Apply LoRA to the model
model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

# Optimizer - only optimize LoRA parameters
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-4)

# Timing variables
last_save_time = time.time()
last_hourly_save = datetime.now()
last_daily_save = datetime.now()

def generate_response(prompt):
    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
    with torch.no_grad():
        outputs = model.generate(**inputs, max_new_tokens=50)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

def update_lora(prompt, response):
    inputs = tokenizer(prompt + response, return_tensors="pt").to(model.device)
    labels = inputs.input_ids.clone()
    
    outputs = model(input_ids=inputs.input_ids, labels=labels)
    loss = outputs.loss
    loss.backward()
    
    optimizer.step()
    optimizer.zero_grad()

def save_lora(save_type):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"lora_{save_type}_{timestamp}"
    path = os.path.join(SAVE_DIR, filename)
    model.save_pretrained(path)
    print(f"LoRA weights saved: {path}")

def manage_checkpoints():
    for save_type in ["periodic", "hourly", "daily"]:
        dirs = sorted(glob.glob(os.path.join(SAVE_DIR, f"lora_{save_type}_*")))
        if save_type == "periodic":
            for dir in dirs[:-5]:  # Keep last 5
                os.system(f"rm -rf {dir}")
        elif save_type == "hourly":
            for dir in dirs[:-2]:  # Keep last 2
                os.system(f"rm -rf {dir}")
        elif save_type == "daily":
            for dir in dirs[:-1]:  # Keep last 1
                os.system(f"rm -rf {dir}")

def check_and_save():
    global last_save_time, last_hourly_save, last_daily_save
    current_time = datetime.now()

    if time.time() - last_save_time > SAVE_INTERVAL:
        save_lora("periodic")
        last_save_time = time.time()

    if current_time - last_hourly_save > timedelta(hours=1):
        save_lora("hourly")
        last_hourly_save = current_time

    if current_time - last_daily_save > timedelta(days=1):
        save_lora("daily")
        last_daily_save = current_time

    manage_checkpoints()

# Main loop
print("Continuous Learning Chat Bot with LoRA (type 'quit' to exit)")
while True:
    user_input = input("You: ")
    if user_input.lower() == "quit":
        break
    
    response = generate_response(user_input)
    print("AI:", response)
    
    update_lora(user_input, response)
    check_and_save()

print("Exiting and saving final LoRA weights...")
save_lora("final")
