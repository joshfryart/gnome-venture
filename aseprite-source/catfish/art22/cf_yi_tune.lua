-- cf_yi_tune.lua : Cat Fish 2.2 Yarn panel icon "tune" (Rod Tune-up, 4 Yarn a run: one branch's milestone
-- doubles come earlier until the next Nap). 64x64, gvlib "icon" mode, house look of cf_icons.lua.
-- Picture: the cat-fishing wand standing upright (red grip, wooden stick, gold bead) with a turquoise
-- spanner clamped on its gold hex collar, the handle sticking out to the right with a rose yarn wrap
-- (the Yarn motif), and a gold 4-point sparkle top right ("tuned up"). Silhouette is a leaning "T",
-- not the X of cf-up-double; main colour turquoise, not the steel of cf-up-motor or violet of cf-up-spring.
-- Run: AppRun -b --script cf_yi_tune.lua     Writes out/cf-yi-tune.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- helpers copied from cf_icons.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function star(c, cx, cy, R, r, a)
  local pts = {}
  for i = 0, 7 do
    local ang = (a or 0) + i * math.pi / 4 - math.pi / 2
    local d = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + 0.5 + math.cos(ang) * d, cy + 0.5 + math.sin(ang) * d }
  end
  return c:poly(pts)
end
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local WOOD = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local RED = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ff9158", rim = "#f2793a", shade = "#ae2a2a" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6" })
local TEAL = felt("#2fb0aa", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#78d8c8", shade = "#1f7486" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- axes: u runs along the spanner (to the lower right), v along the rod (to the upper right)
local SQ = math.sqrt(0.5)
local ux, uy, vx, vy = SQ, SQ, SQ, -SQ
local HX, HY = 27.5, 31.5                                      -- spanner head / nut centre, on the rod
local function P(t, s) return { HX + ux * t + vx * s, HY + uy * t + vy * s } end
local function band(t0, t1, s0, s1) return c:poly({ P(t0, s0), P(t1, s0), P(t1, s1), P(t0, s1) }) end
local stick = c:line({ {17, 42}, {44, 15} }, 4)
local bead = c:ellipse(46, 13, 4.5)
local grip = c:line({ {10, 50}, {18, 42} }, 8)
local nut = c:mask()
do local pts = {} for i = 0, 5 do local a = i * math.pi / 3 + math.pi / 4
  pts[#pts + 1] = { HX + math.cos(a) * 5.2, HY + math.sin(a) * 5.2 } end nut = c:poly(pts) end
-- open-end jaw: a round head with a slot opening to the upper left, round the nut
local head = c:ellipse(HX, HY, 9.5):cut(band(-14, 0, -3.6, 3.6))
local handle = band(6, 21, -4, 4)
local ringC = P(24, 0)
local ring = c:ellipse(ringC[1], ringC[2], 6.5)
local hole = c:ellipse(ringC[1] + 0.5, ringC[2] + 0.5, 1.6)
local wrench = head:add(handle):add(ring):cut(hole)
local yarn = band(9.5, 18, -6, 6)
local big = star(c, 12, 13, 8, 2.6, 0)
local small = star(c, 52, 29, 4.5, 1.6, 0)
local p = c:build{
  { "stick", stick, WOOD, { cres = 2, deep = 0, gloss = false } },
  { "bead", bead, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "grip", grip, RED, { cres = 2, gloss = false } },
  { "nut", nut, GOLD, { cres = 2, gloss = false } },
  { "wrench", wrench, TEAL, { cres = 4, gloss = false } },
  { "yarn", yarn, ROSE, { cres = 2, gloss = false } },
  { "small", small, GOLD, { flat = true, contact = false } },
  { "big", big, GOLD, { flat = true, contact = false } },
}
c:fill(c:ellipse(HX + 0.5, HY + 0.5, 1.5), GOLD.shade)                   -- nut bore
-- yarn wrap strands: shade grooves across the band, every 2nd px along u
for _, t in ipairs({ 12.3, 15.3 }) do
  local a, b2 = P(t, -7), P(t, 7)
  local n = 16
  for i = 0, n do
    local x = math.floor(a[1] + (b2[1] - a[1]) * i / n + 0.5)
    local y = math.floor(a[2] + (b2[2] - a[2]) * i / n + 0.5)
    if c.own[c:key(x, y)] == p.yarn then c:px(x, y, ROSE.shade) end
  end
end
-- gold seam down the handle middle (stitched felt spanner)
do local a, b2 = P(5.5, 0), P(10, 0) c:seam({ { math.floor(a[1]), math.floor(a[2]) }, { math.floor(b2[1]), math.floor(b2[2]) } }, { gap = TEAL.shade }) end
-- grip wraps
for _, q in ipairs({ { 12, 48 }, { 15, 45 } }) do                           -- grip wraps
  for i = 0, 6 do local x, y = q[1] - 3 + i, q[2] - 3 + i
    if c.own[c:key(x, y)] == p.grip then c:px(x, y, RED.shade) end end
end
-- enamel commas and glints
c:paint({ "..gg", ".g..", "g...", "g..." }, 19, 30, { g = TEAL.gloss })
c:paint({ "gg", "g." }, 44, 10, { g = GOLD.gloss })
c:paint({ "...g", "..g.", ".g.." }, 37, 37, { g = TEAL.gloss })
c:paint({ "..g", ".g.", "g.." }, 9, 48, { g = RED.rim })
c:px(12, 13, GOLD.gloss); c:px(11, 12, GOLD.gloss)
local t = c:save(OUT .. "cf-yi-tune.aseprite", OUT .. "cf-yi-tune.png")
print("tune " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw == 0, "check failed")
