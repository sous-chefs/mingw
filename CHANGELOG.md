# mingw Cookbook CHANGELOG

This file is used to list changes made in each version of the mingw cookbook.

## v1.2.2 (2016-06-24)
- Download msys2 from the primary download url (instead of a specific mirror).

## v1.2.1 (2016-06-23)
- Fix msys2 initial install/upgrade steps that dependended on file modification time.
- Make msys2_package :install idempotent - it should not reinstall packages.
- Do not allow bash.exe to be called if MSYSTEM is undefined.

## v1.2.0 (2016-06-03)
- Updating to fix the issue where msys2 bash does not inherit the cwd correctly

## v1.1.0 (2016-06-03)
- Add msys2 based compiler support using the new msys2_package resource

## v1.0.0 (2016-05-11)

- Remove unnecessary default_action from the resources
- Depend on compat_resource cookbook to add Chef 12.1 - 12.4 compatbility
- Add this changelog file
- Fix license metadata in metadata.rb
- Disable FC016 check
