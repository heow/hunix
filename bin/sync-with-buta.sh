#!/bin/bash
pushd ~/.hunix/bin
git-pull heow@buta:/home/heow/bin master
popd

pushd ~/.hunix/etc
git-pull heow@buta:/home/heow/etc master
popd

pushd ~/prj-personal/doc-wiki
git-pull heow@buta:/home/heow/prj-personal/doc-wiki master
popd

pushd ~/prj-work/doc-wiki
git-pull heow@buta:/home/heow/prj-work/doc-wiki master
popd
