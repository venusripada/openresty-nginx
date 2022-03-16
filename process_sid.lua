function starts_with(str, start)
    return str:sub(1, #start) == start
 end

function SplitSid(s)
    delimiter = "="
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result[2];
end

function get_sid_header(headers)
    for k, v in pairs(headers) do
        if k == "set-cookie" and type(v) == "table" then
            for k, v in pairs(v) do
                ngx.log(ngx.ERR, "SET COOCKIE:" ..k .. v)
                if starts_with(v, "sid") then
                    return v
                end
            end
        end
    end
    return nil
end


function fetch_session_and_save(premature,sid, attributes)
    local redis = require "resty.redis"
    local httpc = require("resty.http").new()
    local cjson = require "cjson"
   
    local red = redis:new()
    red:set_timeouts(1000, 1000, 1000)
    local ok, err = red:connect("127.0.0.1", 6379)
    
    ngx.log(ngx.ERR, "Inside  fetch_session_and_save ", sid)
    -- Single-shot requests use the `request_uri` interface.
    local res, err = httpc:request_uri("https://dev-02783336.okta.com/api/v1/sessions/me", {
        method = "GET",
        -- body = "a=1&b=2",
        headers = {
            ["Cookie"] = "sid=" .. sid,
        },
    })
    if not res then
        ngx.log(ngx.ERR, "request failed: ", err)
        return
    end

    local session_response  = res.body

    session_res_table = cjson.decode(session_response)
    ngx.log(ngx.ERR, "Session ID: ", session_res_table["id"])
    res, err = red:set(session_res_table["id"],  cjson.encode(attribute_table))

    ngx.log(ngx.ERR,"session response: ", session_response)
end


local headers, err = ngx.resp.get_headers()
saml_attributes =  ngx.ctx.attribute_table
sid_header = get_sid_header(headers)
ngx.log(ngx.ERR, "SID HEADER: ", sid_header)
if not sid_header then 
    return
end 
sid = SplitSid(sid_header)
ngx.log(ngx.ERR,"SID: " .. sid)
local ok, err = ngx.timer.at(0,fetch_session_and_save,sid, saml_attributes)
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
    return
end

