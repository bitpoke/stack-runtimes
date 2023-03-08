-- Copyright 2023 Bitpoke Soft SRL.
-- Copyright 2018 Pressinfra SRL.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local _M = { _VERSION = '0.1' }

local cors = {}

function _M.init()
    cors.allow_origins = (os.getenv("CORS_ALLOW_ORIGINS") or ""):gsub("%s+", ""):lower()
    cors.allow_paths = (os.getenv("CORS_ALLOW_PATHS") or "\\.(css|ttf|otf|eot|woff|woff2)$")

    cors.allow_methods = (os.getenv("CORS_ALLOW_METHODS") or "GET,POST,PUT,PATCH,DELETE,OPTIONS"):gsub("%s+", ""):upper()
    cors.allow_headers = (os.getenv("CORS_ALLOW_HEADERS") or "accept,accept-encoding,authorization,content-type,dnt,origin,user-agent,x-requested-with"):gsub("%s+", ""):lower()

    cors.allow_credentials = "true" == (os.getenv("CORS_ALLOW_CREDENTIALS") or "false"):lower()
    cors.preflight_max_age = tonumber(os.getenv("CORS_PREFLIGHT_MAX_AGE")) or 86400
    cors.expose_headers = (os.getenv("CORS_EXPOSE_HEADERS") or "")
end

function _M.set_headers()
    local req_method = ngx.req.get_method()
    local req_origin = (ngx.var.http_origin or ''):lower()
    local headers = ngx.header

    -- set only if CORS is enabled
    if '' == cors.allow_origins then
        return
    end

    -- do not override existing headers
    if '' ~= (ngx.var.upstrea_http_access_control_allow_origin or '') then
        return
    end

    -- restrict CORS to specific paths
    if '' ~= cors.allow_paths then
        local from, to, err = ngx.re.find(ngx.var.request_uri or '/', "^[^?]+", "jio")
        if err ~= nil then
            ngx.log(ngx.ERR, "failed to match request uri: ", err)
            return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        end
        local req_path = string.sub(ngx.var.request_uri, from or 1, to)

        if not ngx.re.find(req_path, cors.allow_paths, 'jio') then
            return
        end
    end

    if '*' == cors.allow_origins then
        headers["Access-Control-Allow-Origin"] = "*"
    else
        for origin in cors.allow_origins:gmatch("([^,]+)") do
            if origin == req_origin then
                headers["Access-Control-Allow-Origin"] = req_origin
                break
            end
        end
    end

    if cors.allow_credentials then
        headers["Access-Control-Allow-Credentials"] = "true"
    end

    if req_method == "OPTIONS" then
        headers["Access-Control-Allow-Methods"] = cors.allow_methods
        headers["Access-Control-Allow-Headers"] = cors.allow_headers
        headers["Access-Control-Max-Age"] = tostring(cors.preflight_max_age)

        headers['Content-Type'] = 'text/plain; charset=utf-8'
        headers['Content-Length'] = '0'
        return ngx.exit(ngx.HTTP_NO_CONTENT)
    elseif "" ~= cors.expose_headers then
        headers["Access-Control-Expose-Headers"] = cors.expose_headers
    end
end

return _M
