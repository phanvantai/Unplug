# Unplug - Screen Time Setup

## Fixing the ManagedSettingsAgent Error

The error you're encountering is due to missing entitlements required for Screen Time APIs. Here's how to fix it:

### 1. Add Entitlements File to Xcode Project

1. Open your Xcode project (`Unplug.xcodeproj`)
2. Right-click on the `Unplug` folder in the Project Navigator
3. Select "Add Files to 'Unplug'"
4. Navigate to and select the `Unplug.entitlements` file that was created
5. Make sure "Add to target" is checked for the Unplug target

### 2. Configure Build Settings

1. Select your project in the Project Navigator
2. Select the `Unplug` target
3. Go to the "Signing & Capabilities" tab
4. In the "Code Signing Entitlements" field, enter: `Unplug/Unplug.entitlements`

### 3. Add Required Capabilities

In the "Signing & Capabilities" tab:

1. Click the "+ Capability" button
2. Add "Family Controls" capability

**Note:** Device Activity capability requires special approval from Apple and is not available for all developer accounts. This app has been updated to work with just Family Controls.

### 4. Development Team and Provisioning

Make sure you have:

- A valid Apple Developer account
- The app is signed with a development team
- The bundle identifier is unique

### 5. Testing Notes

- Screen Time APIs only work on physical devices, not in the simulator
- The app will request permission to access Family Controls when it first launches
- Users must grant permission in Settings > Screen Time > Family Controls

### 6. Build and Run

After completing these steps:

1. Clean your build folder (⌘+Shift+K)
2. Build and run on a physical device
3. When prompted, grant Family Controls permission

## Troubleshooting

If you continue to see the error:

1. Verify the entitlements file is properly added to the project
2. Check that the capabilities are correctly configured
3. Ensure you're testing on a physical device
4. Try deleting and reinstalling the app
5. Check that Screen Time is enabled in Settings

## Important Notes

- Family Controls requires iOS 15.0+ or macOS 12.0+
- The app must be run on a physical device for Screen Time APIs to work
- Users will need to grant explicit permission for the app to access Screen Time data

## Important: Device Activity Entitlement

If you encounter the error "Provisioning profile doesn't include the com.apple.developer.deviceactivity entitlement", this is because:

1. **Device Activity requires special approval**: The Device Activity entitlement requires approval from Apple and is not available to all developer accounts
2. **Application required**: You need to apply for this entitlement through Apple Developer portal
3. **Alternative approach**: This app has been updated to work with Family Controls only, providing app blocking functionality without Device Activity monitoring

### Requesting Device Activity Entitlement (Optional)

If you want full Device Activity monitoring capabilities:

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Request the Device Activity entitlement for your app
4. Wait for Apple's approval (this can take several weeks)

For now, the app will work with basic app blocking using Family Controls only.
