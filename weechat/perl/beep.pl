#
# Copyright (c) 2006-2008 by FlashCode <flashcode@flashtux.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Speaker beep on highlight/private msg.
#
# History:
# 2009-10-25, Vern Sun <s5unty@gmail.com>:
#     non-official version: make it better with microblogging bot
# 2009-05-02, FlashCode <flashcode@flashtux.org>:
#     version 0.4: sync with last API changes
# 2008-11-05, FlashCode <flashcode@flashtux.org>:
#     version 0.3: conversion to WeeChat 0.3.0+
# 2007-08-10, FlashCode <flashcode@flashtux.org>:
#     version 0.2: upgraded licence to GPL 3
# 2006-09-02, FlashCode <flashcode@flashtux.org>:
#     version 0.1: initial release
#

use strict;
use constant TRUE => 1;
use constant FALSE => 0;

my $version = "0.4";
my $beep_command = "echo -n \a";

# default values in setup file (~/.weechat/plugins.conf)
my $default_beep_highlight = "on";
my $default_beep_pv        = "on";

weechat::register("beep", "FlashCode <flashcode\@flashtux.org>", $version,
                  "GPL3", "Speaker beep on highlight/private message", "", "");
weechat::config_set_plugin("beep_highlight", $default_beep_highlight) if (weechat::config_get_plugin("beep_highlight") eq "");
weechat::config_set_plugin("beep_pv", $default_beep_pv) if (weechat::config_get_plugin("beep_pv") eq "");

weechat::hook_signal("weechat_highlight", "highlight", "");
weechat::hook_signal("irc_pv", "pv", "");

sub highlight
{
    my $need = FALSE;
    my $name = $_[2];

    if (($name !~ /update\@identi\.ca/) &&
        ($name !~ /twitter\.tweet\.im/)) {
        # IM private message
        $need = TRUE;
    } else {
        # microblogging bot message, do not beep
        $need = FALSE;
        # except somebody reply me
        $need = TRUE if ($name =~ /\@s5unty/);
    }

    if ($need) {
        my $beep = weechat::config_get_plugin("beep_highlight");
        system($beep_command) if ($beep eq "on");
    }
    return weechat::WEECHAT_RC_OK;
}

sub pv
{
    my $need = FALSE;
    my $name = $_[2];

    if (($name !~ /update\@identi\.ca/) &&
        ($name !~ /twitter\.tweet\.im/)) {
        # IM private message
        $need = TRUE;
    } else {
        # microblogging bot message, do not beep
        $need = FALSE;
        # except somebody reply me
        $need = TRUE if ($name =~ /\@s5unty/);
    }

    if ($need) {
        my $beep = weechat::config_get_plugin("beep_pv");
        system($beep_command) if ($beep eq "on");
    }
    return weechat::WEECHAT_RC_OK;
}
