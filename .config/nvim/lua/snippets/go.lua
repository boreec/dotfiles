local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

local i = ls.insert_node
local f = ls.function_node

-- Helper function to reuse user-provided struct name
local function repeat_input(args)
    return args[1][1] or ""
end

ls.add_snippets("go", {
    s("setupTestSuite", {
        t({
            'import (',
            '\t"testing"',
            '',
            '\t"github.com/stretchr/testify/suite"',
            ')',
            '',
            'type ',
        }),
        i(1, "MainTestSuite"), -- First input: user provides the struct name
        t({' struct {',
            '\tsuite.Suite',
            '}',
            '',
            'func (suite *',
        }),
        f(repeat_input, {1}), -- Reuse the struct name
        t({') SetupSuite() {',
            '\t// Run before the test suite execution',
            '}',
            '',
            'func (suite *',
        }),
        f(repeat_input, {1}),
        t({') TearDownSuite() {',
            '\t// Run after the test suite execution',
            '}',
            '',
            'func (suite *',
        }),
        f(repeat_input, {1}),
        t({') SetupTest() {',
            '\t// Run before each test case',
            '}',
            '',
            'func (suite *',
        }),
        f(repeat_input, {1}),
        t({') TearDownTest() {',
            '\t// Run after each test case',
            '}',
            '',
            'func (suite *',
        }),
        f(repeat_input, {1}),
        t({') TestMyFunction() {',
            '\t// Unit test for my function',
            '}',
            '',
            'func Test',
        }),
        f(repeat_input, {1}),
        t({'(t *testing.T) {',
            '\t// Run the test suite',
            '\tsuite.Run(t, new('}),
        f(repeat_input, {1}),
        t({'))',
            '}',
        }),
    }),
})
