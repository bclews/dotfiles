local hyper = { "cmd", "alt", "shift", "ctrl" }
local meh = { "ctrl", "alt", "shift" }

-- Auto-reload on save
hs.pathwatcher
	.new(os.getenv("HOME") .. "/.hammerspoon/", function()
		hs.reload()
	end)
	:start()
hs.alert.show("Hammerspoon loaded")

-- App launchers (Hyper)
local apps = {
	c = "Claude",
	g = "Ghostty",
	m = "Messages",
	n = "Notes",
	o = "Microsoft Outlook",
	p = "1Password",
	s = "Safari",
	t = "Microsoft Teams",
	x = "Xcode",
}

for key, app in pairs(apps) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

-- Website launchers (Meh)
local sites = {
	g = "https://github.com",
}

for key, url in pairs(sites) do
	hs.hotkey.bind(meh, key, function()
		hs.urlevent.openURL(url)
	end)
end

-- System app launchers (Hyper) - these need special handling
hs.hotkey.bind(hyper, "a", function()
	hs.application.open("com.apple.ActivityMonitor")
end)

hs.hotkey.bind(hyper, "f", function()
	hs.application.open("com.apple.finder")
end)

-- Reload config
hs.hotkey.bind(hyper, "r", function()
	hs.reload()
	hs.alert.show("Config reloaded")
end)
