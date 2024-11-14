# Flex11
Flex OS for the Mini-8E MC68HC11 boards

# Status

This currently is a project that is under construction. We're building a 68HC11 board and trying to get Flex recompiled for the 68HC11 instead of the 6800. Right now we're gathering up the resources and testing out the code but nothing has bee built.

# Commands

```
asl -cpu 6811 -i . -L skeletal-FLEX-loader.asm
```

# Directories

| Name | Description |
| -- | --|
| cmds | Directory with the TSC 6800 Flex cmd source |
| Flex2 | Directory with the TSC 6800 Flex 2 OS source |
| Flex3 | Directory with the TSC 6800 Flex 3 OS source |
| LICENSE | Not sure this is correct (and a bit more complex) |
| README.md | |
| src | Directory with the TSC 68HC11 Flex 3 OS source |

# Reference

https://github.com/KenWillmott/M8/wiki
https://github.com/KenWillmott

https://github.com/KenWillmott/Mini11-M8
https://github.com/linuxha/Mini11-M8E
https://github.com/linuxha/M8-6809-Mezzanine
https://github.com/KenWillmott/6522-proto

https://github.com/linuxha/Fuzix-Compiler-Kit
https://github.com/linuxha/Fuzix-Bintools
https://github.com/linuxha/Flex-OS
https://github.com/linuxha/f9dasm

