import torch
import os
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import get_peft_model, LoraConfig, TaskType, PeftModel

torch.cuda.empty_cache()

device = torch.device("cuda")
print(f"GPU: {torch.cuda.get_device_name(0)}")

model_name = "microsoft/phi-2"
tokenizer = AutoTokenizer.from_pretrained(model_name)

if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

def load_or_create_lora_model():
    print("Loading base model...")
    base_model = AutoModelForCausalLM.from_pretrained(
        model_name,
        # torch_dtype=torch.float16,
        device_map='auto',
    )
    
    peft_config = LoraConfig(
        task_type=TaskType.CAUSAL_LM,
        r=8,
        lora_alpha=32,
        lora_dropout=0.1,
        target_modules=["dense", "dense_h_to_4h", "dense_4h_to_h"]
    )
    
    if os.path.exists("./lora_weights"):
        print("Loading existing LoRA weights...")
        lora_model = PeftModel.from_pretrained(base_model, "./lora_weights", is_trainable=True)
    else:
        print("Creating new LoRA model...")
        lora_model = get_peft_model(base_model, peft_config)
    
    # Ensure LoRA parameters are trainable and in float32
    # for name, param in lora_model.named_parameters():
    #     if 'lora' in name:
    #         param.requires_grad = True
    #         param.data = param.data.float()
    
    return lora_model.to(device)

lora_model = load_or_create_lora_model()
lora_model.print_trainable_parameters()  # This will show which parameters are trainable

optimizer = torch.optim.AdamW(lora_model.parameters(), lr=1e-4)

def fine_tune_lora(prompt, response):
    lora_model.train()
    
    full_text = f"{prompt} {tokenizer.eos_token} {response}"
    inputs = tokenizer(full_text, return_tensors="pt", truncation=True, padding="max_length", max_length=512)
    inputs = {k: v.to(device) for k, v in inputs.items()}
    
    optimizer.zero_grad()
    outputs = lora_model(**inputs, labels=inputs["input_ids"])
    loss = outputs.loss
    loss.backward()
    optimizer.step()
    
    print(f"Training loss: {loss.item()}")

def generate_response(prompt):
    lora_model.eval()
    inputs = tokenizer(prompt, return_tensors="pt", padding=True, truncation=True, max_length=512).to(device)
    with torch.no_grad():
        outputs = lora_model.generate(**inputs, max_length=100, pad_token_id=tokenizer.eos_token_id)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# Main loop
interaction_count = 0
save_interval = 5

while True:
    user_input = input("You: ")
    if user_input.lower() == "quit":
        break
    
    response = generate_response(user_input)
    print(f"AI: {response}")
    
    fine_tune_lora(user_input, response)
    
    interaction_count += 1
    if interaction_count % save_interval == 0:
        lora_model.save_pretrained("./lora_weights")
        print("LoRA weights saved.")

lora_model.save_pretrained("./lora_weights")
print("Final LoRA weights saved. Goodbye!")
