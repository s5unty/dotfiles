----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--  * Derived from Wicked, copyright of Lucas de Vries
----------------------------------------------------------
--
-- {{{ Grab environment
local tonumber = tonumber
local os = { time = os.time }
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
-- }}}


-- Net: provides usage statistics for all network interfaces
module("vicious.netglob")
