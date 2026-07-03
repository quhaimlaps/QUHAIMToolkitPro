$script:HTP_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$script:HTP_ROOT\Engine\Bootstrap\Bootstrap.ps1"

Initialize-HtpEngine
