-- ph/buckwheat-kasha (Gourmand P2 dish): tall clay bowl heaped with granular toasted buckwheat, mushroom slices and a melting butter pat
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "buckwheat-kasha"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tall bowl: steep sides narrowing to a foot
local bowl = c:ellipse(31.5, 30, 19, 21):clip(c:rect(0, 30, 63, 63)):add(c:ellipse(31.5, 30, 19, 5))
bowl:add(c:rrect(22, 50, 41, 54, 1))
c:part(bowl, "#8a4a2a", { cres = 4, gloss = { 17, 36 } })
c:fill(c:ellipse(31.5, 30, 19, 5):edge():clip(c:rect(0, 24, 63, 30)), "#c98a55")
-- incised bands to stress the height
-- cream glaze band with a dot pattern
c:fill(c:rect(13, 35, 50, 38):clip(bowl), "#e6c89a")
c:fill(c:rect(13, 38, 50, 38):clip(bowl), "#c4a070")
for x = 15, 48, 4 do c:px(x, 36, "#8a4a2a"); c:px(x + 1, 36, "#8a4a2a") end
c:seam({ {16, 43}, {47, 43} }, { gap = "#6a3420" })
-- kasha heap above the rim
local kasha = c:ellipse(31.5, 30, 16, 3.5):add(c:ellipse(31.5, 26, 14, 7):clip(c:rect(0, 0, 63, 30)))
c:part(kasha, "#8a6a3a", { contour = "#4a2c1a", cres = 3, gloss = false, contact = false })
local seed = 5
local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
for _ = 1, 60 do                                                    -- toasted groats
  local x, y = 18 + rnd(28), 19 + rnd(14)
  if kasha:has(x, y) then c:px(x, y, (rnd(3) == 0) and "#c49a5a" or "#5a3f22") end
end
-- mushroom slices (cap + stem cross-sections)
local function mush(x, y)
  c:paint({ ".mmmm.", "mmmmmm", "..ms..", "..ss.." }, x, y, { m = "#e6d8b4", s = "#b8a07a" })
  c:paint({ ".ssss." }, x, y + 1, { s = "#e6d8b4" })
  c:px(x + 1, y, "#fbf2d8")
end
mush(19, 24); mush(37, 25); mush(28, 28)
-- butter pat, melting down the heap
c:paint({
  "hHHyyy",
  "Hhyyyy",
  "hyyyyd",
  "yyyydd",
  "yyyddd",
  ".y..y.",
  ".y....",
}, 29, 17, { H = "#fff3b0", h = "#f8e48a", y = "#f2d230", d = "#d0a018" })
c:ground(31.5, 56, 14, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
