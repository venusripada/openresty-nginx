local cjson = require "cjson"
local redis = require "resty.redis"

local red = redis:new()
red:set_timeouts(1000, 1000, 1000)
local ok, err = red:connect("127.0.0.1", 6379)

ngx.req.read_body()
local inlinehook_req = ngx.req.get_body_data()

inlinehook_req_obj = cjson.decode(inlinehook_req)

ngx.log(ngx.ERR, "inlinehook_req_obj=" .. type(inlinehook_req_obj))

session_id = inlinehook_req_obj.data.context.session.id

ngx.log(ngx.ERR, "Session from hook=" .. session_id)

saml_attributes_json = red:get(session_id)

ngx.log(ngx.ERR, "Session from redis=" .. saml_attributes_json)

saml_attributes = cjson.decode(saml_attributes_json)

ngx.log(ngx.ERR, "Session from redis decoded=" .. cjson.encode(saml_attributes))

response_command = {
    commands = {}
}

for key, value in pairs(saml_attributes) do
    command = {
        type = "com.okta.identity.patch",
        value = {{
            op = "add",
            path = "/claims/saml-" .. key,
            value = value
        }}
    }
    ngx.log(ngx.ERR, "Inlinhook saml_attributes=" .. key .. ":" .. value)
    table.insert(response_command.commands, command)
    ngx.log(ngx.ERR, "response_commands" .. #response_command.commands)

end

ngx.log(ngx.ERR, "Inlinhook response=" .. cjson.encode(response_command))

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/json; charset=utf-8"
ngx.say(cjson.encode(response_command))
return ngx.exit(ngx.HTTP_OK)
