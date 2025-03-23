const std = @import("std");
const sokol = @import("sokol");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
        // .wayland = true,
        // .x11 = false,
        // .egl = true,
        // .gl = true,
    });
    if (target.result.cpu.arch.isWasm()) {
        const snake = b.addStaticLibrary(.{
            .name = "Snake",
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
        });
        snake.root_module.addImport("sokol", dep_sokol.module("sokol"));

        // create a build step which invokes the Emscripten linker
        const emsdk = dep_sokol.builder.dependency("emsdk", .{});
        const link_step = try sokol.emLinkStep(b, .{
            .lib_main = snake,
            .target = target,
            .optimize = optimize,
            .emsdk = emsdk,
            .use_webgl2 = true,
            .use_emmalloc = true,
            .use_filesystem = false,
            .shell_file_path = dep_sokol.path("src/sokol/web/shell.html"),
        });
        // attach Emscripten linker output to default install step
        b.getInstallStep().dependOn(&link_step.step);
        // ...and a special run step to start the web build output via 'emrun'
        const run = sokol.emRunStep(b, .{ .name = "Snake", .emsdk = emsdk });
        run.step.dependOn(&link_step.step);
        b.step("run", "Run Snake").dependOn(&run.step);
    } else {
        const exe = b.addExecutable(.{
            .name = "Snake",
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
        });
        exe.root_module.addImport("sokol", dep_sokol.module("sokol"));
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}
