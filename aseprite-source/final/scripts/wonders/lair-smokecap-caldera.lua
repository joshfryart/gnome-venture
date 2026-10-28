-- lair-smokecap-caldera.lua : Boss lair (CA, zone 4). "A fire salamander sleeps in the crater." Dawn, warm. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H

L.sky(c, "dawn", 90)
for _, s in ipairs({ {20,10},{60,6},{110,12},{170,8},{214,14},{40,22},{200,26} }) do c:px(s[1], s[2], "#f8e6c8") end
L.cloud(c, 40, 34, 16, "#d49ab8", "#f0aa98"); L.cloud(c, 196, 40, 18, "#a48ac0", "#d49ab8"); L.cloud(c, 120, 24, 12, "#a48ac0", "#d49ab8")
-- far jungle ridge
local far = L.below(c, function(x) return 82 + math.sin(x * 0.07) * 4 + math.sin(x * 0.19) * 2 end)
c:fill(far, "#6a5a98")
local mid = L.below(c, function(x) return 92 + math.sin(x * 0.05 + 1) * 5 end)
c:fill(mid, "#4f7a6a")
-- ground

-- volcano cone with smokecap-brown rock
local CY = 64
local cone = c:poly({ {6,124},{58,CY+12},{82,CY-1},{158,CY-1},{182,CY+12},{234,124},{234,H},{6,H} })
c:part(cone, GV.ramp("#8a5a4a"), { cres = 8, deep = 12, gloss = false })
for _, l in ipairs({ { {40,106},{54,98},{60,104} }, { {176,98},{190,104},{204,100} }, { {80,92},{88,98},{84,106} }, { {150,94},{156,100} } }) do
  c:seam(l, { free = true, on = 3, off = 0, gap = "#4a2c1a" })
end
for _, l in ipairs({ { {64,114},{76,108},{86,112} }, { {154,110},{168,106},{182,112} }, { {100,96},{108,100} } }) do
  c:fill(c:line(l, 1), "#f08a24")
