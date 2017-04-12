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
set name_before=【結果】
set name_after=_2017209
set extension=.csv
set zeroPadding=2



Rem ------------------------------
Rem Start process ...
Rem ------------------------------
set lineCounter=1
set header=
set NLM=^


rem Two empty lines are required here

if !numOfHeader! gtr 0 (
    set headerCounter=1
    for /f "tokens=* delims=: eol= usebackq" %%G in (%file%) do (
        if !numOfHeader! geq !headerCounter! (
            if !headerCounter! equ 1 (
                set header=%%G
            ) else (
                set header=!header!!NLM!%%G
            )

            set /a headerCounter=!headerCounter! + 1
        ) 
        if !headerCounter! gtr !numOfHeader! ( 
            goto :next
        )
    )
)

:next

set /a loopCount=1

for /f "tokens=* delims=: eol= usebackq" %%A in (%file%) do ( 

    Rem ヘッダー分は処理を行わない
    if !loopCount! gtr !numOfHeader! (

        Rem データの行を分解して配列に格納
        set n=
        for %%a in (%%A) do (
            set /a n=n+1
            set [!n!]=%%a
        )

        Rem ファイル名を設定
        if !lineCounter! equ 1 (
            set name=![2]! ![3]!
            set splitFile=!name_before!!name!!name_after!!fileNum!!extension!
            echo Creating !splitFile! ...
        )

        Rem ヘッダーを配置
        if !numOfHeader! gtr 0 (
            if !lineCounter! equ 1 (
                echo !header!>> !splitFile!
            )
        )

        Rem データを挿入
        echo %%A>> !splitFile!

        set /a lineCounter=!lineCounter! + 1


        Rem ファイルの区切りかを判定
        if !lineCounter! gtr !limit! (
            set lineCounter=1
        )

    )

    set /a loopCount=!loopCount!+1

)

pause