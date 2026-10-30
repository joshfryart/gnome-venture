-- ph/banana-chips (Pantry dried): short round red tin, round lid stood on edge behind, a heap of pale gold coin chips on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "banana-chips"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function rell(cx, cy, rx, ry, a)
  local m, ca, sa = c:mask(), math.cos(a), math.sin(a)
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + 0.35)) ^ 2 + (v / (ry + 0.35)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- lid standing on edge against the right rim, behind the heap: a round disc (not a pointed oval) seen
-- almost face-on, with a dark rolled rim band on its right (its thickness), a gold rim line and a
-- pressed ring, so it reads as a tin lid and never as a leaf
c:part(c:ellipse(49, 19, 7, 9), "#a8241f", { gloss = false, cres = 2, deep = 0, rim = false })   -- lid edge (thickness)
local lid = c:ellipse(47, 19, 8, 9)
c:part(lid, "#d6322b", { gloss = { 43, 13 }, contour = "#6b1b2c" })
c:fill(lid:edge():cut(c:rect(0, 19, 63, 63)):cut(c:rect(48, 0, 63, 63)), "#f5cf6a")   -- gold rim, lit upper-left
c:fill(lid:edge():cut(c:rect(0, 0, 63, 18)), "#b07a10")                            -- gold rim, shaded side
c:fill(lid:edge():cut(c:rect(0, 0, 47, 63)):cut(c:rect(0, 19, 63, 63)), "#e8a317")
c:fill(c:ellipse(47, 19, 4, 5):edge(), "#a8241f")                                     -- pressed ring
c:paint({ "...k", "..y.", ".yy.", "yy..", }, 45, 17, { y = "#f5cf6a", k = "#7a4a1f" })   -- tiny banana stamp
-- tin body with the rim on top
local tin = c:rrect(12, 32, 51, 55, 4)
c:part(tin, "#d6322b", { gloss = { 15, 41 } })
c:fill(c:rect(14, 37, 49, 37), "#a8241f"); c:fill(c:rect(14, 52, 49, 52), "#a8241f")
c:fill(c:rect(14, 34, 15, 50), "#e0501f")
-- label band with a banana crescent
c:part(c:rect(18, 40, 45, 49), "cream", { gloss = false, contact = false })
c:paint({
  "...........kk",
  "y.........yk.",
  "yy.......yy..",
  ".yyY...yyys..",
  "..yyyyyyyss..",
  "....sssss....",
}, 25, 41, { y = "#f5cf6a", Y = "#fff1c8", s = "#d0862a", k = "#7a4a1f" })
-- coin chips, back to front
local function chip(x, y)
  c:part(c:ellipse(x, y, 4, 4), "#f5cf6a", { gloss = false, cres = 2, deep = 0, rim = false, contour = "#c89040" })
  c:fill(c:ellipse(x, y, 4, 4):edge():cut(c:rect(0, 0, 63, y)), "#e8a317")
  c:px(x, y, "#c89040"); c:px(x - 2, y - 2, "#fff1c8")
end
for _, p in ipairs({ {32, 17}, {25, 22}, {39, 22}, {18, 27}, {29, 25}, {36, 26}, {23, 30}, {32, 30}, {41, 30} }) do chip(p[1], p[2]) end
c:seam({ {13, 35}, {50, 35} })
c:ground(32, 56, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
