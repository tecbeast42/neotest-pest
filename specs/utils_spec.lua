local utils = require("neotest-pest.utils")

describe("get_test_results", function()
    local output_file = "/tmp/nvomhYaIPj/3"

    it("parses output with whole file", function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    _attr = {
                        assertions = "17",
                        errors = "0",
                        failures = "0",
                        name = "",
                        skipped = "0",
                        tests = "7",
                        time = "0.006846",
                        warnings = "0"
                    },
                    testsuite = { {
                        _attr = {
                            assertions = "1",
                            errors = "0",
                            failures = "0",
                            file = "tests/Examples/some/deep/nesting/NestingTest.php",
                            name = "P\\Tests\\Examples\\some\\deep\\nesting\\NestingTest",
                            skipped = "0",
                            tests = "1",
                            time = "0.002344",
                            warnings = "0"
                        },
                        testcase = {
                            _attr = {
                                assertions = "1",
                                class = "Tests\\Examples\\some\\deep\\nesting\\NestingTest",
                                classname = "Tests.Examples.some.deep.nesting.NestingTest",
                                file = "tests/Examples/some/deep/nesting/NestingTest.php",
                                name = "is true",
                                time = "0.002344"
                            }
                        }
                    }, {
                        _attr = {
                            assertions = "15",
                            errors = "0",
                            failures = "0",
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest",
                            skipped = "0",
                            tests = "5",
                            time = "0.004385",
                            warnings = "0"
                        },
                        testcase = { {
                            _attr = {
                                assertions = "3",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "class constructor",
                                time = "0.000941"
                            }
                        }, {
                            _attr = {
                                assertions = "2",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "tellName",
                                time = "0.000494"
                            }
                        }, {
                            _attr = {
                                assertions = "2",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "can tellAge",
                                time = "0.000384"
                            }
                        }, {
                            _attr = {
                                assertions = "3",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "addFavoriteMovie",
                                time = "0.000959"
                            }
                        }, {
                            _attr = {
                                assertions = "5",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "removeFavoriteMovie",
                                time = "0.001608"
                            }
                        } }
                    }, {
                        _attr = {
                            assertions = "1",
                            errors = "0",
                            failures = "0",
                            file = "tests/Unit/ExampleTest.php",
                            name = "P\\Tests\\Unit\\ExampleTest",
                            skipped = "0",
                            tests = "1",
                            time = "0.000116",
                            warnings = "0"
                        },
                        testcase = {
                            _attr = {
                                assertions = "1",
                                class = "Tests\\Unit\\ExampleTest",
                                classname = "Tests.Unit.ExampleTest",
                                file = "tests/Unit/ExampleTest.php",
                                name = "example",
                                time = "0.000116"
                            }
                        }
                    } }
                }
            }
        }

        local expected = {
            ["tests/Examples/some/deep/nesting/NestingTest.php::is true"] = {
                output_file = output_file,
                short = "PASSED | is true",
                status = "passed"
            },
            ["tests/Feature/UserTest.php::addFavoriteMovie"] = {
                output_file = output_file,
                short = "PASSED | addFavoriteMovie",
                status = "passed"
            },
            ["tests/Feature/UserTest.php::can tellAge"] = {
                output_file = output_file,
                short = "PASSED | can tellAge",
                status = "passed"
            },
            ["tests/Feature/UserTest.php::class constructor"] = {
                output_file = output_file,
                short = "PASSED | class constructor",
                status = "passed"
            },
            ["tests/Feature/UserTest.php::removeFavoriteMovie"] = {
                output_file = output_file,
                short = "PASSED | removeFavoriteMovie",
                status = "passed"
            },
            ["tests/Feature/UserTest.php::tellName"] = {
                output_file = output_file,
                short = "PASSED | tellName",
                status = "passed"
            },
            ["tests/Unit/ExampleTest.php::example"] = {
                output_file = output_file,
                short = "PASSED | example",
                status = "passed"
            }
        }

        assert.are.same(utils.get_test_results(xml_output, output_file), expected)
    end)

    it('parses output with single test', function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    _attr = {
                        assertions = "3",
                        errors = "0",
                        failures = "0",
                        name = "tests/Feature/UserTest.php",
                        skipped = "0",
                        tests = "1",
                        time = "0.004366",
                        warnings = "0"
                    },
                    testsuite = {
                        _attr = {
                            assertions = "3",
                            errors = "0",
                            failures = "0",
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest",
                            skipped = "0",
                            tests = "1",
                            time = "0.004366",
                            warnings = "0"
                        },
                        testcase = {
                            _attr = {
                                assertions = "3",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "addFavoriteMovie",
                                time = "0.004366"
                            }
                        }
                    }
                }
            }
        }

        local expected = {
            ["tests/Feature/UserTest.php::addFavoriteMovie"] = {
                output_file = output_file,
                short = "PASSED | addFavoriteMovie",
                status = "passed"
            }
        }

        assert.are.same(utils.get_test_results(xml_output, output_file), expected)
    end)

    it('parses output with a single failing test', function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    _attr = {
                        assertions = "1",
                        errors = "0",
                        failures = "1",
                        name = "",
                        skipped = "0",
                        tests = "1",
                        time = "0.004215",
                        warnings = "0"
                    },
                    testsuite = {
                        _attr = {
                            assertions = "1",
                            errors = "0",
                            failures = "1",
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest",
                            skipped = "0",
                            tests = "1",
                            time = "0.004215",
                            warnings = "0"
                        },
                        testcase = {
                            _attr = {
                                assertions = "1",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "is false",
                                time = "0.004215"
                            },
                            failure = { "tests/Feature/UserTest.php::it is false\nFailed asserting that true is false.\n\ntests/Feature/UserTest.php:39\nvendor/pestphp/pest/src/Expectation.php:316\nvendor/pestphp/pest/src/Support/Reflection.php:38\nvendor/pestphp/pest/src/Support/HigherOrderMessage.php:96\nvendor/pestphp/pest/src/Support/HigherOrderMessageCollection.php:43\nvendor/pestphp/pest/src/Factories/TestCaseFactory.php:148\nvendor/pestphp/pest/src/Concerns/Testable.php:302\nvendor/pestphp/pest/src/Support/ExceptionTrace.php:29\nvendor/pestphp/pest/src/Concerns/Testable.php:303\nvendor/pestphp/pest/src/Concerns/Testable.php:279\nvendor/pestphp/pest/src/Console/Command.php:119\nvendor/pestphp/pest/bin/pest:62\nvendor/pestphp/pest/bin/pest:63",
                                _attr = {
                                    type = "PHPUnit\\Framework\\ExpectationFailedException"
                                }
                            }
                        }
                    }
                }
            }
        }

        local message = "tests/Feature/UserTest.php::it is false\nFailed asserting that true is false.\n\ntests/Feature/UserTest.php:39\nvendor/pestphp/pest/src/Expectation.php:316\nvendor/pestphp/pest/src/Support/Reflection.php:38\nvendor/pestphp/pest/src/Support/HigherOrderMessage.php:96\nvendor/pestphp/pest/src/Support/HigherOrderMessageCollection.php:43\nvendor/pestphp/pest/src/Factories/TestCaseFactory.php:148\nvendor/pestphp/pest/src/Concerns/Testable.php:302\nvendor/pestphp/pest/src/Support/ExceptionTrace.php:29\nvendor/pestphp/pest/src/Concerns/Testable.php:303\nvendor/pestphp/pest/src/Concerns/Testable.php:279\nvendor/pestphp/pest/src/Console/Command.php:119\nvendor/pestphp/pest/bin/pest:62\nvendor/pestphp/pest/bin/pest:63"

        local expected = {
            ["tests/Feature/UserTest.php::is false"] = {
                errors = { { message = message, line = 38 } }, -- 0-indexed from tests/Feature/UserTest.php:39
                output_file = output_file,
                status = "failed",
                short = "FAILED | is false\n\n" .. message
            }
        }

        local results = utils.get_test_results(xml_output, output_file)
        local key = "tests/Feature/UserTest.php::is false"

        assert.are.same(results[key].errors[1].message, expected[key].errors[1].message)
        assert.are.same(results, expected)
    end)

    it('parses output with errors', function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    _attr = {
                        assertions = "0",
                        errors = "1",
                        failures = "0",
                        name = "",
                        skipped = "0",
                        tests = "1",
                        time = "0.002610",
                        warnings = "0"
                    },
                    testsuite = {
                        _attr = {
                            assertions = "0",
                            errors = "1",
                            failures = "0",
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest",
                            skipped = "0",
                            tests = "1",
                            time = "0.002610",
                            warnings = "0"
                        },
                        testcase = {
                            _attr = {
                                assertions = "0",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "tellName",
                                time = "0.002610"
                            },
                            error = { "tests/Feature/UserTest.php::tellName\nException: Oops!\n\ntests/Feature/UserTest.php:24\nvendor/pestphp/pest/src/Factories/TestCaseFactory.php:151\nvendor/pestphp/pest/src/Concerns/Testable.php:302\nvendor/pestphp/pest/src/Support/ExceptionTrace.php:29\nvendor/pestphp/pest/src/Concerns/Testable.php:303\nvendor/pestphp/pest/src/Concerns/Testable.php:279\nvendor/pestphp/pest/src/Console/Command.php:119\nvendor/pestphp/pest/bin/pest:62\nvendor/pestphp/pest/bin/pest:63",
                                _attr = {
                                    type = "Exception"
                                }
                            }
                        }
                    }
                }
            }
        }

        local message = "tests/Feature/UserTest.php::tellName\nException: Oops!\n\ntests/Feature/UserTest.php:24\nvendor/pestphp/pest/src/Factories/TestCaseFactory.php:151\nvendor/pestphp/pest/src/Concerns/Testable.php:302\nvendor/pestphp/pest/src/Support/ExceptionTrace.php:29\nvendor/pestphp/pest/src/Concerns/Testable.php:303\nvendor/pestphp/pest/src/Concerns/Testable.php:279\nvendor/pestphp/pest/src/Console/Command.php:119\nvendor/pestphp/pest/bin/pest:62\nvendor/pestphp/pest/bin/pest:63"

        local expected = {
            ["tests/Feature/UserTest.php::tellName"] = {
                errors = { { message = message, line = 23 } }, -- 0-indexed from tests/Feature/UserTest.php:24
                output_file = output_file,
                status = "failed",
                short = "ERROR | tellName\n\n" .. message

            }
        }

        assert.are.same(utils.get_test_results(xml_output, output_file), expected)
    end)

    it('parses output with skipped tests', function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    _attr = {
                        assertions = "0",
                        errors = "0",
                        failures = "0",
                        name = "",
                        skipped = "1",
                        tests = "1",
                        time = "0.001544",
                        warnings = "0"
                    },
                    testsuite = {
                        _attr = {
                            assertions = "0",
                            errors = "0",
                            failures = "0",
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest",
                            skipped = "1",
                            tests = "1",
                            time = "0.001544",
                            warnings = "0"
                        },
                        testcase = {
                            _attr = {
                                assertions = "0",
                                class = "Tests\\Feature\\UserTest",
                                classname = "Tests.Feature.UserTest",
                                file = "tests/Feature/UserTest.php",
                                name = "skipped",
                                time = "0.001544"
                            },
                            skipped = {}
                        }
                    }
                }
            }
        }

        local expected = {
            ["tests/Feature/UserTest.php::skipped"] = {
                output_file = output_file,
                short = "SKIPPED | skipped",
                status = "skipped"
            }
        }

        assert.are.same(utils.get_test_results(xml_output, output_file), expected)
    end)
