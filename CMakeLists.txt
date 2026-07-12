cmake_minimum_required(VERSION 3.16)
project(kpictureframe)

set(KF6_MIN_VERSION "6.10.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    I18n
)

set(PLASMOID_ID de.agundur.kpictureframe)

ki18n_install(translate
    INSTALL_DESTINATION ${KDE_INSTALL_LOCALEDIR}
)

install(DIRECTORY package/ DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/${PLASMOID_ID})
