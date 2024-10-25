const std = @import("std");
const posix = std.posix;
const builtin = @import("builtin");
const debug = std.debug.print;
const Sha256 = std.crypto.hash.sha2.Sha256;

const utils = @import("utils.zig");
const file_format = @import("file_format.zig");

const MAX_MASTER_PASSWORD_LEN = 256;

pub fn main() !void {
    switch (builtin.os.tag) {
        .linux => {},
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
        if (try get_master_password(buf[0..])) |pass| {
            _ = pass;
            // TODO get password hash
        }
    }
}

fn get_master_password(buf: []u8) !?[]u8 {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("Enter your master password: ", .{});

    switch (builtin.os.tag) {
        .linux => {
            return try linux_input(buf[0..]);
        },
        else => {
            unreachable;
        },
    }
}

fn linux_input(buf: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    // get and remember terminal state
    var attrs = try posix.tcgetattr(0);
    const original_attrs = attrs;

    // set the terminal to not echo input
    attrs.lflag.ECHO = false;
    attrs.lflag.ICANON = false;
    try posix.tcsetattr(0, .NOW, attrs);

    // read user input
    const input = try stdin.readUntilDelimiterOrEof(buf[0..], '\n');

    // restore the state of the terminal
    try posix.tcsetattr(0, .NOW, original_attrs);

    // the enter is not echoed when they finish typing
    try stdout.print("\n", .{});

    return input;
}
