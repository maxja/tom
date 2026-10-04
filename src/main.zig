const std = @import("std");

fn handleConnection(io: std.Io, stream: std.Io.net.Stream) !void {
    defer stream.close(io);

    var read_buf: [4096]u8 = undefined;
    var write_buf: [4096]u8 = undefined;

    var net_reader = stream.reader(io, &read_buf);
    var net_writer = stream.writer(io, &write_buf);
    var http_server = std.http.Server.init(&net_reader.interface, &net_writer.interface);

    while (true) {
        std.debug.print("serve {any}\n", .{stream});

        var request = http_server.receiveHead() catch break;
        const keep_alive = request.head.keep_alive;

        if (std.mem.eql(u8, request.head.target, "/health")) {
            try request.respond("OK", .{
                .status = .ok,
                .extra_headers = &.{
                    .{ .name = "content-type", .value = "text/plain" },
                },
            });
        } else {
            try request.respond(
                "{\"error\":\"not_found\",\"message\":\"Endpoint not found\"}",
                .{
                    .status = .not_found,
                    .extra_headers = &.{
                        .{ .name = "content-type", .value = "application/json" },
                    },
                },
            );
        }

        if (!keep_alive) break;
    }
}

pub fn main(init: std.process.Init) !void {
    var args = init.minimal.args.iterate();
    _ = args.next();

    const ip = args.next() orelse "127.0.0.1";
    const port = args.next() orelse "8080";

    const port_num = std.fmt.parseInt(u16, port, 10) catch {
        std.debug.print("invalid port, must be a number: {s}\n", .{port});
        return error.InvalidPort;
    };
    const addr = std.Io.net.IpAddress.parse(ip, port_num) catch {
        std.debug.print("invalid ip: {s}\n", .{ip});
        return error.InvalidIp;
    };

    var server = try std.Io.net.IpAddress.listen(&addr, init.io, .{ .reuse_address = true });
    defer server.deinit(init.io);

    std.debug.print("tom is serving on {s}:{d}\n", .{ ip, port_num });

    while (true) {
        const stream = server.accept(init.io) catch |err| {
            std.debug.print("accept error: {s}\n", .{@errorName(err)});
            continue;
        };
        std.Thread.spawn(.{}, handleConnection, .{ init.io, stream }) catch |err| {
            std.debug.print("spawn error: {s}\n", .{@errorName(err)});
            stream.close(init.io);
        };
    }
}
