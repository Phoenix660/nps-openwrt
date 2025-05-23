module("luci.controller.npc", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/npc") then
        return
    end

    -- 检查 UCI 配置中的 hidden 选项
    local uci = require "luci.model.uci".cursor()
    local hidden = uci:get("npc", "settings", "hidden") == "1"

    -- 如果未隐藏，则注册菜单项
    if not hidden then
        entry({"admin", "services", "npc"}, cbi("npc"), _("NPS Client"), 99).dependent = true
        entry({"admin", "services", "npc", "status"}, call("act_status")).leaf = true
    end
end

function act_status()
    local e = {}
    e.running = luci.sys.call("pgrep npc > /dev/null") == 0
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
