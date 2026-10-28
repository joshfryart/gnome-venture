#!/usr/bin/env python3
"""Gradio front end: dropdowns + list upload -> LoRA generations -> postfx -> contact sheet.

  pip install gradio diffusers transformers accelerate peft pillow torch
  python3 app.py --lora ./gv-lora          (on the HF Space, set LORA_DIR env var)

Input list (upload or paste): one per line, `kind: description`, or `description` alone.
Everything runs offline once the base model is cached; pause the Space when idle (it bills per hour).
"""
import argparse, json, os, random, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
import postfx
from PIL import Image

KINDS = ["item", "seed", "icon"]
TAG = "gvstyle pixel art sticker"
PAL = [tuple(c) for c in json.loads(Path(__file__).with_name("palette.json").read_text())]
_pipe = None

def pipe(lora):
    global _pipe
    if _pipe is None:
        import torch
        from diffusers import StableDiffusionPipeline
        dev = "cuda" if torch.cuda.is_available() else "cpu"
        p = StableDiffusionPipeline.from_pretrained("stable-diffusion-v1-5/stable-diffusion-v1-5",
            torch_dtype=torch.float16 if dev == "cuda" else torch.float32, safety_checker=None).to(dev)
        p.load_lora_weights(lora)
        _pipe = p
    return _pipe

def parse(text, default_kind):
    out = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"): continue
        k, _, d = line.partition(":")
        out.append((k.strip(), d.strip()) if d and k.strip() in KINDS else (default_kind, line))
    return out

def generate(lora, text, file, kind, count, seed, steps, cfg):
    if file: text = Path(file).read_text(encoding="utf-8")
    jobs = parse(text, kind)
    if not jobs: return [], "no lines"
    import torch
    p = pipe(lora); sheet = []
    for ji, (k, d) in enumerate(jobs):
        prompt = f"{TAG}, {k}, {d}, flat magenta background"
        for i in range(int(count)):
            g = torch.Generator(p.device).manual_seed(int(seed) + ji * 1000 + i)
            img = p(prompt, num_inference_steps=int(steps), guidance_scale=cfg, generator=g,
                    height=512, width=512).images[0]
            sheet.append((postfx.run(img, PAL), f"{d[:40]} #{i}"))
    return sheet, f"{len(sheet)} images"

def main():
    import gradio as gr
    ap = argparse.ArgumentParser(); ap.add_argument("--lora", default=os.environ.get("LORA_DIR", "gv-lora"))
    a = ap.parse_args()
    out = Path("accepted"); out.mkdir(exist_ok=True)
    with gr.Blocks(title="Gnome Venture first pass") as ui:
        with gr.Row():
            kind = gr.Dropdown(KINDS, value="item", label="Default kind")
            count = gr.Slider(1, 12, 4, step=1, label="Variants per line")
            seed = gr.Number(7, label="Seed", precision=0)
            steps = gr.Slider(10, 40, 25, step=1, label="Steps")
            cfg = gr.Slider(1, 12, 7, step=0.5, label="Guidance")
        text = gr.Textbox(lines=6, label="List (kind: description, one per line)")
        file = gr.File(label="or upload .txt", type="filepath")
        go = gr.Button("Generate", variant="primary")
        gal = gr.Gallery(label="Contact sheet (select, then Accept)", columns=6, object_fit="contain")
        status = gr.Textbox(label="Status", interactive=False)
        name = gr.Textbox(label="Save selected as (slug)")
        acc = gr.Button("Accept selected")
        state = gr.State([])
        def run(*args):
            sheet, msg = generate(a.lora, *args)
            return [(im.resize((256, 256), Image.NEAREST), cap) for im, cap in sheet], msg, sheet
        go.click(run, [text, file, kind, count, seed, steps, cfg], [gal, status, state])
        sel = gr.State(None)
        def on_sel(ev: gr.SelectData): return ev.index
        gal.select(on_sel, None, sel)
        def accept(sheet, i, slug):
            if i is None or not slug: return "pick an image and a slug"
            sheet[i][0].save(out / f"{slug}.png"); return f"saved accepted/{slug}.png"
        acc.click(accept, [state, sel, name], status)
    ui.launch()

if __name__ == "__main__":
    main()
