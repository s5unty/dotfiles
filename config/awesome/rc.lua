-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Utilities
local lain = require("lain")

-- Load Debian menu entries
require("debian.menu")
-- Make `awesome-client` happy
require("awful.remote")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart windowless processes
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        findme = cmd
        firstspace = cmd:find(" ")
        if firstspace then
            findme = cmd:sub(0, firstspace-1)
        end
        awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
    end
end

run_once({ "unclutter -root" })
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/init.lua")
awful.util.terminal = "x-terminal-emulator"
awful.util.tagnames = { "☷", "☳", "☵", "☱", "☶", "☲", "☴", "☰" }

-- This is used later as the default terminal and editor to run.
local terminal     = "urxvt" or "xterm"
local editor       = os.getenv("EDITOR") or "nano" or "vi"
local gui_editor   = "gvim"
local browser      = "google-chrome"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.right,
    awful.layout.suit.tile.top,
    awful.layout.suit.corner.sw,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
awful.util.taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
                )

awful.util.tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function()
                         local instance = nil

                         return function ()
                             if instance and instance.wibox.visible then
                                 instance:hide()
                                 instance = nil
                             else
                                 instance = awful.menu.clients({ theme = { width = 250 } })
                             end
                        end
                     end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(-1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                                          end))

awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Hotkeys
    awful.key({                   }, "F1",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey, "Control" }, ",",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey, "Control" }, ".",   awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, ";", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  previous nonempty", group = "tag"}),

    -- Default client focus
    awful.key({ modkey,           }, "n",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "p",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({                   }, "F10", function () awful.util.mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

	-- How can I make a minimized client visible again?
	-- https://bbs.archlinux.org/viewtopic.php?pid=838211
	awful.key({ modkey, "Shift"   }, "i",
		function ()
			local tag = awful.tag.selected()
			for i=1, #tag:clients() do
				tag:clients()[i].minimized=false
			end
		end),

    -- Layout manipulation
    awful.key({ modkey            }, ".", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey            }, ",", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "0", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey,           }, "9", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
            if s.mybottomwibox then
                s.mybottomwibox.visible = not s.mybottomwibox.visible
            end
        end
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end),  -- move to previous tag
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end),  -- move to next tag
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end),

    -- Standard program
    awful.key({ modkey,           }, "space", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey,           }, "equal",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "minus",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "equal",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "minus",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "equal",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "minus",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "Return", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "i",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key({ modkey, }, "grave", function () awful.screen.focused().quake:toggle() end),

    -- Widgets popups
    -- awful.key({ altkey, }, "c", function () lain.widget.calendar.show(7) end),
    -- awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end),
    -- awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end),

    -- Copy primary to clipboard (terminals to gtk)
    -- awful.key({ modkey }, "c", function () awful.spawn("xsel | xsel -i -b") end),
    -- Copy clipboard to primary (gtk to terminals)
    -- awful.key({ modkey }, "v", function () awful.spawn("xsel -b | xsel") end),

    -- User programs
    -- awful.key({ modkey }, "e", function () awful.spawn(gui_editor) end),
    -- awful.key({ modkey }, "q", function () awful.spawn(browser) end),
    awful.key({ modkey }, "F1", function () awful.util.spawn(terminal.." -name Ranger -T Ranger -e zsh -c ranger") end),
    awful.key({ modkey }, "F2", function () awful.util.spawn("x-www-browser") end),
    awful.key({ modkey }, "F3", function () awful.util.spawn(terminal.." -name Mutt -T Mutt -e zsh -c mutt") end),
    awful.key({ modkey }, "F4", function () awful.util.spawn("VirtualBox --startvm 'win7'") end),
    awful.key({        }, "Scroll_Lock",   function () awful.util.spawn("/sun/.config/awesome/screensaver lock") end),
    awful.key({        }, "Pause",         function () awful.util.spawn("/sun/.config/awesome/screensaver pause") end),

    -- imagemagick / maim / xdotool / slop
    awful.key({        }, "Print", function () awful.spawn("/sun/.config/awesome/takescreen dual") end),
    awful.key({ "Ctrl" }, "Print", function () awful.spawn("/sun/.config/awesome/takescreen full") end),
    awful.key({ altkey }, "Print", function () awful.spawn("/sun/.config/awesome/takescreen active") end),
    awful.key({ modkey }, "Print", function () awful.spawn("/sun/.config/awesome/takescreen select") end),

    -- sdcv/stardict
    awful.key({ modkey }, "d",
        function ()
            local f = io.popen("gpaste-client get 0")
            local word = f:read("*a")
            f:close()
            local f = io.popen("sdcv -n --utf8-output -u 'jmdict-ja-en' -u '朗道英汉字典5.0' "..word.." | tail -n +5 | sed -s 's/<\+/＜/g' | sed -s 's/>\+/＞/g' | sed -s 's/《/＜/g' | sed -s 's/》/＞/g' | sed '$d' | awk 'NR > 1 { print h } { h = $0 } END { ORS = \"\"; print h }'")
            local c = f:read("*a")
            f:close()

            frame = naughty.notify({ text = c, timeout = 15, width = 360, screen = mouse.screen })
        end,
        {description = "translate", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "d", function ()
        awful.prompt.run {
            prompt          = "Dict: ",
            textbox         = awful.screen.focused().mypromptbox.widget,
            history_path    = awful.util.get_cache_dir() .. "/dict",
            exe_callback    = function (cin_word)
                naughty.destroy(frame)

                if cin_word == "" then
                    return
                end
                local f = io.popen("sdcv -n --utf8-output -u 'jmdict-ja-en' -u '21世纪英汉汉英双向词典' "..cin_word.." | tail -n +5 | sed -s 's/<\+/＜/g' | sed -s 's/>\+/＞/g' | sed -s 's/《/＜/g' | sed -s 's/》/＞/g' | sed '$d' | awk 'NR > 1 { print h } { h = $0 } END { ORS = \"\"; print h }'")
                local c = f:read("*a")
                f:close()

                frame = naughty.notify({ text = c, font='Envy Code R 9', timeout = 30, width = 360, screen = mouse.screen })
            end
            }
        end,
        {description = "dict prompt", group = "launcher"}),

    -- calendar
    awful.key({ modkey, "Control" }, "d",
        function ()
            if mycalendar ~= nil then
                naughty.destroy(mycalendar)
                mycalendar = nil
                return
            end
            -- 从这里开始是为了删除末尾的空行和换行符，这样显示在 naughty 的效果会更紧凑一些
            local f = io.popen("gcal -i -s1 --highlighting=\" :#: :*\" -qcn --chinese-months -cezk . | tail -n +3 | awk 'NR > 1 { print h } { h = $0 } END { ORS = \"\"; print h }'")
            local c = f:read("*a")
            f:close()

            mycalendar = naughty.notify({
                text = string.format('<span font_desc="%s">%s</span>', "Envy Code R 10", c),
                position = "bottom_right", --font = "Envy Code R",
                timeout = 0, width = 530, screen = mouse.screen })
        end,
        {description = "calendar", group = "launcher"}),

    -- Default
    --[[ Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
    --]]
    --[[ dmenu
    awful.key({ modkey }, "x", function ()
        awful.spawn(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
        beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
		end)
    --]]
    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
    --]]
)

