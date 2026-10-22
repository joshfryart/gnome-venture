local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local P0, P1, P2 = {12, 43}, {30, 22}, {54, 18}
local function bz(t)
  local a, b, d = (1 - t) ^ 2, 2 * (1 - t) * t, t * t
  return a * P0[1] + b * P1[1] + d * P2[1], a * P0[2] + b * P1[2] + d * P2[2]
end
local function tube(t0, t1, rf)
  local m = c:mask()
  for i = 0, 60 do
    local t = t0 + (t1 - t0) * i / 60
    local x, y = bz(t)
    local r = rf(t)
    m:add(c:ellipse(x, y, r, r))
  end
  return m
end
local pod = tube(0, 1, function(t) return 3 + 5.5 * math.sin(math.pi * t) end)
local slot = tube(0.22, 0.8, function(t) return 1.5 + 3.5 * math.sin(math.pi * (t - 0.22) / 0.58) end)
local stalk = c:line({ {12, 43}, {6, 49} }, 3)
local beans = {}
for i, tt in ipairs({ 0.3, 0.5, 0.7 }) do
  local x, y = bz(tt)
  beans[i] = { math.floor(x + 0.5), math.floor(y + 0.5) }
end
local parts = {
  { "stalk", stalk, GV.ramp("#4a8a3e"), { flat = true } },
  { "pod", pod, GV.ramp("#8c4a1a") },
  { "slot", slot, GV.ramp("#44281c"), { flat = true, rim = false } },
}
for i, b in ipairs(beans) do
  parts[#parts + 1] = { "bean" .. i, c:ellipse(b[1], b[2], 4, 4), "moss", { gloss = { b[1] - 2, b[2] - 2 } } }
end
local p = c:build(parts)
for _, b in ipairs(beans) do c:px(b[1] + 2, b[2] + 1, "#44281c") end
local t = c:save(O .. "aseprite/ph/fava-bean.aseprite", O .. "png/ph/fava-bean.png")
print(GV.report(t))
