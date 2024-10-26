---@class ns
local ns = select(2, ...)

ns.def_safe_price = 1*100*100
ns.currentItemId = nil
ns.safe_table = ns.safe_table or {}
ns.util = {}
ns.debug = true
ns.MBComBuyFrame = nil
ns.price_monitor = {}
ns.tqb = 0 -- total quantity buyable
ns.prev_quantity = 0
ns.tqk = 1 -- total quantity to kill execution at