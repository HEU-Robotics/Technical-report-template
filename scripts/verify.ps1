[CmdletBinding()]
param(
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'
$repoRoot = [System.IO.Path]::GetFullPath((Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$buildDir = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'build'))

if (-not [string]::Equals([System.IO.Path]::GetDirectoryName($buildDir), $repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Unexpected build directory: $buildDir"
}

Push-Location $repoRoot
try {
    if (Test-Path -LiteralPath $buildDir) {
        $buildItem = Get-Item -LiteralPath $buildDir -Force
        if (($buildItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing to clean a reparse point: $buildDir"
        }
        [System.IO.Directory]::Delete($buildDir, $true)
    }
    New-Item -ItemType Directory -Path $buildDir | Out-Null

    $savedErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        if (Get-Command latexmk -ErrorAction SilentlyContinue) {
            $engine = 'latexmk'
            $output = @(& latexmk -xelatex -interaction=nonstopmode -halt-on-error -outdir=build main.tex 2>&1)
            $exitCode = $LASTEXITCODE
        }
        elseif (Get-Command xelatex -ErrorAction SilentlyContinue) {
            $engine = 'xelatex'
            $output = @()
            $exitCode = 0
            foreach ($pass in 1..2) {
                $output += @(& xelatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex 2>&1)
                $exitCode = $LASTEXITCODE
                if ($exitCode -ne 0) { break }
            }
        }
        else {
            throw 'No latexmk or xelatex executable was found.'
        }
    }
    finally {
        $ErrorActionPreference = $savedErrorActionPreference
    }

    $output | Set-Content -Encoding utf8 (Join-Path $buildDir 'verify.log')
    if ($exitCode -ne 0) {
        $tail = $output | Select-Object -Last 40 | Out-String
        throw "$engine failed with exit code $exitCode.`n$tail"
    }

    $pdfPath = Join-Path $buildDir 'main.pdf'
    $latexLogPath = Join-Path $buildDir 'main.log'
    if (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) { throw 'Build succeeded without build/main.pdf.' }
    if (-not (Test-Path -LiteralPath $latexLogPath -PathType Leaf)) { throw 'Build succeeded without build/main.log.' }

    $latexLog = Get-Content -Raw -Encoding utf8 $latexLogPath
    if ($latexLog -match 'LaTeX Warning: (Reference|Citation).*undefined|There were undefined references') {
        throw 'Undefined reference or citation found in build/main.log.'
    }

    $texFiles = @((Join-Path $repoRoot 'main.tex')) + @(Get-ChildItem (Join-Path $repoRoot 'sections') -Filter '*.tex' | Select-Object -ExpandProperty FullName)
    $activeText = foreach ($file in $texFiles) {
        foreach ($line in Get-Content -Encoding utf8 $file) {
            if ($line -notmatch '^\s*%') { $line }
        }
    }
    $references = @([regex]::Matches(($activeText -join "`n"), '\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    foreach ($reference in $references) {
        $imagePath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $reference))
        if (-not $imagePath.StartsWith($repoRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Image reference escaped the project root: $reference"
        }
        if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf)) {
            throw "Referenced image does not exist: $reference"
        }
    }

    if ($Strict) {
        $reportFiles = @((Join-Path $repoRoot 'report-info.tex'), (Join-Path $repoRoot 'main.tex')) +
            @(Get-ChildItem (Join-Path $repoRoot 'sections') -Filter '*.tex' |
                Where-Object { $_.Name -ne 'section-template.tex' } |
                Select-Object -ExpandProperty FullName)
        $reportText = ($reportFiles | ForEach-Object { Get-Content -Raw -Encoding utf8 $_ }) -join ([Environment]::NewLine)
        $placeholderPattern = '\u5F85\u586B\u5199|TODO|TBD|\u6280\u672F\u62A5\u544A\u6807\u9898|\u526F\u6807\u9898\u6216\u9879\u76EE\u540D\u79F0|\u4F5C\u8005\u59D3\u540D'
        if ($reportText -match $placeholderPattern) {
            throw 'Strict check failed: report still contains placeholder text.'
        }
    }

    $mode = if ($Strict) { 'strict' } else { 'template' }
    Write-Output "OK: $engine $mode build passed; $($references.Count) image reference(s) resolved; no undefined references."
    Write-Output "PDF: $pdfPath"
}
finally {
    Pop-Location
}
