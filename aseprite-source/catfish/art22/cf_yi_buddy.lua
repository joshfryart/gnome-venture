-- cf_yi_buddy.lua : Cat Fish Yarn panel icon "buddy" (Buddy cat, 12 Yarn, +10% Kibble while a second owned
-- cat keeps the playing cat company). 64x64 gvlib "icon" mode, house look of cf_icons.lua (cf-up-*).
-- Picture: two plush cats sitting side by side, the ginger one (the player) and a smaller grey buddy leaning
-- in, a rose felt heart above them, and a little rose yarn ball at their feet (the shared Yarn accent).
-- Cat ramps are the coat ramps of cf-cat-orange / cf-cat-grey so the icon matches the real cats.
-- Run: AppRun -b --script cf_yi_buddy.lua      Writes out/cf-yi-buddy.png + .aseprite.
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
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

-- coat ramps (from cf-cat-orange-idleA / cf-cat-grey-idleA)
local GINGER = felt("#e8701a", { gloss = "#fbeab7", dot = "#fbeab7", rim = "#f3bb60", shade = "#a32d0c" })
local GREY = felt("#8a859b", { gloss = "#f1ebe3", dot = "#f1ebe3", rim = "#cdc9d3", shade = "#57516f" })
local ROSE = felt("#d2507e", { gloss = "#ffb8c8", dot = "#ffb8c8", rim = "#ec86a6", shade = "#9a2a58" })
local EAR, MUZ = "#e8909e", "#f2e4c0"

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- ginger cat (left, a little taller)
local aHead = c:ellipse(19.5, 27, 11.5, 9)
  :add(c:poly({ {9, 25}, {10, 12}, {19, 19} })):add(c:poly({ {20, 19}, {29, 12}, {30, 25} }))
local aBody = c:ellipse(19.5, 45, 10, 9):clip(c:rect(0, 0, 63, 53))
local aTail = c:line({ {11, 51}, {7, 47}, {7, 41} }, 4)
-- grey buddy (right, smaller, leaning in)
local bHead = c:ellipse(43.5, 32, 10.5, 8.5)
  :add(c:poly({ {34, 31}, {35, 19}, {43, 25} })):add(c:poly({ {44, 25}, {52, 19}, {53, 31} }))
local bBody = c:ellipse(43.5, 47, 9, 7.5):clip(c:rect(0, 0, 63, 53))
local bTail = c:line({ {51, 52}, {55, 49}, {56, 43} }, 4)
-- rose heart above, yarn ball between their feet
local heart = c:ellipse(28.5, 9, 3.5):add(c:ellipse(35.5, 9, 3.5)):add(c:poly({ {25, 10}, {39, 10}, {32, 18} }))
local ball = c:ellipse(31.5, 51, 4.5)

local p = c:build{
  { "aTail", aTail, GINGER, { cres = 2, deep = 0, gloss = false } },
  { "bTail", bTail, GREY, { cres = 2, deep = 0, gloss = false } },
  { "aBody", aBody, GINGER, { cres = 4, gloss = false } },
  { "aHead", aHead, GINGER, { cres = 4, gloss = { 11, 21 } } },
  { "bBody", bBody, GREY, { cres = 3, gloss = false } },
  { "bHead", bHead, GREY, { cres = 4, gloss = { 36, 26 } } },
  { "ball", ball, ROSE, { cres = 2, gloss = false } },
  { "heart", heart, ROSE, { cres = 3, gloss = { 27, 7 } } },
}

-- inner ears
c:paint({ "e..", "ee.", "eee" }, 12, 16, { e = EAR }); c:paint({ "..e", ".ee", "eee" }, 25, 16, { e = EAR })
c:paint({ "e.", "ee", "ee" }, 37, 23, { e = EAR }); c:paint({ ".e", "ee", "ee" }, 49, 23, { e = EAR })
-- faces: locked eyes, cream muzzle, pink nose, umber mouth
c:eye(12, 24); c:eye(23, 24)
onPart(c, c:ellipse(19.5, 32.5, 4, 2.5), p.aHead, MUZ)
c:paint({ "nn" }, 19, 30, { n = EAR })
c:paint({ "u..u", ".uu." }, 18, 32, { u = "ol2" })
c:eye(36, 29); c:eye(46, 29)
onPart(c, c:ellipse(43.5, 37, 3.5, 2), p.bHead, MUZ)
c:paint({ "nn" }, 43, 35, { n = EAR })
c:paint({ "u..u", ".uu." }, 42, 37, { u = "ol2" })
-- tabby stripes on the ginger forehead, belly seams on both
c:paint({ "s.s", "s.s" }, 18, 19, { s = GINGER.shade })
c:seam({ { 15, 41 }, { 15, 50 } }, { gap = GINGER.shade }); c:seam({ { 24, 41 }, { 24, 50 } }, { gap = GINGER.shade })
c:seam({ { 40, 44 }, { 40, 51 } }, { gap = GREY.shade }); c:seam({ { 47, 44 }, { 47, 51 } }, { gap = GREY.shade })
-- yarn ball wraps
for _, r in ipairs({ 3, 6 }) do
  onPart(c, c:ellipse(36, 47, r + 3):cut(c:ellipse(36, 47, r + 2)), p.ball, ROSE.shade)
end
c:px(30, 49, ROSE.gloss)
-- heart centre seam
c:seam({ { 32, 9 }, { 32, 14 } }, { gap = ROSE.shade })

local t = c:save(OUT .. "cf-yi-buddy.aseprite", OUT .. "cf-yi-buddy.png")
print("buddy " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw == 0, "check failed")
