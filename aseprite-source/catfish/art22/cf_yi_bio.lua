-- cf_yi_bio.lua : Cat Fish Yarn panel icon `bio` (a cat's bio line: 1 Yarn per cat, then free to edit), 64x64,
-- gvlib "icon" mode, the house look of cf_icons.lua (cf-up-*).
-- Run: AppRun -b --script cf_yi_bio.lua        Writes out/cf-yi-bio.png + .aseprite.
-- Drawing: a cream parchment scroll (rolled top and bottom) with a rose cat-head stamp and ink squiggle lines
-- (no readable text), a teal quill pen leaning on it with its gold nib on the last line, and a little rose yarn
-- ball tied to the bottom roll (the shared Yarn accent).
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
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
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

local PAPER = felt("#ecd6a4", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff0c8", shade = "#c49a60" })
local ROLL = felt("#e0c088", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#f5dca8", shade = "#b07e48" })
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6" })
local TEAL = felt("#3aa59a", { gloss = "#c8f0d8", dot = "#c8f0d8", rim = "#7ccfb4", shade = "#2a6f80" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base
local INK = "#4a2c1a"

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local sheet = c:rect(11, 12, 43, 50)
local topR = c:rrect(7, 7, 47, 15, 4)
local botR = c:rrect(7, 47, 47, 55, 4)
local stamp = c:ellipse(18.5, 23, 4.5, 4):add(c:poly({ {14, 22}, {15, 16}, {19, 20} })):add(c:poly({ {18, 20}, {22, 16}, {23, 22} }))
-- quill: feather along the axis from the nib (33,43) up to the upper right
local ax, ay = 21, -33
local a = math.atan(ay, ax)
local feather = rell(c, 47, 21, 13, 5, a)
local shaft = c:line({ {34, 41}, {41, 31} }, 3)
local nib = c:poly({ {31, 46}, {33, 38}, {38, 41} })
local yarn = c:ellipse(52, 50, 7)
local p = c:build{
  { "sheet", sheet, PAPER, { cres = 4, gloss = false } },
  { "top", topR, ROLL, { cres = 3, gloss = { 10, 9 } } },
  { "bot", botR, ROLL, { cres = 3, gloss = false } },
  { "stamp", stamp, ROSE, { cres = 2, gloss = false, contact = false } },
  { "yarn", yarn, ROSE, { cres = 3, gloss = { 48, 46 } } },
  { "nib", nib, GOLD, { cres = 2, gloss = false, bounce = false } },
  { "shaft", shaft, TEAL, { cres = 1, deep = 0, gloss = false } },
  { "feather", feather, TEAL, { cres = 3, gloss = false } },
}
-- ink squiggles: a short "name" line by the stamp, then three bio lines
local function squig(x0, x1, y)
  local pts = {}
  for x = x0, x1, 2 do pts[#pts + 1] = { x, y + ((x // 2) % 2) } end
  trace(c, pts, INK, set(PAPER.base, PAPER.rim, PAPER.shade))
end
squig(25, 38, 20)
squig(15, 38, 29)
squig(15, 36, 35)
squig(15, 29, 41)
-- feather barbs: notch lines across the vane, shaft line along it
local ux, uy = math.cos(a), math.sin(a)
trace(c, { { 40 - ux * 2, 32 - uy * 2 }, { 47 + ux * 9, 21 + uy * 9 } }, TEAL.rim, set(TEAL.base, TEAL.shade))
for _, t in ipairs({ -4, 1, 6 }) do
  local bx, by = 47 + ux * t, 21 + uy * t
  trace(c, { { bx, by }, { bx + 4, by + 2 } }, TEAL.shade, set(TEAL.base, TEAL.rim))
end
c:paint({ ".gg", "g.." }, 43, 14, { g = TEAL.gloss })
c:px(33, 41, GOLD.shade)                                                                 -- nib slit
-- roll seams and the stamp's face
c:seam({ { 10, 11 }, { 44, 11 } }, { gap = ROLL.shade })
c:seam({ { 10, 51 }, { 44, 51 } }, { gap = ROLL.shade })
c:px(17, 22, INK); c:px(20, 22, INK); c:px(16, 21, ROSE.gloss)
-- yarn ball wraps and thread to the bottom roll
for _, r in ipairs({ 3, 6 }) do onPart(c, c:ellipse(58, 44, r + 5):cut(c:ellipse(58, 44, r + 4)), p.yarn, ROSE.shade) end
save = nil
local t = c:save(OUT .. "cf-yi-bio.aseprite", OUT .. "cf-yi-bio.png")
print("bio " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 22 and t.bw == 0, "check failed")
