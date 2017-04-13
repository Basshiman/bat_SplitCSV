@echo off
setLocal EnableDelayedExpansion
goto :begin

Text File Splitter
------------------------------
USAGE: Check Settings section before running.

:begin

Rem ------------------------------
Rem Settings ...
Rem ------------------------------

Rem ------------------------------
Rem Original file information
Rem ------------------------------
set limit=1
set file="bat_input.csv"
set numOfHeader=3
Rem Note: output will have (limit + numOfHeader) lines.

Rem ------------------------------
Rem Output file information
Rem ------------------------------
set nameBefore=【結果】
set nameAfter=_2017209
set extension=.csv
set zeroPadding=2
set batDir=%~dp0
set outDir=output\

if not exist !batDir!!outDir! (
    mkdir !batDir!!outDir!
)



Rem ------------------------------
Rem Start process ...
Rem ------------------------------
set lineCounter=1
set header=
set dqCount=0
set NLM=^


rem Two empty lines are required here

set firstFlag=0
set /a loopCount=0
if !numOfHeader! gtr 0 (
    set headerCounter=1
    for /f "tokens=* delims=: eol= usebackq" %%G in (%file%) do (
        if !numOfHeader! geq !headerCounter! (
            if !firstFlag! equ 0 (
                set firstFlag=1
                set header=%%G
            ) else (
                set header=!header!!NLM!%%G
            )

            Rem データの行を分解して配列に格納
            for %%g in (%%G) do (
                echo %%g | find """" >NUL
                if not ERRORLEVEL 1 (

                    call :COUNT_DQ %%g

                    set /a dqCount=!dqCount! + !dq_n!
                )
            )

            Rem カンマが奇数だった場合、セル内改行などが入っているので、次の行まで取り込む
            set /a dq_flag=!dqCount!%%2
            if !dq_flag! equ 0 (
              set /a dqCount=0
              set /a headerCounter=!headerCounter! + 1
            )

            set /a loopCount=!loopCount! + 1

        )
        if !headerCounter! gtr !numOfHeader! (
            set /a numOfHeader=!loopCount!
            goto :next
        )
    )
)

:next

set /a loopCount=1
set firstFlag=0

for /f "tokens=* delims=: eol= usebackq" %%A in (%file%) do (

    Rem ヘッダー分は処理を行わない
    if !loopCount! gtr !numOfHeader! (

        Rem データの行を分解して配列に格納
        set n=
        for %%a in (%%A) do (
            set /a n=n+1
            set [!n!]=%%a
            echo %%a | find """" >NUL
            if not ERRORLEVEL 1 (

                call :COUNT_DQ %%a

                set /a dqCount=!dqCount! + !dq_n!
            )
        )


        Rem ファイル名を設定
        if !firstFlag! equ 0 (
            set /a firstFlag=1

            set name=![2]! ![3]!
            set splitFile=!nameBefore!!name!!nameAfter!!fileNum!!extension!
            echo Creating !splitFile! ...

            Rem ヘッダーを配置
            if !numOfHeader! gtr 0 (
                echo !header!>> !batDir!!outDir!!splitFile!
            )
        )

        Rem データを挿入
        echo %%A>>!batDir!!outDir!!splitFile!

        Rem カンマが奇数だった場合、セル内改行などが入っているので、次の行まで取り込む
        set /a dq_flag=!dqCount!%%2
        if !dq_flag! equ 0 (
          set /a firstFlag=0
          set /a dqCount=0
          set /a lineCounter=!lineCounter! + 1
        )

        Rem ファイルの区切りかを判定
        if !lineCounter! gtr !limit! (
            set lineCounter=1
        )

    )

    set /a loopCount=!loopCount!+1

)

pause

Rem "の数を数えるサブルーチン
:COUNT_DQ
set dqStr=%1

Rem "の削除
set ndqStr=!dqStr:"=!
set dqStrlen=0
set ndqStrlen=0

Rem カンマありの文字数をカウント
set s=!dqStr!
:DQ_LOOP_HEAD
if defined s (
set s=%s:~1%
set /A dqStrlen+=1
goto :DQ_LOOP_HEAD
)

Rem カンマなしの文字数をカウント
set s=!ndqStr!
:NDQ_LOOP_HEAD
if defined s (
set s=%s:~1%
set /A ndqStrlen+=1
goto :NDQ_LOOP_HEAD
)

Rem カンマありとカンマなしの文字数を比較して、カンマの数をカウント
set /A dq_n=!dqStrlen! - !ndqStrlen!

exit /b
