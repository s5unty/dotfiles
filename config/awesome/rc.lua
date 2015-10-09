-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local bling = require("blingbling")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Load Debian menu entries
require("debian.menu")

require("vicious")
os.setlocale("zh_CN.UTF-8")

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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(awful.util.getdir("config") .. "/theme.lua")
beautiful.init("/sun/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.tiled(beautiful.wallpaper, s, {0, 0})
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
mytags = {
    { mwfact = 0.500, nmaster=2, layout = awful.layout.suit.tile.bottom },
    { mwfact = 0.500, nmaster=1, layout = awful.layout.suit.fair.horizontal },
    { mwfact = 0.500, nmaster=1, layout = awful.layout.suit.tile.left },
    { mwfact = 0.382, nmaster=1, layout = awful.layout.suit.tile.bottom },
    { mwfact = 0.382, nmaster=2, layout = awful.layout.suit.tile.left },
    { mwfact = 0.668, nmaster=1, layout = awful.layout.suit.tile.left },
    { mwfact = 0.618, nmaster=1, layout = awful.layout.suit.tile },
    { mwfact = 0.618, nmaster=1, layout = awful.layout.suit.tile.bottom  },
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

-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu({
    items = {
        { "Debian", debian.menu.Debian_menu.Debian, beautiful.awesome_icon }
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget {{{3
mytextclock = awful.widget.textclock("<span color='#FFFFFF'>%m/%d</span>(%a)<span color='#FFFFFF'>%l:%M</span>(%p)")

-- Create a promodoro widget {{{3
pomodoro = awful.widget.progressbar()
pomodoro:set_width(1)
pomodoro:set_max_value(100)
pomodoro:set_background_color(theme.bg_normal)
pomodoro:set_color('#AECF96')
-- awesome-3.4
--pomodoro:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
-- awesome-3.5
pomodoro:set_color({ type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { { 0, '#AECF96' }, { 0.25, "#88A175" }, { 1, "#FF5656" } }})
pomodoro:set_ticks(true) -- false:平滑的整体，true:间隙的个体

-- Disk IO {{{3
dio_graph = bling.line_graph({ height = 23, width = 65 })
dio_graph:set_show_text(true)
dio_graph:set_label("I/O")
--dio_graph:set_tiles_color("#292B2F")
dio_graph:set_graph_color("#AAAAAA")
dio_graph:set_graph_line_color("#AAAAAA")
vicious.register(dio_graph, vicious.widgets.dio, "${sda total_mb}")

-- CPU widget {{{3
cpu_graph = bling.line_graph({ height = 23, width = 65 })
cpu_graph:set_show_text(true)
cpu_graph:set_label("CPU")
--cpu_graph:set_tiles_color("#292B2F")
cpu_graph:set_graph_color("#AAAAAA")
cpu_graph:set_graph_line_color("#AAAAAA")
vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)

-- Create a wibox for each screen and add it {{{3
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
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

-- Systray {{{3
mysystray = wibox.widget.systray()
-- }}}

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(pomodoro)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(cpu_graph)
    right_layout:add(dio_graph)
    right_layout:add(mytextclock)
    if s == 1 then right_layout:add(mysystray) end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Quake3 console
-- http://awesome.naquadah.org/wiki/Drop-down_terminal
-- save as: ~/.config/awesome/quake.lua
local quake3 = require("quake3")

local quakeconsole = {}
for s = 1, screen.count() do
   quakeconsole[s] = quake({ terminal = terminal,
			     height = 0.3,
			     screen = s })
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- {{{ Screen
    awful.key({ modkey, "Control" }, "h",   function () awful.screen.focus_relative (-1) end),
    awful.key({ modkey, "Control" }, "l",   function () awful.screen.focus_relative ( 1) end),
    awful.key({ modkey },       "Escape",   function () revelation({ class = "URxvt" }) end), -- TODO except_rule ={"Mutt"}
    -- awful.key({ modkey }, "Escape", function () mymainmenu:show(true)  end),
    -- }}}

    -- {{{ Tag
    awful.key({ modkey            }, "Tab",     awful.tag.history.restore),
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
    awful.key({ "Control" }, "Tab", function ()
        awful.client.focus.history.previous()
        client.focus:raise()
    end),
    awful.key({ modkey }, "y", function ()
        local c = awful.client.getmarked()[1]
        if c then
            awful.tag.viewonly(c:tags()[1])
            client.focus = c
            c:raise()
            awful.client.togglemarked (c)
        end
    end),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "z", awful.client.movetoscreen),
    awful.key({ modkey }, "/", awful.client.movetoscreen),
    awful.key({ modkey }, "o", awful.client.floating.toggle),
    awful.key({ modkey }, "m", awful.client.togglemarked),

    awful.key({ modkey }, ".",      function () awful.client.swap.byidx( 1) end),
    awful.key({ modkey }, ",",      function () awful.client.swap.byidx(-1) end),

    awful.key({ modkey }, "Up",     function () awful.client.focus.bydirection("up")    client.focus:raise() end),
    awful.key({ modkey }, "k",      function () awful.client.focus.bydirection("up")    client.focus:raise() end),
    awful.key({ modkey }, "Down",   function () awful.client.focus.bydirection("down")  client.focus:raise() end),
    awful.key({ modkey }, "j",      function () awful.client.focus.bydirection("down")  client.focus:raise() end),
    awful.key({ modkey }, "Left",   function () awful.client.focus.bydirection("left")  client.focus:raise() end),
    awful.key({ modkey }, "h",      function () awful.client.focus.bydirection("left")  client.focus:raise() end),
    awful.key({ modkey }, "Right",  function () awful.client.focus.bydirection("right") client.focus:raise() end),
    awful.key({ modkey }, "l",      function () awful.client.focus.bydirection("right") client.focus:raise() end),

    -- How can I make a minimized client visible again?
    -- https://bbs.archlinux.org/viewtopic.php?pid=838211
    awful.key({ modkey, "Shift" }, "i", function ()
        local tag = awful.tag.selected()
        for i=1, #tag:clients() do
            tag:clients()[i].minimized=false
            tag:clients()[i]:redraw()
        end
    end),

    -- }}}

    -- {{{ Layout
    awful.key({ modkey, "Control" }, "Return", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.layout.inc(layouts, -1) end),
    -- }}}

    -- {{{ Program
    awful.key({ modkey }, "F1", function () awful.util.spawn(terminal.." -name Ranger -T Ranger -e zsh -c ranger") end),
    awful.key({ modkey }, "F2", function () awful.util.spawn("x-www-browser") end),
    awful.key({ modkey }, "F3", function () awful.util.spawn(terminal.." -name Mutt -T Mutt -e zsh -c mutt") end),
    awful.key({ modkey }, "F4", function () awful.util.spawn("VirtualBox --startvm 'WinXP'") end),
    awful.key({ modkey }, "space", function () awful.util.spawn(terminal) end),
    awful.key({ modkey }, "Print", function () awful.util.spawn("scrot -u /tmp/'%Y-%m-%d_$wx$h.png'") end),
    awful.key({        }, "Print", function () awful.util.spawn("scrot /tmp/'%Y-%m-%d_$wx$h.png'") end),
    awful.key({ modkey, "Control" }, "Print", function () awful.util.spawn("scrot -s /tmp/'%Y-%m-%d_$wx$h.png'") end),
    awful.key({ modkey }, "Scroll_Lock",   function () awful.util.spawn("xscreensaver-command -lock") end),
    -- }}}

    -- {{{ calendar
    awful.key({ modkey, "Control" }, "d", function ()
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
        end),
    -- }}}

    -- {{{ sdcv/stardict
    -- 有些字典的翻译结果包含尖括号，会导致 naughty 无法正常显示。这里替换所有的尖括号，并同时美化显示结果
    awful.key({ modkey }, "d", function ()
        local f = io.popen("gpaste get 0")
        local word = f:read("*a")
        f:close()
        local f = io.popen("sdcv -n --utf8-output -u 'jmdict-ja-en' -u '朗道英汉字典5.0' "..word.." | tail -n +5 | sed -s 's/<\+/＜/g' | sed -s 's/>\+/＞/g' | sed -s 's/《/＜/g' | sed -s 's/》/＞/g' | sed '$d' | awk 'NR > 1 { print h } { h = $0 } END { ORS = \"\"; print h }'")
        local c = f:read("*a")
        f:close()

        frame = naughty.notify({ text = c, timeout = 15, width = 360, screen = mouse.screen })
    end),
    awful.key({ modkey, "Shift" }, "d", function ()
        awful.prompt.run({prompt = "Dict: "}, mypromptbox[mouse.screen].widget, function(cin_word)
            naughty.destroy(frame)

            if cin_word == "" then
                return
            end
            local f = io.popen("sdcv -n --utf8-output -u 'jmdict-ja-en' -u '21世纪英汉汉英双向词典' "..cin_word.." | tail -n +5 | sed -s 's/<\+/＜/g' | sed -s 's/>\+/＞/g' | sed -s 's/《/＜/g' | sed -s 's/》/＞/g' | sed '$d' | awk 'NR > 1 { print h } { h = $0 } END { ORS = \"\"; print h }'")
            local c = f:read("*a")
            f:close()

            frame = naughty.notify({ text = c, font='Envy Code R 9', timeout = 30, width = 360, screen = mouse.screen })
        end, nil, awful.util.getdir("cache").."/dict")
    end),
    -- }}}

    -- {{{ run in terminal
    -- ref@http://awesome.naquadah.org/wiki/Launch_In_Terminal_Keyword
    awful.key({ modkey }, "r", function ()
        awful.prompt.run({prompt="Run: "},
        mypromptbox[mouse.screen].widget, function(command)
            if command:sub(1,1) == ":" then
                command = terminal .. ' -e ' .. command:sub(2)
            end
            awful.util.spawn(command)
        end, function(command, cur_pos, ncomp, shell)
            local term = false
            if command:sub(1,1) == ":" then
                term = true
                command = command:sub(2)
                cur_pos = cur_pos - 1
            end
            command, cur_pos =  awful.completion.shell(command, cur_pos,ncomp,shell)
            if term == true then
                command = ':' .. command
                cur_pos = cur_pos + 1
            end
            return command, cur_pos
        end, awful.util.getdir("cache") .. "/history")
    end),
    -- }}}

    -- {{{ Others
    awful.key({ modkey            }, "grave", function () quakeconsole[mouse.screen]:toggle() end),
    awful.key({ modkey, "Control" }, "r", awesome.restart)
    -- }}}
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "t",       function (c) c.ontop = not c.ontop end),
    awful.key({ modkey,           }, "i",       function (c) c.minimized = not c.minimized end),
    awful.key({ modkey, "Shift"   }, "c",       function (c) c:kill() end),
    awful.key({ modkey, "Shift"   }, "r",       function (c) c:redraw() end),
    awful.key({ modkey, "Shift"   }, "f",       function (c) c.fullscreen = not c.fullscreen end),

    awful.key({ modkey            }, "f",       function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
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

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
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
    elseif i == 9 then j = "Escape"
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
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end),
    awful.key({ modkey, "Shift" }, j, function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end),
    awful.key({ modkey, "Control", "Shift" }, j, function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.tag.viewtoggle(tags[screen][i])
        end
    end)
    )
end

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
    focus = true,
    keys = clientkeys,
    buttons = clientbuttons } },

    -- 升级到 3.5.6 后，解决终端不能最大化显示的问题
    -- http://superuser.com/questions/347001/how-can-i-force-gvim-in-awesome-to-fill-the-screen
    -- http://awesome.naquadah.org/wiki/FAQ#How_to_remove_gaps_between_windows.3F
    -- http://www.mail-archive.com/awesome@naquadah.org/msg01767.html
    { rule = { class = "URxvt" },
    properties = { size_hints_honor = false } },

    { rule = { class = "Iptux" },
    properties = { tag = tags[1][8], floating = true } },
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
    { rule = { class = "Iceweasel" },
    properties = { tag = tags[1][7], border_width = 0 } },
    { rule = { class = "Firefox" },
    properties = { tag = tags[1][7], border_width = 0 } },
    { rule = { class = "Browser" },
    properties = { tag = tags[1][7], floating=true } },

    { rule = { instance = "plugin-container" },
    properties = { tag = tags[1][7], floating = true, border_width = 0 } },
    { rule = { instance = "Weechat" },
    properties = { tag = tags[1][8] } },
    { rule = { instance = "Mutt" },
    properties = { tag = tags[1][8] } },
    { rule = { class = "Gtk-recordmydesktop" },
    properties = { floating=true } },
    { rule = { instance = "CMatrix" },
    properties = { floating=true, ontop=true },
    callback = function (c) c.fullscreen = true end },

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
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            -- 用了鼠标自动隐藏程序 unclutter 以后经常出现
            -- 窗口焦点切换不能的情况，所以还是注掉下面这行
            --
            -- 升级到 3.5.6 后，重新打开观察一段时间
            client.focus = c
        end
    end)

--    if not startup then
--        -- Set the windows at the slave,
--        -- i.e. put it at the end of others instead of setting it master.
--        awful.client.setslave(c)
--
--        -- Put windows in a smart way, only if they does not set an initial position.
--        if not c.size_hints.user_position and not c.size_hints.program_position then
--            awful.placement.no_overlap(c)
--            awful.placement.no_offscreen(c)
--        end
--    elseif not c.size_hints.user_position and not c.size_hints.program_position then
--        -- Prevent clients from being unreachable after screen count change
--        awful.placement.no_offscreen(c)
--    end
--
--    local titlebars_enabled = false
--    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
--        -- buttons for the titlebar
--        local buttons = awful.util.table.join(
--                awful.button({ }, 1, function()
--                    client.focus = c
--                    c:raise()
--                    awful.mouse.client.move(c)
--                end),
--                awful.button({ }, 3, function()
--                    client.focus = c
--                    c:raise()
--                    awful.mouse.client.resize(c)
--                end)
--                )
--
--        -- Widgets that are aligned to the left
--        local left_layout = wibox.layout.fixed.horizontal()
--        left_layout:add(awful.titlebar.widget.iconwidget(c))
--        left_layout:buttons(buttons)
--
--        -- Widgets that are aligned to the right
--        local right_layout = wibox.layout.fixed.horizontal()
--        right_layout:add(awful.titlebar.widget.floatingbutton(c))
--        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
--        right_layout:add(awful.titlebar.widget.stickybutton(c))
--        right_layout:add(awful.titlebar.widget.ontopbutton(c))
--        right_layout:add(awful.titlebar.widget.closebutton(c))
--
--        -- The title goes in the middle
--        local middle_layout = wibox.layout.flex.horizontal()
--        local title = awful.titlebar.widget.titlewidget(c)
--        title:set_align("center")
--        middle_layout:add(title)
--        middle_layout:buttons(buttons)
--
--        -- Now bring it all together
--        local layout = wibox.layout.align.horizontal()
--        layout:set_left(left_layout)
--        layout:set_right(right_layout)
--        layout:set_middle(middle_layout)
--
--        awful.titlebar(c):set_widget(layout)
--    end
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("marked",  function(c) c.border_color = beautiful.border_marked end)
-- }}}
