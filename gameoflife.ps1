
$gridWidth      = 40  
$gridHeight     = 40     
$totalGens      = 100    
$pauseMs        = 15    



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

    for ($row = 0; $row -lt $gridHeight; $row++) {
        $nextRow = @()

        for ($col = 0; $col -lt $gridWidth; $col++) {
            $isAlive   = $currentGrid[$row][$col]
            $neighbors = Count-LiveNeighbors -grid $currentGrid -row $row -col $col

            if ($isAlive -eq 1 -and ($neighbors -eq 2 -or $neighbors -eq 3)) {
                $nextRow += 1   
            }
            elseif ($isAlive -eq 0 -and $neighbors -eq 3) {
                $nextRow += 1   
            }
            else {
                $nextRow += 0   
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

    $null = $frame.AppendLine("Generation $generation of $totalGens   (Press Ctrl+C to quit)")

    for ($row = 0; $row -lt $gridHeight; $row++) {
        for ($col = 0; $col -lt $gridWidth; $col++) {

            if ($grid[$row][$col] -eq 1) {
                $null = $frame.Append('#')
            } else {
                $null = $frame.Append(' ')
            }
        }
        $null = $frame.AppendLine()
    }

    Write-Host $frame.ToString() -NoNewline
}




Clear-Host
[Console]::CursorVisible = $false    

$grid = New-RandomGrid               

for ($gen = 1; $gen -le $totalGens; $gen++) {
    Show-Grid -grid $grid -generation $gen         
    $grid = Get-NextGeneration -currentGrid $grid   
    Start-Sleep -Milliseconds $pauseMs              
}

[Console]::CursorVisible = $true     