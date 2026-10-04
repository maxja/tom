const std = @import("std");

pub const Http = struct {
    ip: std.Io.net.IpAddress,
    port: u16,

    pub fn init(ip: std.Io.net.IpAddress, port: u16) Http {
        return .{
            .ip = ip,
            .port = port,
        };
    }
};
