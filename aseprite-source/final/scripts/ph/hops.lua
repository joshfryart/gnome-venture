local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stem = c:line({ {31,6}, {32,9}, {32,18} }, 3)
local leaf = c:poly({
  {34,14},{36,10},{39,9},{41,6},{44,7},{46,5},{50,5},{51,8},{49,9},{51,12},
  {48,12},{47,15},{44,14},{42,16},{39,15},{37,17}
})
local cone = c:ellipse(32, 32, 15, 15)
cone:add(c:poly({ {18,36},{47,36},{40,48},{34,56},{31,56},{25,48} }))

local p = c:build{
  { "stem", stem, "#6a9a3a", { flat = true } },
  { "leaf", leaf, "#4a8a3e", { gloss = false } },
  { "cone", cone, "moss", { gloss = { 23, 22 } } },
}

-- leaf vein
c:fill(c:line({ {36,13}, {42,10}, {49,7} }, 1):clip(p.leaf.m), "#2f5a2a")

-- stacked U-scale bract rows, offset each row
local inner = p.cone.m:shrink(1)
local SH, RIM, FOLD = "#4a8a3e", "#a4b86a", "#2f5a2a"
local rows = { {24, 0}, {31, 4}, {38, 0}, {46, 4}, {52, 0} }
for _, r in ipairs(rows) do
  local y, off = r[1], r[2]
  for x = 32 - 16 + off, 32 + 16, 8 do
    local arc = c:line({ {x-4,y-5},{x-4,y-2},{x-2,y},{x+2,y},{x+4,y-2},{x+4,y-5} }, 1)
    c:fill(arc:clip(inner), SH)
    local lip = c:line({ {x-3,y-1},{x-1,y-1} }, 1)
    lip:add(c:line({ {x-3,y-3},{x-3,y-2} }, 1))
    c:fill(lip:clip(inner), RIM)
  end
end
-- centre fold between rows (on rows where a scale boundary sits mid-cone)
c:fill(c:line({ {32,26}, {32,29} }, 1):clip(inner), FOLD)
c:fill(c:line({ {32,42}, {32,45} }, 1):clip(inner), FOLD)

local t = c:save(O .. "aseprite/ph/hops.aseprite", O .. "png/ph/hops.png")
print(GV.report(t))
