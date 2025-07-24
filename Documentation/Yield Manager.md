# Yield Manager

## Ad Units

Ad Units are representations of spaces on your website where you want ads to render/show up.

By defining your Ad Units in Yield Manager, you can specify the areas **where** advertising can be displayed to your audience, which **sizes** are valid for these areas, at which **time**, and under what **conditions** they should get rendered, and many other important and useful things that you can find below.

The **Placements tab** in the Yield Manager App is where you can handle **Placements**, **Ad Units**, and **HTML Units**. These are the basic blocks of your setup, and each one of them has its own table where you can define them.

### Ad Units and Placements

In Yield Manager, the conceptual idea of Ad Units is split into two parts: **Placements** and **Ad Units**.

A Placement will hold information about places on your page, whereas Ad Units will hold information such as the size and the bidders that can bid on that Ad Unit. Once you have your Ad Units defined, you can associate them with the Placements you have.

### Placements table

In the Placements table, you can define the following:

| Name            | Description                                                                                                                   |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Enabled         | Whether this Placement is enabled or not. If not enabled, it will be completely ignored by Yield Manager.                     |
| Enable If       | If provided, the Placement will only be enabled if all conditions evaluate to be true.                                        |
| Identifier Name | The GPT HTML div ID (e.g. div-gpt-ad-header). Ensure no two enabled Placements use the same Identifier Name at the same time. |
| Internal Name   | A unique name to identify this Placement in Yield Manager.                                                                    |
| Inject          | Whether Yield Manager should add the Placement for you. If disabled, you'll have to add the Placement manually.               |
| Placement       | CSS selector to match elements where Ad Units should be placed.                                                               |
| Position        | Placement position relative to the element: beforebegin, afterbegin, beforeend, afterend.                                     |
| Fetch Trigger   | When the Prebid auction should start. Multiple triggers allowed.                                                              |
| Render Trigger  | When the ad should be rendered. Multiple triggers allowed.                                                                    |
| Lazy Fetch      | Auction starts when the target is in or near view.                                                                            |
| Lazy Render     | Rendering starts when the target is in or near view.                                                                          |
| Slug            | If enabled, a placeholder with "Ad" will be shown.                                                                            |
| Style           | CSS styles to apply to the Ad Unit.                                                                                           |
| Units           | Linked Ad Units/HTML Units for the Placement.                                                                                 |

### Ad Units table

In the Ad Units table, you can define the following:

