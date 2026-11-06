-- folk-grasshopper-1 sprite (folk F2_0) variant: 1
-- Generic rest-stop grasshopper villager, gardener: leaf-green grasshopper, straw hat with tomato band + sprig, denim bib, trowel.
local NAME = "folk-grasshopper-1"
local W, H = 64, 96
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(d, s, b, h) return { deep = d, shade = s, base = b, hi = h } end
local function part(c, m, r, band, px, py)
  if px and m:has(px, py) then c:part(m, r, { band = band or 1, pop = { x = px, y = py } })
  else c:part(m, r, { band = band or 1, nopop = true }) end
  return m
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 and x >= 0 and y >= 0 and x < W and y < H then m:set(x, y) end
  end end
  return m
end
local function ribs(c, m, r, s, step)
  m:copy():shrink(1):each(function(x, y)
    local k = (s < 0) and (x + y) or (y - x)
    if k % step == 0 then c:put(x, y, r.shade) end
  end)
end
local V = {}
local W, H = 64, 96
local BODY = R("#2e5a5a", "#3f8a52", "#78bf48", "#c4e46a")
local EYE = R("#5a3448", "#8a5a46", "#c08a4a", "#eac27a")
local STRAW = R("#7a5240", "#b98a48", "#e4bc62", "#f8e4a0")
local TOM = R("#7a3448", "#b04848", "#de6648", "#f6a070")
local DEN = R("#3a3e6e", "#4e62a0", "#6e8cc8", "#a8c4e8")
local LEAF = R("#2e5a4a", "#3e8a4a", "#62b04a", "#a8dc6a")
local METAL = R("#4e4a6a", "#7e7c9a", "#b4b4c8", "#e8e6f0")
local WOOD = R("#5a3444", "#8a5440", "#b87a4a", "#e0a868")
local BG = R("#8a4462", "#c0606a", "#e98a6c", "#f6b08a")
V.wear = function(c, b, p)
  part(c, c:rrect(26, 62 + b, 38, 78 + b, 2), DEN, 2, 27, 63 + b)
  part(c, c:rect(26, 58 + b, 27, 62 + b), DEN, 1) part(c, c:rect(37, 58 + b, 38, 62 + b), DEN, 1)
  c:put(27, 63 + b, STRAW.hi) c:put(37, 63 + b, STRAW.hi)
  for x = 30, 34 do c:put(x, 69 + b, DEN.shade) end
  c:put(30, 70 + b, DEN.shade) c:put(34, 70 + b, DEN.shade)
end
V.hat = function(c, b, p)
  local s = p.settle and 1 or 0
  local brim = c:ellipse(32, 29 + b, 17, 4.5)
  part(c, brim, STRAW, 1, 18, 29 + b)
  local crown = c:rrect(24, 18 + b, 40, 28 + b, 5)
  part(c, crown, STRAW, 2, 27, 20 + b)
  part(c, c:rect(24, 25 + b, 40, 27 + b):clip(crown), TOM, 1)
  for x = 17, 47, 3 do if brim:has(x, 31 + b) then c:put(x, 31 + b, STRAW.shade) end end
  for x = 26, 38, 3 do c:put(x, 22 + b, STRAW.shade) end
  c:fillMask(c:line({ { 40, 25 + b }, { 43, 22 + b + s } }, 1), LEAF.shade)
  part(c, c:ellipse(44.5, 20.5 + b + s + (p.tw and -1 or 0), 2, 1.5), LEAF, 1)
end
V.prop = function(c, b, p)
  part(c, c:rect(43, 62 + b, 44, 67 + b), WOOD, 1)
  part(c, c:poly{ { 40, 70 + b }, { 47, 70 + b }, { 44, 79 + b } }, METAL, 1, 41, 70 + b)
  c:put(43, 69 + b, METAL.shade) c:put(44, 69 + b, METAL.shade)
  c:put(43, 76 + b, WOOD.deep) c:put(44, 75 + b, WOOD.deep)
end
V.ant = function(b, p)
  local s = p.settle and 1 or 0
  return { { 28, 20 + b }, { 25, 14 + b }, { 21, 10 + b + s } },
         { { 36, 20 + b }, { 39, 14 + b }, { 43 + (p.tw and 1 or 0), 10 + b + s } }
end

