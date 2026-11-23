-- pl-drft-5-perch : 36x36 chibi pal on its perch (lantern pal)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-drft-5-perch-20261120-174727/"
local GV = dofile(D .. "gvlib/gvlib.lua")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- masks
local body = c:ellipse(18, 15.5, 9.5, 8.5)                      -- x 9..27, y 7..24
local belly = c:rect(5, 19, 31, 24):clip(body:copy())
for _, p in ipairs({{11,18},{12,18},{17,18},{18,18},{22,18},{23,18}}) do belly:set(p[1], p[2]) end
local dish  = c:rrect(9, 24, 26, 30, 2)                          -- brass dish on the ground
local capM  = c:rrect(5, 6, 9, 7, 1)                             -- lantern, slim cap
local poleM = c:rect(5, 8, 6, 28)
local glassM = c:rrect(6, 8, 10, 11, 1)
local polefoot = c:rrect(5, 29, 8, 30, 1)
local leaf1 = c:ellipse(14, 5, 2, 1.25)                          -- sprout on head (small)
local leaf2 = c:ellipse(21, 5, 2, 1.25)
local stemM = c:line({{17.5, 8}, {17.5, 6}}, 2)
local puff  = c:ellipse(28.5, 9, 2, 1)                           -- small puff of steam
local puff2 = c:ellipse(30.5, 6.5, 1, 0.5)
local NOP = { cres = 0, deep = 0, bounce = false, contact = false, contour = false }

-- build back to front; light upper-left
local SMALL = { flat = true }
c:build{
  { "leaf1",  leaf1,  "#6bac62", SMALL },
  { "leaf2",  leaf2,  "#6bac62", SMALL },
  { "stem",   stemM,  "#6bac62", { flat = true, rim = false } },
  { "body",   body:copy(), "#c149a9", { gloss = false, cres = 4, deep = 3 } },
  { "belly",  belly,  "#69c1b3", { rim = false, gloss = false, cres = 3, contour = false } },
  { "dish",   dish,   "#f2e498", { gloss = false, cres = 1 } },
  { "cap",    capM,   "#584862", { flat = true } },
  { "pole",   poleM,  "#2d485d", { flat = true, rim = false } },
  { "glass",  glassM, "#f2e498", { flat = true, cres = 0, deep = 0 } },
  { "polefoot", polefoot, "#2d485d", { flat = true } },
  { "puff",   puff,   "#e69ea9", { gloss = false } },
  { "puff2",  puff2,  "#e69ea9", { flat = true, rim = false } },
}
c:ground(17.5, 31, 10, 0.75)

-- TEXTURE (from phase 5)
for _, p in ipairs({{10,8},{13,7},{11,12},{9,15},{25,13}}) do c:px(p[1], p[2], "#ce6e9b") end
for _, p in ipairs({{24,19},{26,17}}) do c:px(p[1], p[2], "#a3378a") end
for _, p in ipairs({{22,15},{23,17}}) do c:px(p[1], p[2], "#c149a9") end
for _, p in ipairs({{12,21},{18,22},{23,21}}) do c:px(p[1], p[2], "#2d5d6e"); c:px(p[1]+1, p[2], "#2d5d6e") end
for _, p in ipairs({{12,18},{23,18}}) do c:px(p[1], p[2], "#48ad9a") end
for _, p in ipairs({{23,29},{21,30}}) do c:px(p[1], p[2], "#c99b52") end
c:px(11, 25, "#c99b52"); c:px(24, 25, "#6e6887")
c:px(14, 5, "#4a8a3e"); c:px(20, 5, "#4a8a3e")
c:px(5, 9, "#4d5f7e")

-- DETAIL: face (big round eyes, tiny mouth, pink cheeks)
c:eye(12, 10); c:eye(20, 10)
c:paint({ ".w.w.", ".www." }, 16, 16, { w = "#2b1c26" })
for _, p in ipairs({{10,15},{11,15},{24,15},{25,15}}) do c:px(p[1], p[2], "#c16a74") end
-- DETAIL: glints and small accents
c:px(7, 9, "#fff3c8"); c:px(8, 9, "#fff3c8"); c:px(7, 10, "#fff3c8")   -- glass glow core
c:px(10, 25, "#fff3c8"); c:px(11, 25, "#fff3c8")                       -- brass dish glint
c:px(12, 27, "#c99b52")                                               -- dish wear
c:px(32, 7, "#e69ea9")                                                -- steam wisp

local t = c:save(D .. "out/pl-drft-5-perch.aseprite", D .. "out/pl-drft-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 2)
