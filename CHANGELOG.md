# mingw Cookbook CHANGELOG

This file is used to list changes made in each version of the mingw cookbook.

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
