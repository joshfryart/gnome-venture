-- cf_yi_balls.lua : Cat Fish Yarn panel icon `balls` (yarn ball colours, 1 Yarn each), 64x64, gvlib "icon"
-- mode, the house look of cf_icons.lua (helpers copied from it).
-- Run: AppRun -b --script cf_yi_balls.lua      Writes out/cf-yi-balls.png + .aseprite.
-- Drawing: a pile of three felt yarn balls (rose and mint at the bottom, gold on top), each wound with thread
-- grooves in two directions, and the gold ball's loose end curling off to the upper right. The triangle pile
-- silhouette keeps it apart from the single ball of cf-ico-yarn and the box of cf-up-toybox.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"

-- felt(hex): gvlib ramp with deep = shade and bounce = base (from cf_icons.lua)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
-- paint only on pixels owned by part P (not gloss, optionally lit felt only) (from cf_icons.lua)
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6", shade = "#9a2f5e" })
local MINT = felt("#4fb88a", { gloss = "#c8f0d8", dot = "#c8f0d8", rim = "#86d8b0", shade = "#2f8a6a" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = 11
local balls = {
  { "rose", 18, 43, ROSE },
  { "mint", 43, 43, MINT },
  { "gold", 30.5, 24, GOLD },
}
local loose = c:line({ {39, 20}, {45, 15}, {51, 15}, {54, 19}, {53, 24}, {49, 26}, {47, 22} }, 3)
local list = {}
for _, b in ipairs(balls) do
  list[#list + 1] = { b[1], c:ellipse(b[2], b[3], R), b[4], { cres = 4, gloss = { b[2] - 7, b[3] - 7 } } }
end
list[#list + 1] = { "loose", loose, GOLD, { cres = 1, deep = 0, gloss = false, contact = false } }
local p = c:build(list)

-- wound thread: grooves (shade) with a lit ridge (rim) just above-left, two winding directions per ball
for _, b in ipairs(balls) do
  local P, F, cx, cy = p[b[1]], b[4], b[2], b[3]
  -- band A: arcs round a centre off the lower right
  local ax, ay = cx + 13, cy + 9
  for _, r in ipairs({ 10, 14, 18 }) do
    onPart(c, c:ellipse(ax, ay, r + 1):cut(c:ellipse(ax, ay, r)), P, F.shade)
    onPart(c, c:ellipse(ax, ay, r + 2):cut(c:ellipse(ax, ay, r + 1)), P, F.rim, true)
  end
  -- band B: arcs round a centre off the upper right, only on the left part of the ball (crossing wrap)
  local bx, by = cx + 12, cy - 12
  for _, r in ipairs({ 15, 19 }) do
    local m = c:ellipse(bx, by, r + 1):cut(c:ellipse(bx, by, r)):clip(c:rect(0, 0, math.floor(cx) - 1, 63))
    onPart(c, m, P, F.shade)
  end
end
-- loose end: a twist line along the strand, a frayed tip
c:px(44, 16, GOLD.gloss); c:px(50, 15, GOLD.gloss)

local name = "cf-yi-balls"
local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24 and t.bw == 0, "check failed")
