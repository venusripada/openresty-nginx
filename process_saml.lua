local b64 = require("ngx.base64")
-- local SLAXML = require 'slaxml'
local SLAXML = require 'slaxdom'
local cjson = require "cjson"

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
-- if not args then
--     ngx.say("failed to get post args: ", err)
--     return
-- end
for key, val in pairs(args) do
    if key == "SAMLResponse" then
        res, err = ngx.decode_base64(val)
        -- ngx.say(key, ": ", val)
        local doc = SLAXML:dom(res)  
        assertion = doc.root.kids[4]
        attributes = assertion.kids[6].kids
        attribute_table = {}
        for i,attribute in ipairs(attributes) do 
            name = attribute.attr['Name']
            value = attribute.kids[1].kids[1].value
            attribute_table[name] = value
            ngx.log(ngx.ERR,"SAML attributes=" .. name .. ":" .. value)
        end
        ngx.ctx.attribute_table = attribute_table
        -- if not res then
        --     ngx.say("failed to set myhash: ", err)
        --     return
        -- end
    end
end