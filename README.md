```
Command
    cli

Global Arguments
    --help -h        [Flag] : Show this message and exit.
    --self-test      [Flag] : Runs a self test.

Attributes
    version 0.1.0
    licence MIT
    description Command Line Tool loader.

Environment Variables
    CLI_COMMAND=

    CLI_META_
```

# Environment Variables
A command executes in an environment. The environment is defined by a set of variables prefixed with `CLI`. The set is divided into mutable [Frame Variables](#frame-variables) and immutable [Backing Variables](#backing-variables).

## Summary
The following lists all environment variables. Examples are for the command line `cli sample kitchen-sink --help`.

CLI Type | Bash Type | Name | Description
--- | --- | --- | ---
[Constant](#constant-variables) | string | [CLI_IFS](#cliifs) | Original IFS value
[Frame](#frame-variables) | array | [CLI_COMMAND](#clicommand) | Full command name
[Frame](#frame-variables) | string | [CLI_NAME](#clicommandname) | Command name
[Frame](#frame-variables) | string | [CLI_TOOL](#cliname) | Tool name
[Frame](#frame-variables) | string | [CLI_GROUP](#cligroup) | Parent group full name
[Metadata](#frame-metadata-variables) | string | [CLI_META](#climeta) | Metadata harvested from help |
[Metadata](#frame-metadata-variables) | string | [CLI_TYPE](#clitype) | Type; `command`, `inline`, or `group`
[Metadata](#frame-metadata-variables) | string | [CLI_SOURCE](#clisource) | Path to command source file
[Metadata](#frame-metadata-variables) | string | [CLI_CACHE](#clicache) | Path to command cache directory
[Metadata](#frame-metadata-variables) | string | [CLI_FUNCTION_MAIN](#clifunctionmain) | Command main function name
[Metadata](#frame-metadata-variables) | string | [CLI_FUNCTION_INLINE](#clifunctioninline) | Command inline function name
[Metadata](#frame-metadata-variables) | string | [CLI_FUNCTION_SELF_TEST](#clifunctionselftest) | Command self-test function name
[Metadata](#frame-metadata-variables) | string | [CLI_FUNCTION_HELP](#clifunctionhelp) | Command help function name
[Metadata](#frame-metadata-variables) | array | [CLI_IMPORT](#cliimport) | Imported commands |
[Metadata](#frame-metadata-variables) | string | [CLI_SYMBOL](#clisymbol) | Backing metadata variable name prefix |

## Constant Variables

### `CLI_IFS`

## Frame Variables
Frame variables are mutable bash variables that provide information about the command being executed. 


### `CLI_COMMAND` 
The portion of the command line that is the path to the command. 

For example, if the command line is `cli list --help`, the the command is `cli list`.

### `CLI_NAME` 
The portion of the command line that identifies the command name. 

For example, if the command line is `cli list --help`, then the command name is `list`.

### `CLI_TOOL` 
The portion of the command line that is the name of the cli tool. 

For example, if the command line is `cli list --help`, then the name is `cli`.

### `CLI_GROUP` 
The portion of the command line that identifies the command group. 

For example, if the command line is `cli temp file --help`, then the group is `cli temp`.

## Frame Metadata Variables
Frame variables are mutable bash variables that provide information about the command being executed. Frame metadata variables reference an immutable [backing variables](#backing-variables). 

If a command calls another command then, the loader will update the frame metadata variable references to the corresponding backing variables for the called command.

### `CLI_META`

### `CLI_TYPE` 
The type of the command. Valid types are:
- `command`
- `inline`
- `group`

Switch `---type` will reflect on a command's type. For example, `cli list ---type` will print `command`.

### `CLI_SOURCE` 
The path to the source file of the command.

Switch `---which` will reflect on the path to a command's source file. For example, `cli list ---which` might print `/workspaces/cli/src/list`.

### `CLI_CACHE` 
Path to the temporary directory used by the loader to cache metadata associated with the command.

Switch `---cache` will reflect on the path to a command's cache directory file. For example, `cli list ---cache` might print `/workspaces/cli/src/.cli/list`.

### `CLI_FUNCTION_MAIN`

### `CLI_FUNCTION_INLINE`

### `CLI_FUNCTION_SELF_TEST`

### `CLI_FUNCTION_HELP`

### `CLI_IMPORT`

### `CLI_SYMBOL` 
Prefix of the backing variables holding metadata describing the command. For example, the `CLI_SYMBOL` for command `cli list` is `CLI_LOADER_CLI_LIST`. 

## Backing Variables 
Backing variables are immutable bash variables. Each [frame variable](#frame-variables) references a backing variable. The name of the variable is composed of a prefix and suffix. Each command has a unix prefix that is stored in `CLI_SYMBOL`. 

Each prefix begins with `CLI_LOADER` followed by the command. For example, `cli list` has the prefix `CLI_LOADER_CLI_LIST`. 

The suffix corresponds to a [frame variable](#frame-variables). For example, command `cli list` has a frame variable `CLI_TYPE` which references a backing variable with suffix `TYPE` or, putting it all together, `CLI_LOADER_CLI_LIST_TYPE`. 

## Loader Variables

### `CLI_LOADER_LOCK`
### `CLI_LOADER_CACHE_IMPORTED`
### `CLI_LOADER_CACHE_COVERED`
### `CLI_LOADER_CACHE_SOURCED_PATHS`
### `CLI_LOADER_KNOWN_COMMANDS`
