local hdr = "<BBHHB"

return function(sock)
    local dat = sock:read(hdr:packsize())
    local p = {}
    p.version, p.rtype, p.reqid, p.len, p.padlen = hdr:unpack(dat)
    p.data = sock:read(p.len)
    sock:read(p.padlen)
    return p
end