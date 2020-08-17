@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  rsocket-cli startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and RSOCKET_CLI_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\rsocket-cli-master-5a7c934.jar;%APP_HOME%\lib\oksocial-output-5.3.jar;%APP_HOME%\lib\jfreesvg-3.4.jar;%APP_HOME%\lib\svg-salamander-1.0.jar;%APP_HOME%\lib\commons-io-2.6.jar;%APP_HOME%\lib\jackson-dataformat-yaml-2.11.0.jar;%APP_HOME%\lib\jackson-module-kotlin-2.11.0.jar;%APP_HOME%\lib\spring-boot-starter-rsocket-2.3.2.RELEASE.jar;%APP_HOME%\lib\jackson-dataformat-cbor-2.11.1.jar;%APP_HOME%\lib\spring-boot-starter-json-2.3.2.RELEASE.jar;%APP_HOME%\lib\jackson-datatype-jdk8-2.11.1.jar;%APP_HOME%\lib\jackson-datatype-jsr310-2.11.1.jar;%APP_HOME%\lib\jackson-module-parameter-names-2.11.1.jar;%APP_HOME%\lib\jackson-databind-2.11.1.jar;%APP_HOME%\lib\guava-29.0-jre.jar;%APP_HOME%\lib\byteunits-0.9.1.jar;%APP_HOME%\lib\okio-jvm-2.7.0.jar;%APP_HOME%\lib\picocli-4.5.0.jar;%APP_HOME%\lib\reactor-kotlin-extensions-1.0.2.RELEASE.jar;%APP_HOME%\lib\rsocket-transport-local-1.0.2.jar;%APP_HOME%\lib\rsocket-transport-netty-1.0.2.jar;%APP_HOME%\lib\rsocket-core-1.0.2.jar;%APP_HOME%\lib\activation-1.1.1.jar;%APP_HOME%\lib\http2-http-client-transport-9.4.19.v20190610.jar;%APP_HOME%\lib\kotlin-reflect-1.3.72.jar;%APP_HOME%\lib\kotlin-stdlib-jdk8-1.3.72.jar;%APP_HOME%\lib\kotlinx-coroutines-jdk8-1.3.8.jar;%APP_HOME%\lib\kotlinx-coroutines-reactor-1.3.8.jar;%APP_HOME%\lib\kotlinx-coroutines-reactive-1.3.8.jar;%APP_HOME%\lib\kotlinx-coroutines-core-1.3.8.jar;%APP_HOME%\lib\slf4j-jdk14-1.8.0-beta4.jar;%APP_HOME%\lib\zt-exec-1.11.jar;%APP_HOME%\lib\spring-boot-starter-2.3.2.RELEASE.jar;%APP_HOME%\lib\spring-boot-starter-logging-2.3.2.RELEASE.jar;%APP_HOME%\lib\logback-classic-1.2.3.jar;%APP_HOME%\lib\log4j-to-slf4j-2.13.3.jar;%APP_HOME%\lib\jul-to-slf4j-1.7.30.jar;%APP_HOME%\lib\slf4j-api-1.8.0-beta4.jar;%APP_HOME%\lib\jackson-annotations-2.11.1.jar;%APP_HOME%\lib\jackson-core-2.11.1.jar;%APP_HOME%\lib\snakeyaml-1.26.jar;%APP_HOME%\lib\failureaccess-1.0.1.jar;%APP_HOME%\lib\listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\checker-qual-2.11.1.jar;%APP_HOME%\lib\error_prone_annotations-2.3.4.jar;%APP_HOME%\lib\j2objc-annotations-1.3.jar;%APP_HOME%\lib\kotlin-stdlib-jdk7-1.3.72.jar;%APP_HOME%\lib\kotlin-stdlib-1.3.72.jar;%APP_HOME%\lib\kotlin-stdlib-common-1.3.72.jar;%APP_HOME%\lib\spring-boot-starter-reactor-netty-2.3.2.RELEASE.jar;%APP_HOME%\lib\reactor-netty-0.9.11.RELEASE.jar;%APP_HOME%\lib\reactor-core-3.3.9.RELEASE.jar;%APP_HOME%\lib\netty-codec-http2-4.1.51.Final.jar;%APP_HOME%\lib\netty-handler-proxy-4.1.51.Final.jar;%APP_HOME%\lib\netty-codec-http-4.1.51.Final.jar;%APP_HOME%\lib\netty-handler-4.1.51.Final.jar;%APP_HOME%\lib\netty-transport-native-epoll-4.1.51.Final-linux-x86_64.jar;%APP_HOME%\lib\netty-codec-socks-4.1.51.Final.jar;%APP_HOME%\lib\netty-codec-4.1.51.Final.jar;%APP_HOME%\lib\netty-transport-native-unix-common-4.1.51.Final.jar;%APP_HOME%\lib\netty-transport-4.1.51.Final.jar;%APP_HOME%\lib\netty-buffer-4.1.51.Final.jar;%APP_HOME%\lib\jetty-client-9.4.19.v20190610.jar;%APP_HOME%\lib\http2-client-9.4.19.v20190610.jar;%APP_HOME%\lib\reactive-streams-1.0.3.jar;%APP_HOME%\lib\spring-messaging-5.2.8.RELEASE.jar;%APP_HOME%\lib\netty-resolver-4.1.51.Final.jar;%APP_HOME%\lib\netty-common-4.1.51.Final.jar;%APP_HOME%\lib\http2-common-9.4.19.v20190610.jar;%APP_HOME%\lib\http2-hpack-9.4.19.v20190610.jar;%APP_HOME%\lib\jetty-http-9.4.19.v20190610.jar;%APP_HOME%\lib\jetty-alpn-client-9.4.19.v20190610.jar;%APP_HOME%\lib\jetty-io-9.4.19.v20190610.jar;%APP_HOME%\lib\annotations-13.0.jar;%APP_HOME%\lib\spring-boot-autoconfigure-2.3.2.RELEASE.jar;%APP_HOME%\lib\spring-boot-2.3.2.RELEASE.jar;%APP_HOME%\lib\jakarta.annotation-api-1.3.5.jar;%APP_HOME%\lib\spring-web-5.2.8.RELEASE.jar;%APP_HOME%\lib\spring-context-5.2.8.RELEASE.jar;%APP_HOME%\lib\spring-aop-5.2.8.RELEASE.jar;%APP_HOME%\lib\spring-beans-5.2.8.RELEASE.jar;%APP_HOME%\lib\spring-expression-5.2.8.RELEASE.jar;%APP_HOME%\lib\spring-core-5.2.8.RELEASE.jar;%APP_HOME%\lib\jetty-util-9.4.19.v20190610.jar;%APP_HOME%\lib\spring-jcl-5.2.8.RELEASE.jar;%APP_HOME%\lib\logback-core-1.2.3.jar;%APP_HOME%\lib\log4j-api-2.13.3.jar


@rem Execute rsocket-cli
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %RSOCKET_CLI_OPTS%  -classpath "%CLASSPATH%" io.rsocket.cli.Main %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable RSOCKET_CLI_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%RSOCKET_CLI_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
