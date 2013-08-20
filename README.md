# Appurify Gem

The official Ruby client for the [Appurify](http://www.appurify.com) API.

### Installation

```
gem install appurify
```

### Configuration

```
client = Appurify::Client.new(key, secret, options)
```

### Listing Device Types

```
device_types = client.device_types
device_type_id = client.device_types.first["device_type_id"]
```

### Uploading An Application

```
response = client.upload_app_from_url(app_url)
application_id = response["app_id"]
```

### Uploading A Test

```
test_type = "uiautomation"
response = client.upload_test_from_url(test_url, test_type)
test_id = response["test_id"]
```

### Starting A Test Run

```
response = client.run_test(device_type_id, application_id, test_id)
test_run_id = response["test_run_id"]
```

### Retrieve Test Run Results

```
response = client.monitor_test(test_run_id)
```

### Contribution

Found a bug or want to add a much needed feature?  Go for it and just send us the Pull Request!
