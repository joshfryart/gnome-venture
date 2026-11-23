<#
.SYNOPSIS
  Draw several missing pal perch sprites (36x36) with ollama-art.ps1, a few at a time, and make a contact sheet.
.EXAMPLE
  .\batch-perch.ps1 -Pals pl-aurc-6,pl-baob-6,pl-chil-6 -Parallel 3
#>
param(
  [Parameter(Mandatory)][string[]]$Pals,
  [int]$Parallel = 3,
  [string]$Model = "glm-5.3-flash:cloud",
  [string]$PalDir = "C:\Users\hello\OneDrive\Desktop\claude\asperite\Use\gnome-venture\game\assets\img\pals",
  [string[]]$Examples = @("bb-catkin-crown", "ss-cocopaddle", "mm-gatepost-hoot", "pl-owl-4")
)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$proj = (Resolve-Path (Join-Path $here "..\..")).Path
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$batch = Join-Path $env:TEMP "ollama-art\perch-batch-$stamp"
$results = Join-Path $proj "ollama-art-results\perches-$stamp"
New-Item -ItemType Directory -Force $batch, $results | Out-Null

# per-pal inputs: x\ (source sprite + done examples) and a generic spec with the pal's own palette
foreach ($p in $Pals) {
  $d = "$batch\$p"; New-Item -ItemType Directory -Force "$d\x" | Out-Null
  Copy-Item "$PalDir\$p.png" "$d\x\pal.png"
  $i = 1
  foreach ($e in $Examples) { Copy-Item "$PalDir\$e.png" "$d\x\ex$i-pal.png"; Copy-Item "$PalDir\perch\$e.png" "$d\x\ex$i-perch.png"; $i++ }
  $pal = & python -c "
from PIL import Image
im=Image.open(r'$d\x\pal.png').convert('RGBA')
c=im.convert('RGB').quantize(12).convert('RGB').getcolors(2000)
print(' '.join('#%02x%02x%02x'%t[1] for t in sorted(c,reverse=True)[:12]))"
  @"
# pals/perch/$p  (36x36 perch sprite)
A "perch" sprite is the pal's small in-game-room version: a chibi miniature of the 64x64 pal sitting/standing on its own little themed perch, with a bigger head and simpler shapes than the 64px art, in the same palette.
- inputs (in ./x/): pal.png = THIS pal at 64x64 (the subject: draw exactly this creature). ex1..ex4 = finished examples, each as exN-pal.png (64x64) and exN-perch.png (36x36). Read ALL of them with the Read tool and study how a perch relates to its pal (head size, how the base is simplified, accents, face) before drawing.
- canvas: 36x36, transparent background; the whole sprite incl. outline fits with at least 1px clear border.
- composition (from the examples): the pal sits at upper-centre, head about 40-45% of the sprite height, big round eyes, tiny mouth, pink cheeks if the pal has them; a SMALL perch/base under it that suits the pal (keep it much smaller than the pal's own base art); a soft shadow ellipse; one or two tiny accents beside it taken from the pal (items, sparkles).
- keep from the pal: its key colours, silhouette features, face and main props. Simplify everything else: 2-3 tone ramps per material, bold clear silhouette, readable at 16px.
- palette (dominant colours of the pal): $pal. Light from upper-left.
- outline: 1px dark selective outline (a dark palette colour, not pure black). No semi-transparent pixels.
"@ | Set-Content -Encoding UTF8 "$d\spec.md"
}

# run in waves of $Parallel
$jobs = @()
function Wait-Slot { while (@($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $Parallel) { Start-Sleep 5 } }
foreach ($p in $Pals) {
  Wait-Slot
  Write-Host "start $p"
  $jobs += Start-Job -Name $p -ScriptBlock {
    param($ps1, $spec, $name, $extra, $model)
    & $ps1 -Spec $spec -Name $name -Extra $extra -Model $model -Avoid "copying the 64px sprite smaller (a perch is a simplified chibi version), flat wide head, muddy mid-tones, hard single-tone shade bands, anything outside 36x36" 2>&1 | Out-String
  } -ArgumentList "$here\ollama-art.ps1", "$batch\$p\spec.md", "$p-perch", "$batch\$p\x", $Model
}
$jobs | Wait-Job | Out-Null
$jobs | ForEach-Object { $_.ChildJobs[0].Output | Out-File "$results\$($_.Name).log" -Encoding utf8 }

# collect newest work folder per pal, copy results, build contact sheet
$rows = @()
foreach ($p in $Pals) {
  $w = Get-ChildItem "$env:TEMP\ollama-art" -Directory -Filter "$p-perch-*" | Sort-Object LastWriteTime | Select-Object -Last 1
  if ($w -and (Test-Path "$($w.FullName)\out\$p-perch.png")) {
    Copy-Item "$($w.FullName)\out\$p-perch.png" "$results\$p.png"
    Copy-Item "$($w.FullName)\$p-perch.lua" "$results\$p.lua" -ErrorAction SilentlyContinue
    $rows += $p
  } else { Write-Host "no result for $p" }
}
$list = ($rows | ForEach-Object { "'$_'" }) -join ","
& python -c "
from PIL import Image, ImageDraw
pals=[$list]; PD=r'$PalDir'; R=r'$results'
S=3; cell=64*S+8; cols=5; rws=(len(pals)+cols-1)//cols
c=Image.new('RGB',(cols*(cell+36*5+14),rws*(64*S+30)),(200,200,200)); d=ImageDraw.Draw(c)
for i,p in enumerate(pals):
    x=(i%cols)*(cell+36*5+14)+6; y=(i//cols)*(64*S+30)+6
    a=Image.open(PD+'\\\\'+p+'.png').convert('RGBA').resize((64*S,64*S),Image.NEAREST); c.paste(a,(x,y),a)
    b=Image.open(R+'\\\\'+p+'.png').convert('RGBA').resize((36*5,36*5),Image.NEAREST); c.paste(b,(x+cell,y+20),b)
    d.text((x,y+64*S+4),p,fill=(0,0,0))
c.save(R+r'\\contact.png')
"
Write-Host "`nResults: $results  (contact sheet: $results\contact.png)"
