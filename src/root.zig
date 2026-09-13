const c = @import("sqlite3");

pub const Db = struct {
    handle: *c.sqlite3,

    pub fn openInMemory() !Db {
        var db: ?*c.sqlite3 = null;
        if (c.sqlite3_open(":memory:", &db) != c.SQLITE_OK) {
            return error.SqliteOpenFailed;
        }
        return .{ .handle = db.? };
    }

    pub fn close(self: *Db) void {
        _ = c.sqlite3_close(self.handle);
    }

    pub fn exec(self: *Db, sql: [*:0]const u8) !void {
        var err_msg: ?[*:0]u8 = null;
        if (c.sqlite3_exec(self.handle, sql, null, null, @ptrCast(&err_msg)) != c.SQLITE_OK) {
            if (err_msg) |msg| c.sqlite3_free(msg);
            return error.SqliteExecFailed;
        }
    }
};

test "sqlite open, create, insert, select" {
    var db = try Db.openInMemory();
    defer db.close();

    try db.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, val TEXT)");
    try db.exec("INSERT INTO test (val) VALUES ('hello')");

    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db.handle, "SELECT val FROM test", -1, &stmt, null) != c.SQLITE_OK) {
        return error.SqlitePrepareFailed;
    }
    defer _ = c.sqlite3_finalize(stmt);

    const std = @import("std");
    if (c.sqlite3_step(stmt) != c.SQLITE_ROW) {
        return error.SqliteNoRow;
    }
    const val = c.sqlite3_column_text(stmt, 0);
    try std.testing.expectEqualStrings("hello", std.mem.span(val));
}
