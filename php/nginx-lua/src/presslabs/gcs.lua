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
local cjson = require "cjson"
local jwt = require "resty.jwt"

local function get_access_token()
    ngx.log(ngx.INFO, "Fetching a new access_token for GCS")
    local key = google_credentials['private_key']
    local jwt_obj = {
        header={
            alg="RS256",
            typ="JWT"
        },
        payload={
            iss=google_credentials['client_email'],
            scope="https://www.googleapis.com/auth/devstorage.read_only",
            aud="https://www.googleapis.com/oauth2/v4/token",
            exp=ngx.time() + 3600,
            iat=ngx.time()
        }
    }

    local jwt_assertion = jwt:sign(key, jwt_obj)
    local ctx = {}
    local req_body = ngx.encode_args({
        grant_type="urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion=jwt_assertion
    })

    local res = ngx.location.capture("/.token", {
        method = ngx.HTTP_POST,
        body = req_body,
        ctx = ctx
    })

    if res.status ~= 200 then
        return nil, "Failed getting access token. " .. (res.body or "")
    else
        local token = cjson.decode(res.body)
        return token['access_token']
    end
end

function _M.setup()
    local key_file = key_file or ''
    local mlcache = require "resty.mlcache"

    local cache, err = mlcache.new("gcs_access_tokens", "cache_dict", {
        lru_size = 10,    -- size of the L1 (Lua VM) cache
        ttl      = 300,   -- 1h ttl for hits
    })
    if err then
        ngx.log(ngx.ERR, "Failed setting up cache: ", err)
        return
    end

    local token, err = cache:get("gcs_access_token", nil, get_access_token)
    if err then
        ngx.log(ngx.ERR, "Failed fetching access token:", err)
        return
    end

    ngx.var.gcs_access_token = token
end

return _M
