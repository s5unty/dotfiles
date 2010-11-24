-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Debian menu entries
require("debian.menu")

require("vicious")

-- {{{ General
modkey   = "Mod4"
terminal = "x-terminal-emulator"
editor   = os.getenv("EDITOR") or "editor"
theme    = awful.util.getdir("config") .. "/theme.lua"
beautiful.init (theme)

toggletags = {
	["x-terminal-emulator"] = { screen = 1, tag = 8 },
}

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
	awful.layout.suit.tile.top,
	awful.layout.suit.tile.right,
}

tags = { }
mytags = {
	{ layout = layouts[2], mwfact = 0.668, nmaster=1 },
	{ layout = layouts[2], mwfact = 0.618, nmaster=1 },
	{ layout = layouts[1], mwfact = 0.500, nmaster=1 },
	{ layout = layouts[2], mwfact = 0.668, nmaster=1 },
	{ layout = layouts[1], mwfact = 0.618, nmaster=1 },
	{ layout = layouts[1], mwfact = 0.618, nmaster=1 },
	{ layout = layouts[2], mwfact = 0.500, nmaster=2 },
	{ layout = awful.layout.suit.fair },
}
for s = 1, screen.count() do
	tags[s] = awful.tag({ "☷", "☳", "☵", "☱", "☶", "☲", "☴", "☰" }, s)
	for i, v in ipairs(mytags) do
		awful.tag.setproperty(tags[s][i], "layout",   v.layout)
		awful.tag.setproperty(tags[s][i], "mwfact",   v.mwfact)
		awful.tag.setproperty(tags[s][i], "nmaster",  v.nmaster)
	end
end
-- }}}

