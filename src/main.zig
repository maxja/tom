const std = @import("std");
const tom = @import("tom");

pub fn main() !void {
    var db = try tom.Db.openInMemory();
    defer db.close();
    std.debug.print("sqlite ok\n", .{});
}
