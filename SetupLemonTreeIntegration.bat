@echo off
rem This Source Code Form is subject to the terms of the Mozilla Public
rem License, v. 2.0. If a copy of the MPL was not distributed with this
rem file, You can obtain one at https://mozilla.org/MPL/2.0/.

echo Registering LemonTree as merge driver for LFS
git config merge.lemontree.name "lemontree merge driver"
git config merge.lemontree.recursive binary
git config merge.lemontree.driver "'C:/Program Files/LieberLieber/LemonTree/LemonTree.Starter.exe' merge --base=\"%%O\" --mine=\"%%A\" --theirs=\"%%B\" --out=\"%%A\""

echo Registering LemonTree as merge tool
git config merge.tool lemontree
git config mergetool.lemontree.cmd "'C:/Program Files/LieberLieber/LemonTree/LemonTree.Starter.exe' merge --base=\"\$BASE\" --mine=\"\$LOCAL\" --theirs=\"\$REMOTE\" --out=\"\$MERGED\""

echo Registering LemonTree as diff driver
git config diff.tool lemontree
git config difftool.lemontree.cmd "'C:/Program Files/LieberLieber/LemonTree/LemonTree.Starter.exe' diff --base=\"\$REMOTE\" --mine=\"\$LOCAL\" --theirs=\"\$REMOTE\""

echo Registration done

pause