-- {{{ Wibox
-- Menu {{{2
mymainmenu = awful.menu.new({
	items = {
		{ "Debian", debian.menu.Debian_menu.Debian }
	}
})
mylauncher = awful.widget.launcher({
	image = image(beautiful.awesome_icon),
	menu  = mymainmenu
})

-- Cpu Graph {{{2
mycpugraph = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
mycpugraph:set_width(80)
mycpugraph:set_background_color('#535d6c')
mycpugraph:set_color('#FF5656')
mycpugraph:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
vicious.register(mycpugraph, vicious.widgets.cpu, '$1', 3)

-- Separator {{{
myspacer         = widget({ type = "textbox", name = "myspacer" })
myseparator      = widget({ type = "textbox", name = "myseparator" })
myspacer.text    = " "
myseparator.text = "|"

-- Others {{{2
--mytextclock = awful.widget.textclock({ align = "right" })
mytextclock = widget({ type = 'textbox' })
vicious.register(mytextclock, vicious.widgets.date, ' %b %d, %R ', 60)

mysystray = widget({ type = "systray" })
mytasklist = {}
mytaglist = {}
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

-- Mouse bindings {{{2
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ width=250 })
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end)
)
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext)
)

-- Install {{{2
for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(function(c)
		return awful.widget.tasklist.label.currenttags(c, s)
	end, mytasklist.buttons)

	-- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s, height = 20 })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            ["layout"] = awful.widget.layout.horizontal.leftright
        },
        s == 1 and mysystray or nil,
        mylayoutbox[s],
        mytextclock,
        mycpugraph,
        mytasklist[s],
        ["layout"] = awful.widget.layout.horizontal.rightleft
    }
end

-- }}}1

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext)
))

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Key bindings

-- {{{ Global
globalkeys = awful.util.table.join (

    -- {{{ Screen
	awful.key({ modkey, "Control" }, "h",   function () awful.screen.focus_relative (-1) end),
	awful.key({ modkey, "Control" }, "l",   function () awful.screen.focus_relative ( 1) end),
	awful.key({ modkey }, "Escape", function () mymainmenu:show(true)  end),
    -- }}}

    -- {{{ Tag
	awful.key({ modkey            }, "grave",   awful.tag.history.restore),
	awful.key({ modkey            }, ";",       awful.tag.history.restore),
	awful.key({ modkey, "Control" }, ".",       awful.tag.viewnext),
	awful.key({ modkey, "Control" }, ",",       awful.tag.viewprev),
	awful.key({ modkey,           }, "minus",   function () awful.tag.incmwfact(-0.05) end),
	awful.key({ modkey,           }, "equal",   function () awful.tag.incmwfact( 0.05) end),
	awful.key({ modkey, "Shift"   }, "minus",   function () awful.tag.incnmaster(-1)   end),
	awful.key({ modkey, "Shift"   }, "equal",   function () awful.tag.incnmaster( 1)   end),
	awful.key({ modkey, "Control" }, "minus",   function () awful.tag.incncol(-1)      end),
	awful.key({ modkey, "Control" }, "equal",   function () awful.tag.incncol( 1)      end),
    -- }}}

    -- {{{ Clients
	awful.key({ modkey }, "n", function ()
		awful.client.focus.byidx( 1)
		client.focus:raise()
	end),
	awful.key({ modkey }, "p", function ()
		awful.client.focus.byidx(-1)
		client.focus:raise()
	end),
	awful.key({ modkey }, "Tab", function ()
		awful.client.focus.history.previous()
		client.focus:raise()
	end),
	awful.key({ modkey }, "y", function ()
		local c = awful.client.getmarked()[1]
		if c then
			awful.tag.viewonly(c:tags()[1])
			client.focus = c
			c:raise()
		end
	end),

	awful.key({ modkey }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey }, "z", awful.client.movetoscreen),
	awful.key({ modkey }, "o", awful.client.floating.toggle),
	awful.key({ modkey }, "b", awful.client.togglemarked),

	awful.key({ modkey }, ".",      function () awful.client.swap.byidx( 1) end),
	awful.key({ modkey }, ",",      function () awful.client.swap.byidx(-1) end),

	awful.key({ modkey }, "Up",     function () awful.client.focus.bydirection("up")    end),
	awful.key({ modkey }, "k",      function () awful.client.focus.bydirection("up")    end),
	awful.key({ modkey }, "Down",   function () awful.client.focus.bydirection("down")  end),
	awful.key({ modkey }, "j",      function () awful.client.focus.bydirection("down")  end),
	awful.key({ modkey }, "Left",   function () awful.client.focus.bydirection("left")  end),
	awful.key({ modkey }, "h",      function () awful.client.focus.bydirection("left")  end),
	awful.key({ modkey }, "Right",  function () awful.client.focus.bydirection("right") end),
	awful.key({ modkey }, "l",      function () awful.client.focus.bydirection("right") end),
    -- }}}

    -- {{{ Layout
	awful.key({ modkey, "Control" }, "Return", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "Return", function () awful.layout.inc(layouts, -1) end),
    -- }}}

    -- {{{ Program
	awful.key({ modkey }, "F1", function () awful.util.spawn("x-terminal-emulator -name Weechat -T Weechat -e weechat-curses") end),
	awful.key({ modkey }, "F2", function () awful.util.spawn("x-www-browser") end),
	awful.key({ modkey }, "F3", function () awful.util.spawn("x-terminal-emulator -name Mutt -T Mutt -e mutt") end),
	awful.key({ modkey }, "F4", function () awful.util.spawn("VirtualBox --startvm 'WindowsXP'") end),
	-- awful.key({ modkey }, "i",  function () awful.util.spawn("x-terminal-emulator -e zsh -c 'stty -ixon; vim'") end),
	awful.key({ modkey }, "space", function () awful.util.spawn("x-terminal-emulator") end),
	awful.key({ modkey, "Shift" }, "space", function () awful.util.spawn("x-terminal-emulator -e ranger") end),
	awful.key({ modkey }, "Print", function () awful.util.spawn("scrot -u /tmp/'%Y-%m-%d_$wx$h.png'") end),
	awful.key({        }, "Print", function () awful.util.spawn("scrot /tmp/'%Y-%m-%d_$wx$h.png'") end),
	awful.key({        }, "XF86Mail", function () awful.util.spawn("x-terminal-emulator -name Mutt -T Mutt -e mutt") end),
	awful.key({        }, "XF86MyComputer", function () awful.tag.viewonly(tags[1][1]) end),
	awful.key({        }, "XF86AudioPlay",        function () awful.util.spawn("mocp.sh") end),
	awful.key({        }, "XF86AudioStop",        function () awful.util.spawn("mocp -s") end),
	awful.key({        }, "XF86AudioPrev",        function () awful.util.spawn("mocp -r") end),
	awful.key({        }, "XF86AudioNext",        function () awful.util.spawn("mocp -f") end),
	awful.key({        }, "XF86AudioLowerVolume", function () awful.util.spawn("mocp -v -1") end),
	awful.key({        }, "XF86AudioRaiseVolume", function () awful.util.spawn("mocp -v +1") end),
    -- }}}

    -- {{{ calendar
	awful.key({ modkey, "Control" }, "d", function ()
		if calendar ~= nil then
			naughty.destroy(calendar)
			calendar = nil
			return
		end

		local fc = ""
		local f  = io.popen("cal; date")
		for line in f:lines() do
			fc = fc .. line .. '\n'
		end
		f:close()

		calendar = naughty.notify({
			text = string.format('<span font_desc="%s">%s</span>', "Envy Code R", fc),
            position = "bottom_right", --font = "Envy Code R",
			timeout = 0, width = 230, screen = mouse.screen })
	end),
    -- }}}

    -- {{{ sdcv/stardict
	awful.key({ modkey }, "d", function ()
		local f = io.popen("xsel -o")
		local new_word = f:read("*a")
		f:close()

		if frame ~= nil then
			naughty.destroy(frame)
			frame = nil
			if old_word == new_word then
				return
			end
		end
		old_word = new_word

		local fc = ""
		local f  = io.popen("sdcv -n --utf8-output -u 'XDICT英汉辞典' "..new_word)
		for line in f:lines() do
			fc = fc .. line .. '\n'
		end
		f:close()

		frame = naughty.notify({ text = fc, timeout = 15, width = 360 })
	end),
	awful.key({ modkey, "Shift" }, "d", function ()
		awful.prompt.run({prompt = "Dict: "}, mypromptbox[mouse.screen].widget, function(cin_word)
			naughty.destroy(frame)

			if cin_word == "" then
				return
			end

			local fc = ""
			local f  = io.popen("sdcv -n --utf8-output -u 'XDICT英汉辞典' "..cin_word)
			for line in f:lines() do
				fc = fc .. line .. '\n'
			end
			f:close()

			frame = naughty.notify({ text = fc, timeout = 30, width = 360 })
		end, nil, awful.util.getdir("cache").."/dict")
	end),
    -- }}}

    -- {{{ Others
	awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
	awful.key({ modkey, "Control" }, "r", awesome.restart)
    -- }}}

)
--- }}}

-- {{{ Tags
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	--
	-- 1  2  3  4  5  6  7  8
	-- ------------------------
	-- 1  2  3  |   1  2  3  4
	--  4  5  6 |    q  w  e
	--   7  8   |     a  s
	-- ------------------------
	--
	if     i == 4 then j = "q"
	elseif i == 5 then j = "w"
	elseif i == 6 then j = "e"
	elseif i == 7 then j = "a"
	elseif i == 8 then j = "s"
	else   j = i
	end

	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, j, function ()
			local screen = mouse.screen
			local t = awful.tag.selected(screen)
			local v = tags[screen][i]
			if v == t and i < 4 then
				awful.tag.history.restore(screen)
			elseif v == t then
				return -- keep the history
			else
				awful.tag.viewonly(v)
			end
		end),
		awful.key({ modkey, "Control" }, j, function ()
			local screen = mouse.screen
			if tags[screen][i] then
				awful.tag.viewtoggle(tags[screen][i])
			end
		end),
		awful.key({ modkey, "Shift" }, j, function ()
			if client.focus and tags[client.focus.screen][i] then
				awful.client.movetotag(tags[client.focus.screen][i])
			end
		end),
		awful.key({ modkey, "Control", "Shift" }, j, function ()
			if client.focus and tags[client.focus.screen][i] then
				awful.client.toggletag(tags[client.focus.screen][i])
			end
		end)
	)
end
-- }}}

-- {{{ Client
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "t",       function (c)
		c.ontop = not c.ontop
	end),

    awful.key({ modkey,           }, "i",       function (c)
		c.minimized = not c.minimized
	end),

	awful.key({ modkey            }, "c",       function (c)
		c:kill()
	end),

	awful.key({ modkey, "Shift"   }, "r",       function (c)
		c:redraw()
	end),

	awful.key({ modkey            }, "f",       function (c)
		c.fullscreen = not c.fullscreen
	end),

	awful.key({ modkey            }, "m",       function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
		c:raise()
	end),

	awful.key({ modkey            }, "/",       function (c)
		c:raise()
	end),

	awful.key({ modkey            }, "BackSpace",function (c)
		c:swap(awful.client.getmaster())
	end),

	awful.key({ modkey            }, "backslash",function (c)
        awful.client.setslave(c)
        awful.client.focus.history.previous()
	end),

	awful.key({ modkey,           }, "Return",  function (c)
		if (c:tags()[1]) then
			awful.tag.viewonly(c:tags()[1])
		end
	end)
)
-- }}}

