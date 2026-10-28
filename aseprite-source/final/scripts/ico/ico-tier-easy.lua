-- ico-tier-easy: tier badge 1 of 3 (Easy, 24 pieces). ONE fat moss-green piece with a tab on every side (a plus-shaped piece).
-- Family: easy = 1 green piece, advanced = 2 gold pieces locked side by side, expert = 3 red pieces in a pyramid.
-- Run: python3 aseprite-source/tools/aseshim.py aseprite-source/final/scripts/ico/ico-tier-easy.lua
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ico/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- body 26x26, four tabs (r 5.5) on short necks
local body = c:rect(18, 18, 43, 43)
body:add(c:ellipse(30.5, 11, 5.5)):add(c:rect(28, 13, 33, 18))   -- top
body:add(c:ellipse(30.5, 50, 5.5)):add(c:rect(28, 43, 33, 48))   -- bottom
body:add(c:ellipse(11, 30.5, 5.5)):add(c:rect(13, 28, 18, 33))   -- left
body:add(c:ellipse(50, 30.5, 5.5)):add(c:rect(43, 28, 48, 33))   -- right
c:build{
  { "piece", body, "moss", { gloss = { 21, 21 } } },
}
-- one gold stud in the middle: the "1"
c:button(29, 29)
local t = c:save(D .. "final/aseprite/ico/ico-tier-easy.aseprite", PNG .. "ico-tier-easy.png")
print("ico-tier-easy", GV.report(t))
