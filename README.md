# mingw Cookbook

Installs MinGW / MSYS2 / TDM-GCC compiler toolchains on Windows. Use it to bootstrap a C/C++ build environment for software that needs to be compiled from source.

## Requirements

### Platforms

- Windows Server 2019, 2022, 2025 (or equivalent client SKUs)

### Chef

- Chef Infra Client 16+

### Cookbooks

None.

## Upgrading from 4.x

The 4.x line shipped a `mingw::default` recipe and `node['msys2']` attributes. Both have been removed in favor of resource properties. See [migration.md](./migration.md) for a step-by-step upgrade guide.

## Usage

Add the cookbook as a dependency:

```ruby
# metadata.rb
depends 'mingw'
```

Then call any of the resources from your own recipes — there is no recipe to include.

```ruby
# your recipe.rb
msys2_package 'base-devel' do
  root 'C:\msys2'
end
```

By default, prefer the MSYS2 packages: they are newer and better supported.

C/C++ compilers on Windows use different exception formats and you need to pick the one your build expects. In 32-bit, you have SJLJ (set-jump/long-jump) and DWARF-2 (DW2). SJLJ can throw across MSVC-built stack frames; DW2 cannot. Some toolchains require a specific format — for example, Rust needs a modern gcc from MSYS2 with DW2. In 64-bit you can still use SJLJ but compilers commonly support SEH (structured exception handling) too.

The compilers shipped via `mingw_get` are 32-bit DW2. TDM-GCC ships in three flavors: 32-bit SJLJ, 32-bit DW2, and a multi-lib that builds 64-bit SEH and 32-bit SJLJ. MSYS2 lets you install mingw-w64 toolchains for either 32-bit DW2 or 64-bit SEH.

## Resources

- [mingw_get](./documentation/mingw_get.md)
- [mingw_tdm_gcc](./documentation/mingw_tdm_gcc.md)
- [msys2_package](./documentation/msys2_package.md)

## License & Authors

**Author:** Sous Chefs ([help@sous-chefs.org](mailto:help@sous-chefs.org))

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
