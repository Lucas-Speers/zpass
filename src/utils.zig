pub fn zeroize(buf: []u8) void {
    for (0..buf.len) |i| {
        buf[i] = 0;
    }
}
