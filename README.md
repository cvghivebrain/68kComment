# 68kComment
Automates the indentation of comments in 68000 assembly.

## Usage
Comment.bat will open all ASM files in the current folder and subfolders, and adjust their comments to column 64.

```
Comment <threshold> <target> [file]
```

- `<threshold>` = Minimum position for detecting a comment. Set to 0 to adjust all comments.
- `<target>` = Position where you want comments to be. Usually a multiple of 8.
- `[file]` = OPTIONAL; Specific file to open. Using this will suppress opening any other files or subfolders.
