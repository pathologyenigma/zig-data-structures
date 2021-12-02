const std = @import("std");
const testing = std.testing;
const meta = std.meta;
const Allocator = std.mem.Allocator;

pub fn List(comptime T: type, allocator: *Allocator) type {
    return struct {
        const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: *T,
            const this = @This();
            fn default() !*Node {
                var node = try allocator.create(Node);
                node.data = try allocator.create(T);
                node.prev = null;
                node.next = null;
                return node;
            }
            fn find(self: *this, data: *const T) bool {
                std.log.info("called once", .{});
                if (self.data.* == data.*) return true;
                if (self.next == null) return false;
                return self.next.?.find(data);
            }
            fn deinit(self: *this) void {
                allocator.destroy(self.data);
            }
        };
        head: *Node,
        tail: *Node,
        len: u32,
        allocator: *Allocator,
        const Self = @This();
        fn init() !Self {
            return Self{
                .head = try Node.default(),
                .tail = try Node.default(),
                .allocator = allocator,
                .len = 0,
            };
        }
        fn deinit(self: *Self) void {
            self.head.deinit();
            self.allocator.destroy(self.head);
            self.tail.deinit();
            self.allocator.destroy(self.tail);
        }
        fn push_front(self: *Self, data: T) !void {
            if (self.len == 0) {
                self.head.data.* = data;
                self.tail.prev = self.head;
                self.head.next = self.tail;
            } else {
                var node = try Node.default();
                node.data.* = data;
                self.head.prev = node;
                node.next = self.head;
                self.head = node;
            }
            self.len += 1;
        }
        fn find(self: *Self, data: *const T) bool {
            if (self.len == 0) return false;
            return self.head.find(data);
        }
        // fn insert_at(self: *Self, data: *T, ) !void{

        // }
    };
}

test "List Constructor and destructor test" {
    const Uint32List = List(u32, std.testing.allocator);
    var list = try Uint32List.init();
    defer list.deinit();
}
test "push_front test" {
    const Uint32List = List(u32, std.testing.allocator);
    var list = try Uint32List.init();
    defer list.deinit();
    try list.push_front(1);
    var a: u32 = 1;
    try std.testing.expect(list.find(&a));
}
