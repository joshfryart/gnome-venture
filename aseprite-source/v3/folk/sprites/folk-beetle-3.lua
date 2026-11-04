-- folk-beetle-3 sprite (folk F2_3) variant: 3
-- Generic rest-stop beetle villager. Upright chunky beetle: domed glossy elytra split at the tail, segmented
-- belly plates, stubby chitin limbs, lamellate club antennae, compound-eye domes around cream eyes, clypeus snout
-- + tiny mandibles. v1 gardener (straw hat with a nibbled brim, red neckerchief, trowel with soil),
-- v2 traveller (cap, striped scarf, pack + bedroll, lantern), v3 cook (dotted kerchief, apron, raised soup ladle).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local V = 3
local NAME = "folk-beetle-" .. V
local INK, GLINT, CREAM = "#2b1c26", "#fdf6dc", HP.P.cream
local VAR = {
  { shell = { hi = "#a8e07c", base = "#4fae5a", shade = "#2f7a62", deep = "#25495c" },
    chit  = { hi = "#7fa874", base = "#4e7a5c", shade = "#36564f", deep = "#2c3646" },
    belly = { hi = "#ece2a4", base = "#cfc278", shade = "#9a9064", deep = "#655c56" },
    cloth = { hi = "#ff9c84", base = "#e0584e", shade = "#a83a4e", deep = "#6a2846" },
    hat   = { hi = "#fbe596", base = "#e2b654", shade = "#b07c44", deep = "#6e4a3e" },
    metal = { hi = "#e6eef0", base = "#a8b8c4", shade = "#6c7890", deep = "#454a66" },
    wood  = { hi = "#e2a466", base = "#a8683a", shade = "#74443a", deep = "#4a2c34" },
    disc  = { base = "#bfe0a0", shade = "#90b888", deep = "#628a70" },
    hrx = 13, sr = 8.5 },
  { shell = { hi = "#f6bc7c", base = "#c8743c", shade = "#8e4642", deep = "#562a42" },
    chit  = { hi = "#a87868", base = "#74484c", shade = "#523444", deep = "#38243a" },
    belly = { hi = "#f2d6a8", base = "#d4a676", shade = "#9e7464", deep = "#644a52" },
    cloth = { hi = "#a0d6f4", base = "#4a92d2", shade = "#3a60a2", deep = "#2e3a70" },
    hat   = { hi = "#9ad8b8", base = "#4e9e8a", shade = "#386a70", deep = "#2a404e" },
    pack  = { hi = "#ecd8a4", base = "#bc9e6a", shade = "#846a54", deep = "#504242" },
    metal = { hi = "#ffe69a", base = "#d8a840", shade = "#9a6a3a", deep = "#5e4036" },
    glow  = { hi = "#fff4c0", base = "#ffd462", shade = "#eca044", deep = "#b0683a" },
    disc  = { base = "#a8d4f0", shade = "#7aa8d8", deep = "#5878b0" },
    hrx = 12, sr = 8 },
  { shell = { hi = "#cc94e2", base = "#8a54b8", shade = "#5c3c8e", deep = "#382a58" },
    chit  = { hi = "#8a7ab0", base = "#5a4c86", shade = "#403666", deep = "#2e2646" },
    belly = { hi = "#e6d8f0", base = "#c4b0d4", shade = "#9282a8", deep = "#5e5276" },
    cloth = { hi = "#fbf0d6", base = "#eadab6", shade = "#bfac9e", deep = "#857888" },
    hat   = { hi = "#ffa4ac", base = "#e2627a", shade = "#aa446a", deep = "#6c2e52" },
    metal = { hi = "#e8f0f2", base = "#aebccc", shade = "#707c96", deep = "#474c6a" },
    soup  = { hi = "#ffd08a", base = "#f09a4a", shade = "#c06440", deep = "#7a3c3c" },
    spot = "#e8c46a",
    disc  = { base = "#f4b8c4", shade = "#d88aa8", deep = "#a8648a" },
    hrx = 14, sr = 9.5 },
}
local R = VAR[V]

