#!/usr/bin/env python3
"""LoRA fine-tune on the gvstyle dataset. Run on the HF GPU (T4), NOT locally.

Wraps diffusers' official train_dreambooth_lora example:
  pip install diffusers transformers accelerate peft datasets bitsandbytes
  python3 train_lora.py --data ./ds --out ./gv-lora [--steps 1500]

Base model is SD 1.5-class so it fits 16 GB (T4). Images are 512x512 (64px art x8 on magenta).
Steps: 1295 images x ~1 epoch ~ 1300 steps at batch 1; 1500 default. Checkpoints every 500.
HARD COST GUARD: stops itself after --max-minutes (default 90) so a T4 can't bill past ~$1 here.
"""
import argparse, subprocess, sys, time, urllib.request
from pathlib import Path

EXAMPLE = "https://raw.githubusercontent.com/huggingface/diffusers/main/examples/text_to_image/train_text_to_image_lora.py"
BASE = "stable-diffusion-v1-5/stable-diffusion-v1-5"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--out", default="gv-lora")
    ap.add_argument("--steps", type=int, default=1500)
    ap.add_argument("--base", default=BASE)
    ap.add_argument("--max-minutes", type=int, default=90)
    a = ap.parse_args()
    script = Path("train_text_to_image_lora.py")
    if not script.exists():
        urllib.request.urlretrieve(EXAMPLE, script)
    cmd = [sys.executable, "-m", "accelerate.commands.launch", str(script),
           f"--pretrained_model_name_or_path={a.base}", f"--train_data_dir={a.data}",
           "--caption_column=text", "--resolution=512", "--center_crop",
           "--train_batch_size=1", "--gradient_accumulation_steps=4", "--gradient_checkpointing",
           f"--max_train_steps={a.steps}", "--learning_rate=1e-4", "--lr_scheduler=cosine",
           "--lr_warmup_steps=50", "--rank=16", "--mixed_precision=fp16", "--seed=7",
           f"--output_dir={a.out}", "--checkpointing_steps=500"]
    print(" ".join(cmd), flush=True)
    p = subprocess.Popen(cmd); t0 = time.time()
    while p.poll() is None:
        if time.time() - t0 > a.max_minutes * 60:
            p.terminate(); print("TIME CAP HIT: stopped training; use the last checkpoint in", a.out); break
        time.sleep(10)
    print("exit", p.returncode, "minutes", round((time.time() - t0) / 60, 1))

if __name__ == "__main__":
    main()
