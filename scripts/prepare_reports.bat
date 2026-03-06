set BUILD_DIR=%BUILD_NUMBER%
set ERROR_DIR=%BUILD_DIR%\error_logs
set REMOTE_BUILD=/users/gen/omswrk1/JEE/OMS/logs/OmsDomain/OmsServer/sanity_logs/%JOB_NAME%_%BUILD_NUMBER%
set HOST=illnqw%ENV%

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