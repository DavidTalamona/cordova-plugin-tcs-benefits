# Method Documentation
## startTrackingLocationUpdates

Call:
```javascript
window['TCSPlugin'].startTrackingLocationUpdates((location) => {});
```

Result:
```json
{
  "latitude": 47.6791001,
  "longitude": 8.6253824,
  "accuracy": 21.195999145507812
}
```

## stopTrackingLocationUpdates

Call:
```javascript
window['TCSPlugin'].stopTrackingLocationUpdates();
```

Result:
```
void
```

## hasGpsPermission

Call:
```javascript
window['TCSPlugin'].hasGpsPermission((result) => {});
```

Result:
```
"0" (no GPS permission)
"1" (has GPS permission)
```

## requestGpsPermission

Call:
```javascript
window['TCSPlugin'].requestGpsPermission((result) => {});
```

Result:
```
"0" (permission not granted)
"1" (permission granted)
```

## storageSave

Call:
```javascript
window['TCSPlugin'].storageSave("Key", "Value");
```

Result:
```
void
```

## storageLoad

Call:
```javascript
window['TCSPlugin'].storageLoad("Key", (value) => {});
```

Result:
```
"value"
```

## storageClear

Call:
```javascript
window['TCSPlugin'].storageClear("Key");
```

Result:
```
void
```

## getMemberInfo

Call:
```javascript
window['TCSPlugin'].getMemberInfo((result) => {});
```

Result:
```
"" (if user is not logged in)
```
```json
{
  "memberNumber": "12345678",
  "email": "muster@tcs.ch",
  "sectionCode": "17"
}
```

## registerDeepLinks

Call:
```javascript
window['TCSPlugin'].registerDeepLinks((result) => {});
```

Result:
```json
{
  "type": "dynamicLink",
  "pathComponents": [ "value1", "value2" ],
  "data": {
    "key": "value"
  }
}
```

or

```json
{
  "type": "notification",
  "title": "title",
  "message": "message",
  "data": {
    "key": "value"
  }
}
```

## getPushToken

Call:
```javascript
window['TCSPlugin'].getPushToken((result) => {});
```

Result:
```
"pushToken"
```