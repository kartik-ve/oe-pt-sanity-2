set BUILD_DIR=%BUILD_NUMBER%
set REMOTE_BASE=/users/gen/omswrk1/JEE/OMS/logs/OmsDomain/OmsServer
set REMOTE_WORKSPACE=%REMOTE_BASE%/sanity_logs
set REMOTE_BUILD=%REMOTE_WORKSPACE%/%JOB_NAME%_%BUILD_NUMBER%
set HOST=illnqw%ENV%

ssh omswrk1@%HOST% ^
  "ps -eo pid,etimes,cmd | awk '$2 >= 21600 && $0 ~ /tail -fn 0 \/users\/gen\/omswrk1\/JEE\/OMS\/logs\/OmsDomain\/OmsServer\/weblogic/ {print $1}' | xargs -r kill -9"

ssh omswrk1@%HOST% ^
  "mkdir -p %REMOTE_BUILD%"

scp java\remote\LogSearch.java ^
  omswrk1@%HOST%:%REMOTE_WORKSPACE%
ssh omswrk1@%HOST% ^
  "javac -d %REMOTE_WORKSPACE% %REMOTE_WORKSPACE%/LogSearch.java"

set TESTSUITE_PREFIX=
if "%SANITY_TYPE%"=="Basic" (
  set "TESTSUITE_PREFIX=Basic Sanity - "
)

for %%S in (NC COS CR RP MT BT SU COAM) do (
  echo Running flow %%S

  ssh omswrk1@%HOST% ^
    "tail -fn 0 $(ls -t %REMOTE_BASE%/weblogic.*.log | head -1) > %REMOTE_BUILD%/%%S.log 2>&1 & echo $! > %REMOTE_BUILD%/%%S.pid"

  set "TESTSUITE="
  if "%%S"=="NC" set "TESTSUITE=New Connect"
  if "%%S"=="COS" set "TESTSUITE=Change of Service"
  if "%%S"=="CR" set "TESTSUITE=Cease & Restart"
  if "%%S"=="RP" set "TESTSUITE=Replace Offer"
  if "%%S"=="MT" set "TESTSUITE=Move & Transfer"
  if "%%S"=="BT" set "TESTSUITE=Bulk Tenant"
  if "%%S"=="SU" set "TESTSUITE=Seasonal Suspend"
  if "%%S"=="COAM" (
    if "%SANITY_TYPE%"=="Basic" (
      set "TESTSUITE=CO & AM"
    ) else (
      goto :after_loop
    )
  )

  call testrunner.bat ^
    -E "ENV %ENV% GTM" ^
    -s "%TESTSUITE_PREFIX%%%TESTSUITE%%" ^
    -j -f "%CD%\%BUILD_DIR%\junit_report\%TESTSUITE_PREFIX%%%TESTSUITE%%" ^
    -r "%CD%\xml\PT.xml"

  ssh omswrk1@%HOST% ^
    "kill $(cat %REMOTE_BUILD%/%%S.pid)"

  ssh omswrk1@%HOST% ^
    "java -cp %REMOTE_WORKSPACE% LogSearch %REMOTE_BUILD%/%%S.log"
)

:after_loop

set ERROR_DIR=%BUILD_DIR%\error_logs

if not exist "%ERROR_DIR%" mkdir "%ERROR_DIR%"
scp omswrk1@%HOST%:%REMOTE_BUILD%/*.err "%ERROR_DIR%"

java -cp "java\local\target\classes;java\local\target\dependency\*" ^
  com.amdocs.sanity.SanityRunner ^
  --config config\sanity.properties ^
  --buildDir %BUILD_DIR% ^
  --jobName "%JOB_NAME%_#%BUILD_NUMBER%" ^
  --type "%SANITY_TYPE%" ^
  --env %ENV% ^
  --tester "%TESTER%" ^
  --project OE ^
  --dmp x.x.x.x

exit /b 0