end)

describe("normalize_test_name", function()
    it("handles simple names", function()
        assert.are.equal("example", utils.normalize_test_name("example"))
    end)

    it("removes 'it ' prefix", function()
        assert.are.equal("is true", utils.normalize_test_name("it is true"))
    end)

    it("removes arrow context with ->", function()
        assert.are.equal("update", utils.normalize_test_name("update -> rejects update that would overlap"))
    end)

    it("removes unicode arrow context", function()
        assert.are.equal("update", utils.normalize_test_name("update → rejects overlapping"))
    end)

    it("removes dataset parameters with single quotes", function()
        assert.are.equal("validates email", utils.normalize_test_name("validates email with 'test@example.com'"))
    end)

    it("removes dataset parameters with double quotes", function()
        assert.are.equal("validates email", utils.normalize_test_name('validates email with "test@example.com"'))
    end)

    it("handles complex describe + it pattern", function()
        assert.are.equal("performs sum", utils.normalize_test_name("it performs sum -> with positive numbers"))
    end)

    it("trims trailing whitespace", function()
        assert.are.equal("test name", utils.normalize_test_name("test name   "))
    end)
end)

describe("generate_id_variants", function()
    it("generates normalized variant", function()
        local variants = utils.generate_id_variants(
            "tests/Feature/UserTest.php",
            "update -> rejects update that would overlap"
        )
        assert.is_true(vim.tbl_contains(variants, "tests/Feature/UserTest.php::update"))
    end)

    it("generates variant for it prefix", function()
        local variants = utils.generate_id_variants(
            "tests/Feature/UserTest.php",
            "it is true"
        )
        assert.is_true(vim.tbl_contains(variants, "tests/Feature/UserTest.php::is true"))
    end)
end)

