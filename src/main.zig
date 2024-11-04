const std = @import("std");
const posix = std.posix;
const windows = std.os.windows;
const builtin = @import("builtin");
const debug = std.debug.print;
const Sha256 = std.crypto.hash.sha2.Sha256;
const aes = std.crypto.aead.aes_gcm.Aes256Gcm;

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
            var sha_output: [32]u8 = undefined;
            Sha256.hash(pass, &sha_output, .{});
            const hex = std.fmt.bytesToHex(sha_output, .upper);
            debug("Hash: {s}\n", .{hex});

            const in = [_]u8{ 0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34 };
            var enc: []u8 = undefined;
            aes.initEnc(sha_output).encrypt(enc[0..], in[0..]);
            debug("encrypted data: {}\n", enc);
            // TODO get password hash
        }
    }
}
