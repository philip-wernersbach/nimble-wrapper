discard """

nimble_wrapper.nim
Part of nimble-wrapper

Copyright (c) 2014, Philip Wernersbach
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""

import os
import osproc
import posix
import sequtils

const possibleNimbleDirs = [".nimble", ".babel"]
const possibleNimbleExes = ["nimble", "babel"]

### FROM http://gist.github.com/Araq/1657152
proc allocCStringArray*(a: openArray[string]): cstringArray =
    ## creates a NULL terminated cstringArray from `a`. The result has to
    ## be freed with `deallocCStringArray` after it's not needed anymore.
    result = cast[cstringArray](alloc0((a.len+1) * sizeof(cstring)))
    for i in 0 .. a.high:
        # XXX get rid of this string copy here:
        var x = a[i]
        result[i] = cast[cstring](alloc0(x.len+1))
        copyMem(result[i], addr(x[0]), x.len)

proc deallocCStringArray*(a: cstringArray) =
    ## frees a NULL terminated cstringArray.
    var i = 0
    while a[i] != nil:
        dealloc(a[i])
        inc(i)
    dealloc(a)
### END http://gist.github.com/Araq/1657152

proc nimbleinstalledAt(base: string): string =
    for nimbleDir in possibleNimbleDirs:
        for nimbleExe in possibleNimbleExes:
            if existsFile(base/nimbleDir/"bin"/nimbleExe):
                return base/nimbleDir/"bin"/nimbleExe

    return ""

proc systemNimbleInstalledAt(base: string): string =
    for nimbleExe in possibleNimbleExes:
            if existsFile(base/"src"/nimbleExe):
                return base/"src"/nimbleExe

    raise newException(ESystem, "System nimble not installed!")

if existsEnv("HOME"):
    var nimbleSetupStatus = 0

    let home = getEnv("HOME")
    var nimblePath = nimbleinstalledAt(home)

    if nimblePath == "" :
        let oldDir = getCurrentDir()

        setCurrentDir(getAppDir()/".."/"nimble")
        stderr.writeln("===== nimble-wrapper: Installing nimble =====")

        let installProcess = startProcess(systemNimbleInstalledAt("."), args = @["install"], options = {poParentStreams})
        nimbleSetupStatus = installProcess.waitForExit

        stderr.writeln("===== nimble-wrapper: Finished installing nimble =====\n")
        setCurrentDir(oldDir)

        nimblePath = nimbleinstalledAt(home)

    if nimbleSetupStatus == 0:
        if execv(nimblePath, @[nimblePath].concat(commandLineParams()).allocCStringArray) == -1:
            stderr.writeln("nimble-wrapper: Can't exec home nimble!")
    else:
        stderr.writeln("nimble-wrapper: Failed to install nimble!")
else:
    stderr.writeln("nimble-wrapper: $HOME must be set!")

quit(QuitFailure)