describe("extract_error_line", function()
    it("extracts line from direct file:line reference", function()
        local message = "tests/Feature/UserTest.php::it is false\nFailed asserting that true is false.\n\ntests/Feature/UserTest.php:39"
        local line = utils.extract_error_line(message, "tests/Feature/UserTest.php")
        assert.are.equal(38, line) -- 0-indexed
    end)

    it("returns nil when no line found", function()
        local message = "Some error without line numbers"
        local line = utils.extract_error_line(message, "tests/Feature/UserTest.php")
        assert.is_nil(line)
    end)

    it("handles nil message gracefully", function()
        local line = utils.extract_error_line(nil, "tests/Feature/UserTest.php")
        assert.is_nil(line)
    end)
end)

describe("get_test_results with Pest v4 naming", function()
    local output_file = "/tmp/test-results"

    it("matches describe block tests via normalization", function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    testsuite = {
                        _attr = {
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest"
                        },
                        testcase = {
                            _attr = {
                                file = "tests/Feature/UserTest.php",
                                name = "update -> rejects update that would overlap with other entry"
                            }
                        }
                    }
                }
            }
        }

        local results = utils.get_test_results(xml_output, output_file)
        -- Should create ID with normalized name
        assert.is_not_nil(results["tests/Feature/UserTest.php::update"])
        assert.are.equal("passed", results["tests/Feature/UserTest.php::update"].status)
    end)

    it("includes line numbers in error results", function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    testsuite = {
                        _attr = {
                            file = "tests/Feature/UserTest.php",
                            name = "P\\Tests\\Feature\\UserTest"
                        },
                        testcase = {
                            _attr = {
                                file = "tests/Feature/UserTest.php",
                                name = "is false"
                            },
                            failure = {
                                "tests/Feature/UserTest.php::it is false\nFailed asserting that true is false.\n\ntests/Feature/UserTest.php:39",
                                _attr = { type = "PHPUnit\\Framework\\ExpectationFailedException" }
                            }
                        }
                    }
                }
            }
        }

        local results = utils.get_test_results(xml_output, output_file)
        local result = results["tests/Feature/UserTest.php::is false"]
        assert.is_not_nil(result)
        assert.are.equal("failed", result.status)
        assert.is_not_nil(result.errors)
        assert.are.equal(38, result.errors[1].line) -- 0-indexed
    end)
