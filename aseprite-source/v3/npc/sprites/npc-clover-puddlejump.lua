-- npc-clover-puddlejump sprite (npc2 P1_6) species: seven-spot ladybird beetle
-- Clover Puddlejump: bouncy young ladybird. Domed red elytra wrapping a gold vest, violet pronotum cap with
-- cream patches, green sweatband with knot tails, short elbowed club antennae, rubber boots.
-- prop: a lucky four-leaf clover held up in the right hand. 64x96 cell, idle x4.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-clover-puddlejump"
local RED = P.ember
local CAP = { hi = "#8a6fd0", base = "#5a459e", shade = "#35295f", deep = "#2a1f45" }
local PAT = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local VEST, BAND, LEAF = P.gold, P.moss, P.moss
local SPOT = "#35295f"
local function eye4(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ad, cl, kt = p.b or 0, p.ad or 0, p.cl or 0, p.kt or 0
  c:groundShadow(32, 88.5, 15, 3.5)
  -- domed elytra + gold vest front
  local shell = c:ellipse(32, 71 + b, 16, 13.5)
  c:part(shell, RED, { band = 3, pop = { x = 20, y = 64 + b } })
  for _, s in ipairs{ {20, 67}, {22, 77}, {44, 67}, {42, 78}, {25, 61}, {39, 61} } do
    c:ellipse(s[1], s[2] + b, 1.5, 1.5):clip(shell:shrink(1)):each(function(x, y) c:put(x, y, SPOT, "s") end)
  end
  local vest = c:ellipse(32, 77 + b, 8, 9):clip(shell)
  c:part(vest, VEST, { band = 2, pop = { x = 27, y = 71 + b } })
  for y = 70 + b, 84 + b do if vest:has(32, y) then c:put(32, y, VEST.shade) end end
  c:put(33, 74 + b, VEST.deep) c:put(33, 79 + b, VEST.deep)
  -- rubber boots (fixed)
  c:part(c:ellipse(27, 87.5, 4.5, 2.5), CAP, { band = 1, pop = { x = 24, y = 86 } })
  c:part(c:ellipse(37.5, 87.5, 4.5, 2.5), CAP, { band = 1, pop = { x = 35, y = 86 }, sep = true })
  -- arms
  c:part(c:ellipse(17, 73 + b, 2.5, 3), CAP, { band = 1, nopop = true })
  -- clover in right hand
  local cx, cy = 48 + cl, 60 + b + (p.cdy or 0)
  c:part(c:line({ {46, 71 + b}, {47, 66 + b}, {cx, cy + 2} }, 1), LEAF, { noshade = true, nopop = true })
  local lv = HP.mask()
  for _, o in ipairs{ {-2, -2}, {2, -2}, {-2, 2}, {2, 2} } do lv:add(c:ellipse(cx + o[1], cy + o[2], 1.8, 1.8)) end
  c:part(lv, LEAF, { band = 1, pop = { x = cx - 3, y = cy - 3 } })
  c:put(cx, cy, LEAF.deep)
  c:part(c:ellipse(46, 71 + b, 2.5, 2.5), CAP, { band = 1, nopop = true, sep = true })
  -- head: red face, violet pronotum cap with cream patches, green band
  local head = c:ellipse(32, 47 + b, 14.5, 12)
  c:part(head, RED, { band = 2, sep = true })
  local cap = head:copy():clip(c:rect(0, 0, 63, 43 + b))
  c:part(cap, CAP, { band = 2, pop = { x = 26, y = 37 + b } })
  c:part(c:ellipse(22, 40 + b, 2.5, 2):clip(cap), PAT, { band = 1, nopop = true })
  c:part(c:ellipse(42, 40 + b, 2.5, 2):clip(cap), PAT, { band = 1, nopop = true })
  local band = head:grow(1):clip(c:rect(0, 44 + b, 63, 46 + b))
  band:add(c:poly{ {44, 45 + b}, {46, 45 + b}, {50, 51 + b + kt}, {48, 52 + b + kt} })
  c:part(band, BAND, { band = 1, pop = { x = 20, y = 44 + b } })
  -- elbowed club antennae
  local an = c:line({ {27, 36 + b}, {25, 31 + b}, {21, 29 + b} }, 1)
  an:add(c:line({ {37, 36 + b}, {39, 31 + b}, {43, 29 + b + ad} }, 1))
  an:add(c:ellipse(20, 28 + b, 2, 2)):add(c:ellipse(44, 28 + b + ad, 2, 2))
  c:part(an, CAP, { band = 1, nopop = true })
  c:put(19, 27 + b, CAP.hi) c:put(43, 27 + b + ad, CAP.hi)
  -- face
  eye4(c, 24, 48 + b) eye4(c, 36, 48 + b)
  c:put(31, 52 + b, RED.shade) c:put(32, 52 + b, RED.shade) c:put(31, 51 + b, RED.hi)
  c:paint({ "i...i", ".iii." }, 30, 54 + b, { i = "ink" })
  for _, s in ipairs{ {20, 52}, {43, 52} } do c:fillMask(c:rect(s[1], s[2] + b, s[1] + 1, s[2] + 1 + b), SPOT) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { b = 0 }, { b = 1, kt = 1, cdy = 1 }, { b = 0 }, { b = 0, ad = -1, cl = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
