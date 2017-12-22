# Method Documentation
## startTrackingLocationUpdates

Call:
```typescript
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
```typescript
window['TCSPlugin'].hasGpsPermission((result) => {});
```

Result:
```
"0" (no GPS permission)
"1" (has GPS permission)
```

## requestGpsPermission

Call:
```typescript
window['TCSPlugin'].requestGpsPermission("Ich brauche die Permission für...", (result) => {});
```

Result:
```
"0" (permission not granted)
"1" (permission granted)
```

## storageSave

Call:
```typescript
window['TCSPlugin'].storageSave("Key", "Value");
```

Result:
```
void
```

## storageLoad

Call:
```typescript
window['TCSPlugin'].storageLoad("Key", (value) => {});
```

Result:
```
"value"
```

## storageClear

Call:
```typescript
window['TCSPlugin'].storageClear("Key");
```

Result:
```
void
```

## getMemberInfo

Call:
```typescript
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
```typescript
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
```typescript
window['TCSPlugin'].getPushToken((result) => {});
```

Result:
```
"pushToken"
```

## navigateBack

Call:
```typescript
window['TCSPlugin'].navigateBack();
```

Result:
```
void
```

## enableSwipeBack (iOS only)

Call:
```typescript
window['TCSPlugin'].enableSwipeBack(true); // or .enableSwipeBack(false)
```

Result:
```
void
```
