-- folk-grasshopper-2 sprite (folk F2_0) variant: 2
-- Generic rest-stop grasshopper villager, traveller: ochre locust, plum flat cap, teal scarf, canvas pack + bedroll, brass lantern.
local NAME = "folk-grasshopper-2"
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
local BODY = R("#5a3a4e", "#8e5e48", "#c48e4c", "#ecc684")
local EYE = R("#3a3050", "#5a4a6e", "#8a6a8a", "#c4a0b0")
local PLUM = R("#3e2a52", "#5e3a6e", "#8a4e8a", "#c07ab0")
local TEAL = R("#2a4a62", "#2e7a80", "#3eae9e", "#90e0c8")
local CANVAS = R("#4a4a4e", "#6e7050", "#9ea064", "#d0cc8e")
local RUST = R("#6a3444", "#a04a40", "#cc6a44", "#f09a68")
local BRASS = R("#6a4a3e", "#a0703e", "#d4a04a", "#f4d27e")
local GLOW = R("#c0703e", "#f0a040", "#fcd070", "#fff0b8")
local BG = R("#5a4680", "#80629e", "#b08ac4", "#d4b4e0")
V.back = function(c, b, p)
  part(c, c:rrect(21, 46 + b, 43, 70 + b, 4), CANVAS, 2, 23, 48 + b)
  local roll = oval(19, 45 + b, 9, 3.5, -20)
  part(c, roll, RUST, 1)
  for _, x in ipairs{ 14, 22 } do c:fillMask(c:line({ { x, 40 + b }, { x + 1, 50 + b } }, 1):clip(roll), RUST.deep) end
end
V.wear = function(c, b, p)
  c:fillMask(c:line({ { 25, 60 + b }, { 26, 76 + b } }, 2), CANVAS.shade)
  c:fillMask(c:line({ { 39, 60 + b }, { 38, 76 + b } }, 2), CANVAS.shade)
  for _, q in ipairs{ { 30, 66 }, { 34, 70 }, { 29, 74 }, { 35, 77 }, { 32, 79 } } do c:put(q[1], q[2] + b, BODY.shade) end
end
V.hat = function(c, b, p)
  local s = p.settle and 1 or 0
  part(c, c:rrect(20, 53 + b, 44, 59 + b, 3), TEAL, 2, 22, 54 + b)
  for _, x in ipairs{ 26, 32, 38 } do c:put(x, 56 + b, TEAL.shade) c:put(x + 1, 57 + b, TEAL.shade) end
  local tail = c:poly{ { 21, 56 + b }, { 26, 57 + b }, { 23 + s, 69 + b }, { 18 + s, 68 + b } }
  part(c, tail, TEAL, 1)
  tail:each(function(x, y) if not tail:has(x, y + 1) and x % 2 == 0 then c:put(x, y, TEAL.deep) end end)
  local dome = c:ellipse(32, 28 + b, 12.5, 6):clip(c:rect(0, 0, 63, 29 + b))
  part(c, dome, PLUM, 2, 26, 24 + b)
  c:fillMask(c:line({ { 32, 23 + b }, { 32, 28 + b } }, 1), PLUM.shade)
  local peak = c:ellipse(32, 30 + b, 11, 2.5):clip(c:rect(0, 30 + b, 63, 40))
  part(c, peak, PLUM, 1)
  peak:each(function(x, y) if not peak:has(x, y + 1) then c:put(x, y, PLUM.deep) end end)
  part(c, c:ellipse(32, 22 + b, 1.5, 1.5), PLUM, 1)
end
V.prop = function(c, b, p)
  local d = p.tw and 1 or 0
  c:fillMask(c:line({ { 44, 69 + b }, { 44 + d, 71 + b } }, 1), BRASS.deep)
  part(c, c:rect(42 + d, 71 + b, 46 + d, 72 + b), BRASS, 1)
  part(c, c:rect(42 + d, 73 + b, 46 + d, 77 + b), GLOW, 1, 43 + d, 74 + b)
  c:fillMask(c:rect(44 + d, 73 + b, 44 + d, 77 + b), BRASS.shade)
  part(c, c:rect(41 + d, 78 + b, 47 + d, 79 + b), BRASS, 1)
end
V.ant = function(b, p)
  local s = p.settle and 1 or 0
  return { { 25, 25 + b }, { 19, 18 + b }, { 14, 15 + b + s } },
         { { 39, 25 + b }, { 45, 18 + b }, { 50 + (p.tw and 1 or 0), 15 + b + s } }
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
