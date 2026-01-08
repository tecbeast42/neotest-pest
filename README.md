# neotest-pest

This plugin provides a [Pest](https://pestphp.com) adapter for the [Neotest](https://github.com/nvim-neotest/neotest) framework.

This is a fork of [V13Axel/neotest-pest](https://github.com/V13Axel/neotest-pest) with Pest v4 support and additional features:

## What's New

### Pest v4 Support

- **Describe blocks** - Full support for `describe()` with both `it()` and `test()` functions
- **Arch testing** - Detection of `arch()->preset()->...` chains (security, laravel, php, etc.)
- **Test name normalization** - Properly matches JUnit XML output to discovered tests

### Improved Diagnostics

- **Inline error display** - Error line numbers are extracted from stack traces and displayed at the correct location
- **Fallback ID matching** - When primary test ID doesn't match, tries normalized variants

### Supported Test Patterns

```php
// Basic tests
test('example test', function () { ... });
it('does something', function () { ... });

// Describe blocks with it()
describe('feature', function () {
    it('works correctly', function () { ... });
});

// Describe blocks with test()
describe('cancel', function () {
    test('guests cannot cancel', function () { ... });
});

// Arch preset tests
arch()->preset()->security();
arch()->preset()->laravel();
arch()->preset()->php();

// Arch with string argument
arch('app namespace')->expect('App')->toBeClasses();

// Pending tests
todo('implement this later');
```

## Installation

Install the plugin using your favorite package manager.

### lazy.nvim

```lua
{
    'nvim-neotest/neotest',
    dependencies = {
        ...,
        'tecbeast42/neotest-pest',
    },
    config = function()
        require('neotest').setup({
            ...,
            adapters = {
                require('neotest-pest'),
            }
        })
    end
}
```

### NixOS / nixvim

```nix
# Custom neotest-pest with Pest v4 support
neotest-pest-v4 = pkgs.vimUtils.buildVimPlugin {
  pname = "neotest-pest";
  version = "unstable";
  src = pkgs.fetchFromGitHub {
    owner = "tecbeast42";
    repo = "neotest-pest";
    rev = "main";
    hash = "sha256-..."; # Use nix flake prefetch to get hash
  };
  dependencies = with pkgs.vimPlugins; [
    neotest
    nvim-nio
    plenary-nvim
  ];
};
```

## Configuration

> [!TIP]
> Any of these options can be set to a lua function that returns the desired result. For example, wanna run tests in parallel, one for each CPU core?
> `parallel = function() return #vim.loop.cpu_info() end,`

```lua
adapters = {
    require('neotest-pest')({
        -- Ignore these directories when looking for tests
        -- -- Default: { "vendor", "node_modules" }
        ignore_dirs = { "vendor", "node_modules" }

        -- Ignore any projects containing "phpunit-only.tests"
        -- -- Default: {}
        root_ignore_files = { "phpunit-only.tests" },

        -- Specify suffixes for files that should be considered tests
        -- -- Default: { "Test.php" }
        test_file_suffixes = { "Test.php", "_test.php", "PestTest.php" },

        -- Sail not properly detected? Explicitly enable it.
        -- -- Default: function() that checks for sail presence
        sail_enabled = function() return false end,

        -- Custom sail executable. Not running in Sail, but running bare Docker?
        -- Set `sail_enabled` = true and `sail_executable` to { "docker", "exec", "[somecontainer]" }
        -- -- Default: "vendor/bin/sail"
        sail_executable = "vendor/bin/sail",

        -- Custom sail project root path.
        -- -- Default: "/var/www/html"
        sail_project_path = "/var/www/html",

        -- Custom pest binary.
        -- -- Default: function that checks for sail presence
        pest_cmd = "vendor/bin/pest",

        -- Run N tests in parallel, <=1 doesn't pass --parallel to pest at all
        -- -- Default: 0
        parallel = 16

        -- Enable ["compact" output printer](https://pestphp.com/docs/optimizing-tests#content-compact-printer)
        -- -- Default: false
        compact = false,

        -- Set a custom path for the results XML file, parsed by this adapter
        --
        ------------------------------------------------------------------------------------
        -- NOTE: This must be a path accessible by both your test runner AND your editor! --
        ------------------------------------------------------------------------------------
        --
        -- -- Default: function that checks for sail presence.
        -- --      - If no sail: Numbered file in randomized /tmp/ directory (using async.fn.tempname())
        -- --      - If sail: "storage/app/" .. os.date("junit-%Y%m%d-%H%M%S")
        results_path = function() "/some/accessible/path" end,
    }),
}
```

## Usage

#### Test single method

To test a single test, hover over the test and run `lua require('neotest').run.run()`.

```lua
vim.keymap.set('n', '<leader>tn', function() require('neotest').run.run() end)
```

#### Test file

To test a file run `lua require('neotest').run.run(vim.fn.expand('%'))`

```lua
vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end)
```

#### Test directory

To test a directory run `lua require('neotest').run.run("path/to/directory")`

#### Test suite

To test the full test suite run `lua require('neotest').run.run({ suite = true })`

## Contributing

Please raise a PR if you are interested in adding new functionality or fixing any bugs. When submitting a bug, please include an example test that I can test against.

To trigger the tests for the adapter, run:

```sh
./scripts/test
```

## Prior Art

This package is a fork of [V13Axel/neotest-pest](https://github.com/V13Axel/neotest-pest), which was forked from [theutz/neotest-pest](https://github.com/theutz/neotest-pest), which relied heavily on [olimorris/neotest-phpunit](https://github.com/olimorris/neotest-phpunit).

The Pest v4 treesitter query fix was adapted from [mmillis1/neotest-pest](https://github.com/mmillis1/neotest-pest).
