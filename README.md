This is a snapshot of a webrender revision that was hitting a macOS/Intel shader bug. [This particular bug was filed as bug 1689510](https://bugzilla.mozilla.org/show_bug.cgi?id=1689510), but we have hit variations of broken integer equality comparisons [many times before](https://github.com/servo/webrender/wiki/Driver-issues#2864---mac-glsl-compiler-bug-with-integer-comparisons).

It is not a reduced testcase.

Run with the following command:

```
cargo run --bin wrench -- show wrench/reftests/text/text.yaml
```

Blue text means no driver bug.
Black text means driver bug.

See [ps_text_run.glsl](./webrender/res/ps_text_run.glsl) for more details.

Affected configurations include Intel HD Graphics 530 on macOS Big Sur 11.2 Beta, and many others.
