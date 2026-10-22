local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function mx(pts) local r = {} for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end return r end

-- wing: leading edge up to a tip, scalloped trailing edge between finger ends
local LW = { {30,29}, {23,24}, {15,21}, {8,15}, {9,33}, {17,39}, {25,44}, {31,46} }
local function wing(pts, flip)
  local m = c:poly(pts)
  local cuts = { {13,40,4.2,4.2}, {21,45,4,3.8}, {28.5,49,3.2,3} }
  for _, e in ipairs(cuts) do
    local x = flip and (63 - e[1]) or e[1]
    m:cut(c:ellipse(x, e[2], e[3], e[4]))
  end
  return m
end
local lw, rw = wing(LW, false), wing(mx(LW), true)

local wingR = GV.ramp("#6e5646")
local furR  = GV.ramp("#4b3a2f", { rim = "#7b66b4" })
local lilac = GV.ramp("#d8d0f5")

local head = c:ellipse(31.5, 26, 7, 6.5)
local earL = c:poly({ {25,25}, {24,13}, {31,21} })
local earR = c:poly(mx({ {25,25}, {24,13}, {31,21} }))
head:add(earL); head:add(earR)

-- echo arcs (2 px), one per side, bulging outward
local arcL = c:line({ {20,9}, {18,11}, {17,14}, {18,17}, {20,19} }, 2)
local arcR = c:line(mx({ {20,9}, {18,11}, {17,14}, {18,17}, {20,19} }), 2)

local p = c:build{
  { "lw", lw, wingR },
  { "rw", rw, wingR },
  { "body", c:ellipse(31.5, 37, 6, 8), furR, { stitch = { side = "lit" } } },
  { "head", head, furR },
  { "arcL", arcL, lilac, { flat = true } },
  { "arcR", arcR, lilac, { flat = true } },
}

-- finger bones
local bone = "#4b3a2f"
c:fill(c:line({ {27,31}, {10,18} }, 1):clip(lw), bone)
c:fill(c:line({ {27,32}, {10,33} }, 1):clip(lw), bone)
c:fill(c:line({ {27,34}, {17,39} }, 1):clip(lw), bone)
c:fill(c:line(mx({ {27,31}, {10,18} }), 1):clip(rw), bone)
c:fill(c:line(mx({ {27,32}, {10,33} }), 1):clip(rw), bone)
c:fill(c:line(mx({ {27,34}, {17,39} }), 1):clip(rw), bone)

-- inner ear
c:paint({ "p", "p", "pp" }, 26, 17, { p = "#8a6a7a" })
c:paint({ ".p", ".p", "pp" }, 36, 17, { p = "#8a6a7a" })
-- eyes (small)
c:eye(27, 25, true); c:eye(34, 25, true)
-- tiny fangs
c:paint({ "c.c" }, 30, 30, { c = "#f1e9e4" })
-- chest chevron
c:paint({ "c...c", ".c.c.", "..c.." }, 29, 34, { c = "#f1e9e4" })

local t = c:save(O .. "aseprite/ph/creature-echo-bat.aseprite", O .. "png/ph/creature-echo-bat.png")
print(GV.report(t))
