-- folk-grasshopper-3 sprite (folk F2_0) variant: 3
-- Generic rest-stop grasshopper villager, cook: rose-pink grasshopper, polka-dot mustard kerchief with knot, cream apron, copper ladle of soup.
local NAME = "folk-grasshopper-3"
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
local BODY = R("#6a3a6a", "#ac5a88", "#e888a6", "#fcc0c8")
local EYE = R("#3a3060", "#5a4c8a", "#8a7cba", "#c0b4e0")
local MUST = R("#7a4a3e", "#c08032", "#ecb440", "#fae08a")
local APRON = R("#6e6a88", "#a8a4bc", "#e6dcc8", "#faf2e0")
local COPPER = R("#5a3444", "#94504a", "#cc7a4a", "#f4b882")
local SOUP = R("#7a4a3e", "#b06a3a", "#e09a3a", "#f8cc6a")
local BG = R("#466e94", "#5e98b4", "#8cc8d4", "#c0e4e8")
V.wear = function(c, b, p)
  local ap = c:rrect(24, 62 + b, 40, 82 + b, 3)
  part(c, ap, APRON, 2, 26, 63 + b)
  for x = 24, 40 do if ap:has(x, 79 + b) then c:put(x, 79 + b, MUST.base) end end
  c:fillMask(c:rrect(29, 70 + b, 35, 75 + b, 1):edge(), APRON.shade)
  part(c, c:ellipse(22, 68 + b, 2, 1.5), MUST, 1)
end
V.hat = function(c, b, p)
  local k = c:ellipse(32, 40 + b, 13.5, 14.5):clip(c:rect(0, 0, 63, 31 + b))
  part(c, k, MUST, 2, 24, 29 + b)
  for _, q in ipairs{ { 27, 28 }, { 32, 27 }, { 37, 29 }, { 30, 31 }, { 35, 31 }, { 23, 31 }, { 41, 31 } } do
    if k:has(q[1], q[2] + b) then c:put(q[1], q[2] + b, APRON.hi) end end
  local t = p.tw and -1 or 0
  part(c, c:poly{ { 46, 29 + b }, { 51, 26 + b + t }, { 50, 30 + b } }, MUST, 1)
  part(c, c:poly{ { 46, 31 + b }, { 50, 34 + b }, { 47, 34 + b } }, MUST, 1)
  part(c, c:ellipse(45, 30 + b, 2.5, 2), MUST, 1, 44, 29 + b)
end
V.prop = function(c, b, p)
  part(c, c:line({ { 42, 58 + b }, { 44, 67 + b } }, 2), COPPER, 1)
  part(c, c:ellipse(46, 72 + b, 3.5, 2.5), COPPER, 1, 44, 71 + b)
  part(c, c:ellipse(46, 71.5 + b, 2, 1), SOUP, 1)
  if p.tw then c:put(47, 75 + b, SOUP.base) end
end
V.ant = function(b, p)
  local s = p.settle and 1 or 0
  return { { 28, 27 + b }, { 26, 19 + b }, { 22, 14 + b + s } },
         { { 36, 27 + b }, { 38, 19 + b }, { 42 + (p.tw and 1 or 0), 14 + b + s } }
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
