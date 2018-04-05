import objcbridge

class ScreensManager():
    def showCreateWalletViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showCreateWalletViewController', handler)
        pass

    def showEnterOrCreateWalletViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showEnterOrCreateWalletViewController', handler)
        pass

    def showCreateNewSeedViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showCreateNewSeedViewController', handler)
        pass

    def showHaveASeedViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showHaveASeedViewController', handler)
        pass

    def showConfirmSeedViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showConfirmSeedViewController', handler)
        pass

    def showEnterWalletPasswordViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showEnterWalletPasswordViewController', handler)
        pass

    def showWalletViewController(self, historyHandler, receiveHandler, sendHandler, menuHandler, mainHandler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showWalletViewController', [historyHandler, receiveHandler, sendHandler, menuHandler, mainHandler])
        pass
    
    def showServerViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showServerViewController', handler)

    def showSettingsViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showSettingsViewController', handler)
        pass

    def showTransactionDetailViewController(self, handler):
        objcbridge.sendCommandWithHandler('ScreensManager', 'showTransactionDetailViewController', handler)
