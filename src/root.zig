const std = @import("std");
const testing = std.testing;
const rbt = @import("rbt");

const MemInfo = struct {
    ptr: *anyopaque,
    s: usize,
    id: isize,
};

fn cmpMemInfo(a: MemInfo, b: MemInfo) std.math.Order {
    return std.math.order(@as(usize, @intFromPtr(a.ptr)), @as(usize, @intFromPtr(b.ptr)));
}

const RBT = rbt.ArrayRedBlackTree(rbt.RedBlackTreeUnmanaged(MemInfo, cmpMemInfo));
const A = std.ArrayList(MemInfo);

pub var memoryTree : RBT = RBT.init(std.heap.c_allocator);
pub var idx : isize = 0;
pub var drops : A = A.init(std.heap.c_allocator);

export fn mymalloc(size: usize) callconv(.C) ?*anyopaque {
    const rst = std.c.malloc(size);
    if (rst) |a| {
        const m = MemInfo { .ptr = a, .s = size, .id = idx };
        idx += 1;
        const b = memoryTree.append(m) catch @panic("OOM");
        if (!b) { @panic("IMA"); }
    }
    // std.debug.print("M{}\n", .{ size });
    return rst;
}

export fn myfree(ptr: ?*anyopaque) callconv(.C) void {
    // std.debug.print("F\n", .{});
    if (ptr == null) {
        return; 
    }
    var m : MemInfo = undefined;
    m.ptr = ptr.?;
    const n = memoryTree.inner_tree.getEntryFor(m);
    if (n.node == null) { @panic("IMF"); }
    m = n.node.?.*.key; 
    drops.append(m) catch @panic("OOM2");
    if (!memoryTree.remove(m)) { @panic("MTN"); }
    std.c.free(ptr);
}

export fn collect(fd: c_int) callconv(.C) void {
    collectImpl(fd) catch @panic("E");
}

fn collectImpl(fd: c_int) !void {
    const f = std.fs.File { .handle = fd };
    const w = f.writer();
    var bw = std.io.bufferedWriter(w);
    const wr = bw.writer();
    if (memoryTree.items.len != 0) {
        try wr.print("L M {}\n", .{ memoryTree.items.len });
    }
    // size &id actual-ptr
    for (drops.items) |i| {
        try wr.print("{} &{} 0x{x}\n", .{ i.s, i.id, @intFromPtr(i.ptr) });
    }
    try bw.flush();
}