#!/bin/sh

export `echo xyz`=abc
echo $xyz
unset xyz

echo $xyz
