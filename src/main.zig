const std = @import("std");
const posix = std.posix;
const windows = std.os.windows;
const builtin = @import("builtin");
const debug = std.debug.print;
const Sha256 = std.crypto.hash.sha2.Sha256;

const utils = @import("utils.zig");
const file_format = @import("file_format.zig");
const input = @import("password_input.zig");

const MAX_MASTER_PASSWORD_LEN = 256;

pub fn main() !void {
    switch (builtin.os.tag) {
        .linux => {},
        .windows => {},
        else => {
            debug("{any} is currently not supported at the moment\n", .{builtin.os.tag});
            return;
        },
    }

    // TODO read file from args
    const filename = "test.zpass";
    const file = file_format.readFromFile(filename);
    debug("{any}\n", .{file});

    // get the master password from the user
    var buf: [MAX_MASTER_PASSWORD_LEN]u8 = undefined;
    utils.zeroize(buf[0..]); // TODO place this where it belongs

    // retry taking user input until a good password if found
    while (true) {
        if (try input.get_master_password(buf[0..])) |pass| {
            debug("You typed: {s}\nLength: {d}\n", .{ pass, pass.len });
            // TODO get password hash
        }
    }
}

test "read file" {
    _ = file_format;
}
