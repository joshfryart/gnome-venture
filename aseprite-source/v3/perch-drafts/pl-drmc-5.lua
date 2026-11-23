-- pl-drmc-5-perch.lua : chibi purple chef pal on a small pouf perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drmc-5-perch-20261120-180121/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0, cres = 2, deep = 3 }

-- ramps (spec palette + pale treatment)
local R = {
  body   = { rim = "#c6a8ce", base = "#4c3f8b", shade = "#442861", deep = "#271b4a", bounce = "#563653", gloss = "#c6a8ce", dot = "#c6a8ce", pale = false },
  hat    = { rim = "#fff3c8", base = "#f3eada", shade = "#d5d0da", deep = "#8977a0", bounce = "#f3eada", gloss = "#fff3c8", dot = "#ffffff", pale = true },
  pouf   = { rim = "#d5d0da", base = "#8977a0", shade = "#563653", deep = "#563653", bounce = "#8977a0", gloss = "#c6a8ce", dot = "#c6a8ce", pale = false },
  bun    = { rim = "#fff3c8", base = "#f3eada", shade = "#d5d0da", deep = "#8977a0", bounce = "#d5d0da", gloss = "#fff3c8", dot = "#ffffff", pale = true },
  speck  = { rim = "#fff3c8", base = "#fff3c8", shade = "#f3eada", deep = "#d5d0da", bounce = "#fff3c8", gloss = "#fff3c8", dot = "#ffffff", pale = true },
  shadow = { base = "#563653" },
}
R.block = { base = "#8977a0" } -- block-in stand-in

local PHASE = 7 -- 2 block-in, 3 perspective, 4 shade, 5 texture, 6 detail, 7 critique
local function ramp(name, phase)
  local flat = phase <= 2 -- block-in: flat silhouettes only
  if flat then
    if name == "body" then return { base = "#4c3f8b" } end
    if name == "hat" or name == "bun" then return { base = "#f3eada" } end
    if name == "shadow" then return { base = "#563653" } end
    if name == "speck" then return { base = "#fff3c8" } end
    return { base = "#8977a0" }
  end
  return R[name]
end

-- shapes
local shadowM = c:ellipse(17.5, 29.7, 9.5, 1.4)
local poufM   = c:rrect(10, 25, 25, 29, 3):add(c:ellipse(17.5, 25.2, 8, 2))
local puffM   = c:ellipse(12.5, 7.5, 4, 2.5):add(c:ellipse(22.5, 7.5, 4, 2.5)):add(c:ellipse(17.5, 8.2, 7, 4.3))
local bunM    = c:rrect(27, 27, 30, 29, 1)
local bodyM   = c:ellipse(17.5, 18, 9, 5.8)
local speckM  = c:ascii({ ".x.", "xxx", ".x." }, 29, 4)

local p = c:build{
  { "shadow", shadowM, ramp("shadow", PHASE), { flat = true, rim = false, gloss = false, solid = false, contact = false, bounce = false, cres = 0, deep = 0 } },
  { "pouf",   poufM,   ramp("pouf", PHASE),   { cres = 1, deep = 0, gloss = false, stitch = PHASE >= 4 and { side = "lit" } or false } },
  { "bun",    bunM,    ramp("bun", PHASE),    { cres = 1, deep = 0, gloss = false } },
  { "puff",   puffM,   ramp("hat", PHASE),    { cres = 2, deep = 3, gloss = false } },
  { "body",   bodyM,   ramp("body", PHASE),   { cres = 2, deep = 3, gloss = false, contour = false } },
  { "speck",  speckM,  ramp("speck", PHASE),  { flat = true, rim = false, gloss = false, pale = true } },
}

if PHASE >= 4 then
  -- big lit patch on the body upper-left, then gloss after it
  local lit = bodyM:shift(-4, -4):clip(bodyM):shrink(1)
  c:fill(lit, "#9647c5")
  c:gloss(bodyM, R.body)
end

if PHASE >= 6 then
  -- detail: enamel gloss comma + dot on the hat, glint px on the pouf rim
  c:gloss(puffM, R.hat)
  c:px(11, 24, "#c6a8ce")
end

if PHASE >= 5 then
  -- texture: subtle, hand-placed, following the form (<=1 shade step)
  -- plush dither at the body's light/shade border
  c:px(17, 21, "#4c3f8b"); c:px(20, 20, "#4c3f8b")            -- base px stepping into the crescent
  c:px(19, 21, "#442861"); c:px(23, 19, "#442861")            -- base px stepping toward the deep edge
  -- felt weave on the pouf (single tuft marks on base px, clear of the stitch)
  c:px(12, 28, "#563653"); c:px(20, 27, "#563653"); c:px(22, 28, "#563653")
  -- fold on the bun
  c:px(29, 28, "#d5d0da")
  -- soft dither where the hat shade begins
  c:px(23, 7, "#f3eada"); c:px(21, 9, "#f3eada")
end

if PHASE >= 7 then
  -- critique fixes: break up the deep band, keep the cheek clean
  c:px(23, 20, "#442861"); c:px(22, 21, "#442861")
end

if PHASE >= 3 then
  -- face (keeps the pal's closed happy eyes, tiny mouth, cheeks); drawn after the lit patch
  c:px(12, 15, "#2b1c26"); c:px(13, 16, "#2b1c26"); c:px(14, 15, "#2b1c26")
  c:px(21, 15, "#2b1c26"); c:px(22, 16, "#2b1c26"); c:px(23, 15, "#2b1c26")
  c:px(17, 18, "#2b1c26"); c:px(18, 18, "#2b1c26")
  c:px(10, 17, "#c05a52"); c:px(11, 17, "#c05a52")
  c:px(24, 17, "#c05a52"); c:px(25, 17, "#c05a52")
  -- speck core
  c:px(30, 5, "#ffffff")
end

-- outline: build, then recolour the selective outline to the pal's dark palette colour
c:finish()
for k, h in pairs(c.pix) do
  if h == "#74462a" or h == "#4a2c1a" or h == "#2a1a10" then c.pix[k] = "#2b1c26" end
end

local t = c:save(D .. "out/pl-drmc-5-perch.aseprite", D .. "out/pl-drmc-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
