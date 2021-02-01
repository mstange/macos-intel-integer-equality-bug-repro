# Investigation complete, repository archived

We traced the bug to the use of the `texelFetchOffset` function.
There is a more reduced standalone testcase at [jrmuizel/texel-fetch-offset](https://github.com/jrmuizel/texel-fetch-offset).

More details on the bug are in [bug 1690027](https://bugzilla.mozilla.org/show_bug.cgi?id=1690027).

# Old description

This is a snapshot of a webrender revision that was hitting a macOS/Intel OpenGL shader compilation bug. [This particular bug was filed as bug 1689510](https://bugzilla.mozilla.org/show_bug.cgi?id=1689510), but we have hit variations of broken integer equality comparisons [many times before](https://github.com/servo/webrender/wiki/Driver-issues#2864---mac-glsl-compiler-bug-with-integer-comparisons).

It has been reduced by some amount but not by much.

Run with the following command:

```
cargo run --bin wrench -- --use-unoptimized-shaders --shaders=res2 show wrench/reftests/text/text.yaml
```

Blue text means no driver bug.
Black text means driver bug.

See [ps_text_run.glsl](./res2/ps_text_run.glsl) for more details.

Affected configurations include Intel HD Graphics 530 on macOS Big Sur 11.2 Beta, and many others.
