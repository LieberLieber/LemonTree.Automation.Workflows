ECHO FOO
%~dp0mpmsmerge.cmd "%~dp0merge\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms" "%~dp0base\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms" "%~dp0mine\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms" "%~dp0theirs\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms"
type %~dp0mpmsmerge-output.log
