module("luci.controller.npc", package.seeall)

-- 手动控制开关：true=显示菜单，false=隐藏菜单
local show_menu = false

function index()
    local fs = require "nixio.fs"

    -- 如果不开启，则直接返回，不注册菜单
    if not show_menu then
        return
    end

    -- 没有配置文件也不显示
    if not fs.access("/etc/config/npc") then
        return
    end

    -- 菜单入口
    entry({"admin", "services", "npc"}, cbi("npc"), _("NPS Client"), 99).dependent = true
    entry({"admin", "services", "npc", "status"}, call("act_status")).leaf = true
end

function act_status()
    local fs = require "nixio.fs"
    local e  = {}

    if not fs.access("/usr/bin/npc") then
        e.installed    = false
        e.running      = false
        e.version      = ""
        e.core_version = ""
    else
        e.installed    = true
        e.running      = (luci.sys.call("pgrep npc > /dev/null") == 0)
        local ver_out  = luci.sys.exec("/usr/bin/npc -version 2>/dev/null")
        e.version      = ver_out:match("Version:%s*([v%d%.%-]+)")      or ""
        e.core_version = ver_out:match("Core version:%s*([v%d%.%-]+)") or ""
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