local function part(c, m, r, band, pop) c:part(m, r, { band = band or 2, nopop = not pop, pop = pop }) return m end
local function eye(c, x, y, blink)
  part(c, c:ellipse(x + 2, y + 2, 3, 3), R.shell, 1)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3},{1,1} } do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, s, tw, ad, ps = p.b, p.s or 0, p.tw or 0, p.ad or 0, p.ps or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  if V == 2 then -- pack + bedroll behind the right shoulder
    part(c, c:rrect(37, 46 + b, 51, 70 + b, 3), R.pack, 2, { x = 39, y = 48 + b })
    part(c, c:rrect(37, 46 + b, 51, 52 + b, 2), R.pack, 1)
    part(c, c:rrect(39, 41 + b + s, 53, 46 + b + s, 2), R.hat, 1, { x = 41, y = 42 + b + s })
    for y = 42, 45 do c:put(46, y + b + s, R.hat.deep) end
    part(c, c:rect(43, 51 + b, 45, 53 + b), R.metal, 1)
  end
  -- legs + feet (fixed)
  for _, sg in ipairs{ -1, 1 } do
    part(c, c:line({ { 32 + sg * 4, 78 }, { 32 + sg * 5, 84 }, { 32 + sg * 6, 87 } }, 3), R.chit, 1)
    part(c, c:ellipse(32 + sg * 7.5, 87.5, 3.5, 1.5), R.chit, 1)
  end
  -- elytra
  local sh = c:ellipse(27.5, 70 + b, R.sr, 14)
  sh:add(c:ellipse(36.5, 70 + b, R.sr, 14))
  sh:cut(c:poly{ { 30, 85 + b }, { 34, 85 + b }, { 32, 79 + b } })
  part(c, sh, R.shell, 2, { x = 21, y = 61 + b })
  for y = 62, 67 do if sh:has(21, y + b) then c:put(21, y + b, R.shell.hi) end end
  for y = 60, 63 do if sh:has(41, y + b) then c:put(41, y + b, R.shell.hi) end end
  c:put(21, 61 + b, GLINT) c:put(41, 59 + b, GLINT)
  if V == 3 then
    for _, q in ipairs{ {20,68},{21,76},{42,67},{41,76} } do
      for dx = 0, 1 do for dy = 0, 1 do if sh:has(q[1] + dx, q[2] + dy + b) then c:put(q[1] + dx, q[2] + dy + b, R.spot) end end end
    end
  end
  -- middle leg nubs
  for _, sg in ipairs{ -1, 1 } do part(c, c:line({ { 32 + sg * 11, 74 + b }, { 32 + sg * 15, 77 + b }, { 32 + sg * 15, 80 + b } }, 2), R.chit, 1) end
  -- belly plates
  local bel = c:rrect(26, 60 + b, 38, 83 + b, 5)
  part(c, bel, R.belly, 1)
  for _, yy in ipairs{ 66, 70, 74, 78 } do for x = 26, 38 do
    if bel:has(x - 1, yy + b) and bel:has(x + 1, yy + b) then c:put(x, yy + b, R.belly.shade) end end end
  -- body clothes
  if V == 1 then
    part(c, c:poly{ { 23, 57 + b }, { 41, 57 + b }, { 32, 67 + b } }, R.cloth, 2, { x = 26, y = 58 + b })
    part(c, c:ellipse(32, 59 + b, 2, 1.5), R.cloth, 1)
    for _, q in ipairs{ {28,61},{35,61},{32,64} } do c:put(q[1], q[2] + b, R.cloth.hi) end
  elseif V == 2 then
    c:fillMask(c:line({ { 40, 61 + b }, { 28, 79 + b } }, 2), R.pack.shade)
    local sc = c:rrect(22, 55 + b, 42, 61 + b, 2)
    part(c, sc, R.cloth, 2, { x = 24, y = 56 + b })
    for x = 25, 41, 4 do for y = 55, 61 do if sc:has(x, y + b) then c:put(x, y + b, R.cloth.shade) end end end
    part(c, c:line({ { 36, 60 + b }, { 37, 66 + b }, { 37 + s, 71 + b } }, 3), R.cloth, 1)
    c:put(36 + s, 72 + b, R.cloth.deep) c:put(38 + s, 72 + b, R.cloth.deep)
  else
    local sk = c:rrect(23, 70 + b, 41, 85 + b, 3)
    part(c, sk, R.cloth, 2, { x = 25, y = 72 + b })
    part(c, c:rrect(27, 61 + b, 37, 71 + b, 2), R.cloth, 1, { x = 28, y = 62 + b })
    for x = 29, 35 do c:put(x, 75 + b, R.cloth.shade) c:put(x, 79 + b, R.cloth.shade) end
    for y = 75, 79 do c:put(29, y + b, R.cloth.shade) c:put(35, y + b, R.cloth.shade) end
    for x = 24, 40, 2 do c:put(x, 84 + b, R.cloth.shade) end
    part(c, c:ellipse(42, 71 + b, 1.5, 1.5), R.hat, 1)
  end
  -- left arm
  local lx = (V == 2) and 17 or 21
  part(c, c:line({ { 24, 62 + b }, { 20, 67 + b }, { lx, 71 + b } }, 3), R.chit, 1)
  if V == 2 then -- lantern hangs from the left hand
    local ly = b + s
    part(c, c:rrect(12, 75 + ly, 20, 77 + ly, 1), R.metal, 1)
    part(c, c:rrect(13, 78 + ly, 19, 83 + ly, 1), R.glow, 1, { x = 14, y = 79 + ly })
    for y = 78, 83 do c:put(16, y + ly, R.metal.shade) end
    part(c, c:rect(12, 84 + ly, 20, 85 + ly), R.metal, 1)
  end
  part(c, c:ellipse(lx + 0.5, 73 + b, 2, 2), R.chit, 1)
  -- right arm + prop
  if V == 1 then
    part(c, c:line({ { 40, 62 + b }, { 44, 67 + b }, { 45, 71 + b } }, 3), R.chit, 1)
    local ty = b + ps
    part(c, c:rect(45, 73 + ty, 47, 77 + ty), R.wood, 1)
    part(c, c:poly{ { 43, 78 + ty }, { 49, 78 + ty }, { 48, 83 + ty }, { 46, 86 + ty }, { 44, 83 + ty } }, R.metal, 2, { x = 44, y = 79 + ty })
    c:put(46, 85 + ty, R.wood.deep) c:put(45, 84 + ty, R.wood.shade) c:put(47, 84 + ty, R.wood.shade)
    part(c, c:ellipse(46.5, 72 + b, 2, 2), R.chit, 1)
  elseif V == 2 then
    part(c, c:line({ { 40, 62 + b }, { 43, 67 + b }, { 43, 71 + b } }, 3), R.chit, 1)
    part(c, c:ellipse(43.5, 72 + b, 2, 2), R.chit, 1)
  else
    part(c, c:line({ { 40, 62 + b }, { 44, 60 + b }, { 46, 56 + b } }, 3), R.chit, 1)
  end
  -- head
  local hx, hy = 32, 47 + b
  part(c, c:ellipse(hx, hy, R.hrx, 10), R.chit, 2, { x = hx - 6, y = hy - 6 })
  c:put(hx - 7, hy - 6, GLINT)
  part(c, c:ellipse(hx, hy + 5, 3.5, 2), R.shell, 1, { x = hx - 2, y = hy + 4 })
  for x = hx - 1, hx + 1 do c:put(x, hy + 8, INK) end
  c:put(hx - 2, hy + 7, INK) c:put(hx + 2, hy + 7, INK)
  c:put(hx - 4, hy + 7, R.chit.deep) c:put(hx - 3, hy + 8, R.chit.deep) c:put(hx + 4, hy + 7, R.chit.deep) c:put(hx + 3, hy + 8, R.chit.deep)
  eye(c, hx - 10, hy - 3, p.blink) eye(c, hx + 6, hy - 3, p.blink)
  c:cheek(hx - 8, hy + 3) c:cheek(hx + 7, hy + 3)
  -- headwear
  local ast
  if V == 1 then
    local hb = c:ellipse(hx, hy - 9, 17, 3.5)
    hb:cut(c:ellipse(hx + 17, hy - 9, 1.5, 1.5))
    part(c, hb, R.hat, 1)
    local cr = c:rrect(hx - 7, hy - 19, hx + 7, hy - 9, 4)
    part(c, cr, R.hat, 2, { x = hx - 5, y = hy - 17 })
    hb:each(function(x, y) if not cr:has(x, y) and (x + y * 2) % 4 == 0 then c:put(x, y, R.hat.shade) end end)
    for x = hx - 7, hx + 7 do
      if cr:has(x, hy - 12) then c:put(x, hy - 12, R.cloth.base) end
      if cr:has(x, hy - 11) then c:put(x, hy - 11, R.cloth.shade) end
    end
    ast = hy - 19
  elseif V == 2 then
    local cap = c:ellipse(hx, hy - 8, 11, 6)
    cap:clip(c:rect(0, 0, 63, hy - 7))
    part(c, cap, R.hat, 2, { x = hx - 5, y = hy - 12 })
    for y = hy - 13, hy - 8 do c:put(hx + 1, y, R.hat.shade) end
    part(c, c:ellipse(hx - 5, hy - 7, 9, 2), R.hat, 1)
    part(c, c:ellipse(hx + 1, hy - 14, 1.5, 1), R.cloth, 1)
    ast = hy - 13
  else
    local k = c:ellipse(hx, hy - 2, R.hrx + 1, 9)
    k:clip(c:rect(0, 0, 63, hy - 4))
    part(c, k, R.hat, 2, { x = hx - 6, y = hy - 9 })
    k:each(function(x, y) if x % 4 == 0 and y % 3 == 0 then c:put(x, y, R.cloth.hi) end end)
    part(c, c:ellipse(hx - 13, hy - 10, 2.5, 2), R.hat, 1)
    part(c, c:ellipse(hx - 16, hy - 13, 2, 2.5), R.hat, 1)
    part(c, c:ellipse(hx - 12, hy - 8, 1.5, 1.5), R.hat, 1)
    ast = hy - 10
  end
  if V == 3 then -- raised soup ladle
    local ly = b + ps
    part(c, c:line({ { 46, 57 + b }, { 48, 47 + ly }, { 50, 41 + ly } }, 2), R.metal, 1)
    part(c, c:ellipse(51, 38 + ly, 4, 3), R.metal, 2, { x = 49, y = 36 + ly })
    part(c, c:ellipse(51, 37 + ly, 2.5, 1.5), R.soup, 1)
    part(c, c:ellipse(46.5, 56 + b, 2, 2), R.chit, 1)
  end
  -- antenna clubs
  local cl = { { 20, 21 + b + ad }, { 44 + tw, 21 + b + ad - tw } }
  for _, q in ipairs(cl) do
    part(c, c:ellipse(q[1], q[2], 2.5, 2), R.shell, 1, { x = q[1] - 2, y = q[2] - 1 })
    c:put(q[1], q[2], R.shell.deep)
  end
  c:finish{ outline = true }
  local function stalk(pts) c:line(pts, 1):each(function(x, y) if not c:get(x, y) then c:put(x, y, INK) end end) end
  stalk{ { hx - 3, ast }, { 27, 26 + b }, { 21, 22 + b + ad } }
  stalk{ { hx + 3, ast }, { 37, 26 + b }, { 43 + tw, 22 + b + ad - tw } }
  HP.assertClean(c)
  return c
end

local PL = { { b = 0 }, { b = 1, s = 1, ad = 1, ps = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(PL) do frames[#frames + 1] = frame(p) end
local W, H, N = 64, 96, #frames
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  imgs[f] = im
end
local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, N do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local s1 = Sprite(W * N, H, ColorMode.RGB) s1.cels[1].image = strip
s1:saveCopyAs(out .. NAME .. ".png") s1:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
local Ly = spr.layers[1] Ly.name = NAME
for f = 1, N do spr:newCel(Ly, spr.frames[f], imgs[f], Point(0, 0)) spr.frames[f].duration = (f % 2 == 0) and 0.35 or 0.55 end
local tg = spr:newTag(1, N) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