root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
	{ rule = { },
	  properties = { border_width = beautiful.border_width,
					 border_color = beautiful.border_normal,
					 focus = true,
					 keys = clientkeys,
					 buttons = clientbuttons } },
	{ rule = { class = "Qq" },
	  properties = { floating = true } },
	{ rule = { instance = "MPlayer" },
	  properties = { floating = true } },
	{ rule = { instance = "gimp" },
	  properties = { floating = true } },
	{ rule = { instance = "Download" },
	  properties = { floating = true } },
	{ rule = { instance = "Browser" },
	  properties = { floating = true } },
	{ rule = { instance = "Extension" },
	  properties = { floating = true } },

	-- Set Firefox to always map on tags number 2 of screen 1.
	{ rule = { instance = "Navigator" },
	  properties = { tag = tags[1][2], floating = false, border_width = 0 } },
	{ rule = { instance = "Mutt" },
	  properties = { tag = tags[1][3] } },
	{ rule = { instance = "Weechat" },
	  properties = { tag = tags[1][3] } },
	{ rule = { class = "VirtualBox" },
	  properties = { tag = tags[1][6] } },
	{ rule = { instance = "ssh-askpass" },
	  properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
	-- Add a titlebar
	-- awful.titlebar.add(c, { modkey = modkey })

	-- Enable sloppy focus
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			-- client.focus = c
		end
	end)

	-- Check application->toggletag mappings.
	local cls = c.class
	local inst = c.instance
	local target
	if toggletags[cls] then
		target = toggletags[cls]
		awful.client.toggletag(tags[target.screen][target.tag], c)
		client.focus = c
	elseif toggletags[inst] then
		target = toggletags[inst]
		awful.client.toggletag(tags[target.screen][target.tag], c)
		client.focus = c
	end

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end

	c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.add_signal("marked", function(c) c.border_color = beautiful.border_marked end)
-- }}}

-- {{{ Autorun
--awful.util.spawn("/opt/dropbox/bin/dropbox start -i") --
-- }}}