set(LLVM_LINK_COMPONENTS support)
set(LLVM_USED_LIBS clangTooling clangBasic clangAST)

find_package(GTK2 COMPONENTS gtk)
include_directories(${GTK2_INCLUDE_DIRS})

add_clang_executable(codemap
  CodeMap.cpp
  ClassGraphic.cpp
  Collection.cpp
  BaseObject.cpp
  MethodObject.cpp
  )
target_link_libraries(codemap
  clangTooling
  clangBasic
  clangASTMatchers
  ${GTK2_LIBRARIES}
  )