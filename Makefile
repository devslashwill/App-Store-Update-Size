export THEOS_DEVICE_IP=192.168.2.5
include theos/makefiles/common.mk

LIBRARY_NAME = AppStoreUpdateSize
AppStoreUpdateSize_FILES = Tweak.xm
AppStoreUpdateSize_FRAMEWORKS = UIKit CoreGraphics
AppStoreUpdateSize_PRIVATE_FRAMEWORKS = iTunesStoreUI StoreServices
AppStoreUpdateSize_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
AppStoreUpdateSize_LDFLAGS = -lsubstrate

include $(THEOS_MAKE_PATH)/library.mk

after-install::
	-install.exec "killall AppStore"
	-install.exec "open com.apple.AppStore"
