if (EXISTS "${PROJECT_SOURCE_DIR}/../libwebsockets/include/")
  message (STATUS "Sibling libwebsockets found.")
  set (LIBWEBSOCKETS_FOUND TRUE)
  set (LIBWEBSOCKETS_INCLUDE_DIRS
    "${PROJECT_SOURCE_DIR}/../libwebsockets/include/"
    "${PROJECT_BINARY_DIR}/../libwebsockets/")
  set (LIBWEBSOCKETS_LIBRARY websockets_shared)
  if (LIBWEBSOCKETS_USE_STATIC_LIBS)
    message (STATUS "Using static sibling libwebsockets.")
    set (LIBWEBSOCKETS_LIBRARY websockets)
  else ()
    message (STATUS "Using shared sibling libwebsockets.")
  endif ()
  set (LIBWEBSOCKETS_LIBRARIES ${LIBWEBSOCKETS_LIBRARY})
else ()
  message (STATUS "Sibling libwebsockets NOT found.")
endif ()
