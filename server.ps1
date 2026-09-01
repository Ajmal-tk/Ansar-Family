# Simple PowerShell Local Web Server for Ansar Family
$port = 8080
$prefix = "http://localhost:$port/"
$root = "c:\Users\ATK\ansar_family"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()

Write-Host "Ansar Family Web Server running on $prefix"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $urlPath = $request.Url.LocalPath
    if ($urlPath -eq "/") { $urlPath = "/index.html" }

    $localFilePath = Join-Path $root $urlPath

    if (Test-Path $localFilePath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($localFilePath)
        if ($localFilePath.EndsWith(".html")) { $response.ContentType = "text/html; charset=utf-8" }
        elseif ($localFilePath.EndsWith(".css")) { $response.ContentType = "text/css" }
        elseif ($localFilePath.EndsWith(".js")) { $response.ContentType = "application/javascript" }
        
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
        $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    $response.Close()
}
