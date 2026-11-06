-- folk-tortoise-1 sprite (folk F2_7) variant: 1
-- Generic rest-stop tortoise villager. gardener: straw sun hat with sprig, denim bib, trowel.
local NAME = "folk-tortoise-1"

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
  skin = R("#bcc98c", "#93a666", "#667a52", "#434d4a"), shell = R("#e8b064", "#c07d3c", "#8a5236", "#57343c"),
  plas = R("#f4e2a4", "#dcbc72", "#a88654", "#6e5448"), style = "rings", nail = "#f2e6c4",
  cloth = R("#93b6d8", "#6188bc", "#465c92", "#323c66"), hat = R("#f8e6a4", "#e4c26c", "#b28c4e", "#765a42"),
  band = R("#b4dc74", "#78b04e", "#4a8048", "#33584a"), metal = R("#e4e8f0", "#adb4c6", "#747c98", "#4c4e68"),
  wood = R("#d89a5c", "#a8693c", "#734534", "#4e2e34"), btn = "#f2c75a", cheek = "#e8948c", cheekhi = "#f4b4a4",
  disc = R("#d4ecf4", "#a4cce4", "#74a2c8", "#4f78a4"),
}
local V = {}
V.clothes = function(c, p, b) -- denim dungaree bib with patch pocket
  local bib = c:rrect(25, 63 + b, 39, 81 + b, 2)
  c:part(bib, S.cloth, { band = 2, nopop = true })
  c:part(c:line({ { 26, 63 + b }, { 23, 57 + b } }, 2), S.cloth, { band = 1, nopop = true })
  c:part(c:line({ { 38, 63 + b }, { 41, 57 + b } }, 2), S.cloth, { band = 1, nopop = true })
  for x = 29, 35 do c:put(x, 68 + b, S.cloth.deep) end
  for y = 69, 73 do c:put(29, y + b, S.cloth.shade) c:put(35, y + b, S.cloth.shade) end
  for x = 30, 34 do c:put(x, 69 + b, S.cloth.hi) end
  for y = 64, 80, 2 do c:put(25, y + b, S.cloth.hi) end
  pts(c, { { 26, 64 + b }, { 38, 64 + b } }, S.btn)
  pts(c, { { 27, 78 + b }, { 28, 78 + b }, { 27, 79 + b } }, S.band.base) -- grass stain
end
V.propBack = function(c, p, b) c:part(c:rect(44, 59 + b, 46, 73 + b), S.wood, { band = 1, nopop = true }) c:put(44, 60 + b, S.wood.hi) end
V.propFront = function(c, p, b) -- trowel, point down
  local t = p.tw or 0
  c:part(c:rect(44, 74 + b, 46, 75 + b), S.metal, { band = 1, nopop = true })
  local bl = c:poly{ { 42, 76 + b }, { 48, 76 + b }, { 47 + t, 81 + b }, { 45 + t, 84 + b }, { 43 + t, 81 + b } }
  c:part(bl, S.metal, { band = 2, nopop = true })
  c:fillMask(c:line({ { 45, 76 + b }, { 45 + t, 82 + b } }, 1):clip(bl), S.metal.hi)
  c:put(44 + t, 82 + b, S.band.shade) -- crumb of soil
end
V.hat = function(c, p, b) -- wide straw sun hat, green band, sprig tucked in
  local hb, sw = b, (p.settle or 0) + (p.tw or 0)
  local brim = c:ellipse(32, 31 + hb, 19.5, 4.5)
  c:part(brim, S.hat, { band = 2, pop = { x = 15, y = 30 + hb } })
  brim:each(function(x, y) if (x + 2 * y) % 4 == 0 and c:get(x, y) == S.hat.base then c:put(x, y, S.hat.shade) end end)
  brim:each(function(x, y) if not brim:has(x, y + 1) then c:put(x, y, S.hat.deep) end end)
  local cr = c:ellipse(32, 23.5 + hb, 9, 5) cr:add(c:rect(23, 23 + hb, 41, 30 + hb))
  c:part(cr, S.hat, { band = 2, pop = { x = 27, y = 20 + hb } })
  cr:each(function(x, y) if (x + 2 * y) % 4 == 1 and y < 27 + hb and c:get(x, y) == S.hat.base then c:put(x, y, S.hat.shade) end end)
  for x = 23, 41 do c:put(x, 27 + hb, S.band.base) c:put(x, 28 + hb, x > 34 and S.band.deep or S.band.shade) end
  for x = 24, 40 do c:put(x, 30 + hb, S.hat.shade) end
  -- sprig: stem + three leaves, tips settle on breath
  c:fillMask(c:line({ { 40, 28 + hb }, { 44, 22 + hb } }, 1), S.band.deep)
  c:part(c:ellipse(46, 21 + hb + sw, 2.5, 1.5), S.band, { band = 1, nopop = true })
  c:part(c:ellipse(43, 19 + hb, 1.5, 2.5), S.band, { band = 1, nopop = true })
  c:part(c:ellipse(46.5, 25 + hb + sw, 2, 1.5), S.band, { band = 1, nopop = true })
  pts(c, { { 45, 20 + hb + sw }, { 43, 18 + hb } }, S.band.hi)
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