| Name          | Description                                                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Enabled       | Whether this Ad Unit is enabled.                                                                                                                  |
| Enable If     | If provided, will only be enabled if conditions are met.                                                                                          |
| Internal Name | Unique identifier in Yield Manager.                                                                                                               |
| Ad Unit Path  | GPT full Ad Unit path (e.g. /19968336/header-bid-tag-0). [More info](https://developers.google.com/publisher-tag/guides/get-started#ad-unit-path) |
| Media Types   | 'banner' or 'video - outstream'.                                                                                                                  |
| Sizes         | Valid sizes (e.g. \[300,250]). Use `v640x480` for video.                                                                                          |
| Refresh       | Numeric value in seconds or a "refresh control".                                                                                                  |

### Importing Ad Units from JSON

You can import units from a JSON object to speed up migration.

#### How to import

Click the **upload icon** in the **Ad Units table** to paste your JSON object.
A preview component will show what will be imported. Click **Import** to proceed.

#### JSON object format

The object must be an **array** of **objects** following the [Prebid Ad Units object](https://docs.prebid.org/dev-docs/adunit-reference.html), with the required `path` property. `name` is optional.

Only `code` and `path` are mandatory. Others will be ignored if invalid.

Example:

```json
[
    {
        "code": "div-0",
        "path": "/19968336/header-bid-tag-0",
        "mediaTypes": {
            "banner": { "sizes": [[300, 250], [300, 600]] }
        },
        "bids": [{
            "bidder": "appnexus",
            "params": { "placementId": 13144370 }
        }]
    },
    {
        "code": "div-1",
        "path": "/19968336/header-bid-tag-1",
        "mediaTypes": {
            "banner": { "sizes": [728, 90] }
        },
        "bids": [{
            "bidder": "appnexus",
            "params": { "placementId": 13144370 }
        }]
    }
]
```

## Bidders

In the Bidders tab, you set up your Prebid Bidder adapters.

### Prebid Bidders table

Define your Prebid Bidders and their parameters.

#### Adding a new Bidder

Use the dropdown at the top right of the table. You can also create a new one by typing a name.

#### Bidders Parameters

You can set parameters:

* Via the *Params* column.
* Or via the *Params Template* column (advanced).

**Note:** Editing the *Params Template* overrides the *Params* column.

##### Params Template column

Allows code-based config. Useful for static params or referencing variables like:

```json
{ "siteId": "[[siteId]]" }
```

##### Overriding Bidder Params for an Ad Unit

In the Ad Unit table, expand a row to override bidder params. Grayed-out values mean default is used. You can reset to default using the globe icon.

To disable a bidder for a specific Ad Unit:

* Set override params to `{}`
* Or leave all related Placement ID table values empty.

### Placement IDs table

Specify values for params set in the Bidders table. Allows default and conditional groups (e.g. domain-specific).

Default group must have all values set. Other groups can inherit from it.

#### Import params from JSON

Click the upload icon near a group name.

JSON must include `code` and a `bids` array with `bidder` and `params`. `name` is optional.

Example:

```json
[
    {
        "code": "header",
        "bids": [{
            "bidder": "pubmatic",
            "params": { "publisherId": "13144370" }
        }]
    },
    {
        "code": "ignored",
        "name": "my-ad-unit-2",
        "bids": [
            {
                "bidder": "appnexus",
                "params": { "placementId": 13144370 }
            },
            {
                "name": "appnexus-2",
                "bidder": "appnexus",
                "params": { "placementId": 13144371 }
            }
        ]
    }
]
```

## Namespace

Namespace aggregates **Variables**, **Conditions**, **Triggers**, and **Refresh Controls**.

### Variables

Used in field values and conditions. Includes built-in and custom variables.

### Condition sets

A set of inner conditions defined by a `name`, `operator`, and `value`.

#### Operators

Available: `equal`, `less than`, `greater than`, `not equal`, `contains`, `regex`, etc. Numeric comparisons cast strings to numbers.

### Triggers

Triggers determine when Ad/HTML units activate.

Each trigger has an `event` and optional `condition sets`. When the event fires and conditions match, the trigger fires.

#### Fetch Trigger

* For Ad Units: When to start Prebid auction.

#### Render Trigger

* For Ad and HTML Units: When to render or execute them.

#### Trigger Events

| Name                   | When it happens                                                         |
| ---------------------- | ----------------------------------------------------------------------- |
| Script Loaded          | When YM script starts. (HTML Units only)                                |
| Window Ready           | `document.readyState` is `interactive`.                                 |
| Window Loaded          | `document.readyState` is `complete`.                                    |
| Consent Initialization | When CMP is loaded and ready.                                           |
| Manual event           | On calling `ayManagerEnv.dispatchManualEvent()` after DOMContentLoaded. |

## Settings

General and Prebid-specific settings.

### Yield Manager

#### Yield Manager Script Version

Choose version in settings. A warning will show if a feature isn’t supported in your current version.

### Prebid.js

#### Custom bid pool feature

All bids go into a shared pool. YM assigns highest matching bids to compatible Ad Units.

##### Include and Exclude filters

* **Include**: All items included unless a list is given.
* **Exclude**: Remove items from the inclusion set.

## Yield Manager Legacy Mode

Access via **YM Legacy UI** switcher. Use it for emergency deployments on the previous major version.

**Note:** Changes in Legacy Mode aren’t reflected in the current workspace and vice versa. Use only for emergencies.

## Yield Manager Client Script

### Ad Unit Instances

Defined in the UI tables, but when the YM script runs, each Ad Unit can have multiple **instances**.

Each instance is based on the Ad Unit + its context. Instance codes are variants of the Ad Unit’s Identifier Name.

If you use:

* `inject=false` and place the same code multiple times, or
* define a selector that matches multiple elements

Then multiple Ad Unit Instances will be created on the page.


# Client API

## ayManagerEnv

The global namespace that Yield Manager uses for its API.

### Method Summary

| Name                  | Description                                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cmd`                 | The Yield Manager actions queue for asynchronous execution of related calls.                                                                                  |
| `refresh`             | Makes a new request for bids and refreshes Ad Unit slots with new ad content.                                                                                 |
| `fetch`               | Request new bids for Ad Unit instances.                                                                                                                       |
| `render`              | Sets the targeting and calls `pubads().refresh` on the slot of Ad Unit instances. Effectively rendering any winning bids that were fetched and are available. |
| `reset`               | Destroy the slots for Ad Unit instances, reset their status, and remove their container from the page.                                                        |
| `destroy`             | Destroy the Ad Unit instances. Prevents further auto-injection until `restore()` is called.                                                                   |
| `restore`             | Reverts the second step of the `destroy` API method, restoring DOM elements.                                                                                  |
| `trigger`             | Attempt to trigger Ad Unit instances.                                                                                                                         |
| `changePage`          | Triggers the page change flow.                                                                                                                                |
| `dispatchManualEvent` | Fires the manual event used by triggers.                                                                                                                      |
| `onEvent`             | Registers a callback invoked when events are fired.                                                                                                           |
| `offEvent`            | Turns off an event callback defined with `onEvent`.                                                                                                           |

---

### `cmd`

Reference to the command queue for asynchronous execution of Yield Manager's related calls.

To push calls:

```html
<script>
    window.ayManagerEnv = window.ayManagerEnv || { cmd: [] };
    window.ayManagerEnv.cmd.push(() => {
        console.log("when the Yield Manager script finally loads, it will run this code.");
    });
</script>
```

#### Signature

```js
ayManagerEnv.cmd
```

#### Types

```js
/** @type { Array<() => void> } */
```

---

### `refresh`

Makes a new request for bids and refreshes Ad Unit slots with new ad content.

Modes:

* `visible`: refresh visible instances
* `near`: refresh instances within offset
* `page`: default, refresh instances queryable in DOM

#### Signature

```js
ayManagerEnv.refresh([placementCodes], [options]);
```

#### Types

```js
/**
 * @param { Array<String> } [placementCodes]
 * @param { Object } [options]
 * @param { ("visible"|"near"|"page") } [options.mode]
 * @param { Number } [options.offset]
 * @param { Boolean } [options.useInstanceCodes]
 * @param { Boolean } [options.preFetch]
 * @param { Boolean } [options.onlyUpdateViewedAt]
 * @param { Boolean } [options.ignoreRefreshLimits]
 * @returns { void }
 */
```

---

### `fetch`

Request new bids for Ad Unit instances.

Modes:

* `visible`: fetch for visible instances
* `near`: fetch for instances within offset
* `page`: default, fetch for instances queryable in DOM

#### Signature

```js
ayManagerEnv.fetch([placementCodes], [options]);
```

#### Types

```js
/**
 * @param { Array<String> } [placementCodes]
 * @param { Object } [options]
 * @param { ("visible"|"near"|"page") } [options.mode]
 * @param { Number } [options.offset]
 * @param { Boolean } [options.useInstanceCodes]
 * @returns { void }
 */
```

---

### `render`

Sets the targeting and calls `pubads().refresh` on Ad Unit instances.

Modes:

* `visible`: render visible instances
* `near`: render within offset
* `page`: default

#### Signature

```js
ayManagerEnv.render([placementCodes], [options]);
```

#### Types

```js
/**
 * @param { Array<String> } [placementCodes]
 * @param { Object } [options]
 * @param { ("visible"|"near"|"page") } [options.mode]
 * @param { Number } [options.offset]
 * @param { Boolean } [options.useInstanceCodes]
 * @returns { void }
 */
```

---

### `reset`

Destroys Ad Unit instance slots, resets their status, and removes their container from the page.

Modes:

* `visible`: reset visible instances
* `near`: reset within offset
* `page`: default

#### Signature

```js
ayManagerEnv.reset([placementCodes], [options]);
```

#### Types

```js
/**
 * @param { Array<String> } [placementCodes]
 * @param { Object } [options]
 * @param { ("visible"|"near"|"page") } [options.mode]
 * @param { Number } [options.offset]
 * @param { Boolean } [options.useInstanceCodes]
 * @returns { void }
 */
```

---

### `destroy`

Destroys Ad Unit instances and prevents further auto-injection until `restore()` is called.

Modes:

* `visible`
* `near`
* `page`: default

#### Signature

```js
ayManagerEnv.destroy([placementCodes], [options]);
```

#### Types

```js
/**
 * @param { Array<String> } [placementCodes]
 * @param { Object } [options]
 * @param { ("visible"|"near"|"page") } [options.mode]
 * @param { Number } [options.offset]
 * @param { Boolean } [options.useInstanceCodes]
 * @returns { void }
 */
```

---

### `restore`

Reverts changes made by `destroy()` by restoring DOM elements so `changePage()` will act on them again.

#### Signature

```js
ayManagerEnv.restore([adUnitCodes]);
```

#### Types

```js
/**
 * @param { Array<String> } [adUnitCodes]
 * @returns { void }
 */
```

---

### `trigger`

Triggers Ad Unit instances' fetch/render flow.

Modes:

* `visible`
* `near`
* `page`: default

#### Signature

```js
ayManagerEnv.trigger([placementCodes], [options]);
```

#### Types

```js
/**
 * @param { Array<String> } [placementCodes]
 * @param { Object } [options]
 * @param { ("visible"|"near"|"page") } [options.mode]
 * @param { Number } [options.offset]
 * @param { Boolean } [options.useInstanceCodes]
 * @returns { void }
 */
```

---

### `changePage`

Triggers the page change flow.

Depending on `options.refresh` and `options.reset`:

* If both false (default):

  1. Reset outdated/removed instances
  2. Inject valid ones
* If `refresh` is true:

  1. Reset outdated/removed instances
  2. Refresh all
  3. Inject valid ones
* If `reset` is true:

  1. Remove all instances
  2. Inject valid ones

> ⚠️ Call only when the new page's DOM is fully inserted.

#### Signature

```js
ayManagerEnv.changePage([options]);
```

#### Types

```js
/**
 * @param { Object } [options]
 * @param { Boolean } [options.refresh]
 * @param { Boolean } [options.reset]
 * @returns { void }
 */
```

# Event Handlers

Yield Manager emits multiple events allowing you to extend or modify behavior with custom code.

With the `onEvent` API function, an event listener can be registered for the listed events:

```js
ayManagerEnv.onEvent('afterDefineSlot', function(adUnitInstanceCode, slot) {
    console.log(`New slot defined with instance code ${adUnitInstanceCode} and ad unit path ${slot.getAdUnitPath()}`);
});
```

## Events

| Name                                                                                                                | Description                                                     | Available Since | Callback Arguments                                     |
| ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | --------------- | ------------------------------------------------------ |
| [error](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#error)                                   | An error has been detected by YM.                               | 3.0.0           | First arg: error object, Second arg: debug info object |
| beforePageChange                                                                                                    | The changePage flow will run.                                   | 3.0.0           | None                                                   |
| afterPageChange                                                                                                     | The changePage flow is complete.                                | 3.0.0           | None                                                   |
| [beforeDefineSlot](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#beforedefineslot)             | `googletag.defineSlot` will be called for an ad unit instance.  | 3.0.0           | Instance code, info object                             |
| [afterDefineSlot](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#afterdefineslot)               | `googletag.defineSlot` was just called for an ad unit instance. | 3.0.0           | Instance code, slot object                             |
| [beforeRefresh](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#beforerefresh)                   | Emitted before auctions run. **(unstable\*)**                   | 3.0.0           | Array of instance codes                                |
| [afterRefresh](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#afterrefresh)                     | Emitted after `googletag.pubads().refresh`. **(unstable\*)**    | 3.0.0           | Array of instance codes                                |
| [beforeApsInit](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#beforeapsinit)                   | Before `apstag.init` call.                                      | 3.0.0           | APS config object                                      |
| [afterApsInit](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#afterapsinit)                     | After apstag initialization.                                    | 3.0.0           | APS config object                                      |
| [prebidBeforeFetchBids](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#prebidbeforefetchbids)   | Before `pbjs.requestBids`.                                      | 3.0.0           | Object with ad units and timeout                       |
| [apsBeforeFetchBids](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#apsbeforefetchbids)         | Before `apstag.fetchBids`.                                      | 3.0.0           | Object with slots and timeout                          |
| [beforeDefineAdUnitPath](https://suite.assertiveyield.com/docs/yield-manager/event-handlers#beforeDefineAdUnitPath) | After parsing `adUnit.path` but before using it in auctions.    | 3.2.0           | Ad unit instance object                                |

\* **Note:** These event arguments and timings may change in future versions.

## Callback Arguments

### beforeDefineSlot

| Argument            | Type                                       |
| ------------------- | ------------------------------------------ |
| adUnitInstanceCode  | string                                     |
| slotArgs.adUnitPath | string                                     |
| slotArgs.size       | `[number, number]` or `[number, number][]` |
| slotArgs.div        | string                                     |

### afterDefineSlot

| Argument           | Type                            |
| ------------------ | ------------------------------- |
| adUnitInstanceCode | string                          |
| slot               | `googletag.Slot` or `undefined` |

### beforeRefresh

| Argument            | Type       |
| ------------------- | ---------- |
| adUnitInstanceCodes | `string[]` |

### afterRefresh

| Argument            | Type       |
| ------------------- | ---------- |
| adUnitInstanceCodes | `string[]` |

### beforeApsInit / afterApsInit

| Argument | Type     |
| -------- | -------- |
| config   | `object` |

### prebidBeforeFetchBids

| Argument           | Type       |
| ------------------ | ---------- |
| requestObj.adUnits | `object[]` |
| requestObj.timeout | `number`   |

### apsBeforeFetchBids

| Argument             | Type       |
| -------------------- | ---------- |
| bidConfig.slots      | `object[]` |
| bidConfig.bidTimeout | `number`   |

### beforeDefineAdUnitPath

| Argument      | Type                             |
| ------------- | -------------------------------- |
| partialAdUnit | `{ code: string, path: string }` |

---

# Advanced Integrations

Below you will find more advanced integrations using HTML units, where there is no UI support yet.

## Targeting / Key-Values

```js
<script type="text/javascript">
    // page level targeting
    googletag.cmd.push(function() {
        googletag.pubads().setTargeting('ay_ym', 'on');
    });

    // slot level targeting
    ayManagerEnv.onEvent("afterDefineSlot", function(adUnitInstanceCode, slot) {
        var targetingMap = {
            'pos': adUnitInstanceCode.replace(/__ayManagerEnv__.+$/, '')
        };
        slot.updateTargetingFromMap(targetingMap);
    });
</script>
```

## Interstitial and Out-Of-Page Slot

Currently no UI is available to configure these, but they can be added via HTML:

### Interstitial

```js
<script type="text/javascript">
    googletag.cmd.push(function() {
        var interstitialSlot = googletag.defineOutOfPageSlot('/6355419/Travel/Europe/France/Paris', googletag.enums.OutOfPageFormat.INTERSTITIAL);
        if (interstitialSlot) {
            interstitialSlot.addService(googletag.pubads());
            googletag.pubads().refresh([interstitialSlot]);
        }
    });
</script>
```

### Out Of Page

```js
<script type="text/javascript">
    googletag.cmd.push(function() {
        var slot = 'OOP-1';
        var wrapper = document.createElement('div');
        wrapper.id = slot;
        document.body.appendChild(wrapper);
        var oopSlot = googletag.defineOutOfPageSlot('/6355419/Travel/Europe/France/Paris', slot).addService(googletag.pubads());
        googletag.pubads().refresh([oopSlot]);
    });
</script>
```

## Slug Name and Style

```html
<style type="text/css">
    .ayManagerEnv_slug::before {
        content: 'Advertisement';
        text-transform: uppercase;
    }
</style>
```

## Sticky Close Button

This is an example of a sticky footer ad unit with a close button.

Make sure to replace `StickyBottom` with the manual placement ID.

```html
<div id="aymStickyFooter" class="empty">
    <div data-ay-manager-id="StickyBottom">
        <script type="text/javascript">
            window.ayManagerEnv = window.ayManagerEnv || { cmd: [] };
            window.ayManagerEnv.cmd.push(function() {
                ayManagerEnv.display("StickyBottom");
            });
        </script>
    </div>
    <div id="aymStickyFooterClose" onclick="window.ayManagerEnv.destroy(['StickyBottom']); try { document.getElementById('aymStickyFooter').remove(); } catch(e) {};">X</div>
</div>

<script>
    googletag.cmd.push(function() {
        googletag.pubads().addEventListener("slotRenderEnded", function(event) {
            if (event.slotContentChanged) {
                const slot = event.slot;
                const elemId = slot.getSlotElementId();
                if (elemId.toLowerCase().includes("sticky")) {
                    const sticky = document.getElementById("aymStickyFooter");
                    if (event.isEmpty) {
                        if (sticky.classList.contains("empty")) return;
                        sticky.classList.add("empty");
                    } else {
                        sticky.classList.remove("empty");
                    }
                }
            }
        });
    });
</script>

<style>
    #aymStickyFooter.empty {
        padding: 0;
        border-top: none;
    }
    #aymStickyFooter.empty #aymStickyFooterClose {
        display: none;
    }
    #aymStickyFooter {
        display: block;
        position: fixed;
        bottom: 0;
        background-color: white;
        border-top: 1px solid #efefef;
        z-index: 150;
        padding: 5px 5px 0;
        transform: translate(-50%);
        left: 50%;
    }
    #aymStickyFooterClose {
        position: absolute;
        top: -20px;
        right: 0;
        background-color: white;
        font-family: sans-serif;
        text-align: center;
        border-top: 1px solid gray;
        border-left: 1px solid gray;
        border-radius: 50% 0 0 0;
        padding: 3px;
        height: 20px;
        width: 20px;
        cursor: pointer;
        line-height: 10px;
        font-size: 14px;
        display: flex;
        justify-content: center;
        align-items: center;
    }
