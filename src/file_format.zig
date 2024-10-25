const Self = @This();

pub fn readFromFile(filename: []const u8) Self {
    _ = filename;
    return .{};
}

pub fn writeToFile(self: Self, filename: []const u8) !void {
    _ = self;
    _ = filename;
}
