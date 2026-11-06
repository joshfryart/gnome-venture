-- folk-tortoise-2 sprite (folk F2_7) variant: 2
-- Generic rest-stop tortoise villager. traveller: flat cap, scarf, bedroll on shell, satchel, lantern.
local NAME = "folk-tortoise-2"

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", P.cream
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function px(c, x, y, h) if x >= 0 and y >= 0 and x < c.w and y < c.h then c:put(x, y, h) end end
local function pts(c, l, h) for _, q in ipairs(l) do px(c, q[1], q[2], h) end end
local function onBase(c, m, from, to) local l = {} m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], to) end end
-- tortoise shell: marginal scutes on the rim, costal seams, per-variant scute markings
local function shellDeco(c, sh, cx, cy, rx, ry, S, nseg)
  local inner = sh:shrink(2)
  local rim = sh:copy():cut(inner)
  local l = {}
  rim:each(function(x, y) local a = math.atan(y + .5 - cy, x + .5 - cx) local s = (a / (2 * math.pi) + 1) * nseg
    local f = s - math.floor(s) l[#l + 1] = { x, y, f < 0.2 and S.shell.deep or S.shell.shade } end)
  local nc = nseg // 3
  local Rm = (rx + ry) / 2
  inner:each(function(x, y)
    local dx, dy = (x + .5 - cx) / rx, (y + .5 - cy) / ry
    local r = math.sqrt(dx * dx + dy * dy)
    local a = math.atan(dy, dx)
    local s = (a / (2 * math.pi) + 1) * nc + 0.5
    local f = s - math.floor(s)
    local Lg = 2 * math.pi * r * Rm / nc
    local col
    if r > 0.56 and r < 0.56 + 1.1 / ry then col = S.shell.deep
    elseif r > 0.56 and f * Lg < 1 then col = S.shell.deep
    elseif r > 0.6 then
      local du, dv = (f - 0.5) * Lg, (r - 0.79) * Rm
      if S.style == "rings" then local d = math.abs(du) + math.abs(dv)
        if d < 1.2 then col = S.shell.hi elseif d > 2.6 and d < 3.5 then col = S.shell.shade end
      elseif S.style == "blotch" then if math.abs(du) < Lg * 0.28 and math.abs(dv) < 2.2 then col = (du + dv > 1) and S.shell.base or S.shell.hi end
      elseif S.style == "star" then
        local rr = math.abs(du) + math.abs(dv)
        if rr < 1.3 then col = S.ray.hi
        elseif math.sqrt(du * du + dv * dv) < Lg * 0.45 and (math.abs(du) < .6 or math.abs(dv) < .6 or math.abs(du - dv) < .7 or math.abs(du + dv) < .7) then
          col = (du + dv > 0) and S.ray.base or S.ray.hi end
      end
    end
    if col then l[#l + 1] = { x, y, col } end
  end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end
end

local S = {
  skin = R("#b4c8bc", "#86a096", "#5b7272", "#3c4a58"), shell = R("#a8a062", "#7a7442", "#544e3a", "#38323a"),
  plas = R("#e8dcb0", "#c8b884", "#988a68", "#665c58"), style = "blotch", nail = "#ece2c8",
  scarf = R("#f08478", "#cc4a4c", "#933446", "#5e2840"), cap = R("#c09ad0", "#8e64a4", "#634884", "#433460"),
  canvas = R("#e4cc9a", "#bd9d6a", "#8a6c50", "#5c4640"), leather = R("#c0845a", "#91583e", "#643a36", "#422630"),
  brass = R("#f6d670", "#d09c3c", "#956236", "#623c34"), glass = R("#fff2c4", "#ffd86e", "#f0a848", "#c06a3c"),
  cheek = "#e08a90", cheekhi = "#f0aeb0", disc = R("#ffe4a8", "#f2c262", "#d29a48", "#a86e40"),
}
local V = {}
V.onShell = function(c, p, b) -- bedroll strapped across the top of the shell
  local s = p.settle or 0
  local roll = c:rrect(10, 50 + b + s, 54, 56 + b + s, 3)
  c:part(roll, S.canvas, { band = 2, nopop = true })
  for x = 12, 52 do c:put(x, 51 + b + s, S.canvas.hi) end
  for _, ex in ipairs{ 11, 52 } do pts(c, { { ex, 52 + b + s }, { ex, 53 + b + s }, { ex + 1, 54 + b + s }, { ex + (ex < 30 and 1 or -1), 52 + b + s } }, S.canvas.deep) end
  for _, sx in ipairs{ 17, 46 } do for y = 50, 56 do c:put(sx, y + b + s, S.leather.base) c:put(sx + 1, y + b + s, S.leather.shade) end end
end
V.clothes = function(c, p, b) -- satchel strap + bag
  c:part(c:line({ { 23, 58 + b }, { 40, 76 + b } }, 2), S.leather, { band = 1, nopop = true })
  local bag = c:rrect(36, 73 + b, 45, 81 + b, 1)
  c:part(bag, S.leather, { band = 2, nopop = true })
  for x = 36, 45 do c:put(x, 76 + b, S.leather.deep) end
  for x = 37, 44 do c:put(x, 74 + b, S.leather.hi) end
  pts(c, { { 40, 77 + b }, { 41, 77 + b } }, S.brass.base)
end
V.collar = function(c, p, b) -- crimson scarf, tail over the left chest
  local tl = (p.settle or 0) + (p.tw or 0)
  c:part(c:rrect(24, 50 + b, 40, 57 + b, 2), S.scarf, { band = 2, nopop = true })
  local tail = c:poly{ { 26, 55 + b }, { 30, 55 + b }, { 28 + tl, 66 + b }, { 24 + tl, 66 + b } }
  c:part(tail, S.scarf, { band = 1, nopop = true })
  for i = 0, 4, 2 do c:put(24 + i + tl, 67 + b, S.scarf.shade) end
  for x = 25, 39, 3 do c:put(x, 54 + b, S.scarf.shade) end
end
V.hat = function(c, p, b) -- tilted plum flat cap with button and front peak
  local cap = c:ellipse(31, 31 + b, 12.5, 6.5):clip(c:rect(0, 0, 63, 33 + b))
  c:part(cap, S.cap, { band = 2, pop = { x = 24, y = 27 + b } })
  for x = 19, 43 do if cap:has(x, 33 + b) then c:put(x, 33 + b, S.cap.shade) end end
  local vis = c:ellipse(34, 34.5 + b, 10.5, 2)
  c:part(vis, S.cap, { band = 1, nopop = true })
  vis:each(function(x, y) if not vis:has(x, y + 1) then c:put(x, y, S.cap.deep) end end)
  for x = 26, 42 do if vis:has(x, 34 + b) then c:put(x, 34 + b, S.cap.hi) end end
  c:part(c:rect(30, 24 + b, 31, 25 + b), S.cap, { band = 1, nopop = true })
  c:fillMask(c:line({ { 26, 27 + b }, { 36, 26 + b } }, 1), S.cap.shade)
end
V.propFront = function(c, p, b) -- brass lantern hanging from the left fist
  local t = p.tw or 0
  pts(c, { { 18, 73 + b }, { 18 + t, 74 + b } }, INK)
  c:part(c:rect(15 + t, 75 + b, 22 + t, 76 + b), S.brass, { band = 1, nopop = true })
  local gl = c:rect(15 + t, 77 + b, 22 + t, 82 + b)
  c:part(gl, S.glass, { band = 2, nopop = true })
  for y = 77, 82 do c:put(15 + t, y + b, S.brass.shade) c:put(22 + t, y + b, S.brass.deep) end
  pts(c, { { 18 + t, 79 + b }, { 19 + t, 79 + b }, { 18 + t, 80 + b }, { 19 + t, 80 + b } }, S.glass.hi)
  pts(c, { { 18 + t, 81 + b }, { 19 + t, 81 + b } }, S.glass.shade)
  c:part(c:rect(15 + t, 83 + b, 22 + t, 84 + b), S.brass, { band = 1, nopop = true })
  c:put(16 + t, 75 + b, S.brass.hi)
end
local function eye(c, x, y, blink, S)
  for i = 0, 3 do c:put(x + i, y - 1, S.skin.deep) end
  c:put(x - 1, y, S.skin.deep) c:put(x + 4, y, S.skin.deep)
  if blink then for i = 0, 3 do c:put(x + i, y + 1, INK) end return end
  for _, q in ipairs({ { 0, 0 }, { 3, 0 }, { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 1, y, CREAM) c:put(x + 2, y, CREAM)
  c:put(x + 1, y + 1, CREAM) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89, 15, 3)
  -- stumpy elephant legs + feet (fixed)
  for _, fx in ipairs{ 26, 38 } do
    local leg = c:rect(fx - 3, 79, fx + 3, 87)
    leg:add(c:ellipse(fx, 87.5, 4.5, 2))
    c:part(leg, S.skin, { band = 1, nopop = true })
    for _, dx in ipairs{ -2, 0, 2 } do c:put(fx + dx, 89, S.nail) end
    c:put(fx - 2, 82, S.skin.shade) c:put(fx + 1, 84, S.skin.shade) c:put(fx - 1, 85, S.skin.hi)
  end
  if V.behind then V.behind(c, p, b) end
  -- domed shell behind the body
  local sh = c:ellipse(32, 65 + b, 18.5, 16)
  c:part(sh, S.shell, { band = 2, nopop = true })
  shellDeco(c, sh, 32, 65.5 + b, 18.5, 16, S, 18)
  if V.onShell then V.onShell(c, p, b) end
  -- plastron belly with scute grooves
  local pl = c:ellipse(32, 70 + b, 11.5, 12.5)
  c:part(pl, S.plas, { band = 2, nopop = true })
  for _, y in ipairs{ 63, 69, 75 } do for x = 22, 42 do if pl:has(x, y + b) and pl:has(x, y + b - 2) then c:put(x, y + b, S.plas.shade) end end end
  for y = 59, 81 do if pl:has(32, y + b) then c:put(32, y + b, S.plas.shade) end end
  if V.clothes then V.clothes(c, p, b) end
  if V.propBack then V.propBack(c, p, b) end
  -- stubby scaly arms with claws
  local la, ra = c:ellipse(18.5, 67 + b, 3.5, 5.5), c:ellipse(45.5, 67 + b, 3.5, 5.5)
  c:part(la, S.skin, { band = 1, nopop = true }) c:part(ra, S.skin, { band = 2, nopop = true })
  pts(c, { { 17, 64 + b }, { 17, 65 + b } }, S.skin.hi)
  pts(c, { { 19, 66 + b }, { 18, 69 + b }, { 46, 65 + b }, { 45, 69 + b } }, S.skin.shade)
  pts(c, { { 17, 72 + b }, { 19, 72 + b }, { 44, 72 + b }, { 46, 72 + b } }, S.nail)
  -- wrinkly neck
  local nk = c:rect(27, 48 + b, 37, 57 + b)
  c:part(nk, S.skin, { band = 1, nopop = true })
  for _, q in ipairs{ { 28, 53 }, { 29, 53 }, { 30, 54 }, { 34, 53 }, { 35, 53 }, { 29, 56 }, { 30, 56 }, { 35, 56 } } do c:put(q[1], q[2] + b, S.skin.shade) end
  if V.collar then V.collar(c, p, b) end
  -- blunt tortoise head: domed skull + beak snout, head plates
  local hd = c:ellipse(32, 39 + b, 13.5, 10.5)
  hd:add(c:ellipse(32, 44 + b, 10, 6.5))
  c:part(hd, S.skin, { band = 2, pop = { x = 23, y = 33 + b } })
  for _, q in ipairs{ { 28, 31 }, { 29, 32 }, { 30, 32 }, { 34, 32 }, { 35, 32 }, { 36, 31 }, { 32, 29 }, { 32, 30 }, { 21, 41 }, { 22, 43 }, { 43, 41 }, { 42, 43 }, { 24, 46 }, { 40, 46 } } do c:put(q[1], q[2] + b, S.skin.shade) end
  eye(c, 24, 38 + b, p.blink, S) eye(c, 37, 38 + b, p.blink, S)
  pts(c, { { 30, 43 + b }, { 34, 43 + b } }, S.skin.deep)
  pts(c, { { 31, 42 + b }, { 32, 42 + b }, { 33, 42 + b } }, S.skin.hi)
  -- hooked beak smile
  for x = 28, 36 do c:put(x, 47 + b, INK) end
  pts(c, { { 27, 46 + b }, { 37, 46 + b }, { 32, 48 + b } }, INK)
  pts(c, { { 29, 48 + b }, { 30, 48 + b }, { 34, 48 + b }, { 35, 48 + b } }, S.skin.hi)
  c:cheek(22, 44 + b) c:cheek(41, 44 + b)
  if V.hat then V.hat(c, p, b) end
  if V.propFront then V.propFront(c, p, b) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local FR = { { b = 0 }, { b = 1, settle = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local W, H = 64, 96
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local frames = {}
for i, p in ipairs(FR) do frames[i] = frame(p) end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, #frames do spr:newEmptyFrame() end
local strip = Image(W * #frames, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 4) and 0.35 or 0.3
  strip:drawImage(im, Point((f - 1) * W, 0))
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, #frames) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * #frames, H, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " ok")
