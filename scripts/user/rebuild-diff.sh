#!/usr/bin/env bash
nix store diff-closures /run/booted-system /run/current-system
