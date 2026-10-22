local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered pod along axis tip (10,53) -> top (48,18)
local ax, ay, bx, by = 10, 53, 48, 18
local L = math.sqrt((bx-ax)^2 + (by-ay)^2)
local dx, dy = (bx-ax)/L, (by-ay)/L
local nx, ny = -dy, dx            -- points lower-right
local function hw(t)
  if t < 0.75 then return 1 + 6.5 * math.sin(t / 0.75 * math.pi / 2) ^ 0.8 end
  return 7.5 - (t - 0.75) * 4
end
local L1, L2 = {}, {}
for i = 0, 20 do
  local t = i / 20
  local px, py = ax + dx * L * t, ay + dy * L * t
  local w = hw(t)
  L1[#L1+1] = { px + nx * w, py + ny * w }
  table.insert(L2, 1, { px - nx * w, py - ny * w })
end
local pts = {}
for _, p in ipairs(L1) do pts[#pts+1] = p end
for _, p in ipairs(L2) do pts[#pts+1] = p end
local pod = c:poly(pts)

-- calyx cap: rounded block wrapping the top end, with three pointed sepals
local cap = c:ellipse(48, 19, 6.5, 6.5)
cap:add(c:poly({ {39, 22}, {45, 15}, {43, 27} }))
cap:add(c:poly({ {41, 15}, {48, 12}, {45, 20} }))
cap:add(c:poly({ {46, 29}, {52, 22}, {48, 21} }))

local stem = c:line({ {52, 14}, {56, 10} }, 3)

c:build{
  { "pod",  pod,  "gold", { gloss = { 22, 36 } } },
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "cap",  cap,  GV.ramp("#4a8a3e") },
}

-- lengthwise ridge lines, offset from the centre line
local sh = GV.R.gold.shade
for _, off in ipairs({ -3, 3 }) do
  for i = 3, 34 do
    local t = i / L
    local w = hw(t)
    if math.abs(off) < w - 1.5 then
      local x = math.floor(ax + dx * i + nx * off + 0.5)
      local y = math.floor(ay + dy * i + ny * off + 0.5)
      if pod:has(x, y) and not cap:has(x, y) then
        local cur = c:get(x, y)
        if cur ~= GV.R.gold.gloss and cur ~= GV.R.gold.dot then c:px(x, y, sh) end
      end
    end
  end
end

local t = c:save(O .. "aseprite/ph/okra.aseprite", O .. "png/ph/okra.png")
print(GV.report(t))
