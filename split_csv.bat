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
set nameBefore=�y���ʁz
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

            Rem �f�[�^�̍s�𕪉����Ĕz��Ɋi�[
            for %%g in (%%G) do (
                echo %%g | find """" >NUL
                if not ERRORLEVEL 1 (

                    call :COUNT_DQ %%g

                    set /a dqCount=!dqCount! + !dq_n!
                )
            )

            Rem �J���}����������ꍇ�A�Z�������s�Ȃǂ������Ă���̂ŁA���̍s�܂Ŏ�荞��
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

    Rem �w�b�_�[���͏������s��Ȃ�
    if !loopCount! gtr !numOfHeader! (

        Rem �f�[�^�̍s�𕪉����Ĕz��Ɋi�[
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


        Rem �t�@�C������ݒ�
        if !firstFlag! equ 0 (
            set /a firstFlag=1

            set name=![2]! ![3]!
            set splitFile=!nameBefore!!name!!nameAfter!!fileNum!!extension!
            echo Creating !splitFile! ...

            Rem �w�b�_�[��z�u
            if !numOfHeader! gtr 0 (
                echo !header!>> !batDir!!outDir!!splitFile!
            )
        )

        Rem �f�[�^��}��
        echo %%A>>!batDir!!outDir!!splitFile!

        Rem �J���}����������ꍇ�A�Z�������s�Ȃǂ������Ă���̂ŁA���̍s�܂Ŏ�荞��
        set /a dq_flag=!dqCount!%%2
        if !dq_flag! equ 0 (
          set /a firstFlag=0
          set /a dqCount=0
          set /a lineCounter=!lineCounter! + 1
        )

        Rem �t�@�C���̋�؂肩�𔻒�
        if !lineCounter! gtr !limit! (
            set lineCounter=1
        )

    )

    set /a loopCount=!loopCount!+1

)

pause

Rem "�̐��𐔂���T�u���[�`��
:COUNT_DQ
set dqStr=%1

Rem "�̍폜
set ndqStr=!dqStr:"=!
set dqStrlen=0
set ndqStrlen=0

Rem �J���}����̕��������J�E���g
set s=!dqStr!
:DQ_LOOP_HEAD
if defined s (
set s=%s:~1%
set /A dqStrlen+=1
goto :DQ_LOOP_HEAD
)

Rem �J���}�Ȃ��̕��������J�E���g
set s=!ndqStr!
:NDQ_LOOP_HEAD
if defined s (
set s=%s:~1%
set /A ndqStrlen+=1
goto :NDQ_LOOP_HEAD
)

Rem �J���}����ƃJ���}�Ȃ��̕��������r���āA�J���}�̐����J�E���g
set /A dq_n=!dqStrlen! - !ndqStrlen!

exit /b
