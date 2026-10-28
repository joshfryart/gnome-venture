#!/usr/bin/env python3
"""Gradio front end: dropdowns + list upload -> LoRA generations -> postfx -> contact sheet.

Runs on a ZeroGPU Space (private). Needs the Space secret HF_TOKEN (read access to the private LoRA repo).
Env overrides: LORA_REPO, LORA_SUBFOLDER.
List format (upload .txt or paste): one per line, `kind: description`, or just `description`.
"""
import json, os, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
import gradio as gr
import postfx
from PIL import Image

try:
    import spaces
    gpu = spaces.GPU(duration=120)
except ImportError:                       # local run
    gpu = lambda f: f

KINDS = ["item", "seed", "icon"]
TAG = "gvstyle pixel art sticker"
BASE = "stable-diffusion-v1-5/stable-diffusion-v1-5"
LORA_REPO = os.environ.get("LORA_REPO", "jjman34/gnomeventure-lora")
LORA_SUB = os.environ.get("LORA_SUBFOLDER", "checkpoint-1500")
TOKEN = os.environ.get("HF_TOKEN")
PAL = [tuple(c) for c in json.loads(Path(__file__).with_name("palette.json").read_text())]

import torch
from diffusers import StableDiffusionPipeline
dev = "cuda" if torch.cuda.is_available() else "cpu"
pipe = StableDiffusionPipeline.from_pretrained(
    BASE, torch_dtype=torch.float16 if dev == "cuda" else torch.float32, safety_checker=None)
pipe.load_lora_weights(LORA_REPO, subfolder=LORA_SUB,
                       weight_name="pytorch_lora_weights.safetensors", token=TOKEN)
pipe.to(dev)

def parse(text, default_kind):
    out = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"): continue
        k, _, d = line.partition(":")
        out.append((k.strip(), d.strip()) if d and k.strip() in KINDS else (default_kind, line))
    return out

@gpu
def render(jobs, count, seed, steps, cfg):
    sheet = []
    for ji, (k, d) in enumerate(jobs):
        prompt = f"{TAG}, {k}, {d}, flat magenta background"
        for i in range(int(count)):
            g = torch.Generator(pipe.device).manual_seed(int(seed) + ji * 1000 + i)
            img = pipe(prompt, num_inference_steps=int(steps), guidance_scale=cfg,
                       generator=g, height=512, width=512).images[0]
            sheet.append((postfx.run(img, PAL), f"{d[:40]} #{i}"))
    return sheet

def run(text, file, kind, count, seed, steps, cfg):
    if file: text = Path(file).read_text(encoding="utf-8")
    jobs = parse(text or "", kind)[:6]          # cap lines per click: ZeroGPU calls are short
    if not jobs: return [], "no lines", []
    sheet = render(jobs, min(int(count), 6), seed, steps, cfg)
    return ([(im.resize((256, 256), Image.NEAREST), cap) for im, cap in sheet],
            f"{len(sheet)} images", sheet)

out = Path("accepted"); out.mkdir(exist_ok=True)
with gr.Blocks(title="Gnome Venture first pass") as ui:
    with gr.Row():
        kind = gr.Dropdown(KINDS, value="item", label="Default kind")
        count = gr.Slider(1, 6, 4, step=1, label="Variants per line")
        seed = gr.Number(7, label="Seed", precision=0)
        steps = gr.Slider(10, 40, 25, step=1, label="Steps")
        cfg = gr.Slider(1, 12, 7, step=0.5, label="Guidance")
    text = gr.Textbox(lines=6, label="List (kind: description, one per line; max 6 lines per click)")
    file = gr.File(label="or upload .txt", type="filepath")
    go = gr.Button("Generate", variant="primary")
    gal = gr.Gallery(label="Contact sheet (tap one to select, then Download)", columns=4, object_fit="contain")
    status = gr.Textbox(label="Status", interactive=False)
    state = gr.State([]); sel = gr.State(None)
    go.click(run, [text, file, kind, count, seed, steps, cfg], [gal, status, state])
    def on_select(ev: gr.SelectData): return ev.index
    gal.select(on_select, None, sel)
    name = gr.Textbox(label="Save selected as (slug)")
    dl = gr.File(label="Download")
    def accept(sheet, i, slug):
        if i is None or not slug: return None
        p = out / f"{slug}.png"; sheet[i][0].save(p); return str(p)
    gr.Button("Save selected").click(accept, [state, sel, name], dl)
ui.launch()
