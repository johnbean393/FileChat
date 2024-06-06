<h1 align="center">FileChat</h1>

Chat with LLMs on your Mac without installing any other software. Every conversation is saved locally, all conversations happen offline.

- Customize persona and expertise by changing the system prompt
- Try any llama.cpp compatible GGUF model
- No internet connection required, all local (with the option to connect to a remote model)

**Note: FileChat is an extended version of FreeChat. You can visit the original [here](https://github.com/psugihara/FreeChat)**

## Installation

**Requirements**
An Apple Silicon Mac with RAM ≥ 16 GB

**Prebuilt Package**
- Download the packages from [Releases](https://github.com/johnbean393/FileChat/releases), and open it. Note that since the package is not notarized, you will need to enable it in System Settings. 

**Build it yourself**
- Download, open in Xcode, and build it.

## Goals

The main goal of FileChat is to make open, local, private models accessible to more people, and allow a local model to gain context of files and folders.

FileChat is a native LLM application for macOS that runs completely locally. Download it and ask your LLM a question without doing any configuration. Give the LLM access to your folders and files with just 1 click, allowing them to reply with context.

- No config. Usable by people who haven't heard of models, prompts, or LLMs.
- Performance and simplicity over dev experience or features. Notes not Word, Swift not Elektron.
- Local first. Core functionality should not require an internet connection.
- No conversation tracking. Talk about whatever you want with FileChat, just like Notes.
- Open source. What's the point of running local AI if you can't audit that it's actually running locally?

### Contributing

Contributions are very welcome. Let's make FileChat simple and powerful.

### Credits

This project would not be possible without the hard work of:

- psugihara and contributors who built [FreeChat](https://github.com/psugihara/FreeChat)
- Georgi Gerganov for [llama.cpp](https://github.com/ggerganov/llama.cpp)
- Meta for training Llama 3
- TheBloke (Tom Jobbins) for model quantization
