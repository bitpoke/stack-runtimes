-- Copyright 2023 Bitpoke Soft SRL.
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

function _M.setup()
    local headers = ngx.header
    local ext_regex = [=[(?<=.\.)(((tar)\.)?[^.]+)$]=];
    local ext_mime_types = {
        -- web
        ["html"] = "text/html",
        ["htm"] = "text/html",
        ["shtml"] = "text/html",
        ["css"] = "text/css",
        ["xml"] = "text/xml",
        ["gif"] = "image/gif",
        ["jpeg"] = "image/jpeg",
        ["jpg"] = "image/jpeg",
        ["js"] = "application/javascript",
        ["atom"] = "application/atom+xml",
        ["rss"] = "application/rss+xml",
        -- text
        ["mml"] = "text/mathml",
        ["txt"] = "text/plain",
        ["jad"] = "text/vnd.sun.j2me.app-descriptor",
        ["wml"] = "text/vnd.wap.wml",
        ["htc"] = "text/x-component",
        -- images
        ["png"] = "image/png",
        ["svg"] = "image/svg+xml",
        ["svgz"] = "image/svg+xml",
        ["tif"] = "image/tiff",
        ["tiff"] = "image/tiff",
        ["wbmp"] = "image/vnd.wap.wbmp",
        ["webp"] = "image/webp",
        ["ico"] = "image/x-icon",
        ["jng"] = "image/x-jng",
        ["bmp"] = "image/x-ms-bmp",
        -- fonts
        ["ttf"] = "application/x-font-ttf",
        ["ttc"] = "application/x-font-ttf",
        ["otf"] = "application/x-font-otf",
        ["woff"] = "application/font-woff",
        ["woff2"] = "application/font-woff2",
        ["eot"] = "application/vnd.ms-fontobject",
        -- misc
        ["jar"] = "application/java-archive",
        ["war"] = "application/java-archive",
        ["ear"] = "application/java-archive",
        ["json"] = "application/json",
        ["hqx"] = "application/mac-binhex40",
        ["doc"] = "application/msword",
        ["pdf"] = "application/pdf",
        ["ps"] = "application/postscript",
        ["eps"] = "application/postscript",
        ["ai"] = "application/postscript",
        ["rtf"] = "application/rtf",
        ["m3u8"] = "application/vnd.apple.mpegurl",
        ["kml"] = "application/vnd.google-earth.kml+xml",
        ["kmz"] = "application/vnd.google-earth.kmz",
        ["xls"] = "application/vnd.ms-excel",
        ["ppt"] = "application/vnd.ms-powerpoint",
        ["odg"] = "application/vnd.oasis.opendocument.graphics",
        ["odp"] = "application/vnd.oasis.opendocument.presentation",
        ["ods"] = "application/vnd.oasis.opendocument.spreadsheet",
        ["odt"] = "application/vnd.oasis.opendocument.text",
        ["wmlc"] = "application/vnd.wap.wmlc",
        ["7z"] = "application/x-7z-compressed",
        ["cco"] = "application/x-cocoa",
        ["jardiff"] = "application/x-java-archive-diff",
        ["jnlp"] = "application/x-java-jnlp-file",
        ["run"] = "application/x-makeself",
        ["pl"] = "application/x-perl",
        ["pm"] = "application/x-perl",
        ["prc"] = "application/x-pilot",
        ["pdb"] = "application/x-pilot",
        ["rar"] = "application/x-rar-compressed",
        ["rpm"] = "application/x-redhat-package-manager",
        ["sea"] = "application/x-sea",
        ["swf"] = "application/x-shockwave-flash",
        ["sit"] = "application/x-stuffit",
        ["tcl"] = "application/x-tcl",
        ["tk"] = "application/x-tcl",
        ["der"] = "application/x-x509-ca-cert",
        ["pem"] = "application/x-x509-ca-cert",
        ["crt"] = "application/x-x509-ca-cert",
        ["xpi"] = "application/x-xpinstall",
        ["xhtml"] = "application/xhtml+xml",
        ["xspf"] = "application/xspf+xml",
        ["zip"] = "application/zip",
        -- binary
        ["bin"] = "application/octet-stream",
        ["exe"] = "application/octet-stream",
        ["dll"] = "application/octet-stream",
        ["deb"] = "application/octet-stream",
        ["dmg"] = "application/octet-stream",
        ["iso"] = "application/octet-stream",
        ["img"] = "application/octet-stream",
        ["msi"] = "application/octet-stream",
        ["msp"] = "application/octet-stream",
        ["msm"] = "application/octet-stream",
        -- audio
        ["mid"] = "audio/midi",
        ["midi"] = "audio/midi",
        ["kar"] = "audio/midi",
        ["mp3"] = "audio/mpeg",
        ["ogg"] = "audio/ogg",
        ["m4a"] = "audio/x-m4a",
        ["ra"] = "audio/x-realaudio",
        -- video
        ["3gpp"] = "video/3gpp",
        ["3gp"] = "video/3gpp",
        ["ts"] = "video/mp2t",
        ["mp4"] = "video/mp4",
        ["mpeg"] = "video/mpeg",
        ["mpg"] = "video/mpeg",
        ["mov"] = "video/quicktime",
        ["webm"] = "video/webm",
        ["flv"] = "video/x-flv",
        ["m4v"] = "video/x-m4v",
        ["mng"] = "video/x-mng",
        ["asx"] = "video/x-ms-asf",
        ["asf"] = "video/x-ms-asf",
        ["wmv"] = "video/x-ms-wmv",
        ["avi"] = "video/x-msvideo"
    }

    if headers['Content-Type'] == "application/octet-stream" then
        local m = ngx.re.match(ngx.var.uri, ext_regex, "iUo")
        if m then
            headers['Content-Type'] = ext_mime_types[m[0]] or "application/octet-stream"
        end
    end

    ngx.header = headers
end

return _M
