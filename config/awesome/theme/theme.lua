---------------------------
-- Default awesome theme --
---------------------------

theme = {}

theme.font          = "DejaVu Sans 9"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = "1"
theme.border_normal = "#d5d5d5"
theme.border_focus  = "#000000"
theme.border_marked = "#ff7f24"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = "/sun/.config/awesome/theme/taglist_squares_sel.png"
theme.taglist_squares_unsel = "/sun/.config/awesome/theme/taglist_squares_unsel.png"

theme.tasklist_font = "Envy Code R 10"
theme.tasklist_floating_icon = "/sun/.config/awesome/theme/mark.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = "15"
theme.menu_width  = "100"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper = "/sun/.config/awesome/light_wp.png"

-- You can use your own layout icons like this:
-- http://ni.fr.eu.org/blog/awesome_icons/
-- 直接用脚本画图
-- mkicons --fg trans --bg '#222222' --fg '#aaaaaa' --size 20x20 --margin-top 2 --margin-bottom 2 --margin-left 2 --margin-right 2
theme.layout_fairh      = "/sun/.config/awesome/theme/layout_fairh.png"
theme.layout_fairv      = "/sun/.config/awesome/theme/layout_fairv.png"
theme.layout_floating   = "/sun/.config/awesome/theme/layout_floating.png"
theme.layout_magnifier  = "/sun/.config/awesome/theme/layout_magnifier.png"
theme.layout_max        = "/sun/.config/awesome/theme/layout_max.png"
theme.layout_fullscreen = "/sun/.config/awesome/theme/layout_fullscreen.png"
theme.layout_tilebottom = "/sun/.config/awesome/theme/layout_tilebottom.png"
theme.layout_tileleft   = "/sun/.config/awesome/theme/layout_tileleft.png"
theme.layout_tile       = "/sun/.config/awesome/theme/layout_tile.png"
theme.layout_tiletop    = "/sun/.config/awesome/theme/layout_tiletop.png"
theme.layout_spiral     = "/sun/.config/awesome/theme/layout_spiral.png"
theme.layout_dwindle    = "/sun/.config/awesome/theme/layout_dwindle.png"

theme.awesome_icon = "/usr/share/pixmaps/debian-logo.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
