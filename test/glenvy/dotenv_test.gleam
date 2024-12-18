import envoy
import gleam/dict
import glenvy/dotenv
import simplifile
import startest.{describe, it}
import startest/expect
import test_utils.{reset_env}

pub fn dotenv_nonexistent_file_test() {
  dotenv.load_from(path: "definitely_does_not_exist.env")
  |> expect.to_be_error
  |> expect.to_equal(dotenv.Io(simplifile.Enoent))
}

pub fn dotenv_simple_env_test() {
  reset_env(["KEY", "KEY_2"])

  let assert Ok(Nil) = dotenv.load_from(path: "test/fixtures/simple.env")

  envoy.get("KEY")
  |> expect.to_be_ok
  |> expect.to_equal("1")

  envoy.get("KEY_2")
  |> expect.to_be_ok
  |> expect.to_equal("value")
}

pub fn dotenv_simple_windows_env_test() {
  reset_env(["KEY", "KEY_2"])

  let assert Ok(Nil) =
    dotenv.load_from(path: "test/fixtures/simple_windows.env")

  envoy.get("KEY")
  |> expect.to_be_ok
  |> expect.to_equal("1")

  envoy.get("KEY_2")
  |> expect.to_be_ok
  |> expect.to_equal("value")
}

pub fn dotenv_equals_in_value_env_test() {
  reset_env(["KEY", "TRAILING_EQ", "STARTING_EQ", "KEY_2"])

  let assert Ok(Nil) =
    dotenv.load_from(path: "test/fixtures/equals_in_value.env")

  envoy.get("KEY")
  |> expect.to_be_ok
  |> expect.to_equal("1")

  envoy.get("TRAILING_EQ")
  |> expect.to_be_ok
  |> expect.to_equal("YmFkIHZhbHVlIQ==")

  envoy.get("STARTING_EQ")
  |> expect.to_be_ok
  |> expect.to_equal("=foobar")

  envoy.get("KEY_2")
  |> expect.to_be_ok
  |> expect.to_equal("2")
}

pub fn read_from_tests() {
  describe("glenvy/dotenv", [
    describe("read_from", [
      describe("given a path to a simple .env file", [
        it("returns the environment variables in that file", fn() {
          dotenv.read_from(path: "test/fixtures/simple.env")
          |> expect.to_be_ok
          |> expect.to_equal(
            [#("KEY", "1"), #("KEY_2", "value")]
            |> dict.from_list,
          )
        }),
      ]),
      describe("given a path to .env file with Windows line endings", [
        it("returns the environment variables in that file", fn() {
          dotenv.read_from(path: "test/fixtures/simple_windows.env")
          |> expect.to_be_ok
          |> expect.to_equal(
            [#("KEY", "1"), #("KEY_2", "value")]
            |> dict.from_list,
          )
        }),
      ]),
    ]),
  ])
}
