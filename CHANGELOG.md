# Changelog

## [1.0.1](https://github.com/tris203/hawtkeys.nvim/compare/v1.0.0...v1.0.1) (2023-12-24)


### Bug Fixes

* HawtKeysAll highlights bug ([#52](https://github.com/tris203/hawtkeys.nvim/issues/52)) ([57d0b0e](https://github.com/tris203/hawtkeys.nvim/commit/57d0b0e3c7f93f47c9b9f94da59bdc7403decb27))

## 1.0.0 (2023-12-23)


### ⚠ BREAKING CHANGES

* lazy keymap support ([#41](https://github.com/tris203/hawtkeys.nvim/issues/41))
* Usercommands/Remove default keymaps ([#2](https://github.com/tris203/hawtkeys.nvim/issues/2))

### Features

* add default key mapping &lt;leader&gt;hwt ([ca02dfa](https://github.com/tris203/hawtkeys.nvim/commit/ca02dfa9984efad622af79ced05045adc7f71223))
* add excludeAlreadyMapped flag ([808651a](https://github.com/tris203/hawtkeys.nvim/commit/808651a05bd77cc908cafb9793e5a290c79bd63c))
* add highlighting ([#3](https://github.com/tris203/hawtkeys.nvim/issues/3)) ([f1155c8](https://github.com/tris203/hawtkeys.nvim/commit/f1155c8e4e87c73724291f3fac71e8dcf39b421f))
* add hint to search prompt ([#29](https://github.com/tris203/hawtkeys.nvim/issues/29)) ([dedcf53](https://github.com/tris203/hawtkeys.nvim/commit/dedcf53dc257b902e767319a8cd03b3c62a621fb))
* add keymap to config ([5507afe](https://github.com/tris203/hawtkeys.nvim/commit/5507afe0f4312ca99d0a637a822c62dca438d2c6))
* add types ([8351b34](https://github.com/tris203/hawtkeys.nvim/commit/8351b341b7c555770895a35cb98a063f2596c8f1))
* begining of UI ([0d5d8bb](https://github.com/tris203/hawtkeys.nvim/commit/0d5d8bb901cc3e31dd9a9d6f9f2b16c146899cbf))
* cleaner 'all' menu with extmarks and nice mode lists ([#25](https://github.com/tris203/hawtkeys.nvim/issues/25)) ([39f4f96](https://github.com/tris203/hawtkeys.nvim/commit/39f4f962cea8dd31dad0dcb6d78582429d7f8d6c))
* dupes UI refresh ([#44](https://github.com/tris203/hawtkeys.nvim/issues/44)) ([e9d3afc](https://github.com/tris203/hawtkeys.nvim/commit/e9d3afc651ae0003bb82cc20f41ccad662eec6f6))
* duplicate checks ([74132a6](https://github.com/tris203/hawtkeys.nvim/commit/74132a6f36ff1e9bc3b44bba98c1e2c2c6501696))
* exclude already mapped keys from return ([d7f20ee](https://github.com/tris203/hawtkeys.nvim/commit/d7f20ee6833af7ad515edf601c450f7c3193869c))
* highlight search matches and search result score ([#31](https://github.com/tris203/hawtkeys.nvim/issues/31)) ([d56ec52](https://github.com/tris203/hawtkeys.nvim/commit/d56ec52f4b3c597d5f57a625f0b8e063782ab7ad))
* lazy keymap support ([#41](https://github.com/tris203/hawtkeys.nvim/issues/41)) ([c6705da](https://github.com/tris203/hawtkeys.nvim/commit/c6705da0a8c8ceddfa754f3e00c12e517bd421cc))
* lhs blacklists ([#34](https://github.com/tris203/hawtkeys.nvim/issues/34)) ([ce9dac1](https://github.com/tris203/hawtkeys.nvim/commit/ce9dac1ee66cb04ff83975c400247f35695ce6f1))
* make search prompt border seamless ([#32](https://github.com/tris203/hawtkeys.nvim/issues/32)) ([2ecef6f](https://github.com/tris203/hawtkeys.nvim/commit/2ecef6f2ed3ab127a7e620766abe5d2bc57b867b))
* remove alreadyMapped flag ([98c6b81](https://github.com/tris203/hawtkeys.nvim/commit/98c6b812f38639f9d251ce9f7fc6096b08c355be))
* start show all, and treesitter search ([ce5edce](https://github.com/tris203/hawtkeys.nvim/commit/ce5edce08da82ed1c00d64b68ca096ae94042ec0))
* testing and configurable iterative mapping ([dae77e1](https://github.com/tris203/hawtkeys.nvim/commit/dae77e1262bf1ddc05d0a90a9b837e59a15d09e8))
* use vim map description if rhs isn't available ([#28](https://github.com/tris203/hawtkeys.nvim/issues/28)) ([f2e85f8](https://github.com/tris203/hawtkeys.nvim/commit/f2e85f818c1df22e970b47dc35e21d24b525e629))
* Usercommands/Remove default keymaps ([#2](https://github.com/tris203/hawtkeys.nvim/issues/2)) ([dcb4f35](https://github.com/tris203/hawtkeys.nvim/commit/dcb4f35dcdc2a20a9697030c3f9ab7ce78e93e0c))


### Bug Fixes

* add augroup ([#43](https://github.com/tris203/hawtkeys.nvim/issues/43)) ([1451dcd](https://github.com/tris203/hawtkeys.nvim/commit/1451dcd4b74f6efd14f44da0ff80791ffe76660d))
* add dynamic updates ([f24266d](https://github.com/tris203/hawtkeys.nvim/commit/f24266d67f44a6c1eed4a0c339ce47b741e9e7f2))
* add keymap caching ([#1](https://github.com/tris203/hawtkeys.nvim/issues/1)) ([5554fc1](https://github.com/tris203/hawtkeys.nvim/commit/5554fc1899e6229ba960c9b64b053ab414d7044f))
* add missing space to ui rendering ([#38](https://github.com/tris203/hawtkeys.nvim/issues/38)) ([f400cb0](https://github.com/tris203/hawtkeys.nvim/commit/f400cb0b94bde43bb59f221fb1f5ccba40b374ff))
* cache for search ([bb133c5](https://github.com/tris203/hawtkeys.nvim/commit/bb133c545e6eb056425badb5fe0ab34056536e89))
* check for `buffer = ...` in treesitter key search ([0605496](https://github.com/tris203/hawtkeys.nvim/commit/0605496e2cfa3ae0475086ec0ec315c5e1185a13))
* **ci:** create empty doc file for docgen ([#48](https://github.com/tris203/hawtkeys.nvim/issues/48)) ([4471de6](https://github.com/tris203/hawtkeys.nvim/commit/4471de64333242afdd05869e05d8d548e42c6dea))
* dont cache as aggressively ([#20](https://github.com/tris203/hawtkeys.nvim/issues/20)) ([01625e1](https://github.com/tris203/hawtkeys.nvim/commit/01625e15e31568cc247f5b16902cb50d3b245e64))
* **duplicates:** fix data shape ([#37](https://github.com/tris203/hawtkeys.nvim/issues/37)) ([683e163](https://github.com/tris203/hawtkeys.nvim/commit/683e163909dba3247775f581d9897c540d8245b1))
* formatting ([59b202b](https://github.com/tris203/hawtkeys.nvim/commit/59b202b5d6272844e8326016f3a74be07c276480))
* readme ([4ceec64](https://github.com/tris203/hawtkeys.nvim/commit/4ceec649f2a82f8c9afe3b056b521480a1745596))
* readme ([64a3da7](https://github.com/tris203/hawtkeys.nvim/commit/64a3da7bdaf136c9f5029ed743c357036d6f4ec1))
* ts scan optimisations ([#6](https://github.com/tris203/hawtkeys.nvim/issues/6)) ([2a73379](https://github.com/tris203/hawtkeys.nvim/commit/2a7337983fbf5d2ba4492cac3c6ae5120b7f2f30))
* **utils:** capitalization in comparison of defaults ([#40](https://github.com/tris203/hawtkeys.nvim/issues/40)) ([eccd881](https://github.com/tris203/hawtkeys.nvim/commit/eccd881d10a1b9f12383ea6e64adc63c4ad5da18))
