-- h3lib.lua : small shared helpers for the h3 scenes (folk, palms, pots).
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local H = { L = L, GV = GV }
-- chibi gnome folk. o: cloth, hat (colour or false), skin, beard (colour), sit, big (full 5x5 eyes), lean
function H.folk(c, x, gy, o)
  o = o or {}
  local big = o.big
  local bw, bh = (o.sit and 7 or 6), (o.sit and 4 or 5)
  c:part(c:ellipse(x, gy - bh, bw, bh), GV.ramp(o.cloth or "#4e8a9a"), { cres = 3, deep = 4, gloss = false })
  local hy = gy - bh * 2 - (big and 4 or 3)
  local hrx, hry = (big and 8 or 6), (big and 7 or 5.5)
  c:part(c:ellipse(x, hy, hrx, hry), GV.ramp(o.skin or "#e9b98a"), { cres = 2, deep = 3, gloss = false })
  if o.beard then
    c:part(c:ellipse(x, hy + hry - 1, hrx - 1, 3.5), GV.ramp(o.beard, { dot = "#fff3c8" }), { cres = 2, deep = 3, flat = true, gloss = false, outline = false })
  end
  if o.hat ~= false then
    local lean = o.lean or 0
    local top = hy - hry - (big and 10 or 8)
    c:part(c:poly({ {x - hrx - 1, hy - 3}, {x + lean, top}, {x + hrx + 1, hy - 3} }), GV.ramp(o.hat or "#d6322b"), { cres = 3, deep = 4, gloss = false, outline = false, contour = "#2a1a10" })
  end
  if big then c:eye(x - 7, hy - 3); c:eye(x + 2, hy - 3); c:px(x - 1, hy + 3, "#8a4234"); c:px(x, hy + 3, "#8a4234")
  else c:eye(x - 5, hy - 2, true); c:eye(x + 1, hy - 2, true); c:px(x - 1, hy + 2, "#8a4234"); c:px(x, hy + 2, "#8a4234") end
  return hy
end
-- palm tree: trunk from (x,y) leaning to (tx,ty), fronds fan at the top
function H.palm(c, x, y, tx, ty, s)
  s = s or 1
  c:part(c:line({ {x, y}, {(x + tx) / 2 + 2, (y + ty) / 2}, {tx, ty} }, 4), GV.ramp("#a8582f"), { cres = 2, deep = 3, gloss = false })
  local fr = { {-16,-3},{-12,6},{12,6},{16,-3},{-6,-9},{6,-9} }
  for i, f in ipairs(fr) do
    local ex, ey = tx + f[1] * s, ty + f[2] * s - 2
    local m = c:line({ {tx, ty}, {(tx + ex) / 2, math.min(ty, ey) - 4 * s}, {ex, ey} }, 3)
    c:part(m, GV.ramp(i % 2 == 0 and "#4a8a3e" or "#7ab55c"), { flat = true, gloss = false })
  end
  c:part(c:ellipse(tx - 2, ty + 3, 2, 2), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
  c:part(c:ellipse(tx + 2, ty + 3, 2, 2), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
end
function H.stars(c, n, maxy, seed) L.stars(c, n, maxy, seed) end
return H