end
-- crater: lava bowl
c:fill(c:ellipse(120, CY, 46, 12), "#6b1b2c")
c:fill(c:ellipse(120, CY + 1, 43, 10), "#d6322b")
c:fill(c:ellipse(120, CY + 2, 38, 8), "#e0501f")
c:fill(c:ellipse(120, CY + 3, 30, 5), "#f08a24")
for _, x in ipairs({ 92, 104, 146, 154, 84 }) do c:px(x, CY + 2 + (x % 3), "#fbd078"); c:px(x + 1, CY + 3 + (x % 3), "#fbd078") end
-- salamander sleeping curled in the lava bowl
local SX, SY = 114, CY - 2
c:part(c:ellipse(SX, SY + 2, 28, 11), GV.ramp("#e0501f"), { cres = 5, deep = 7 })
local tail = c:line({ {SX + 22, SY + 8}, {SX + 8, SY + 12}, {SX - 10, SY + 12}, {SX - 24, SY + 8}, {SX - 30, SY + 2} }, 5)
c:part(tail, GV.ramp("#e0501f"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(SX - 31, SY, 2.5, 2.5), GV.ramp("#fbd078"), { flat = true, outline = false })
for _, p in ipairs({ {-16,-2},{-6,-6},{6,-5},{16,-2},{-22,4},{0,2},{-12,6} }) do c:part(c:ellipse(SX + p[1], SY + p[2], 2.5, 2), GV.ramp("#f5cf6a"), { flat = true, gloss = false, outline = false }) end
-- stubby front paw
c:part(c:ellipse(SX + 24, SY + 12, 5, 3), GV.ramp("#e0501f"), { flat = true })
-- head resting on the front lip (right), fire frills
local hx, hy = SX + 34, SY + 5
c:part(c:poly({ {hx-6,hy-14},{hx,hy-6},{hx-10,hy-6} }), GV.ramp("#f5cf6a"), { flat = true, outline = false })
c:part(c:poly({ {hx+4,hy-15},{hx+10,hy-6},{hx-2,hy-6} }), GV.ramp("#f08a24"), { flat = true, outline = false })
c:part(c:poly({ {hx+12,hy-12},{hx+16,hy-4},{hx+8,hy-5} }), GV.ramp("#f5cf6a"), { flat = true, outline = false })
c:part(c:ellipse(hx, hy + 1, 14, 10), GV.ramp("#e0501f"), { cres = 4, deep = 7 })
for _, ex in ipairs({ hx - 8, hx + 3 }) do
  c:px(ex, hy - 1, "#2a1a10"); c:px(ex + 1, hy, "#2a1a10"); c:px(ex + 2, hy, "#2a1a10"); c:px(ex + 3, hy, "#2a1a10"); c:px(ex + 4, hy - 1, "#2a1a10")
end
c:px(hx - 3, hy + 6, "#2a1a10"); c:px(hx - 2, hy + 6, "#2a1a10"); c:px(hx - 1, hy + 6, "#2a1a10"); c:px(hx, hy + 6, "#2a1a10")
c:px(hx + 9, hy + 3, "#6b1b2c"); c:px(hx + 9, hy + 4, "#6b1b2c")
-- front rim lip covers the lower body
local lip = c:ellipse(120, CY + 6, 49, 13); lip:cut(c:ellipse(120, CY + 1, 46, 11)); lip:clip(c:rect(0, CY + 8, W, CY + 30))
c:part(lip, GV.ramp("#a07060"), { cres = 2, deep = 3, gloss = false })
-- smoke rising from the nose and the crater
local function puff(x, y, r, col, sh) c:fill(c:ellipse(x, y, r, r * 0.85), col); c:fill(c:ellipse(x + 1, y + 1, r * 0.7, r * 0.55), sh) end
puff(152, 50, 4, "#e8dcd8", "#c3b2c8"); puff(156, 41, 5, "#e8dcd8", "#c3b2c8"); puff(164, 30, 6, "#d8ccd0", "#a898b8"); puff(178, 19, 8, "#c8bcc8", "#a898b8")
puff(86, 50, 3, "#e8dcd8", "#c3b2c8"); puff(82, 42, 4, "#d8ccd0", "#a898b8"); puff(76, 33, 5, "#c8bcc8", "#a898b8")
-- foreground jungle floor over the cone foot
local fg = L.below(c, function(x) return 112 + math.sin(x * 0.06 + 2) * 3 end)
c:part(fg, GV.ramp("#6a9a3a"), { outline = true, gloss = false, cres = 3, deep = 5 })
for _, x in ipairs({ 30, 52, 90, 128, 150, 176, 206, 224 }) do c:px(x, 118 + x % 5, "#a4b86a"); c:px(x + 1, 117 + x % 5, "#c8d77a") end
-- smokecap mushrooms on the slopes (grey-brown caps, stems)
local function smokecap(x, y, s)
  c:part(c:rrect(x - s * 0.3, y - s, x + s * 0.3, y, 1), GV.ramp("#e8d9b0"), { gloss = false, cres = 2 })
  local cap = c:ellipse(x, y - s - 1, s, s * 0.6); cap:cut(c:rect(x - s - 1, y - s + 1, x + s + 1, y))
  c:part(cap, GV.ramp("#9a8a90"), { cres = 3, deep = 4 })
  c:px(x - s * 0.4, y - s - 2, "#cfc0c8")
  c:px(x, y - s * 1.5, "#c3b2c8"); c:px(x + 1, y - s * 1.5 - 2, "#c3b2c8")
end
smokecap(40, 122, 9); smokecap(60, 128, 5); smokecap(186, 124, 10); smokecap(206, 129, 5); smokecap(112, 124, 6); smokecap(130, 128, 4)
-- foreground palms
local function palm(x, y, h, lean)
  c:fill(c:line({ {x, y}, {x + lean, y - h} }, 2), "#8a4f2a")
  local tx, ty = x + lean, y - h
  for _, d in ipairs({ {-12,2},{-9,-4},{-4,-7},{4,-7},{9,-4},{12,2} }) do
    c:part(c:line({ {tx, ty}, {tx + d[1] * 0.5, ty + d[2] - 2}, {tx + d[1], ty + d[2] + 3} }, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false })
  end
end
palm(12, 128, 34, 5); palm(230, 128, 32, -4)
c:ground(120, 128, 30, 2)
L.finish(c, "lair-smokecap-caldera")
