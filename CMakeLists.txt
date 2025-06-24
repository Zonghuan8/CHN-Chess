cmake_minimum_required(VERSION 3.16)

project(CHN-Chess VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

#添加下面一行解决图片资源无法找到的问题
set(CMAKE_AUTORCC ON)

qt_add_executable(appCHN-Chess
    main.cpp
    chess.qrc
)

qt_add_qml_module(appCHN-Chess
    URI Chess
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES ChessBoard.qml
        QML_FILES ChessPiece.qml
        RESOURCES chess.qrc
        QML_FILES HomePage.qml
        QML_FILES PvpGamePage.qml
        QML_FILES PveGamePage.qml
        SOURCES stone.h stone.cpp
        SOURCES board.h board.cpp
        QML_FILES RulesPage.qml
        QML_FILES AboutPage.qml

        QML_FILES AnimationEffect.qml
        SOURCES moverecord.h moverecord.cpp

        QML_FILES settings.js
        SOURCES
        QML_FILES

        SOURCES aigameboard.h aigameboard.cpp
        QML_FILES AIChessBoard.qml

        QML_FILES MusicPlayer.qml
        RESOURCES music.qrc
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appCHN-Chess PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appCHN-Chess
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCHN-Chess
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appCHN-Chess
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
