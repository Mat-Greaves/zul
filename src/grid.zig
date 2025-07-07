const std = @import("std");

pub const Direction = enum {
    up,
    down,
    left,
    right,
};

const Point = struct {
    x: u32,
    y: u32,
};

pub const Grid = struct {
    /// source is a string representing a MxN dimentioned grid
    /// with rows separated by \n.
    ///
    /// Newline characters are not treated as part of the grid when
    /// iterating and retrieving values.
    source: []u8,
    width: u32,
    height: u32,

    pub fn init(source: []u8) Grid {
        const width: u32 = @intCast(std.mem.indexOf(u8, source, "\n").?);
        return .{
            .source = source,
            .width = width,
            .height = @as(u32, @intCast(source.len)) / width,
        };
    }

    /// item returns the element located at p within g.
    pub fn item(g: Grid, p: Point) ?u8 {
        const elem = (p.y * (g.width + 1)) + p.x;
        if (elem > g.source.len - 1) {
            return null;
        }
        return g.source[elem];
    }

    /// set sets v a point p within g. Returning the previous value that was there.
    pub fn set(g: Grid, p: Point, v: u8) ?u8 {
        const elem = (p.y * (g.width + 1)) + p.x;
        if (elem > g.source.len - 1) {
            return null;
        }
        const was = g.source[elem];
        g.source[elem] = v;
        return was;
    }

    /// up returns the position one above the current point within the grid.
    pub fn up(_: Grid, curr: Point) ?Point {
        if (curr.y == 0) {
            return null;
        }
        return .{ .x = curr.x, .y = curr.y - 1 };
    }

    /// down returns the position one below the current point within the grid.
    pub fn down(g: Grid, curr: Point) ?Point {
        if (curr.y == g.height - 1) {
            return null;
        }
        return .{ .x = curr.x, .y = curr.y + 1 };
    }

    /// left returns the position one to the left of the current point within the grid.
    pub fn left(_: Grid, curr: Point) ?Point {
        if (curr.x == 0) {
            return null;
        }
        return .{ .x = curr.x - 1, .y = curr.y };
    }

    /// right returns the position one to the right of the current point within the grid.
    pub fn right(g: Grid, curr: Point) ?Point {
        if (curr.x == g.width - 1) {
            return null;
        }
        return .{ .x = curr.x + 1, .y = curr.y };
    }

    /// next return the next Point travelling in direction d within g
    /// returning null if that point is outside g.
    pub fn next(g: Grid, curr: Point, d: Direction) ?Point {
        return switch (d) {
            .up => g.up(curr),
            .down => g.down(curr),
            .left => g.left(curr),
            .right => g.right(curr),
        };
    }

    // pointOf returns the firt Point of c within g or null if it cannot be found.
    pub fn pointOf(g: Grid, c: u8) ?Point {
        const i: u32 = @intCast(std.mem.indexOf(u8, g.source, &.{c}) orelse return null);
        return .{
            .x = i % (g.width + 1),
            .y = i / (g.width + 1),
        };
    }
};

test "init" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(5, g.width);
    try std.testing.expectEqual(4, g.height);
}

test "item" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual('a', g.item(.{ .x = 0, .y = 0 }));
    try std.testing.expectEqual('e', g.item(.{ .x = 4, .y = 0 }));
    try std.testing.expectEqual('t', g.item(.{ .x = 4, .y = 3 }));
    try std.testing.expectEqual(null, g.item(.{ .x = 5, .y = 3 }));
    try std.testing.expectEqual(null, g.item(.{ .x = 0, .y = 4 }));
}

test "up" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 0 }), g.up(.{ .x = 0, .y = 1 }));
    try std.testing.expectEqual(null, g.up(.{ .x = 0, .y = 0 }));
}

test "down" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 1 }), g.down(.{ .x = 0, .y = 0 }));
    try std.testing.expectEqual(null, g.down(.{ .x = 0, .y = 3 }));
}

test "left" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 0 }), g.left(.{ .x = 1, .y = 0 }));
    try std.testing.expectEqual(null, g.left(.{ .x = 0, .y = 0 }));
}

test "right" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(@as(Point, .{ .x = 4, .y = 0 }), g.right(.{ .x = 3, .y = 0 }));
    try std.testing.expectEqual(null, g.right(.{ .x = 4, .y = 0 }));
}

test "next" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 0 }), g.next(.{ .x = 0, .y = 1 }, .up));
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 1 }), g.next(.{ .x = 0, .y = 0 }, .down));
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 0 }), g.next(.{ .x = 1, .y = 0 }, .left));
    try std.testing.expectEqual(@as(Point, .{ .x = 1, .y = 0 }), g.next(.{ .x = 0, .y = 0 }, .right));
}

test "pointOf" {
    var grid =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
    .*;
    const g = Grid.init(&grid);
    try std.testing.expectEqual(@as(Point, .{ .x = 0, .y = 0 }), g.pointOf('a'));
    try std.testing.expectEqual(@as(Point, .{ .x = 2, .y = 1 }), g.pointOf('h'));
    try std.testing.expectEqual(@as(Point, .{ .x = 4, .y = 3 }), g.pointOf('t'));
}
