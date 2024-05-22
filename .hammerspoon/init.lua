AppKeyBindings = {} -- key bindings for opening apps
WebKeyBindings = {} -- key bindings for opening web pages

function AddAppKeyBinding(app, mods, key)
  k = hs.hotkey.bind(mods, key, function()
    hs.application.open(app)
  end)
  AppKeyBindings[app] = k
end

function AddWebKeyBinding(url, mods, key)
 k = hs.hotkey.bind(mods, key, function()
  hs.urlevent.openURL(url)
end)
  WebKeyBindings[url] = k
end

function ShowKeyBindings()
  local rect = {x=100, y=100, w=100, h=100}
  local sheetView = hs.webview.new(rect)
  sheetView:windowTitle("CheatSheets")
  sheetView:windowStyle("utility")
  sheetView:allowGestures(true)
  sheetView:allowNewWindows(false)
  sheetView:level(hs.drawing.windowLevels.tornOffMenu)
  local cscreen = hs.screen.mainScreen()
  local cres = cscreen:fullFrame()
  sheetView:frame({
      x = cres.x+cres.w*0.15/2,
      y = cres.y+cres.h*0.25/2,
      w = cres.w*0.85,
      h = cres.h*0.75
  })
  -- todo: parse key binding dictionaries to hmtl
  -- sheetView:html(webcontent)
  sheetView:show()
  -- to do: check if the web view is already opened
end

-- rebinding
hs.hotkey.bind("ctrl", "/", function()
  hs.eventtap.keyStroke({}, "\\")
end)

hs.hotkey.bind("ctrl", "]", function()
  hs.eventtap.keyStroke({}, "|")
end)

-- app shortcuts
AddAppKeyBinding("Bruno.app", {"ctrl", "shift"}, "B")
AddAppKeyBinding("alacritty", {"ctrl", "shift"}, "C")
AddAppKeyBinding("Docker.app", {"ctrl", "shift"}, "D")
AddAppKeyBinding("firefox", {"ctrl", "shift"}, "F")

-- website shortcuts
AddWebKeyBinding("https://github.com/", {"ctrl", "cmd"}, "G")
AddWebKeyBinding("https://linear.app/", {"ctrl", "cmd"}, "L")

hs.hotkey.bind({"ctrl", "shift"}, "H", "show key bindings", ShowKeyBindings)
