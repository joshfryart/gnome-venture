local which = app.params.name or "all"
for _, name in ipairs(ORDER) do
  if which == "all" or which == name then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = name }
    local ok, err = xpcall(PICS[name], debug.traceback)
    if not ok then print("ERR " .. name .. ": " .. err) end
    foot()
    c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
  end
end
