const std = @import("std");
const testing = std.testing;
const meta = std.meta;
const Allocator = std.mem.Allocator;

pub fn List(comptime T: type) type {
    return struct {
        const Node = struct {
            prev: ?*this,
            next: ?*this,
            data: *T,
            const this = @This();
            fn default(allocator: *Allocator) !*this {
                var data = try allocator.create(T);
                var node = try allocator.create(this);
                node.prev = null;
                node.next = null;
                node.data = data;
                std.log.warn("node data: {*}", .{node});
                return node;
            }
            fn find(self: *this, data: *const T) ?*this {
                std.log.info("called once", .{});
                if (self.data.* == data.*) return self;
                if (self.next == null) return null;
                return self.next.?.find(data);
            }
            // fn deinit(self: *this) void {
            //     allocator.destroy(self.data);
            // }
        };
        head: *Node,
        tail: *Node,
        len: u32,
        allocator: *Allocator,
        const Self = @This();
        fn init(allocator: *Allocator) !Self {
            return Self{
                .head = try Node.default(allocator),
                .tail = try Node.default(allocator),
                .allocator = allocator,
                .len = 0,
            };
        }
        fn deinit(self: *Self) void {
            // self.head.deinit();
            self.allocator.destroy(self.head);
            // self.tail.deinit();
            self.allocator.destroy(self.tail);
        }
        fn push_front(self: *Self, data: T) !void {
            if (self.len == 0) {
                self.head.data.* = data;
                self.tail.prev = self.head;
                self.head.next = self.tail;
            } else {
                var node = try Node.default(self.allocator);
                node.data.* = data;
                self.head.prev = node;
                node.next = self.head;
                self.head = node;
            }
            self.len += 1;
        }
        fn find(self: *Self, data: T) ?*Node {
            if (self.len == 0) return null;
            return self.head.find(&data);
        }
        fn insert_after(self: *Self, data: T, key: *Node) !void {
            var node = try Node.default(self.allocator);
            node.data.* = data;
            node.next = key.next;
            key.next = node;
            node.prev = key;
            self.len += 1;
        }
    };
}

test "List Constructor and destructor test" {
    var anera = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const Uint32List = List(u32);
    var list = try Uint32List.init(&anera.allocator);
    defer list.deinit();
}
test "push_front test" {
    var anera = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const Uint32List = List(u32);
    var list = try Uint32List.init(&anera.allocator);
    defer list.deinit();
    try list.push_front(1);
    try list.push_front(1);
    var a: u32 = 1;
    try std.testing.expect(list.find(a) != null);
}
