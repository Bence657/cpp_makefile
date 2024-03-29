CXX=clang++
CXXFLAGS = -std=c++17 -pthread -MD -MP
LDFLAGS :=

SRCDIR  = ./src
OBJSDIR = ./build
DEPDIR	= ./include
OUTPUT = project.out

#  Release version is compiled with optimisation flag
ifeq ($(RELEASE), 1)
	CXXFLAGS += -Ofast
endif

# Find all subdirectories
INCLUDES = $(shell find $(SRCDIR) -type d | sed s/^/-I/)

# Get all sources files from source directory
SOURCES = $(shell find $(SRCDIR) -type f -name '*.cpp')

# Generate all objects from source file
OBJECTS  = $(SOURCES:$(SRCDIR)%.cpp=$(OBJSDIR)%.o)

# Main rule
$(OUTPUT): $(OBJSDIR) $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) $(LDFLAGS) -o $(OUTPUT)

# Make each object
$(OBJECTS): $(OBJSDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Generate dependency files for each object
# This makes sure that not everything is recompiled if headers are modified
-include $(SOURCES:$(SRCDIR)%.cpp=$(OBJSDIR)%.d)

# Recusively copy directory structure of src/ to build/ without files
$(OBJSDIR):
	rsync -av -f"+ */" -f"- *" $(SRCDIR)/ $(OBJSDIR)

all:
	make

release:
	make RELEASE=1

clean:
	rm -f $(OUTPUT)
	rm -rf $(OBJSDIR)