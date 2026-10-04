const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var args = init.minimal.args.iterate();

    _ = args.next();
    const ip = args.next() orelse "127.0.0.1";
    const port = args.next() orelse "8080";

    const port_num = std.fmt.parseInt(u16, port, 10) catch {
        std.debug.print("invalid port, must be a number: {s}\n", .{port});
        return error.InvalidPort;
    };

    std.debug.print("tom is serving on {s}:{d}\n", .{ ip, port_num });
}
