# Makefile for compiling macism CLI and TemporaryWindow GUI app

# Compiler and flags
SWIFTC = swiftc

# Targets for CLI (macism)
CLI_SOURCES = KeyUtils.swift WindowUtils.swift TSMUtils.swift Server.swift InputSourceManager.swift macism.swift
CLI_TARGET = macism
CLI_FRAMEWORKS = -framework Carbon

# Targets for GUI (TemporaryWindow.app)
GUI_SOURCES = WindowUtils.swift TemporaryWindow.swift
GUI_TARGET = TemporaryWindow
GUI_APP_BUNDLE = TemporaryWindow.app

# Default target: build both CLI and GUI
all: $(CLI_TARGET) $(GUI_APP_BUNDLE)

# Rule to build the macism CLI binary
$(CLI_TARGET): $(CLI_SOURCES)
	$(SWIFTC) $(CLI_SOURCES) $(CLI_FRAMEWORKS) -o $(CLI_TARGET)

# Rule to build the TemporaryWindow executable
$(GUI_TARGET): $(GUI_SOURCES)
	$(SWIFTC) $(GUI_SOURCES) -o $(GUI_TARGET)

# Rule to create the TemporaryWindow.app bundle
$(GUI_APP_BUNDLE): $(GUI_TARGET)
	mkdir -p $(GUI_APP_BUNDLE)/Contents/MacOS
	cp -rf $(GUI_TARGET) $(GUI_APP_BUNDLE)/Contents/MacOS/

# Clean up the build artifacts
clean:
	rm -f $(CLI_TARGET)
	rm -f $(GUI_TARGET)
	rm -rf $(GUI_APP_BUNDLE)/Contents/MacOS/$(GUI_TARGET)

# Rebuild by cleaning and then building
rebuild: clean all

# Phony targets (not representing actual files)
.PHONY: all clean rebuild
