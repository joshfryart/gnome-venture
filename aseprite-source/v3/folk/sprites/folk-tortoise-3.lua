-- folk-tortoise-3 sprite (folk F2_7) variant: 3
-- Generic rest-stop tortoise villager. cook: polka kerchief with bow, apron, soup ladle.
local NAME = "folk-tortoise-3"

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
  skin = R("#e6cc96", "#c4a068", "#8f6e50", "#5e4644"), shell = R("#86644c", "#5c4038", "#432e34", "#2f222c"),
  ray = R("#f2d26a", "#c89c44", "#8e6838", "#5c4038"),
  plas = R("#f4e4b4", "#d8be82", "#a88c62", "#6e5a52"), style = "star", nail = "#f6ead0",
  apron = R("#fbf3dc", "#ece0c4", "#c4b4b0", "#8c7c8c"), kerch = R("#f4a066", "#d6693e", "#9e4638", "#66303a"),
  rose = R("#f8b4bc", "#e2808e", "#b05a74", "#7a3e5c"), copper = R("#f8b484", "#d27a4c", "#984a40", "#62303a"),
  soup = R("#fbd27a", "#e8963e", "#b65e34", "#7e3c34"), steam = "#e6dcec",
  cheek = "#ec8c86", cheekhi = "#f8b0a0", disc = R("#fde0e2", "#f2aab2", "#d07c8e", "#a0566e"),
}
local V = {}
V.clothes = function(c, p, b) -- cream apron with scalloped hem, rose ties, heart pocket
  local ap = c:poly{ { 24, 59 + b }, { 40, 59 + b }, { 43, 81 + b }, { 21, 81 + b } }
  c:part(ap, S.apron, { band = 2, nopop = true })
  for x = 21, 43 do if x % 3 == 0 then c:put(x, 81 + b, S.apron.deep) end end
  for y = 70, 80, 2 do c:put(27, y + b, S.apron.shade) c:put(37, y + 1 + b, S.apron.shade) end
  c:part(c:rect(20, 66 + b, 44, 67 + b), S.rose, { band = 1, nopop = true })
  c:part(c:ellipse(46, 69 + b, 1.5, 1.5), S.rose, { band = 1, nopop = true })
  pts(c, { { 30, 72 + b }, { 32, 72 + b }, { 29, 73 + b }, { 30, 73 + b }, { 31, 73 + b }, { 32, 73 + b }, { 33, 73 + b }, { 30, 74 + b }, { 31, 74 + b }, { 32, 74 + b }, { 31, 75 + b } }, S.rose.base)
  c:put(30, 72 + b, S.rose.hi)
end
V.collar = function(c, p, b)
  c:fillMask(c:line({ { 25, 59 + b }, { 28, 52 + b } }, 1), S.rose.shade)
  c:fillMask(c:line({ { 39, 59 + b }, { 36, 52 + b } }, 1), S.rose.shade)
end
V.propBack = function(c, p, b) -- soup ladle held up, drip falling
  c:part(c:line({ { 46, 72 + b }, { 48, 58 + b }, { 49, 52 + b } }, 2), S.copper, { band = 1, nopop = true })
  local bowl = c:ellipse(50, 49 + b, 4.5, 3)
  c:part(bowl, S.copper, { band = 2, nopop = true })
  for x = 47, 53 do c:put(x, 47 + b, S.soup.base) end
  pts(c, { { 48, 47 + b }, { 49, 47 + b } }, S.soup.hi)
  c:put(47, 48 + b, S.copper.hi)
  local d = (p.tw or 0) + (p.settle or 0)
  c:put(54, 51 + b + d, S.soup.base) if d == 0 then c:put(54, 50 + b, S.soup.base) end
end
V.hat = function(c, p, b) -- polka-dot kerchief with a bow knot on top
  local k = c:ellipse(32, 33 + b, 14.5, 8.5):clip(c:rect(0, 0, 63, 35 + b))
  c:part(k, S.kerch, { band = 2, pop = { x = 23, y = 29 + b } })
  for x = 17, 47 do if k:has(x, 35 + b) then c:put(x, 35 + b, S.kerch.deep) end end
  k:each(function(x, y) if (x + 3 * y) % 6 == 0 and y < 34 + b and k:has(x + 1, y) and c:get(x, y) ~= S.kerch.deep then c:put(x, y, CREAM) end end)
  local t = p.tw or 0
  local bow = c:ellipse(39, 23 + b, 3, 2) bow:add(c:ellipse(45, 22 + b - t, 3, 2))
  c:part(bow, S.kerch, { band = 1, nopop = true })
  c:part(c:ellipse(42, 24 + b, 1.5, 1.5), S.kerch, { band = 1, nopop = true })
  pts(c, { { 38, 22 + b }, { 44, 21 + b - t } }, S.kerch.hi)
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
