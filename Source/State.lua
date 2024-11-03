---@class ns
local ns = select(2, ...)

ns.def_safe_price = 1 * 100 * 100
local currentItemId = ns.StateManager:new()
currentItemId:setValue(-1)
ns.currentItemId = currentItemId
local tqb = ns.StateManager:new()
tqb:setValue(-1)
ns.tqb = tqb
local safe_price = ns.StateManager:new()
safe_price:setValue(ns.def_safe_price)
ns.safe_price = safe_price
ns.safe_table = ns.safe_table or {}
ns.util = {} or ns.util
ns.tqk = 1
ns.Trace = false -- module control
ns.debug = true
--TODO: Refine debug_table to function on module basis 
ns.debug_table = {
    debug = false,
    agg = false,
    results_frame = false,
    purchase_frame = false,
    price_handler = false,
    throttle_check = false,
    safe_frame = false,
}
ns.log_table = {
    results_frame = false,
    purchase_frame = false,
    purchase_helper = false,
    price_handler = false,
    throttle_check = false,
    safe_frame = false,
}

ns.tqk = 1 -- total quantity to kill execution at

