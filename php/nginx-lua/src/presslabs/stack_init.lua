-- Copyright 2019 Pressinfra SRL.
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

function _M.get_google_credentials()
    local google_credentials = nil
    if "" ~= (os.getenv("GOOGLE_CREDENTIALS") or "") then
        google_credentials = cjson.decode(os.getenv("GOOGLE_CREDENTIALS"))
    else
        local well_known_gac_file = ((os.getenv("HOME") or "/var/www") .. "/.config/gcloud/google_application_credentials.json")
        local gac_file = os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or well_known_gac_file
        local f, err = io.open(gac_file, "rb")
        if err then
            ngx.log(ngx.WARN, "Could not configure Google Application Credentials: ", err)
        else
            google_credentials = cjson.decode(f:read("*all"))
            f:close()
        end
    end
    return google_credentials
end

return _M