</style>
```

## Outstream Settings

To adjust default outstream video settings, use the following:

```js
<script type="text/javascript">
    ayManagerEnv.onEvent('prebidBeforeFetchBids', function(requestObj) {
        requestObj.adUnits.forEach(function(unit) {
            if (unit.mediaTypes.video && unit.mediaTypes.video.context === 'outstream') {
                unit.mediaTypes.video = {
                    context: 'outstream',
                    playerSize: [640, 480],
                    mimes: ['video/mp4', 'video/webm', 'application/javascript'],
                    api: [1, 2],
                    protocols: [1, 2, 3, 4, 5, 6, 7, 8],
                    playbackmethod: [2],
                    skip: 0,
                    placement: 2,
                    minduration: 5,
                    maxduration: 30
                };
            }
        });
    });
</script>
```

## ORTB2 Div ID

```js
<script>
ayManagerEnv.onEvent('prebidBeforeFetchBids', function(bidConfig) {
    bidConfig.adUnits.forEach(function(adUnit) {
        adUnit.ortb2Imp = adUnit.ortb2Imp || {};
        adUnit.ortb2Imp.ext = adUnit.ortb2Imp.ext || {};
        adUnit.ortb2Imp.ext.data = adUnit.ortb2Imp.ext.data || {};

        adUnit.ortb2Imp.ext.data.divId = adUnit.code;
        adUnit.ortb2Imp.ext.data.placement = adUnit.code.replace(/__ayManagerEnv__.+/, '');
    });
});
</script>
```

## IntentIQ

**Note:** Requires Prebid modules `userId`, `pubProvidedIdSystem`, and `unifiedIdSystem`.

**Conditions:**

* `isIIQsupportedGeo`: `'Country' regex 'US|CA|AU|NZ|JP|SG|MY|TH|PH|MX|BR'`
* `isIOS`: `function () { return /iPhone|iPad|iPod|ios-app/.test(window.navigator.userAgent || window.navigator.vendor || window.opera); }`

```js
<script type="text/javascript">
    (function() {
        const config = {
            partnerId: 0, // replace with your partner id
            revenueBias: 1, // can be set based on the partner's revenue share, e.g. 0.9 to subtract 10% revenue share
            reportGroupToCustomDimension: 'custom_8', // can be set to any custom_X dimension, to have the IntentIQ AB group reported to the AY analytics
            browserBlackList: ['chrome'],
        }

        const abGroups = { B: 'withoutIIQ', A: 'withIIQ', U: 'notYetDefined', N: 'none', L: 'blackList', T: 'initialized', O: 'optedOut' };
        let latestABGroup;
        let didCallback = false;
        let didTimeout = false;
        let didAuctionInit = false;
        window.assertiveQueue = window.assertiveQueue || [];
        function updateAnalytics(status) {
            if (config.reportGroupToCustomDimension) {
                const isIIQReady = didCallback || latestABGroup === 'L' || latestABGroup === 'O';
                if (!status && didAuctionInit && latestABGroup && isIIQReady) {
                    status = abGroups[latestABGroup] || ('unknown-' + latestABGroup);
                    if (didTimeout && latestABGroup === 'U') {
                        status = 'timeout';
                    }
                }
                if (status) {
                    window.assertiveQueue.push(function () {
                        assertive.setConfig('analytics.custom.' + config.reportGroupToCustomDimension, status);
                    });
                }
            }
            googletag.cmd.push(function() {
                googletag.pubads().setTargeting('intent_iq_group', (didCallback && didAuctionInit && latestABGroup) || 'U');
            });
        }
        updateAnalytics('pendingIIQ');

        const pbjs = window[ayManagerEnv.settings.prebidSettings.prebidScript.windowName];
        let externalReporting = false;
        let intentIq;
        const script = document.createElement('script');
        script.src = 'https://' + ayManagerEnv.versionInfo.entityId + '.ay.delivery/thirdparty/intentiq/IIQUniversalID-6.12.js';
        script.onload = function() {
            intentIq = new window.IntentIqObject({
                partner: config.partnerId,
                pbjs: pbjs,
                timeoutInMillis: 3000,
                manualWinReportEnabled: true,
                ABTestingConfigurationSource: 'IIQServer',
                domainName: window.location.hostname.replace('www.', ''),
                vrBrowserBlackList: typeof config.browserBlackList === 'string' ? config.browserBlackList.split(',') : config.browserBlackList,
                allowGDPR: {{ Is EEA GB or CH }},
                callback: function(eids, callbackType) {
                    didCallback = true;
                    didTimeout = callbackType === 'fireCallbackOnRequestTimeout';
                    externalReporting = latestABGroup === 'A' || latestABGroup === 'B';
                    updateAnalytics();
                },
                groupChanged: function(abGroup) {
                    latestABGroup = abGroup;
                    updateAnalytics();
                },
            });
            window['intentIq_' + config.partnerId] = intentIq;
            if (intentIq.intentIqConfig.mode === 'PIXEL') {
                updateAnalytics('blackList');
            }
        };
        document.head.appendChild(script);

        pbjs.que.push(function () {
            // waits for auction init before reporting the ab group, to not report it between auction and ad call
            const auctionInitEvent = function() {
                didAuctionInit = true;
                updateAnalytics();
                pbjs.offEvent('auctionInit', auctionInitEvent);
            };
            pbjs.onEvent('auctionInit', auctionInitEvent);
        });

        window.addEventListener('assertive_logImpression', function(event) {
            if (!externalReporting || !intentIq) {
                return;
            }
            const payload = event.data.payload;
            if (payload.unfilled || payload.sourceInternal !== 'gpt') {
                return;
            }

            payload.revenueBias = config.revenueBias;

            if (payload.preBidWon && payload.highestBid) {
                if (typeof intentIq.reportExternalWin === 'function') {
                    const highestBid = payload.highestBid;
                    const cpm = parseFloat(highestBid.cpm);
                    if (cpm <= 0 || cpm > 100) {
                        return;
                    }
                    intentIq.reportExternalWin({
                        biddingPlatformId: 1,
                        bidderCode: highestBid.bidderCode,
                        prebidAuctionId: highestBid.auctionId,
                        cpm,     
                        currency: highestBid.currency, 
                        originalCpm: parseFloat(highestBid.originalCpm),
                        originalCurrency: highestBid.originalCurrency,
                        status: highestBid.status,
                        placementId: highestBid.adUnitCode,
                    });
                }
            }
        });
    })();
</script>
```