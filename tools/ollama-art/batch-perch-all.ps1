<#
.SYNOPSIS
  Draw EVERY pal perch that is still missing (pl-*-N sprites with no perch) with Ollama via ollama-art.ps1.
  Resumable: results land in a fixed folder and finished pals are skipped on rerun. No Claude critic (Ollama only).
.EXAMPLE
  .\batch-perch-all.ps1 -Parallel 5
  .\batch-perch-all.ps1 -Limit 20          # just the next 20
#>
param(
  [int]$Parallel = 5,
  [int]$Limit = 0,
  [int]$JobMinutes = 30,
  [string]$Model = "glm-5.3-flash:cloud",
  [string]$PalDir = "C:\Users\hello\OneDrive\Desktop\claude\asperite\Use\gnome-venture\game\assets\img\pals",
  [string[]]$Examples = @("bb-catkin-crown", "ss-cocopaddle", "mm-gatepost-hoot", "pl-owl-4")
)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$proj = (Resolve-Path (Join-Path $here "..\..")).Path
$results = Join-Path $proj "ollama-art-results\perches-all"
$batch = Join-Path $env:TEMP "ollama-art\perch-all"
New-Item -ItemType Directory -Force $batch, $results | Out-Null

# already drawn: the live game's perches + earlier test batch + this batch's own results
$have = @{}
Get-ChildItem "$PalDir\perch\*.png" | ForEach-Object { $have[$_.BaseName] = 1 }
Get-ChildItem $results -Filter "pl-*.png" -ErrorAction SilentlyContinue | ForEach-Object { $have[$_.BaseName] = 1 }
Get-ChildItem (Join-Path $proj "ollama-art-results") -Recurse -Filter "pl-*-?.png" -ErrorAction SilentlyContinue | ForEach-Object { if (-not $have.ContainsKey($_.BaseName)) { Copy-Item $_.FullName "$results\$($_.Name)" -ErrorAction SilentlyContinue; $have[$_.BaseName] = 1 } }
$todo = Get-ChildItem "$PalDir\pl-*.png" | ForEach-Object { $_.BaseName } | Where-Object { -not $have.ContainsKey($_) } | Sort-Object
if ($Limit -gt 0) { $todo = $todo | Select-Object -First $Limit }
Write-Host ("to draw: {0}  (parallel {1})" -f @($todo).Count, $Parallel)

function Prep([string]$p) {
  $d = "$batch\$p"; Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force "$d\x" | Out-Null
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
- composition (from the examples): the pal sits at upper-centre, head about 40-45% of the sprite height, big round eyes, tiny mouth, pink cheeks if the pal has them; a SMALL perch/base under it that suits the pal (much smaller than the pal's own base art); a soft shadow ellipse; one or two tiny accents beside it taken from the pal.
- keep from the pal: its key colours, silhouette features, face and main props. Simplify everything else: 2-3 tone ramps per material, bold clear silhouette, readable at 16px.
- palette (dominant colours of the pal): $pal. Light from upper-left.
- outline: 1px dark selective outline (a dark palette colour, not pure black). No semi-transparent pixels.
"@ | Set-Content -Encoding UTF8 "$d\spec.md"
  return $d
}

$running = @{}   # pal -> job
$done = 0; $failed = @()
function Harvest {
  foreach ($p in @($running.Keys)) {
    $j = $running[$p]
    $age = (New-TimeSpan -Start $j.PSBeginTime -End (Get-Date)).TotalMinutes
    if ($j.State -eq 'Running' -and $age -gt $JobMinutes) { Stop-Job $j; Write-Host "timeout $p" }
    if ($j.State -ne 'Running') {
      $j.ChildJobs[0].Output | Out-File "$results\$p.log" -Encoding utf8
      $w = Get-ChildItem "$env:TEMP\ollama-art" -Directory -Filter "$p-perch-*" | Sort-Object LastWriteTime | Select-Object -Last 1
      if ($w -and (Test-Path "$($w.FullName)\out\$p-perch.png")) {
        Copy-Item "$($w.FullName)\out\$p-perch.png" "$results\$p.png"
        Copy-Item "$($w.FullName)\$p-perch.lua" "$results\$p.lua" -ErrorAction SilentlyContinue
        $script:done++
      } else { $script:failed += $p }
      Remove-Job $j; $running.Remove($p)
      Remove-Item "$batch\$p" -Recurse -Force -ErrorAction SilentlyContinue
      if ($w) { Remove-Item $w.FullName -Recurse -Force -ErrorAction SilentlyContinue }   # keep disk use down; the PNG + lua are saved
      "{0} done={1} failed={2} running={3} {4}" -f (Get-Date -Format "HH:mm:ss"), $script:done, @($script:failed).Count, $running.Count, $p | Add-Content "$results\progress.txt"
    }
  }
}

foreach ($p in $todo) {
  while ($running.Count -ge $Parallel) { Start-Sleep 10; Harvest }
  $d = Prep $p
  $running[$p] = Start-Job -Name $p -ScriptBlock {
    param($ps1, $spec, $name, $extra, $model)
    & $ps1 -Spec $spec -Name $name -Extra $extra -Model $model -Avoid "copying the 64px sprite smaller (a perch is a simplified chibi version), flat wide head, muddy mid-tones, hard single-tone shade bands, anything outside 36x36" 2>&1 | Out-String
  } -ArgumentList "$here\ollama-art.ps1", "$d\spec.md", "$p-perch", "$d\x", $Model
}
while ($running.Count -gt 0) { Start-Sleep 10; Harvest }
if ($failed.Count) { $failed | Set-Content "$results\failed.txt" }

# contact sheets of 30 (source pal | perch)
$all = Get-ChildItem $results -Filter "pl-*.png" | ForEach-Object { $_.BaseName } | Sort-Object
$n = 0
for ($k = 0; $k -lt $all.Count; $k += 30) {
  $chunk = $all[$k..([Math]::Min($k + 29, $all.Count - 1))]
  $n++; $list = ($chunk | ForEach-Object { "'$_'" }) -join ","
  & python -c "
from PIL import Image, ImageDraw
pals=[$list]; PD=r'$PalDir'; R=r'$results'
S=2; cols=6; cw=64*S+36*4+16; rws=(len(pals)+cols-1)//cols
c=Image.new('RGB',(cols*cw,rws*(64*S+22)),(200,200,200)); d=ImageDraw.Draw(c)
for i,p in enumerate(pals):
    x=(i%cols)*cw+4; y=(i//cols)*(64*S+22)+4
    a=Image.open(PD+'\\\\'+p+'.png').convert('RGBA').resize((64*S,64*S),Image.NEAREST); c.paste(a,(x,y),a)
    b=Image.open(R+'\\\\'+p+'.png').convert('RGBA').resize((36*4,36*4),Image.NEAREST); c.paste(b,(x+64*S+4,y+8),b)
    d.text((x,y+64*S+4),p,fill=(0,0,0))
c.save(R+'\\\\contact-$n.png')
"
}
Write-Host ("`nDone: {0} drawn, {1} failed. Results: {2}" -f $done, @($failed).Count, $results)
