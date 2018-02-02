param(
    [string]$type
)

$timestamp = Get-Date -Format yyy.MM.dd

$logpath = $PSScriptRoot + "\logs\"

#Change this to specify port
$port = 8530

#Change this t specify cycles number
$attempt = 5

$table = @{}

$table_begin = @{
'192.168.0.0/24'=0.25;
}

if(!(Test-Path -Path $logpath )){
    new-item -path "$logpath" -ItemType directory
}


function setup-list {
    $file = $logpath + $filename
    $msg="Starting setup at " + (get-date -format G)
    $msg | out-file $file -append
    foreach ($h in $table.GetEnumerator()) {
        $Net = $h.Name
        $Net
        $name = $($Net -replace('/','_'))
        [uint64]$value = $h.Value*1000000
        $answer = New-NetQosPolicy -name $name -IPProtocol TCP -ThrottleRateActionBitsPerSecond $value -NetworkProfile domain -IPSrcPortMatchCondition $port -IPdstprefixmatchcondition $Net 2>$null
        if ($answer) {
            $text = (get-date -format G) + " " + $net + " successfully throttled to " + $h.Value
            $text | out-file $file -append
        } else {
            $table_begin.Add($h.Name, $h.Value)
        }
    }
}

function drop-list {
    $file = $logpath + $filename
    $msg="Starting dropping at " + (get-date -format G)
    $msg | out-file $file -append
    foreach ($h in $table.GetEnumerator()) {
        $Net = $h.Name
        $Net
        $name = $($Net -replace('/','_'))
        $answer_tmp = remove-NetQosPolicy -name "$Name" -Confirm:$false  2>&1
        $answer = $answer_tmp | ?{$_.gettype().Name -eq "ErrorRecord"}
        if (!$answer) {
            $text = (get-date -format G) + " " + $net + " successfully remove throttling from " + $h.Value
            $text | out-file $file -append
        } else {
            $table_begin.Add($h.Name, $h.Value)
        }
    }
}




function bad_end {
    $msg_head = "Attempts: " + $attempt
    $msg_head | out-file $errorFile -append
    foreach ($h in $table.GetEnumerator()) {
        $h.Name | out-file $errorFile -append
    }
    exit
}



if ($type -eq "setup") {
    $errorFile = $logpath + $timestamp + "_setup_errors.txt"
    $filename = $timestamp + "_setup.txt"
    while ($table_begin.count -ne 0 ) {
        if ($attempt -eq 0){
            bad_end
        }
        $attempt -= 1
        $table = $table_begin
        $table_begin = @{}
        setup-list
    }
} elseif ($type -eq "drop") {
    $errorFile = $logpath + $timestamp + "_drop_errors.txt"
    $filename = $timestamp + "_drop.txt"
    while ($table_begin.count -ne 0) {
        if ($attempt -eq 0){
            bad_end
        }
        $attempt -= 1
    $table = $table_begin
    $table_begin = @{}
    drop-list
    }
} else {
    "Wrong cmd params.", "Usage:", "posershell qos.ps1 setup      Is for setup", "posershell qos.ps1 drop       Is for dropping setuped rules" | write-host
    Break
}
