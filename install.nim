discard """

install.nim
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

var prefix: string

if paramCount() >= 1:
    prefix = paramStr(1)
else:
    prefix = "nimble_wrapper"

proc startCmdProcessAndSuccessOrDie(command: string, args: openArray[string]) =
    stdout.write(">>> ")

    let installProcess = startProcess(command, args = args, options = {poParentStreams, poUsePath, poEchoCmd})
    if installProcess.waitForExit != 0:
        raise newException(ESystem, "Command failed!")

proc shExec(command: string, args: openArray[string]) =
    startCmdProcessAndSuccessOrDie(command, args)

proc cd(path: string) =
    echo ">>> cd " & path
    setCurrentDir(path)

proc mkdir_force(path: string) =
    createDir(path)

proc cpfile_a(source: string, dest: string) =
    copyFileWithPermissions(source, dest, false)

echo "Installing nimble_wrapper.\n"

shExec("nimrod", @["c", "-d:release", "nimble_wrapper"])

mkdir_force prefix/"bin"
cpfile_a("nimble-wrapper", prefix/"bin"/"nimble")

cd prefix
if not existsDir("nimble"):
    shExec("git", @["clone", "git://github.com/nimrod-code/nimble.git", "nimble"])

cd "nimble"
shExec("nimrod", @["c", "-d:release", "src/nimble"])

echo "\nnimble-wrapper installed into \"" & prefix & "\", binary is at \"" & prefix & "/bin/nimble\"."