end)

describe("arch test result parsing", function()
    local output_file = "/tmp/test-arch-results"

    it("parses arch preset test results with arrow naming", function()
        -- Pest outputs arch()->preset()->security() as "preset → security"
        local xml_output = {
            testsuites = {
                testsuite = {
                    testsuite = {
                        _attr = {
                            file = "tests/Feature/ArchTest.php",
                            name = "P\\Tests\\Feature\\ArchTest"
                        },
                        testcase = {
                            _attr = {
                                file = "tests/Feature/ArchTest.php::preset → security",
                                name = "preset → security"
                            }
                        }
                    }
                }
            }
        }

        local results = utils.get_test_results(xml_output, output_file)
        -- The normalized name should strip the arrow context
        assert.is_not_nil(results["tests/Feature/ArchTest.php::preset"])
        assert.are.equal("passed", results["tests/Feature/ArchTest.php::preset"].status)
    end)

    it("parses arch preset test with multiple chained methods", function()
        -- Pest outputs arch()->preset()->laravel()->ignoring() chains
        local xml_output = {
            testsuites = {
                testsuite = {
                    testsuite = {
                        _attr = {
                            file = "tests/Feature/ArchTest.php",
                            name = "P\\Tests\\Feature\\ArchTest"
                        },
                        testcase = {
                            _attr = {
                                file = "tests/Feature/ArchTest.php::preset → laravel → ignoring 'App\\Models\\Model'",
                                name = "preset → laravel → ignoring 'App\\Models\\Model'"
                            }
                        }
                    }
                }
            }
        }

        local results = utils.get_test_results(xml_output, output_file)
        -- The normalized name should strip everything after first arrow
        assert.is_not_nil(results["tests/Feature/ArchTest.php::preset"])
        assert.are.equal("passed", results["tests/Feature/ArchTest.php::preset"].status)
    end)

    it("parses failed arch test with error details", function()
        local xml_output = {
            testsuites = {
                testsuite = {
                    testsuite = {
                        _attr = {
                            file = "tests/Feature/ArchTest.php",
                            name = "P\\Tests\\Feature\\ArchTest"
                        },
                        testcase = {
                            _attr = {
                                file = "tests/Feature/ArchTest.php::preset → laravel",
                                name = "preset → laravel"
                            },
                            failure = {
                                "Expecting 'app/Http/Controllers/MyController.php' not to have public methods...\n\napp/Http/Controllers/MyController.php:42",
                                _attr = { type = "Pest\\Arch\\Exceptions\\ArchExpectationFailedException" }
                            }
                        }
                    }
                }
            }
        }

        local results = utils.get_test_results(xml_output, output_file)
        local result = results["tests/Feature/ArchTest.php::preset"]
        assert.is_not_nil(result)
        assert.are.equal("failed", result.status)
        assert.is_not_nil(result.errors)
        assert.is_not_nil(result.errors[1].message)
    end)
end)

-- NOTE: Treesitter discovery limitations
-- The following arch() patterns are NOT detected by treesitter discovery:
--   arch()->preset()->security()
--   arch()->preset()->laravel()->ignoring(...)
--   arch()->expect('App\\Models')->...
--
-- Only arch('description', function() {...}) with a string argument is detected.
-- This is a known limitation because treesitter cannot match arbitrary-depth
-- method chains. These tests will run when executing the whole file but won't
-- appear individually in the neotest summary.
-- vim: fdm=indent fdl=2
