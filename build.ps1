# Builds wkDirect3D.dll (a 32-bit WormKit module for Worms Armageddon 3.8.1) with MinGW (32-bit gcc).
#   .\build.ps1 [-Gcc C:\MinGW\bin\gcc.exe] [-Shaders]     (-Shaders: src\shaders.h made again from tools\mkshaders.c)
param([string]$Gcc = 'C:\MinGW\bin\gcc.exe', [switch]$Shaders)
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$opt = @('-O2', '-Wall', '-Wextra', '-std=gnu99', '-msse2', '-mfpmath=sse', '-mstackrealign')
if ($Shaders) {
    $ErrorActionPreference = 'Continue'
    & $Gcc -O2 -Wall (Join-Path $here 'tools\mkshaders.c') -o (Join-Path $here 'tools\mkshaders.exe')
    if ($LASTEXITCODE -ne 0) { throw 'mkshaders build failed' }
    & (Join-Path $here 'tools\mkshaders.exe') (Join-Path $here 'src\shaders.h')
    if ($LASTEXITCODE -ne 0) { throw 'shaders failed' }
    $ErrorActionPreference = 'Stop'
}
$ErrorActionPreference = 'Continue'     # (compiler warnings on stderr are not build failures)
& $Gcc -shared @opt -static-libgcc -s (Join-Path $here 'src\wkDirect3D.c') -o (Join-Path $here 'wkDirect3D.dll') -lgdi32
$ErrorActionPreference = 'Stop'
if ($LASTEXITCODE -ne 0) { throw 'wkDirect3D.dll build failed' }
Get-FileHash -LiteralPath (Join-Path $here 'wkDirect3D.dll') -Algorithm SHA256 | Select-Object Hash, Path
