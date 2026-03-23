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
	t = "Ghostty",
	b = "Safari",
	s = "Slack",
	f = "Finder",
	m = "Mail",
	o = "Obsidian",
	p = "1Password",
}

for key, app in pairs(apps) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

-- Website launchers (Meh)
local sites = {
	g = "https://github.com",
	c = "https://claude.ai",
	y = "https://youtube.com",
}

for key, url in pairs(sites) do
	hs.hotkey.bind(meh, key, function()
		hs.urlevent.openURL(url)
	end)
end

-- Reload config
hs.hotkey.bind(hyper, "r", function()
	hs.reload()
	hs.alert.show("Config reloaded")
end)
