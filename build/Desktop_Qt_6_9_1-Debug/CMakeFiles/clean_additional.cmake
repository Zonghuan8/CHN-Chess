# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appCHN-Chess_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appCHN-Chess_autogen.dir/ParseCache.txt"
  "appCHN-Chess_autogen"
  )
endif()
