include theos/makefiles/common.mk

TWEAK_NAME = AppStoreUpdateSize
AppStoreUpdateSize_FILES = Tweak.xm
AppStoreUpdateSize_FRAMEWORKS = UIKit CoreGraphics
AppStoreUpdateSize_PRIVATE_FRAMEWORKS = iTunesStoreUI StoreServices

include $(THEOS_MAKE_PATH)/tweak.mk
