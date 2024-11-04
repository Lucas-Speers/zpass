const std = @import("std");
const Self = @This();

pub fn readFromFile(filename: []const u8, alloc: std.mem.Allocator) !Self {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const size_limit = std.math.maxInt(u32);
    const file_data = try file.readToEndAlloc(alloc, size_limit);
    std.debug.print("{s}", .{file_data});

    return .{};
}

pub fn writeToFile(self: Self, filename: []const u8) !void {
    _ = self;
    _ = filename;
}

test "read file" {
    _ = try readFromFile("test.txt", std.testing.allocator);
}
