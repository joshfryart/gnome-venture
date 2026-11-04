-- npc-lyra-fiddlewing sprite (npc2 P1_19) species: grasshopper
-- Lyra Fiddlewing: slim green grasshopper fiddler, big folded hind-leg knees, straw sun hat with red band, orange smock; prop: fiddle. idle x4.
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

local NAME = "npc-lyra-fiddlewing"
local GREEN = R("#c4e07a", "#86c05a", "#4f8a5a", "#33584f")
local MUZ   = R("#eef4a8", "#c2dc7c", "#86b266", "#4f8a5a")
local SHIRT = R("#ffd36a", "#f0a531", "#c06a3a", "#8a4140")
local STRAW = R("#ffeaa0", "#e8c060", "#b98a4a", "#7f5a42")
local BAND  = R("#ee6a62", "#c03a48", "#8a2a44", "#5e2040")
local WOOD  = R("#eaa262", "#b8683a", "#874437", "#5a2e34")
local KNOB  = R("#b49ae0", "#7a5fb8", "#5a4290", "#3e2e6a")
local CREAM = R("#fff1c8", "#f3e0b0", "#c8a890", "#8a6a70")
function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, st, tw = p.b or 0, p.st or 0, p.tw or 0
  c:groundShadow(32, 89.5, 14, 3)
  -- folded hind legs: femur up to a high knee, tibia back down to the ground
  for _, s in ipairs{ -1, 1 } do
    local hx, kx, fx = 32 + s * 6, 32 + s * 15, 32 + s * 11
    c:part(c:line({ { fx, 89 }, { kx + s * 0.5, 64 + b } }, 2), GREEN, { band = 1, nopop = true })
    local fem = c:line({ { hx, 79 + b }, { 32 + s * 11, 70 + b }, { kx, 63 + b } }, 4)
    c:part(fem, GREEN, { band = 1, pop = { x = kx - 1, y = 62 + b } })
    for i = 0, 2 do c:put(math.floor(fx + s * 0.5 - s * (i + 1) * 0.6), 87 - i * 7, GREEN.deep) end
  end
  -- small front feet
  c:part(c:ellipse(28, 88.5, 2.5, 1.5), GREEN, { band = 1, nopop = true })
  c:part(c:ellipse(36, 88.5, 2.5, 1.5), GREEN, { band = 1, nopop = true })
  c:part(c:rect(27, 83, 28, 87), GREEN, { band = 1, nopop = true })
  c:part(c:rect(36, 83, 37, 87), GREEN, { band = 1, nopop = true })
  -- smock
  c:part(c:ellipse(32, 75 + b, 9.5, 9), SHIRT, { band = 2, pop = { x = 26, y = 70 + b } })
  c:part(c:poly{ { 26, 67 + b }, { 32, 71 + b }, { 32, 73 + b }, { 25, 70 + b } }, CREAM, { band = 1, nopop = true })
  c:part(c:poly{ { 38, 67 + b }, { 32, 71 + b }, { 32, 73 + b }, { 39, 70 + b } }, CREAM, { band = 1, nopop = true })
  -- fiddle against the chest, neck up to the left; bow in right hand
  local fid = c:ellipse(35, 78 + b, 4, 3.5) fid:add(c:ellipse(34.5, 73.5 + b, 3, 2.5))
  c:part(fid, WOOD, { band = 1, pop = { x = 33, y = 72 + b } })
  c:put(33, 77 + b, WOOD.deep) c:put(37, 77 + b, WOOD.deep)
  c:part(c:line({ { 33, 71 + b }, { 27, 64 + b } }, 2), WOOD, { band = 1, nopop = true })
  c:part(c:ellipse(26.5, 63 + b, 1.5, 1.5), WOOD, { band = 1, nopop = true })
  for y = 73, 80 do c:put(35, y + b, CREAM.base) end
  c:fillMask(c:line({ { 46, 66 + b - tw }, { 27, 82 + b + tw } }, 1), WOOD.deep)
  c:part(c:ellipse(29, 67 + b, 2, 2), GREEN, { band = 1, nopop = true })
  c:part(c:ellipse(43, 71 + b, 2, 2), GREEN, { band = 1, nopop = true })
  -- head with side eye bulges, pale snout plate
  local head = c:ellipse(32, 52 + b, 11, 11)
  head:add(c:ellipse(21.5, 51 + b, 3, 4)) head:add(c:ellipse(42.5, 51 + b, 3, 4))
  c:part(head, GREEN, { band = 2, pop = { x = 23, y = 47 + b } })
  c:part(c:ellipse(32, 58 + b, 5.5, 4), MUZ, { band = 1, nopop = true })
  c:put(31, 61 + b, GREEN.deep) c:put(33, 61 + b, GREEN.deep)
  for _, q in ipairs{ { 29, 59 }, { 30, 60 }, { 34, 60 }, { 35, 59 } } do c:put(q[1], q[2] + b, P.ink) end
  if p.blink then
    for _, x in ipairs{ 21, 38 } do for i = 0, 4 do c:put(x + i, 51 + b, P.ink) end end
  else c:eyeLocked(21, 49 + b) c:eyeLocked(38, 49 + b) end
  c:cheek(25, 55 + b) c:cheek(38, 55 + b)
  -- straw sun hat: wide brim seen from above, crown, red band
  local brim = c:ellipse(32, 43 + b, 17, 4.5)
  c:part(brim, STRAW, { band = 2, pop = { x = 18, y = 42 + b } })
  for x = 16, 48, 3 do if brim:has(x, 45 + b) then c:put(x, 45 + b, STRAW.shade) end end
  local crown = c:rrect(25, 31 + b, 39, 43 + b, 4)
  c:part(crown, STRAW, { band = 2, pop = { x = 27, y = 33 + b } })
  for x = 24, 40 do if crown:has(x, 43 + b) then c:put(x, 43 + b, STRAW.deep) end end
  c:part(c:rect(25, 38 + b, 39, 40 + b), BAND, { band = 1, pop = { x = 26, y = 38 + b } })
  for x = 28, 36, 4 do c:put(x, 34 + b, STRAW.shade) end
  -- antenna knobs
  local tips = { { 22 - tw, 13 + b + st }, { 43 + tw, 13 + b + st } }
  for _, t in ipairs(tips) do c:part(c:ellipse(t[1], t[2], 1.8, 1.8), KNOB, { band = 1, pop = { x = t[1] - 1, y = t[2] - 1 } }) end
  c:finish{ outline = true }
  c:fillMask(c:line({ { 29, 30 + b }, { 25, 21 + b }, { tips[1][1] + 1, tips[1][2] + 2 } }, 1), P.ink)
  c:fillMask(c:line({ { 35, 30 + b }, { 39, 21 + b }, { tips[2][1] - 1, tips[2][2] + 2 } }, 1), P.ink)
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

