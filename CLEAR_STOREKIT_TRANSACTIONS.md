# How to Clear StoreKit Test Transactions

## In Xcode:
1. Open your project in Xcode
2. Go to **Debug** menu → **StoreKit** → **Manage Transactions**
3. Delete all transactions listed there
4. Clean build folder: **Product** → **Clean Build Folder** (⇧⌘K)
5. Delete app from simulator
6. Run the app again

## Alternative Method:
1. In Simulator, go to **Device** → **Erase All Content and Settings**
2. This will reset the entire simulator

## To Disable StoreKit Configuration Temporarily:
1. Edit your scheme: **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** → **Options**
3. Under **StoreKit Configuration**, select **None**
4. Run the app (this will connect to real App Store sandbox)
EOF < /dev/null
