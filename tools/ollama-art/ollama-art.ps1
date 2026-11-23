<#
.SYNOPSIS
  Have an Ollama model (via `ollama launch claude`) draw one gvlib asset in phases, scored against a reference.

.EXAMPLE
  .\ollama-art.ps1 -Spec ..\..\img-redraw-full\specs\games\crop-vegetable.md -Name crop-vegetable -Ref ..\..\img-redraw-full\png\games\crop-vegetable.png
  .\ollama-art.ps1 -Spec spec.md -Name honeybrook -Ref reference.png -Scene -Critic -Notes "Road must lead the eye to the archway."

  -Scene   adds LIGHTING + COMPOSITION phases (big multi-object scenes).
  -Critic  after the draft, a stronger Claude model critiques the render (3 fixes) and the Ollama model applies them once.
  Work happens in a fresh folder under $env:TEMP\ollama-art; nothing in the project is modified.
#>
param(
  [Parameter(Mandatory)][string]$Spec,
  [Parameter(Mandatory)][string]$Name,
  [string]$Model  = "glm-5.3-flash:cloud",
  [string]$Ref,
  [switch]$Scene,
  [switch]$Critic,
  [string]$CriticModel = "sonnet",
  [int]$FixRenders = 3,
  [string]$Extra  = "",    # folder copied to ./x in the work folder (style examples, source sprites)
  [string]$Notes  = "",
  [string]$Avoid  = ""
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$proj = (Resolve-Path (Join-Path $here "..\..")).Path
$work = Join-Path $env:TEMP ("ollama-art\{0}-{1}" -f $Name, (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Force "$work\out", "$work\gvlib" | Out-Null

foreach ($f in "gvlib.lua", "README.md", "brief.md") { Copy-Item (Join-Path $proj "gvlib\$f") "$work\gvlib\" }
Copy-Item (Resolve-Path $Spec) "$work\spec.md"
Copy-Item "$here\render.sh", "$here\dump.lua", "$here\score.py" $work
if ($Ref) { Copy-Item (Resolve-Path $Ref) "$work\reference.png" }
if ($Extra) { Copy-Item (Resolve-Path $Extra) "$work\x" -Recurse }

# measure the reference so proportions are known up front
$refFacts = ""
if ($Ref) {
  $refFacts = (& python -c "
from PIL import Image
im=Image.open(r'$work\reference.png').convert('RGBA'); W,H=im.size
bb=im.getchannel('A').getbbox() or (0,0,W,H)
c=im.convert('RGB').quantize(8).convert('RGB').getcolors(1000)
top=sorted(c,reverse=True)[:8]
print('canvas %dx%d, opaque bbox x%d..%d y%d..%d (%dx%d, aspect %.2f). Dominant colours: %s' % (W,H,bb[0],bb[2]-1,bb[1],bb[3]-1,bb[2]-bb[0],bb[3]-bb[1],(bb[2]-bb[0])/max(1,bb[3]-bb[1]),' '.join('#%02x%02x%02x'%t[1] for t in top)))
" 2>$null)
}

$w = $work -replace '\\', '/'
$refLine = if ($Ref) { "- ./reference.png is the target. Facts measured from it: $refFacts`n- Try Read on it to look at it; render.sh also prints a SCORE vs it (higher is better, 0..1). Match its form, proportions, shading and polish, but write your own code." } else { "- No reference image: follow spec.md." }
$extra = ""
if ($Notes) { $extra += "`n## Direction from the art lead`n$Notes`n" }
if ($Avoid) { $extra += "`n## Avoid (seen in earlier attempts)`n$Avoid`n" }

$sceneMid = ""; $n = 7
if ($Scene) {
  $sceneMid = @"
3b. COMPOSITION - focal point, leading lines (a road/path must lead the eye to the focus), grouping and spacing of objects, overlap/depth order, clear silhouettes, balance left/right.
3c. LIGHTING - one light source and time of day: ambient colour wash, shadow direction and length, warm light on lit faces, cool/hazy tone with distance (atmospheric perspective), glow from windows and lanterns.
"@
}
@"
# Task: draw ONE asset with an Aseprite Lua script, $Name.lua (write it to ./$Name.lua)
Inputs: ./spec.md (asset spec), gvlib/README.md + gvlib/brief.md (read both first; gvlib/gvlib.lua is the source).
$refLine
Load the library with: dofile("$w/gvlib/gvlib.lua")
Save with c:save("$w/out/$Name.aseprite", "$w/out/$Name.png") and print(GV.report(t)).

## Rendering
Run:  bash render.sh $Name.lua $Name   (add "x0 y0 x1 y1" to zoom a region of a big canvas)
Prints the GV.report line, size/bbox/palette legend, a character map ('.' = transparent) for small canvases or a zoomed region, and SCORE (with change vs the previous render). Writes out/${Name}_x6.png (Read it if you can view images).

## Phases - exactly ONE render per phase. Do not merge phases. After each render add at most 3 problems to notes.md (one line each), fix them in the NEXT phase's edit.
1. PLAN - no render. 5 lines in notes.md: parts, coordinates, one ramp per part, light from upper-left.
2. BLOCK-IN - flat silhouettes only. Check: bbox/aspect match spec and reference.
3. PERSPECTIVE - proportions, overlap order, foreshortening (ellipses for round forms, converging lines for roads/roofs/stalls), ground contact and contact shadows, scale between parts. Objects sit on the ground plane, never float.
$sceneMid4. SHADE - ramps, shade crescent following the form, 1px selective outline, bounce light. No hard single-tone bands.
5. TEXTURE - hand-placed, subtle, following the form: material marks (grain, stone joints, fabric weave, skin pits), tone-on-tone variation, 1px dither at light/shade borders, edge wear. Each texture is at most 1 shade step from its base and must not change what the object looks like.
6. DETAIL - gloss, highlights, small accents.
7. CRITIQUE - adversarial: list the 3 weakest areas versus the reference/spec (use zoomed renders and the SCORE), fix only those, render once. Then final check: semi=0, margin OK, readable at 16px, no streaks or fringing.
Extra renders allowed beyond the phases: $FixRenders, only to repair a failed check (assert, semi>0, margin, crash). Stall guard: if SCORE total does not improve for 2 consecutive renders, stop and report.
Only edit files in this folder. Never write outside it.

## Quality bar
- Hand-placed, deliberate pixels; clear light-to-shade ramps; no hard single-tone bands where a curved terminator belongs.
- Each part clearly readable and separated; no streaks; no purple/odd fringing; no pillow shading.
- Restraint: texture and detail stay subtle. If a detail changes what the object looks like, remove it.
- semi-transparent pixels must be 0.
$extra
## Final reply
One line, max 50 words: `OK|PARTIAL`, renders used, final SCORE, anything unresolved. Details stay in notes.md.
"@ | Set-Content -Encoding UTF8 "$work\TASK.md"

function Invoke-Agent([string]$prompt, [string]$extraTools = "") {
  $ErrorActionPreference = "Continue"   # ollama writes a harmless unrecognized_model line to stderr
  & ollama launch claude --model $Model -- -p $prompt `
    --allowedTools "Read" "Glob" "Grep" "Write" "Edit" "Bash(bash render.sh:*)" 2>&1 |
    Where-Object { $_ -notmatch "unrecognized_model|NativeCommandError|CategoryInfo|FullyQualifiedErrorId|^\s*\+|^At |^\s*$" }
}

Write-Host "Work folder: $work"
Push-Location $work
try {
  Write-Host "--- draft ($Model)"
  Invoke-Agent "Read TASK.md in this folder and do exactly what it says."

  if ($Critic -and (Test-Path "$work\out\$Name`_x6.png")) {
    Write-Host "--- critique ($CriticModel)"
    # side-by-side image: reference (left) | render (right), both at 6x nearest
    $cmp = "out/compare.png"
    & python -c "
import os
from PIL import Image
r=Image.open('out/$Name.png').convert('RGBA')
if os.path.exists('reference.png'): f=Image.open('reference.png').convert('RGBA'); lab='reference target'
elif os.path.exists('x/pal.png'): f=Image.open('x/pal.png').convert('RGBA'); lab='source sprite'
else: f=r; lab='none'
def sc(im): return 6 if max(im.size)<=128 else 2
ims=[]
for im in (f,r):
    s=sc(im); b=Image.new('RGBA',im.size,(236,236,236,255)); b.alpha_composite(im); ims.append(b.resize((im.width*s,im.height*s),Image.NEAREST))
c=Image.new('RGBA',(ims[0].width+ims[1].width+12,max(i.height for i in ims)),(40,40,40,255))
c.paste(ims[0],(0,0)); c.paste(ims[1],(ims[0].width+12,0)); c.save('$cmp')
"
    $best = if (Test-Path "out/best.txt") { Get-Content "out/best.txt" } else { "n/a (no reference)" }
    $leftIs = if ($Ref) { "the reference target" } else { "the source sprite the render is derived from (it may be a larger, more detailed version; judge whether RIGHT keeps its identity, colours and key features in a simplified form)" }
    $cp = "You are an art director for pixel art. Read spec.md and out/compare.png (LEFT = $leftIs, RIGHT = the current render; Read it as an image). Current best SCORE: $best. Reply with exactly 3 bullets, max 80 words total: the three biggest differences between RIGHT and LEFT/the spec and a concrete fix for each (region, shape change). Rules: match the palette and outline style of the spec - never introduce new colours or restyle what already matches; only fix real shape, proportion or shading differences. Do not edit anything."
    $crit = & claude -p $cp --model $CriticModel --allowedTools "Read" 2>&1 | Out-String
    $crit | Set-Content -Encoding UTF8 "$work\critic.md"
    Write-Host $crit
    Write-Host "--- apply critique ($Model)"
    Invoke-Agent "Read critic.md (3 fixes from an art director) and notes.md. Apply the 3 fixes to $Name.lua, render once with render.sh, append the outcome to notes.md. Reply in one line."
    # keep-the-best: if the critique made the score worse, restore the best script and re-render
    if ((Test-Path "out/best.txt") -and (Test-Path "out/scores.txt")) {
      $bestV = [double](Get-Content "out/best.txt"); $lastV = [double](Get-Content "out/scores.txt" | Select-Object -Last 1)
    } else { $bestV = 0; $lastV = 1 }   # no reference -> no score -> nothing to restore
    if ($lastV -lt $bestV) {
      Write-Host "critique scored $lastV < best $bestV -> restoring best"
      Copy-Item out\best.lua "$Name.lua" -Force
      & bash render.sh "$Name.lua" $Name 2>&1 | Select-String "SCORE"
    }
  }
} finally { Pop-Location }

if (Test-Path "$work\out\$Name.png") {
  $sc = if (Test-Path "$work\out\scores.txt") { (Get-Content "$work\out\scores.txt" | Select-Object -Last 1) } else { "n/a" }
  Write-Host "`nDone. Result: $work\out\$Name.png   (6x: $work\out\${Name}_x6.png)   last score: $sc"
} else {
  Write-Host "`nNo PNG produced. Check $work"
}
