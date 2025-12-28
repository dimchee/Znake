const std = @import("std");
const sokol = @import("sokol");

const state = struct {
    var pass_action: sokol.gfx.PassAction = .{};
};

export fn init() void {
    sokol.gfx.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 1, .g = 1, .b = 0, .a = 1 },
    };
    std.debug.print("Backend: {}\n", .{sokol.gfx.queryBackend()});
}

export fn frame() void {
    const g = state.pass_action.colors[0].clear_value.g + 0.01;
    state.pass_action.colors[0].clear_value.g = if (g > 1.0) 0.0 else g;
    sokol.gfx.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sokol.gfx.endPass();
    sokol.gfx.commit();
}
export fn cleanup() void {
    sokol.gfx.shutdown();
}

pub fn main() !void {
    sokol.app.run(.{
        .frame_cb = frame,
        .init_cb = init,
        .cleanup_cb = cleanup,
        .window_title = "Znake",
    });
}
