local detector = require("case-dial.detector")

describe("detector", function()
  describe("detect", function()
    -- snake_case tests
    describe("snake_case", function()
      it("should detect simple snake_case", function()
        assert.are.equal("snake", detector.detect("foo_bar"))
      end)

      it("should detect snake_case with numbers", function()
        assert.are.equal("snake", detector.detect("foo_bar_123"))
      end)

      it("should detect snake_case with multiple underscores", function()
        assert.are.equal("snake", detector.detect("foo_bar_baz"))
      end)
    end)

    -- PascalCase tests
    describe("PascalCase", function()
      it("should detect simple PascalCase", function()
        assert.are.equal("pascal", detector.detect("FooBar"))
      end)

      it("should detect PascalCase with numbers", function()
        assert.are.equal("pascal", detector.detect("FooBar123"))
      end)

      it("should detect PascalCase with multiple words", function()
        assert.are.equal("pascal", detector.detect("FooBarBaz"))
      end)
    end)

    -- camelCase tests
    describe("camelCase", function()
      it("should detect simple camelCase", function()
        assert.are.equal("camel", detector.detect("fooBar"))
      end)

      it("should detect camelCase with numbers", function()
        assert.are.equal("camel", detector.detect("fooBar123"))
      end)

      it("should detect camelCase with multiple words", function()
        assert.are.equal("camel", detector.detect("fooBarBaz"))
      end)
    end)

    -- CONSTANT_CASE tests
    describe("CONSTANT_CASE", function()
      it("should detect simple CONSTANT_CASE", function()
        assert.are.equal("constant", detector.detect("FOO_BAR"))
      end)

      it("should detect CONSTANT_CASE with numbers", function()
        assert.are.equal("constant", detector.detect("FOO_BAR_123"))
      end)

      it("should detect CONSTANT_CASE with multiple underscores", function()
        assert.are.equal("constant", detector.detect("FOO_BAR_BAZ"))
      end)
    end)

    -- kebab-case tests
    describe("kebab-case", function()
      it("should detect simple kebab-case", function()
        assert.are.equal("kebab", detector.detect("foo-bar"))
      end)

      it("should detect kebab-case with numbers", function()
        assert.are.equal("kebab", detector.detect("foo-bar-123"))
      end)

      it("should detect kebab-case with multiple dashes", function()
        assert.are.equal("kebab", detector.detect("foo-bar-baz"))
      end)
    end)

    -- Invalid cases (single word or unknown)
    describe("invalid cases", function()
      it("should return unknown for single word lowercase", function()
        assert.are.equal("unknown", detector.detect("foo"))
      end)

      it("should return unknown for single word uppercase", function()
        assert.are.equal("unknown", detector.detect("FOO"))
      end)

      it("should return unknown for single word capitalized", function()
        assert.are.equal("unknown", detector.detect("Foo"))
      end)

      it("should return unknown for empty string", function()
        assert.are.equal("unknown", detector.detect(""))
      end)

      it("should return unknown for nil", function()
        assert.are.equal("unknown", detector.detect(nil))
      end)

      it("should return unknown for string with spaces", function()
        assert.are.equal("unknown", detector.detect("foo bar"))
      end)

      it("should return unknown for string with special characters", function()
        assert.are.equal("unknown", detector.detect("foo@bar"))
      end)
    end)
  end)

  describe("is_valid_target", function()
    it("should return true for valid snake_case", function()
      assert.is_true(detector.is_valid_target("foo_bar"))
    end)

    it("should return true for valid camelCase", function()
      assert.is_true(detector.is_valid_target("fooBar"))
    end)

    it("should return false for single word", function()
      assert.is_false(detector.is_valid_target("foo"))
    end)

    it("should return false for empty string", function()
      assert.is_false(detector.is_valid_target(""))
    end)
  end)
end)