local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function frame(p)
  local c = HP.canvas{ w = W, h = H, name = NAME }
  local b = p.bob
  c:groundShadow(32, 89, 18, 3)
  if V.back then V.back(c, b, p) end
  for _, s in ipairs{ -1, 1 } do   -- hind tibiae down to fixed feet
    part(c, c:line({ { 32 + s * 15, 53 + b }, { 32 + s * 17, 70 }, { 32 + s * 17, 86 } }, 2), BODY, 1)
    part(c, c:ellipse(32 + s * 18, 88.5, 2.5, 1.5), BODY, 1)
  end
  part(c, c:rect(26, 78 + b, 27, 87), BODY, 1) part(c, c:rect(37, 78 + b, 38, 87), BODY, 1)
  part(c, c:ellipse(26, 88.5, 3, 1.5), BODY, 1, 25, 87) part(c, c:ellipse(38.5, 88.5, 3, 1.5), BODY, 1, 37, 87)
  local body = part(c, c:ellipse(32, 70 + b, 10, 10), BODY, 2, 27, 64 + b)
  for _, yy in ipairs{ 74, 78 } do for x = 23, 41 do if body:has(x, yy + b + 1) then c:put(x, yy + b, BODY.shade) end end end
  for _, s in ipairs{ -1, 1 } do   -- big folded jumping femurs, knees up beside the jaw
    local hx, hy, kx, ky = 32 + s * 7, 75 + b, 32 + s * 15, 53 + b
    local fem = oval((hx + kx) / 2, (hy + ky) / 2, 11.5, 3.5, math.deg(math.atan(ky - hy, kx - hx)))
    part(c, fem, BODY, 2)
    ribs(c, fem, BODY, s, 3)
    part(c, c:ellipse(kx, ky, 2, 2), BODY, 1)
    c:put(kx, ky + 1, BODY.deep) c:put(kx + s, ky, BODY.deep)
    c:put(kx - s, ky - 1, BODY.hi)
  end
  part(c, c:rrect(22, 52 + b, 42, 61 + b, 3), BODY, 2, 25, 53 + b)
  for y = 54, 60 do c:put(32, y + b, BODY.shade) end
  if V.wear then V.wear(c, b, p) end
  part(c, c:line({ { 23, 61 + b }, { 21, 67 + b } }, 2), BODY, 1)
  part(c, c:line({ { 41, 61 + b }, { 43, 67 + b } }, 2), BODY, 1)
  local head = c:ellipse(32, 40 + b, 13, 13.5)
  head:add(c:ellipse(32, 50 + b, 8.5, 5.5))
  part(c, head, BODY, 2, 25, 31 + b)
  for y = 41, 47 do c:put(28, y + b, BODY.shade) c:put(36, y + b, BODY.shade) end
  part(c, c:ellipse(21.5, 37 + b, 4, 5.5), EYE, 1, 20, 33 + b)
  part(c, c:ellipse(42.5, 37 + b, 4, 5.5), EYE, 1, 41, 33 + b)
  eye(c, 20, 35 + b, p.blink) eye(c, 41, 35 + b, p.blink)
  part(c, c:rrect(29, 47 + b, 35, 50 + b, 1), BODY, 1, 30, 47 + b)
  c:put(28, 52 + b, EYE.deep) c:put(36, 52 + b, EYE.deep)
  c:put(29, 51 + b, INK) for x = 30, 34 do c:put(x, 52 + b, INK) end c:put(35, 51 + b, INK)
  c:cheek(24, 46 + b) c:cheek(38, 46 + b)
  if V.hat then V.hat(c, b, p) end
  if V.prop then V.prop(c, b, p) end
  part(c, c:ellipse(21, 68 + b, 1.5, 1.5), BODY, 1) part(c, c:ellipse(43.5, 68 + b, 1.5, 1.5), BODY, 1)
  c:finish{ outline = true }
  local a1, a2 = V.ant(b, p)
  c:fillMask(c:line(a1, 1), INK) c:fillMask(c:line(a2, 1), INK)
  HP.assertClean(c)
  return c
end
local IDLE = { { bob = 0 }, { bob = 1, settle = true }, { bob = 0 }, { bob = 0, blink = true, tw = true } }
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, #IDLE do spr:newEmptyFrame() end
local strip = Image(W * #IDLE, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, p in ipairs(IDLE) do
  local c = frame(p)
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do
    local x, y = i % W, i // W
    im:putPixel(x, y, rgba(hex)) strip:putPixel((f - 1) * W + x, y, rgba(hex))
  end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 4) and 0.25 or 0.35
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, #IDLE) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * #IDLE, H, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " ok")
