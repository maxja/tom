const std = @import("std");
const tom = @import("tom");
const Http = @import("http.zig").Http;

pub fn main(init: std.process.Init) !void {
    // Init database
    var db = try tom.Db.openInMemory();
    defer db.close();
    std.debug.print("sqlite ok\n", .{});

    // Init server
    var port: u16 = 9000;
    var args = init.minimal.args.iterate();
    _ = args.skip(); // skip argv[0] (program name)
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--port")) {
            if (args.next()) |port_str| {
                port = std.fmt.parseInt(u16, port_str, 10) catch blk: {
                    std.debug.print("Warning: invalid port '{s}', using {d}\n", .{ port_str, port });
                    break :blk port;
                };
            }
        }
    }

    std.debug.print("Starting server on port {d}...\n", .{port});

    const server = Http.open(port);
    try server.run(init.io);
}
