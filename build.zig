const std = @import("std");
const print = @import("std").debug.print;
const builtin = @import("builtin");
const tgt = @import("builtin").target;



pub fn build(b: *std.build.Builder) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const want_assert = b.option(bool, "want_assert", "Enable asserts") orelse false;
    const want_redzones = b.option(bool, "want_redzones", "Enable redzones") orelse true;

    const platform_byte_order: u16 = if (target.getCpuArch().endian() == std.builtin.Endian.Little) 0x10 else 0x20;

    const config_header = b.addConfigHeader(
        .{
            .style = .blank,
        },
        .{
            .WANT_ASSERT = want_assert,
            .WANT_REDZONES = want_redzones,
            .IS_LITTLE_ENDIAN = 0x10,
            .IS_BIG_ENDIAN = 0x20,
            .PLATFORM_BYTE_ORDER = platform_byte_order,
        },
    );

//    print("want_assert: {}\n", .{want_assert});
//    print("target: {}\n", .{target});
//    const t = target.toTarget();
//    var flag_felf = "-felf64";
//    if (t.cpu.arch == .x86_64) {
//        print("x86_64\n", .{});
//        flag_felf = "-felf64";
//    } else if (t.cpu.arch == .x86) {
//        flag_felf = "-felf32";
//    } else if (t.cpu.arch == .aarch64) {
//        print("aarch64\n", .{});
//        flag_felf = "       ";
//    } else {
//        print("unknown\n", .{});
//        flag_felf = "       ";
//    }
//    print("flag_felf: {s}\n", .{flag_felf});

//    const want_assert_str = switch (want_assert) {
//        true => "1",
//        false => "0",
//    };

    const common_cflags: []const []const u8 = &.{
        "-fno-sanitize=undefined",
    };

    const lib = b.addStaticLibrary(.{
        .name = "bsdnt",
        .target = target,
        .optimize = optimize,
    });

    lib.addConfigHeader(config_header);

    const lib_sources = [_][]const u8{
        "helper.c",
        "nn.c",
        "nn_linear.c",
        "nn_quadratic.c",
        "nn_subquadratic.c",
        "sha1.c",
        "test.c",
        "zz0.c",
        "zz.c",
    };

    lib.addCSourceFiles(&lib_sources, common_cflags);
    lib.addIncludePath(.{ .path = "." });
    lib.linkLibC();

    lib.installConfigHeader(config_header, .{ .dest_rel_path = "bsdnt/config.h" });
    lib.installHeader("helper_arch.h", "bsdnt/helper_arch.h");
    lib.installHeader("helper.h", "bsdnt/helper.h");
    lib.installHeader("nn_arch.h", "bsdnt/nn_arch.h");
    lib.installHeader("nn.h", "bsdnt/nn.h");
    lib.installHeader("nn_linear_arch.h", "bsdnt/nn_linear_arch.h");
    lib.installHeader("nn_quadratic_arch.h", "bsdnt/nn_quadratic_arch.h");
    lib.installHeader("nn_subquadratic_arch.h", "bsdnt/nn_subquadratic_arch.h");
    lib.installHeader("rand.h", "bsdnt/rand.h");
    lib.installHeader("sha1.h", "bsdnt/sha1.h");
    lib.installHeader("test.h", "bsdnt/test.h");
    lib.installHeader("tuning.h", "bsdnt/tuning.h");
    lib.installHeader("types_arch.h", "bsdnt/types_arch.h");
    lib.installHeader("zz0.h", "bsdnt/zz0.h");
    lib.installHeader("zz.h", "bsdnt/zz.h");

    b.installArtifact(lib);
}
