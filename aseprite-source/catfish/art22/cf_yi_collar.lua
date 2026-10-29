-- cf_yi_collar.lua : Cat Fish Yarn panel icon `collar` (collar tint, 2 Yarn per cat per colour), 64x64, gvlib
-- "icon" mode, the house look of cf_icons.lua (helpers copied from it).
-- Run: AppRun -b --script cf_yi_collar.lua      Writes out/cf-yi-collar.png + .aseprite.
-- Drawing: a round rose felt collar seen from a little above (thicker front band), gold stitch seam along
-- the band, a gold bell hanging from a gold tag ring at the front, a pink yarn bow (the Yarn panel motif)
-- on the left, and two small felt colour swatches (mint, sky) bottom right for "pick a tint".
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

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

local ROSE = felt("#c8406e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#e8789c", shade = "#8e2a5a" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local PINK = felt("#f08cb4", { gloss = "#ffe0ec", dot = "#ffe0ec", rim = "#ffb8d0", shade = "#c85a8e" })
local MINT = felt("#4fb88a", { gloss = "#c8f0d8", dot = "#c8f0d8", rim = "#86d8b0", shade = "#2f8a6a" })
local SKY = felt("#4f8fd8", { gloss = "#c8e4ff", dot = "#c8e4ff", rim = "#8cbcf0", shade = "#3a5fae" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local CX = 29.5
local band = c:ellipse(CX, 26, 22, 14):cut(c:ellipse(CX, 23, 15.5, 7.5))
local buckle = c:rrect(44, 25, 53, 34, 2)
local tag = c:rrect(27, 39, 32, 45, 2)
local bell = c:ellipse(CX, 51, 6, 5.5)
local loopL = c:poly({ {15, 37}, {8, 31}, {8, 43} }):grow(1)
local loopR = c:poly({ {16, 37}, {23, 31}, {23, 43} }):grow(1)
local knot = c:rrect(13, 35, 18, 40, 2)
local endA = c:line({ {14, 40}, {12, 47}, {13, 50} }, 3)
local endB = c:line({ {17, 40}, {19, 47} }, 3)
local sw1 = c:rrect(39, 46, 47, 54, 2)
local sw2 = c:rrect(47, 40, 55, 48, 2)
local p = c:build{
  { "band", band, ROSE, { cres = 4, gloss = { 13, 20 } } },
  { "buckle", buckle, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "tag", tag, GOLD, { flat = true, contact = false } },
  { "bell", bell, GOLD, { cres = 3, gloss = false, bounce = false } },
  { "endA", endA, PINK, { flat = true, contact = false } },
  { "endB", endB, PINK, { flat = true, contact = false } },
  { "loopL", loopL, PINK, { cres = 2, gloss = false } },
  { "loopR", loopR, PINK, { cres = 2, gloss = false } },
  { "knot", knot, PINK, { cres = 2, gloss = false } },
  { "sw2", sw2, SKY, { cres = 2, gloss = false } },
  { "sw1", sw1, MINT, { cres = 2, gloss = false } },
}
-- gold stitch seam along the middle of the band, round from the buckle and back to it
local pts = {}
for i = 0, 28 do
  local t = math.pi * 0.14 + i * (math.pi * 1.72) / 28
  pts[#pts + 1] = { CX + 18.5 * math.cos(t), 24.5 + 10.8 * math.sin(t) }
end
c:seam(pts, { gap = ROSE.shade })
-- buckle: frame window showing the band, prong across it
c:fill(c:rect(47, 28, 50, 31), ROSE.shade)
c:fill(c:rect(47, 29, 50, 30), ROSE.base)
c:paint({ "gggg" }, 46, 29, { g = GOLD.rim })
c:paint({ "gg", "g." }, 45, 26, { g = GOLD.gloss })
-- bell: slot across the middle, sound hole, glint
c:paint({ "ssssssssss" }, 25, 51, { s = GOLD.shade })
c:paint({ "hh", "hh" }, 29, 53, { h = C.hole })
c:paint({ "gg", "g." }, 26, 47, { g = GOLD.gloss })
-- wound yarn strands on the bow loops, knot glint
c:paint({ "s..", ".s.", "..s" }, 10, 34, { s = PINK.shade })
c:paint({ "s..", ".s.", "..s" }, 10, 38, { s = PINK.shade })
c:paint({ "..s", ".s.", "s.." }, 19, 34, { s = PINK.shade })
c:paint({ "..s", ".s.", "s.." }, 19, 38, { s = PINK.shade })
c:paint({ "gg", "g." }, 9, 32, { g = PINK.gloss })
c:px(14, 36, PINK.gloss)
-- swatches: stitched felt squares with a glint
c:seam({ { 41, 52 }, { 45, 52 } }, { gap = MINT.shade })
c:seam({ { 49, 46 }, { 53, 46 } }, { gap = SKY.shade })
c:paint({ "gg", "g." }, 41, 48, { g = MINT.gloss })
c:paint({ "gg", "g." }, 49, 42, { g = SKY.gloss })

local name = "cf-yi-collar"
local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24 and t.bw == 0, "check failed")
