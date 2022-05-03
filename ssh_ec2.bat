@echo off
REM Wrapper for aws SessionManager and Instance connect

set "INSTANCE_ID=%~1"
if "%INSTANCE_ID%"=="" (
  call :_usage
  goto EOF
)

shift

:loop
if not "%~1"=="" (
  if "%~1"=="--key-file" (
    set "KEY_FILE=%~2"
    shift
  ) else if "%~1"=="--port-number" (
    set "PORT_NUMBER=%~2"
    shift
  ) else if "%~1"=="--user" (
    set "USER_NAME=%~2"
    shift
  ) else if "%~1"=="--send-key-only" (
    set "SEND_KEY_ONLY=true"
  )
  shift
  goto :loop
)

if "%USER_NAME%"=="" (
  set "USER_NAME=ubuntu"
)

if "%PORT_NUMBER%"=="" (
  set "PORT_NUMBER=22"
)

if "%KEY_FILE%"=="" (
  set "KEY_FILE=%USERPROFILE%\.ssh\id_rsa.pub"
)

for /F "delims=" %%R in ("%KEY_FILE%") do set KEY_FILE_URL=%%~fR
set "KEY_FILE_URL=file:///%KEY_FILE_URL%"
set "KEY_FILE_URL=%KEY_FILE_URL:///\\=//%"
set "KEY_FILE_URL=%KEY_FILE_URL:\=/%"

call :_get_instance_az

call :_send_ssh_public_key_to_instance

if NOT "%SEND_KEY_ONLY%"=="true" (
  aws ssm start-session --target %INSTANCE_ID% --document-name AWS-StartSSHSession --parameters portNumber=%PORT_NUMBER% 
)

goto EOF

:_get_instance_az
    FOR /F "tokens=1 usebackq delims=^:" %%f in (`aws ec2 describe-instances --instance-ids="%INSTANCE_ID%" --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text`) do set "AZ=%%~f"
goto EOF

:_send_ssh_public_key_to_instance
    aws ec2-instance-connect send-ssh-public-key --instance-id "%INSTANCE_ID%" --availability-zone "%AZ%" --instance-os-user "%USER_NAME%" --ssh-public-key "%KEY_FILE_URL%"
goto EOF

:_usage
echo  ^

 ^

%~n0^: ssh proxy for putty to ec2 instance via ssm/instance-connect^

 ^

Requirements:^

    - AWS CLI is installed.^

    - Permission to run "aws ssm start-session".^

    - Permission to run "aws ec2 describe-instances" to determine which AZ the instance is in.^

    - Permission to run "aws ec2-instance-connect send-ssh-public-key"^

    - A public key file in ssh format (e.g. id_rsa.pub) corresponding to the private key file used by putty (.ppk). ^

    - SSH connections through the SessionManager are allowed in putty session config.^

        [Connection]-[Proxy]^

          [Proxy Type]^

            Local^

          [Telnet command, or local proxy command]^

            "ssh_ec2 %%host --port-number %%port\n"^

 ^

Usage:^

    %~n0 ^<instance-id^> [--user ^<user^>] [--key-file ^<key-file^>] [--port-number ^<port-number^>] [--send-key-only]^

 ^

Options:^

    instance-id:        ID of the instance to ssh to.(e.g. "i-12345678")^

    --user:             (default: "ubuntu")^

    --key-file:         (default: "%USERPROFILE%\.ssh\id_rsa.pub")^

    --port-number:      (default: 22)^

    --send-key-only:    Only transfer the key and do not execute ssh command. (default: false) >&2

goto EOF
:EOF
