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
local cjson = require "cjson"
local jwt = require "resty.jwt"

local OAUTH2_INTERNAL_TOKEN_ENDPOINT = "/.internal/google-cloud/oauth2/v4/token"
local MEDATADA_INTERNAL_ENDPOINT = "/.internal/google-cloud/metadata/computeMetadata"
local METADATA_INTERNAL_TOKEN_ENDPOINT = MEDATADA_INTERNAL_ENDPOINT .. "/v1/instance/service-accounts/default/token"

local function get_metadata_token()
    ngx.log(ngx.INFO, "Fetching a new access_token from metadata server")

    local ctx = {}

    local res = ngx.location.capture(METADATA_INTERNAL_TOKEN_ENDPOINT, {
        method = ngx.HTTP_GET,
        ctx = ctx
    })

    if res.status ~= 200 then
        return nil, "Failed getting access token. " .. (res.body or "")
    else
        local token = cjson.decode(res.body)
        local cache_ttl = math.floor(tonumber(token['expires_in'] or "30") / 3)
        -- this should not happen, but if our token expires in less than 30 seconds,
        -- we cache it for 10 seconds regardless
        -- NOTE: cache_ttl = 0 means cache forever
        if 10 >= cache_ttl then
            cache_ttl = 10
        end
        return token['access_token'], nil, cache_ttl
    end
end

local function get_oauth2_token()
    ngx.log(ngx.INFO, "Fetching a new google ouath2 access_token")
    local key = google_credentials['private_key']
    local jwt_obj = {
        header = {
            alg = "RS256",
            typ = "JWT"
        },
        payload = {
            iss = google_credentials['client_email'],
            scope = "https://www.googleapis.com/auth/devstorage.read_only",
            aud = "https://www.googleapis.com/oauth2/v4/token",
            exp = ngx.time() + 3600,
            iat = ngx.time()
        }
    }

    local jwt_assertion = jwt:sign(key, jwt_obj)
    local ctx = {}
    local req_body = ngx.encode_args({
        grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion = jwt_assertion
    })

    local res = ngx.location.capture(OAUTH2_INTERNAL_TOKEN_ENDPOINT, {
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

local function get_access_token()
    if google_credentials ~= nil then
        return get_oauth2_token()
    else
        return get_metadata_token()
    end
end

function _M.setup()
    local mlcache = require "resty.mlcache"

    local cache, err = mlcache.new("gcs_access_tokens", "cache_dict", {
        lru_size = 10, -- size of the L1 (Lua VM) cache
        ttl      = 300, -- 1h ttl for hits
    })
    if err == nil then
        ngx.log(ngx.ERR, "Failed setting up cache: ", err)
        return
    end

    ---@diagnostic disable-next-line: redefined-local
    local token, err = cache:get("gcs_access_token", nil, get_access_token)
    if err then
        ngx.log(ngx.ERR, "Failed fetching access token:", err)
        return
    end

    ngx.var.gcs_access_token = token
end

function _M.init()
    local google_credentials = nil
    if "" ~= (os.getenv("GOOGLE_CREDENTIALS") or "") then
        google_credentials = cjson.decode(os.getenv("GOOGLE_CREDENTIALS") or "")
    else
        local well_known_gac_file = ((os.getenv("HOME") or "/var/www") .. "/.config/gcloud/google_application_credentials.json")
        local gac_file = os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or well_known_gac_file
        local f, err = io.open(gac_file, "rb")
        if err and gac_file ~= well_known_gac_file then
            ngx.log(ngx.WARN, "Could not configure Google Application Credentials: ", err)
        elseif not err and f ~= nil then
            google_credentials = cjson.decode(f:read("*all"))
            f:close()
        end
    end
    return google_credentials
end

return _M
