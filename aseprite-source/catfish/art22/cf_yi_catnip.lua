-- cf_yi_catnip.lua : Cat Fish Yarn panel icon "catnip" (Catnip Hour: 1 Yarn a day, taps pay x2 for an hour).
-- 64x64, gvlib "icon" mode, house look of cf_icons.lua (cf-up-*): felt ramps, one crescent, gloss comma,
-- gold thread seams, umber contours, 1 px #000000 border.
-- Picture: a wooden hourglass whose sand is green catnip (pile below, remnant above, a falling stream), a
-- catnip leaf pair sprouting from the top cap, pink yarn tied round the waist (the Yarn panel motif) and two
-- stacked gold 4-point sparkles at the right for "x2". Unlike cf-up-catnip (a green sprig) the hourglass is the
-- main shape.
-- Run: AppRun -b --script cf_yi_catnip.lua     Writes out/cf-yi-catnip.png + .aseprite.
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

-- ramps (shared with cf_icons.lua)
local WOOD = felt("#b07a45", { gloss = "#ecc58a", dot = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })
local LEAF = felt("#5aa83c", { gloss = "#d4ec8a", dot = "#d4ec8a", rim = "#8ccc5a", shade = "#2f7a3a" })
local GLASS = felt("#a9d6ea", { gloss = "#eef8f2", dot = "#eef8f2", rim = "#d4ecf4", shade = "#6f98c4" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx = 23.5
local leafL = rell(c, 16.5, 10, 7, 3.5, -0.35)
local leafR = rell(c, 30.5, 10, 7, 3.5, 0.35)
for _, lf in ipairs({ leafL, leafR }) do                                  -- toothed top edge
  lf:edge():each(function(x, y) if ((x + 2 * y) % 5 == 0) and y < 10 then lf:del(x, y) end end)
end
local glass = c:poly({ {11, 17}, {36, 17}, {36, 22}, {26, 32}, {26, 35}, {36, 45}, {36, 51}, {11, 51},
                       {11, 45}, {21, 35}, {21, 32}, {11, 22} })
local postL = c:rect(7, 17, 9, 50)
local postR = c:rect(37, 17, 39, 50)
local capT = c:rrect(5, 12, 41, 17, 2)
local capB = c:rrect(5, 50, 41, 56, 2)
local inner = glass:shrink(2)
local pile = c:ellipse(cx, 52, 12, 8):clip(inner)
local rem = c:poly({ {13, 25}, {35, 25}, {26, 33}, {21, 33} }):clip(inner)
local stream = c:rect(23, 33, 24, 46)
local yarn = c:rrect(18, 31, 29, 36, 2)
local loose = c:line({ {29, 35}, {32, 38}, {33, 42}, {31, 44} }, 2)
local big = star(c, 50, 15, 6.5, 2.3, 0)
local small = star(c, 50, 31, 4.5, 1.6, 0)

local p = c:build{
  { "leafL", leafL, LEAF, { cres = 2, gloss = false } },
  { "leafR", leafR, LEAF, { cres = 2, gloss = false } },
  { "postL", postL, WOOD, { cres = 1, deep = 0, gloss = false } },
  { "postR", postR, WOOD, { cres = 1, deep = 0, gloss = false } },
  { "glass", glass, GLASS, { cres = 3, gloss = false } },
  { "rem", rem, LEAF, { cres = 2, gloss = false, contact = false } },
  { "stream", stream, LEAF, { flat = true, contact = false } },
  { "pile", pile, LEAF, { cres = 3, gloss = false, contact = false } },
  { "capT", capT, WOOD, { cres = 2, gloss = { 8, 13 } } },
  { "capB", capB, WOOD, { cres = 3, gloss = { 8, 51 } } },
  { "loose", loose, PINK, { flat = true, contact = false } },
  { "yarn", yarn, PINK, { cres = 2, gloss = false } },
  { "small", small, GOLD, { cres = 1, gloss = false, bounce = false, contact = false } },
  { "big", big, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } },
}
-- glass glints (upper-left of each bulb)
c:paint({ "ggg", "g..", "g.." }, 13, 19, { g = GLASS.gloss })
c:paint({ "g", "g" }, 13, 46, { g = GLASS.gloss })
-- catnip leaf specks in the pile
c:paint({ ".r.", "rr." }, 17, 47, { r = LEAF.rim })
c:paint({ ".r", "r." }, 27, 46, { r = LEAF.rim })
-- yarn wraps
for _, x in ipairs({ 21, 24, 27 }) do onPart(c, c:line({ {x, 32}, {x + 1, 35} }, 1), p.yarn, PINK.shade) end
c:px(19, 32, PINK.gloss); c:px(20, 32, PINK.gloss)
-- leaf midribs, cap seams
c:seam({ { 22, 11 }, { 16, 10 }, { 11, 9 } }, { gap = LEAF.shade })
c:seam({ { 25, 11 }, { 31, 10 }, { 36, 9 } }, { gap = LEAF.shade })
c:seam({ { 8, 15 }, { 38, 15 } }, { gap = WOOD.shade })
c:seam({ { 8, 53 }, { 38, 53 } }, { gap = WOOD.shade })
-- star glints
c:px(49, 14, GOLD.gloss); c:px(50, 14, GOLD.gloss); c:px(49, 30, GOLD.gloss)

local t = c:save(OUT .. "cf-yi-catnip.aseprite", OUT .. "cf-yi-catnip.png")
print("catnip " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
