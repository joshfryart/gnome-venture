-- ph/npc-unknown : 80x100 bust, flat umber gnome silhouette with a "?" cut out, border not on bottom
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local s = c:poly({ {40, 6}, {58, 34}, {22, 34} })          -- hat
s:add(c:rrect(18, 32, 61, 37, 2))                           -- brim
s:add(c:ellipse(39.5, 47, 16, 13))                          -- head
s:add(c:poly({ {21, 50}, {58, 50}, {49, 76}, {30, 76} }))   -- beard
s:add(c:rrect(8, 68, 71, 99, 14))                          -- shoulders and torso (bleeds off the bottom)
c:part(s, GV.ramp("#4a2c1a"), { flat = true })
local q = { ".XXXXXX.", "XXXXXXXX", "XX....XX", ".....XXX", "....XXX.", "...XXX..", "...XX...", "...XX...", "........", "...XX...", "...XX..." }
local big = {}
for _, row in ipairs(q) do local r = row:gsub(".", function(ch) return ch .. ch end) big[#big + 1] = r; big[#big + 1] = r end
c:paint(big, 32, 76, { X = "#7a4a1f" })
H.done(c, "npc-unknown", "ph/npc-unknown.png", 16)
