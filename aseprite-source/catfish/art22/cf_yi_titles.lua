-- cf_yi_titles.lua : Cat Fish Yarn panel icon `titles` (buy the titles Cat Person 15 Yarn / Napmaster 30 Yarn for
-- the Almanac), 64x64, gvlib "icon" mode, the house look of cf_icons.lua (helpers copied from it).
-- Run: AppRun -b --script cf_yi_titles.lua      Writes out/cf-yi-titles.png + .aseprite.
-- Drawing: a royal violet felt swallowtail banner hanging from a pink yarn cord (pompom knots at both ends),
-- a darker violet top hem the cord runs through, gold edge stitches, and a cream felt cat-head emblem wearing
-- a little gold crown. Violet main colour and a tall notched silhouette keep it apart from the other Yarn
-- icons and from the round cf-badge-* medallions. No text.
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

local VIO = felt("#6a4cb8", { gloss = "#d8c8ff", dot = "#ece4ff", rim = "#9a80e0", shade = "#44308a" })
local HEM = { gloss = VIO.rim, dot = VIO.rim, rim = VIO.rim, base = VIO.shade, shade = "#30226a" }
HEM.deep, HEM.bounce = HEM.shade, HEM.base
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })
local CREAM = felt("#f0dcb0", { gloss = "#fff3c8", dot = "#fff3c8", rim = "#fff0c8", shade = "#c8a070" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cord = c:line({ {12, 12}, {21, 15}, {32, 16}, {43, 15}, {52, 12} }, 3)
local pomL = c:ellipse(10.5, 11, 3.5)
local pomR = c:ellipse(53.5, 11, 3.5)
local banner = c:poly({ {15, 15}, {49, 15}, {49, 56}, {32, 46}, {15, 56} })
local hem = c:rrect(13, 13, 51, 20, 2)
-- emblem: cat head with two ears, crown on top
local head = c:ellipse(32, 36, 10, 8)
  :add(c:poly({ {22, 35}, {23, 23}, {30, 30} })):add(c:poly({ {34, 30}, {41, 23}, {42, 35} }))
local crown = c:poly({ {26, 26}, {26, 19}, {29, 23}, {32, 18}, {35, 23}, {38, 19}, {38, 26} })
local p = c:build{
  { "banner", banner, VIO, { cres = 5, gloss = false } },
  { "hem", hem, HEM, { cres = 2, gloss = false } },
  { "cord", cord, PINK, { cres = 1, deep = 0, gloss = false } },
  { "pomL", pomL, PINK, { cres = 2, gloss = false } },
  { "pomR", pomR, PINK, { cres = 2, gloss = false } },
  { "head", head, CREAM, { cres = 3, gloss = false } },
  { "crown", crown, GOLD, { cres = 2, gloss = false, bounce = false } },
}
-- gold edge stitches down both sides and along the swallowtail
c:seam({ { 18, 23 }, { 18, 51 } }, { gap = VIO.shade })
c:seam({ { 46, 23 }, { 46, 51 } }, { gap = VIO.shade })
c:seam({ { 19, 51 }, { 32, 43 }, { 45, 51 } }, { gap = VIO.shade })
-- banner sheen on the lit left side
c:paint({ "g", "g", "g", ".", "g" }, 19, 25, { g = VIO.gloss })
-- cat face: closed happy eyes, nose, inner ears
c:paint({ "u...u", ".uuu." }, 25, 34, { u = "ol2" })
c:paint({ "u...u", ".uuu." }, 35, 34, { u = "ol2" })
c:paint({ "pp" }, 31, 38, { p = PINK.base })
onPart(c, c:poly({ {25, 31}, {25, 27}, {28, 30} }), p.head, PINK.rim)
onPart(c, c:poly({ {39, 31}, {39, 27}, {36, 30} }), p.head, PINK.rim)
-- crown jewels and glint
c:px(32, 23, PINK.base); c:px(28, 24, VIO.base); c:px(36, 24, VIO.base)
c:px(27, 21, GOLD.gloss); c:px(32, 19, GOLD.gloss)
c:paint({ "gg", "g." }, 8, 9, { g = PINK.gloss }); c:paint({ "gg", "g." }, 51, 9, { g = PINK.gloss })
c:paint({ "gg", "g." }, 25, 33 - 4, { g = CREAM.gloss })

local t = c:save(OUT .. "cf-yi-titles.aseprite", OUT .. "cf-yi-titles.png")
print("titles " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
