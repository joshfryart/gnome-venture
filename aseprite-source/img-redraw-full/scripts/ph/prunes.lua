-- ph/prunes (Pantry dried): squat burlap sack, thick rolled-down cuff, dark prunes peeking out, zig-zag stitched plum patch
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "prunes"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- prunes behind the cuff
local function prune(x, y)
  c:part(c:ellipse(x, y, 5, 4), "#4e2a3a", { gloss = false, cres = 2, deep = 0 })
  c:px(x - 2, y - 1, "#6a3a4a"); c:px(x - 1, y - 1, "#6a3a4a"); c:px(x + 1, y + 1, "#6a3a4a"); c:px(x + 2, y, "#6a3a4a")
  c:px(x - 2, y - 2, "#7a5cc0")
end
prune(32, 12); prune(23, 16); prune(41, 16); prune(32, 18)
-- slumped boxy sack: shoulders wider at the bottom
local sack = c:poly({ {14, 24}, {50, 24}, {54, 50}, {52, 56}, {12, 56}, {10, 50} })
c:part(sack, "#c9a96e", { gloss = { 15, 30 } })
for y = 29, 54, 3 do for x = 13 + (y % 2), 52, 3 do if sack:has(x, y) and c:get(x, y) == "#c9a96e" then c:px(x, y, "#9a6b3f") end end end
-- rolled cuff
local cuff = c:rrect(9, 18, 55, 27, 4)
c:part(cuff, "#d8b97e", { gloss = { 12, 21 } })
c:fill(c:rect(12, 21, 52, 21), "#9a6b3f"); c:fill(c:rect(12, 24, 52, 24), "#9a6b3f")
-- zig-zag thread round the cuff hem
for x = 11, 53 do c:px(x, (x % 2 == 0) and 25 or 26, "#e8a317") end
-- cream patch with zig-zag edge stitch
c:part(c:rect(23, 33, 41, 49), "cream", { gloss = false, contact = false })
for x = 24, 40 do c:px(x, (x % 2 == 0) and 34 or 35, "#e8a317"); c:px(x, (x % 2 == 0) and 47 or 48, "#e8a317") end
for y = 35, 47 do c:px((y % 2 == 0) and 24 or 25, y, "#e8a317"); c:px((y % 2 == 0) and 39 or 40, y, "#e8a317") end
-- plum emblem
c:paint({
  "...sll.",
  "...s...",
  ".ppppp.",
  "pPpppps",
  "ppppppd",
  "pppppdd",
  ".ppdds.",
  "..sss..",
}, 29, 37, { p = "#6a3a6a", P = "#a894dc", s = "#4e2a3a", d = "#3a1f2a", l = "#4f9a45" })
-- loose cord from the cuff
c:fill(c:line({ {47, 27}, {48, 31}, {47, 35} }, 1), "#7a4a1f")
c:px(46, 36, "#7a4a1f"); c:px(48, 36, "#7a4a1f")
c:ground(32, 56, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
