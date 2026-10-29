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
local TEAL = felt("#2fb0aa", { gloss = "#d8fff0", dot = "#d8fff0", rim = "#78d8c8", shade = "#1f7486" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local RX = 20                                                  -- rod centre column (x RX..RX+3)
local stick = c:rect(RX, 13, RX + 3, 45)
local bead = c:ellipse(RX + 1.5, 11, 4)
local grip = c:rrect(RX - 4, 44, RX + 7, 55, 3)
local nut = c:poly({ {RX - 3, 30}, {RX + 7, 30}, {RX + 9, 34}, {RX + 7, 39}, {RX - 3, 39}, {RX - 5, 34} })
-- spanner: open-jaw head round the nut (opening to the left), handle to the right, ring end with a hole
local hcx, hcy = RX + 2, 34.5
local head = c:ellipse(hcx, hcy, 11, 10):cut(c:rect(hcx - 13, 31, hcx - 3, 38)):cut(nut:grow(0))
local handle = c:rrect(RX + 10, 31, 48, 38, 2)
local ring = c:ellipse(49, 34.5, 6.5):cut(c:ellipse(49.5, 34.5, 2))
local wrench = head:add(handle):add(ring)
local yarn = c:rrect(35, 29, 43, 40, 2)
local big = star(c, 45, 15, 7, 2.4, 0)
local small = star(c, 34, 22, 4, 1.5, 0)
local p = c:build{
  { "stick", stick, WOOD, { cres = 2, deep = 0, gloss = false } },
  { "bead", bead, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "grip", grip, RED, { cres = 3, gloss = { RX - 2, 46 } } },
  { "nut", nut, GOLD, { cres = 2, gloss = false } },
  { "wrench", wrench, TEAL, { cres = 4, gloss = false } },
  { "yarn", yarn, ROSE, { cres = 3, gloss = false } },
  { "small", small, GOLD, { flat = true, contact = false } },
  { "big", big, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } },
}
-- grip wraps
for _, y in ipairs({ 49, 52 }) do onPart(c, c:rect(RX - 3, y, RX + 6, y), p.grip, RED.shade, true) end
-- yarn wrap strands: diagonal shade grooves, lit ridge beside them
for i = 0, 3 do
  local x0 = 35 + i * 3
  for d = 0, 11 do
    local x, y = x0 + math.floor(d / 4), 29 + d
    local k = c:key(x, y)
    if c.own[k] == p.yarn then c:px(x, y, ROSE.shade) end
    local k2 = c:key(x - 1, y)
    if c.own[k2] == p.yarn and not c.shd[k2] then c:px(x - 1, y, ROSE.rim) end
  end
end
-- loose yarn end curling down from the wrap
-- gold seam along the handle (stitched felt spanner)
c:seam({ { RX + 11, 37 }, { 33, 37 } }, { gap = TEAL.shade })
c:seam({ { 44, 37 }, { 45, 37 } }, { gap = TEAL.shade })
-- nut facet line and gloss
c:paint({ "gg", "g." }, RX - 2, 31, { g = GOLD.gloss })
-- enamel commas
c:paint({ "..ggg", ".g...", "g...." }, RX - 6, 26, { g = TEAL.gloss })
c:paint({ "gggg", "g..." }, RX + 12, 32, { g = TEAL.gloss })
c:paint({ "gg", "g." }, RX - 1, 8, { g = GOLD.gloss })
c:px(45, 15, GOLD.gloss); c:px(44, 14, GOLD.gloss)

local t = c:save(OUT .. "cf-yi-tune.aseprite", OUT .. "cf-yi-tune.png")
print("tune " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw == 0, "check failed")
