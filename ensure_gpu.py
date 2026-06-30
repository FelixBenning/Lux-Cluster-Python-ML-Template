import os
import torch

print(f"SLURM_JOB_GPUS: {os.environ.get("SLURM_JOB_GPUS")}")  
# if this does not return anything, try the shell command
# nvidia-smi -L

print(f"torch.version.cuda={torch.version.cuda}") # None implies CPU version
print(f"torch cuda available: {torch.cuda.is_available()}")
print(f"torch.cuda.device_count()={torch.cuda.device_count()}")
