# Copyright (c) 2026 Ruslan Belous #
param(
    [int]$gridWidth  = 40,    
    [int]$gridHeight = 20,
    [String]$title = "Ruslan"
)   
$totalGens      = 500    
$pauseMs        = 20    
$liveCellCounter = 0

$letterFilePath = Join-Path $PSScriptRoot "letters.ps1"
if (Test-Path $letterFilePath) { . $letterFilePath } else { Write-Error "Missing letters.ps1"; return }

function New-EmptyGrid {
    $grid = @()   

    for ($row = 0; $row -lt $gridHeight; $row++) {
        $currentRow = @()   

        for ($col = 0; $col -lt $gridWidth; $col++) {
            $currentRow += 0
        }

        $grid += , $currentRow
    }

    return $grid
}

function New-RandomGrid {
    $grid = @()   

    for ($row = 0; $row -lt $gridHeight; $row++) {
        $currentRow = @()   

        for ($col = 0; $col -lt $gridWidth; $col++) {
            $currentRow += Get-Random -Minimum 0 -Maximum 2
        }

        $grid += , $currentRow
    }

    return $grid
}

function New-PresetGrid {
    param(
        [int]$charWidth = 3
    )
    $grid = New-EmptyGrid
    $startX = [int][Math]::Max(0, ($gridWidth - ($title.Length * $charWidth)) / 2)
    $startY = [int][Math]::Max(0, ($gridHeight - 7) / 2) 
    Write-Host $StartX -ForegroundColor Red
    Write-Host $StartY -ForegroundColor Red
    for ($i = $startX; $i -le $gridWidth; $i++){

    }
}



function Count-LiveNeighbors {
    param(
        $grid,
        [int]$row,
        [int]$col
    )

    $liveCount = 0

    for ($rowOffset = -1; $rowOffset -le 1; $rowOffset++) {
        for ($colOffset = -1; $colOffset -le 1; $colOffset++) {

            if ($rowOffset -eq 0 -and $colOffset -eq 0) {
                continue 
            }

            $neighborRow = ($row + $rowOffset + $gridHeight) % $gridHeight
            $neighborCol = ($col + $colOffset + $gridWidth)  % $gridWidth

            $liveCount += $grid[$neighborRow][$neighborCol]
        }
    }

    return $liveCount
}


function Get-NextGeneration {
    param($currentGrid)

    $nextGrid = @()   
    $changes = 0
    for ($row = 0; $row -lt $gridHeight; $row++) {
        $nextRow = @()
        

        for ($col = 0; $col -lt $gridWidth; $col++) {
            $isAlive   = $currentGrid[$row][$col]
            $neighbors = Count-LiveNeighbors -grid $currentGrid -row $row -col $col

            if ($isAlive -eq 1 -and ($neighbors -eq 2 -or $neighbors -eq 3)) {
                $nextRow += 1
                $LiveCellCounter += 1
            }
            elseif ($isAlive -eq 0 -and $neighbors -eq 3) {
                $nextRow += 1
                $liveCellCounter += 1
            }
            else {
                $nextRow += 0
                $liveCellCounter -= 1
            }
        }

        $nextGrid += , $nextRow
    }

    return $nextGrid
}



function Show-Grid {
    param(
        $grid,
        [int]$generation
    )


    [Console]::SetCursorPosition(0, 0)


    $frame = [System.Text.StringBuilder]::new()
    for ($row = 0; $row -lt $gridHeight; $row++) {
        for ($col = 0; $col -lt $gridWidth; $col++) {

            if ($grid[$row][$col] -eq 1) {
                $null = $frame.Append('@') # like print
                $liveCellCounter += 1 
            } else {
                $null = $frame.Append(' ')
            }
        }
        $null = $frame.AppendLine() # like println
    }

    
    $displayString = $frame.ToString()
    $header = "Game of life: gen: " + $generation + " - " + $liveCellCounter + " live cells "
    Write-Host $header -ForegroundColor Cyan
    Write-Host $frame.ToString() -NoNewline
    #Write-Host ($displayString.Substring($displayString.IndexOf("`n") + 1)) -NoNewline
}




Clear-Host
[Console]::CursorVisible = $false    

$grid = New-RandomGrid

for ($gen = 1; $gen -le $totalGens; $gen++) {
    New-PresetGrid -charWidth 5
    Show-Grid -grid $grid -generation $gen  
    $grid = Get-NextGeneration -currentGrid $grid
    Start-Sleep -Milliseconds $pauseMs
}

[Console]::CursorVisible = $true     