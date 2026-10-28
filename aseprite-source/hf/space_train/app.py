"""One-shot trainer Space. Needs: GPU hardware (T4) and a Space secret HF_TOKEN (write token).

Click "Start training": downloads the private dataset, runs train_lora.py (self-stops at --max-minutes),
uploads the LoRA to a private model repo, then PAUSES this Space so billing stops.
A watchdog also pauses the Space after HARD_CAP_MIN minutes no matter what.
"""
import os, subprocess, sys, threading, time
from pathlib import Path
import gradio as gr
from huggingface_hub import HfApi, snapshot_download

TOKEN = os.environ.get("HF_TOKEN")
SPACE = os.environ.get("SPACE_ID")
DATASET = os.environ.get("DATASET_REPO", "jjman34/asperitegen_gnomeventure")
MODEL = os.environ.get("MODEL_REPO", "jjman34/gnomeventure-lora")
STEPS = os.environ.get("STEPS", "1500")
TRAIN_MIN = int(os.environ.get("TRAIN_MIN", "90"))
HARD_CAP_MIN = int(os.environ.get("HARD_CAP_MIN", "120"))
api = HfApi(token=TOKEN)
LOG = Path("train.log")
started = False

def sync():
    """Push log + whatever LoRA/checkpoints exist to the model repo so nothing is lost when the Space pauses."""
    try:
        api.create_repo(MODEL, private=True, exist_ok=True)
        if LOG.exists(): api.upload_file(path_or_fileobj=str(LOG), path_in_repo="train.log", repo_id=MODEL)
        if Path("gv-lora").exists(): api.upload_folder(folder_path="gv-lora", repo_id=MODEL, repo_type="model")
    except Exception as e:
        LOG.open("a").write(f"sync failed: {e!r}\n")

def syncer():
    while True:
        time.sleep(300); sync()

def pause():
    try: api.pause_space(SPACE)
    except Exception as e: LOG.open("a").write(f"pause failed: {e}\n")

def watchdog():
    time.sleep(HARD_CAP_MIN * 60)
    LOG.open("a").write("HARD CAP: pausing Space\n"); sync(); pause()

def job():
    def w(s): LOG.open("a").write(s + "\n")
    try:
        w("downloading dataset"); data = snapshot_download(DATASET, repo_type="dataset", token=TOKEN, local_dir="ds")
        n = len(list(Path(data).glob("*.png"))); w(f"{n} images")
        p = subprocess.Popen([sys.executable, "train_lora.py", "--data", data, "--out", "gv-lora",
                              "--steps", STEPS, "--max-minutes", str(TRAIN_MIN)],
                             stdout=LOG.open("a"), stderr=subprocess.STDOUT)
        p.wait(); w(f"trainer exit {p.returncode}")
        sync(); w(f"uploaded to {MODEL}")
    except Exception as e:
        w(f"ERROR: {e!r}")
    finally:
        w("pausing Space"); sync(); pause()

def start():
    global started
    if not TOKEN: return "Missing HF_TOKEN secret"
    if started: return "already started"
    started = True
    threading.Thread(target=watchdog, daemon=True).start()
    threading.Thread(target=syncer, daemon=True).start()
    threading.Thread(target=job, daemon=True).start()
    return "started"

def tail():
    return "\n".join(LOG.read_text().splitlines()[-40:]) if LOG.exists() else "(no log yet)"

with gr.Blocks() as ui:
    gr.Markdown("One-shot LoRA trainer. Press Start once.")
    b = gr.Button("Start training", variant="primary")
    s = gr.Textbox(label="Status")
    log = gr.Textbox(label="Log (last 40 lines)", lines=20)
    b.click(start, None, s)
    gr.Timer(5).tick(tail, None, log)
ui.launch()
