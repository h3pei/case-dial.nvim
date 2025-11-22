local converter = require("case-dial.converter")

describe("converter", function()
  describe("convert", function()
    -- From snake_case
    describe("from snake_case", function()
      it("should convert to pascal", function()
        assert.are.equal("FooBar", converter.convert("foo_bar", "pascal"))
      end)

      it("should convert to camel", function()
        assert.are.equal("fooBar", converter.convert("foo_bar", "camel"))
      end)

      it("should convert to constant", function()
        assert.are.equal("FOO_BAR", converter.convert("foo_bar", "constant"))
      end)

      it("should convert to kebab", function()
        assert.are.equal("foo-bar", converter.convert("foo_bar", "kebab"))
      end)

      it("should convert to snake (identity)", function()
        assert.are.equal("foo_bar", converter.convert("foo_bar", "snake"))
      end)
    end)

    -- From PascalCase
    describe("from PascalCase", function()
      it("should convert to snake", function()
        assert.are.equal("foo_bar", converter.convert("FooBar", "snake"))
      end)

      it("should convert to camel", function()
        assert.are.equal("fooBar", converter.convert("FooBar", "camel"))
      end)

      it("should convert to constant", function()
        assert.are.equal("FOO_BAR", converter.convert("FooBar", "constant"))
      end)

      it("should convert to kebab", function()
        assert.are.equal("foo-bar", converter.convert("FooBar", "kebab"))
      end)
    end)

    -- From camelCase
    describe("from camelCase", function()
      it("should convert to snake", function()
        assert.are.equal("foo_bar", converter.convert("fooBar", "snake"))
      end)

      it("should convert to pascal", function()
        assert.are.equal("FooBar", converter.convert("fooBar", "pascal"))
      end)

      it("should convert to constant", function()
        assert.are.equal("FOO_BAR", converter.convert("fooBar", "constant"))
      end)

      it("should convert to kebab", function()
        assert.are.equal("foo-bar", converter.convert("fooBar", "kebab"))
      end)
    end)

    -- From CONSTANT_CASE
    describe("from CONSTANT_CASE", function()
      it("should convert to snake", function()
        assert.are.equal("foo_bar", converter.convert("FOO_BAR", "snake"))
      end)

      it("should convert to pascal", function()
        assert.are.equal("FooBar", converter.convert("FOO_BAR", "pascal"))
      end)

      it("should convert to camel", function()
        assert.are.equal("fooBar", converter.convert("FOO_BAR", "camel"))
      end)

      it("should convert to kebab", function()
        assert.are.equal("foo-bar", converter.convert("FOO_BAR", "kebab"))
      end)
    end)

    -- From kebab-case
    describe("from kebab-case", function()
      it("should convert to snake", function()
        assert.are.equal("foo_bar", converter.convert("foo-bar", "snake"))
      end)

      it("should convert to pascal", function()
        assert.are.equal("FooBar", converter.convert("foo-bar", "pascal"))
      end)

      it("should convert to camel", function()
        assert.are.equal("fooBar", converter.convert("foo-bar", "camel"))
      end)

      it("should convert to constant", function()
        assert.are.equal("FOO_BAR", converter.convert("foo-bar", "constant"))
      end)
    end)

    -- Multiple words
    describe("multiple words", function()
      it("should handle three words snake to pascal", function()
        assert.are.equal("FooBarBaz", converter.convert("foo_bar_baz", "pascal"))
      end)

      it("should handle three words pascal to snake", function()
        assert.are.equal("foo_bar_baz", converter.convert("FooBarBaz", "snake"))
      end)

      it("should handle three words camel to constant", function()
        assert.are.equal("FOO_BAR_BAZ", converter.convert("fooBarBaz", "constant"))
      end)
    end)

    -- With numbers
    describe("with numbers", function()
      it("should preserve numbers in conversion", function()
        assert.are.equal("Foo123Bar", converter.convert("foo_123_bar", "pascal"))
      end)

      it("should handle trailing numbers", function()
        assert.are.equal("foo_bar123", converter.convert("fooBar123", "snake"))
      end)
    end)

    -- Edge cases
    describe("edge cases", function()
      it("should return nil for empty string", function()
        assert.is_nil(converter.convert("", "snake"))
      end)

      it("should return nil for nil input", function()
        assert.is_nil(converter.convert(nil, "snake"))
      end)

      it("should return nil for invalid target case", function()
        assert.is_nil(converter.convert("foo_bar", "invalid"))
      end)
    end)

    -- Consecutive uppercase handling
    describe("consecutive uppercase", function()
      it("should handle XMLParser", function()
        assert.are.equal("xml_parser", converter.convert("XMLParser", "snake"))
      end)

      it("should handle parseXMLData", function()
        assert.are.equal("parse_xml_data", converter.convert("parseXMLData", "snake"))
      end)

      it("should handle HTTPSConnection", function()
        assert.are.equal("https_connection", converter.convert("HTTPSConnection", "snake"))
      end)
    end)
  end)

  describe("get_case_types", function()
    it("should return all case types", function()
      local types = converter.get_case_types()
      assert.are.equal(5, #types)
      assert.is_true(vim.tbl_contains(types, "snake"))
      assert.is_true(vim.tbl_contains(types, "pascal"))
      assert.is_true(vim.tbl_contains(types, "camel"))
      assert.is_true(vim.tbl_contains(types, "constant"))
      assert.is_true(vim.tbl_contains(types, "kebab"))
    end)
  end)
end)
