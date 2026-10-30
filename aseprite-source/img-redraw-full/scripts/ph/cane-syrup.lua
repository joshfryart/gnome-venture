-- ph/cane-syrup (Pantry cordial): small amber-painted tin syrup pail, wire bail handle arcing over a pressed lid, pouring lip, sugarcane stalk label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cane-syrup"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- bail handle first so the pail sits in front of it
local bail = c:mask()
for a = 0, 180, 4 do local r = math.rad(a); bail:add(c:rect(math.floor(32 + 16 * math.cos(r) + 0.5), math.floor(22 - 13 * math.sin(r) + 0.5), math.floor(32 + 16 * math.cos(r) + 0.5) + 1, math.floor(22 - 13 * math.sin(r) + 0.5) + 1)) end
c:part(bail, "#5b6470", { flat = true, contact = false })
local tin = GV.ramp("#c8821f", { rim = "#e0a02f", shade = "#a8641f" })
c:part(c:rrect(14, 24, 50, 56, 3), tin, { gloss = { 17, 28 } })
c:fill(c:rect(16, 27, 17, 53), "#e0a02f")
c:fill(c:rect(15, 28, 49, 28):add(c:rect(15, 53, 49, 53)), "#a8641f")
-- pressed lid with a pour lip on the right
c:part(c:poly({ {43, 19}, {54, 17}, {54, 21}, {48, 26}, {43, 26} }), tin, { gloss = false, cres = 2 })
c:part(c:rrect(13, 19, 49, 25, 2), GV.ramp("#e0a02f", { shade = "#c8821f" }), { gloss = { 16, 20 }, cres = 2 })
c:fill(c:rect(15, 22, 47, 22), "#c8821f")
c:seam({ {15, 24}, {48, 24} }, { free = true })
-- ear rivets
c:part(c:rect(14, 21, 16, 23), "#5b6470", { flat = true }); c:part(c:rect(48, 21, 50, 23), "#5b6470", { flat = true })
-- lithographed label with a sugarcane stalk
c:part(c:rrect(20, 32, 44, 50, 2), "cream", { gloss = false, contact = false })
c:fill(c:rect(31, 37, 33, 48), "#4f9a45"); c:fill(c:rect(31, 37, 31, 48), "#7ab55c")
for _, y in ipairs({ 40, 43, 46 }) do c:fill(c:rect(30, y, 34, y), "#2f5a2a") end
c:paint({ "a...a", ".a.a.", "aaaaa", "..a.." }, 30, 34, { a = "#a4b86a" })
c:ground(32, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
