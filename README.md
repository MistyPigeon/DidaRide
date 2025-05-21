# DidaRide

A Java-based project that lets you write and run scripts/projects in Perl, Lua, and Kotlin.

## Features

- Java CLI tool to run scripts in Perl (`perl_projects`), Lua (`lua_projects`), and Kotlin (`kotlin_proj`)
- Add your own files to the appropriate folder
- Example scripts for each language

## Requirements

- Java 11+ (to run this project)
- Perl, Lua, and Kotlin compilers/interpreters installed and available in your PATH

## Usage

1. Build the project (using Maven or your preferred method).
2. Add your scripts to the corresponding folder:
    - Perl: `perl_projects/`
    - Lua: `lua_projects/`
    - Kotlin: `kotlin_proj/`
3. Run the Java CLI:
    ```
    java -cp target/classes com.example.MultiLangRunner
    ```
4. Follow the prompts to select a language and provide your filename.

## Example

To run the example Perl script:
- Select `perl` as language
- Enter `hello.pl` as filename

Same for Lua (`hello.lua`) and Kotlin (`Hello.kt`).

## Notes

- For Kotlin, your `.kt` file should have a `main` function.
- The script runner assumes the interpreters/compilers are in your PATH.
