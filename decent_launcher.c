// decent_launcher.c — tiny Mach-O launcher for the standalone Decent.app built
// by make_standalone_osx.sh.
//
// WHY a compiled launcher instead of a #!/bin/bash CFBundleExecutable:
// macOS 26 enforces a LAUNCH CONSTRAINT on /bin/bash — LaunchServices refuses to
// spawn it as an app's main executable ("AMFI: Launch Constraint Violation ...
// /bin/bash"), so a shell-script main executable fails to launch (error 162 /
// "(null)") no matter how the bundle is signed or notarized. A real Mach-O main
// executable sidesteps the constraint entirely.
//
// What it does: chdir to the bundle's Contents/, read the interpreter path from
// Contents/Resources/interp (written by make_standalone_osx.sh), and exec it on
// de1plus.tcl — the same thing the old bash launcher did. Reading the interp
// from a file (rather than hardcoding) lets ONE compiled launcher serve both the
// arm64 (undroidwish-arm64) and x86 (undroidwish) builds.

#include <stdlib.h>
#include <unistd.h>
#include <libgen.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <mach-o/dyld.h>

int main(int argc, char **argv) {
    char path[PATH_MAX];
    uint32_t sz = sizeof(path);
    if (_NSGetExecutablePath(path, &sz) != 0) return 1;          // .../Contents/MacOS/Decent

    char macos[PATH_MAX];
    strncpy(macos, dirname(path), sizeof(macos) - 1);
    macos[sizeof(macos) - 1] = '\0';                             // .../Contents/MacOS

    char contents[PATH_MAX];
    strncpy(contents, dirname(macos), sizeof(contents) - 1);
    contents[sizeof(contents) - 1] = '\0';                       // .../Contents

    if (chdir(contents) != 0) return 1;                          // de1plus.tcl runs with cwd=Contents

    // Interpreter path written by make_standalone_osx.sh (one line, absolute).
    char interp[PATH_MAX] = {0};
    FILE *f = fopen("Resources/interp", "r");
    if (f) {
        if (fgets(interp, sizeof(interp), f)) {
            size_t n = strlen(interp);
            while (n && (interp[n - 1] == '\n' || interp[n - 1] == '\r')) interp[--n] = '\0';
        }
        fclose(f);
    }
    if (interp[0] == '\0')
        strncpy(interp, "/usr/local/bin/undroidwish-arm64", sizeof(interp) - 1);

    execl(interp, interp,
          "Resources/de1plus/de1plus.tcl",
          "-sdlheight", "801", "-sdlwidth", "1280",
          "-sdlrootheight", "800", "-sdlrootwidth", "1280",
          "-name", "DE1", (char *)NULL);
    return 1;   // exec failed (interpreter missing / not executable)
}
