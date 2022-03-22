local cjson = require "cjson"

local response_command = {
    commands = {{
        type = "com.okta.assertion.patch",
        value = {{
            op = "add",
            path = "/claims/hookRanTime",
            value = {
                attributes = {
                    NameFormat = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
                },
                attributeValues = {{
                    attributes = {
                        ["xsi:type"] = "xs:string"
                    },
                    value = os.date('%Y-%m-%d %H:%M:%S')
                }}
            }
        }}
    }}
}

ngx.status = ngx.HTTP_OK
ngx.header.content_type = "application/json; charset=utf-8"
ngx.say(cjson.encode(response_command))
return ngx.exit(ngx.HTTP_OK)