clientkeys = awful.util.table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "o",      awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey            }, "BackSpace", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "z",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "i",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 8 do
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
        -- View tag only.
        awful.key({ modkey }, j,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ altkey, "Control" }, j,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, j,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control" }, j,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = false } },

    -- Set Firefox to always map on the first tag on screen 1.
    { rule = { class = "Firefox" },
      properties = { screen = 1, tag = screen[1].tags[1] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized = true } },
    -- 升级到 3.5.6 后，解决终端不能最大化显示的问题
    -- http://superuser.com/questions/347001/how-can-i-force-gvim-in-awesome-to-fill-the-screen
    -- http://awesome.naquadah.org/wiki/FAQ#How_to_remove_gaps_between_windows.3F
    -- http://www.mail-archive.com/awesome@naquadah.org/msg01767.html
    { rule = { class = "URxvt" },
    properties = { size_hints_honor = false } },

    { rule = { instance = "MPlayer" },
    properties = { floating = true } },
    { rule = { instance = "gimp" },
    properties = { floating = true } },
    { rule = { class = "Screenkey" },
    properties = { floating = true }, switchtotag = true },
    { rule = { instance = "feh" },
    properties = { floating = true }, callback = awful.placement.under_mouse },
    { rule = { class = "Android" },
    properties = { floating = true } },
    { rule = { class = "GNUstep" },
    properties = { floating = true } },
    { rule = { class = "Virt-manager.py" },
    properties = { floating = true } },

    -- Set Iceweasel/Firefox to always map on tag 7 of screen 1.
    { rule = { class = "Google-chrome" },
    properties = { tag = screen[1].tags[1][7], border_width = 0 } },
    { rule = { class = "Google-chrome", role = "app" },
    properties = { tag = screen[1].tags[1][7], floating = true } },
    { rule = { class = "Google-chrome", role = "pop-up" },
    properties = { tag = screen[1].tags[1][7], floating = true } },
    { rule = { class = "Chromium" },
    properties = { tag = screen[1].tags[1][7], border_width = 0 } },
    { rule = { class = "Chromium", role = "app" },
    properties = { tag = screen[1].tags[1][7], floating = true } },
    { rule = { class = "Chromium", role = "pop-up" },
    properties = { tag = screen[1].tags[1][7], floating = true } },


    { rule = { instance = "plugin-container" },
    properties = { tag = screen[1].tags[1][7], floating = true, border_width = 0 } },
    { rule = { instance = "Weechat" },
    properties = { tag = screen[1].tags[1][8] } },
    { rule = { instance = "Mutt" },
    properties = { tag = screen[1].tags[1][8] } },
    { rule = { class = "Gtk-recordmydesktop" },
    properties = { floating=true } },
    { rule = { instance = "CMatrix" },
    properties = { floating=true, ontop=true },
	callback = function (c)
		c.screen = 1
		c:geometry( { x = 0, y = 0, width = 3840, height = 1080 } )
	end },

    { rule = { class = "Pidgin" },
    properties = { floating=true, ontop=true } },
    { rule = { class = "Cssh" },
    properties = { floating=true, ontop=true },
    callback = function (c)
        local cl_width = 180    -- width of cluster ssh agent window
        local def_left = false  -- default placement.
        local scr_area = screen[c.screen].workarea
        local geometry = nil

        -- scr_area is unaffected, so we can use the naive coordinates
        if geometry == nil then
            if def_left then
                geometry = {x=scr_area.x, y=scr_area.y, width=cl_width}
            else
                geometry = {x=scr_area.x+scr_area.width-cl_width, y=scr_area.y, width=cl_width}
            end
        end
        c:geometry(geometry)
    end },
    { rule = { class = "Keepassx" },
    properties = { floating=true, ontop=true } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized then -- no borders if only 1 client visible
            c.border_width = 0
        elseif #awful.screen.focused().clients > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("marked",  function(c) c.border_color = beautiful.border_marked end)
-- }}}
