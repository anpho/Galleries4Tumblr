APP_NAME = WPCollection

CONFIG += qt warn_on cascades10

include(config.pri)
LIBS += -lbb -lbbsystem -lbbplatform  -lbbdevice -lclipboard -lbbdata
LIBS += -lbbcascadespickers
QT += network


RESOURCES += assets.qrc
DEPENDPATH += assets