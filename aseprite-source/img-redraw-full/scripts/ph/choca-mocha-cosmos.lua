local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local heads = { {14, 19}, {32, 13}, {50, 21} }
local function head(cx, cy)
  local m = c:ellipse(cx, cy, 3, 3)
  for i = 0, 7 do
    local a = i * math.pi / 4 + math.pi / 8
    m:add(c:ellipse(cx + math.cos(a) * 4.6, cy + math.sin(a) * 4.6, 2.2, 2.2))
  end
  return m
end
local stems = c:mask()
for _, h in ipairs(heads) do stems:add(c:line({ {32, 39}, {h[1], h[2]} }, 2)) end

local wine  = GV.ramp("#9c2c4a", { rim = "#c8505e", shade = "#74203a", deep = "#521630", bounce = "#8a2a3e" })
local glass = GV.ramp("#8fcbd8", { rim = "#c8ecdc", shade = "#3f8fb0", deep = "#2f6290" })
local cork  = GV.ramp("#d9a660", { shade = "#b07a45", deep = "#8a4f2a" })
local stemR = GV.ramp("#4a8a3e", { shade = "#2f5a2a" })

local body = c:rrect(21, 39, 43, 55, 6)
body:add(c:rrect(28, 32, 36, 41, 1))
local parts = {
  { "stems", stems, stemR, { flat = true } },
  { "bottle", body, glass, { gloss = { 25, 42 } } },
  { "cork", c:rrect(27, 28, 37, 32, 1), cork },
}
for i, h in ipairs(heads) do
  parts[#parts + 1] = { "head" .. i, head(h[1], h[2]), wine, { gloss = (i == 2) and { h[1] - 4, h[2] - 4 } or false } }
end
local p = c:build(parts)

-- water band with stems visible through it
local water = c:rect(23, 46, 41, 53):clip(body:shrink(2))
c:fill(water, "#5aa0c4")
c:fill(c:rect(23, 46, 41, 46):clip(body:shrink(2)), "#8fcbd8")
for y = 41, 53 do
  c:px(31, y, "#4a8a3e"); c:px(32, y, "#2f5a2a")
end
c:px(30, 49, "#4a8a3e"); c:px(33, 49, "#4a8a3e")
-- glass highlight streak
for y = 43, 52 do c:px(25, y, "#c8ecdc") end
c:px(26, 44, "#c8ecdc")
-- cork texture
c:px(30, 30, "#b07a45"); c:px(34, 29, "#b07a45")

-- flower centres
for _, h in ipairs(heads) do
  c:paint({ "ggg", "ggs", "gss" }, h[1] - 1, h[2] - 1, { g = "#e8a317", s = "#7a3a14" })
end

c:ground(32, 57, 12, 1.5)
local t = c:save(O .. "aseprite/ph/choca-mocha-cosmos.aseprite", O .. "png/ph/choca-mocha-cosmos.png")
print(GV.report(t))
