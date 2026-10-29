-- cf_yi_season.lua : Cat Fish Yarn panel icon `season` (Seasonal room, 3 Yarn per season: petals, fireflies,
-- leaves or flakes drift through the room in that season). 64x64 gvlib "icon" mode, house look of cf_icons.lua
-- (felt ramps, one crescent lower right, gloss comma, gold thread seams, umber contours, 1 px #000000 border).
-- Picture: a round felt badge sewn from four quarter panels, one per season, clockwise from top left:
-- spring (mint, pink blossom), summer (sky, gold sun), autumn (wheat, orange leaf), winter (violet, pale
-- flake). Gold seams run along the cross and round the rim; the hub where the panels meet is a little pink
-- yarn ball with a loose curling end (the Yarn panel motif). Silhouette: a full disc with a yarn tail.
-- Run: AppRun -b --script cf_yi_season.lua      Writes out/cf-yi-season.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- helpers copied from cf_icons.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function set(...) local s = {} for _, v in ipairs({ ... }) do s[v] = true end return s end
local function trace(c, pts, hex, on, skip)
  local seen, n = {}, 0
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local s = math.max(1, math.ceil(math.max(math.abs(x1 - x0), math.abs(y1 - y0))))
    for t = 0, s do
      local x, y = math.floor(x0 + (x1 - x0) * t / s + 0.5), math.floor(y0 + (y1 - y0) * t / s + 0.5)
      local k = y * 100 + x
      if not seen[k] then
        seen[k] = true; n = n + 1
        if (on == nil or on[c:get(x, y) or ""]) and not (skip and skip(n)) then c:px(x, y, hex) end
      end
    end
  end
end
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local MINT = felt("#6fbf7a", { gloss = "#d4f0b0", dot = "#d4f0b0", rim = "#9cd890", shade = "#3f8a62" })
local SKY = felt("#6fb4e0", { gloss = "#e0f4f0", dot = "#e0f4f0", rim = "#a0d4ec", shade = "#4a7cc0" })
local WHEAT = felt("#e8c27a", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#f5dca0", shade = "#c08a4a" })
local VIO = felt("#7a68c0", { gloss = "#d8c8ff", dot = "#d8c8ff", rim = "#a090dc", shade = "#4e3a8a" })
local ROSE = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb", shade = "#b04478" })
local LEAF = felt("#dc6f2c", { gloss = "#ffc27a", dot = "#ffc27a", rim = "#f2a860", shade = "#a8442a" })
local FLAKE = { gloss = "#f4fbff", dot = "#f4fbff", rim = "#f4fbff", base = "#e0ecf8", shade = "#b8c8e8" }
FLAKE.deep, FLAKE.bounce = FLAKE.shade, FLAKE.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local CX, CY = 30.5, 30.5
local disc = c:ellipse(CX, CY, 25)
local function quarter(x0, y0, x1, y1) return disc:copy():clip(c:rect(x0, y0, x1, y1)) end
local qTL, qTR = quarter(0, 0, 30, 30), quarter(31, 0, 63, 30)
local qBR, qBL = quarter(31, 31, 63, 63), quarter(0, 31, 30, 63)
local hub = c:ellipse(CX, CY, 6.5)
-- loose yarn end leaving the hub, crossing the autumn/winter seam and curling off the lower rim
local tail = c:line({ {33, 36}, {36, 44}, {40, 52}, {45, 57}, {50, 57}, {52, 53}, {49, 51} }, 2)

-- motifs (one per quarter, centred about 11 px out along each diagonal)
-- spring: five-petal blossom
local bloom = c:mask()
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  bloom:add(c:ellipse(18.5 + math.cos(a) * 3.6, 18.5 + math.sin(a) * 3.6, 2.6))
end
local bloomC = c:ellipse(18.5, 18.5, 1.5)
-- summer: sun disc with eight rays
local sunC = c:ellipse(42.5, 18.5, 4)
local rays = c:mask()
for i = 0, 7 do
  local a = i * math.pi / 4
  local ux, uy = math.cos(a), math.sin(a)
  local vx, vy = -uy, ux
  local function P(t, s) return { 43 + ux * t + vx * s, 19 + uy * t + vy * s } end
  rays:add(c:poly({ P(4.5, -2), P(8, 0), P(4.5, 2) }))
end
-- autumn: an orange leaf with a stem
local leaf = rell(c, 43, 42, 7, 4, -0.8)
local stem = c:line({ {37, 48}, {39, 46} }, 2)
-- winter: six-arm flake
local flake = c:mask()
for i = 0, 2 do
  local a = i * math.pi / 3 + math.pi / 2
  local dx, dy = math.cos(a) * 6, math.sin(a) * 6
  flake:add(c:line({ {18 - dx, 43 - dy}, {18 + dx, 43 + dy} }, 2))
end

local p = c:build{
  { "qTL", qTL, MINT, { light = disc, cres = 5, gloss = { 12, 14 } } },
  { "qTR", qTR, SKY, { light = disc, cres = 5, gloss = false } },
  { "qBL", qBL, VIO, { light = disc, cres = 5, gloss = false } },
  { "qBR", qBR, WHEAT, { light = disc, cres = 5, gloss = false } },
  { "rays", rays, GOLD, { flat = true, contact = false } },
  { "sun", sunC, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } },
  { "bloom", bloom, ROSE, { cres = 2, gloss = false, contact = false } },
  { "bloomC", bloomC, GOLD, { flat = true, contact = false } },
  { "stem", stem, LEAF, { flat = true, contact = false } },
  { "leaf", leaf, LEAF, { cres = 2, gloss = false, contact = false } },
  { "flake", flake, FLAKE, { flat = true, contact = false } },
  { "tail", tail, ROSE, { flat = true, contact = false } },
  { "hub", hub, ROSE, { cres = 3, gloss = false } },
}
-- gold seams along the cross and edge stitch round the rim
c:seam({ { CX - 0.5, 7 }, { CX - 0.5, 23 } }); c:seam({ { CX - 0.5, 38 }, { CX - 0.5, 54 } })
c:seam({ { 7, CY - 0.5 }, { 23, CY - 0.5 } }); c:seam({ { 38, CY - 0.5 }, { 54, CY - 0.5 } })
c:stitch(disc)
-- yarn wraps on the hub ball
local onH = set(ROSE.base, ROSE.rim)
trace(c, { {26, 28}, {30, 25}, {34, 27} }, ROSE.shade, onH)
trace(c, { {25, 32}, {30, 29}, {36, 31} }, ROSE.shade, onH)
trace(c, { {27, 35}, {31, 33}, {35, 34} }, ROSE.shade, onH)
c:paint({ "gg", "g." }, 26, 26, { g = ROSE.gloss })
-- leaf midrib, sun glint, flake glint
trace(c, { {39, 46}, {47, 38} }, LEAF.shade, set(LEAF.base, LEAF.rim))
c:paint({ "gg", "g." }, 40, 16, { g = GOLD.gloss })
local t = c:save(OUT .. "cf-yi-season.aseprite", OUT .. "cf-yi-season.png")
print("season " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24 and t.bw == 0, "check failed")
