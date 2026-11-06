-- npc-nettle-thornwhistle sprite (npc2 P1_23) species: field cricket
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
-- 4-tone form: base + shade band (part) + lit upper-left rim (hi) + deep underside (AO)
local function form(c, m, r, o)
  o = o or {}
  c:part(m, r, { band = o.band or 2, nopop = true, inner = o.inner, sep = o.sep })
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return m end
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local B, Sh = r.base:lower(), r.shade:lower()
  local hl, dp = {}, {}
  m:each(function(x, y)
    local v = c:get(x, y)
    if v == B and not m:has(x - 1, y - 1) and x <= cx and y <= cy then hl[#hl + 1] = { x, y } end
    if o.under ~= false and not m:has(x, y + 1) and (v == B or v == Sh) then dp[#dp + 1] = { x, y } end
  end)
  for _, q in ipairs(hl) do keep(c, q[1], q[2], r.hi) end
  for _, q in ipairs(dp) do keep(c, q[1], q[2], r.deep) end
  if o.pop then for _, q in ipairs(o.pop) do keep(c, q[1], q[2], r.hi) end end
  return m
end
local function eyeS(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade:lower() then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- fern frond along a polyline (base -> tip), opposite pinnae shrinking toward the tip
local function fernMask(c, pts, L, w, skipTip)
  local stem, leaves, sm = c:line(pts, 1), HP.mask(), {}
  for i = 1, #pts - 1 do local a, b = pts[i], pts[i + 1]
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]), 1)
    for s = 0, n - 1 do sm[#sm + 1] = { a[1] + (b[1] - a[1]) * s / n, a[2] + (b[2] - a[2]) * s / n, (b[1] - a[1]) / n, (b[2] - a[2]) / n } end end
  local N = #sm - (skipTip or 0)
  for k = 2, N, 2 do local q = sm[k]
    local f = 1 - k / #sm
    local len = math.max(1, math.floor(L * (0.35 + 0.65 * f) + 0.5))
    local d = math.sqrt(q[3] ^ 2 + q[4] ^ 2) local dx, dy = q[3] / d, q[4] / d
    for _, s in ipairs{ -1, 1 } do
      leaves:add(c:line({ { q[1], q[2] }, { q[1] - dy * s * len + dx * len * 0.5, q[2] + dx * s * len + dy * len * 0.5 } }, w))
    end
  end
  return stem, leaves
end
local SKIN  = { hi = "#cfe08e", base = "#8fb35c", shade = "#5e8462", deep = "#3b5258" }
-- Lanky field cricket musician: long antennae with bobble tips, bead circlet, folded brown wings flaring
-- past the hips, big bent jumping legs, gold shirt with cream collar. Prop: a thorn-wood whistle.
local NAME = "npc-nettle-thornwhistle"
local GRN  = { hi = "#c4e07a", base = "#76bb4e", shade = "#43885a", deep = "#2b5250" }
local PL   = { hi = "#eef5b0", base = "#c4e07a", shade = "#8fbf62", deep = "#43885a" }
local WING = { hi = "#d9c08a", base = "#a88a58", shade = "#76604e", deep = "#4c3c44" }
local GOLD = { hi = "#ffe38a", base = "#f5b82e", shade = "#c97a3a", deep = "#7d4a3e" }
local CR   = { hi = P.cream, base = "#f3e6c8", shade = "#c9c2cc", deep = "#8e8aa0" }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, st, tw = p.b or 0, p.st or 0, p.tw or 0
  c:groundShadow(32, 90, 14, 3)
  for _, s in ipairs{ -1, 1 } do                -- folded wings behind
    local w = c:poly{ {32+s*5,58+b},{32+s*11,60+b},{32+s*16,80+b},{32+s*13,83+b},{32+s*7,72+b} }
    form(c, w, WING)
    c:line({ {32+s*9,63+b},{32+s*13,79+b} }, 1):clip(w:shrink(1)):each(function(x, y) keep(c, x, y, WING.shade) end)
  end
  for _, s in ipairs{ -1, 1 } do                -- jumping legs (fixed): thigh up to a knee, shin down
    local fx = 32 + s * 8
    form(c, c:line({ {32+s*6,77},{32+s*12,69},{32+s*14,64} }, 4):add(c:ellipse(32+s*14, 64, 2, 2)), GRN)
    form(c, c:line({ {32+s*14,67},{32+s*11,78},{fx,85} }, 2), GRN, { under = false })
    form(c, c:ellipse(fx + s, 87.5, 3.5, 2.5), GRN)
  end
  -- shirt + collar
  form(c, c:ellipse(32, 70 + b, 9.5, 11), GOLD, { band = 3 })
  form(c, c:poly{ {29,58+b},{35,58+b},{32,64+b} }, GRN, { under = false })
  form(c, c:poly{ {25,59+b},{31,59+b},{30,65+b} }, CR) form(c, c:poly{ {33,59+b},{39,59+b},{34,65+b} }, CR)
  for _, y in ipairs{ 69, 74 } do c:put(32, y + b, P.cream) c:put(32, y + 1 + b, GOLD.deep) end
  -- tiny arms
  form(c, c:ellipse(22, 67 + b, 2.5, 4), GRN) form(c, c:ellipse(22, 71 + b, 2, 1.5), GRN)
  form(c, c:ellipse(42, 66 + b, 2.5, 3.5), GRN)
  -- antennae (behind head) with bobble tips
  c:fillMask(c:line({ {28,33+b},{24,22+b},{20,13+b+st} }, 1), GRN.shade)
  c:fillMask(c:line({ {36,33+b},{40,22+b},{44+tw,13+b+st} }, 1), GRN.shade)
  form(c, c:ellipse(19, 11 + b + st, 2, 2), GRN) form(c, c:ellipse(45 + tw, 11 + b + st, 2, 2), GRN)
  -- head
  local hd = c:ellipse(32, 43 + b, 14.5, 12.5)
  form(c, hd, GRN, { band = 3, pop = { {22,35+b},{23,35+b},{22,36+b} } })
  -- bead circlet (curves down at the front)
  local BEAD = { P.petal, P.gold, P.dusk, P.ember, P.sea }
  for x = 18, 46 do
    local y = 34 + math.floor(2.5 * math.sqrt(math.max(0, 1 - ((x - 32) / 14.5) ^ 2)) + .5) + b
    if hd:has(x, y) then keep(c, x, y, P.wood.deep) end
  end
  for i, x in ipairs{ 21, 26, 32, 38, 43 } do
    local y = 34 + math.floor(2.5 * math.sqrt(math.max(0, 1 - ((x - 32) / 14.5) ^ 2)) + .5) + b
    local bm = c:ellipse(x, y, 1.5, 1.5)
    c:part(bm, BEAD[i], { band = 1, nopop = true })
    local bx, by = bm:bbox() c:put(bx + 1, by, BEAD[i].hi)
  end
  -- face: plate snout + mandibles + smile
  form(c, c:poly{ {29,44+b},{36,44+b},{35,50+b},{30,50+b} }, PL, { under = false })
  keep(c, 30, 51 + b, P.wood.shade) keep(c, 34, 51 + b, P.wood.shade)
  for _, q in ipairs{ {29,52},{30,53},{31,53},{32,53},{33,53},{34,53},{35,52} } do c:put(q[1], q[2] + b, P.ink) end
  eyeS(c, 22, 40 + b, p.blink) eyeS(c, 39, 40 + b, p.blink)
  c:cheek(20, 47 + b) c:cheek(42, 47 + b)
  -- thorn-wood whistle (prop) in the right hand
  local wh = c:line({ {39,71+b},{50,62+b+tw} }, 3)
  wh:set(44, 65 + b) wh:set(47, 62 + b + tw)
  form(c, wh, P.wood, { band = 1 })
  keep(c, 42, 68 + b, P.wood.deep) keep(c, 45, 66 + b + tw, P.wood.deep)
  form(c, c:ellipse(42, 69 + b, 2, 2), GRN)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = { frame{ b = 0 }, frame{ b = 1, st = 1 }, frame{ b = 0 }, frame{ b = 0, blink = true, tw = -1 } }
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
