-- cf-yi-stake.lua : Cat Fish Yarn panel icon `stake` (Stakeout: tomorrow's shelter looks harder for the coat
-- you pick). 64x64 gvlib "icon" mode, house look of cf_icons.lua (felt ramps, one crescent, gloss comma,
-- gold thread seams, umber contours, 1 px #000000 border).
-- Subject: a pair of teal felt binoculars seen from the front, two big sky-glass lenses in gold rims, eyepieces
-- peeking up behind, a gold focus wheel on the bridge, on a rose yarn strap looped over the top
-- (the yarn accent shared by the Yarn panel icons).
-- Run: AppRun -b --script cf-yi-stake.lua      Writes out/cf-yi-stake.png + .aseprite.
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
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6" })
local TEAL = felt("#2f9a8a", { gloss = "#c8f0d8", dot = "#c8f0d8", rim = "#6cc4a8", shade = "#1f6a6e" })
local GLASS = felt("#5aa8d8", { gloss = "#eef8f2", dot = "#eef8f2", rim = "#9cd4ec", shade = "#3a6aa8" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local LX, RX, LY = 19, 44, 40                                    -- lens centres
-- yarn strap: a rose yarn loop over the top, from eyepiece to eyepiece
local strap = c:line({ {14, 21}, {15, 15}, {20, 11}, {26, 9}, {37, 9}, {43, 11}, {48, 15}, {49, 21} }, 3)
local eyeL = c:rrect(13, 18, 25, 30, 3)                          -- eyepieces behind
local eyeR = c:rrect(38, 18, 50, 30, 3)
local bridge = c:rrect(25, 29, 38, 40, 3)
local wheel = c:rrect(27, 22, 36, 30, 2)                         -- focus wheel on top of the bridge
local barL = c:ellipse(LX, LY, 11.5, 11)
local barR = c:ellipse(RX, LY, 11.5, 11)
local ringL = c:ellipse(LX, LY + 1, 8.5, 8)
local ringR = c:ellipse(RX, LY + 1, 8.5, 8)
local glassL = c:ellipse(LX, LY + 1, 6, 5.5)
local glassR = c:ellipse(RX, LY + 1, 6, 5.5)
local p = c:build{
  { "strap", strap, ROSE, { flat = true, contact = false } },
  { "eyeL", eyeL, TEAL, { cres = 3, gloss = { 15, 20 } } },
  { "eyeR", eyeR, TEAL, { cres = 3, gloss = { 40, 20 } } },
  { "wheel", wheel, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "bridge", bridge, TEAL, { cres = 3, gloss = false } },
  { "barL", barL, TEAL, { cres = 4, gloss = { LX - 8, LY - 7 } } },
  { "barR", barR, TEAL, { cres = 4, gloss = { RX - 8, LY - 7 } } },
  { "ringL", ringL, GOLD, { cres = 2, gloss = false, contact = false } },
  { "ringR", ringR, GOLD, { cres = 2, gloss = false, contact = false } },
  { "glassL", glassL, GLASS, { cres = 3, gloss = false, contact = false } },
  { "glassR", glassR, GLASS, { cres = 3, gloss = false, contact = false } },
}
-- yarn twist on the strap: shade ticks every 3 px
p.strap.m:each(function(x, y) if (x + y) % 4 == 0 and c.own[c:key(x, y)] == p.strap then c:px(x, y, ROSE.shade) end end)
-- focus wheel ridges
for _, x in ipairs({ 29, 31, 33 }) do onPart(c, c:rect(x, 24, x, 28), p.wheel, GOLD.shade) end
-- eyepiece cups: a dark band near the top
for _, m in ipairs({ { eyeL, p.eyeL }, { eyeR, p.eyeR } }) do
  local x0, y0, x1 = m[1]:bbox()
  onPart(c, c:rect(x0, 23, x1, 23), m[2], TEAL.shade)
end
-- gold seam round the barrel lower halves (felt join)
for _, cx in ipairs({ LX, RX }) do
  c:seam({ { cx - 9, LY + 2 }, { cx - 7, LY + 7 }, { cx - 4, LY + 9 }, { cx, LY + 10 }, { cx + 4, LY + 9 },
           { cx + 7, LY + 7 }, { cx + 9, LY + 2 } }, { gap = TEAL.shade })
end
-- glass glints: a comma upper left, a dot lower right
for _, cx in ipairs({ LX, RX }) do
  c:paint({ ".gg", "g..", "g.." }, cx - 4, LY - 3, { g = GLASS.gloss })
  c:px(cx + 3, LY + 4, GLASS.rim)
end
c:px(28, 23, GOLD.gloss)
-- enamel comma on each barrel's lit upper-left band (the rings cover the auto gloss spot)
local band = set(TEAL.base, TEAL.rim)
for _, cx in ipairs({ LX, RX }) do
  trace(c, { { cx - 10, LY - 2 }, { cx - 9, LY - 5 }, { cx - 7, LY - 8 }, { cx - 4, LY - 9 } }, TEAL.gloss, band)
end

local t = c:save(OUT .. "cf-yi-stake.aseprite", OUT .. "cf-yi-stake.png")
print("stake " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 22 and t.bw == 0, "check failed")
