function New-SocialClip {
    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InputFile,

        [ValidateNotNullOrEmpty()]
        [string]$OutputFile = [IO.Path]::GetFileNameWithoutExtension($InputFile),

        [ValidateRange(0, 100)]
        [int]$BlurPercentage,

        [switch]$TikTok,

        [switch]$Instagram
    )

    $width, $height = (ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 $InputFile).Split("x")[0, 1]
    $coefficient = $width/$height

    if ($TikTok) {
        $OutputFile = "TikTok_" + $OutputFile + ".mp4"
        ffmpeg.exe -y -i $InputFile -vf "split [original][copy]; [copy] crop=ih*9/16:ih:iw/2-ow/2:0, scale=$($width):$([Math]::Ceiling(($coefficient * $width) / 2) * 2), gblur=sigma=$($BlurPercentage)[blurred]; [blurred][original]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" $OutputFile
    }

    if ($Instagram) {
        $OutputFile = "Instagram_" + $OutputFile + ".mp4"
        ffmpeg.exe -y -i $InputFile -vf "split [original][copy]; [copy] crop=$($height)*1/1:$($height):$($width)/2-ow/2:0, scale=$($width):$($width), gblur=sigma=$($BlurPercentage)[blurred]; [blurred][original]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" $OutputFile
    }

    if (!($Instagram -or $TikTok)) {Write-Error "Please provide -TikTok or -Instagram as a parameter."}
}
