const std = @import("std");

pub const Http = struct {
    port: u16,

    pub fn open(port: u16) Http {
        return .{ .port = port };
    }

    pub fn run(self: Http, io: std.Io) !void {
        const address = std.Io.net.IpAddress{
            .ip4 = std.Io.net.Ip4Address.unspecified(self.port),
        };
        var server = try std.Io.net.IpAddress.listen(&address, io, .{ .reuse_address = true });
        defer server.deinit(io);

        std.debug.print("Listening on 0.0.0.0:{d}\n", .{self.port});

        while (true) {
            const stream = server.accept(io) catch |err| {
                std.debug.print("Accept error: {s}\n", .{@errorName(err)});
                continue;
            };
            handleConnection(io, stream) catch |err| {
                std.debug.print("Connection error: {s}\n", .{@errorName(err)});
            };
        }
    }
};

fn handleConnection(io: std.Io, stream: std.Io.net.Stream) !void {
    defer stream.close(io);

    var read_buf: [4096]u8 = undefined;
    var write_buf: [4096]u8 = undefined;

    var net_reader = stream.reader(io, &read_buf);
    var net_writer = stream.writer(io, &write_buf);
    var http_server = std.http.Server.init(&net_reader.interface, &net_writer.interface);

    while (true) {
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

test "Http.open stores port" {
    const server = Http.open(8080);
    try std.testing.expectEqual(@as(u16, 8080), server.port);
}
