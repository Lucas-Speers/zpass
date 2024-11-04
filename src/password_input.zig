const std = @import("std");
const posix = std.posix;
const windows = std.os.windows;
const builtin = @import("builtin");

pub fn get_master_password(buf: []u8) !?[]u8 {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("Enter your master password: ", .{});

    switch (builtin.os.tag) {
        .linux => {
            return try linux_input(buf[0..]);
        },
        .windows => {
            return try windows_input(buf[0..]);
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

fn windows_input(buf: []u8) !?[]u8 {
    const stdin_handle = try windows.GetStdHandle(windows.STD_INPUT_HANDLE);
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var mode: u32 = 0;
    if (windows.kernel32.GetConsoleMode(stdin_handle, &mode) == 0) {
        return error.ConsoleModeFailure;
    }

    const flags: u32 = 0x4 | 0x6;
    const new_mode: u32 = mode & ~flags;
    if (windows.kernel32.SetConsoleMode(stdin_handle, new_mode) == 0) {
        return error.ConsoleModeFailure;
    }

    const input = try stdin.readUntilDelimiterOrEof(buf[0..], '\r');

    if (windows.kernel32.SetConsoleMode(stdin_handle, mode) == 0) {
        return error.ConsoleModeFailure;
    }

    try stdout.print("\n", .{});

    return input;
}
