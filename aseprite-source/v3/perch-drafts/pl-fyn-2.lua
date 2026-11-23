-- pl-fyn-2-perch.lua — 36x36 perch sprite (chibi pal on its perch)
local D0 = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-fyn-2-perch-20261120-185327/"
local GV = dofile(D0 .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- ===== shapes =====
local leafL = c:ellipse(14, 7, 2, 1)                    -- sprout, left leaf
local leafR = c:ellipse(21, 7, 2, 1)                    -- sprout, right leaf
local stem  = c:rrect(17, 8, 18, 10, 0)                 -- sprout stem into head
local sprout = leafL:copy() sprout:add(leafR) sprout:add(stem)
local head  = c:ellipse(17.5, 14.5, 9, 6.5)             -- big chibi head y8..21
local body  = c:rrect(13, 20, 23, 26, 4)                -- squat body
local mount = c:rrect(7, 24, 28, 28, 3)                 -- stone mound y24..28
local moss  = c:ellipse(17.5, 24.5, 6, 1.8)             -- moss wrap on mound top
local footL = c:rrect(11, 27, 14, 28, 0)
local footR = c:rrect(20, 27, 23, 28, 0)
local sprig = c:rrect(9, 26, 10, 27, 0)                 -- tiny leaf accent, mound front-left

-- ===== parts (back to front) =====
local p = c:build{
  { "sprout", sprout, "#74bd51" },
  { "body",   body,   "#a89164" },
  { "head",   head,   "#a89164" },
  { "mound",  mount,  "#658286" },
  { "footL",  footL,  "#584d65", { flat = true } },
  { "footR",  footR,  "#584d65", { flat = true } },
  { "moss",   moss,   "#74bd51" },
  { "sprig",  sprig,  "#74bd51", { flat = true } },
}

-- ===== face =====
c:eye(13, 11, true); c:eye(20, 11, true)                -- big round eyes, wide set
c:px(17, 15, "#582a2d"); c:px(18, 15, "#582a2d")        -- tiny mouth
c:px(10, 14, "#c9a087"); c:px(10, 15, "#c9a087")        -- cheeks, upper-left
c:px(11, 15, "#c9a087")
c:px(23, 15, "#c9a087"); c:px(24, 15, "#c9a087")
c:px(23, 16, "#c9a087")
c:px(17, 22, "#c7af68"); c:px(18, 22, "#c7af68")        -- tiny gold chest dot

-- ===== texture (hand-placed, subtle) =====
local joint = "#4d5f66"                                 -- stone joint, 1 step down
c:px(10, 26, joint); c:px(11, 26, joint)                -- short joint run, lit face
c:px(12, 25, "#86a49e")                                 -- stone glint speckles
c:px(24, 25, "#86a49e")
c:px(14, 24, "#7c8f88"); c:px(21, 24, "#7c8f88")        -- moss tone variation
c:px(17, 23, "#8fbf62"); c:px(20, 23, "#8fbf62")
c:px(23, 12, "#a89164"); c:px(24, 13, "#a89164")        -- 1px dither at head terminator
c:px(25, 15, "#a89164")
c:px(11, 27, "#8fbf62")                                 -- sprig lighter tone

c:ground(17.5, 28.7, 10.5, 1)

local t = c:save(D0 .. "out/pl-fyn-2-perch.aseprite", D0 .. "out/pl-fyn-2-perch.png")
print(GV.report(t))
