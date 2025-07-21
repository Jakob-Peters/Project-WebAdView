# Setup

Follow these steps to setup the Didomi iOS and tvOS SDK:

* [Requirements](#requirements)
* [Add the SDK to your project](#add-the-sdk-to-your-project)
* [Initialize the SDK](#initialize-the-sdk)
* [Setup the SDK UI](#setup-the-sdk-ui)
* [Configure the SDK](#configure-the-sdk)
* [SwiftUI](#swiftui)

## Requirements

We offer our SDK as a pre-compiled binary package as a XCFramework that you can add to your application. We support iOS versions >= 9 and tvOS versions >= 11.

## Add the SDK to your project

The package can be added using CocoaPods or manually.

### Using CocoaPods

The package can be added using CocoaPods:

{% tabs %}
{% tab title="Xcode >= 12 (XCFramework)" %}
1\. If you haven't already, install the latest version of [CocoaPods](https://guides.cocoapods.org/using/getting-started.html).\
2\. Add this line to your `Podfile`:

```
pod 'Didomi-XCFramework', '2.26.3'
```
{% endtab %}
{% endtabs %}

### Using Swift Package Manager

The iOS SDK is available through Swift Package Manager as a binary library. In order to integrate it into your iOS or tvOS project follow the instructions below:

* Open your Xcode project
* Select your project in the **navigator area**
* Select your project in the **PROJECT** section
* Select the **Package Dependencies**
* Click on the **+** button
* Copy the package url [https://github.com/didomi/didomi-ios-sdk-spm](https://github.com/didomi/didomi-ios-sdk-spm) into the search bar
* Select the **didomi-ios-sdk-spm** package from the list
* Click on **Add Package**
* From the **Choose Package Products for the didomi-ios-sdk-spm** screen click on Add Package

Your setup should end up looking like this:

<figure><img src="https://1703900661-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LDh8ZWDZrXs8sc4QKEQ%2Fuploads%2FpMTK5XBYgyuiVWQEMlRn%2Fimage.png?alt=media&#x26;token=a2720a92-d086-4ac1-9d09-952867872d3d" alt=""><figcaption><p>Swift Package Manager setup</p></figcaption></figure>

### Manually

The package can also be added manually as explained below:

1. Download and unzip the latest version of our framework for Xcode >= 12: [https://sdk.didomi.io/ios/didomi-ios-sdk-X.Y.Z-xcframework.zip](https://sdk.didomi.io/ios/didomi-ios-sdk-X.Y.Z-xcframework.zip) where `X.Y.Z` corresponds to the version number that you want to add.
2. In Xcode, select your project.
3. In Xcode, select your project.
4. Then, select your app target.
5. Click on the `General` tab.
6. Scroll down to the `Embedded binaries` section.
7. From finder, drag the `Didomi.framework` file into the `Embedded binaries` section.
8. Make sure the `Copy items if needed` box is checked and click on `finish`
9. Your configuration should end up looking as follows:

![](https://1703900661-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-LDh8ZWDZrXs8sc4QKEQ%2F-LQG0uZgg2Z5FOHMTwjH%2F-LQG2ADr21LSQMjTL1Xd%2Fimage.png?alt=media\&token=80f06567-9a6a-4fe7-ae2d-1631f42306ca)

### Objective-C projects only

The iOS Didomi SDK is written in Swift so if your app is written in Objective-C, please make sure that the `Always Embed Swift Standard Libraries` flag is set to `YES` as shown in the image below:

![](https://1703900661-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-LDh8ZWDZrXs8sc4QKEQ%2F-LbcmMdE_v3VV6Hd8XzX%2F-LbcnIsQsXx1vLAu_pDs%2Fimage.png?alt=media\&token=bbcf5ca9-49ff-4b49-9b44-cb37566c26ab)

## Initialize the SDK

Once our SDK has been added to your project, you need to initialize it. The initialization process will prepare the SDK for interactions with the user and your application. It is important to launch the SDK initialization as soon as possible.

In the `AppDelegate`, make sure to import the `Didomi` module, then call the `initialize` method and pass your API key:

{% tabs %}
{% tab title="Swift" %}
```swift
import UIKit
import Didomi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let parameters = DidomiInitializeParameters(
            apiKey: "<Your API key>",
            localConfigurationPath: "<Your local config path>",
            remoteConfigurationURL: "<Your remote config url>",
            providerID: "<Your provider ID>",
            disableDidomiRemoteConfig: true|false,
            languageCode: "<Your language code>",
            noticeID: "<Your notice ID>"
        )
        Didomi.shared.initialize(parameters)
        
        // Important: views should not wait for onReady to be called.
        // You might want to execute code here that needs the Didomi SDK
        // to be initialized such us: analytics and other non-IAB vendors.
        Didomi.shared.onReady {
            // The Didomi SDK is ready to go, you can call other functions on the SDK
        }
        
        return true
    }
}
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
#import <UIKit/UIKit.h>
#import <Didomi/Didomi.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
```

```objectivec
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    Didomi *didomi = [Didomi shared];
    DidomiInitializeParameters *parameters = [[DidomiInitializeParameters alloc] initWithApiKey: @"<Your API key>"
                                                                         localConfigurationPath: nil
                                                                         remoteConfigurationURL: nil
                                                                                     providerID: nil
                                                                      disableDidomiRemoteConfig: NO
                                                                                   languageCode: nil
                                                                                       noticeID: @"<Your notice ID>"];
    
    [didomi initialize: parameters];
    // Important: views should not wait for onReady to be called.
    // You might want to execute code here that needs the Didomi SDK
    // to be initialized such us: analytics and other non-IAB vendors.
    [didomi onReadyWithCallback:^{
        // The Didomi SDK is ready to go, you can call other functions on the SDK
    }];

    return YES;
}

@end
```
{% endtab %}
{% endtabs %}

Keep in mind that the SDK initialization is an asynchronous process so you must avoid interacting with the `Didomi` object until it is actually ready to handle your requests. Use the `onReady` closure in Swift or the `onReadyWithCallback` method in Objective-C to register a listener for the ready event.

## Setup the SDK UI

{% hint style="info" %}
Note: the `setupUI` method should be called only from your main/entry `UIViewController` which in most cases should be once per app launch.

You do not need to call `onReady`, `isReady` or `shouldConsentBeCollected` before calling `setupUI` because they are called internally. Therefore, by calling this method the consent notice and preference views will only be displayed if it is required and only once the SDK is ready.
{% endhint %}

In order for the SDK to be able to display UI elements and interact with the user, you must provide a reference to your main `UIViewController`. Make sure to import the `Didomi` module and call the `setupUI` method in Swift, `setupUIWithContainerController` in Objective-C, of the SDK in the `viewDidLoad` method of your main `UIViewController`:

{% tabs %}
{% tab title="Swift" %}
```swift
import UIKit
import Didomi

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Didomi.shared.setupUI(containerController: self)
    }
}
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
#import <UIKit/UIKit.h>
#import <Didomi/Didomi.h>

@interface ViewController : UIViewController

@end
```

```objectivec
#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Didomi *didomi = [Didomi shared];
    [didomi setupUIWithContainerController:self];
}

@end
```
{% endtab %}
{% endtabs %}

### Deep links

If you are using deep links or have multiple main activities in your app make sure that the `setupUI` function is called on every activity that the user can launch the app on.\
\
This will ensure that consent is always collected as needed and there is no path where the user can launch the app without consent being collected. If `setupUI` is missing at some entry points, you will see lower consent rates as users will be using the app without giving consent.

## Configure the SDK

We support three options for configuring the UI and the behavior of the SDK:

* [Didomi Console](#from-the-console-recommended): the SDK is configured remotely from the Didomi Console
* [Local file](#local-file): the SDK is configured from a `didomi_config.json` file embedded in your app package
* [Remote file](#remote-file): the SDK is configured from a remote didomi\_config.json file

### From the Console (Recommended)

You can configure the consent notice in your app by creating a notice in your Didomi Console. It will automatically be linked to your app through your API Key and, optionally, your app package name.\
You can access the Didomi console [here](http://console.didomi.io).

In order to enable this option, make sure to pass the `disableDidomiRemoteConfig` parameter as `false` when calling the initialize method as shown below.

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.initialize(
    apiKey: "<Your API key>",
    localConfigurationPath: nil,
    remoteConfigurationURL: nil,
    providerId: nil,
    disableDidomiRemoteConfig: false
)
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
[didomi initializeWithApiKey:@"<Your API key>" localConfigurationPath:nil remoteConfigurationURL:nil providerId:nil disableDidomiRemoteConfig:NO languageCode:nil];
```
{% endtab %}
{% endtabs %}

The SDK will automatically use the remote configuration hosted by Didomi and cache it locally. The cached version is refreshed every 60 minutes.

### Local file (deprecated)

{% hint style="danger" %}
Using your own remote file automatically disables the TCF integration.\
If your app uses the TCF, you must use a configuration from the Didomi Console.
{% endhint %}

{% hint style="warning" %}
Using a local file will prevent you to support multiple regulations.
{% endhint %}

With this option, you create your own SDK configuration file and embed in your app package.

The SDK behavior is configured in a `didomi_config.json` file that must be placed somewhere under your project folder (see the image below for reference). Create a file with the following content to get started:

{% tabs %}
{% tab title="didomi_config.json" %}
```javascript
{
    "app": {
        "name": "My App Name",
        "privacyPolicyURL": "http://www.website.com/privacy",
        "vendors": {
            "iab": {
                "all": true
            }
        },
        "gdprAppliesGlobally": true,
        "gdprAppliesWhenUnknown": true
    }
}
```
{% endtab %}
{% endtabs %}



![](https://1703900661-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-LDh8ZWDZrXs8sc4QKEQ%2F-LQFzUeaDGXpkTwd9QAo%2F-LQFzYfWXIjbXbBXyqw4%2Fimage.png?alt=media\&token=9a83ea58-311b-4956-967a-e019867b95be)

You also need to disable loading the remote configuration to ensure that only the local file is loaded and that no HTTP request is sent. Update your [`initialize`](../reference/api#initialize) call to set the `disableDidomiRemoteConfig` parameter to `true`:

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.initialize(
    apiKey: "<Your API key>",
    localConfigurationPath: nil,
    remoteConfigurationURL: nil,
    providerId: nil,
    disableDidomiRemoteConfig: true
)
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
[didomi initializeWithApiKey:@"<Your API key>" localConfigurationPath:nil remoteConfigurationURL:nil providerId:nil disableDidomiRemoteConfig:YES languageCode:nil];
```
{% endtab %}
{% endtabs %}

Your SDK is now setup. [Read the Getting started section](../consent-notice/getting-started) to learn more about how to configure it to match your app UI and requirements.

### Remote file

{% hint style="danger" %}
Using your own remote file automatically disables the TCF integration.\
If your app uses the TCF, you must use a configuration from the Didomi Console.
{% endhint %}

{% hint style="info" %}
Enabling this option will prevent the configuration from being loaded from the Didomi Console.
{% endhint %}

You can provide a remote URL for the SDK to download the `didomi_config.json` configuration file from. That allows you to update the SDK configuration without having to re-publish you mobile application.

When that configuration is enabled, the SDK will automatically use the remote configuration and cache it locally. The cached version is refreshed every 60 minutes. If there is no connection available to download the remote file and no locally cached version, the SDK will try to use the local `didomi_config.json` (provided in the app bundle) as a fallback.

To enable that option, change your call to [initialize](../reference/api#initialize) to provide the remote file URL:

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.initialize(
    apiKey: "<Your API key>",
    localConfigurationPath: nil,
    remoteConfigurationURL: "http://www.website.com/didomi_config.json",
    providerId: nil,
    disableDidomiRemoteConfig: false
)
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
[didomi initializeWithApiKey:@"<Your API key>" localConfigurationPath:nil remoteConfigurationURL:@"http://www.website.com/didomi_config.json" providerId:nil disableDidomiRemoteConfig:NO languageCode:nil];
```
{% endtab %}
{% endtabs %}

Also see the [reference documentation of the initialize function](../reference/api#initialize) for more information.

### Download Global Vendor List (GVL)

Since version 1.40.1 the GVL will be downloaded by default from our API before the SDK is initialized. If you want to stop this behaviour, provide the `app.vendors.iab.requireUpdatedGVL` flat set to false in the CUSTOM JSON section when editing your notice on the Console app (or in your local `didomi_config.json` file if that's the case).

```
{
    "app": {
        "vendors": {
            "iab": {
                "requireUpdatedGVL": false
            }
        }
    }
}
```

A timeout can also be provided to specify a maximum timeout for the Download of the GVL. This can be done by providing the `app.vendors.iab.updateGVLTimeout` property (in seconds).

```
{
    "app": {
        "vendors": {
            "iab": {
                "updateGVLTimeout": 10
            }
        }
    }
}
```

## SwiftUI

When you create a new Apple app, among other things you need to choose if your app is going to use UIKit or SwiftUI. SwiftUI is Apple's new framework for creating user interfaces in a declarative way. In order to use the Didomi SDK in a SwiftUI app we suggest the following steps.

### Prepare UIViewController to call setupUI method

1. Create a new Swift file. You can name it for example `DidomiWrapper`.
2. Inside this new file, create a new class that extends `UIViewController`. We need this to make sure we call the `setupUI` method when the `viewDidlLoad` method is called.
3. Inside the same file, create a struct that implements the `UIViewControllerRepresentable` protocol as shown below:

```swift
import SwiftUI
import Didomi

// If you have your own UIViewController you can use that instead.
class DidomiViewController: UIViewController {
    override func viewDidLoad() {
        // 2)
        Didomi.shared.setupUI(containerController: self)
    }
}

// 3)
struct DidomiWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let didomiViewController = DidomiViewController()
        
        return didomiViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // We don't need to implement this method
    }
}
```

### Prepare AppDelegate to call initialize method

When using SwiftUI, you might still want to use the `UIApplicationDelegate` functionality. Since we want to initialize the Didomi SDK as early as possible we recommend creating a class that implements the `UIApplicationDelegate`.

1. Create a new Swift file. You can name it for example `YourSwiftUIApp`.
2. Create a new class that extends the `UIApplicationDelegate` protocol. Inside the `applicationDidFinishLaunchingWithOptions` method, call the Didomi `initialize` method.
3. Create a new struct that implements the SwiftUI's `App` protocol. Use the `UIApplicationDelegateAdaptor` property wrapper to connect this new struct with the `AppDelegate` class. Make sure this new struct uses the `main` annotation. Now you are ready to use the new `DidomiWrapper` struct that you created in the previous steps.

The snippet below shows the steps explained in the points above.

```swift
import SwiftUI
import Didomi

// 2)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let parameters = DidomiInitializeParameters(
            apiKey: "<Your API key>",
            localConfigurationPath: "<Your local config path>",
            remoteConfigurationURL: "<Your remote config url>",
            providerID: "<Your provider ID>",
            disableDidomiRemoteConfig: true|false,
            languageCode: "<Your language code>",
            noticeID: "<Your notice ID>"
        )
        Didomi.shared.initialize(parameters)
        return true
    }
}

// 3)
@main
struct YourSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            DidomiWrapper()
        }
    }
}
```


# API

This section is a comprehensive reference of the methods and events exposed by the iOS SDK that you can leverage in your application.

Always use `Didomi.shared` to get a reference to the Didomi SDK. Also make sure to always call the SDK after it is fully initialized (see [onReady](#onready)).



## Usage

### addEventListener

Add an event listener to catch events triggered by the SDK. [See the dedicated section for more details](https://developers.didomi.io/cmp/mobile-sdk/ios/reference/events)

### removeEventListener

Remove a previously added event listener.

**Requires SDK to be initialized**

No.

**Parameters**

| Name          | Type            | Description                   |
| ------------- | --------------- | ----------------------------- |
| eventListener | `EventListener` | The event listener to remove. |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```java
Didomi.shared.removeEventListener(listener: currentEventListener)
```
{% endtab %}
{% endtabs %}

### getJavaScriptForWebView

Get JavaScript to embed into a WebView to pass the consent status from the app to the Didomi Web SDK embedded into the WebView.

Inject the returned tag into a WebView with `evaluateJavaScript`.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

| Type (Swift) | Type (Objective-C) | Description                           |
| ------------ | ------------------ | ------------------------------------- |
| `String`     | `NSString *`       | JavaScript code to embed in a WebView |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getJavaScriptForWebView()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
NSString *javaScriptForWebView = [didomi getJavaScriptForWebView];
```
{% endtab %}
{% endtabs %}

### getQueryStringForWebView

Get a query string parameter to append to the URL of a WebView to pass the consent status from the app to the Didomi Web SDK embedded into the WebView.

Read our article on [sharing consent with WebViews](../../share-consent-with-webviews) for more information.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

| Type     | Description                                                                                                                                                                            |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `String` | Query string parameter with the format `didomiConfig.user.externalConsent.value=...`. It can be appended to your URL after a `?` or a `&` if your URL already contains a query string. |

**Example**

{% tabs %}
{% tab title="Swift" %}
```java
Didomi.shared.getQueryStringForWebView()
```
{% endtab %}

{% tab title="Objective-C" %}
```
Didomi *didomi = [Didomi shared];
NSString *queryStringForWebView = [didomi getQueryStringForWebView];
```
{% endtab %}
{% endtabs %}

### hideNotice

Hide the consent notice.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.hideNotice()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];

[didomi hideNotice];
```
{% endtab %}
{% endtabs %}

### hidePreferences

Hide the preferences popup.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.hidePreferences()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];

[didomi hidePreferences];
```
{% endtab %}
{% endtabs %}

### initialize

Initialize the SDK. The initialization runs on a background thread to avoid blocking your UI. Use the [onReady](#onready) function to know when the initialization is done and the SDK is ready to be used.

**Requires SDK to be initialized**

No.

**Parameter:**

|            |                            |
| ---------- | -------------------------- |
| **Name**   | Type                       |
| parameters | DidomiInitializeParameters |

**Description for `DidomiInitializeParameters`**

{% hint style="warning" %}
The parameter `disableDidomiRemoteConfig` is deprecated, we strongly suggest you to create your notice from the console (see [Setup fromThe Console](../../setup#from-the-console-recommended) for more information).
{% endhint %}

| Name                                   | Type    | Optional | Description                                                                                                                                                                                                                                                                                                                                                                         |
| -------------------------------------- | ------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| apiKey                                 | String  | No       | Your API key                                                                                                                                                                                                                                                                                                                                                                        |
| localConfigurationPath                 | String  | Yes      | The path to your local config file in your `assets/` folder. Defaults to `didomi_config.json` if null.                                                                                                                                                                                                                                                                              |
| remoteConfigurationURL                 | String  | Yes      |  The URL to a remote configuration file to load during initialization. When provided, the file at the URL will be downloaded and cached to be used instead of the local `assets/didomi_config.json`. If there is no Internet connection available and no previously cached file, the local file will be used as fallback.                                                           |
| providerID                             | String  | Yes      | Your provider ID (if any). A provider ID is assigned when you work with Didomi through a third-party. If are not sure if you have one, set this to `null`.                                                                                                                                                                                                                          |
| disableDidomiRemoteConfig (deprecated) | Boolean | Yes      | <p>Prevent the SDK from loading a remote configuration from the Didomi Console. Defaults to <code>true</code> (not loading remote config).</p><p>Set this parameter to <code>false</code> to use a remote consent notice configuration loaded from the Didomi Console.</p><p>Set this parameter to <code>true</code> to disable loading configurations from the Didomi Console.</p> |
| languageCode                           | String  | Yes      | Language in which the consent UI should be displayed. By default, the consent UI is displayed in the language configured in the device settings. This property allows you to override the default setting and specify a language to display the UI in. String containing the language code or the local code e.g.: `"es"`, `"fr"`, `"en_US"`_,_ `"zh_HK"`, etc.                     |
| noticeID                               | String  | Yes      | Notice ID to load the configuration from. If provided, the SDK bypasses the app ID targeting and directly loads the configuration from the notice ID.                                                                                                                                                                                                                               |
| countryCode                            | String  | Yes      | <p>Override user country code when determining the privacy regulation to apply. </p><p>Keep <code>null</code> to let the Didomi SDK determine the user country.</p>                                                                                                                                                                                                                 |
| regionCode                             | String  | Yes      | <p>Override user region code when determining the privacy regulation to apply. </p><p>Keep <code>null</code> to let the Didomi SDK determine the user region.</p><p>Ignored if countryCode is not set.</p>                                                                                                                                                                          |
| isUnderage                             | Boolean | Yes      | Whether the user is underage or not. This parameters can only be used if the Underage feature has been configured in your notice. (Underage is currently in beta version).                                                                                                                                                                                                          |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
let parameters = DidomiInitializeParameters(
    apiKey: "<Your API key>",
    noticeID: "<Your notice ID>"
)
initialize(parameters)
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DidomiInitializeParameters *parameters = [[DidomiInitializeParameters alloc] initWithApiKey: @"<Your API key>"
                                                                         localConfigurationPath: nil
                                                                         remoteConfigurationURL: nil
                                                                                     providerID: nil
                                                                      disableDidomiRemoteConfig: NO
                                                                                   languageCode: nil
                                                                                       noticeID: @"<Your Notice ID>"];
    
[didomi initialize: parameters];
```
{% endtab %}
{% endtabs %}

### isNoticeVisible

Check if the consent notice is currently displayed.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

`Bool`

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.isNoticeVisible()
```
{% endtab %}

{% tab title="Objective-C" %}
```
Didomi *didomi = [Didomi shared];
BOOL isNoticeVisible = [didomi isNoticeVisible];
```
{% endtab %}
{% endtabs %}

### isPreferencesVisible

Check if the preferences popup is currently displayed.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

`Bool`

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.isPreferencesVisible()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
BOOL isPreferencesVisible = [didomi isPreferencesVisible];
```
{% endtab %}
{% endtabs %}

### isReady

Check if the SDK is ready.

**Requires SDK to be initialized**

No.

**Parameters**

No parameter.

**Returns**

`Bool`

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.isReady()
```
{% endtab %}

{% tab title="Objective-C" %}
```
Didomi *didomi = [Didomi shared];
BOOL isReady = [didomi isReady];
```
{% endtab %}
{% endtabs %}

### onError

Add a closure that will be executed if an unexpected situation occurs, for example an error during the initialization process.

**Requires SDK to be initialized**

**No**

**Parameters**

| **Name** | Type   | Description                                             |
| -------- | ------ | ------------------------------------------------------- |
| callback | `func` | A closure executed when an unexpected situation occurs. |

**Returns**

The method itself does not return a value but when the closure is executed an error object is passed to it which explains the reason of the unexpected situation.

We recommend calling this method before calling the `initialize` method.

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.onError { errorEvent in
    // Closure executed
}
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi onErrorWithCallback:^(DDMErrorEvent * _Nonnull event) {
    NSLog(@"An unexpected situation occurred.");
}];
```
{% endtab %}
{% endtabs %}

### onReady

Add an event listener that will be called when the SDK is ready (ie fully initialized). If the event listener is added after the SDK initialization, the listener will be called immediately.

All calls to other functions of this API must only be made in a listener to the ready event to make sure that the SDK is initialized before it is used.

**Requires SDK to be initialized**

No.

**Parameters**

| Name     | Type   | Description                              |
| -------- | ------ | ---------------------------------------- |
| callback | `func` | A function to call when the SDK is ready |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.onReady {
    // The SDK is ready
}
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi onReadyWithCallback:^{
    // The SDK is ready
}];
```
{% endtab %}
{% endtabs %}

### setLogLevel

Set the minimum level of messages to log. The SDK will not log messages under that level.\
See [Logging](../logging) for more information.

**Requires SDK to be initialized**

No.

**Parameters**

| Name     | Type    | Description                       |
| -------- | ------- | --------------------------------- |
| minLevel | `UInt8` | Minimum level of messages to log. |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.setLogLevel(minLevel: 2)
```
{% endtab %}
{% endtabs %}

### setupUI

{% hint style="info" %}
Internally, the setupUI method calls the `showNotice` method, which calls the `shouldConsentBeCollected` method. Therefore, by calling the `setupUI` method, the notice or preferences view will be displayed only if required.&#x20;
{% endhint %}

Setup the SDK UI workflows. This method is used to pass a reference to a `UIViewController` to the SDK that will use it as needed. By calling this method the notice or the preferences views will be displayed only once the SDK is ready and if consent should be collected. This must be called once in your main `UIViewController`.

**Requires SDK to be initialized**

No.

**Parameters**

| Name                | Type               | Description                                     |
| ------------------- | ------------------ | ----------------------------------------------- |
| containerController | `UIViewController` | The controller to use for displaying the notice |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.setupUI(containerController: this)
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi setupUIWithContainerController:self];
```
{% endtab %}
{% endtabs %}

### showNotice

{% hint style="info" %}
In most cases this method should be called if the notice should be displayed in response to a user action (e.g.: select the privacy settings section within your app). By calling the setupUI method, the notice will be displayed if required.
{% endhint %}

Show the consent notice. The consent notice actually only gets shown if needed (consent is required and we are missing consent information for some vendor or purpose).

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.showNotice()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi showNotice];
```
{% endtab %}
{% endtabs %}

### showPreferences

{% hint style="info" %}
In most cases this method should be called if you want to show the Preferences screen in response to a user action (the user pressing a "Consent Preferences" button in your app menu, for instance).
{% endhint %}

Show the Preferences view to the user. This method can be used to allow the user to update their preferences after the notice has been closed. We suggest adding a link/button/item that calls this method somewhere in your app, for example from your settings menu. By default, the Purposes view is displayed first. By calling this method, users will have the opportunity to modify the choices previously made.

{% hint style="info" %}
We strongly advise you to always pass the `viewController` parameter unless you can be certain that `setupUI` has been called.
{% endhint %}

**Requires SDK to be initialized**

Yes.

**Parameters**

| Name       | Type               | Description                                          |
| ---------- | ------------------ | ---------------------------------------------------- |
| controller | `UIViewController` | The controller to use for displaying the Preferences |
| view       | `Didomi.Views`     | The view to show (`.purposes` or `.vendors`)         |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.showPreferences()
Didomi.shared.showPreferences(viewController, .purposes) // Open the Purposes view
Didomi.shared.showPreferences(viewController, .vendors) // Open the Vendors view
Didomi.shared.showPreferences(viewController, .sensitivePersonalInformation) // Open the Sensitive Personal Information view
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
// We use `self` assuming this method is called from a `UIViewController`
[didomi showPreferencesWithController:self view:ViewsPurposes];
```
{% endtab %}
{% endtabs %}

### updateSelectedLanguage

Method used to update the selected language of the Didomi SDK and any property that depends on it.

In most cases this method doesn't need to be called. It would only be required for those apps that allow language change on-the-fly, i.e.: from within the app rather than from the device settings.

If your configuration involves country code (`en-US`), you can provide a locale code to change the regional configuration as well. If only language code (`en`) is provided and your configuration requires a country code, the country from the device location will be used (and will fallback to the default country if required).

In order to update the language of the views displayed by the Didomi SDK, this method needs to be called before these views are displayed.

**Requires SDK to be initialized**

Yes.

**Parameters**

| Name         | Type     | Description                                                                                                        |
| ------------ | -------- | ------------------------------------------------------------------------------------------------------------------ |
| languageCode | `String` | string containing the 2-letter language code or 5-letter locale code e.g. `en`, `es`, `fr`, `en_US`, `zh_HK`, etc. |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.onReady {
    Didomi.shared.updateSelectedLanguage(languageCode: "en")
}
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi onReadyWithCallback:^{
    [didomi updateSelectedLanguageWithLanguageCode:@"en"];
}];
```
{% endtab %}
{% endtabs %}



***

## Notice Config

### getPurpose

Get a purpose based on its ID.

{% hint style="warning" %}
**Not available for Objective-C**

This function is only exposed to Swift apps and cannot be called from Objective-C.
{% endhint %}

**Requires SDK to be initialized**

Yes.

**Parameters**

| Name      | Type     | Description                       |
| --------- | -------- | --------------------------------- |
| purposeId | `String` | ID of the purpose we want to get. |

**Returns**

| Type      | Description                                                              |
| --------- | ------------------------------------------------------------------------ |
| `Purpose` | A `Purpose` with ID `purposeId` found in the array of required purposes. |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getPurpose(purposeId: "purpose-id")
```
{% endtab %}
{% endtabs %}

### getRequiredPurposes

Get the list of purpose that are required (automatically determined from the list of required vendors).

{% hint style="warning" %}
**Not available for Objective-C**

This function is only exposed to Swift apps and cannot be called from Objective-C.
{% endhint %}

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

| Type        | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `[Purpose]` | An array of type `Purpose` containing the required purposes. |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getRequiredPurposes()
```
{% endtab %}
{% endtabs %}

### getRequiredVendors

Get the list of vendors that are required (determined from the configuration).

{% hint style="warning" %}
**Not available for Objective-C**

This function is only exposed to Swift apps and cannot be called from Objective-C.
{% endhint %}

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

| Type       | Description                                                |
| ---------- | ---------------------------------------------------------- |
| `[Vendor]` | An array of type `Vendor` containing the required vendors. |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getRequiredVendors()
```
{% endtab %}
{% endtabs %}

### getText

Method used to get a dictionary/map based on the key being passed. These keys and texts are extracted from the notice content, preferences content and the `texts` property specified in the `didomi_config.json` file as described here [https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-theme#translatable-texts-for-custom-notices](https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-theme#translatable-texts-for-custom-notices).

**Requires SDK to be initialized**

Yes.

**Parameters**

| Name | Type   | Description                                           |
| ---- | ------ | ----------------------------------------------------- |
| key  | String | key associated to the dictionary that we want to get. |

**Returns**

| Type           | Description                                                                                                                                                 |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dictionary/map | Dictionary/map containing the translations for an specific key in different languages, with the form { "en:" "text in English", "fr": "texte en Français" } |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getText("key")
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
NSString *translatedText = [didomi getTextWithKey:@"key"];
```
{% endtab %}
{% endtabs %}

### getTranslatedText

Method used to get a translated text based on the key being passed.

The language and the source of this translated text will depend on the availability of the translation for the specific key.

The language being used will be either the selected language of the SDK (based on device Locale and other parameters) or the language specified by app developers as the default language being used by the SDK. The source can be either the `didomi_config.json` file, which can be either local or remote, or a file that is bundled within the SDK.

These are the attempts performed by the SDK to try to find a translation for the specific key:

* Get translated value in user locale (selected language) from `didomi_config.json` (either local or remote).
* Get translated value in default locale (from the config) from `didomi_config.json` (either local or remote).
* Get translated value in user locale (selected language) from the Didomi-provided translations (bundled within the Didomi SDK).
* Get translated value in default locale (from the config) from the Didomi-provided translations (bundled within the Didomi SDK).

If no translation can be found after these 4 attempts, the key will be returned.

App developers can provide these translated texts through the `didomi_config.json` file (locally or remotely) in 3 different ways:

* Custom texts for the consent notice: [https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-notice#texts](https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-notice#texts)
* Custom texts for the preferences: [https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-preferences-popup#text](https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-preferences-popup#text)
* Custom texts for custom notices: [https://developers.didomi.io/cmp/mobile-sdk/consent-notice/customize-the-theme#translatable-texts-for-custom-notices](https://developers.didomi.io/cmp/mobile-sdk/consent-notice/build-your-own-custom-notice#translatable-texts-for-custom-notices)

**Requires SDK to be initialized**

Yes.

**Parameters**

| Name | Type   | Description                                                |
| ---- | ------ | ---------------------------------------------------------- |
| key  | String | key associated to the text that we want to get translated. |

**Returns**

Translated text.

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getTranslatedText("key")
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
NSString *translatedText = [didomi getTranslatedTextWithKey:@"key"];
```
{% endtab %}
{% endtabs %}

### getVendor

Get a vendor based on its ID.

{% hint style="warning" %}
**Not available for Objective-C**

This function is only exposed to Swift apps and cannot be called from Objective-C.
{% endhint %}

**Requires SDK to be initialized**

Yes.

**Parameters**

| Name     | Type     | Description                      |
| -------- | -------- | -------------------------------- |
| vendorId | `String` | ID of the vendor we want to get. |

**Returns**

| Type     | Description                                                           |
| -------- | --------------------------------------------------------------------- |
| `Vendor` | A `Vendor` with ID `vendorId` found in the array of required vendors. |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getVendor(vendorId: "vendor-id")
```
{% endtab %}
{% endtabs %}

### getTotalVendorCount

Get the total count of required vendors.

**Requires SDK to be initialized**

Yes.

**Returns**

| Type  | Description            |
| ----- | ---------------------- |
| `Int` | The total vendor count |

**Example**

{% tabs %}
{% tab title="Swift" %}
```java
Didomi.shared.getTotalVendorCount();
```
{% endtab %}

{% tab title="Obj-C" %}
```kotlin
Didomi *didomi = [Didomi shared];

[didomi getTotalVendorCount];
```
{% endtab %}
{% endtabs %}

### getIABVendorCount

Get the count of required IAB vendors.

**Requires SDK to be initialized**

Yes.

**Returns**

| Type  | Description          |
| ----- | -------------------- |
| `Int` | The IAB vendor count |

**Example**

{% tabs %}
{% tab title="Swift" %}
```java
Didomi.shared.getIABVendorCount();
```
{% endtab %}

{% tab title="Obj-C" %}
```kotlin
Didomi *didomi = [Didomi shared];

[didomi getIABVendorCount];
```
{% endtab %}
{% endtabs %}

### getNonIABVendorCount

Get the count of required vendors which are not part of the IAB.

**Requires SDK to be initialized**

Yes.

**Returns**

| Type  | Description              |
| ----- | ------------------------ |
| `Int` | The non-IAB vendor count |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.getNonIABVendorCount();
```
{% endtab %}

{% tab title="Obj-C" %}
```objectivec
Didomi *didomi = [Didomi shared];

[didomi getNonIABVendorCount];
```
{% endtab %}
{% endtabs %}





## User Status

### applicableRegulation

Get the applicable regulation.

**Requires SDK to be initialized**

**yes.**

**Returns**

| Type   | Description                                                                                                                                                                                                                                          |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Enum` | <p>Representation of the current regulation as a <code>Regulation</code> enum value, such as <code>.gdpr</code>, <code>.cpra</code> or <code>.none</code>.</p><p></p><p>Note that some regulations present as enum values are not available yet.</p> |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
let regulation = Didomi.shared.applicableRegulation
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
NSString *regulation = [Didomi.shared applicableRegulation];
```
{% endtab %}
{% endtabs %}

### addVendorStatusListener

Listen for changes on the user status linked to a specific vendor.

**Requires SDK to be initialized**

No.

**Parameters**

| Name     | Type                                                 | Description                                                                                                                                                                                   |
| -------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id       | `String`                                             | <p>The ID of the vendor for which we want to start listening for changes.</p><p><br>This ID should be the ID provided by Didomi, which doesn't contain prefixes.</p>                          |
| callback | callback: `(CurrentUserStatus.VendorStatus) -> Void` | <p>Callback that will be executed whenever changes are detected on the specified vendor.<br><br>When this callback is executed, the status linked to the specified vendor will be passed.</p> |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.addVendorStatusListener(id: "vendor-id") { newStatus in
  print("Vendor Status changed. New status: \(newStatus)")
}
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
[[Didomi shared] addVendorStatusListenerWithId:@"vendor-id" :^(DDMCurrentUserStatusVendor *newStatus) {
  NSLog(@"Vendor Status changed. New status: %@", newStatus);
}];
```
{% endtab %}
{% endtabs %}

### removeVendorStatusListener

Stop listening for changes on the user status linked to a specific vendor.

**Requires SDK to be initialized**

No.

**Parameters**

| Name | Type     | Description                                                                                                                                                            |
| ---- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id   | `String` | <p>The ID of the vendor for which we want to stop listening for changes.</p><p></p><p>This ID should be the ID provided by Didomi, which doesn't contain prefixes.</p> |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.removeVendorStatusListener(id: "vendor-id")
```
{% endtab %}

{% tab title="Objective-C" %}

{% endtab %}
{% endtabs %}

### getCurrentUserStatus

#### Definition

Exposes the user status for the current regulation that applies.

#### Parameters

No parameters.

#### Returns

The user status containing the computed global status for Vendors and purposes:

* A vendor's global status is enabled, if and only if:
  * the vendor is enabled directly in the vendors layer in all legal basis
  * **AND** all its related purposes are enabled or essential.
* A purpose's global status is enabled in one of the two conditions:
  * the purpose is enabled for all the legal basis that it is configured for.
  * **OR** when the purpose is essential.

| Parameter                     | Type      | Description                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ----------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| vendors                       | `object`  | <ul><li>Dictionary that maps the ID of a vendor to an object representing its status.</li><li>The IDs used in this dictionary correspond to the Didomi IDs i.e.: without the <code>c:</code> or any other prefix.</li><li>Vendors with undefined user status are included in the response with <code>enabled: false.</code></li><li>Vendors with ONLY essential purposes are automatically set with <code>enable: true</code></li></ul> |
| purposes                      | `object`  | <ul><li>Dictionary that maps the ID of a purpose to an object representing its status.</li><li>Purposes with undefined user status are included in the response with <code>enabled: false.</code></li><li>Essential purposes are automatically set with <code>enable: true</code></li></ul>                                                                                                                                             |
| regulation                    | `enum`    | <ul><li>Representation of the current regulation as a <code>Regulation</code> enum value, such as <code>.gdpr</code>, <code>.cpra</code> or <code>.none</code>.</li><li>Note that some regulations present as enum values are not available yet.</li></ul>                                                                                                                                                                              |
| userId                        | `string`  | Didomi user id.                                                                                                                                                                                                                                                                                                                                                                                                                         |
| created                       | `string`  | User choices creation date.                                                                                                                                                                                                                                                                                                                                                                                                             |
| updated                       | `string`  | User choices update date.                                                                                                                                                                                                                                                                                                                                                                                                               |
| consentString                 | `string`  | TCF consent as string                                                                                                                                                                                                                                                                                                                                                                                                                   |
| additionalConsent             | `string`  | Additional consent.                                                                                                                                                                                                                                                                                                                                                                                                                     |
| gppString                     | `string`  | GPP string. **Note:** GPP feature is currently in _beta_ version.                                                                                                                                                                                                                                                                                                                                                                       |
| shouldUserStatusBeCollected() | `Boolean` | Determine if the User Status (consent) should be collected or not, based on regulation, expiration date, and user status at the time of the call to `Didomi#getCurrentUserStatus()`. This method is only valid for objects returned by Didomi after a call to `getCurrentUserStatus()`. Not available in Objective-C.                                                                                                                   |

#### Examples

{% tabs %}
{% tab title="Swift" %}
```swift
let currentUserStatus = Didomi.shared.getCurrentUserStatus()

// Example: get consent status for vendor `google`
let vendorStatus = currentUserStatus.vendors["google"]
let isVendorEnabled = vendorStatus.enabled

// Example: get consent status for custom vendor
// with ID `custom-vendor-id` (without `c:` prefix).
let customVendorStatus = currentUserStatus.vendors["custom-vendor-id"]
let isCustomVendorEnabled = customVendorStatus.enabled
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
DDMCurrentUserStatus *currentUserStatus = [didomi getCurrentUserStatus];

// Example: get consent status for vendor `google`
DDMVendorStatus *vendorStatus = [currentUserStatus.vendors objectForKey:@"google"];
BOOL isVendorEnabled = [vendorStatus.enabled boolValue];
```
{% endtab %}
{% endtabs %}

### isUserStatusPartial

#### Definition

Determine if the user has provided a choice for all vendors selected for the regulation and linked data processing.

This function returns `true` if the user has not expressed a choice for all the required vendors and data processing.

Requires SDK to be initialized.

#### Parameters

No parameters.

#### Returns

`boolean`

* This function returns true if the following conditions are all met
  * A regulation apply for the current user (i.e: regulation is not NONE)
  * At least one vendor is configured (if there is no vendor configured, this function always returns false as there is no status to collect)
  * We miss user status for some vendors or purposes
* Otherwise, it will return false.
  * e.g: If regulation = none (i.e no regulation apply to the end user) → This function returns false
* Edge cases: a new vendor is added to the notice and status is not collected yet for that vendor. In this case the function will return true until the user update their choice on the consent banner.

#### Examples

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.isUserStatusPartial()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
BOOL isUserStatusPartial = [didomi isUserStatusPartial];
```
{% endtab %}
{% endtabs %}

### openCurrentUserStatusTransaction

**Definition**

Create an instance of  the `CurrentUserStatusTransaction` class.

This class provides mechanisms to stage updates to the user status regarding purposes and vendors, allowing for batch operations.&#x20;

Updates made through its methods are queued and applied simultaneously to the user status only once the `commit` method of the returned object is called.

Additional details:

* The status of vendors and purposes whose IDs are not not specified through the methods provided by `CurrentUserStatusTransaction` are kept unchanged.
* Essential purposes are always set to enabled and can’t be updated by the methods provided by `CurrentUserStatusTransaction`.
* When the regulation applied for a user is `none`, the methods provided by `CurrentUserStatusTransaction` should not update the status of any vendor or purpose which will always remain as enabled. When the `commit` method is called it will return `false`.
* If the IDs that are passed through the methods provided by `CurrentUserStatusTransaction` don’t correspond to vendors or purposes required by the Notice Config, they will be ignored.

**Requires SDK to be initialized**

Yes.

#### Parameters

No parameter.

**Returns**

An instance of the `CurrentUserStatusTransaction` class.

**Description of the** `CurrentUserStatusTransaction` **class**

<table><thead><tr><th width="207">Method</th><th width="233">Parameters</th><th>Returns</th><th>Description</th></tr></thead><tbody><tr><td><code>enablePurpose</code></td><td><code>id</code> (<code>String</code>): ID of the purpose to be enabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Enable a single purpose based on its ID.</td></tr><tr><td><code>enablePurposes</code></td><td><code>ids</code> (<code>[String]</code>): IDs of the purposes to be enabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Enable multiple purposes based on their IDs.</td></tr><tr><td><code>disablePurpose</code></td><td><code>id</code> (<code>String</code>): ID of the purpose to be disabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Disable a single purpose based on its ID.</td></tr><tr><td><code>disablePurposes</code></td><td><code>ids</code> (<code>[String]</code>): IDs of the purposes to be disabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Disable multiple purposes based on their IDs.</td></tr><tr><td><code>enableVendor</code></td><td><code>id</code> (<code>String</code>): Didomi ID of the vendor to be enabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Enable a single vendor based on its Didomi ID.</td></tr><tr><td><code>enableVendors</code></td><td><code>ids</code> (<code>[String]</code>): Didomi IDs of the vendors to be enabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Enable multiple vendors based on their Didomi IDs.</td></tr><tr><td><code>disableVendor</code></td><td><code>id</code> (<code>String</code>): Didomi ID of the vendor to be disabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Disable a single vendor based on its Didomi ID.</td></tr><tr><td><code>disableVendors</code></td><td><code>ids</code> (<code>[String]</code>): Didomi IDs of the vendors to be disabled.</td><td>Current <code>CurrentUserStatusTransaction</code> object.</td><td>Disable multiple vendors based on their Didomi IDs.</td></tr><tr><td><code>commit</code></td><td>No parameters.</td><td><code>Bool</code>: <code>true</code> if user status has been updated, <code>false</code> otherwise.</td><td>Commit the changes that have been made through other methods.</td></tr></tbody></table>

#### Examples

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomi = Didomi.shared
</strong>let transaction = didomi.openCurrentUserStatusTransaction()

// enable a purpose
transaction.enablePurpose("cookies")
// enable purposes
transaction.enablePurpose(["cookies", "analytics"])
// disable a purpose
transaction.enablePurpose("analytics")
// disable purposes
transaction.disablePurposes(["cookies", "analytics"])
// enable a vendor
transaction.enableVendor("vendor-1")
// enable vendors
transaction.enableVendors(["vendor-1","vendor-2"])
// disable a vendor
transaction.disableVendor("vendor-1")
// disable vendors
transaction.disableVendors(["vendor-1", "vendor-1"])

// Chain multiple calls
transaction.enablePurpose("cookies").disablePurpose("analytics")

// Save user choices
let updated = transaction.commit()
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
CurrentUserStatusTransaction *transaction = [didomi openCurrentUserStatusTransaction];

// Enable a purpose
[transaction enablePurpose:@"cookies"];
// Enable purposes
[transaction enablePurposes:@[@"cookies", @"analytics"]];
// Disable a purpose
[transaction disablePurpose:@"analytics"];
// Disable purposes
[transaction disablePurposes:@[@"cookies", @"analytics"]];
// Enable a vendor
[transaction enableVendor:@"vendor-1"];
// Enable vendors
[transaction enableVendors:@[@"vendor-1", @"vendor-2"]];
// Disable a vendor
[transaction disableVendor:@"vendor-1"];
// Disable vendors
[transaction disableVendors:@[@"vendor-1", @"vendor-2"]];

// Chain multiple calls
[[transaction enablePurpose:@"cookies"] disablePurpose:@"analytics"];

// Save user choices
BOOL updated = [transaction commit];
```
{% endtab %}
{% endtabs %}

### reset

**Definition**

Reset all the consent information for the current user. This will remove all consent information stored on the device by Didomi and will trigger re-collection of consent. The consent notice will be displayed again when `setupUI` is called.

If the SDK is not initialized when this method is called, the reset will be performed during SDK initialization.

**Requires SDK to be initialized**

No.

**Parameters**

No parameter.

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.reset()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi reset];
```
{% endtab %}
{% endtabs %}

### setCurrentUserStatus

#### Definition

Set the user status for purposes and vendors. This function will trigger events and API calls every time it is called (and the user status changes) so make sure to push all user choices at once and not one by one.

Please read [our article](https://support.didomi.io/analytics-with-a-custom-setup) on what to expect from your analytics when setting a custom behavior for your consent notice.

#### Parameters

Add the desired global status for each vendor and each purpose:

* the vendor status specified in this function will be reflected on the vendor’s layer.
  * vendor enabled : true → means the vendor is enabled in all the legal basis that this vendor uses.
  * vendor enabled : false → means the vendor is disabled in all the legal basis that this vendor uses
* the purposes status specified in this function will be reflected on the preferences layer.
  * purpose enabled : true → means the purpose is enabled in all the legal basis in which it’s defined.
  * purpose enabled : false → means the purpose is disabled in all the legal basis in which it’s defined.

#### Returns

`boolean`

`true` if the user choices have changed (i.e. the user had made different choices before this function got called).

#### Examples

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift">let currentUserStatus = CurrentUserStatus(
    purposes: ["purpose1": PurposeStatus(id: "purpose1", enabled: true)],
    vendors: ["vendor1": VendorStatus(id: "vendor1", enabled: true)]
)

<strong>let updated = Didomi.shared.setCurrentUserStatus(currentUserStatus)
</strong></code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMCurrentUserStatusPurpose *purposeStatus = [[DDMCurrentUserStatusPurpose alloc] initWithId:@"purpose1" enabled:true];
DDMCurrentUserStatusVendor *vendorStatus = [[DDMCurrentUserStatusVendor alloc] initWithId:@"vendor1" enabled:true];

NSDictionary<NSString *, DDMCurrentUserStatusPurpose *> *purposeStatuses = @{
    @"purpose1": purposeStatus
};

NSDictionary<NSString *, DDMCurrentUserStatusVendor *> *vendorStatuses = @{
    @"vendor1": vendorStatus
};

DDMCurrentUserStatus *currentUserStatus = [[DDMCurrentUserStatus alloc] initWithPurposes:purposeStatuses vendors:vendorStatuses];

Didomi *didomi = [Didomi shared];
bool updated = [didomi setCurrentUserStatusWithCurrentUserStatus:currentUserStatus];
```
{% endtab %}
{% endtabs %}

### setUserAgreeToAll

Report that the user has enabled consents and legitimate interests for all purposes and vendors configured for your app.

This function will log the user choice on our platform and close the notice.

Consent statuses for essential purposes are not stored.

Please read [our article](https://support.didomi.io/analytics-with-a-custom-setup) on what to expect from your analytics when setting a custom behavior for your consent notice.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

`Bool`

`true` if the user choices have changed (i.e. the user had made different choices before this function got called).

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.setUserAgreeToAll()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi setUserAgreeToAll];
```
{% endtab %}
{% endtabs %}

### setUserDisagreeToAll

Report that the user has disabled consents and legitimate interests for all purposes and vendors configured for your app.

This function will log the user choice on our platform and close the notice.

Consent statuses for essential purposes are not stored.&#x20;

Please read [our article](https://support.didomi.io/analytics-with-a-custom-setup) on what to expect from your analytics when setting a custom behavior for your consent notice.

**Requires SDK to be initialized**

Yes.

**Returns**

`Bool`

`true` if the user choices have changed (i.e. the user had made different choices before this function got called).

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.setUserDisagreeToAll()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi setUserDisagreeToAll];
```
{% endtab %}
{% endtabs %}

### shouldUserStatusBeCollected

#### Definition

Determine if user status (consent) should be collected for the visitor. Returns `true` if user status is required for the current user and one of following two conditions is met:

* User status has never been collected for this visitor yet
* New user status should be collected (as new vendors have been added) AND the number of days before recollecting them has exceeded

If none of these two conditions is met, the function returns `false`. This function is mainly present to allow you to know when to display your own notice if you have disabled our standard notice.

Requires SDK to be initialized.

#### **Parameters**

No parameter.

#### **Returns**

`boolean`

#### Examples

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.shouldUserStatusBeCollected()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi shouldUserStatusBeCollected];
```
{% endtab %}
{% endtabs %}

### setUser

The `setUser` function is used to configure settings specific to the user currently navigating the mobile app. It can be used in various scenarios, such as:

* Authenticating the user.&#x20;
* Enabling cross-device functionality. For detailed information, see [documentation](../../share-consents-across-devices).
* Setting user-specific attributes, like identifying the user as underage.

**Parameter:**

<table><thead><tr><th width="198">Name</th><th width="254">Type</th><th>Description</th></tr></thead><tbody><tr><td>parameters</td><td><code>DidomiUserParameters</code></td><td>Object containing properties required to set a user.</td></tr></tbody></table>

_**Description for**_ `DidomiUserParameters`_**:**_

<table><thead><tr><th width="193">Name</th><th width="219">Type</th><th>Description</th></tr></thead><tbody><tr><td>userAuth</td><td><code>UserAuth</code></td><td>User authentication object. Can be either <code>UserAuthWithoutParams</code>, <code>UserAuthWithEncryptionParams</code> or <code>UserAuthWithHashParams</code>.</td></tr><tr><td>dcsUserAuth</td><td><code>UserAuthParams?</code></td><td>Optional. Dedicated user with encryption or hash used for Didomi Consent String signature. Can be either <code>UserAuthWithEncryptionParams</code> or <code>UserAuthWithHashParams</code>.<br>This parameter can only be used if you are using the Didomi Consent String feature (This feature is currently in beta version)</td></tr><tr><td>containerController</td><td><code>UIViewController?</code></td><td>Optional. Activity of the application if the notice should be displayed when the consent expired or the user is new.</td></tr><tr><td>isUnderage</td><td><code>Boolean?</code></td><td>Optional. Whether the user is underage or not. This parameters can only be used if the Underage feature has been configured in your notice. (Underage is currently in beta version).</td></tr></tbody></table>

Parameters for `UserAuthWithoutParams` :

<table><thead><tr><th width="204">Name</th><th width="228">Type</th><th>Description</th></tr></thead><tbody><tr><td>id</td><td><code>String</code></td><td>Organization ID to associate with the user.</td></tr></tbody></table>

Parameters for `UserAuthWithEncryptionParams` :

<table><thead><tr><th width="211">Name</th><th width="202">Type</th><th>Description</th></tr></thead><tbody><tr><td>id</td><td><code>String</code></td><td>Organization ID to associate with the user.</td></tr><tr><td>algorithm</td><td><code>String</code></td><td>Algorithm used for computing the user ID.</td></tr><tr><td>secretId</td><td><code>String</code></td><td>ID of the secret used for the computing the user ID.</td></tr><tr><td>initializationVector</td><td><code>String</code></td><td>Initialization Vector used for encrypting the message.</td></tr><tr><td>expiration</td><td><code>TimeInterval?</code></td><td>Optional. Expiration time as UNIX timestamp (must be > 0).</td></tr></tbody></table>

Parameters for `UserAuthWithHashParams` :

<table><thead><tr><th width="212">Name</th><th width="205">Type</th><th>Description</th></tr></thead><tbody><tr><td>id</td><td><code>String</code></td><td>Organization ID to associate with the user.</td></tr><tr><td>algorithm</td><td><code>String</code></td><td>Algorithm used for computing the user ID.</td></tr><tr><td>secretId</td><td><code>String</code></td><td>ID of the secret used for the computing the user ID.</td></tr><tr><td>digest</td><td><code>String</code></td><td>Digest used for representing the user ID</td></tr><tr><td>salt</td><td><code>String?</code></td><td>Optional. Salt used for computing the user ID.</td></tr><tr><td>expiration</td><td><code>TimeInterval?</code></td><td>Optional. Expiration time as UNIX timestamp (must be > 0)</td></tr></tbody></table>

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.setUser(DidomiUserParameters(
            userAuth: UserAuthWithoutParams(
                        id: "e3222031-7c45-4f4a-8851-ffd57dbf0a2a"
            ), // user ID
            dcsUserAuth: UserAuthWithEncryptionParams(
                        id: "e3222031-7c45-4f4a-8851-ffd57dbf0a2b",
                        algorithm: "algorithm",
                        secretID: "secret_id",
                        initialisationVector: "initialization_vector",
                        expiration: 10000 // or null
            ), // optional DCS user authentication
            containerController: viewController, // optional View Controller
            isUnderage: true // optional underage flag
));

Didomi.shared.setUser(DidomiUserParameters(
            userAuth: UserAuthWithEncryptionParams(
                        id: "e3222031-7c45-4f4a-8851-ffd57dbf0a2a",
                        algorithm: "algorithm",
                        secretID: "secret_id",
                        initialisationVector: "initialization_vector",
                        expiration: 10000 // or nil
            ), // user authentication
            dcsUserAuth: UserAuthWithEncryptionParams(
                        id: "e3222031-7c45-4f4a-8851-ffd57dbf0a2b",
                        algorithm: "algorithm",
                        secretID: "secret_id",
                        initialisationVector: "initialization_vector",
                        expiration: 10000 // or nil
            ), // optional DCS user authentication
            containerController: viewController, // optional View Controller
            isUnderage: true // optional underage flag
));

Didomi.shared.setUser(DidomiUserParameters(
            userAuth: UserAuthWithHashParams(
                        id: "e3222031-7c45-4f4a-8851-ffd57dbf0a2a",
                        algorithm: "algorithm",
                        secretID: "secret_id",
                        digest: "digest",
                        salt: "salt", // or nil
                        expiration: 10000 // or nil
            ), // user authentication
            dcsUserAuth: UserAuthWithHashParams(
                        id: "e3222031-7c45-4f4a-8851-ffd57dbf0a2b",
                        algorithm: "algorithm",
                        secretID: "secret_id",
                        digest: "digest",
                        salt: "salt", // or nil
                        expiration: 10000 // or nil
            ), // optional DCS user authentication
            containerController: viewController, // optional View Controller
            isUnderage: true // optional underage flag
));
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DidomiUserParameters *params1 = [[DidomiUserParameters alloc] initWithUserAuth:
    [[UserAuthWithoutParams alloc] initWithId: @"e3222031-7c45-4f4a-8851-ffd57dbf0a2a"]
    dcsUserAuth:[[UserAuthWithEncryptionParams alloc] initWithId: @"e3222031-7c45-4f4a-8851-ffd57dbf0a2b"
                                                     algorithm: @"algorithm"
                                                     secretID: @"secret_id"
                                        initialisationVector: @"initialization_vector"
                                                   expiration: @10000]
    containerController: viewController
    isUnderage: @(YES)];
[[Didomi shared] setUser: params1];

DidomiUserParameters *params2 = [[DidomiUserParameters alloc] initWithUserAuth:
    [[UserAuthWithEncryptionParams alloc] initWithId: @"e3222031-7c45-4f4a-8851-ffd57dbf0a2a"
                                           algorithm: @"algorithm"
                                           secretID: @"secret_id"
                              initialisationVector: @"initialization_vector"
                                         expiration: @10000]
    dcsUserAuth:[[UserAuthWithEncryptionParams alloc] initWithId: @"e3222031-7c45-4f4a-8851-ffd57dbf0a2b"
                                                     algorithm: @"algorithm"
                                                     secretID: @"secret_id"
                                        initialisationVector: @"initialization_vector"
                                                   expiration: @10000]
    containerController: viewController
    isUnderage: @(YES)];
[[Didomi shared] setUser: params2];

DidomiUserParameters *params3 = [[DidomiUserParameters alloc] initWithUserAuth:
    [[UserAuthWithHashParams alloc] initWithId: @"e3222031-7c45-4f4a-8851-ffd57dbf0a2a"
                                     algorithm: @"algorithm"
                                     secretID: @"secret_id"
                                       digest: @"digest"
                                         salt: @"salt"
                                   expiration: @10000]
    dcsUserAuth:[[UserAuthWithHashParams alloc] initWithId: @"e3222031-7c45-4f4a-8851-ffd57dbf0a2b"
                                               algorithm: @"algorithm"
                                               secretID: @"secret_id"
                                                 digest: @"digest"
                                                   salt: @"salt"
                                             expiration: @10000]
    containerController: viewController
    isUnderage: @(YES)];
[[Didomi shared] setUser: params3];
```
{% endtab %}
{% endtabs %}

### clearUser

Remove custom user information from organization. This will also reset the Didomi User ID.

**Requires SDK to be initialized**

Yes.

**Parameters**

No parameter.

**Returns**

Nothing

#### Examples

{% tabs %}
{% tab title="Swift" %}
```swift
Didomi.shared.clearUser()
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
Didomi *didomi = [Didomi shared];
[didomi clearUser];
```
{% endtab %}
{% endtabs %}


# Events

The Didomi SDK triggers various events to notify you that the user has taken some action (changed their consent status, open the preferences screen, etc.) or that an important event has happened.

This section describes what events are available and how to subscribe to them.

## addEventListener

Add an event listener to catch events triggered by the SDK. Events listeners allow you to react to different events of interest. This function is safe to call before the `ready` event has been triggered.

**Requires SDK to be initialized**

No.

**Parameters**

| Name          | Type            | Description                                                      |
| ------------- | --------------- | ---------------------------------------------------------------- |
| eventListener | `EventListener` | The event listener. An instance of a subclass of `EventListener` |

**Returns**

Nothing

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onConsentChanged = { event in
</strong>    // The consent status of the user has changed
}

didomiEventListener.onHideNotice = { event in
    // The notice is being hidden
}

didomiEventListener.onShowNotice = { event in
    // The notice is being shown
}

Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];

[didomiEventListener setOnConsentChanged:^(enum DDMEventType event) {
    // The consent status of the user has changed
}];

[didomiEventListener setOnHideNotice:^(enum DDMEventType event) {
    // The notice is being hidden
}];

[didomiEventListener setOnShowNotice:^(enum DDMEventType event) {
    // The notice is being shown
}];

[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

### Event types <a href="#event-types" id="event-types"></a>

This section presents a comprehensive list of the event types exposed by the Didomi SDK and usage examples.

#### **onConsentChanged**

Triggered when a consent is given or withdrawn by the user. It's only triggered when the consent status actually changes. For instance, if the user saves consents without adding/removing any consent then this does not get called.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onConsentChanged = { event in
</strong>    // The consent status of the user has changed
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnConsentChanged:^(enum DDMEventType event) {
    // The consent status of the user has changed
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onHideNotice**

Triggered when the consent notice is hidden. If you have disabled our default consent notice to replace it with your own, you need to hide your custom notice when this event gets triggered.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onHideNotice = { event in
</strong>    // The notice is being hidden
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnHideNotice:^(enum DDMEventType event) {
    // The notice is being hidden
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onShowNotice**

Triggered when the consent notice gets displayed. If you have disabled our default consent notices to replace them with your own, you need to show your custom notice when this event gets triggered.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onShowNotice = { event in
    // The notice is being shown
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnShowNotice:^(enum DDMEventType event) {
    // The notice is being shown
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onNoticeClickAgree**

Triggered when the user clicks on agree on the notice.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onNoticeClickAgree = { event in
    // Click on agree on notice
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnNoticeClickAgree:^(enum DDMEventType event) {
    // Click on agree on notice
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onNoticeClickMoreInfo**

Triggered when the user clicks on learn more on the notice.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onNoticeClickMoreInfo = { event in
    // Click on learn more on notice
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnNoticeClickMoreInfo:^(enum DDMEventType event) {
    // Click on learn more on notice
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onHidePreferences**

Triggered when the preferences screen becomes hidden, for example when the user closes it or saves their consent.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onHidePreferences = { event in
    // The preferences screen is being hidden
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnHidePreferences:^(enum DDMEventType event) {
    // The preferences screen is being hidden
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onShowPreferences**

Triggered when the preferences screen gets displayed.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onShowPreferences = { event in
    // The preferences screen is being shown
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnShowPreferences:^(enum DDMEventType event) {
    // The preferences screen is being shown
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickAgreeToAll**

Triggered when the user clicks on agree to all on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickAgreeToAll = { event in
    // Click on agree to all on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickAgreeToAll:^(enum DDMEventType event) {
    // Click on agree to all on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickDisagreeToAll**

Triggered when the user clicks on disagree to all on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickDisagreeToAll = { event in
    // Click on disagree to all on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickDisagreeToAll:^(enum DDMEventType event) {
    // Click on disagree to all on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickPurposeAgree**

Triggered when the user agrees to a purpose on the preferences popup.

**Listener parameters**

* event: EventType (enum)
* purposeId: String

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickPurposeAgree = { event, purposeId in
    // Click on agree to a purpose on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickPurposeAgree:^(enum DDMEventType event, purposeId) {
    // Click on agree to a purpose on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickPurposeDisagree**

Triggered when the user disagrees to a purpose on the preferences popup. (purposeId provided as a parameter)

**Listener parameters**

* event: EventType (enum)
* purposeId: String

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickPurposeDisagree = { event, purposeId in
    // Click on disagree to a purpose on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickPurposeDisagree:^(enum DDMEventType event, purposeId) {
    // Click on disagree to a purpose on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickViewVendors**

Triggered when the user clicks on view vendors on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickViewVendors = { event in
    // Click view vendors on purposes view on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickViewVendors:^(enum DDMEventType event) {
    // Click view vendors on purposes view on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickViewSPIPurposes**

Triggered when the user clicks on view Sensitive Personal Information from the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onPreferencesClickViewSPIPurposes = { event in
</strong>    // User clicked on view Sensitive Personal Information from the preferences popup.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickViewSPIPurposes:^(enum DDMEventType event) {
    // User clicked on view Sensitive Personal Information from the preferences popup.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickSaveChoices**

Triggered when the user saves his choice on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickSaveChoices = { event in
    // Click on save on the purposes view on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickSaveChoices:^(enum DDMEventType event) {
    // Click on save on the purposes view on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

**onPreferencesClickVendorAgree**

Triggered when the user agrees to a vendor on the preferences popup.

**Listener parameters**

* event: EventType (enum)
* vendorId: String

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickVendorAgree = { event, vendorId in
    // Click on agree to a vendor on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickVendorAgree:^(enum DDMEventType event, vendorId) {
    // Click on agree to a vendor on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

**onPreferencesClickVendorDisagree**

Triggered when the user disagrees to a vendor on the preferences popup.

**Listener parameters**

* event: EventType (enum)
* vendorId: String

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickVendorDisagree = { event, vendorId in
    // Click on disagree to a vendor on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickVendorDisagree:^(enum DDMEventType event, vendorId) {
    // Click on disagree to a vendor on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickVendorSaveChoices**

This happens when the user saves his choice on the vendors view on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickVendorSaveChoices = { event in
    // Click on save on the vendors view on preferences popup
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickVendorSaveChoices:^(enum DDMEventType event) {
    // Click on save on the vendors view on preferences popup
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onNoticeClickDisagree**

Triggered when the user clicks on disagree on the notice.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onNoticeClickDisagree = { event in
    // Select disagree on the notice
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnNoticeClickDisagree:^(enum DDMEventType event) {
    // Select disagree on the notice
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onNoticeClickViewVendors**

Triggered when the user clicks on partners on the notice.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onNoticeClickViewVendors = { event in
    // Select Our Partners on the notice
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnNoticeClickViewVendors:^(enum DDMEventType event) {
    // Select Our Partners on the notice
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onNoticeClickViewSPIPurposes**

Triggered when the user clicks on Sensitive Personal Information from the notice.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onNoticeClickViewSPIPurposes = { event in
</strong>    // User clicked on Sensitive Personal Information from the notice.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnNoticeClickViewSPIPurposes:^(enum DDMEventType event) {
    // User clicked on Sensitive Personal Information from the notice.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onNoticeClickPrivacyPolicy**

Triggered when the user clicks on privacy policy on the notice (available on TV only).

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onNoticeClickPrivacyPolicy = { event in
    // Select Our Privacy Policy on the notice (tvOS only)
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnNoticeClickPrivacyPolicy:^(enum DDMEventType event) {
    // Select Our Privacy Policy on the notice (tvOS only)
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickAgreeToAllPurposes**

Triggered when the user flips ON all purposes switch on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickAgreeToAllPurposes = { event in
    // Agree to all purposes using the bulk action button on the preferences screen
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickAgreeToAllPurposes:^(enum DDMEventType event) {
    // Agree to all purposes using the bulk action button on the preferences screen
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickDisagreeToAllPurposes**

Triggered when the user flips OFF all purposes switch on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickDisagreeToAllPurposes = { event in
    // Disagree to all purposes using the bulk action button on the preferences screen
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickDisagreeToAllPurposes:^(enum DDMEventType event) {
    // Disagree to all purposes using the bulk action button on the preferences screen
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickAgreeToAllVendors**

Triggered when the user flips ON all vendors switch on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickAgreeToAllVendors = { event in
    // Agree to all vendors using the bulk action button on the preferences screen
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickAgreeToAllVendors:^(enum DDMEventType event) {
    // Agree to all vendors using the bulk action button on the preferences screen
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickDisagreeToAllVendors**

Triggered when the user flips OFF all vendors switch on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickDisagreeToAllVendors = { event in
    // Disagree to all vendors using the bulk action button on the preferences screen
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickDisagreeToAllVendors:^(enum DDMEventType event) {
    // Disagree to all vendors using the bulk action button on the preferences screen
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickViewPurposes**

Triggered when the user clicks on view purposes on the preferences popup.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
didomiEventListener.onPreferencesClickViewPurposes = { event in
    // Select displaying the purposes on the preferences screen
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickViewPurposes:^(enum DDMEventType event) {
    // Select displaying the purposes on the preferences screen
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickSPIPurposeAgree**

Triggered when the toggle linked to a Personal Data purpose is set to agree/enabled.

**Listener parameters**

* event: EventType (enum)
* purposeId: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onPreferencesClickSPIPurposeAgree = { event, purposeId in
</strong>    // Toggle linked to a Personal Data purpose was set to agree/enabled.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickSPIPurposeAgree:^(enum DDMEventType event, NSString * _Nullable purposeId) {
    // Toggle linked to a Personal Data purpose was set to agree/enabled.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickSPIPurposeDisagree**

Triggered when the toggle linked to a Personal Data purpose is set to disagree/disabled.

**Listener parameters**

* event: EventType (enum)
* purposeId: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onPreferencesClickSPIPurposeDisagree = { event, purposeId in
</strong>    // Toggle linked to a Personal Data purpose was set to disagree/disabled.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickSPIPurposeDisagree:^(enum DDMEventType event, NSString * _Nullable purposeId) {
    // Toggle linked to a Personal Data purpose was set to disagree/disabled.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickSPICategoryAgree**

Triggered when the toggle linked to a Personal Data category is set to agree/enabled.

**Listener parameters**

* event: EventType (enum)
* categoryId: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onPreferencesClickSPICategoryAgree = { event, categoryId in
</strong>    // Toggle linked to a Personal Data category was set to agree/enabled.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickSPICategoryAgree:^(enum DDMEventType event, NSString * _Nullable categoryId) {
    // Toggle linked to a Personal Data category was set to agree/enabled.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickSPICategoryDisagree**

Triggered when the toggle linked to a Personal Data category is set to disagree/disabled.

**Listener parameters**

* event: EventType (enum)
* categoryId: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onPreferencesClickSPICategoryDisagree = { event, categoryId in
</strong>    // Toggle linked to a Personal Data category was set to disagree/disabled.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickSPICategoryDisagree:^(enum DDMEventType event, NSString * _Nullable categoryId) {
    // Toggle linked to a Personal Data category was set to disagree/disabled.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onPreferencesClickSPIPurposeSaveChoices**

Triggered when the Save button from the Sensitive Personal Information screen is pressed.

**Listener parameters**

* event: EventType (enum)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onPreferencesClickSPIPurposeSaveChoices = { event in
</strong>    // Save button from the Sensitive Personal Information screen was pressed.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnPreferencesClickSPIPurposeSaveChoices:^(enum DDMEventType event) {
    // Save button from the Sensitive Personal Information screen was pressed.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onSyncUserChanged**

Triggered when the user is changed from [setUser](../api#setuser) function only if sync is enabled.

**Listener parameters**

*   `SyncUserChangedEvent`: object

    | Property | Type     | Description                                                                                          |
    | -------- | -------- | ---------------------------------------------------------------------------------------------------- |
    | userAuth | UserAuth | The new user as `UserAuthWithoutParams`, `UserAuthWithEncryptionParams` or `UserAuthWithHashParams`. |

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onSyncUserChanged = { event in
</strong>    let userAuth = event.userAuth
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener onSyncUserChanged:^(DDMSyncUserChangedEvent event) {
    NSUserAuth *userAuth = event.userAuth;
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onSyncDone**

{% hint style="warning" %}
This event has been deprecated. Use [onSyncReady](#onsyncready) instead.
{% endhint %}

Triggered when the consent synchronization is successful (Cross-device).

**Listener parameters**

* event: EventType (enum)
* organizationUserId: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onSyncDone = { event, organizationUserId in
</strong>    // The consent synchronization was successful.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnSyncDone:^(enum DDMEventType event, NSString * _Nullable organizationUserId) {
    // The consent synchronization was successful.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onSyncError**

Triggered when the consent synchronization has failed (Cross-device).

**Listener parameters**

* event: EventType (enum)
* error: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onSyncError = { event, error in
</strong>    // The consent synchronization has failed.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnSyncError:^(enum DDMEventType event, NSString * _Nullable error) {
    // The consent synchronization has failed.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onSyncReady**

Triggered when the user status synchronization is ready (Cross-device).

**Listener parameters**

`SyncReadyEvent` object

| Property           | Type              | Description                                                                                                                                                                                          |
| ------------------ | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| organizationUserId | String            | The organization user ID (OUID) used for the sync.                                                                                                                                                   |
| statusApplied      | Boolean           | Indicates if the user status has been applied locally from the remote Didomi backend. `true` if the user status was applied from the remote, `false` otherwise.                                      |
| syncAcknowledged   | Lambda expression | Callback that can be used to communicate to the Didomi servers that the synchronization has been communicated to the user. Returns `true` if the API event was successfully sent, `false` otherwise. |

**Example**

{% tabs %}
{% tab title="Swift" %}
```swift
let didomiEventListener = EventListener()

didomiEventListener.onSyncReady = { event in
    // User status synchronization was successful.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
```
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnSyncReady:^(DDMEventReady event) {
    // The consent synchronization was successful.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onLanguageUpdated**

Triggered when SDK language has been successfully changed.

**Listener parameters**

* event: EventType (enum)
* languageCode: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onLanguageUpdated = { event, languageCode in
</strong>    // SDK language has been successfully changed.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnLanguageUpdated:^(enum DDMEventType event, NSString * _Nullable languageCode) {
    // SDK language has been successfully changed.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}

#### **onLanguageUpdateFailed**

Triggered when SDK language update has failed. (reason provided as a parameter)

**Listener parameters**

* event: EventType (enum)
* reason: String (nullable/optional)

**Example**

{% tabs %}
{% tab title="Swift" %}
<pre class="language-swift"><code class="lang-swift"><strong>let didomiEventListener = EventListener()
</strong>
<strong>didomiEventListener.onLanguageUpdateFailed = { event, reason in
</strong>    // SDK language update has failed.
}
Didomi.shared.addEventListener(listener: didomiEventListener)
</code></pre>
{% endtab %}

{% tab title="Objective-C" %}
```objectivec
DDMEventListener *didomiEventListener = [[DDMEventListener alloc] init];
[didomiEventListener setOnLanguageUpdateFailed:^(enum DDMEventType event, NSString * _Nullable reason) {
    // Event was triggered.
}];
[didomi addEventListenerWithListener:didomiEventListener];
```
{% endtab %}
{% endtabs %}


# Share consent with WebViews

If your mobile app sometimes opens WebViews or Chrome Custom Tabs to display specific content to the user, you should ensure that consent is passed from your app to the website loaded in the WebView or Chrome Custom Tab. That will ensure that the user does not have to give consent again in WebViews or Chrome Custom Tabs.

The setup is the following:

* Collect consent in your app with the Didomi native SDKs
* Launch a WebView or a Chrome Custom Tab with the Didomi Web SDK embedded in it
* Inject JavaScript into the WebView to pass consent information from the native app

This guide assumes that you have already setup the Didomi native SDKs in your Android or iOS app, and that you have setup our Web SDK in the HTML pages loaded into your WebViews or Chrome Custom Tabs.

{% hint style="danger" %}
**SDK requirements**\
The minimum SDK versions that support passing TCF v2 consent to a WebView are 1.26.1 (Android) and 1.38.0 (iOS).

The minimum SDK version that supports passing consent to a Chrome Custom Tab is 1.17.0 (Android).
{% endhint %}

{% hint style="info" %}
If your app is a web application embedded through a WebView or a PWA, we recommend [using our Web SDK](../web-sdk) rather than our native mobile SDKs.
{% endhint %}

## Web SDK configuration in the WebView or Chrome Custom Tab

You need to embed the Didomi Web SDK in the HTML page that is loaded by the WebView or the Chrome Custom Tab so that it can collect the consent information passed from the app and share it with vendors.

The list of vendors configured in the web SDK in the WebView should be a subset of the list of vendors configured in the mobile app. That will ensure that the WebView has all the consent information it needs and does not re-collect consent. Examples:

| Configuration                                                                                         | WebView behavior                                                                                              |
| ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Vendors in the mobile app and the WebView are the same                                                | WebView will not display the consent UI and will use the consent information provided by the mobile app as is |
| Vendors in the WebView are a subset of the vendors in the mobile app                                  | WebView will not display the consent UI and will use the consent information provided by the mobile app as is |
| Vendors in the mobile app are a subset of the vendors in the WebView, or there is no vendor in common | WebView will display the consent UI and collect user consent for the vendors that are specific to the WebView |

Other parameters of the web SDK can be configured freely, in particular with respect to the IAB framework and tags management.

## Inject consent information into the WebView or Chrome Custom Tab

Passing consent to a WebView or to a Chrome Custom Tab is a slightly different operation. Read below for specific instructions based on the method you are using.

### WebViews (Android and iOS)

The consent status can be passed to the Web SDK by embedding JavaScript code into your WebView.

{% hint style="warning" %}
On Android, make sure JavaScript is enabled on the WebView. In some configurations (for example, when using a custom domain), enabling DOM storage is also necessary.
{% endhint %}

The Android and iOS SDKs automatically generate the required JavaScript code for you with the `getJavaScriptForWebView` method. Call that method and embed the returned string into your WebView:

{% tabs %}
{% tab title="Kotlin" %}
```kotlin
webView.settings.javaScriptEnabled = true
webView.settings.domStorageEnabled = true

val didomi = Didomi.getInstance()
didomi.onReady {
    val didomiJavaScriptCode = didomi.getJavaScriptForWebView()
    webView.evaluateJavascript(didomiJavaScriptCode) { s ->
    }
}
```
{% endtab %}

{% tab title="Java" %}
```java
webView.getSettings().setJavaScriptEnabled(true);
webView.getSettings().setDomStorageEnabled(true);

final Didomi didomi = Didomi.getInstance();
didomi.onReady(() -> {
    String didomiJavaScriptCode = didomi.getJavaScriptForWebView();
    webView.evaluateJavascript(didomiJavaScriptCode, s -> {
    });
});
```
{% endtab %}

{% tab title="Swift" %}
```swift
Didomi.shared.onReady {
    let didomiJavaScriptCode = Didomi.shared.getJavaScriptForWebView()
    webView.evaluateJavaScript(didomiJavaScriptCode, completionHandler: nil)
}
```
{% endtab %}
{% endtabs %}

### Chrome Custom Tabs (Android only)

#### Android SDK

As Chrome Custom Tabs do not allow embedding JavaScript into a web page, the consent status of the user can be passed to the Web SDK by appending a query string parameter to the URL loaded by the Chrome Custom Tab. That query string parameter will contain the current status of the user and will be read by the Web SDK.

{% tabs %}
{% tab title="Kotlin" %}
```kotlin
val didomi = Didomi.getInstance()
didomi.onReady {
    val didomiQueryString = didomi.queryStringForWebView
    val url = "https://www.website.com/?$didomiQueryString"
}
```
{% endtab %}

{% tab title="Java" %}
```java
final Didomi didomi = Didomi.getInstance();
didomi.onReady(() -> {
    String didomiQueryString = didomi.getQueryStringForWebView();
    String url = "https://www.website.com/?" + didomiQueryString;
});
```
{% endtab %}
{% endtabs %}

The [`getQueryStringForWebView`](../android/reference/api#getquerystringforwebview) method returns a query string parameter with the format `didomiConfig.user.externalConsent.value=...`. It can be appended to your URL after a `?` or a `&` if your URL already contains a query string.

Example of a full URL: `https://www.website.com/?didomiConfig.user.externalConsent.value=...`

#### Web SDK

The Web SDK needs to be configured to read the user consent from the query string as that behavior is disabled by default. To do so, update your custom JSON or your local `didomiConfig` with:

```javascript
{
  user: {
    externalConsent: {
      enabled: true
    }
  }
}
```

## Hide the notice in the WebView or Chrome Custom Tab

The notice should automatically get hidden in the WebView as consent is passed from the mobile app to the website. However, it might happen that the notice gets displayed for a very short time before being hidden.

To avoid that visual glitch, you can disable the notice in your WebView or Chrome Custom Tab to make sure that it never shows by appending `didomiConfig.notice.enable=false` to the query string of the URL that you are loading:

```http
{{YOUR_WEBSITE_URL}}?didomiConfig.notice.enable=false
```

If the notice still shows in the WebView or Chrome Custom Tab when navigating to another page, ensure that the list of vendors and purposes is the same between the mobile app and the website that is loaded in the WebView or Chrome Custom Tab.
