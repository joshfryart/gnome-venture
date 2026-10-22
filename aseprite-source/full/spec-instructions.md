# Spec-writing instructions (Sonnet)
You prepare compact art specs so an artist can redraw game assets as pixel art WITHOUT reading the original SVGs. Your shard file lists assets (id = `<folder>/<name>`, viewBox, and sometimes a `hint`).
For each asset: read the original SVG at C:\Users\hello\AppData\Local\Temp\gv\game\assets\img\<folder>\<name>.svg and write ONE spec file to C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\img-redraw-full\specs\<folder>\<name>.md (mkdir -p). Max 25 lines each, dense bullets, no padding.
Read once before starting: C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\gvlib\brief.md and README.md (mode names and terms). Example specs to imitate: C:\Users\hello\OneDrive\Desktop\claude\asperite\gnome-venture\specs\ico\ico-thumbs-down.md and specs\ph\npc-jasper-burrowman.md.
Each spec has:
- `canvas:` width x height, gvlib mode (sticker | icon | bust | scene), and "draw at half-size, write 2x" when the canvas is wider than ~100 px.
- `subject:` one sentence, what the object IS and its mood, for someone who has not seen it. Infer from the file name and shapes (broken-X = a damaged X; stage-N = growth stage N of a plant; nav-X = navigation icon; guide-XX = region emblem, no text; banner-XX = region banner, no text; *-seed = a seed item). Describe what to draw; do not copy the SVG's look.
- `must-read-at-16px:` the ONE silhouette feature that must be unmistakable at 16 px.
- `distinct:` one concrete feature that makes THIS asset look different from similar siblings (a unique silhouette, container, prop or composition). Artists must never reuse one layout for several assets, so name something specific.
- `parts:` 4-9 parts back to front with approximate geometry in final canvas pixel coordinates (apply any viewBox offset) and a base hex colour for each from the SVG fills, nudged to Part A palette families when close.
- `joins:` natural seam / edge stitch / 4x4 button locations, or "none".
- `face:` locked eyes needed and where (creatures and npc busts always have eyes).
- `notes:` broken-* list the damage (crack, snapped part, chipped corner, loose piece); pale subjects cream-safe; busts 60% pens and bleed off the bottom; scenes/banners/landing/tiles full-bleed, no halo, thread-gold hem stitch allowed; stage-* show the growth stage clearly; if the asset has a `hint`, follow it for the container/design.
Reply ONLY with "done" and the number of spec files written.
