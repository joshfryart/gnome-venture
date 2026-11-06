-- npc-lark-fernsway sprite (npc2 P1_19) species: rhinoceros beetle
-- Lark Fernsway: round young rhino beetle, brown split shell, nub horn, fern-green scarf; prop: fern frond. idle x4.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function bz(a, b, cc, t) local u = 1 - t
  return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end

local NAME = "npc-lark-fernsway"
local SHELL = R("#c98a52", "#9a5f36", "#6e3f45", "#4a2a3c")
local HORN  = R("#ecb878", "#c08048", "#86504a", "#4a2a3c")
local BELLY = R("#f2dba2", "#d9b378", "#a8806a", "#7a5560")
local FERN  = R("#c2dc6e", "#6fae48", "#3f7a4e", "#2f4f4a")
local LEG   = R("#8a5a44", "#5e3b3a", "#432a36", "#34202e")
local GOLD  = "#f0c050"
function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, st, tw = p.b or 0, p.st or 0, p.tw or 0
  c:groundShadow(32, 89.5, 13, 3)
  c:part(c:ellipse(27, 88, 3.5, 2), LEG, { band = 1, pop = { x = 25, y = 87 } })
  c:part(c:ellipse(37, 88, 3.5, 2), LEG, { band = 1, pop = { x = 35, y = 87 } })
  -- body shell + belly plates
  c:part(c:ellipse(32, 74 + b, 12, 11), SHELL, { band = 2, pop = { x = 23, y = 69 + b } })
  local belly = c:ellipse(32, 76 + b, 7, 8)
  c:part(belly, BELLY, { band = 2, nopop = true })
  for _, y in ipairs{ 72, 76, 80 } do for x = 26, 38 do
    if belly:has(x, y + b - 1) and belly:has(x, y + b + 1) and belly:has(x - 1, y + b) and belly:has(x + 1, y + b) then c:put(x, y + b, BELLY.shade) end end end
  c:part(c:ellipse(19.5, 73 + b, 2.5, 4), SHELL, { band = 1, nopop = true })
  -- fern frond prop (tip settles / twitches)
  local A, Bq, C = { 46, 82 + b }, { 46, 66 + b }, { 50 + tw, 51 + b + st }
  local sp = {} for i = 0, 10 do local x, y = bz(A, Bq, C, i / 10) sp[#sp + 1] = { x, y } end
  local leaves = HP.mask()
  for i = 1, 6 do
    local t = 0.28 + i * 0.11
    local x, y = bz(A, Bq, C, t)
    local s = (i % 2 == 0) and 1 or -1
    local sz = 3.6 - i * 0.38
    leaves:add(oval(x + s * (sz + 0.3), y - 0.6, sz, 1.3, -s * 28))
  end
  leaves:add(oval(C[1], C[2] + 0.5, 1.2, 2, 0))
  c:part(leaves, FERN, { band = 1, pop = { x = 46, y = 62 + b } })
  c:fillMask(c:line(sp, 1):clip(c:rect(0, 0, 63, 79 + b)), FERN.deep)
  c:part(c:ellipse(44.5, 72 + b, 2.5, 3.5), SHELL, { band = 1, nopop = true })
  c:part(c:ellipse(45.5, 75 + b, 2, 1.6), LEG, { band = 1, nopop = true })
  -- head: shell crown seen from above, tan face plate, nub horn
  local head = c:ellipse(32, 47 + b, 14.5, 13)
  c:part(head, SHELL, { band = 2, pop = { x = 23, y = 39 + b } })
  for y = 35, 44 do c:put(32, y + b, SHELL.deep) end
  for _, y in ipairs{ 37, 40, 43 } do c:put(33, y + b, GOLD) end
  c:part(c:ellipse(32, 54 + b, 9, 5), BELLY, { band = 1, nopop = true })
  c:part(c:poly{ { 30, 55 + b }, { 35, 55 + b }, { 35, 49 + b }, { 34, 46 + b }, { 32, 47 + b }, { 31, 50 + b } }, HORN, { band = 1, pop = { x = 33, y = 48 + b } })
  if p.blink then
    for _, x in ipairs{ 23, 36 } do for i = 0, 4 do c:put(x + i, 47 + b, P.ink) end end
  else c:eyeLocked(23, 45 + b) c:eyeLocked(36, 45 + b) end
  for _, q in ipairs{ { 29, 57 }, { 30, 58 }, { 31, 58 }, { 32, 58 }, { 33, 58 }, { 34, 58 }, { 35, 57 } } do c:put(q[1], q[2] + b, P.ink) end
  c:cheek(21, 52 + b) c:cheek(41, 52 + b)
  -- fern scarf + knot tail
  c:part(c:rrect(20, 59 + b, 44, 63 + b, 2), FERN, { band = 1, pop = { x = 22, y = 60 + b } })
  c:part(c:poly{ { 22, 61 + b }, { 26, 62 + b }, { 25, 70 + b + st }, { 21, 69 + b + st } }, FERN, { band = 1, nopop = true })
  for x = 22, 42, 3 do c:put(x, 61 + b, FERN.shade) end
  -- fan-club antennae tips
  local tips = { { 20 - tw, 25 + b + st }, { 44 + tw, 25 + b + st } }
  for _, t in ipairs(tips) do
    local m = c:rect(t[1] - 1, t[2] - 2, t[1] + 1, t[2] + 1)
    c:part(m, HORN, { band = 1, nopop = true })
    c:put(t[1], t[2] - 1, HORN.deep) c:put(t[1], t[2], HORN.deep)
  end
  c:finish{ outline = true }
  c:fillMask(c:line({ { 27, 35 + b }, { 23, 30 + b }, { tips[1][1] + 1, tips[1][2] + 3 } }, 1), P.ink)
  c:fillMask(c:line({ { 37, 35 + b }, { 41, 30 + b }, { tips[2][1] - 1, tips[2][2] + 3 } }, 1), P.ink)
  return c
end

local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
local function export(frames)
  local W, H, N = 64, 96, #frames
  local strip = Image(W*N, H, ColorMode.RGB) strip:clear(pc.rgba(0,0,0,0))
  local spr = Sprite(W, H, ColorMode.RGB)
  for _ = 2, N do spr:newEmptyFrame() end
  for f, c in ipairs(frames) do
    local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0,0,0,0))
    for i, hex in pairs(c.pix) do local col = rgba(hex) im:putPixel(i % W, i // W, col) strip:putPixel((f-1)*W + i % W, i // W, col) end
    spr:newCel(spr.layers[1], spr.frames[f], im, Point(0,0))
    spr.frames[f].duration = (f == 1 or f == 3) and 0.5 or 0.35
  end
  local tg = spr:newTag(1, N) tg.name = "idle"
  spr:saveAs(out .. NAME .. ".aseprite") spr:close()
  local s2 = Sprite(W*N, H, ColorMode.RGB) s2.cels[1].image = strip s2:saveCopyAs(out .. NAME .. ".png") s2:close()
  print(NAME .. ": " .. N .. " frames -> " .. out)
end
local IDLE = { { b = 0 }, { b = 1, st = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(IDLE) do local c = frame(p) HP.assertClean(c) frames[#frames+1] = c end
export(frames)

